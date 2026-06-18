-- ============================================================================
-- migrations/009_rollback.sql  — EMERGENCY UNDO for 009_svi_prayer.sql
--
-- Human-gated (Inv #5/#10): the PASTOR runs this in the Supabase SQL editor.
-- Committed BEFORE the forward migration is run (Inv #157). Idempotent.
--
-- Removes the 4 prayer SVI metrics AND strips their 4 keys from every weight
-- profile. Pure data — no table dropped. (Re-deploying the Edge Function with
-- the generic count_rows handler is harmless on its own and is NOT reverted
-- here; it only fires for metrics that exist.)
-- ============================================================================

-- 1) Strip the 4 prayer weight keys from every profile that has any of them.
UPDATE svi_weight_profiles
SET weights = weights
      - 'prayer_saved_30d'
      - 'prayer_opens_14d'
      - 'prayer_answered_90d'
      - 'prayer_intercessions_30d'
WHERE weights ?| array['prayer_saved_30d','prayer_opens_14d','prayer_answered_90d','prayer_intercessions_30d'];

-- 2) Delete the 4 metric rows.
DELETE FROM svi_metrics
WHERE metric_key IN ('prayer_saved_30d','prayer_opens_14d','prayer_answered_90d','prayer_intercessions_30d');

-- ============================================================================
-- END 009_rollback.sql
-- ============================================================================
