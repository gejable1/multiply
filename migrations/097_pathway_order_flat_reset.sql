-- 097_pathway_order_flat_reset.sql
-- Session 82. Ordering arc, step 1 of 3 (Inv #400).
--
-- pathway_section_order.order_map is keyed "level|category". The member Journey
-- in MMT/MLT/MD is a FLAT list per level, so a category-scoped key cannot express
-- the intended sequence (e.g. join-lc before usbong1, different categories).
-- The arc re-keys order_map to "level".
--
-- WHY RESET RATHER THAN CONVERT: a production SELECT across all 12 churches found
-- exactly ONE entry -- Rosehill, key "0|book", 2 rung_keys, 2026-07-25 -- and it
-- never reached a member's phone because no tool reads order_map at all today.
-- Converting "0|book" -> "0" would produce a PARTIAL flat list holding only the
-- two books. Under the resolver's semantics (listed keys rank first, unlisted
-- fall back to sort_order) that hoists both books ABOVE join-lc, usbong1 and
-- daily-devo the moment the tools start reading. Proven on PG16. A reset costs
-- one pastor one re-click; a conversion silently reorders every L0 member.
--
-- This migration ONLY clears legacy-shaped maps. The key-shape CHECK constraint
-- is deliberately deferred to 098, which must run AFTER the poster is deployed
-- writing flat keys -- otherwise the next reorder click would raise an error.
--
-- No schema change. Flat, idempotent, self-verifying. Proven on PG16.
-- Verify block asserts only THIS migration's effects, never a global total.

UPDATE public.pathway_section_order o
   SET order_map  = '{}'::jsonb,
       updated_at = now()
 WHERE EXISTS (
   SELECT 1 FROM jsonb_object_keys(o.order_map) AS k WHERE k LIKE '%|%'
 );

-- STAMP THIS MIGRATION
INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('097','097_pathway_order_flat_reset.sql','Ordering arc 1/3: cleared legacy level|category order_map entries (1 row, Rosehill 0|book) ahead of the flat level re-key. Conversion rejected: it would hoist books above the rest of L0.')
ON CONFLICT (version) DO UPDATE SET filename=excluded.filename, note=excluded.note, applied_at=now();

-- SELF-VERIFY -- expect all_ok = PASS. Asserts only this migration's effects.
SELECT
  (SELECT count(*) FROM public.pathway_section_order o
     WHERE EXISTS (SELECT 1 FROM jsonb_object_keys(o.order_map) AS k WHERE k LIKE '%|%')) AS legacy_keys_left,
  (SELECT count(*) FROM public.pathway_section_order) AS order_rows,
  (SELECT count(*) FROM public.schema_migrations WHERE version = '097') AS self_stamped,
  CASE WHEN (SELECT count(*) FROM public.pathway_section_order o
               WHERE EXISTS (SELECT 1 FROM jsonb_object_keys(o.order_map) AS k WHERE k LIKE '%|%')) = 0
        AND (SELECT count(*) FROM public.schema_migrations WHERE version = '097') = 1
       THEN 'PASS' ELSE 'FAIL' END AS all_ok;
