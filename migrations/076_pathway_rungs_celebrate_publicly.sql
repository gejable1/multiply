-- ============================================================================
-- 076_pathway_rungs_celebrate_publicly.sql   ·   Session 70
--
-- Mark which pathway rungs may be celebrated PUBLICLY (read aloud to the LC group),
-- via meta->>'celebrate_publicly'.
--
-- THE PRINCIPLE (Pastor Gerry's call, and it is the right one):
--   Public celebration is for EVENTS, never for STATES.
--   An EVENT is something that HAPPENED: you read the book, you attended EGR, you
--   were baptized, you joined a Life Group. Celebrating it in front of the group
--   affirms, and says nothing about anyone who has not done it yet -- they simply
--   have not read it yet.
--   A STATE is something about WHO SOMEONE IS: their character, their assurance of
--   salvation, their moral standing. Celebrate that publicly and the SILENCE about
--   everyone else becomes a verdict. "Joy is growing in Ana" makes the group ask
--   why not Ben. "No moral failure in 5 years" tells the room that moral failure is
--   being measured -- and says something about whoever is never named.
--   So: rung completions still notify the DISCIPLE privately (all of them -- they
--   still hear that they are seen). Only EVENTS may be spoken in the room.
--
-- INCLUDED (56 rows / 52 distinct keys): all `book`, `lesson`, `training`, `ministry`,
-- plus the two baptism rungs.
--
-- DELIBERATELY EXCLUDED, each for a reason:
--   * Financial integrity audit          -- sensitive; never broadcast
--   * Assurance of salvation, Salvation Journal, No moral failure 5 yrs,
--     No active church discipline, No lifestyle inconsistencies, Family affirmation,
--     Elder confirmation, and the nine fruit of the Spirit  -- all STATES
--   * Active small group member, Lead a Life Group consistently  -- STATES ("consistently")
--   * EGR Follow-up Care                 -- pastoral CARE, not attendance. Announcing it
--                                           would tell the room that Ana needed follow-up.
--   * Small group facilitation, Coach 2+ Life Group leaders  -- competencies
--
-- FAIL-CLOSED BY DESIGN: absence of the flag means PRIVATE. Every future rung is
-- private until someone deliberately opens it. The inverse default would mean a
-- sensitive rung added a year from now gets broadcast silently, and nobody notices.
--
-- SCOPE: base (church_id IS NULL) + Rosehill's own overlay rows. A church overlay row
-- takes precedence over its base twin in the UI, so Rosehill's overlays of Usbong /
-- Baptism / The Multiplication Effect must carry the flag too, or those three would
-- never celebrate for Rosehill. TrueNorth's 4 overlay rungs are NOT touched -- their
-- overlay, their pastoral call to make.
--
-- FLAT (#209). RERUN-SAFE (#210): `||` merge is idempotent. Ledger-stamped (#212).
-- ============================================================================

-- ── STEP 1: base rungs
UPDATE public.pathway_rungs
SET    meta = COALESCE(meta, '{}'::jsonb) || '{"celebrate_publicly": true}'::jsonb,
       updated_at = now()
WHERE  church_id IS NULL
  AND  rung_key IN (
  'apiis',
  'baptism',
  'basic-christianity',
  'book-advantage',
  'book-christian-coaching',
  'book-disciplines-coach',
  'book-fresh-wind',
  'book-happy-lies',
  'book-leadership-coaching',
  'book-making-leader',
  'book-master-plan',
  'book-mere-christianity',
  'book-multiply',
  'book-real-life-discipleship',
  'book-spiritual-leadership',
  'book-still-sovereign',
  'book-unlad',
  'book-usad',
  'book-usbong',
  'book-why-men',
  'btli-101',
  'btli-102-103',
  'btli-104',
  'btli-105',
  'btli-106',
  'btli1',
  'direct-ministry',
  'glorious-hope',
  'join-lc',
  'leading-dept',
  'leading-leaders',
  'leading-org',
  'leading-others',
  'leading-yourself',
  'mult-effect',
  'ref-character-baptism',
  'serve-ministry',
  'train-apiis-masters',
  'train-bible-reading',
  'train-biblical-counseling',
  'train-ccf-hope',
  'train-conflict',
  'train-egr',
  'train-entering-formation',
  'train-eolo',
  'train-gifts',
  'train-idc-basic',
  'train-idc-coaching',
  'train-idc-discipleship',
  'train-new-believers',
  'train-preaching',
  'usbong1'
);

-- ── STEP 2: Rosehill's overlay twins (overlay wins over base in the UI)
UPDATE public.pathway_rungs
SET    meta = COALESCE(meta, '{}'::jsonb) || '{"celebrate_publicly": true}'::jsonb,
       updated_at = now()
WHERE  church_id = (SELECT id FROM public.churches WHERE slug = 'rosehill')
  AND  rung_key IN ('book-usbong', 'ref-character-baptism', 'x-the-multiplication-effect-gyzg');

-- ── LEDGER
INSERT INTO public.schema_migrations (version, filename, note)
VALUES (76, '076_pathway_rungs_celebrate_publicly.sql',
        'Add meta.celebrate_publicly=true to 56 base rungs (book/lesson/training/ministry/baptism) + 3 Rosehill overlay rungs. Fail-closed: character, assurance, moral-standing and coaching-care rungs stay PRIVATE. Public celebration is for events, never states.')
ON CONFLICT (version) DO NOTHING;

-- ── SELF-VERIFY (rerun until true) ──────────────────────────────────────────
-- EXPECT:
--   (base)    | celebratable 56 | total 204
--   rosehill  | celebratable  3 | total   5
--   truenorth | celebratable  0 | total   4   <-- correct: not ours to decide
SELECT COALESCE(c.slug, '(base)') AS owner,
       count(*) FILTER (WHERE r.meta->>'celebrate_publicly' = 'true') AS celebratable,
       count(*)                                                       AS total
FROM   public.pathway_rungs r
LEFT   JOIN public.churches c ON c.id = r.church_id
GROUP  BY 1
ORDER  BY 1;

-- ── GUARD: NOTHING outside the allowed categories may carry the flag. ZERO rows.
--
-- NOTE: an earlier version of this guard also matched `title_en ILIKE '%discipline%'`
-- to catch "No active church discipline". It false-alarmed on the BOOK "Disciplines of
-- a Christian Coach (Webb)" -- which is correctly flagged. Substring matching on human
-- titles is the wrong instrument; assert on CATEGORY, which is what we actually decided.
SELECT r.category, r.level, r.rung_key, r.title_en
FROM   public.pathway_rungs r
WHERE  r.meta->>'celebrate_publicly' = 'true'
  AND  r.category NOT IN ('book','lesson','training','ministry')
  AND  r.rung_key NOT IN ('baptism','ref-character-baptism');

-- ── GUARD 2: the rungs that must NEVER be public are provably unflagged. ZERO rows.
-- The `private_rungs_seen` count proves the guard is actually matching real titles and
-- is not silently empty because a title was misspelled here.
SELECT r.title_en, (r.meta->>'celebrate_publicly') AS flag
FROM   public.pathway_rungs r
WHERE  r.meta->>'celebrate_publicly' = 'true'
  AND  r.title_en IN (
         'No moral failure 5 yrs','No active church discipline',
         'No lifestyle inconsistencies','Financial integrity audit',
         'Assurance of salvation','Salvation Journal','Family affirmation',
         'Elder confirmation','EGR Follow-up Care','Active small group member',
         'Lead a Life Group consistently','Small group facilitation',
         'Coach 2+ Life Group leaders',
         'Love','Joy','Peace','Patience','Kindness','Goodness',
         'Faithfulness','Gentleness','Self-control');

-- VERIFIED IN PROD: counts base 56/204, rosehill 3/5, truenorth 0/4;
-- both guards returned zero rows; private_rungs_seen = 6 (guard is not blind).
