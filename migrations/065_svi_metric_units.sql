-- -- 065_svi_metric_units.sql
-- Add a display "unit" noun to each Wave-5a count_rows metric so the care-detail
-- "How each number is derived" reads descriptively ("6 Prayer Meetings attended")
-- instead of the generic "6 records". Data-driven: modal reads compute_config.unit;
-- future metrics carry their own unit. Idempotent (|| overwrites), FLAT, self-verifying.

UPDATE svi_metrics SET compute_config = compute_config || '{"unit":"Prayer Meetings attended"}'::jsonb WHERE metric_key='prayer_meeting_att';
UPDATE svi_metrics SET compute_config = compute_config || '{"unit":"Sunday School sessions attended"}'::jsonb WHERE metric_key='gather_sunday_school';
UPDATE svi_metrics SET compute_config = compute_config || '{"unit":"BTLI sessions attended"}'::jsonb WHERE metric_key='growth_btli_att';
UPDATE svi_metrics SET compute_config = compute_config || '{"unit":"BTLI lessons passed"}'::jsonb WHERE metric_key='growth_btli_pass';
UPDATE svi_metrics SET compute_config = compute_config || '{"unit":"Special Batch sessions attended"}'::jsonb WHERE metric_key='growth_batch_att';
UPDATE svi_metrics SET compute_config = compute_config || '{"unit":"pipeline rungs completed"}'::jsonb WHERE metric_key='growth_pathway_moves';
UPDATE svi_metrics SET compute_config = compute_config || '{"unit":"thanksgiving entries shared"}'::jsonb WHERE metric_key='fellowship_celebration';
UPDATE svi_metrics SET compute_config = compute_config || '{"unit":"meeting-prep responses given"}'::jsonb WHERE metric_key='fellowship_meeting_prep';
UPDATE svi_metrics SET compute_config = compute_config || '{"unit":"LC guides prepared"}'::jsonb WHERE metric_key='service_guide_prep';
UPDATE svi_metrics SET compute_config = compute_config || '{"unit":"sermons preached (Wed + Sun)"}'::jsonb WHERE metric_key='service_preaching';

insert into public.schema_migrations (version, filename, applied_at, note)
values ('065','065_svi_metric_units.sql', now(),
        'Add display unit noun to Wave-5a count_rows metrics for descriptive care-detail explanations')
on conflict (version) do nothing;

-- self-verify: expect 10 rows, each with a unit + check=ok
SELECT metric_key, compute_config->>'unit' AS unit,
       CASE WHEN compute_config ? 'unit' THEN 'ok' ELSE 'MISSING' END AS check
FROM svi_metrics
WHERE metric_key IN ('prayer_meeting_att','gather_sunday_school','growth_btli_att',
  'growth_btli_pass','growth_batch_att','growth_pathway_moves','fellowship_celebration',
  'fellowship_meeting_prep','service_guide_prep','service_preaching')
ORDER BY metric_key;