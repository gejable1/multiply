-- ============================================================================
-- migrations/003_verify.sql  — Wave 1 verification, ONE batch, ONE JSON result.
--
-- Run AFTER 003_prayer_wave1.sql. Returns a single row (column verify_003) so
-- the Supabase mobile editor's "last grid only" shows the whole check at once.
-- Read-only. Look at "all_ok": true means every check passed.
--
-- Expected:
--   tables_count = 4, church_id = all true, partial_unique_index = true,
--   rls_enabled  = all false  →  all_ok = true
-- ============================================================================
WITH t AS (
  SELECT table_name FROM information_schema.tables
  WHERE table_schema = 'public'
    AND table_name IN ('prayer_requests','prayer_list_items','prayer_list_opens','prayer_intercessions')
),
c AS (
  SELECT table_name, bool_or(column_name = 'church_id') AS has_church_id
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name IN ('prayer_requests','prayer_list_items','prayer_list_opens','prayer_intercessions')
  GROUP BY table_name
),
idx AS (
  SELECT count(*) AS n FROM pg_indexes
  WHERE schemaname = 'public' AND indexname = 'uq_prayer_list_items_member_request'
),
r AS (
  SELECT relname, relrowsecurity FROM pg_class
  WHERE relkind = 'r'
    AND relname IN ('prayer_requests','prayer_list_items','prayer_list_opens','prayer_intercessions')
)
SELECT jsonb_pretty(jsonb_build_object(
  'tables_present',       (SELECT jsonb_agg(table_name ORDER BY table_name) FROM t),
  'tables_count',         (SELECT count(*) FROM t),
  'church_id',            (SELECT jsonb_object_agg(table_name, has_church_id) FROM c),
  'partial_unique_index', (SELECT n = 1 FROM idx),
  'rls_enabled',          (SELECT jsonb_object_agg(relname, relrowsecurity) FROM r),
  'all_ok',
    ( (SELECT count(*) FROM t) = 4
      AND (SELECT count(*) FROM c) = 4
      AND (SELECT bool_and(has_church_id) FROM c)
      AND (SELECT n = 1 FROM idx)
      AND (SELECT count(*) FROM r) = 4
      AND (SELECT bool_and(relrowsecurity IS FALSE) FROM r) )
)) AS verify_003;
-- ============================================================================
-- END 003_verify.sql
-- ============================================================================
