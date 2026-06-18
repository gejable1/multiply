-- ============================================================================
-- migrations/010_lc_meeting_scoring.sql
-- SVI — LC-meeting-based scoring config (pairs with the index.ts EF change).
--
-- Human-gated (Inv #5/#10): the PASTOR runs this in the Supabase SQL editor.
-- IDEMPOTENT: fixed SET on score_rules; `||` merge only adds the floor key.
-- Rollback first: migrations/010_rollback.sql (Inv #157). No CREATE TABLE → no RLS.
--
-- Pairs with the Edge Function (deploy index.ts too):
--   • service_lc_led  — now scored for L2+ leaders from how many distinct weeks
--                       their LC actually met (≥1 member present at an LC Meeting),
--                       over an 8-week window. These tiers map that count → score.
--   • gather_lc / fellowship_lc_rate — softened to no_meeting_floor_score when the
--                       member's LC did NOT meet (vs full penalty when it met but
--                       they were absent).
-- ============================================================================

-- ── STEP 0 — CAPTURE current values FIRST (save this output for rollback) ────
SELECT metric_key, score_rules, compute_config FROM svi_metrics
 WHERE metric_key IN ('service_lc_led','gather_lc','fellowship_lc_rate');


-- ── STEP 1 — service_lc_led tiers (distinct meeting-weeks over 8 weeks) ──────
UPDATE svi_metrics SET score_rules =
  '{"type":"linear_threshold","thresholds":[{"value":7,"score":10},{"value":5,"score":7},{"value":3,"score":4},{"value":1,"score":2},{"value":0,"score":0}]}'::jsonb
 WHERE metric_key = 'service_lc_led';


-- ── STEP 2 — softened floor when the LC did not meet ─────────────────────────
UPDATE svi_metrics SET compute_config = COALESCE(compute_config,'{}'::jsonb) || '{"no_meeting_floor_score":4}'::jsonb
 WHERE metric_key IN ('gather_lc','fellowship_lc_rate');


-- ── STEP 3 — VERIFY ──────────────────────────────────────────────────────────
SELECT metric_key, compute_type, score_rules, compute_config FROM svi_metrics
 WHERE metric_key IN ('service_lc_led','gather_lc','fellowship_lc_rate');

-- ============================================================================
-- END 010_lc_meeting_scoring.sql
-- ============================================================================
