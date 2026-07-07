-- 064_svi_wave5a_metrics.sql
-- Wave 5a: 10 SVI metrics (count-first). GLOBAL catalog (no church_id) — every
-- church sees them; weight defaults to 0 (opt-in) so seeding disturbs NO church.
-- null_if_zero:true = opt-in (non-participant excluded, not zeroed). Prayer Meeting
-- + Celebration are UNIVERSAL (0 = real low signal), so NO null_if_zero.
-- Requires the null_if_zero + sufficiency EF change to be live BEFORE any of these
-- opt-in metrics is given a weight. FLAT, self-verifying, ON CONFLICT idempotent.

INSERT INTO svi_metrics
  (metric_key, display_name, category, compute_type, compute_config, score_rules,
   min_pipeline_level, max_pipeline_level, is_active, sort_order)
VALUES
  ('prayer_meeting_att','Prayer Meeting attendance (8w)','prayer','count_rows',
   '{"table":"attendance","member_col":"member_id","date_col":"event_date","lookback_days":56,"filter":{"event_type":"Prayer Meeting","present":true}}'::jsonb,
   '{"type":"linear_threshold","thresholds":[{"value":1,"score":4},{"value":3,"score":7},{"value":6,"score":10}]}'::jsonb,
   0,5,true,84),

  ('gather_sunday_school','Sunday School attendance (8w)','gather','count_rows',
   '{"table":"attendance","member_col":"member_id","date_col":"event_date","lookback_days":56,"filter":{"event_type":"Sunday School","present":true},"null_if_zero":true}'::jsonb,
   '{"type":"linear_threshold","thresholds":[{"value":1,"score":4},{"value":3,"score":7},{"value":6,"score":10}]}'::jsonb,
   0,5,true,15),

  ('growth_btli_att','BTLI attendance (12w)','growth','count_rows',
   '{"table":"attendance","member_col":"member_id","date_col":"event_date","lookback_days":84,"filter":{"event_type":"BTLI","present":true},"null_if_zero":true}'::jsonb,
   '{"type":"linear_threshold","thresholds":[{"value":2,"score":4},{"value":5,"score":7},{"value":9,"score":10}]}'::jsonb,
   0,5,true,71),

  ('growth_btli_pass','BTLI lessons passed (6mo)','growth','count_rows',
   '{"table":"btli_quiz_attempts","member_col":"member_id","date_col":"submitted_at","lookback_days":180,"filter":{"passed":true,"counts_for_grade":true},"null_if_zero":true}'::jsonb,
   '{"type":"linear_threshold","thresholds":[{"value":1,"score":5},{"value":2,"score":7},{"value":3,"score":10}]}'::jsonb,
   0,5,true,72),

  ('growth_batch_att','Special Batch attendance (12w)','growth','count_rows',
   '{"table":"attendance","member_col":"member_id","date_col":"event_date","lookback_days":84,"filter":{"event_type":"General Purpose Batch","present":true},"null_if_zero":true}'::jsonb,
   '{"type":"linear_threshold","thresholds":[{"value":1,"score":4},{"value":3,"score":7},{"value":6,"score":10}]}'::jsonb,
   0,5,true,73),

  ('growth_pathway_moves','Pipeline rungs completed (90d)','growth','count_rows',
   '{"table":"pathway_progress","member_col":"member_id","date_col":"completed_at","lookback_days":90,"null_if_zero":true}'::jsonb,
   '{"type":"linear_threshold","thresholds":[{"value":1,"score":6},{"value":2,"score":8},{"value":3,"score":10}]}'::jsonb,
   0,5,true,74),

  ('fellowship_celebration','Celebration / thanksgiving (30d)','fellowship','count_rows',
   '{"table":"gratitude_entries","member_col":"member_id","date_col":"entry_date","lookback_days":30}'::jsonb,
   '{"type":"linear_threshold","thresholds":[{"value":1,"score":5},{"value":3,"score":8},{"value":6,"score":10}]}'::jsonb,
   0,5,true,41),

  ('fellowship_meeting_prep','LC meeting-prep engagement (30d)','fellowship','count_rows',
   '{"table":"lc_meeting_responses","member_col":"member_id","date_col":"created_at","lookback_days":30,"null_if_zero":true}'::jsonb,
   '{"type":"linear_threshold","thresholds":[{"value":1,"score":5},{"value":2,"score":8},{"value":4,"score":10}]}'::jsonb,
   0,5,true,42),

  ('service_guide_prep','LC guide prep — leader (5w)','service','count_rows',
   '{"table":"lc_meeting_guides","member_col":"lcl_id","date_col":"meeting_date","lookback_days":35,"filter":{"status":"published"},"null_if_zero":true}'::jsonb,
   '{"type":"linear_threshold","thresholds":[{"value":1,"score":5},{"value":2,"score":8},{"value":4,"score":10}]}'::jsonb,
   2,5,true,86),

  ('service_preaching','Preaching — Wed + Sun (6mo)','service','count_rows',
   '{"table":"wednesday_preaching","member_col":"preacher_member_id","date_col":"preach_date","lookback_days":180,"null_if_zero":true}'::jsonb,
   '{"type":"linear_threshold","thresholds":[{"value":1,"score":6},{"value":2,"score":8},{"value":3,"score":10}]}'::jsonb,
   2,5,true,87)
ON CONFLICT (metric_key) DO NOTHING;

insert into public.schema_migrations (version, filename, applied_at, note)
values ('064','064_svi_wave5a_metrics.sql', now(),
        'Wave 5a: 10 count-first SVI metrics (global catalog, weight-0 opt-in). null_if_zero for opt-in; Prayer Meeting + Celebration universal.')
on conflict (version) do nothing;

-- self-verify (rerun-until-true): expect 10 rows, check=PASS
SELECT metric_key, category, sort_order,
       CASE WHEN count(*) OVER () = 10 THEN 'PASS' ELSE 'FAIL' END AS check
FROM svi_metrics
WHERE metric_key IN ('prayer_meeting_att','gather_sunday_school','growth_btli_att',
  'growth_btli_pass','growth_batch_att','growth_pathway_moves','fellowship_celebration',
  'fellowship_meeting_prep','service_guide_prep','service_preaching')
ORDER BY sort_order;