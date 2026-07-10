-- =====================================================================
-- 072_svi_option_b_multi_ministry.sql
-- SVI Wave 5b · Option B — reward multi-ministry service WITHOUT lowering
-- anyone. Keeps service_ministry_role (boolean → 10) untouched, and ADDS a
-- new bonus metric service_multi_ministry that is n/a for 0–1 ministries and
-- scores 7 (two) / 10 (three). New generic compute_type 'count_fields' counts
-- non-empty configured member columns; returns null below min_count (n/a,
-- sufficiency-guarded), so members below 2 are neither rewarded nor penalised.
--
-- Inserted at weight 0 (absent from every svi_weight_profile) → ZERO effect on
-- any score until the Pastor weights it in MD → SVI Weights (service, per level).
--
-- Human-gated: run in Supabase SQL Editor (expect all_ok=PASS), commit, then
-- redeploy compute-svi-weekly (Verify-JWT OFF) with the count_fields handler.
-- =====================================================================

-- 1) Widen the compute_type CHECK to allow 'count_fields'
--    (#290 — verified the live DDL first; it did NOT include count_fields).
ALTER TABLE svi_metrics DROP CONSTRAINT IF EXISTS svi_metrics_compute_type_check;
ALTER TABLE svi_metrics ADD CONSTRAINT svi_metrics_compute_type_check
  CHECK (compute_type = ANY (ARRAY[
    'sql_query','jsonb_extract','count_rows','boolean_check',
    'date_recency','manual_override','rate_rows','count_fields'
  ]));

-- 2) Insert the bonus metric (idempotent on metric_key).
INSERT INTO svi_metrics
  (metric_key, display_name, category, compute_type, compute_config, score_rules,
   min_pipeline_level, max_pipeline_level, is_active, sort_order)
VALUES
  ('service_multi_ministry','Multi-ministry service (2+)','service','count_fields',
   '{"table":"members","fields":["ministry","ministry2","ministry3"],"min_count":2,"unit":"ministries"}'::jsonb,
   '{"type":"linear_threshold","thresholds":[{"value":3,"score":10},{"value":2,"score":7}]}'::jsonb,
   1,5,true,88)
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

-- 3) Stamp the migration ledger.
INSERT INTO schema_migrations (version, filename, note)
VALUES ('072','072_svi_option_b_multi_ministry.sql','Wave 5b Option B: count_fields compute_type + service_multi_ministry bonus metric (weight 0); widened compute_type CHECK')
ON CONFLICT (version) DO NOTHING;

-- 4) Self-verify (rerun until all_ok=PASS).
SELECT
  (SELECT count(*) FROM svi_metrics WHERE metric_key='service_multi_ministry' AND is_active) AS metric_present,
  (SELECT compute_type FROM svi_metrics WHERE metric_key='service_multi_ministry')           AS ctype,
  (SELECT compute_config->>'min_count' FROM svi_metrics WHERE metric_key='service_multi_ministry') AS min_count,
  -- confirm CHECK now accepts count_fields
  (SELECT true FROM pg_constraint WHERE conname='svi_metrics_compute_type_check'
     AND pg_get_constraintdef(oid) LIKE '%count_fields%')                                     AS check_widened,
  -- confirm it is NOT weighted anywhere yet (weight 0 → zero effect)
  (SELECT count(*) FROM svi_weight_profiles WHERE weights ? 'service_multi_ministry')          AS weighted_in_profiles,
  CASE WHEN
        (SELECT count(*) FROM svi_metrics WHERE metric_key='service_multi_ministry' AND is_active)=1
    AND (SELECT compute_type FROM svi_metrics WHERE metric_key='service_multi_ministry')='count_fields'
    AND (SELECT true FROM pg_constraint WHERE conname='svi_metrics_compute_type_check'
           AND pg_get_constraintdef(oid) LIKE '%count_fields%')
    AND (SELECT count(*) FROM svi_weight_profiles WHERE weights ? 'service_multi_ministry')=0
       THEN 'PASS' ELSE 'FAIL' END AS all_ok;
