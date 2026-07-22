-- =====================================================================
-- 083_svi_wave5c_multiplication.sql
-- SVI Wave 5c · Multiplication (the flagship) — "are a leader's disciples
-- advancing?" For each leader (L2+), the fraction of their disciples who
-- completed >=1 pathway rung in the window (discipler_id -> disciples ->
-- pathway_progress). CARE-LENS, not a KPI:
--   * no disciples          -> n/a (null, sufficiency-guarded, never a penalty)
--   * disciples, none moving -> a gentle low score (a flag to notice + support)
--
-- New compute_type 'disciples_advancing' (handled by a special-case in
-- compute-svi-weekly, alongside service_lc_led) + new category 'multiplication'.
-- Seeded at weight 0 (absent from every svi_weight_profile) => ZERO effect on any
-- score until the Pastor weights it in MD -> SVI Weights (per level, L2+).
--
-- Human-gated: run in Supabase SQL Editor (expect all_ok=PASS), commit, then
-- redeploy compute-svi-weekly (Verify-JWT OFF) with the new handler.
-- =====================================================================

-- 1) Widen the compute_type CHECK to allow 'disciples_advancing'
--    (#290 — DROP + re-ADD the full live list before inserting the new value).
ALTER TABLE svi_metrics DROP CONSTRAINT IF EXISTS svi_metrics_compute_type_check;
ALTER TABLE svi_metrics ADD CONSTRAINT svi_metrics_compute_type_check
  CHECK (compute_type = ANY (ARRAY[
    'sql_query','jsonb_extract','count_rows','boolean_check',
    'date_recency','manual_override','rate_rows','count_fields',
    'disciples_advancing'
  ]));

-- 2) Widen the category CHECK to allow 'multiplication'
--    (#290 — same pattern; the flagship gets its own care-detail line).
ALTER TABLE svi_metrics DROP CONSTRAINT IF EXISTS svi_metrics_category_check;
ALTER TABLE svi_metrics ADD CONSTRAINT svi_metrics_category_check
  CHECK (category = ANY (ARRAY[
    'gather','word','prayer','fellowship','mission',
    'growth','service','stewardship','multiplication'
  ]));

-- 3) Seed the metric (idempotent on metric_key). RATE mode: advanced / disciples.
INSERT INTO svi_metrics
  (metric_key, display_name, category, compute_type, compute_config, score_rules,
   min_pipeline_level, max_pipeline_level, is_active, sort_order)
VALUES
  ('multiplication_disciples_advancing','Disciples advancing','multiplication','disciples_advancing',
   '{"lookback_days":90,"mode":"rate","unit":"disciples advancing"}'::jsonb,
   '{"type":"rate_to_score","ranges":[{"min_rate":0.6,"score":10},{"min_rate":0.4,"score":8},{"min_rate":0.2,"score":6},{"min_rate":0.05,"score":4},{"min_rate":0,"score":2}]}'::jsonb,
   2,5,true,95)
ON CONFLICT (metric_key) DO UPDATE SET
  display_name   = EXCLUDED.display_name,
  category       = EXCLUDED.category,
  compute_type   = EXCLUDED.compute_type,
  compute_config = EXCLUDED.compute_config,
  score_rules    = EXCLUDED.score_rules,
  min_pipeline_level = EXCLUDED.min_pipeline_level,
  max_pipeline_level = EXCLUDED.max_pipeline_level,
  is_active      = EXCLUDED.is_active,
  sort_order     = EXCLUDED.sort_order;

-- 4) Stamp the migration ledger.
INSERT INTO schema_migrations (version, filename, note)
VALUES ('083','083_svi_wave5c_multiplication.sql','Wave 5c: disciples_advancing compute_type + multiplication category + multiplication_disciples_advancing metric (weight 0); widened compute_type + category CHECKs')
ON CONFLICT (version) DO NOTHING;

-- 5) Self-verify (rerun until all_ok=PASS).
SELECT
  (SELECT count(*) FROM svi_metrics WHERE metric_key='multiplication_disciples_advancing' AND is_active) AS metric_present,
  (SELECT compute_type FROM svi_metrics WHERE metric_key='multiplication_disciples_advancing') AS ctype,
  (SELECT category     FROM svi_metrics WHERE metric_key='multiplication_disciples_advancing') AS cat,
  (SELECT true FROM pg_constraint WHERE conname='svi_metrics_compute_type_check'
     AND pg_get_constraintdef(oid) LIKE '%disciples_advancing%') AS ctype_check_widened,
  (SELECT true FROM pg_constraint WHERE conname='svi_metrics_category_check'
     AND pg_get_constraintdef(oid) LIKE '%multiplication%')       AS cat_check_widened,
  (SELECT count(*) FROM svi_weight_profiles WHERE weights ? 'multiplication_disciples_advancing') AS weighted_in_profiles,
  CASE WHEN
        (SELECT count(*) FROM svi_metrics WHERE metric_key='multiplication_disciples_advancing' AND is_active)=1
    AND (SELECT compute_type FROM svi_metrics WHERE metric_key='multiplication_disciples_advancing')='disciples_advancing'
    AND (SELECT category FROM svi_metrics WHERE metric_key='multiplication_disciples_advancing')='multiplication'
    AND (SELECT true FROM pg_constraint WHERE conname='svi_metrics_compute_type_check'
           AND pg_get_constraintdef(oid) LIKE '%disciples_advancing%')
    AND (SELECT true FROM pg_constraint WHERE conname='svi_metrics_category_check'
           AND pg_get_constraintdef(oid) LIKE '%multiplication%')
    AND (SELECT count(*) FROM svi_weight_profiles WHERE weights ? 'multiplication_disciples_advancing')=0
       THEN 'PASS' ELSE 'FAIL' END AS all_ok;
