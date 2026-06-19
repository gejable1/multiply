-- ============================================================================
-- migrations/011_devo_reflection_streak_cleanup.sql
--   Idempotent. Run AFTER 011_diagnostic_devo_streak.sql (eyeballed the count).
--   HUMAN-GATED (Inv #153): the Pastor runs this in the Supabase SQL editor.
--
-- Purpose (Inv #62 + 10-word rule): a devotional attendance row means reflection
-- COMPLETION. Historically closeDevoReader wrote that row on reader-close even
-- with no/short reflection. This deletes those orphan rows so the streak reflects
-- real >=10-word reflections — but ONLY past days (Manila-today excluded so an
-- in-progress entry is never clobbered) AND only where no qualifying reflection exists.
--
-- SAFETY: Step 1 backs up every doomed row into a new table FIRST. That backup
-- IS the rollback source (Inv #10/#157 — free tier has no DB backups). Step 2
-- deletes. Step 3 verifies (one row). Re-running is safe: the backup INSERT skips
-- already-captured ids; the DELETE is a no-op once the rows are gone.
--
-- Doomed predicate (identical to the diagnostic):
--   a.event_type = 'devotional'
--   AND a.event_date < (now() AT TIME ZONE 'Asia/Manila')::date
--   AND NOT EXISTS (a >=10-word reflection for same member_id + same date)
-- ============================================================================

-- ── Step 1 — backup (rollback source) ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS _backup_devo_attendance_cleanup_20260620 (LIKE attendance);
ALTER TABLE _backup_devo_attendance_cleanup_20260620 DISABLE ROW LEVEL SECURITY;

INSERT INTO _backup_devo_attendance_cleanup_20260620
SELECT a.*
FROM attendance a
WHERE a.event_type = 'devotional'
  AND a.event_date < (now() AT TIME ZONE 'Asia/Manila')::date
  AND NOT EXISTS (
    SELECT 1
    FROM devotional_reflections r
    WHERE r.member_id = a.member_id
      AND r.entry_date = a.event_date
      AND CASE WHEN coalesce(trim(r.reflection), '') = '' THEN 0
               ELSE array_length(regexp_split_to_array(trim(r.reflection), '\s+'), 1) END >= 10
  )
  AND NOT EXISTS (
    SELECT 1 FROM _backup_devo_attendance_cleanup_20260620 b WHERE b.id = a.id
  );

-- ── Step 2 — delete the doomed rows ─────────────────────────────────────────
DELETE FROM attendance a
WHERE a.event_type = 'devotional'
  AND a.event_date < (now() AT TIME ZONE 'Asia/Manila')::date
  AND NOT EXISTS (
    SELECT 1
    FROM devotional_reflections r
    WHERE r.member_id = a.member_id
      AND r.entry_date = a.event_date
      AND CASE WHEN coalesce(trim(r.reflection), '') = '' THEN 0
               ELSE array_length(regexp_split_to_array(trim(r.reflection), '\s+'), 1) END >= 10
  );

-- ── Step 3 — verify (ONE row) ───────────────────────────────────────────────
-- Expect: rows_backed_up = the diagnostic's rows_to_delete,
--         rows_remaining_should_be_zero = 0.
SELECT
  (SELECT count(*) FROM _backup_devo_attendance_cleanup_20260620) AS rows_backed_up,
  (SELECT count(*)
     FROM attendance a
     WHERE a.event_type = 'devotional'
       AND a.event_date < (now() AT TIME ZONE 'Asia/Manila')::date
       AND NOT EXISTS (
         SELECT 1
         FROM devotional_reflections r
         WHERE r.member_id = a.member_id
           AND r.entry_date = a.event_date
           AND CASE WHEN coalesce(trim(r.reflection), '') = '' THEN 0
                    ELSE array_length(regexp_split_to_array(trim(r.reflection), '\s+'), 1) END >= 10
       )
  ) AS rows_remaining_should_be_zero;

-- ============================================================================
-- END 011_devo_reflection_streak_cleanup.sql
-- ============================================================================
