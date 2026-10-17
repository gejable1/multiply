-- migrations/121_btli1_l9_quiz_wording.sql
-- S104 - BTLI 1 L9 quiz: align wording with the rebuilt L9 guides (L15 spec).
-- Tagalog lines now use the same English Bible-book names as the guides
-- (Matthew, 2 Corinthians, 1 Thessalonians, Romans, John, Ephesians, 2 Timothy),
-- and Q3's Tagalog answer reads naturally ("...at hindi maapektuhan ang mensahe").
-- Questions, answers and correct flags are otherwise UNCHANGED. Text-only edit.
-- RUN FLAT (no BEGIN/COMMIT). Idempotent; rerun-until-true.

UPDATE public.btli_quizzes
SET questions = (replace(replace(replace(replace(replace(replace(replace(replace(questions::text, 'Para hindi masira ang imahe na sumisira sa mensahe', 'Para hindi masira ang imahe at hindi maapektuhan ang mensahe'), 'Mateo 28:19', 'Matthew 28:19'), '2 Corinto 5:20', '2 Corinthians 5:20'), '1 Tesalonica 2:', '1 Thessalonians 2:'), 'Roma 6:23', 'Romans 6:23'), 'Juan 3:16', 'John 3:16'), 'Efeso 2:8-9', 'Ephesians 2:8-9'), '2 Timoteo 2:2', '2 Timothy 2:2'))::jsonb
WHERE course_code = 'BTLI 1' AND lesson_number = 9
  AND (questions::text LIKE '%Para hindi masira ang imahe na sumisira sa mensahe%' OR questions::text LIKE '%Mateo 28:19%' OR questions::text LIKE '%2 Corinto 5:20%' OR questions::text LIKE '%1 Tesalonica 2:%' OR questions::text LIKE '%Roma 6:23%' OR questions::text LIKE '%Juan 3:16%' OR questions::text LIKE '%Efeso 2:8-9%' OR questions::text LIKE '%2 Timoteo 2:2%');

INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('121', '121_btli1_l9_quiz_wording.sql',
        'S104: BTLI 1 L9 quiz Tagalog wording aligned with rebuilt L9 guides (English book names; Q3 answer phrasing). Text-only.')
ON CONFLICT (version) DO UPDATE
  SET filename = EXCLUDED.filename, note = EXCLUDED.note, applied_at = now();

SELECT 'L9 quiz row found' AS checkpoint,
       CASE WHEN (SELECT count(*) FROM public.btli_quizzes WHERE course_code='BTLI 1' AND lesson_number=9) = 1 THEN 'PASS' ELSE 'FAIL' END AS status
UNION ALL
SELECT 'still 10 questions',
       CASE WHEN (SELECT jsonb_array_length(questions) FROM public.btli_quizzes WHERE course_code='BTLI 1' AND lesson_number=9) = 10 THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'old wording gone',
       CASE WHEN NOT EXISTS (SELECT 1 FROM public.btli_quizzes WHERE course_code='BTLI 1' AND lesson_number=9 AND (questions::text LIKE '%Para hindi masira ang imahe na sumisira sa mensahe%' OR questions::text LIKE '%Mateo 28:19%' OR questions::text LIKE '%2 Corinto 5:20%' OR questions::text LIKE '%1 Tesalonica 2:%' OR questions::text LIKE '%Roma 6:23%' OR questions::text LIKE '%Juan 3:16%' OR questions::text LIKE '%Efeso 2:8-9%' OR questions::text LIKE '%2 Timoteo 2:2%')) THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'answer key unchanged (8 MC correct + 1 TF true)',
       CASE WHEN (SELECT count(*) FROM public.btli_quizzes b, jsonb_array_elements(b.questions) q, jsonb_array_elements(coalesce(q->'options','[]'::jsonb)) o
                  WHERE b.course_code='BTLI 1' AND b.lesson_number=9 AND (o->>'correct')::boolean) = 8
             AND (SELECT count(*) FROM public.btli_quizzes b, jsonb_array_elements(b.questions) q
                  WHERE b.course_code='BTLI 1' AND b.lesson_number=9 AND q->>'type'='tf' AND (q->>'correct')::boolean) = 1
            THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'ledger 121',
       CASE WHEN EXISTS (SELECT 1 FROM public.schema_migrations WHERE version='121') THEN 'PASS' ELSE 'FAIL' END;
