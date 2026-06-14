-- ============================================================================
-- 005_rollback.sql — recreate the lc_group-family indexes dropped by 005, verbatim
-- (definitions captured from SCHEMA_DUMP_SECRET_recreate_multiply.sql). Emergency
-- undo. HUMAN-GATED; NOT run by CC. Idempotent (IF NOT EXISTS).
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_absnotices_lc_group_unack ON public.absence_notices USING btree (member_lc_group, acknowledged_at) WHERE (acknowledged_at IS NULL);
CREATE INDEX IF NOT EXISTS idx_att_event_lc ON public.attendance USING btree (event_lc_group);
CREATE INDEX IF NOT EXISTS idx_att_lc_date ON public.attendance USING btree (event_lc_group, event_date);
CREATE INDEX IF NOT EXISTS idx_att_member_lc ON public.attendance USING btree (member_lc_group);
CREATE INDEX IF NOT EXISTS idx_members_pending_lc ON public.members USING btree (pending_lc_group) WHERE (pending_lc_group IS NOT NULL);
CREATE INDEX IF NOT EXISTS idx_svi_snapshots_lc ON public.svi_snapshots USING btree (lc_group, week_start DESC);
