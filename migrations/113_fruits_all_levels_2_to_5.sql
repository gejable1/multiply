-- migrations/113_fruits_all_levels_2_to_5.sql
-- S87 -- the Pastor's ruling: all nine fruits of the Spirit (Gal 5:22-23)
-- become available as predefined choices at Levels 2-5.
--
-- CONTEXT. The original catalog (060) staggered the fruits as a deliberate
-- per-level emphasis (L2 carried love/joy/patience/kindness, L3
-- love/faithfulness/goodness/self-control, and so on). This migration does
-- not delete that emphasis -- it completes the SET: the missing fruits are
-- added to the TEMPLATE lane only, at L2-L5, so every church's library
-- picker offers all nine at those levels. Nothing is pushed into any church
-- lane; a pastor still chooses which fruits his level emphasizes. L0 and L1
-- keep their original design untouched.
--
-- MECHANISM. Each missing fruit is copied VERBATIM from its own live sibling
-- row (same rung_key at the lowest level that carries it) -- title_en,
-- title_tl, descriptions, category, completion_source, auto_source_key,
-- trackable, published, meta all travel as the writer wrote them (#438).
-- Reference shape: character / manual / trackable=false -- fruit is observed
-- and affirmed, never a checkbox to grade. sort_order appends after each
-- level's current max (the picker sorts alphabetically anyway; template
-- order never renders on a church wall post-fork).
--
-- No docs move: the template lane has no pathway_versions doc, and no church
-- lane row is created or edited, so #437 is satisfied by having nothing to
-- keep in step. New rows carry created_at = now(), so the future opt-in badge
-- will count them as new-since-sync for every church.
--
-- Flat (#209), idempotent (where-not-exists), self-verifying on its own
-- effects (#403), ledger stamped (#402). Proved on ephemeral PG16 seeded with
-- the real 060 distribution, scope proven against a populated church lane,
-- and the verify proven able to FAIL on the pre-state (#413).

drop table if exists _fruits;
create temp table _fruits(rung_key text);
insert into _fruits(rung_key) values
  ('ref-character-love'), ('ref-character-joy'), ('ref-character-peace'),
  ('ref-character-patience'), ('ref-character-kindness'), ('ref-character-goodness'),
  ('ref-character-faithfulness'), ('ref-character-gentleness'), ('ref-character-self-control');

drop table if exists _targets113;
create temp table _targets113(level int);
insert into _targets113(level) values (2), (3), (4), (5);

-- Source row per fruit: the template's own copy at the lowest level carrying it.
drop table if exists _src;
create temp table _src as
select distinct on (r.rung_key) r.*
  from public.pathway_rungs r
  join _fruits f on f.rung_key = r.rung_key
 where r.church_id is null
 order by r.rung_key, r.level;

insert into public.pathway_rungs
  (church_id, level, sort_order, rung_key, title_en, title_tl,
   description_en, description_tl, category, completion_source,
   auto_source_key, trackable, published, meta)
select null,
       t.level,
       coalesce((select max(x.sort_order) from public.pathway_rungs x
                  where x.church_id is null and x.level = t.level), 0)
         + row_number() over (partition by t.level order by s.rung_key),
       s.rung_key, s.title_en, s.title_tl,
       s.description_en, s.description_tl, s.category, s.completion_source,
       s.auto_source_key, s.trackable, s.published, s.meta
  from _src s
 cross join _targets113 t
 where not exists (select 1 from public.pathway_rungs r
                    where r.church_id is null
                      and r.level = t.level
                      and r.rung_key = s.rung_key);

-- ---- ledger stamp (#402/#212)
insert into public.schema_migrations (version, filename, note) values
  ('113','113_fruits_all_levels_2_to_5.sql','All nine fruits of the Spirit (Gal 5:22-23) made available as library-picker choices at L2-L5: missing fruits copied verbatim from their own template sibling rows into the TEMPLATE lane only (character/manual/non-trackable reference shape preserved). No church lane touched; L0-L1 original staggered design untouched; pastors opt in per fruit via the picker.')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

-- ---- SELF-VERIFY -- asserts only THIS migration's own effects (#403), rerun-safe.
-- Expect: fruits_missing_l2_l5 0, fruits_present_l2_l5 36, sources_found 9,
-- all_ok PASS.
select
  (select count(*) from _fruits f cross join _targets113 t
    where not exists (select 1 from public.pathway_rungs r
                       where r.church_id is null and r.level = t.level
                         and r.rung_key = f.rung_key))                        as fruits_missing_l2_l5,
  (select count(*) from public.pathway_rungs r
     join _fruits f on f.rung_key = r.rung_key
    where r.church_id is null and r.level between 2 and 5)                    as fruits_present_l2_l5,
  (select count(*) from _src)                                                 as sources_found,
  case when
       (select count(*) from _fruits f cross join _targets113 t
         where not exists (select 1 from public.pathway_rungs r
                            where r.church_id is null and r.level = t.level
                              and r.rung_key = f.rung_key)) = 0
   and (select count(*) from public.pathway_rungs r
          join _fruits f on f.rung_key = r.rung_key
         where r.church_id is null and r.level between 2 and 5) = 36
   and (select count(*) from _src) = 9
  then 'PASS' else 'FAIL' end                                                 as all_ok;
