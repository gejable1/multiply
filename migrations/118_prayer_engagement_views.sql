-- migrations/118_prayer_engagement_views.sql
-- S94 - Prayer feed: fix "Pray" button resetting to green + undercounted
-- "N praying" / "saved by N".
-- CAUSE: _loadPrayerEngagement() read EVERY prayer_intercessions row for the
--   visible feed in one query. PostgREST caps responses at 1,000 rows and the
--   query was unordered, so once total taps passed 1,000 (1,484 at diagnosis,
--   Oct 9 2026) a member's own taps could fall outside the returned page:
--   the button forgot they prayed, and every count read low.
-- FIX: move the distinct-member counting into the database.
--   * v_prayer_engagement_counts - ONE row per request: distinct intercessors
--     + distinct savers (status <> 'removed'). Bounded by feed size, never by
--     tap volume.
--   * v_prayer_my_intercessions  - DISTINCT (request_id, member_id) pairs. The
--     client filters by its own member_id -> at most one row per request.
-- Counts only - never names, no leaderboard (Inv #10 spirit). Views are
-- security_invoker so any future RLS on the base tables still applies (022).
-- RUN FLAT (no BEGIN/COMMIT) - Inv #209. Idempotent; rerun-until-true.

-- 1) Per-request distinct counts.
CREATE OR REPLACE VIEW public.v_prayer_engagement_counts
WITH (security_invoker = true) AS
SELECT
  r.id AS request_id,
  (SELECT COUNT(DISTINCT i.member_id)
     FROM public.prayer_intercessions i
    WHERE i.request_id = r.id)                         AS praying_count,
  (SELECT COUNT(DISTINCT s.member_id)
     FROM public.prayer_list_items s
    WHERE s.request_id = r.id
      AND s.status <> 'removed')                       AS saved_by_count
FROM public.prayer_requests r;

-- 2) Distinct intercessor pairs (who has prayed for which request, once each).
CREATE OR REPLACE VIEW public.v_prayer_my_intercessions
WITH (security_invoker = true) AS
SELECT DISTINCT i.request_id, i.member_id
FROM public.prayer_intercessions i;

GRANT SELECT ON public.v_prayer_engagement_counts TO anon, authenticated;
GRANT SELECT ON public.v_prayer_my_intercessions  TO anon, authenticated;

-- 3) Ledger stamp (023 contract).
INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('118', '118_prayer_engagement_views.sql',
        'S94 prayer engagement views: distinct counts + distinct intercessor pairs (fixes 1,000-row cap on Pray button state)')
ON CONFLICT (version) DO UPDATE
  SET filename = EXCLUDED.filename, note = EXCLUDED.note, applied_at = now();

-- 4) Self-verify - rerun the whole file until every row reads PASS.
SELECT 'view: engagement counts' AS checkpoint,
       CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS status
FROM information_schema.views
WHERE table_schema = 'public' AND table_name = 'v_prayer_engagement_counts'
UNION ALL
SELECT 'view: my intercessions',
       CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END
FROM information_schema.views
WHERE table_schema = 'public' AND table_name = 'v_prayer_my_intercessions'
UNION ALL
SELECT 'one count row per request',
       CASE WHEN (SELECT COUNT(*) FROM public.v_prayer_engagement_counts)
               = (SELECT COUNT(*) FROM public.prayer_requests)
            THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'distinct pairs match raw taps',
       CASE WHEN (SELECT COUNT(*) FROM public.v_prayer_my_intercessions)
               = (SELECT COUNT(*) FROM (SELECT DISTINCT request_id, member_id
                                          FROM public.prayer_intercessions) d)
            THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'ledger 118',
       CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END
FROM public.schema_migrations WHERE version = '118';
