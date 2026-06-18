-- ============================================================================
-- migrations/009_svi_prayer.sql
-- Prayer / Panalangin — Wave 4 (Silent SVI). Backend-only, INVISIBLE to members.
--
-- Human-gated (Inv #5/#10): the PASTOR runs this in the Supabase SQL editor.
-- IDEMPOTENT: metric seed uses ON CONFLICT (metric_key) DO NOTHING; weight merge
-- uses `||` (only adds keys, never clobbers existing weights). Rollback first:
-- migrations/009_rollback.sql (Inv #157).
--
-- Adds 4 prayer-engagement metrics so prayer activity quietly feeds each member's
-- SVI as a MODEST care/shepherding signal — never a points/score/scoreboard
-- (SVI is not member-facing). All use compute_type 'count_rows' = the new GENERIC
-- handler in the compute-svi-weekly Edge Function (index.ts), which reads
-- table / member_col / date_col / lookback_days / filter from compute_config.
--
-- ⚠️ EDGE FUNCTION REDEPLOY REQUIRED (separate, human-gated): the count_rows
--    handler was a stub; index.ts now implements it generically. Deploy the EF
--    (supabase functions deploy compute-svi-weekly) for these metrics to score.
--    Until then they simply return null and contribute nothing (fail-soft).
--
-- TENANCY: svi_metrics is a GLOBAL catalog table (NO church_id — see 001's
-- excluded list), so no church_id here. svi_weight_profiles is per-church but we
-- only UPDATE existing rows' weights jsonb (no church_id touched). No new table
-- → no RLS step needed.
--
-- 'answered' SOURCE DECISION (reported): prayer_answered_90d counts the member's
-- OWN answered requests (prayer_requests.requester_id = member, status='answered',
-- answered_at window) — their own answered-prayer testimony — NOT prayer_list_items
-- answered (which would fold in others' saved requests + propagated answers).
-- ============================================================================


-- ── 1. Seed 4 'prayer' metrics (count_rows; modest linear_threshold scoring) ──
INSERT INTO svi_metrics
  (metric_key, display_name, category, compute_type, compute_config, score_rules,
   min_pipeline_level, max_pipeline_level, is_active, sort_order)
VALUES
  ('prayer_saved_30d',
   'Prayers saved (30d)', 'prayer', 'count_rows',
   '{"table":"prayer_list_items","member_col":"member_id","date_col":"created_at","lookback_days":30,"filter":{"source":"saved"}}'::jsonb,
   '{"type":"linear_threshold","thresholds":[{"value":1,"score":4},{"value":3,"score":7},{"value":6,"score":10}]}'::jsonb,
   0, 5, true, 80),

  ('prayer_opens_14d',
   'Prayer-list opens (14d)', 'prayer', 'count_rows',
   '{"table":"prayer_list_opens","member_col":"member_id","date_col":"opened_at","lookback_days":14}'::jsonb,
   '{"type":"linear_threshold","thresholds":[{"value":1,"score":4},{"value":4,"score":7},{"value":8,"score":10}]}'::jsonb,
   0, 5, true, 81),

  ('prayer_answered_90d',
   'Answered prayers (90d)', 'prayer', 'count_rows',
   '{"table":"prayer_requests","member_col":"requester_id","date_col":"answered_at","lookback_days":90,"filter":{"status":"answered"}}'::jsonb,
   '{"type":"linear_threshold","thresholds":[{"value":1,"score":6},{"value":2,"score":8},{"value":3,"score":10}]}'::jsonb,
   0, 5, true, 82),

  ('prayer_intercessions_30d',
   'Interceding for others (30d)', 'prayer', 'count_rows',
   '{"table":"prayer_intercessions","member_col":"member_id","date_col":"prayed_at","lookback_days":30}'::jsonb,
   '{"type":"linear_threshold","thresholds":[{"value":1,"score":3},{"value":5,"score":7},{"value":12,"score":10}]}'::jsonb,
   0, 5, true, 83)
ON CONFLICT (metric_key) DO NOTHING;


-- ── 2. MERGE modest weights into every active weight profile ─────────────────
-- `||` only ADDS the 4 keys (never clobbers existing weights). Weight = 1 each:
-- the smallest non-zero integer the MD weights editor supports — prayer is ONE
-- small input, never dominant. Applied to ALL active profiles (default + each
-- level), consistent with the metrics' 0–5 level range; the Pastor can fine-tune
-- live in MD → SVI Weights (the editor shows each weight's % share).
UPDATE svi_weight_profiles
SET weights = COALESCE(weights, '{}'::jsonb) || jsonb_build_object(
      'prayer_saved_30d',          1,
      'prayer_opens_14d',          1,
      'prayer_answered_90d',       1,
      'prayer_intercessions_30d',  1
    )
WHERE is_active = true;


-- ============================================================================
-- 3. VERIFY — ONE batch, ONE JSON result. all_ok = true means:
--    the 4 metrics exist AND every active profile carries all 4 weight keys.
-- ============================================================================
WITH m AS (
  SELECT count(*) AS n FROM svi_metrics
  WHERE metric_key IN ('prayer_saved_30d','prayer_opens_14d','prayer_answered_90d','prayer_intercessions_30d')
),
p AS (
  SELECT count(*) AS total,
         count(*) FILTER (
           WHERE weights ?& array['prayer_saved_30d','prayer_opens_14d','prayer_answered_90d','prayer_intercessions_30d']
         ) AS with_all_keys
  FROM svi_weight_profiles WHERE is_active = true
)
SELECT jsonb_pretty(jsonb_build_object(
  'metrics_seeded',               (SELECT n FROM m),
  'metrics_expected',             4,
  'active_profiles',              (SELECT total FROM p),
  'profiles_with_all_4_weights',  (SELECT with_all_keys FROM p),
  'all_ok',
    ( (SELECT n FROM m) = 4
      AND (SELECT total FROM p) = (SELECT with_all_keys FROM p)
      AND (SELECT total FROM p) > 0 )
)) AS verify_009;
-- ============================================================================
-- END 009_svi_prayer.sql
-- ============================================================================
