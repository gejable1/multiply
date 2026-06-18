-- ============================================================================
-- migrations/008_rollback.sql  — EMERGENCY UNDO for 008_prayer_reminders.sql
--
-- Human-gated (Inv #5/#10): the PASTOR runs this in the Supabase SQL editor.
-- Committed BEFORE the forward migration is run (Inv #157). Idempotent.
-- Drops the Wave-3 prayer reminders table. DESTROYS members' reminder prefs only.
-- ============================================================================

DROP TABLE IF EXISTS prayer_reminders;

-- ============================================================================
-- END 008_rollback.sql
-- ============================================================================
