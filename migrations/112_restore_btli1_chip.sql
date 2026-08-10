-- migrations/112_restore_btli1_chip.sql
-- S87 -- restore the BTLI 101 course chip that migration 110's chip move
-- failed to deliver.
--
-- WHAT WENT WRONG IN 110, honestly. The chip move guarded on
-- spine.meta = '{}'::jsonb, but btli1 has carried {"celebrate_publicly": true}
-- since migration 076 -- in EVERY lane. The guard no-op'd everywhere, the
-- delete then removed btli-101 (the chip's only home) from the template and
-- the ten target lanes, rows and docs, and 110's own self-verify passed
-- because it, too, measured EMPTINESS as a proxy for chip-presence. Two
-- lessons, both invariant-grade: a fixture that omits production's meta flags
-- proves the wrong thing (#428 -- fingerprint the lanes, #441), and a gate
-- must test the presence of the intended content, never a proxy (#427).
-- Caught live by the Pastor 2026-08-08 running the lane diagnostic.
--
-- THE CURE. The canonical chip text below is lifted VERBATIM from migration
-- 060 (the writer's own signature, #438); 110's renumber chain never touched
-- it (it references only 'BTLI 101', which did not renumber). It is MERGED
-- (meta || chip) into btli1 in the TEMPLATE and ALL TWELVE church lanes --
-- Rosehill and True North included this time, which supersedes the hand
-- "Step 0" the Pastor was given -- guarded on NOT (meta ? 'title'), so:
--   * celebrate_publicly and any other existing keys survive the merge;
--   * a pastor-authored chip (title present) is never clobbered;
--   * rerun-safe: once the chip is present the row no longer matches.
-- Docs move with rows (#437): every pathway_versions doc whose btli1 item
-- lacks a chip title gets the same merge into that item's meta.
--
-- Proved on ephemeral PG16 with btli1 seeded EXACTLY as production holds it
-- ({"celebrate_publicly": true}), plus a custom-chip lane that must survive
-- untouched, and by deliberate failure (#413).

create temp table _chip(j jsonb);
insert into _chip(j) values ($chip${"type": "🎓 BTLI Module · Level 1 — Team Member", "title": "BTLI 101: Foundations of Discipleship", "body": "<h3>Course Overview</h3>\n    <p>BTLI 101 is the entry-level module of the Bible Training and Leadership Institute. It provides every new church member with the theological and relational foundations for genuine Christian discipleship — the starting point of the entire MULTIPLY pipeline.</p>\n    <h3>Learning Objectives</h3>\n    <ul>\n      <li>Articulate a clear and confident testimony of personal salvation</li>\n      <li>Understand the basics of assurance of salvation (1 John 5:13)</li>\n      <li>Establish daily Bible reading and journaling as a lifestyle</li>\n      <li>Understand the purpose and meaning of baptism and communion</li>\n      <li>Begin consistent attendance and participation in a Life Community</li>\n      <li>Make the first EOLO (Each One Love One) invitation</li>\n    </ul>\n    <h3>Topics Covered</h3>\n    <ul>\n      <li>Session 1: The Gospel — What You Believed and Why It Matters</li>\n      <li>Session 2: Assurance of Salvation — Knowing You Know</li>\n      <li>Session 3: The Bible — How to Read It Every Day</li>\n      <li>Session 4: Prayer — Talking with God Like He's There</li>\n      <li>Session 5: The Church — Why You Can't Follow Jesus Alone</li>\n      <li>Session 6: Baptism and Communion — The Ordinances Explained</li>\n      <li>Session 7: The Holy Spirit — Your Helper from Day One</li>\n      <li>Session 8: EOLO — Your First Assignment as a Disciple</li>\n    </ul>\n    <h3>Format</h3>\n    <p>8 sessions of 90 minutes each. Can be done in small group (4–8 persons) with a trained facilitator, or as a 1-on-1 with a discipler. Written assignments and Scripture memory required for completion.</p>", "footer": "BTLI · Bible Training and Leadership Institute · Your Church", "source": "multiply-template"}$chip$::jsonb);

-- ---- rows: template + every church lane
update public.pathway_rungs r
   set meta = r.meta || (select j from _chip), updated_at = now()
 where r.level = 1 and r.rung_key = 'btli1'
   and not (r.meta ? 'title');

-- ---- docs: every published/draft doc whose btli1 item lacks a chip title
with newdocs as (
  select v.id,
         jsonb_set(v.doc, '{levels}', coalesce((
           select jsonb_object_agg(lk, q.arr)
             from jsonb_object_keys(v.doc->'levels') lk
             cross join lateral (
               select coalesce(jsonb_agg(
                        case when lk = '1' and e->>'rung_key' = 'btli1'
                                  and not (coalesce(e->'meta','{}'::jsonb) ? 'title')
                             then jsonb_set(e, '{meta}',
                                    coalesce(e->'meta','{}'::jsonb) || (select j from _chip))
                             else e
                        end order by ord), '[]'::jsonb) as arr
                 from jsonb_array_elements(v.doc->'levels'->lk) with ordinality x(e, ord)
             ) q
         ), '{}'::jsonb)) as newdoc
    from public.pathway_versions v
   where v.doc ? 'levels'
)
update public.pathway_versions v
   set doc = n.newdoc, updated_at = now()
  from newdocs n
 where n.id = v.id and v.doc is distinct from n.newdoc;

-- ---- ledger stamp (#402/#212)
insert into public.schema_migrations (version, filename, note) values
  ('112','112_restore_btli1_chip.sql','Restore the BTLI 101 course chip onto btli1 in the template and all twelve church lanes, rows and docs, after 110''s chip move no-op''d on an emptiness guard (btli1 has carried celebrate_publicly since 076, so meta was never {}). Chip lifted verbatim from 060; jsonb-merged so celebrate_publicly and any pastor-authored keys survive; guarded on NOT (meta ? ''title''); supersedes the Pastor''s hand Step 0 for Rosehill/True North.')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

-- ---- SELF-VERIFY -- this time the gate tests the CONTENT, not a proxy (#427).
-- Expect: rows_missing_chip 0, rows_with_chip_and_celebrate >= 13,
-- docs_items_missing_chip 0, all_ok PASS.
select
  (select count(*) from public.pathway_rungs r
    where r.level = 1 and r.rung_key = 'btli1'
      and not (r.meta ? 'title'))                                            as rows_missing_chip,
  (select count(*) from public.pathway_rungs r
    where r.level = 1 and r.rung_key = 'btli1'
      and r.meta ? 'title' and r.meta ? 'celebrate_publicly')                as rows_with_chip_and_celebrate,
  (select count(*) from public.pathway_versions v
     cross join lateral jsonb_array_elements(v.doc->'levels'->'1') e
    where v.doc ? 'levels' and e->>'rung_key' = 'btli1'
      and not (coalesce(e->'meta','{}'::jsonb) ? 'title'))                   as docs_items_missing_chip,
  case when
       (select count(*) from public.pathway_rungs r
         where r.level = 1 and r.rung_key = 'btli1'
           and not (r.meta ? 'title')) = 0
   and (select count(*) from public.pathway_rungs r
         where r.level = 1 and r.rung_key = 'btli1' and r.meta ? 'title') >= 13
   and (select count(*) from public.pathway_versions v
          cross join lateral jsonb_array_elements(v.doc->'levels'->'1') e
         where v.doc ? 'levels' and e->>'rung_key' = 'btli1'
           and not (coalesce(e->'meta','{}'::jsonb) ? 'title')) = 0
  then 'PASS' else 'FAIL' end                                                as all_ok;
