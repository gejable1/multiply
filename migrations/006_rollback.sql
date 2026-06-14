-- ============================================================================
-- 006_rollback.sql — recreate the 3 dormant views from their CAPTURED definitions.
-- ⛔ PLACEHOLDER — not armed. The view CREATE defs live only in the live DB, so this
-- rollback cannot be authored blind. Before dropping (006), capture the defs:
--   run diag_lc_group_views.sql block 1 → pg_get_viewdef(...) for each view,
--   paste them below as `CREATE OR REPLACE VIEW ...;`, then DELETE the guard block.
-- HUMAN-GATED; NOT run by CC.
-- ============================================================================

DO $$ BEGIN
  RAISE EXCEPTION
    '006_rollback not armed: paste the captured CREATE VIEW defs (from diag_lc_group_views.sql block 1) above this guard and remove it before running.';
END $$;

-- CREATE OR REPLACE VIEW public.v_member_attendance_rates AS <paste pg_get_viewdef here>;
-- CREATE OR REPLACE VIEW public.v_attendance_summary      AS <paste pg_get_viewdef here>;
-- CREATE OR REPLACE VIEW public.v_consecutive_absences    AS <paste pg_get_viewdef here>;
