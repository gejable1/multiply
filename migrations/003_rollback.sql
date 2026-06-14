-- ============================================================================
-- migrations/003_rollback.sql  — EMERGENCY UNDO for 003_prayer_wave1.sql
--
-- Human-gated (Inv #5/#10): the PASTOR runs this in the Supabase SQL editor.
-- Committed BEFORE the forward migration is run (Inv #157 — free tier = no
-- backups, so the rollback script is the only net).
--
-- Drops the four Prayer-feature tables created by 003 (Wave 1). Idempotent:
-- DROP ... IF EXISTS. Child tables first (FK to prayer_requests), parent last.
-- This DESTROYS all prayer data — only run to fully reverse Wave 1.
-- ============================================================================

DROP TABLE IF EXISTS prayer_intercessions;
DROP TABLE IF EXISTS prayer_list_opens;
DROP TABLE IF EXISTS prayer_list_items;
DROP TABLE IF EXISTS prayer_requests;

-- ============================================================================
-- END 003_rollback.sql
-- ============================================================================
