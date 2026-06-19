-- ============================================================================
-- migrations/011_diagnostic_devo_streak.sql  — READ-ONLY. Run FIRST.
--
-- Counts the "doomed" devotional attendance rows that the streak↔reflection
-- coupling (Inv #62 + 10-word rule) makes obsolete: a devotional attendance row
-- (= reflection COMPLETION) that has NO qualifying >=10-word reflection for the
-- same member + same date.
--
-- This file does NOT change anything. Look at the summary row, optionally
-- eyeball the detail SELECT (uncomment), THEN run 011_devo_reflection_streak_cleanup.sql.
--
-- "Doomed" predicate (used identically in the cleanup migration):
--   a.event_type = 'devotional'
--   AND a.event_date < (now() AT TIME ZONE 'Asia/Manila')::date   -- exclude Manila-today
--   AND NOT EXISTS (a >=10-word reflection for same member_id + same date)
--
-- 10-word predicate (whitespace-split, NULL/blank → 0):
--   CASE WHEN coalesce(trim(r.reflection),'') = '' THEN 0
--        ELSE array_length(regexp_split_to_array(trim(r.reflection), '\s+'), 1) END >= 10
-- ============================================================================

-- ── Summary (ONE row) ───────────────────────────────────────────────────────
SELECT
  count(*)                          AS rows_to_delete,
  count(DISTINCT a.member_id)       AS members_affected,
  min(a.event_date)                 AS earliest_date,
  max(a.event_date)                 AS latest_date
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
  );

-- ── Detail (up to 100 doomed rows) — UNCOMMENT to eyeball before deleting ────
-- SELECT a.id, a.member_id, a.member_name, a.event_date
-- FROM attendance a
-- WHERE a.event_type = 'devotional'
--   AND a.event_date < (now() AT TIME ZONE 'Asia/Manila')::date
--   AND NOT EXISTS (
--     SELECT 1
--     FROM devotional_reflections r
--     WHERE r.member_id = a.member_id
--       AND r.entry_date = a.event_date
--       AND CASE WHEN coalesce(trim(r.reflection), '') = '' THEN 0
--                ELSE array_length(regexp_split_to_array(trim(r.reflection), '\s+'), 1) END >= 10
--   )
-- ORDER BY a.event_date DESC
-- LIMIT 100;

-- ============================================================================
-- END 011_diagnostic_devo_streak.sql
-- ============================================================================
