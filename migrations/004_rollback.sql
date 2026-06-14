-- ============================================================================
-- 004_rollback.sql — restore promote_pending_lc_transfers() to its PRIOR (text)
-- definition verbatim. Emergency undo for 004. HUMAN-GATED; NOT run by CC.
-- (Note: the prior version is the buggy text-only promotion — restoring it
-- re-introduces the Inv #166 issue. Use only to revert 004.)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.promote_pending_lc_transfers()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  UPDATE members
  SET
    lc_group         = pending_lc_group,
    discipler_name   = COALESCE(pending_discipler, discipler_name),
    pending_lc_group = NULL,
    pending_discipler = NULL,
    transfer_date    = NULL,
    updated_at       = now()
  WHERE
    transfer_date IS NOT NULL
    AND transfer_date <= CURRENT_DATE
    AND pending_lc_group IS NOT NULL;
END;
$function$;
