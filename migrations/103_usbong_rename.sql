-- 103_usbong_rename.sql
-- Session 84. Renames the Usbong curriculum identifier from 'Usbong 1' to 'Usbong'
-- across every column that carries it as a KEY or a LIVE LABEL, in ONE transaction.
--
-- WHY
--
-- Invariant #30 mandated natural names with a space and a number. The Session 84
-- addendum narrows that: a number belongs in a curriculum identifier only when the
-- curriculum is part of a SERIES. There is no Usbong 2 and none is planned, so the
-- number is noise. BTLI keeps its number -- BTLI 2 is anticipated and the cohort-slug
-- convention (btli201_xxxxxx) already reserves it.
--
-- WHY THIS IS ONE TRANSACTION AND NOT FIFTEEN
--
-- Two pairs of columns are compared against EACH OTHER at runtime, and both sides
-- must move together or the comparison silently starts failing:
--
--   (a) usbong_quizzes.attendance_event_name_pattern  vs  attendance.event_name
--       multiply_shared.js lowercases both and substring-matches
--       (n.includes(pattern)). 233 historical attendance rows. If the pattern moves
--       and the event names do not, every member loses the attendance path to Usbong
--       eligibility -- silently, with no error anywhere.
--
--   (b) cohort_programs.usbong_course_code  vs  usbong_quizzes.course_code
--       compared with strict equality (e.usbong_course_code === courseCode). Move one
--       side only and enrolled members lose the enrollment path.
--
-- Neither comparison is hard-coded in the frontend, so NO code change is needed for
-- them -- only simultaneity. The one file that DID hard-code the name
-- (usbong_quiz_player.html) was fixed in PR #270 and now resolves the course from the
-- data with ilike 'usbong%', which matches either spelling. That is why this migration
-- can run at any time after #270 merged, in either order relative to a deploy.
--
-- WHY A REGEX AND NOT replace()
--
-- The stored forms are not uniform. A survey of actual values found four shapes:
--     'Usbong 1 . L1 . ...'      title case, space-delimited
--     'usbong 1 . l1 .'          lower case (the matching pattern)
--     'Faith_USBONG 1'           UPPER case, at END of string -- no trailing space
--     'TAPOS NA ANG USBONG 1!'   UPPER case, followed by '!'
-- replace(x,'Usbong 1 ','Usbong ') silently misses the last two. So prose columns use
--     regexp_replace(col, '(usbong) 1\M', '\1', 'gi')
-- which is case-insensitive when matching but case-PRESERVING when substituting (\1
-- reinstates whatever case was found), and anchors on \M (end of word) so a
-- hypothetical 'Usbong 10' can never become 'Usbong 0'. Columns whose whole value is
-- known exactly are set by equality instead, because an exact set is stronger than a
-- rewrite.
--
-- WHAT IS DELIBERATELY NOT RENAMED
--
--   notifications.body (2), notifications.payload (2)
--       Messages already delivered and read. Rewriting them makes the record disagree
--       with what the member actually received.
--   attendance_self_attest_log.meta (8)
--       An append-only audit log; member_tool.html only ever INSERTs to it and nothing
--       reads meta->>'event_type' for matching, so a stale string breaks nothing. An
--       audit trail records what was asserted at the time. Editing it would defeat it.
--
-- These three are not oversights, and the final gate PINS THEM at their exact counts
-- so that what was left behind stays provable rather than merely claimed.
--
-- Flat (#209), self-verifying on its own effects (#403), stamped (#402), LF-only
-- ASCII (#242 -- note that the separator character in the data is never typed here;
-- every transform is expressed without it). Every gate is INSIDE the transaction and
-- was proved by deliberate failure on ephemeral PG16 (#413).

BEGIN;

-- ============================ PRE-GATE ============================
-- Production must look exactly as surveyed. If any count differs, the survey is stale
-- and the correct response is to re-run it and update these constants -- never to
-- loosen the gate.
CREATE TEMP TABLE _103_expect(surface text PRIMARY KEY, kind text, n_expected bigint, n_found bigint)
  ON COMMIT DROP;

INSERT INTO _103_expect(surface, kind, n_expected, n_found) VALUES
 ('usbong_quizzes.course_code', 'rename', 10,
   (SELECT count(*) FROM public.usbong_quizzes WHERE course_code = 'Usbong 1')),
 ('usbong_quizzes.attendance_event_name_pattern', 'rename', 10,
   (SELECT count(*) FROM public.usbong_quizzes WHERE attendance_event_name_pattern ~* 'usbong 1')),
 ('usbong_quizzes.intro_text', 'rename', 1,
   (SELECT count(*) FROM public.usbong_quizzes WHERE intro_text ~* 'usbong 1')),
 ('usbong_quizzes.outro_pass_text', 'rename', 1,
   (SELECT count(*) FROM public.usbong_quizzes WHERE outro_pass_text ~* 'usbong 1')),
 ('attendance.event_name', 'rename', 233,
   (SELECT count(*) FROM public.attendance WHERE event_name ~* 'usbong 1')),
 ('cohort_programs.usbong_course_code', 'rename', 1,
   (SELECT count(*) FROM public.cohort_programs WHERE usbong_course_code = 'Usbong 1')),
 ('cohorts.name', 'rename', 1,
   (SELECT count(*) FROM public.cohorts WHERE name ~* 'usbong 1')),
 ('pathway_rungs.rung_key', 'rename', 13,
   (SELECT count(*) FROM public.pathway_rungs WHERE rung_key = 'usbong1')),
 ('pathway_rungs.auto_source_key', 'rename', 13,
   (SELECT count(*) FROM public.pathway_rungs WHERE auto_source_key = 'lesson:usbong1:all')),
 ('pathway_rungs.title_en', 'rename', 13,
   (SELECT count(*) FROM public.pathway_rungs WHERE title_en ~* 'usbong 1')),
 ('pathway_rungs.title_tl', 'rename', 13,
   (SELECT count(*) FROM public.pathway_rungs WHERE title_tl ~* 'usbong 1')),
 ('pathway_progress.rung_key', 'rename', 6,
   (SELECT count(*) FROM public.pathway_progress WHERE rung_key = 'usbong1')),
 ('pathway_progress.note', 'rename', 4,
   (SELECT count(*) FROM public.pathway_progress WHERE note = 'auto:lesson:usbong1:all')),
 ('pathway_versions.doc', 'rename', 12,
   (SELECT count(*) FROM public.pathway_versions
     WHERE doc::text ~* 'usbong 1' OR doc::text LIKE '%usbong1%')),
 ('pipeline_lessons.aim', 'rename', 1,
   (SELECT count(*) FROM public.pipeline_lessons WHERE aim ~* 'usbong 1')),
 -- the three that must NOT move
 ('LEAVE notifications.body', 'leave', 2,
   (SELECT count(*) FROM public.notifications WHERE body ~* 'usbong 1')),
 ('LEAVE notifications.payload', 'leave', 2,
   (SELECT count(*) FROM public.notifications WHERE payload::text ~* 'usbong 1')),
 ('LEAVE attendance_self_attest_log.meta', 'leave', 8,
   (SELECT count(*) FROM public.attendance_self_attest_log WHERE meta::text ~* 'usbong 1'));

DO $$
DECLARE bad text; n_pending bigint; n_done bigint; n_rename bigint;
BEGIN
  -- Leave-behinds must ALWAYS equal their surveyed count, in either state.
  SELECT string_agg(surface || ': expected ' || n_expected || ', found ' || n_found, '; ' ORDER BY surface)
    INTO bad FROM _103_expect WHERE kind = 'leave' AND n_expected IS DISTINCT FROM n_found;
  IF bad IS NOT NULL THEN
    RAISE EXCEPTION '103 PRE-GATE FAILED -- a column that must NOT be renamed has changed: %', bad;
  END IF;

  -- Every rename surface must be in the SAME state: all still carrying the old form
  -- (pending), or all already clear (a rerun). A MIXED state means a previous run
  -- half-applied, or production drifted, and must never be papered over.
  SELECT count(*) FILTER (WHERE n_found = n_expected),
         count(*) FILTER (WHERE n_found = 0),
         count(*)
    INTO n_pending, n_done, n_rename
    FROM _103_expect WHERE kind = 'rename';

  IF n_pending = n_rename THEN
    RAISE NOTICE '103 pre-gate OK: all % rename surfaces pending, leave-behinds intact', n_rename;
  ELSIF n_done = n_rename THEN
    RAISE NOTICE '103 pre-gate OK: already applied -- all % rename surfaces already clear; statements below will no-op and the gates will re-verify', n_rename;
  ELSE
    SELECT string_agg(surface || ': expected ' || n_expected || ' or 0, found ' || n_found, '; ' ORDER BY surface)
      INTO bad FROM _103_expect
     WHERE kind = 'rename' AND n_found <> n_expected AND n_found <> 0;
    RAISE EXCEPTION '103 PRE-GATE FAILED -- rename surfaces are in a MIXED state (% pending, % already done, of %). Re-run the survey and correct the constants; do not loosen this gate. Offending: %',
      n_pending, n_done, n_rename, COALESCE(bad, '(counts differ but none individually off -- inspect _103_expect)');
  END IF;
END $$;

-- Baseline the two runtime comparisons BEFORE touching anything, so we can prove they
-- are unchanged afterwards. position() is the exact mirror of the JS .includes().
CREATE TEMP TABLE _103_runtime(phase text, metric text, n bigint) ON COMMIT DROP;

INSERT INTO _103_runtime(phase, metric, n)
SELECT 'before', 'eligibility_matches', count(*)
  FROM public.attendance a
  JOIN public.usbong_quizzes q
    ON q.is_active IS TRUE
   AND COALESCE(q.attendance_event_name_pattern,'') <> ''
   AND position(q.attendance_event_name_pattern IN lower(a.event_name)) > 0;

-- No attendance row may match more than one lesson. This is what the trailing
-- separator in the pattern protects: without it, the l1 pattern swallows every l10
-- event. Proving it holds before AND after is stronger than checking l1/l10 by hand.
INSERT INTO _103_runtime(phase, metric, n)
SELECT 'before', 'ambiguous_attendance', count(*) FROM (
  SELECT a.id
    FROM public.attendance a
    JOIN public.usbong_quizzes q
      ON q.is_active IS TRUE
     AND COALESCE(q.attendance_event_name_pattern,'') <> ''
     AND position(q.attendance_event_name_pattern IN lower(a.event_name)) > 0
   GROUP BY a.id HAVING count(*) > 1) x;

INSERT INTO _103_runtime(phase, metric, n)
SELECT 'before', 'enrollment_matches', count(*)
  FROM public.cohort_programs cp
  JOIN public.usbong_quizzes q ON q.course_code = cp.usbong_course_code;

-- ============================ THE RENAME ============================

-- 1-4. usbong_quizzes: the code, the matching pattern, and two prose columns. One
-- statement so a row can never be half-renamed.
UPDATE public.usbong_quizzes
   SET course_code                   = 'Usbong',
       attendance_event_name_pattern = regexp_replace(attendance_event_name_pattern, '(usbong) 1\M', '\1', 'gi'),
       intro_text                    = regexp_replace(intro_text,                    '(usbong) 1\M', '\1', 'gi'),
       outro_pass_text               = regexp_replace(outro_pass_text,               '(usbong) 1\M', '\1', 'gi'),
       outro_fail_text               = regexp_replace(outro_fail_text,               '(usbong) 1\M', '\1', 'gi'),
       lesson_title                  = regexp_replace(lesson_title,                  '(usbong) 1\M', '\1', 'gi'),
       updated_at                    = now()
 WHERE course_code = 'Usbong 1';

-- 5. attendance.event_name -- 233 historical rows, the other half of comparison (a).
UPDATE public.attendance
   SET event_name = regexp_replace(event_name, '(usbong) 1\M', '\1', 'gi'),
       updated_at = now()
 WHERE event_name ~* 'usbong 1';

-- 6. cohort_programs -- the other half of comparison (b).
UPDATE public.cohort_programs
   SET usbong_course_code = 'Usbong'
 WHERE usbong_course_code = 'Usbong 1';

-- 7. cohorts.name -- a live label members see ('Faith_USBONG 1'). Upper case and at
-- the end of the string, which is exactly the shape a plain replace would miss.
UPDATE public.cohorts
   SET name = regexp_replace(name, '(usbong) 1\M', '\1', 'gi')
 WHERE name ~* 'usbong 1';

-- 8-11. pathway_rungs: two keys set by equality, two prose titles by regex.
UPDATE public.pathway_rungs
   SET rung_key        = 'usbong',
       auto_source_key = 'lesson:usbong:all',
       title_en        = regexp_replace(title_en, '(usbong) 1\M', '\1', 'gi'),
       title_tl        = regexp_replace(title_tl, '(usbong) 1\M', '\1', 'gi'),
       updated_at      = now()
 WHERE rung_key = 'usbong1';

-- 12-13. pathway_progress. rung_key is text with no FK to pathway_rungs, so member
-- history does NOT follow automatically -- these 6 rows are the completions of the
-- rung being renamed, and missing them would erase six members' progress. note holds
-- machine-written provenance ('auto:lesson:usbong1:all'), not a human's words, so it
-- is a key and moves too.
UPDATE public.pathway_progress
   SET rung_key = 'usbong'
 WHERE rung_key = 'usbong1';

UPDATE public.pathway_progress
   SET note = 'auto:lesson:usbong:all'
 WHERE note = 'auto:lesson:usbong1:all';

-- 14. pathway_versions.doc -- the published pipeline document for all 12 churches.
-- Exact key forms first, then prose. jsonb round-trips through text; key ORDER may
-- normalise but jsonb is already order-normalised, so the value is unchanged.
UPDATE public.pathway_versions
   SET doc = regexp_replace(
               replace(
                 replace(doc::text, '"usbong1"', '"usbong"'),
                 'lesson:usbong1:all', 'lesson:usbong:all'),
               '(usbong) 1\M', '\1', 'gi')::jsonb,
       updated_at = now()
 WHERE doc::text ~* 'usbong 1' OR doc::text LIKE '%usbong1%';

-- 15. pipeline_lessons.aim -- curriculum prose.
UPDATE public.pipeline_lessons
   SET aim = regexp_replace(aim, '(usbong) 1\M', '\1', 'gi')
 WHERE aim ~* 'usbong 1';

-- ============================ POST-GATES ============================

-- (i) Every renamed surface must now be empty of the old form, and the three
--     deliberate leave-behinds must be untouched at their exact counts.
DO $$
DECLARE bad text; n bigint;
BEGIN
  bad := '';
  SELECT count(*) INTO n FROM public.usbong_quizzes
    WHERE course_code ~* 'usbong 1' OR attendance_event_name_pattern ~* 'usbong 1'
       OR intro_text ~* 'usbong 1' OR outro_pass_text ~* 'usbong 1'
       OR outro_fail_text ~* 'usbong 1' OR lesson_title ~* 'usbong 1';
  IF n <> 0 THEN bad := bad || format('usbong_quizzes:%s; ', n); END IF;

  SELECT count(*) INTO n FROM public.attendance WHERE event_name ~* 'usbong 1';
  IF n <> 0 THEN bad := bad || format('attendance.event_name:%s; ', n); END IF;

  SELECT count(*) INTO n FROM public.cohort_programs WHERE usbong_course_code ~* 'usbong 1';
  IF n <> 0 THEN bad := bad || format('cohort_programs:%s; ', n); END IF;

  SELECT count(*) INTO n FROM public.cohorts WHERE name ~* 'usbong 1';
  IF n <> 0 THEN bad := bad || format('cohorts.name:%s; ', n); END IF;

  SELECT count(*) INTO n FROM public.pathway_rungs
    WHERE rung_key = 'usbong1' OR auto_source_key LIKE '%usbong1%'
       OR title_en ~* 'usbong 1' OR title_tl ~* 'usbong 1';
  IF n <> 0 THEN bad := bad || format('pathway_rungs:%s; ', n); END IF;

  SELECT count(*) INTO n FROM public.pathway_progress
    WHERE rung_key = 'usbong1' OR note LIKE '%usbong1%';
  IF n <> 0 THEN bad := bad || format('pathway_progress:%s; ', n); END IF;

  SELECT count(*) INTO n FROM public.pathway_versions
    WHERE doc::text ~* 'usbong 1' OR doc::text LIKE '%usbong1%';
  IF n <> 0 THEN bad := bad || format('pathway_versions.doc:%s; ', n); END IF;

  SELECT count(*) INTO n FROM public.pipeline_lessons WHERE aim ~* 'usbong 1';
  IF n <> 0 THEN bad := bad || format('pipeline_lessons.aim:%s; ', n); END IF;

  -- the deliberate leave-behinds, pinned
  SELECT count(*) INTO n FROM public.notifications WHERE body ~* 'usbong 1';
  IF n <> 2 THEN bad := bad || format('notifications.body should still be 2, is %s; ', n); END IF;
  SELECT count(*) INTO n FROM public.notifications WHERE payload::text ~* 'usbong 1';
  IF n <> 2 THEN bad := bad || format('notifications.payload should still be 2, is %s; ', n); END IF;
  SELECT count(*) INTO n FROM public.attendance_self_attest_log WHERE meta::text ~* 'usbong 1';
  IF n <> 8 THEN bad := bad || format('attest_log.meta should still be 8, is %s; ', n); END IF;

  IF bad <> '' THEN
    RAISE EXCEPTION '103 POST-GATE FAILED -- %', bad;
  END IF;
  RAISE NOTICE '103 post-gate (i) OK: renamed surfaces clean, leave-behinds intact';
END $$;

-- (ii) The two runtime comparisons must be UNCHANGED. This is the gate that protects
--      233 attendance rows and every member's eligibility: it measures the JOIN, not
--      the rows, so a pattern that moved without its event names shows up as a drop.
INSERT INTO _103_runtime(phase, metric, n)
SELECT 'after', 'eligibility_matches', count(*)
  FROM public.attendance a
  JOIN public.usbong_quizzes q
    ON q.is_active IS TRUE
   AND COALESCE(q.attendance_event_name_pattern,'') <> ''
   AND position(q.attendance_event_name_pattern IN lower(a.event_name)) > 0;

INSERT INTO _103_runtime(phase, metric, n)
SELECT 'after', 'ambiguous_attendance', count(*) FROM (
  SELECT a.id
    FROM public.attendance a
    JOIN public.usbong_quizzes q
      ON q.is_active IS TRUE
     AND COALESCE(q.attendance_event_name_pattern,'') <> ''
     AND position(q.attendance_event_name_pattern IN lower(a.event_name)) > 0
   GROUP BY a.id HAVING count(*) > 1) x;

INSERT INTO _103_runtime(phase, metric, n)
SELECT 'after', 'enrollment_matches', count(*)
  FROM public.cohort_programs cp
  JOIN public.usbong_quizzes q ON q.course_code = cp.usbong_course_code;

DO $$
DECLARE bad text; amb bigint;
BEGIN
  SELECT string_agg(b.metric || ': ' || b.n || ' -> ' || a.n, '; ' ORDER BY b.metric)
    INTO bad
    FROM _103_runtime b JOIN _103_runtime a ON a.metric = b.metric
   WHERE b.phase = 'before' AND a.phase = 'after' AND a.n IS DISTINCT FROM b.n;
  IF bad IS NOT NULL THEN
    RAISE EXCEPTION '103 RUNTIME GATE FAILED -- a matching count changed across the rename, so one side moved without the other: %', bad;
  END IF;

  SELECT n INTO amb FROM _103_runtime WHERE phase = 'after' AND metric = 'ambiguous_attendance';
  IF amb <> 0 THEN
    RAISE EXCEPTION '103 RUNTIME GATE FAILED -- % attendance rows now match more than one lesson; the trailing separator that blocks the l1/l10 collision was damaged', amb;
  END IF;
  RAISE NOTICE '103 post-gate (ii) OK: eligibility, ambiguity and enrollment matching all unchanged';
END $$;

-- (iii) Migration 102's own validator must accept the new key. After the rename,
--       pathway_auto_source_options() derives 'lesson:usbong:all' from the renamed
--       course_code, and the rungs must carry exactly that. If either half failed to
--       move, this reports a bad key and the whole transaction rolls back.
DO $$
DECLARE n bigint;
BEGIN
  IF NOT public.pathway_auto_source_ok('lesson:usbong:all') THEN
    RAISE EXCEPTION '103 VOCABULARY GATE FAILED -- lesson:usbong:all is not recognised, so course_code and auto_source_key are out of step';
  END IF;
  SELECT count(*) INTO n FROM public.v_effective_auto_rungs e
   WHERE NOT public.pathway_auto_source_ok(e.auto_source_key);
  IF n <> 0 THEN
    RAISE EXCEPTION '103 VOCABULARY GATE FAILED -- % reachable rungs now carry an unrecognised auto source', n;
  END IF;
  RAISE NOTICE '103 post-gate (iii) OK: 102 validator clean, live_bad_auto_keys = 0';
END $$;

INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('103','103_usbong_rename.sql','Renames the Usbong curriculum identifier from ''Usbong 1'' to ''Usbong'' across 15 columns in 10 tables, in one transaction (Invariant #30, Session 84 addendum: a number belongs in a curriculum identifier only when the curriculum is part of a series; there is no Usbong 2). Includes the two runtime comparisons that must move together -- attendance_event_name_pattern vs 233 attendance.event_name rows (substring match) and cohort_programs.usbong_course_code vs usbong_quizzes.course_code (equality) -- either of which, moved alone, would silently cost members their Usbong eligibility. Case-preserving regex, since stored forms include ''Faith_USBONG 1'' (upper, end of string) and ''USBONG 1!'' that a plain replace would miss. Deliberately NOT renamed: notifications.body/payload (already-delivered messages) and attendance_self_attest_log.meta (append-only audit log, insert-only in code); the post-gate pins all three at their exact counts.')
ON CONFLICT (version) DO UPDATE SET filename=excluded.filename, note=excluded.note, applied_at=now();

COMMIT;

-- SELF-VERIFY -- expect all_ok = PASS. Recomputed after COMMIT, so it reads committed
-- state rather than the temp tables the transaction used.
SELECT
  (SELECT count(*) FROM public.usbong_quizzes WHERE course_code = 'Usbong')          AS quizzes_renamed,
  (SELECT count(*) FROM public.attendance WHERE event_name LIKE 'Usbong %')          AS attendance_renamed,
  (SELECT count(*) FROM public.pathway_rungs WHERE rung_key = 'usbong')              AS rungs_renamed,
  (SELECT count(*) FROM public.pathway_progress WHERE rung_key = 'usbong')           AS progress_renamed,
  (SELECT count(*) FROM public.attendance a
     JOIN public.usbong_quizzes q ON q.is_active IS TRUE
      AND COALESCE(q.attendance_event_name_pattern,'') <> ''
      AND position(q.attendance_event_name_pattern IN lower(a.event_name)) > 0)      AS eligibility_matches,
  (SELECT count(*) FROM public.v_effective_auto_rungs e
     WHERE NOT public.pathway_auto_source_ok(e.auto_source_key))                     AS live_bad_auto_keys,
  (SELECT count(*) FROM public.pathway_auto_source_options() WHERE key = 'lesson:usbong:all')
                                                                                     AS vocab_has_usbong,
  (SELECT count(*) FROM public.notifications WHERE body ~* 'usbong 1')               AS left_notifications,
  (SELECT count(*) FROM public.attendance_self_attest_log WHERE meta::text ~* 'usbong 1')
                                                                                     AS left_attest_log,
  (SELECT count(*) FROM public.schema_migrations WHERE version = '103')              AS self_stamped,
  CASE WHEN
       (SELECT count(*) FROM public.usbong_quizzes WHERE course_code = 'Usbong 1') = 0
   AND (SELECT count(*) FROM public.attendance WHERE event_name ~* 'usbong 1') = 0
   AND (SELECT count(*) FROM public.pathway_rungs WHERE rung_key = 'usbong1') = 0
   AND (SELECT count(*) FROM public.pathway_progress WHERE rung_key = 'usbong1') = 0
   AND (SELECT count(*) FROM public.pathway_versions WHERE doc::text LIKE '%usbong1%') = 0
   AND (SELECT count(*) FROM public.v_effective_auto_rungs e
         WHERE NOT public.pathway_auto_source_ok(e.auto_source_key)) = 0
   AND (SELECT count(*) FROM public.pathway_auto_source_options() WHERE key = 'lesson:usbong:all') = 1
   AND (SELECT count(*) FROM public.notifications WHERE body ~* 'usbong 1') = 2
   AND (SELECT count(*) FROM public.attendance_self_attest_log WHERE meta::text ~* 'usbong 1') = 8
   AND (SELECT count(*) FROM public.schema_migrations WHERE version = '103') = 1
       THEN 'PASS' ELSE 'FAIL' END                                                   AS all_ok;
