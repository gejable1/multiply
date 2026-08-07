-- migrations/109_template_dedupe_and_egr_progression.sql
-- S86 -- remove ten shadow/duplicate coaching notes and name the EGR progression.
--
-- SCOPE: the shared template lane PLUS the ten church lanes that have never been
-- edited. Rosehill and True North are deliberately EXCLUDED -- Rosehill carries
-- six versions of the platform owner own decisions and True North has diverged
-- (206 rungs against the others 204). Their pastor edits them in the editor.
--
-- WHY THE DOC IS EDITED TOO, and this is the whole reason this migration is not
-- three DELETE statements. pathway_versions.doc IS the church pipeline;
-- publish_pathway_version() regenerates pathway_rungs FROM it. Deleting rows
-- while leaving the doc describing them means the first pastor to press Publish
-- RESURRECTS every duplicate. Rows and doc must move together or not at all.
-- Migration 108 was immune to this because opt-in additions travel through the
-- doc already; deletions do not.
--
-- WHAT GOES, and why each is safe. All ten are trackable = false, so no member
-- has ever ticked one and no progress can be lost -- asserted by a gate below
-- that HALTS if any pathway_progress row exists for these keys.
--   shadows -- a coaching note naming the completion of something already
--   tickable on the same screen: ref-character-baptism beside `baptism`,
--   ref-character-assurance-of-salvation beside `salvation`,
--   ref-character-completed-new-believers-orientation beside
--   `train-new-believers`, ref-character-completed-btli-101 beside `btli-101`.
--   devotional pile-up -- one habit described in four columns at L0 and again
--   at L1/L2. `lifedev-devotional` (the church devotional guide) SURVIVES at
--   every level, by the platform owner ruling; habit-daily-devotional,
--   train-bible-reading and ref-character-daily-devotional-habit go.
--
-- WHAT STAYS, and this is the trap any naive dedupe would fall into: the fruit
-- of the Spirit. Love, Joy, Peace, Faithfulness, Goodness, Gentleness,
-- Self-control, Kindness and Patience repeat at nearly every level ON PURPOSE
-- (Gal 5:22-23) -- the same fruit examined again at each stage of maturity.
-- A duplicate-title sweep would strip the theological spine out of the pipeline.
-- Nothing here touches them; a post-condition proves it.
--
-- EGR IS NOT DUPLICATION. train-egr at L0/L1/L2 looked like the same rung filed
-- three times under three names. It is a progression: attend, then facilitate,
-- then teach. Only the labels were lazy. Retitled, not merged.
--
-- Flat (#209), idempotent, self-verifying (#403), ledger stamped (#402).
-- Proven on PG16 before shipping.

-- ---------------------------------------------------------------- THE SETS
drop table if exists _doomed;
create temp table _doomed(level int, rung_key text);
insert into _doomed(level, rung_key) values
    (0, 'ref-character-baptism'),
    (0, 'ref-character-assurance-of-salvation'),
    (0, 'ref-character-completed-new-believers-orientation'),
    (0, 'ref-character-daily-devotional-habit'),
    (0, 'habit-daily-devotional'),
    (0, 'train-bible-reading'),
    (1, 'ref-character-completed-btli-101'),
    (1, 'habit-daily-devotional'),
    (1, 'train-bible-reading'),
    (2, 'habit-daily-devotional')
;

drop table if exists _retitle;
create temp table _retitle(level int, rung_key text, title_en text);
insert into _retitle(level, rung_key, title_en) values
    (0, 'train-egr', E'EGR \u2014 Experiencing God Retreat (Attendee)'),
    (1, 'train-egr', E'EGR \u2014 Facilitator / Guide'),
    (2, 'train-egr', E'EGR \u2014 Lecturer / Speaker')
;

-- The ten untouched lanes. Named explicitly and then GATED: if a rename or a new
-- tenant makes this anything other than ten, the migration stops rather than
-- silently editing a church nobody agreed to.
drop table if exists _targets;
create temp table _targets(id uuid, name text);
insert into _targets(id, name)
select id, name from public.churches
where name not in ('Rosehill Christian Church', 'True North');

-- ------------------------------------------------------------- THE GATES
-- Proved by deliberate failure on PG16: each of these was made to fire.
do $gate$
declare v_n int; v_prog int; v_tr int;
begin
  select count(*) into v_n from _targets;
  if v_n <> 10 then
    raise exception 'HALT: expected exactly 10 target churches, found %. Refusing to edit an unreviewed set.', v_n;
  end if;

  -- No member may lose a completion -- but scoped to the lanes THIS migration
  -- actually edits. pathway_progress is church-scoped, and the template lane
  -- cannot carry progress at all (progress belongs to members, members belong to
  -- churches). The first version of this check counted progress GLOBALLY, so
  -- nine hand-marked coaching notes in ROSEHILL -- a church deliberately
  -- excluded from the target set -- blocked the cleanup of ten other churches.
  -- The gate was right to stop; it was simply asking about the wrong lanes.
  select count(*) into v_prog
    from public.pathway_progress p
    join _doomed  d on d.level = p.level and d.rung_key = p.rung_key
    join _targets tg on tg.id = p.church_id;
  if v_prog > 0 then
    raise exception 'HALT: % pathway_progress rows exist in TARGET churches for rungs marked for deletion. Nothing deleted.', v_prog;
  end if;

  -- Scoped to the edited lanes, for the same reason as the progress gate above.
  -- A pastor may make a rung trackable IN HIS OWN LANE -- Rosehill did exactly
  -- that to ref-character-baptism -- and an excluded church's local decision
  -- must not veto a cleanup of ten other churches.
  select count(*) into v_tr
    from public.pathway_rungs r
    join _doomed d on d.level = r.level and d.rung_key = r.rung_key
   where r.trackable
     and (r.church_id is null or r.church_id in (select id from _targets));
  if v_tr > 0 then
    raise exception 'HALT: % rungs marked for deletion are TRACKABLE in the template or a TARGET church. Nothing deleted.', v_tr;
  end if;
end
$gate$;

-- --------------------------------------------------------- 1. THE ROWS
-- The safety conditions live INSIDE this statement, not in a preceding gate.
-- A DO block that RAISEs is a SEPARATE statement: if the script is ever run
-- somewhere an aborted statement does not abort the script, the gate screams and
-- the delete proceeds anyway. Proved on PG16 -- psql without ON_ERROR_STOP did
-- exactly that. Inlined, the delete is incapable of touching a trackable rung, a
-- rung any member has completed, or anything at all unless the target set is
-- exactly the ten reviewed churches.
delete from public.pathway_rungs r
using _doomed d
where d.level = r.level and d.rung_key = r.rung_key
  and (r.church_id is null or r.church_id in (select id from _targets))
  and r.trackable = false
  and not exists (select 1 from public.pathway_progress p
                   where p.level = r.level and p.rung_key = r.rung_key
                     and p.church_id is not distinct from r.church_id)
  and (select count(*) from _targets) = 10;

update public.pathway_rungs r
   set title_en = t.title_en, title_tl = t.title_en, updated_at = now()
  from _retitle t
 where t.level = r.level and t.rung_key = r.rung_key
   and (r.church_id is null or r.church_id in (select id from _targets))
   and r.title_en is distinct from t.title_en
   and (select count(*) from _targets) = 10;

-- ------------------------------------------- 2. THE DOCS (rows and doc move together)
-- Pass A: drop the doomed rung_keys out of every level array of every target doc.
with newdocs as (
  select v.id,
         jsonb_set(v.doc, '{levels}', coalesce((
           select jsonb_object_agg(lk, q.arr)
             from jsonb_object_keys(v.doc->'levels') lk
             cross join lateral (
               select coalesce(jsonb_agg(e order by ord), '[]'::jsonb) as arr
                 from jsonb_array_elements(v.doc->'levels'->lk) with ordinality x(e, ord)
                where not exists (select 1 from _doomed d
                                   where d.level = lk::int
                                     and d.rung_key = e->>'rung_key')
             ) q
         ), '{}'::jsonb)) as newdoc
    from public.pathway_versions v
   where v.church_id in (select id from _targets)
     and v.doc ? 'levels'
     and (select count(*) from _targets) = 10
)
update public.pathway_versions v
   set doc = n.newdoc, updated_at = now()
  from newdocs n
 where n.id = v.id;

-- Pass B: apply the EGR titles inside every target doc.
with newdocs as (
  select v.id,
         jsonb_set(v.doc, '{levels}', coalesce((
           select jsonb_object_agg(lk, q.arr)
             from jsonb_object_keys(v.doc->'levels') lk
             cross join lateral (
               select coalesce(jsonb_agg(
                        case when t.title_en is null then e
                             else jsonb_set(jsonb_set(e, '{title_en}', to_jsonb(t.title_en)),
                                            '{title_tl}', to_jsonb(t.title_en))
                        end order by ord), '[]'::jsonb) as arr
                 from jsonb_array_elements(v.doc->'levels'->lk) with ordinality x(e, ord)
                 left join _retitle t
                   on t.level = lk::int and t.rung_key = e->>'rung_key'
             ) q
         ), '{}'::jsonb)) as newdoc
    from public.pathway_versions v
   where v.church_id in (select id from _targets)
     and v.doc ? 'levels'
     and (select count(*) from _targets) = 10
)
update public.pathway_versions v
   set doc = n.newdoc, updated_at = now()
  from newdocs n
 where n.id = v.id;

-- ---- ledger stamp (#402/#212)
insert into public.schema_migrations (version, filename, note) values
  ('109','109_template_dedupe_and_egr_progression.sql','Remove 10 non-trackable shadow/duplicate coaching notes and retitle the EGR progression (attend/facilitate/teach), in the template lane and the 10 unedited church lanes; pathway_versions.doc updated in step so a later Publish cannot resurrect them. Rosehill and True North excluded. Fruit of the Spirit untouched.')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

-- ---- SELF-VERIFY -- asserts only THIS migration own effects (#403).
-- Expect: doomed_rows_left 0, doomed_in_docs 0, egr_rows_wrong 0,
-- egr_in_docs_wrong 0, fruit_rows_kept > 0, progress_lost 0, all_ok PASS.
select
  (select count(*) from public.pathway_rungs r join _doomed d
     on d.level=r.level and d.rung_key=r.rung_key
    where r.church_id is null or r.church_id in (select id from _targets))   as doomed_rows_left,
  (select count(*) from public.pathway_versions v
     cross join lateral jsonb_object_keys(v.doc->'levels') lk
     cross join lateral jsonb_array_elements(v.doc->'levels'->lk) e
     join _doomed d on d.level = lk::int and d.rung_key = e->>'rung_key'
    where v.church_id in (select id from _targets))                          as doomed_in_docs,
  (select count(*) from public.pathway_rungs r join _retitle t
     on t.level=r.level and t.rung_key=r.rung_key
    where (r.church_id is null or r.church_id in (select id from _targets))
      and r.title_en is distinct from t.title_en)                            as egr_rows_wrong,
  (select count(*) from public.pathway_versions v
     cross join lateral jsonb_object_keys(v.doc->'levels') lk
     cross join lateral jsonb_array_elements(v.doc->'levels'->lk) e
     join _retitle t on t.level = lk::int and t.rung_key = e->>'rung_key'
    where v.church_id in (select id from _targets)
      and e->>'title_en' is distinct from t.title_en)                        as egr_in_docs_wrong,
  (select count(*) from public.pathway_rungs
    where rung_key in ('ref-character-love','ref-character-joy','ref-character-peace',
                       'ref-character-faithfulness','ref-character-goodness',
                       'ref-character-gentleness','ref-character-self-control',
                       'ref-character-kindness','ref-character-patience'))    as fruit_rows_kept,
  (select count(*) from public.pathway_progress p
     join _doomed d on d.level=p.level and d.rung_key=p.rung_key
     join _targets tg on tg.id = p.church_id)                                as progress_lost,
  case when
       (select count(*) from public.pathway_rungs r join _doomed d on d.level=r.level and d.rung_key=r.rung_key
         where r.church_id is null or r.church_id in (select id from _targets)) = 0
   and (select count(*) from public.pathway_versions v
          cross join lateral jsonb_object_keys(v.doc->'levels') lk
          cross join lateral jsonb_array_elements(v.doc->'levels'->lk) e
          join _doomed d on d.level = lk::int and d.rung_key = e->>'rung_key'
         where v.church_id in (select id from _targets)) = 0
   and (select count(*) from public.pathway_rungs r join _retitle t on t.level=r.level and t.rung_key=r.rung_key
         where (r.church_id is null or r.church_id in (select id from _targets))
           and r.title_en is distinct from t.title_en) = 0
   and (select count(*) from public.pathway_progress p
          join _doomed d on d.level=p.level and d.rung_key=p.rung_key
          join _targets tg on tg.id = p.church_id) = 0
   and (select count(*) from public.pathway_rungs where rung_key like 'ref-character-love') > 0
  then 'PASS' else 'FAIL' end                                                as all_ok;
