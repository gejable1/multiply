-- ============================================================================
-- migrations/011_devo_reflection_streak_cleanup.sql
--   EXECUTED by Pastor in Supabase 2026-06-20 (today-inclusive). Committed for
--   record. Idempotent — safe but unnecessary to re-run.
--   HUMAN-GATED (Inv #153): the Pastor runs migrations in the Supabase SQL editor.
--
-- Purpose (Inv #62 + 10-word rule): a devotional attendance row means reflection
-- COMPLETION. Historically closeDevoReader wrote that row on reader-close even
-- with no/short reflection. This deletes those orphan rows so the streak reflects
-- real >=10-word reflections.
--
-- TODAY-INCLUSIVE (no event_date < Manila-today guard): today is safe to clean
-- because (a) the shipped Part A code (member_tool.html aa78dd5) no longer writes
-- a read-only/short-reflection attendance row, and (b) an in-progress entry has
-- NO attendance row until the reader is closed — so there is nothing to clobber.
-- Do NOT "re-helpfully" re-add an event_date exclusion.
--
-- SAFETY: Step 1 backs up every doomed row into a new table FIRST. That backup
-- IS the rollback source (Inv #10/#157 — free tier has no DB backups). Step 2
-- deletes. Step 3 verifies (one row). Re-running is safe: the backup INSERT skips
-- already-captured ids; the DELETE is a no-op once the rows are gone.
--
-- Doomed predicate (today-inclusive — identical to the cleanup below):
--   a.event_type = 'devotional'
--   AND NOT EXISTS (a >=10-word reflection for same member_id + event_date=entry_date)
--
-- 10-word predicate ('\s+' is correct under standard_conforming_strings):
--   CASE WHEN COALESCE(TRIM(r.reflection),'') = '' THEN 0
--        ELSE array_length(regexp_split_to_array(TRIM(r.reflection), '\s+'), 1) END >= 10
--
-- Columns confirmed from deployed code (schema.json is local-only/gitignored):
--   attendance(member_id, member_name, event_type, event_date)
--   devotional_reflections(member_id, entry_date, reflection)
-- ============================================================================

-- ── Step 1 — backup (rollback source) ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS _backup_devo_attendance_cleanup_20260620 (LIKE attendance);
ALTER TABLE _backup_devo_attendance_cleanup_20260620 DISABLE ROW LEVEL SECURITY;

INSERT INTO _backup_devo_attendance_cleanup_20260620
SELECT a.*
FROM attendance a
WHERE a.event_type = 'devotional'
  AND NOT EXISTS (
    SELECT 1
    FROM devotional_reflections r
    WHERE r.member_id = a.member_id
      AND r.entry_date = a.event_date
      AND CASE WHEN COALESCE(TRIM(r.reflection), '') = '' THEN 0
               ELSE array_length(regexp_split_to_array(TRIM(r.reflection), '\s+'), 1) END >= 10
  )
  AND NOT EXISTS (
    SELECT 1 FROM _backup_devo_attendance_cleanup_20260620 b WHERE b.id = a.id
  );

-- ── Step 2 — delete the doomed rows (today-inclusive) ───────────────────────
DELETE FROM attendance a
WHERE a.event_type = 'devotional'
  AND NOT EXISTS (
    SELECT 1
    FROM devotional_reflections r
    WHERE r.member_id = a.member_id
      AND r.entry_date = a.event_date
      AND CASE WHEN COALESCE(TRIM(r.reflection), '') = '' THEN 0
               ELSE array_length(regexp_split_to_array(TRIM(r.reflection), '\s+'), 1) END >= 10
  );

-- ── Step 3 — verify (ONE row) ───────────────────────────────────────────────
-- Expect: rows_backed_up = the diagnostic's WILL-DELETE count,
--         remaining_should_be_zero = 0.
SELECT
  (SELECT count(*) FROM _backup_devo_attendance_cleanup_20260620) AS rows_backed_up,
  (SELECT count(*)
     FROM attendance a
     WHERE a.event_type = 'devotional'
       AND NOT EXISTS (
         SELECT 1
         FROM devotional_reflections r
         WHERE r.member_id = a.member_id
           AND r.entry_date = a.event_date
           AND CASE WHEN COALESCE(TRIM(r.reflection), '') = '' THEN 0
                    ELSE array_length(regexp_split_to_array(TRIM(r.reflection), '\s+'), 1) END >= 10
       )
  ) AS remaining_should_be_zero;

-- ============================================================================
-- END 011_devo_reflection_streak_cleanup.sql
-- ============================================================================
