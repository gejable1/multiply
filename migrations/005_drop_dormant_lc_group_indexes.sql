-- ============================================================================
-- 005_drop_dormant_lc_group_indexes.sql   (Tier 4B · Inv #166 · OPTIONAL / LOW-PRIORITY)
-- ----------------------------------------------------------------------------
-- The lc_group / member_lc_group / event_lc_group columns are decorative
-- (Inv #166); these indexes only served the old TEXT grouping/matching that the
-- frontend no longer performs (LACR, Pulse, announcements, absence-notices, and
-- transfer-state all now key on discipler_id / facilitator_id). Dropping them
-- reclaims per-write index maintenance.
--
-- SAFE: an index is a pure performance structure — dropping one never loses data;
-- 005_rollback.sql recreates them verbatim. Still HUMAN-GATED (Pastor runs it).
-- Run only after confirming no live consumer queries these columns (the Tier-2
-- repo sweep + diag_lc_group_views.sql both show none). Idempotent (IF EXISTS).
-- ============================================================================

DROP INDEX IF EXISTS public.idx_absnotices_lc_group_unack;
DROP INDEX IF EXISTS public.idx_att_event_lc;
DROP INDEX IF EXISTS public.idx_att_lc_date;
DROP INDEX IF EXISTS public.idx_att_member_lc;
DROP INDEX IF EXISTS public.idx_members_pending_lc;
DROP INDEX IF EXISTS public.idx_svi_snapshots_lc;
