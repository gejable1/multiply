-- ============================================================================
-- migrations/002_normalize_usbong_stems.sql
-- Normalize drifted question stems on Usbong 1, lessons 6–10:
--   stem_en / stem_tl  →  question_en / question_tl   (the #125 canonical key).
--
-- WHY: lessons 6–10 stored each question's stem under stem_en/stem_tl, while the
-- quiz players (pre-`_qText`) and lesson_quiz_editor.html (reads question_en
-- only, lines 827–828) read question_en → the stem rendered BLANK while the
-- choices showed. The players were already hardened with a tolerant _qText
-- accessor (commit 0e5fa20); this migration fixes the DATA so the EDITOR (and any
-- other question_en consumer) shows the stems too.
--
-- SCOPE: ONLY the stem keys. Options are deliberately left as {en,tl,correct} —
-- they are tolerated everywhere (players via _optText; the editor remaps
-- label_en⇄en on load and re-canonicalizes to label_en on save), so renaming
-- them is unnecessary risk.
--
-- Human-gated (Inv #153): the PASTOR runs this in the Supabase SQL editor; CC
-- holds no service-role key. ADDITIVE-shaped + IDEMPOTENT: transforms only
-- questions that HAVE stem_en and LACK question_en, and the `IS DISTINCT FROM`
-- guard makes a re-run a no-op. Scoped to Usbong 1 L6–10 (lessons 1–5 are already
-- canonical question_en and are never touched).
-- Rollback: migrations/002_rollback.sql (Inv #157 — Free tier = no backups).
-- ============================================================================

UPDATE usbong_quizzes uq
SET questions  = sub.new_questions,
    updated_at = now()
FROM (
  SELECT q.id,
         jsonb_agg(
           CASE
             WHEN (elem ? 'stem_en') AND NOT (elem ? 'question_en') THEN
               (elem - 'stem_en' - 'stem_tl')
               || jsonb_build_object('question_en', elem->'stem_en')
               || CASE WHEN elem ? 'stem_tl'
                       THEN jsonb_build_object('question_tl', elem->'stem_tl')
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
  AND uq.questions IS DISTINCT FROM sub.new_questions;   -- idempotent: skip if unchanged


-- ── VERIFY (Inv #125): every question on Usbong 1 L6–10 now has a non-null
--    question_en and NO leftover stem_en. Expect, per lesson:
--    all_have_question_en = true,  any_stem_en_left = false.
SELECT lesson_number,
       bool_and((elem->>'question_en') IS NOT NULL) AS all_have_question_en,
       bool_or(elem ? 'stem_en')                    AS any_stem_en_left
FROM usbong_quizzes,
     LATERAL jsonb_array_elements(questions) AS e(elem)
WHERE course_code = 'Usbong 1' AND lesson_number BETWEEN 6 AND 10
GROUP BY lesson_number
ORDER BY lesson_number;

-- ============================================================================
-- END 002_normalize_usbong_stems.sql
-- ============================================================================
