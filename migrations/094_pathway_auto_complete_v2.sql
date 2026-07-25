-- migrations/094_pathway_auto_complete_v2.sql
-- Auto-completion v2 -- the engine now honours each church's OWN catalog.
--
-- WHAT WAS WRONG. Migration 084 (v1) joined base rungs only: every INSERT
-- carried `pathway_rungs r ON r.church_id IS NULL`. It never consulted a
-- church's overlay. Three consequences, only the first of which was known:
--   A. a church that AUTHORS its own auto rung never gets it ticked;
--   B. a church that TOMBSTONES a base auto rung (overlay, published=false)
--      still gets progress written for a rung it does not display;
--   C. a church whose overlay says the rung is MANUAL still gets it auto-ticked.
-- The live diagnostic found A=0, B=0, C=2 (Rosehill L2 conflict + disc). Those
-- two were not doctrine -- they were damage from the poster editor, which
-- dropped completion_source/auto_source_key on customize; migration 093 repaired
-- them and the editor fix stops it recurring. v2 must land AFTER 093, otherwise
-- honouring the overlay would strand 131 legitimate completions behind a rung
-- new members could no longer earn.
--
-- THE RESOLVER. One view, v_effective_auto_rungs, computes the effective rung
-- set per church exactly the way every client already does it: for each
-- (level, rung_key), the overlay row wins over the base row; then published,
-- completion_source='auto' and a non-null auto_source_key. One place owns the
-- precedence, the way #380 wired quiz visibility to a single resolver. It is
-- security_invoker (migration 022 doctrine), so a client sees only its own
-- church while the SECURITY DEFINER engine sees all.
--
-- MATCHING. v1 matched assessments by rung_key and lessons/streaks by
-- auto_source_key. v2 matches everything by auto_source_key -- the field that
-- actually names the source of truth. For the 9 base rungs the two are 1:1
-- (verified against migration 057), so base behaviour is unchanged; overlay
-- rungs with their own rung_key now work, which is the whole point.
--
-- Progress is written at the EFFECTIVE rung's level, so a church that moved a
-- rung gets its progress where the poster actually shows it.
--
-- v2 never deletes. Rows written by v1 stay exactly as they are.
--
-- Flat (#209), idempotent, self-verifying (#210), ledger-stamped. PG16-proven (#379).

CREATE OR REPLACE VIEW public.v_effective_auto_rungs AS
SELECT c.id AS church_id, r.level, r.rung_key, r.auto_source_key
FROM public.churches c
JOIN LATERAL (
  SELECT DISTINCT ON (x.level, x.rung_key) x.*
  FROM public.pathway_rungs x
  WHERE x.church_id IS NULL OR x.church_id = c.id
  ORDER BY x.level, x.rung_key, (x.church_id IS NOT NULL) DESC
) r ON TRUE
WHERE r.completion_source = 'auto'
  AND r.published IS NOT FALSE
  AND r.auto_source_key IS NOT NULL;

ALTER VIEW public.v_effective_auto_rungs SET (security_invoker = true);

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

  SELECT count(*) INTO n_after FROM pathway_progress;
  RETURN (n_after - n_before)::int;
END;
$fn$;

GRANT EXECUTE ON FUNCTION public.auto_complete_pathway_rungs() TO service_role;

-- Run it once now (idempotent -- a rerun returns 0).
SELECT public.auto_complete_pathway_rungs() AS rows_inserted_this_run;

INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('094','094_pathway_auto_complete_v2.sql','Auto-completion v2: v_effective_auto_rungs resolver (overlay wins by level+rung_key, published, auto only); engine matches on auto_source_key and writes at the effective level; overlay-authored auto rungs now tick, tombstoned/manual ones no longer do')
ON CONFLICT (version) DO UPDATE SET filename=excluded.filename, note=excluded.note, applied_at=now();

-- SELF-VERIFY -- expect all_ok = PASS.
SELECT
  (SELECT count(*) FROM pg_views WHERE viewname='v_effective_auto_rungs')            AS resolver_present,
  (SELECT count(*) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
    WHERE c.relname='v_effective_auto_rungs' AND n.nspname='public'
      AND 'security_invoker=true' = ANY(c.reloptions))                               AS resolver_security_invoker,
  (SELECT count(*) FROM v_effective_auto_rungs)                                      AS effective_auto_rungs_all_churches,
  (SELECT count(*) FROM pathway_progress WHERE note LIKE 'auto:%')                   AS auto_progress_rows,
  (SELECT count(*) FROM pg_proc WHERE proname='auto_complete_pathway_rungs'
      AND prosrc LIKE '%v_effective_auto_rungs%')                                    AS engine_uses_resolver,
  CASE WHEN (SELECT count(*) FROM pg_views WHERE viewname='v_effective_auto_rungs')=1
        AND (SELECT count(*) FROM pg_proc WHERE proname='auto_complete_pathway_rungs'
               AND prosrc LIKE '%v_effective_auto_rungs%')=1
       THEN 'PASS' ELSE 'FAIL' END                                                   AS all_ok;
