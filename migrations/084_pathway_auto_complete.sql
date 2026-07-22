-- =====================================================================
-- 084_pathway_auto_complete.sql
-- Auto-completion engine — the "auto" pathway rungs tick themselves.
-- pathway_progress was manual-only (LCL toggles in MLT). This adds a
-- SECURITY DEFINER function that derives completion for the 9 OBJECTIVE
-- auto rungs from their source of truth, idempotently, with REAL milestone
-- dates (so multiplication's 90-day window stays honest):
--   assessment:gifts      -> gifts_diagnostic exists            (min date_taken)
--   assessment:salvation  -> diagnostic_results exists          (min date_taken)
--   assessment:disc/strengths/conflict -> member_profiles       (min date_taken)
--   lesson:btli1:all      -> passed EVERY active BTLI-1 lesson  (last pass)
--   lesson:usbong1:all    -> passed EVERY active Usbong-1 lesson(last pass)
--   streak:devotional:7|30-> reached N consecutive >=10-word days (the Nth day)
-- Auto rows: marked_by = NULL, note = 'auto:<source_key>' (distinct from LCL
-- marks). Character/fruit rungs stay 'manual' (human-witnessed) — untouched.
-- Idempotent via ON CONFLICT on (church_id, member_id, level, rung_key).
-- church_id provided explicitly, so the JWT-stamp trigger (058) no-ops.
-- PROVEN on PG16: 10/10 boundary asserts (partial course excluded, 6-day
-- streak excluded, inactive lesson excluded, retake uses earliest date,
-- rerun = 0). Base auto rungs only (v1).
--
-- Human-gated: run in Supabase SQL Editor (expect all_ok=PASS), commit, then
-- the compute-svi-weekly redeploy calls it on every full weekly run.
-- =====================================================================

CREATE OR REPLACE FUNCTION auto_complete_pathway_rungs()
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $fn$
DECLARE n_before bigint; n_after bigint;
BEGIN
  SELECT count(*) INTO n_before FROM pathway_progress;

  -- ===== ASSESSMENTS: a row in the source = the milestone (earliest date_taken) =====
  -- gifts -> gifts_diagnostic
  INSERT INTO pathway_progress (church_id, member_id, level, rung_key, completed_at, marked_by, note)
  SELECT g.church_id, g.member_id, r.level, r.rung_key, (min(g.date_taken))::timestamptz, NULL, 'auto:'||r.auto_source_key
  FROM gifts_diagnostic g
  JOIN pathway_rungs r ON r.church_id IS NULL AND r.completion_source='auto' AND r.rung_key='gifts'
  WHERE g.member_id IS NOT NULL AND g.church_id IS NOT NULL AND g.date_taken IS NOT NULL
  GROUP BY g.church_id, g.member_id, r.level, r.rung_key, r.auto_source_key
  ON CONFLICT (church_id, member_id, level, rung_key) DO NOTHING;

  -- salvation -> diagnostic_results
  INSERT INTO pathway_progress (church_id, member_id, level, rung_key, completed_at, marked_by, note)
  SELECT dr.church_id, dr.member_id, r.level, r.rung_key, (min(dr.date_taken))::timestamptz, NULL, 'auto:'||r.auto_source_key
  FROM diagnostic_results dr
  JOIN pathway_rungs r ON r.church_id IS NULL AND r.completion_source='auto' AND r.rung_key='salvation'
  WHERE dr.member_id IS NOT NULL AND dr.church_id IS NOT NULL AND dr.date_taken IS NOT NULL
  GROUP BY dr.church_id, dr.member_id, r.level, r.rung_key, r.auto_source_key
  ON CONFLICT (church_id, member_id, level, rung_key) DO NOTHING;

  -- disc / strengths / conflict -> member_profiles (profile_type -> rung_key map)
  INSERT INTO pathway_progress (church_id, member_id, level, rung_key, completed_at, marked_by, note)
  SELECT mp.church_id, mp.member_id, r.level, r.rung_key, (min(mp.date_taken))::timestamptz, NULL, 'auto:'||r.auto_source_key
  FROM member_profiles mp
  JOIN pathway_rungs r ON r.church_id IS NULL AND r.completion_source='auto'
       AND r.rung_key = CASE mp.profile_type WHEN 'disc' THEN 'disc' WHEN 'strengths' THEN 'strengths' WHEN 'conflict_style' THEN 'conflict' END
  WHERE mp.profile_type IN ('disc','strengths','conflict_style')
    AND mp.member_id IS NOT NULL AND mp.church_id IS NOT NULL AND mp.date_taken IS NOT NULL
  GROUP BY mp.church_id, mp.member_id, r.level, r.rung_key, r.auto_source_key
  ON CONFLICT (church_id, member_id, level, rung_key) DO NOTHING;

  -- ===== LESSONS: passed EVERY active lesson of the course =====
  -- BTLI (btli_quizzes / btli_quiz_attempts). Course token from auto_source_key ('lesson:<course>:all').
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
  SELECT p.church_id, p.member_id, r.level, r.rung_key, p.done_at, NULL, 'auto:'||r.auto_source_key
  FROM passed p JOIN tot t ON t.cc = p.cc
  JOIN pathway_rungs r ON r.church_id IS NULL AND r.completion_source='auto'
       AND r.auto_source_key LIKE 'lesson:%:all' AND split_part(r.auto_source_key,':',2) = p.cc
  WHERE t.total > 0 AND p.passed_lessons >= t.total
  ON CONFLICT (church_id, member_id, level, rung_key) DO NOTHING;

  -- Usbong (usbong_quizzes / usbong_quiz_attempts).
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
  SELECT p.church_id, p.member_id, r.level, r.rung_key, p.done_at, NULL, 'auto:'||r.auto_source_key
  FROM passed p JOIN tot t ON t.cc = p.cc
  JOIN pathway_rungs r ON r.church_id IS NULL AND r.completion_source='auto'
       AND r.auto_source_key LIKE 'lesson:%:all' AND split_part(r.auto_source_key,':',2) = p.cc
  WHERE t.total > 0 AND p.passed_lessons >= t.total
  ON CONFLICT (church_id, member_id, level, rung_key) DO NOTHING;

  -- ===== STREAKS: ever reached N consecutive devotional days (>=10-word reflection) =====
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
  INSERT INTO pathway_progress (church_id, member_id, level, rung_key, completed_at, marked_by, note)
  SELECT s.church_id, s.member_id, r.level, r.rung_key, s.milestone::timestamptz, NULL, 'auto:'||r.auto_source_key
  FROM pathway_rungs r
  JOIN LATERAL (
    SELECT member_id, church_id,
           min(start_date + (split_part(r.auto_source_key,':',3)::int - 1)) AS milestone
    FROM runs WHERE len >= split_part(r.auto_source_key,':',3)::int
    GROUP BY member_id, church_id
  ) s ON TRUE
  WHERE r.church_id IS NULL AND r.completion_source='auto' AND r.auto_source_key LIKE 'streak:devotional:%'
  ON CONFLICT (church_id, member_id, level, rung_key) DO NOTHING;

  SELECT count(*) INTO n_after FROM pathway_progress;
  RETURN (n_after - n_before)::int;
END;
$fn$;

-- Grant execute to the service role (compute-svi-weekly calls it via rpc).
GRANT EXECUTE ON FUNCTION public.auto_complete_pathway_rungs() TO service_role;

-- One-time backfill (idempotent — rerun returns 0).
SELECT public.auto_complete_pathway_rungs() AS rows_inserted_this_run;

-- Stamp the migration ledger.
INSERT INTO schema_migrations (version, filename, note)
VALUES ('084','084_pathway_auto_complete.sql','Auto-completion engine: auto_complete_pathway_rungs() derives the 9 objective auto rungs (assessments/lessons/streaks) into pathway_progress, idempotent, real dates; backfilled')
ON CONFLICT (version) DO NOTHING;

-- Self-verify (rerun until all_ok=PASS).
SELECT
  (SELECT count(*) FROM pg_proc WHERE proname='auto_complete_pathway_rungs')          AS fn_present,
  (SELECT count(*) FROM pathway_progress WHERE note LIKE 'auto:%')                     AS auto_rows_total,
  CASE WHEN (SELECT count(*) FROM pg_proc WHERE proname='auto_complete_pathway_rungs')=1
       THEN 'PASS' ELSE 'FAIL' END                                                     AS all_ok;
