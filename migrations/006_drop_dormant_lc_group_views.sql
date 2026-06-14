-- ============================================================================
-- 006_drop_dormant_lc_group_views.sql   (Tier 4B · Inv #166 · OPTIONAL · ⛔ BLOCKED)
-- ----------------------------------------------------------------------------
-- v_member_attendance_rates / v_attendance_summary / v_consecutive_absences appear
-- DORMANT: the Tier-2 repo sweep found ZERO frontend/Edge-Function consumers (only
-- a name-list comment in the schema dump). If they GROUP BY member_lc_group /
-- event_lc_group they are also Inv #166-wrong — but dormant, so just drop them.
--
-- ⛔ DO NOT RUN until BOTH are confirmed via diag_lc_group_views.sql:
--    • block 3 (view→view deps) and block 4 (functions) return NO dependents, AND
--    • the captured pg_get_viewdef(...) output (block 1) has been pasted into
--      006_rollback.sql so a rollback can actually recreate the views.
--   Their CREATE defs live ONLY in the live DB; CC cannot author the rollback blind.
--
-- HUMAN-GATED. Idempotent (IF EXISTS).
-- ============================================================================

DROP VIEW IF EXISTS public.v_member_attendance_rates;
DROP VIEW IF EXISTS public.v_attendance_summary;
DROP VIEW IF EXISTS public.v_consecutive_absences;
