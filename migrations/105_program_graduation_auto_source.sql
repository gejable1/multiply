-- migrations/105_program_graduation_auto_source.sql
-- Completion by GRADUATION, not by quiz accumulation.
--
-- WHAT WAS WRONG. Rosehill's two tracked rungs both auto-complete from
-- 'lesson:<course>:all' -- every active quiz of a course passed. But the church
-- does not finish courses that way. Usbong runs as rolling batches: a
-- participant graduates individually, at their own pace, inside a cohort that
-- stays active for the others. BTLI 101 runs plenary: the class works to the end
-- and the batch graduates together. The live diagnostic:
--   L0 usbong  -- 6 credited by quizzes, 10 who actually graduated, 1 in both.
--   L1 btli1   -- 3 credited by quizzes, ZERO graduations ever recorded, and the
--                 course is 11 of 20 lessons shipped inside a THREE-book program
--                 (Usad, Unlad + Leading Yourself).
-- The two routes were capturing almost disjoint populations: leaders work the
-- quizzes because they are preparing to teach; participants graduate a batch
-- without opening one.
--
-- WHAT THIS DOES NOT DO. It does not repoint any rung. Eleven other churches
-- carry the same base keys and may not run cohorts at all; changing their
-- behaviour from here would be a decision taken on their behalf. This migration
-- only teaches the vocabulary and the engine. Each church repoints its own rungs
-- in the editor, where the validator checks the key before publish.
--
-- WHY 'OR' AND NOT A MODE FLAG. A per-program 'rolling|plenary' setting would
-- have to be kept in step with how the batch is actually closed. The OR needs no
-- setting and is robust to which row the admin updates -- member, cohort, or
-- both give the same answer.
--
-- TEACHERS ARE EXCLUDED. A teacher's membership also satisfies "cohort graduated
-- and did not withdraw". One Rosehill teacher graduation lasted four minutes
-- (joined 08:57:47, exited 09:01:49) -- cohort admin, not formation. Teachers
-- still earn the rung through the lesson arms, on quizzes they actually passed.
--
-- INSERT-ONLY. Like every arm in 094, this one is ON CONFLICT DO NOTHING. It
-- cannot disturb the manual marks a pastor made for members whose Usbong
-- predates the pipeline, and it cannot remove a completion.
--
-- Flat (#209), gate inside the transaction (#413), three-state pre-gate (#422),
-- self-verifying on its own effects (#403), ledger-stamped (#402).

BEGIN;

-- ---------------------------------------------------------------- 1. the key
-- Deriving a key from the display name would be fragile: the BTLI program is
-- called 'BTLI 101 (Usad, Unlad+Leading Yourself)'. A stable column instead.
ALTER TABLE public.cohort_programs ADD COLUMN IF NOT EXISTS program_key text;

-- PRE-GATE (three-state, #422). Exactly one program must carry each course code,
-- or program_key is ambiguous and the arm would credit the wrong cohort.
DO $$
DECLARE n_usbong bigint; n_btli bigint;
BEGIN
  SELECT count(*) INTO n_usbong FROM public.cohort_programs WHERE usbong_course_code = 'Usbong';
  SELECT count(*) INTO n_btli   FROM public.cohort_programs WHERE btli_course_code   = 'BTLI 1';
  IF n_usbong = 0 THEN
    RAISE EXCEPTION '105 PRE-GATE FAILED (too few) -- no cohort_programs row carries usbong_course_code = Usbong';
  ELSIF n_usbong > 1 THEN
    RAISE EXCEPTION '105 PRE-GATE FAILED (too many) -- % rows carry usbong_course_code = Usbong; program_key would be ambiguous', n_usbong;
  END IF;
  IF n_btli = 0 THEN
    RAISE EXCEPTION '105 PRE-GATE FAILED (too few) -- no cohort_programs row carries btli_course_code = BTLI 1';
  ELSIF n_btli > 1 THEN
    RAISE EXCEPTION '105 PRE-GATE FAILED (too many) -- % rows carry btli_course_code = BTLI 1; program_key would be ambiguous', n_btli;
  END IF;
  RAISE NOTICE '105 pre-gate OK: exactly one Usbong program and one BTLI program';
END $$;

UPDATE public.cohort_programs
   SET program_key = 'usbong', updated_at = now()
 WHERE usbong_course_code = 'Usbong';

UPDATE public.cohort_programs
   SET program_key = 'btli101', updated_at = now()
 WHERE btli_course_code = 'BTLI 1';

-- One program_key per church. NULLS NOT DISTINCT so two shared programs
-- (church_id IS NULL) cannot both claim the same key.
CREATE UNIQUE INDEX IF NOT EXISTS cohort_programs_program_key_uk
  ON public.cohort_programs (church_id, program_key) NULLS NOT DISTINCT
  WHERE program_key IS NOT NULL;

-- --------------------------------------------------------- 2. the vocabulary
-- pathway_auto_source_ok() delegates here, so one arm teaches the editor
-- picklist, the validator, and publish at once (#405). SECURITY INVOKER, so a
-- church sees only the programs it can read.
CREATE OR REPLACE FUNCTION public.pathway_auto_source_options()
RETURNS TABLE(key text, label_en text, kind text)
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public
AS $fn$
  SELECT v.key, v.label_en, v.kind
    FROM (VALUES
      ('assessment:gifts',     'Spiritual Gifts assessment completed', 'assessment'),
      ('assessment:salvation', 'Salvation diagnostic completed',       'assessment'),
      ('assessment:disc',      'DISC assessment completed',            'assessment'),
      ('assessment:strengths', 'Strengths assessment completed',       'assessment'),
      ('assessment:conflict',  'Conflict style assessment completed',  'assessment')
    ) v(key, label_en, kind)
  UNION ALL
  -- BOTH lesson tables, mirroring the TWO arms in 094 (:97-117, :119-138).
  -- library_quizzes is excluded deliberately -- see 102 header note (1).
  SELECT 'lesson:' || q.cc || ':all',
         'All active lessons passed: ' || min(q.course_code),
         'lesson'
    FROM (
      SELECT lower(replace(course_code, ' ', '')) AS cc, course_code
        FROM public.btli_quizzes   WHERE is_active IS TRUE
      UNION ALL
      SELECT lower(replace(course_code, ' ', '')) AS cc, course_code
        FROM public.usbong_quizzes WHERE is_active IS TRUE
    ) q
   GROUP BY q.cc
  UNION ALL
  SELECT 'streak:devotional:' || s.n,
         'Devotional streak reached ' || s.n || ' days',
         'streak'
    FROM (VALUES (7),(14),(21),(30),(40),(60),(90),(100),(365)) s(n)
  UNION ALL
  -- NEW (105): graduation. Mirrors the program arm in auto_complete_pathway_rungs().
  SELECT 'program:' || p.program_key || ':complete',
         'Graduated the program: ' || min(p.name),
         'program'
    FROM public.cohort_programs p
   WHERE p.program_key IS NOT NULL
     AND p.is_active IS TRUE
   GROUP BY p.program_key;
$fn$;

COMMENT ON FUNCTION public.pathway_auto_source_options() IS
  'The auto-complete vocabulary, expanded to concrete choices. Feeds the editor picklist AND pathway_auto_source_ok, so the rule has one home. Must stay in step with auto_complete_pathway_rungs() (094 + 105), which is where these strings are actually consumed -- INCLUDING BOTH lesson arms and the program arm. Reading only the first arm is what produced the 13 false positives in Session 83 (#416).';

-- ------------------------------------------------------------- 3. the engine
-- Lifted verbatim from 094 with ONE arm added, so no existing arm can be lost
-- in transcription. 6 arms in, 7 arms out.
CREATE OR REPLACE FUNCTION public.auto_complete_pathway_rungs()
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $fn$
DECLARE n_before bigint; n_after bigint;
BEGIN
  SELECT count(*) INTO n_before FROM pathway_progress;

  -- ===== ASSESSMENTS =====
  INSERT INTO pathway_progress (church_id, member_id, level, rung_key, completed_at, marked_by, note)
  SELECT g.church_id, g.member_id, e.level, e.rung_key, (min(g.date_taken))::timestamptz, NULL, 'auto:'||e.auto_source_key
  FROM gifts_diagnostic g
  JOIN v_effective_auto_rungs e
    ON e.church_id = g.church_id AND e.auto_source_key = 'assessment:gifts'
  WHERE g.member_id IS NOT NULL AND g.church_id IS NOT NULL AND g.date_taken IS NOT NULL
  GROUP BY g.church_id, g.member_id, e.level, e.rung_key, e.auto_source_key
  ON CONFLICT (church_id, member_id, level, rung_key) DO NOTHING;

  INSERT INTO pathway_progress (church_id, member_id, level, rung_key, completed_at, marked_by, note)
  SELECT dr.church_id, dr.member_id, e.level, e.rung_key, (min(dr.date_taken))::timestamptz, NULL, 'auto:'||e.auto_source_key
  FROM diagnostic_results dr
  JOIN v_effective_auto_rungs e
    ON e.church_id = dr.church_id AND e.auto_source_key = 'assessment:salvation'
  WHERE dr.member_id IS NOT NULL AND dr.church_id IS NOT NULL AND dr.date_taken IS NOT NULL
  GROUP BY dr.church_id, dr.member_id, e.level, e.rung_key, e.auto_source_key
  ON CONFLICT (church_id, member_id, level, rung_key) DO NOTHING;

  INSERT INTO pathway_progress (church_id, member_id, level, rung_key, completed_at, marked_by, note)
  SELECT mp.church_id, mp.member_id, e.level, e.rung_key, (min(mp.date_taken))::timestamptz, NULL, 'auto:'||e.auto_source_key
  FROM member_profiles mp
  JOIN v_effective_auto_rungs e
    ON e.church_id = mp.church_id
   AND e.auto_source_key = CASE mp.profile_type
         WHEN 'disc' THEN 'assessment:disc'
         WHEN 'strengths' THEN 'assessment:strengths'
         WHEN 'conflict_style' THEN 'assessment:conflict' END
  WHERE mp.profile_type IN ('disc','strengths','conflict_style')
    AND mp.member_id IS NOT NULL AND mp.church_id IS NOT NULL AND mp.date_taken IS NOT NULL
  GROUP BY mp.church_id, mp.member_id, e.level, e.rung_key, e.auto_source_key
  ON CONFLICT (church_id, member_id, level, rung_key) DO NOTHING;

  -- ===== LESSONS: passed EVERY active lesson of the course =====
  WITH tot AS (
    SELECT lower(replace(course_code,' ','')) AS cc, count(DISTINCT lesson_number) AS total
    FROM btli_quizzes WHERE is_active IS TRUE GROUP BY 1
  ),
  passed AS (
    SELECT a.church_id, a.member_id, lower(replace(q.course_code,' ','')) AS cc,
           count(DISTINCT q.lesson_number) AS passed_lessons, max(a.submitted_at) AS done_at
    FROM btli_quiz_attempts a JOIN btli_quizzes q ON q.id=a.quiz_id
    WHERE a.passed IS TRUE AND a.member_id IS NOT NULL AND a.church_id IS NOT NULL
    GROUP BY a.church_id, a.member_id, 3
  )
  INSERT INTO pathway_progress (church_id, member_id, level, rung_key, completed_at, marked_by, note)
  SELECT p.church_id, p.member_id, e.level, e.rung_key, p.done_at, NULL, 'auto:'||e.auto_source_key
  FROM passed p JOIN tot t ON t.cc = p.cc
  JOIN v_effective_auto_rungs e
    ON e.church_id = p.church_id
   AND e.auto_source_key LIKE 'lesson:%:all'
   AND split_part(e.auto_source_key,':',2) = p.cc
  WHERE t.total > 0 AND p.passed_lessons >= t.total
  ON CONFLICT (church_id, member_id, level, rung_key) DO NOTHING;

  WITH tot AS (
    SELECT lower(replace(course_code,' ','')) AS cc, count(DISTINCT lesson_number) AS total
    FROM usbong_quizzes WHERE is_active IS TRUE GROUP BY 1
  ),
  passed AS (
    SELECT a.church_id, a.member_id, lower(replace(q.course_code,' ','')) AS cc,
           count(DISTINCT q.lesson_number) AS passed_lessons, max(a.submitted_at) AS done_at
    FROM usbong_quiz_attempts a JOIN usbong_quizzes q ON q.id=a.quiz_id
    WHERE a.passed IS TRUE AND a.member_id IS NOT NULL AND a.church_id IS NOT NULL
    GROUP BY a.church_id, a.member_id, 3
  )
  INSERT INTO pathway_progress (church_id, member_id, level, rung_key, completed_at, marked_by, note)
  SELECT p.church_id, p.member_id, e.level, e.rung_key, p.done_at, NULL, 'auto:'||e.auto_source_key
  FROM passed p JOIN tot t ON t.cc = p.cc
  JOIN v_effective_auto_rungs e
    ON e.church_id = p.church_id
   AND e.auto_source_key LIKE 'lesson:%:all'
   AND split_part(e.auto_source_key,':',2) = p.cc
  WHERE t.total > 0 AND p.passed_lessons >= t.total
  ON CONFLICT (church_id, member_id, level, rung_key) DO NOTHING;

  -- ===== STREAKS: ever reached N consecutive >=10-word devotional days =====
  INSERT INTO pathway_progress (church_id, member_id, level, rung_key, completed_at, marked_by, note)
  SELECT s.church_id, s.member_id, e.level, e.rung_key, s.milestone::timestamptz, NULL, 'auto:'||e.auto_source_key
  FROM v_effective_auto_rungs e
  JOIN LATERAL (
    WITH qual AS (
      SELECT DISTINCT member_id, church_id, entry_date
      FROM devotional_reflections
      WHERE reflection IS NOT NULL AND btrim(reflection) <> ''
        AND array_length(regexp_split_to_array(btrim(reflection), '\s+'), 1) >= 10
        AND member_id IS NOT NULL AND church_id IS NOT NULL
    ),
    grp AS (
      SELECT member_id, church_id, entry_date,
             entry_date - (row_number() OVER (PARTITION BY member_id ORDER BY entry_date))::int AS g
      FROM qual
    ),
    runs AS (
      SELECT member_id, church_id, min(entry_date) AS start_date, count(*) AS len
      FROM grp GROUP BY member_id, church_id, g
    )
    SELECT member_id, church_id,
           min(start_date + (split_part(e.auto_source_key,':',3)::int - 1)) AS milestone
    FROM runs
    WHERE len >= split_part(e.auto_source_key,':',3)::int
      AND church_id = e.church_id
    GROUP BY member_id, church_id
  ) s ON TRUE
  WHERE e.auto_source_key LIKE 'streak:devotional:%'
  ON CONFLICT (church_id, member_id, level, rung_key) DO NOTHING;

  -- ===== PROGRAMS: graduated the batch =====
  -- Two models, one rule. Usbong is ROLLING -- each participant graduates at
  -- their own pace inside a still-active cohort. BTLI 101 is PLENARY -- the
  -- class runs to the end of the lessons and everyone graduates together.
  -- The OR covers both, and is robust to WHICH row the admin updates: member,
  -- cohort, or both land the same result. A rule that needs two tables kept in
  -- step is a rule that quietly stops working.
  -- Teachers are excluded. A teacher's membership also satisfies "cohort
  -- graduated and did not withdraw", and one Rosehill teacher graduation lasted
  -- four minutes -- cohort admin, not formation. Teachers still earn the rung
  -- through the lesson arms above, on the quizzes they actually passed.
  INSERT INTO pathway_progress (church_id, member_id, level, rung_key, completed_at, marked_by, note)
  SELECT cm.church_id, cm.member_id, e.level, e.rung_key,
         min(coalesce(cm.exited_at, co.end_date::timestamptz, cm.joined_at)),
         NULL, 'auto:'||e.auto_source_key
  FROM cohort_members cm
  JOIN cohorts co         ON co.id = cm.cohort_id
  JOIN cohort_programs p  ON p.id  = co.program_id
  JOIN v_effective_auto_rungs e
    ON e.church_id = cm.church_id
   AND e.auto_source_key LIKE 'program:%:complete'
   AND split_part(e.auto_source_key,':',2) = p.program_key
  WHERE cm.member_id IS NOT NULL AND cm.church_id IS NOT NULL
    AND p.program_key IS NOT NULL
    AND cm.role IN ('participant','apprentice')
    AND ( cm.status = 'graduated'
          OR (co.status = 'graduated' AND cm.status <> 'withdrew') )
  GROUP BY cm.church_id, cm.member_id, e.level, e.rung_key, e.auto_source_key
  ON CONFLICT (church_id, member_id, level, rung_key) DO NOTHING;

  SELECT count(*) INTO n_after FROM pathway_progress;
  RETURN (n_after - n_before)::int;
END;
$fn$;

GRANT EXECUTE ON FUNCTION public.auto_complete_pathway_rungs() TO service_role;

-- POST-GATE (i). The two new keys must be recognised by the SAME acceptance
-- rule the validator and publish use. Proved by deliberate failure: a key that
-- cannot exist must be rejected, or the check is vacuous.
DO $$
BEGIN
  IF NOT public.pathway_auto_source_ok('program:usbong:complete') THEN
    RAISE EXCEPTION '105 VOCABULARY GATE FAILED -- program:usbong:complete is not recognised';
  END IF;
  IF NOT public.pathway_auto_source_ok('program:btli101:complete') THEN
    RAISE EXCEPTION '105 VOCABULARY GATE FAILED -- program:btli101:complete is not recognised';
  END IF;
  IF public.pathway_auto_source_ok('program:doesnotexist:complete') THEN
    RAISE EXCEPTION '105 VOCABULARY GATE FAILED -- a nonexistent program key was ACCEPTED, so the check proves nothing';
  END IF;
  RAISE NOTICE '105 post-gate (i) OK: both program keys accepted, a bogus one rejected';
END $$;

-- POST-GATE (ii). No rung anywhere may now carry an auto source the engine
-- cannot honour. This is the check 103 used; it must still hold.
DO $$
DECLARE n bigint;
BEGIN
  SELECT count(*) INTO n FROM public.v_effective_auto_rungs e
   WHERE NOT public.pathway_auto_source_ok(e.auto_source_key);
  IF n <> 0 THEN
    RAISE EXCEPTION '105 VOCABULARY GATE FAILED -- % reachable rungs carry an unrecognised auto source', n;
  END IF;
  RAISE NOTICE '105 post-gate (ii) OK: live_bad_auto_keys = 0';
END $$;

-- POST-GATE (iii). The arm this migration ADDS must have changed nobody's
-- pathway: no rung has been repointed yet, so it can have nothing to honour.
-- It measures the PROGRAM ARM specifically, by counting its own note prefix
-- before and after. An earlier draft demanded the whole engine return 0 and
-- failed on the live database -- correctly: the engine also runs six older arms
-- and had a genuine backlog waiting. "My arm did nothing" and "the engine did
-- nothing" are different claims, and only the first is this migration's to make.
-- The incidental total is reported, not suppressed.
DO $$
DECLARE n_before bigint; n_after bigint; n_total int;
BEGIN
  SELECT count(*) INTO n_before FROM public.pathway_progress WHERE note LIKE 'auto:program:%';
  SELECT public.auto_complete_pathway_rungs() INTO n_total;
  SELECT count(*) INTO n_after  FROM public.pathway_progress WHERE note LIKE 'auto:program:%';
  IF n_after <> n_before THEN
    RAISE EXCEPTION '105 EFFECT GATE FAILED -- the program arm wrote % rows, but no rung points at a program yet', n_after - n_before;
  END IF;
  RAISE NOTICE '105 post-gate (iii) OK: program arm wrote 0 rows; engine total this run = % (pre-existing arms catching up)', n_total;
END $$;

INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('105','105_program_graduation_auto_source.sql','Graduation as an auto-complete source: program_key on cohort_programs, program:<key>:complete in the vocabulary, and a seventh arm in auto_complete_pathway_rungs that credits a member who graduated a batch as participant/apprentice (rolling) or was still enrolled when the cohort graduated (plenary). Teachers excluded. Insert-only. No rung repointed -- each church chooses in the editor')
ON CONFLICT (version) DO UPDATE SET filename=excluded.filename, note=excluded.note, applied_at=now();

COMMIT;

-- SELF-VERIFY -- expect all_ok = PASS. Emits a visible row either way (#403).
SELECT
  (SELECT count(*) FROM public.cohort_programs WHERE program_key IS NOT NULL)        AS programs_keyed,
  (SELECT count(*) FROM public.pathway_auto_source_options() WHERE kind='program')   AS program_options_offered,
  (SELECT count(*) FROM pg_proc WHERE proname='auto_complete_pathway_rungs'
      AND prosrc LIKE '%cohort_members%')                                            AS engine_has_program_arm,
  (SELECT count(*) FROM pg_indexes WHERE indexname='cohort_programs_program_key_uk') AS program_key_unique,
  (SELECT count(*) FROM public.pathway_rungs
    WHERE auto_source_key LIKE 'program:%')                                          AS rungs_repointed_expect_0,
  CASE WHEN (SELECT count(*) FROM public.cohort_programs WHERE program_key IS NOT NULL) = 2
        AND (SELECT count(*) FROM public.pathway_auto_source_options() WHERE kind='program') = 2
        AND (SELECT count(*) FROM pg_proc WHERE proname='auto_complete_pathway_rungs'
               AND prosrc LIKE '%cohort_members%') = 1
        AND (SELECT count(*) FROM pg_indexes WHERE indexname='cohort_programs_program_key_uk') = 1
       THEN 'PASS' ELSE 'FAIL' END                                                   AS all_ok;
