-- migrations/117_promo_team_lesson_seed.sql  (v2 - NULL-church-aware)
-- S90 - Promo Team champion lesson.
-- FACTS THIS VERSION ENCODES (learned from the live run of v1):
--   * cohort_programs rows created via MD go through catalogWrite -> the
--     CANONICAL lane: church_id IS NULL, shared across churches (like BTLI 101).
--   * pipeline_lessons read policy is base-or-mine (033): a canonical lesson
--     (church_id NULL) is readable by every church; audience='cohort_only'
--     still gates visibility to granted cohorts only.
--   * pipeline_lesson_grants and cohort_lesson_unlocks are STRICT mine-only
--     (016): those rows MUST be church-stamped or members cannot read them
--     and the lesson resolves invisible.
-- THEREFORE: lesson stays canonical (NULL, matching its program); the grant
-- and the unlock are stamped with the FOUNDING COHORT's church_id (derived,
-- never hardcoded). A future church adopting the shared program needs its own
-- church-stamped grant row - one INSERT, the platform-graduation step.
-- RUN FLAT (no BEGIN/COMMIT) - Inv #209. Idempotent; rerun-until-true.
-- All church comparisons are NULL-safe (IS NOT DISTINCT FROM) - v1 failed
-- precisely because NULL = NULL is not true.

-- 1) The lesson row - canonical, like its program. LIMIT 1 guards dup names.
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
    AND pl.church_id IS NOT DISTINCT FROM p.church_id
);

-- 2) Program-level grant, stamped with the FOUNDING cohort's church so its
--    members can read it (strict RLS). Derived from '2026 Promo Team'.
INSERT INTO public.pipeline_lesson_grants (lesson_id, program_id, church_id)
SELECT pl.id, p.id, c.church_id
FROM (
  SELECT id, church_id FROM public.cohort_programs
  WHERE name = 'MULTIPLY Promotional Team'
  ORDER BY created_at ASC
  LIMIT 1
) p
JOIN public.cohorts c
  ON c.program_id = p.id AND c.name = '2026 Promo Team'
JOIN public.pipeline_lessons pl
  ON pl.title_en = 'Promo Team - Champion Training'
 AND pl.church_id IS NOT DISTINCT FROM p.church_id
WHERE c.church_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM public.pipeline_lesson_grants g
    WHERE g.lesson_id = pl.id AND g.program_id = p.id
      AND g.church_id IS NOT DISTINCT FROM c.church_id
  );

-- 3) Day-one unlock for the founding batch (church-stamped from the cohort;
--    unlocked_at set: the resolver treats NULL unlocked_at as still locked).
INSERT INTO public.cohort_lesson_unlocks (cohort_id, lesson_id, unlocked_at, notes, church_id)
SELECT c.id, pl.id, now(),
  'S90 seed: day-one unlock for the founding promo batch',
  c.church_id
FROM (
  SELECT id, church_id FROM public.cohort_programs
  WHERE name = 'MULTIPLY Promotional Team'
  ORDER BY created_at ASC
  LIMIT 1
) p
JOIN public.cohorts c
  ON c.program_id = p.id AND c.name = '2026 Promo Team'
JOIN public.pipeline_lessons pl
  ON pl.title_en = 'Promo Team - Champion Training'
 AND pl.church_id IS NOT DISTINCT FROM p.church_id
WHERE NOT EXISTS (
  SELECT 1 FROM public.cohort_lesson_unlocks u
  WHERE u.cohort_id = c.id AND u.lesson_id = pl.id
);

-- 4) Ledger stamp (023 contract) - DO UPDATE restamps over the v1 run.
INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('117', '117_promo_team_lesson_seed.sql',
        'S90 promo team lesson v2: canonical lesson + church-stamped program grant + founding-batch unlock (NULL-safe joins)')
ON CONFLICT (version) DO UPDATE
  SET filename = EXCLUDED.filename, note = EXCLUDED.note, applied_at = now();

-- 5) Self-verify - rerun the whole file until every row reads PASS.
SELECT 'program row (canonical)' AS checkpoint,
       CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL (' || COUNT(*) || ')' END AS status
FROM public.cohort_programs WHERE name = 'MULTIPLY Promotional Team'
UNION ALL
SELECT 'lesson row (canonical)',
       CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL (' || COUNT(*) || ')' END
FROM public.pipeline_lessons
WHERE title_en = 'Promo Team - Champion Training'
  AND audience = 'cohort_only' AND published = true
  AND jsonb_array_length(attachments) = 3
UNION ALL
SELECT 'program grant (church-stamped)',
       CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL (' || COUNT(*) || ')' END
FROM public.pipeline_lesson_grants g
JOIN public.pipeline_lessons pl ON pl.id = g.lesson_id
WHERE pl.title_en = 'Promo Team - Champion Training'
  AND g.program_id IS NOT NULL AND g.church_id IS NOT NULL
UNION ALL
SELECT 'founding-batch unlock (church-stamped)',
       CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL (' || COUNT(*) || ')' END
FROM public.cohort_lesson_unlocks u
JOIN public.pipeline_lessons pl ON pl.id = u.lesson_id
JOIN public.cohorts c ON c.id = u.cohort_id
WHERE pl.title_en = 'Promo Team - Champion Training'
  AND c.name = '2026 Promo Team'
  AND u.unlocked_at IS NOT NULL AND u.church_id IS NOT NULL
UNION ALL
SELECT 'ledger 117',
       CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL (' || COUNT(*) || ')' END
FROM public.schema_migrations WHERE version = '117';
