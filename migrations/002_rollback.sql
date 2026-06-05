-- ============================================================================
-- migrations/002_rollback.sql
-- EMERGENCY UNDO for 002_normalize_usbong_stems.sql. Human-gated (Inv #153) —
-- the PASTOR runs this in the Supabase SQL editor ONLY to reverse migration 002.
-- Free tier = no DB backups (Inv #157), so this is the manual undo.
--
-- Reverses 002 on Usbong 1, lessons 6–10:
--   question_en / question_tl  →  stem_en / stem_tl
--
-- IDEMPOTENT: transforms only questions that HAVE question_en and LACK stem_en,
-- and the `IS DISTINCT FROM` guard makes a re-run a no-op. Scoped to L6–10 so it
-- NEVER touches the canonically-question_en lessons 1–5. (If a question was added
-- to L6–10 via the editor after 002, this reverts its stem to stem_en too — the
-- intended pre-002 shape.)
-- ============================================================================

UPDATE usbong_quizzes uq
SET questions  = sub.new_questions,
    updated_at = now()
FROM (
  SELECT q.id,
         jsonb_agg(
           CASE
             WHEN (elem ? 'question_en') AND NOT (elem ? 'stem_en') THEN
               (elem - 'question_en' - 'question_tl')
               || jsonb_build_object('stem_en', elem->'question_en')
               || CASE WHEN elem ? 'question_tl'
                       THEN jsonb_build_object('stem_tl', elem->'question_tl')
                       ELSE '{}'::jsonb END
             ELSE elem
           END
           ORDER BY ord
         ) AS new_questions
  FROM usbong_quizzes q,
       LATERAL jsonb_array_elements(q.questions) WITH ORDINALITY AS e(elem, ord)
  WHERE q.course_code = 'Usbong 1'
    AND q.lesson_number BETWEEN 6 AND 10
  GROUP BY q.id
) sub
WHERE uq.id = sub.id
  AND uq.questions IS DISTINCT FROM sub.new_questions;

-- ============================================================================
-- END 002_rollback.sql
-- ============================================================================
