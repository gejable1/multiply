-- ============================================================================
-- 004_promote_pending_lc_transfers_by_id.sql   (Tier 4B · Inv #166)
-- ----------------------------------------------------------------------------
-- Rewrite promote_pending_lc_transfers() to promote a DATE-SCHEDULED transfer by
-- the CANONICAL pointers (facilitator_id / discipler_id ← pending_facilitator_id),
-- mirroring the app's MultiplyShared.transfers.approve (multiply_shared.js
-- _xferApprove). The PRIOR version moved only the decorative lc_group /
-- discipler_name TEXT and never touched facilitator_id — so a scheduled
-- (transfer_date-driven) promotion silently failed to move the actual LCL.
--
-- HUMAN-GATED (Inv #5/#10/#153): the Pastor runs this in the Supabase SQL editor.
-- CC does NOT run it. Idempotent (CREATE OR REPLACE). Rollback restores the prior
-- definition verbatim — see 004_rollback.sql.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.promote_pending_lc_transfers()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  UPDATE members m
  SET
    facilitator_id         = m.pending_facilitator_id,
    discipler_id           = m.pending_facilitator_id,   -- discipler = LCL (Inv #46)
    facilitator_name       = dest.name,
    discipler_name         = dest.name,
    discipler              = dest.name,                  -- legacy text col, kept in sync
    lc_group               = COALESCE(NULLIF(btrim(dest.lc_group), ''), dest.name),
    pending_facilitator_id = NULL,
    pending_lc_group       = NULL,
    pending_transfer_by    = NULL,
    pending_discipler      = NULL,
    updated_at             = now()
  FROM members dest
  WHERE dest.id = m.pending_facilitator_id
    AND m.pending_facilitator_id IS NOT NULL          -- re-run guard (cleared above)
    AND m.transfer_date IS NOT NULL
    AND m.transfer_date <= CURRENT_DATE;
END;
$function$;

-- Verify (read-only) — after running, this should return 0:
-- SELECT count(*) AS still_overdue
--   FROM members
--   WHERE pending_facilitator_id IS NOT NULL
--     AND transfer_date IS NOT NULL
--     AND transfer_date <= CURRENT_DATE;
