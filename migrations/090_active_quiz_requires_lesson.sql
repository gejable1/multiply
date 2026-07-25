-- 090_active_quiz_requires_lesson.sql
-- Session 80: an ACTIVE quiz must have a lesson_id.
--
-- Why: quiz visibility is being wired to pipeline_lesson_grants, resolved by
-- quiz.lesson_id -> pipeline_lessons.id. Once visibility depends on the grant,
-- a NULL lesson_id has no lesson to check a grant against. Rather than choose
-- between "fail-open" (reopen the leak) and "fail-closed" (a single missing
-- link makes a quiz vanish for everyone), we make the NULL impossible on an
-- ACTIVE quiz. Inactive drafts may still have a null lesson_id -- draft first,
-- link before activating.
--
-- Applies to BOTH btli_quizzes and usbong_quizzes -- the two curricula stay in
-- lockstep (Inv #127). A CHECK constraint (not NOT NULL) so inactive rows are
-- exempt. Flat + idempotent via DROP-then-ADD (no ADD CONSTRAINT IF NOT EXISTS
-- in Postgres). Self-verifying (#210). PG16-proven.

ALTER TABLE public.btli_quizzes
  DROP CONSTRAINT IF EXISTS btli_quizzes_active_needs_lesson;
ALTER TABLE public.btli_quizzes
  ADD CONSTRAINT btli_quizzes_active_needs_lesson
  CHECK (is_active = false OR lesson_id IS NOT NULL);

ALTER TABLE public.usbong_quizzes
  DROP CONSTRAINT IF EXISTS usbong_quizzes_active_needs_lesson;
ALTER TABLE public.usbong_quizzes
  ADD CONSTRAINT usbong_quizzes_active_needs_lesson
  CHECK (is_active = false OR lesson_id IS NOT NULL);

INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('090','090_active_quiz_requires_lesson.sql','S80: CHECK is_active=false OR lesson_id NOT NULL on btli_quizzes + usbong_quizzes (quiz visibility wired to lesson grants)')
ON CONFLICT (version) DO NOTHING;

SELECT
  (SELECT count(*) FROM pg_constraint
    WHERE conname='btli_quizzes_active_needs_lesson') = 1              AS btli_constraint,
  (SELECT count(*) FROM pg_constraint
    WHERE conname='usbong_quizzes_active_needs_lesson') = 1            AS usbong_constraint,
  (SELECT count(*) FROM public.btli_quizzes
    WHERE is_active = true AND lesson_id IS NULL) = 0                  AS btli_no_active_nulls,
  (SELECT count(*) FROM public.usbong_quizzes
    WHERE is_active = true AND lesson_id IS NULL) = 0                  AS usbong_no_active_nulls;
