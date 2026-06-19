-- ============================================================================
-- migrations/011_diagnostic_devo_streak.sql  — READ-ONLY. Run FIRST.
--
-- Eyeball the last 14 days of devotional attendance before the cleanup. Each row
-- is a devotional attendance day; reflection_words = the MAX word count across
-- the member's reflection(s) for that date; status = 'WILL DELETE' when there is
-- NO >=10-word reflection (the streak↔reflection coupling, Inv #62 + 10-word rule)
-- else 'keep'. This file changes nothing.
--
-- 10-word predicate (whitespace-split, NULL/blank → 0; '\s+' is correct under
-- standard_conforming_strings):
--   CASE WHEN COALESCE(TRIM(r.reflection),'') = '' THEN 0
--        ELSE array_length(regexp_split_to_array(TRIM(r.reflection), '\s+'), 1) END
--
-- Columns confirmed from deployed code (schema.json is local-only/gitignored):
--   attendance(member_id, member_name, event_type, event_date)
--   devotional_reflections(member_id, entry_date, reflection)
-- ============================================================================

SELECT
  a.member_name,
  a.event_date,
  COALESCE((
    SELECT MAX(
      CASE WHEN COALESCE(TRIM(r.reflection), '') = '' THEN 0
           ELSE array_length(regexp_split_to_array(TRIM(r.reflection), '\s+'), 1) END
    )
    FROM devotional_reflections r
    WHERE r.member_id = a.member_id
      AND r.entry_date = a.event_date
  ), 0) AS reflection_words,
  CASE WHEN NOT EXISTS (
         SELECT 1
         FROM devotional_reflections r
         WHERE r.member_id = a.member_id
           AND r.entry_date = a.event_date
           AND CASE WHEN COALESCE(TRIM(r.reflection), '') = '' THEN 0
                    ELSE array_length(regexp_split_to_array(TRIM(r.reflection), '\s+'), 1) END >= 10
       )
       THEN 'WILL DELETE' ELSE 'keep' END AS status
FROM attendance a
WHERE a.event_type = 'devotional'
  AND a.event_date >= ((now() AT TIME ZONE 'Asia/Manila')::date - INTERVAL '14 days')
ORDER BY a.event_date DESC, a.member_name;

-- ============================================================================
-- END 011_diagnostic_devo_streak.sql
-- ============================================================================
