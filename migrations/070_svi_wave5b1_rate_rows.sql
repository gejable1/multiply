-- =====================================================================
-- 070_svi_wave5b1_rate_rows.sql
-- SVI Wave 5b-1 — the rate engine.
-- Convert 4 attendance-cadence metrics from count_rows -> rate_rows
-- (present ÷ opportunities). svi_metrics is GLOBAL (no church_id).
--
-- rostered  (Sunday School / BTLI / Special Batch):
--     denom = the member's OWN logged sessions (present+absent) for the
--     event_type in-window  ->  present / (present+absent).
--     An absence lowers the rate ("an absent is an absent").
--     0 logged rows = not enrolled = null (n/a), #281 preserved.
-- events_held (Prayer Meeting, church-wide, no roster):
--     denom = distinct church-held dates (>=1 present) in-window.
--     held=0 -> null (n/a); present=0 while held>0 -> rate 0 (counted).
--
-- null_if_zero routes BOTH n/a cases through the existing sufficiency path.
-- FLAT (#209), rerun-until-true (#210).
-- =====================================================================

-- 1) Widen the compute_type CHECK to allow 'rate_rows' (#290 — verified the
--    live DDL first: it did NOT include rate_rows).
ALTER TABLE svi_metrics DROP CONSTRAINT IF EXISTS svi_metrics_compute_type_check;
ALTER TABLE svi_metrics ADD CONSTRAINT svi_metrics_compute_type_check
  CHECK (compute_type = ANY (ARRAY[
    'sql_query','jsonb_extract','count_rows','boolean_check',
    'date_recency','manual_override','rate_rows'
  ]));

-- 2) Convert the 4 metrics.
UPDATE svi_metrics SET
  compute_type   = 'rate_rows',
  compute_config = '{"table":"attendance","member_col":"member_id","date_col":"event_date","lookback_days":56,"event_type":"Prayer Meeting","denominator_mode":"events_held","null_if_zero":true,"unit":"prayer meetings"}'::jsonb,
  score_rules    = '{"type":"rate_to_score","ranges":[{"min_rate":0.75,"score":10},{"min_rate":0.40,"score":7},{"min_rate":0.15,"score":4}]}'::jsonb,
  updated_at     = now()
WHERE metric_key = 'prayer_meeting_att';

UPDATE svi_metrics SET
  compute_type   = 'rate_rows',
  compute_config = '{"table":"attendance","member_col":"member_id","date_col":"event_date","lookback_days":56,"event_type":"Sunday School","denominator_mode":"rostered","null_if_zero":true,"unit":"Sunday School sessions"}'::jsonb,
  score_rules    = '{"type":"rate_to_score","ranges":[{"min_rate":0.75,"score":10},{"min_rate":0.40,"score":7},{"min_rate":0.15,"score":4}]}'::jsonb,
  updated_at     = now()
WHERE metric_key = 'gather_sunday_school';

UPDATE svi_metrics SET
  compute_type   = 'rate_rows',
  compute_config = '{"table":"attendance","member_col":"member_id","date_col":"event_date","lookback_days":84,"event_type":"BTLI","denominator_mode":"rostered","null_if_zero":true,"unit":"BTLI sessions"}'::jsonb,
  score_rules    = '{"type":"rate_to_score","ranges":[{"min_rate":0.75,"score":10},{"min_rate":0.40,"score":7},{"min_rate":0.15,"score":4}]}'::jsonb,
  updated_at     = now()
WHERE metric_key = 'growth_btli_att';

UPDATE svi_metrics SET
  compute_type   = 'rate_rows',
  compute_config = '{"table":"attendance","member_col":"member_id","date_col":"event_date","lookback_days":84,"event_type":"General Purpose Batch","denominator_mode":"rostered","null_if_zero":true,"unit":"Batch sessions"}'::jsonb,
  score_rules    = '{"type":"rate_to_score","ranges":[{"min_rate":0.75,"score":10},{"min_rate":0.40,"score":7},{"min_rate":0.15,"score":4}]}'::jsonb,
  updated_at     = now()
WHERE metric_key = 'growth_batch_att';

-- 3) Ledger self-stamp.
INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('070','070_svi_wave5b1_rate_rows.sql','Wave 5b-1: 4 attendance metrics count_rows->rate_rows (rostered + events_held denominators); widened compute_type CHECK')
ON CONFLICT (version) DO NOTHING;

-- 4) Self-verify (rerun-until-true): expect all_ok = PASS.
SELECT
  count(*) FILTER (WHERE compute_type='rate_rows')                                                   AS rate_metrics,
  count(*) FILTER (WHERE compute_type='rate_rows' AND score_rules->>'type'='rate_to_score')          AS rate_scored,
  count(*) FILTER (WHERE compute_type='rate_rows' AND compute_config ? 'denominator_mode')           AS with_mode,
  CASE WHEN count(*) FILTER (WHERE compute_type='rate_rows')=4
        AND count(*) FILTER (WHERE compute_type='rate_rows' AND score_rules->>'type'='rate_to_score')=4
        AND count(*) FILTER (WHERE compute_type='rate_rows' AND compute_config ? 'denominator_mode')=4
       THEN 'PASS' ELSE 'FAIL' END                                                                   AS all_ok
FROM svi_metrics
WHERE metric_key IN ('prayer_meeting_att','gather_sunday_school','growth_btli_att','growth_batch_att');
