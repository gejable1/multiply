-- ============================================================================
-- migrations/010_rollback.sql  — EMERGENCY UNDO for 010_lc_meeting_scoring.sql
--
-- Human-gated (Inv #5/#10): the PASTOR runs this in the Supabase SQL editor.
-- Committed BEFORE the forward migration is run (Inv #157). Pure data — no table.
-- ============================================================================

-- Remove the softening floor key from the two LC-fellowship metrics.
UPDATE svi_metrics SET compute_config = compute_config - 'no_meeting_floor_score'
 WHERE metric_key IN ('gather_lc','fellowship_lc_rate');

-- TODO (manual): restore service_lc_led.score_rules from the values the FORWARD
-- migration's first SELECT printed. Paste the captured jsonb below and run:
-- UPDATE svi_metrics SET score_rules = '<PASTE captured service_lc_led score_rules>'::jsonb
--  WHERE metric_key = 'service_lc_led';

-- ============================================================================
-- END 010_rollback.sql
-- ============================================================================
