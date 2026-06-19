-- ============================================================================
-- migrations/011_rollback.sql  — emergency undo for 011_devo_reflection_streak_cleanup.sql
--   NOT run by default. Restores every deleted row from the Step-1 backup.
--   Idempotent: rows already present in attendance are skipped (matched by id).
--   HUMAN-GATED (Inv #153/#157) — the Pastor runs this in Supabase only if needed.
-- ============================================================================

INSERT INTO attendance
SELECT b.*
FROM _backup_devo_attendance_cleanup_20260620 b
WHERE NOT EXISTS (
  SELECT 1 FROM attendance a WHERE a.id = b.id
);

-- Verify the restore (ONE row): restored_now should match the backup count.
SELECT
  (SELECT count(*) FROM _backup_devo_attendance_cleanup_20260620) AS rows_in_backup,
  (SELECT count(*)
     FROM attendance a
     JOIN _backup_devo_attendance_cleanup_20260620 b ON b.id = a.id) AS rows_present_in_attendance;

-- Drop the backup table ONLY after the Pastor confirms the restore looks right:
-- DROP TABLE IF EXISTS _backup_devo_attendance_cleanup_20260620;

-- ============================================================================
-- END 011_rollback.sql
-- ============================================================================
