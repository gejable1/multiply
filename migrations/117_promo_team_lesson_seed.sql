-- migrations/117_promo_team_lesson_seed.sql
-- S90 - Promo Team champion lesson.
-- One cohort_only lesson carrying the three promo/ documents as attachments.
-- Visibility rides a PROGRAM-level grant on "MULTIPLY Promotional Team", so
-- every batch under that program - the founding "2026 Promo Team" and every
-- future wave - sees it with zero further SQL. Participants are unlocked
-- day-one for the founding batch (future batches: Pastor's unlock button in
-- MD batch management; the resolver honors unlocked_at / scheduled_for).
-- RUN FLAT (no BEGIN/COMMIT) - Inv #209. Idempotent: every insert is guarded
-- by NOT EXISTS; rerun-until-true. Self-verify SELECT appended.
-- If the program row is missing or misnamed, all inserts are 0-row no-ops and
-- the verify SELECT reports FAIL - nothing is guessed, nothing half-lands.

-- 1) The lesson row - church-scoped to the program's own church.
--    LIMIT 1 guards the pathological duplicate-program-name case.
INSERT INTO public.pipeline_lessons
  (level, track, lesson_number, title_en, title_tl, aim, audience, published, attachments, church_id)
SELECT
  NULL,
  'Team',
  1,
  'Promo Team - Champion Training',
  'Promo Team - Pagsasanay ng Champion',
  'Equip every promo-team champion to master, model, teach, and testify about one area of MULTIPLY.',
  'cohort_only',
  true,
  '[{"label":"Champion Training (7 Areas)","url":"promo/training.html","role_required":"all"},{"label":"Mastery Cards","url":"promo/mastery_cards.html","role_required":"all"},{"label":"Testimony Page","url":"promo/testimony.html","role_required":"all"}]'::jsonb,
  p.church_id
FROM (
  SELECT id, church_id FROM public.cohort_programs
  WHERE name = 'MULTIPLY Promotional Team'
  ORDER BY created_at ASC
  LIMIT 1
) p
WHERE NOT EXISTS (
  SELECT 1 FROM public.pipeline_lessons pl
  WHERE pl.title_en = 'Promo Team - Champion Training'
    AND pl.church_id = p.church_id
);

-- 2) Program-level grant: the lesson is visible to members of ANY cohort
--    whose program is "MULTIPLY Promotional Team".
INSERT INTO public.pipeline_lesson_grants (lesson_id, program_id, church_id)
SELECT pl.id, p.id, p.church_id
FROM (
  SELECT id, church_id FROM public.cohort_programs
  WHERE name = 'MULTIPLY Promotional Team'
  ORDER BY created_at ASC
  LIMIT 1
) p
JOIN public.pipeline_lessons pl
  ON pl.title_en = 'Promo Team - Champion Training'
 AND pl.church_id = p.church_id
WHERE NOT EXISTS (
  SELECT 1 FROM public.pipeline_lesson_grants g
  WHERE g.lesson_id = pl.id AND g.program_id = p.id
);

-- 3) Day-one unlock for the founding "2026 Promo Team" batch.
--    unlocked_at MUST be set: the resolver treats a row with NULL unlocked_at
--    and NULL/future scheduled_for as still locked.
INSERT INTO public.cohort_lesson_unlocks (cohort_id, lesson_id, unlocked_at, notes, church_id)
SELECT c.id, pl.id, now(),
  'S90 seed: day-one unlock for the founding promo batch',
  c.church_id
FROM public.cohorts c
JOIN (
  SELECT id, church_id FROM public.cohort_programs
  WHERE name = 'MULTIPLY Promotional Team'
  ORDER BY created_at ASC
  LIMIT 1
) p ON c.program_id = p.id
JOIN public.pipeline_lessons pl
  ON pl.title_en = 'Promo Team - Champion Training'
 AND pl.church_id = c.church_id
WHERE c.name = '2026 Promo Team'
  AND NOT EXISTS (
    SELECT 1 FROM public.cohort_lesson_unlocks u
    WHERE u.cohort_id = c.id AND u.lesson_id = pl.id
  );

-- 4) Ledger stamp (023 contract: version PK, filename, note; DO UPDATE)
INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('117', '117_promo_team_lesson_seed.sql',
        'S90 promo team lesson: cohort_only lesson + program grant + founding-batch unlock')
ON CONFLICT (version) DO UPDATE
  SET filename = EXCLUDED.filename, note = EXCLUDED.note, applied_at = now();

-- 5) Self-verify - rerun the whole file until every row reads PASS.
SELECT 'program row'   AS checkpoint,
       CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL (' || COUNT(*) || ')' END AS status
FROM public.cohort_programs WHERE name = 'MULTIPLY Promotional Team'
UNION ALL
SELECT 'lesson row',
       CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL (' || COUNT(*) || ')' END
FROM public.pipeline_lessons
WHERE title_en = 'Promo Team - Champion Training'
  AND audience = 'cohort_only' AND published = true
  AND jsonb_array_length(attachments) = 3
UNION ALL
SELECT 'program grant',
       CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL (' || COUNT(*) || ')' END
FROM public.pipeline_lesson_grants g
JOIN public.pipeline_lessons pl ON pl.id = g.lesson_id
WHERE pl.title_en = 'Promo Team - Champion Training' AND g.program_id IS NOT NULL
UNION ALL
SELECT 'founding-batch unlock',
       CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL (' || COUNT(*) || ')' END
FROM public.cohort_lesson_unlocks u
JOIN public.pipeline_lessons pl ON pl.id = u.lesson_id
JOIN public.cohorts c ON c.id = u.cohort_id
WHERE pl.title_en = 'Promo Team - Champion Training'
  AND c.name = '2026 Promo Team' AND u.unlocked_at IS NOT NULL
UNION ALL
SELECT 'ledger 117',
       CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL (' || COUNT(*) || ')' END
FROM public.schema_migrations WHERE version = '117';
