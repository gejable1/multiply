-- ============================================================================
-- 075_rosehill_overlay_title_tl.sql   ·   Session 70
--
-- Backfill title_tl for Rosehill's 5 OVERLAY pathway rungs.
--
-- WHY: migration 074 filled every BASE rung (church_id IS NULL, 204 rows), but by
-- design it carried `WHERE church_id IS NULL` and therefore never touched a church's
-- own overlay rows. Rosehill has 5 overlay rungs, all still title_tl = NULL, so they
-- would keep showing English in BOTH language modes even after 074.
--
-- SCOPE: Rosehill ONLY. TrueNorth's 4 overlay rungs are deliberately NOT touched --
-- their overlay is their own to translate or leave. We scope by churches.slug rather
-- than a hardcoded UUID so this is readable and cannot hit the wrong tenant.
--
-- MATCHING: on rung_key, not title_en. Overlay keys are unique per (church, level)
-- and are the stable handle; one key here is auto-generated
-- ("x-the-multiplication-effect-gyzg") and its title could be re-edited later.
--
-- TRANSLATION NOTES:
--   * Usbong / Baptism reuse the exact wording 074 gave their base twins, so the
--     overlay and the base never disagree with each other in the UI.
--   * "The Multiplication Effect" (Mac Lake) is a BOOK TITLE -- kept English on
--     purpose, with title_tl set equal to title_en so the choice is explicit in the
--     data rather than implied by a NULL.
--   * DISC is a brand; it stays as the trailing qualifier rather than being translated.
--
-- FLAT (#209). RERUN-SAFE (#210): only writes rows whose title_tl is still NULL/blank,
-- so a re-run changes nothing and never clobbers a later hand-edit. Ledger-stamped (#212).
-- ============================================================================

UPDATE public.pathway_rungs r
SET    title_tl = v.tl,
       updated_at = now()
FROM  (VALUES
  ('book-usbong',                        'Usbong (Debosyonal)'),
  ('ref-character-baptism',              'Bautismo'),
  ('disc',                               'Pagsusuri sa istilo ng pagtatrabaho (DISC)'),
  ('conflict',                           'Pagsusuri sa istilo sa pagharap sa alitan'),
  ('x-the-multiplication-effect-gyzg',   'The Multiplication Effect')
) AS v(rk, tl)
WHERE  r.church_id = (SELECT id FROM public.churches WHERE slug = 'rosehill')
  AND  r.rung_key = v.rk
  AND  (r.title_tl IS NULL OR btrim(r.title_tl) = '');

-- ── LEDGER
INSERT INTO public.schema_migrations (version, filename, note)
VALUES (75, '075_rosehill_overlay_title_tl.sql',
        'Backfill title_tl for Rosehill''s 5 overlay pathway_rungs (074 covered base rows only). TrueNorth overlay intentionally untouched.')
ON CONFLICT (version) DO NOTHING;

-- ── SELF-VERIFY (rerun until true) ──────────────────────────────────────────
-- EXPECT exactly 3 rows:
--   (base)     | 204 rungs | 0 missing_tl
--   rosehill   |   5 rungs | 0 missing_tl   <-- this migration
--   truenorth  |   4 rungs | 4 missing_tl   <-- CORRECT: not ours to translate
SELECT COALESCE(c.slug, '(base)') AS owner,
       count(*)                                                                  AS rungs,
       count(*) FILTER (WHERE r.title_tl IS NULL OR btrim(r.title_tl) = '')      AS missing_tl
FROM   public.pathway_rungs r
LEFT   JOIN public.churches c ON c.id = r.church_id
GROUP  BY 1
ORDER  BY 1;
