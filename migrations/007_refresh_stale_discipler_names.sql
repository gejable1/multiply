-- ============================================================================
-- 007_refresh_stale_discipler_names.sql   (OPTIONAL · COSMETIC · Inv #166)
-- ----------------------------------------------------------------------------
-- One-shot refresh to clear STALE denormalized discipler names. discipler_name is
-- a decorative text mirror (Inv #166): canonical decisions already resolve
-- discipler_id → the live members row, so this changes NOTHING functional — it just
-- makes the stored label match the current leader name (e.g. after a leader rename
-- like Melvin Aquino → Choti Aquino, which left 2 members' discipler_name stale).
--
-- HUMAN-GATED (Inv #5/#10): the Pastor runs this at his discretion. CC does NOT run
-- it. Idempotent (the WHERE guard makes a re-run a no-op). No rollback file: this
-- only syncs text to current truth, so there is nothing meaningful to "undo".
-- ============================================================================

-- 1) Read-only preview — which rows are stale (run first; expect a handful):
-- SELECT m.id, m.name AS member, m.discipler_name AS stored, lead.name AS current
--   FROM members m JOIN members lead ON lead.id = m.discipler_id
--   WHERE m.discipler_name IS DISTINCT FROM lead.name;

-- 2) The refresh (sync stored discipler_name → current leader name):
UPDATE members m
SET    discipler_name = lead.name
FROM   members lead
WHERE  lead.id = m.discipler_id
  AND  m.discipler_name IS DISTINCT FROM lead.name;

-- Verify (read-only) — should return 0 after running:
-- SELECT count(*) AS still_stale
--   FROM members m JOIN members lead ON lead.id = m.discipler_id
--   WHERE m.discipler_name IS DISTINCT FROM lead.name;
