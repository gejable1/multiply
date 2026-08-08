-- migrations/110_btli_renumber_books_to_lessons.sql
-- S87 -- the Mac Lake books (and Usad/Unlad) become lessons, not books to read,
-- and the BTLI track is renumbered to say so.
--
-- THE PASTOR'S RULING. The five Mac Lake books -- Leading Yourself, Leading
-- Others, Leading Leaders, Leading a Department, Leading an Organization --
-- are being turned into BTLI lesson content, not standalone reading
-- assignments. Usad and Unlad are already inside BTLI 101. So the standalone
-- "Read <book>" rungs go, and the BTLI modules are renumbered by level:
--   L0  Complete Usbong (10 lessons)   -> Usbong (10 Lessons)
--   L1  Complete BTLI 1 (20 lessons)   -> BTLI 101 (Usad, Unlad, Leading Yourself)
--   L2  BTLI 102 & 103                 -> BTLI 201 (Leading Others)
--   L3  BTLI 104                       -> BTLI 301 (Leading Leaders)
--   L4  BTLI 105                       -> BTLI 401 (Leading a Department)
--   L5  BTLI 106                       -> BTLI 501 (Leading an Organization)
--
-- RUNG KEYS DO NOT MOVE. pathway_progress is keyed on (level, rung_key) text,
-- so `btli-102-103` keeps its key while its title says BTLI 201. A key rename
-- would orphan completions; a title rename cannot.
--
-- WHAT GOES (eight rungs per lane), and why each is safe HERE:
--   btli-101          (L1) -- duplicate of the renamed btli1 spine rung
--   leading-yourself  (L1) -- now inside BTLI 101
--   book-usad         (L1) -- now inside BTLI 101
--   book-unlad        (L2) -- now inside BTLI 101
--   leading-others    (L2) -- now BTLI 201
--   leading-leaders   (L3) -- now BTLI 301
--   leading-dept      (L4) -- now BTLI 401
--   leading-org       (L5) -- now BTLI 501
-- Unlike 109, some of these are TRACKABLE (they were tickable book rungs), so
-- the safety condition is not trackable=false -- it is ZERO pathway_progress on
-- these keys in the edited lanes, enforced twice: a gate that halts the script,
-- and the same predicate INLINED in the DELETE itself (#433), per-row AND
-- whole-set, so a runner without ON_ERROR_STOP still deletes nothing.
--
-- THE CHIP MOVE. The btli1 spine rung has NO meta chip; the rich "BTLI 101"
-- course chip lives on the doomed btli-101 reference rung. Before deleting,
-- each lane's btli1 inherits btli-101's chip -- only where btli1's meta is
-- empty, so no pastor-authored chip can ever be clobbered. The five book chips
-- are NOT moved onto the BTLI modules: those modules already carry their own
-- course chips, and the full content rewrite waits on the Pastor's lesson
-- outlines. (Book chip bodies remain recoverable from git history / template
-- seed 060.)
--
-- THE MINIMAL RENUMBER PASS. Chip bodies and two assessments cross-reference
-- the old numbers ("Completion of BTLI 103", "Requires completion of BTLI
-- 101-105", "Have BTLI 101 and 102 been completed?"). A case-sensitive ordered
-- replacement chain renumbers them; "BTLI 101" itself is never touched -- it
-- remains the L1 course. Known cosmetic remainder, accepted: inside the old
-- 102&103 chip, both session blocks now read "BTLI 201:"; the real content
-- rewrite is a later arc.
--
-- SCOPE: the template lane PLUS the ten never-edited church lanes -- the 109
-- pattern verbatim. Rosehill and True North are EXCLUDED; the Pastor applies
-- this by hand in the editor (delete the 8, rename the 6; the BTLI 101 chip is
-- recoverable from the library picker, template union own).
--
-- ROWS AND DOC MOVE TOGETHER (#437): every edit above is mirrored into the ten
-- target churches' pathway_versions.doc in the same transaction-less flat run,
-- so a later Publish cannot resurrect a deleted book rung or an old number.
-- The template lane has no doc (pathway_versions.church_id is NOT NULL).
--
-- Flat (#209), idempotent, self-verifying on its own effects (#403), ledger
-- stamped (#402). Proved on PG16 and by deliberate failure (#413) before
-- shipping. Pure ASCII: the en dash ships as E'\u2013'.

-- ---------------------------------------------------------------- THE SETS
drop table if exists _doomed;
create temp table _doomed(level int, rung_key text);
insert into _doomed(level, rung_key) values
    (1, 'btli-101'),
    (1, 'leading-yourself'),
    (1, 'book-usad'),
    (2, 'book-unlad'),
    (2, 'leading-others'),
    (3, 'leading-leaders'),
    (4, 'leading-dept'),
    (5, 'leading-org')
;

drop table if exists _retitle;
create temp table _retitle(level int, rung_key text, title_en text, title_tl text);
insert into _retitle(level, rung_key, title_en, title_tl) values
    (0, 'usbong',        'Usbong (10 Lessons)',                       'Usbong (10 aralin)'),
    (1, 'btli1',         'BTLI 101 (Usad, Unlad, Leading Yourself)',  'BTLI 101 (Usad, Unlad, Leading Yourself)'),
    (2, 'btli-102-103',  'BTLI 201 (Leading Others)',                 'BTLI 201 (Leading Others)'),
    (3, 'btli-104',      'BTLI 301 (Leading Leaders)',                'BTLI 301 (Leading Leaders)'),
    (4, 'btli-105',      'BTLI 401 (Leading a Department)',           'BTLI 401 (Leading a Department)'),
    (5, 'btli-106',      'BTLI 501 (Leading an Organization)',        'BTLI 501 (Leading an Organization)')
;

-- The ten untouched lanes -- named by the same predicate 109 proved, then GATED.
drop table if exists _targets;
create temp table _targets(id uuid, name text);
insert into _targets(id, name)
select id, name from public.churches
where name not in ('Rosehill Christian Church', 'True North');

-- The renumber chain, ORDERED: longer strings first so a shorter pair can never
-- pre-empt a longer one. Case-sensitive throughout; rung_keys are lowercase and
-- can never collide with 'BTLI 1..'.
create or replace function pg_temp._btli_renumber(t text) returns text
language sql immutable as $fn$
  select replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
           t,
           E'BTLI 101\u2013105',  E'BTLI 101\u2013401'),
           'BTLI 101 and 102',    'BTLI 101 and 201'),
           'BTLI 102 and 103',    'BTLI 201'),
           'BTLI 102 &amp; 103',  'BTLI 201'),
           'BTLI 102 & 103',      'BTLI 201'),
           'BTLI 102',            'BTLI 201'),
           'BTLI 103',            'BTLI 201'),
           'BTLI 104',            'BTLI 301'),
           'BTLI 105',            'BTLI 401'),
           'BTLI 106',            'BTLI 501')
$fn$;

-- ------------------------------------------------------------- THE GATES
-- Proved by deliberate failure on PG16: each of these was made to fire.
do $gate$
declare v_n int; v_prog int;
begin
  select count(*) into v_n from _targets;
  if v_n <> 10 then
    raise exception 'HALT: expected exactly 10 target churches, found %. Refusing to edit an unreviewed set.', v_n;
  end if;

  -- No member may lose a completion -- scoped to the lanes THIS migration
  -- edits (#432). The template lane cannot carry progress; Rosehill and True
  -- North are excluded, so their marks (Rosehill certainly has some on these
  -- books) must not veto the ten target churches.
  select count(*) into v_prog
    from public.pathway_progress p
    join _doomed  d  on d.level = p.level and d.rung_key = p.rung_key
    join _targets tg on tg.id   = p.church_id;
  if v_prog > 0 then
    raise exception 'HALT: % pathway_progress rows exist in TARGET churches for rungs marked for deletion. Nothing deleted. Bring the list to the Pastor.', v_prog;
  end if;
end
$gate$;

-- ------------------------------------------- 1. THE CHIP MOVE (rows, before the delete)
update public.pathway_rungs spine
   set meta = src.meta, updated_at = now()
  from public.pathway_rungs src
 where spine.level = 1 and spine.rung_key = 'btli1'
   and src.level   = 1 and src.rung_key   = 'btli-101'
   and src.church_id is not distinct from spine.church_id
   and (spine.church_id is null or spine.church_id in (select id from _targets))
   and spine.meta = '{}'::jsonb
   and src.meta  <> '{}'::jsonb
   and (select count(*) from _targets) = 10;

-- --------------------------------------------------------- 2. THE ROWS
-- Safety INLINED (#433): scope, per-row no-progress, WHOLE-SET no-progress,
-- and the reviewed target count -- a runner that ignored the gate above still
-- cannot delete a completed rung, nor anything at all if ANY doomed rung in a
-- target lane carries progress.
delete from public.pathway_rungs r
using _doomed d
where d.level = r.level and d.rung_key = r.rung_key
  and (r.church_id is null or r.church_id in (select id from _targets))
  and not exists (select 1 from public.pathway_progress p
                   where p.level = r.level and p.rung_key = r.rung_key
                     and p.church_id is not distinct from r.church_id)
  and not exists (select 1 from public.pathway_progress p2
                   join _doomed  d2 on d2.level = p2.level and d2.rung_key = p2.rung_key
                   join _targets t2 on t2.id    = p2.church_id)
  and (select count(*) from _targets) = 10;

update public.pathway_rungs r
   set title_en = t.title_en, title_tl = t.title_tl, updated_at = now()
  from _retitle t
 where t.level = r.level and t.rung_key = r.rung_key
   and (r.church_id is null or r.church_id in (select id from _targets))
   and (r.title_en is distinct from t.title_en or r.title_tl is distinct from t.title_tl)
   and (select count(*) from _targets) = 10;

update public.pathway_rungs r
   set meta = pg_temp._btli_renumber(r.meta::text)::jsonb, updated_at = now()
 where (r.church_id is null or r.church_id in (select id from _targets))
   and r.meta::text ~ E'BTLI 10[2-6]|BTLI 101\u2013105|BTLI 101 and 102'
   and (select count(*) from _targets) = 10;

-- ------------------------------------------- 3. THE DOCS (rows and doc move together)
-- Pass A: btli1 inherits btli-101's chip inside each target doc, where empty.
with newdocs as (
  select v.id,
         jsonb_set(v.doc, '{levels}', coalesce((
           select jsonb_object_agg(lk, q.arr)
             from jsonb_object_keys(v.doc->'levels') lk
             cross join lateral (
               select coalesce(jsonb_agg(
                        case when lk = '1' and e->>'rung_key' = 'btli1'
                                  and coalesce(e->'meta','{}'::jsonb) = '{}'::jsonb
                                  and chip.meta is not null
                             then jsonb_set(e, '{meta}', chip.meta)
                             else e
                        end order by ord), '[]'::jsonb) as arr
                 from jsonb_array_elements(v.doc->'levels'->lk) with ordinality x(e, ord)
                 left join lateral (
                   select e2->'meta' as meta
                     from jsonb_array_elements(v.doc->'levels'->'1') e2
                    where e2->>'rung_key' = 'btli-101'
                      and coalesce(e2->'meta','{}'::jsonb) <> '{}'::jsonb
                    limit 1
                 ) chip on true
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
 where n.id = v.id and v.doc is distinct from n.newdoc;

-- Pass B: drop the doomed rung_keys out of every level array of every target doc.
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
     -- Destructive-in-effect (a later Publish RETIRES what the doc omits), so it
     -- carries the same whole-set veto as the row DELETE (#433): if ANY doomed
     -- rung in a target lane holds progress, no doc loses an item either.
     and not exists (select 1 from public.pathway_progress p2
                      join _doomed  d2 on d2.level = p2.level and d2.rung_key = p2.rung_key
                      join _targets t2 on t2.id    = p2.church_id)
)
update public.pathway_versions v
   set doc = n.newdoc, updated_at = now()
  from newdocs n
 where n.id = v.id and v.doc is distinct from n.newdoc;

-- Pass C: apply the six new titles inside every target doc.
with newdocs as (
  select v.id,
         jsonb_set(v.doc, '{levels}', coalesce((
           select jsonb_object_agg(lk, q.arr)
             from jsonb_object_keys(v.doc->'levels') lk
             cross join lateral (
               select coalesce(jsonb_agg(
                        case when t.title_en is null then e
                             else jsonb_set(jsonb_set(e, '{title_en}', to_jsonb(t.title_en)),
                                            '{title_tl}', to_jsonb(t.title_tl))
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
 where n.id = v.id and v.doc is distinct from n.newdoc;

-- Pass D: renumber the old BTLI numbers everywhere else in the target docs
-- (chip titles and bodies). Runs AFTER Pass C: the new titles contain no
-- 'BTLI 10[2-6]' substring, so the chain cannot touch them.
update public.pathway_versions v
   set doc = pg_temp._btli_renumber(v.doc::text)::jsonb, updated_at = now()
 where v.church_id in (select id from _targets)
   and v.doc::text ~ E'BTLI 10[2-6]|BTLI 101\u2013105|BTLI 101 and 102'
   and (select count(*) from _targets) = 10;

-- ---- ledger stamp (#402/#212) -- gated on the same predicates as the edits,
-- so a runner that sailed past a HALT cannot stamp a migration that refused to run.
insert into public.schema_migrations (version, filename, note)
select '110','110_btli_renumber_books_to_lessons.sql','Mac Lake books + Usad/Unlad become lessons: delete 8 standalone book/duplicate rungs, retitle the 6-course BTLI spine (Usbong / BTLI 101 / 201 / 301 / 401 / 501), move the BTLI 101 chip onto btli1, renumber cross-references; template lane + the 10 never-edited church lanes, pathway_versions.doc updated in step. Rosehill and True North excluded (Pastor edits them in the editor). Rung keys unchanged; pathway_progress untouched.'
 where (select count(*) from _targets) = 10
   and not exists (select 1 from public.pathway_progress p2
                    join _doomed  d2 on d2.level = p2.level and d2.rung_key = p2.rung_key
                    join _targets t2 on t2.id    = p2.church_id)
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

-- ---- SELF-VERIFY -- asserts only THIS migration's own effects (#403), rerun-safe.
-- Expect: doomed_rows_left 0, doomed_in_docs 0, retitle_wrong 0,
-- retitle_in_docs_wrong 0, old_numbers_rows 0, old_numbers_docs 0,
-- btli1_chip_missing 0, spine_rows_kept 66 (6 keys x 11 lanes; adjust only if
-- the lane count ever changes), progress_lost 0, all_ok PASS.
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
      and (r.title_en is distinct from t.title_en
        or r.title_tl is distinct from t.title_tl))                          as retitle_wrong,
  (select count(*) from public.pathway_versions v
     cross join lateral jsonb_object_keys(v.doc->'levels') lk
     cross join lateral jsonb_array_elements(v.doc->'levels'->lk) e
     join _retitle t on t.level = lk::int and t.rung_key = e->>'rung_key'
    where v.church_id in (select id from _targets)
      and (e->>'title_en' is distinct from t.title_en
        or e->>'title_tl' is distinct from t.title_tl))                      as retitle_in_docs_wrong,
  (select count(*) from public.pathway_rungs r
    where (r.church_id is null or r.church_id in (select id from _targets))
      and r.meta::text ~ E'BTLI 10[2-6]|BTLI 101\u2013105|BTLI 101 and 102')                  as old_numbers_rows,
  (select count(*) from public.pathway_versions v
    where v.church_id in (select id from _targets)
      and v.doc::text ~ E'BTLI 10[2-6]|BTLI 101\u2013105|BTLI 101 and 102')                   as old_numbers_docs,
  (select count(*) from public.pathway_rungs r
    where r.level = 1 and r.rung_key = 'btli1'
      and (r.church_id is null or r.church_id in (select id from _targets))
      and r.meta = '{}'::jsonb)                                              as btli1_chip_missing,
  (select count(*) from public.pathway_rungs r join _retitle t
     on t.level=r.level and t.rung_key=r.rung_key
    where r.church_id is null or r.church_id in (select id from _targets))   as spine_rows_kept,
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
           and (r.title_en is distinct from t.title_en or r.title_tl is distinct from t.title_tl)) = 0
   and (select count(*) from public.pathway_versions v
          cross join lateral jsonb_object_keys(v.doc->'levels') lk
          cross join lateral jsonb_array_elements(v.doc->'levels'->lk) e
          join _retitle t on t.level = lk::int and t.rung_key = e->>'rung_key'
         where v.church_id in (select id from _targets)
           and (e->>'title_en' is distinct from t.title_en or e->>'title_tl' is distinct from t.title_tl)) = 0
   and (select count(*) from public.pathway_rungs r
         where (r.church_id is null or r.church_id in (select id from _targets))
           and r.meta::text ~ E'BTLI 10[2-6]|BTLI 101\u2013105|BTLI 101 and 102') = 0
   and (select count(*) from public.pathway_versions v
         where v.church_id in (select id from _targets)
           and v.doc::text ~ E'BTLI 10[2-6]|BTLI 101\u2013105|BTLI 101 and 102') = 0
   and (select count(*) from public.pathway_rungs r
         where r.level = 1 and r.rung_key = 'btli1'
           and (r.church_id is null or r.church_id in (select id from _targets))
           and r.meta = '{}'::jsonb) = 0
   and (select count(*) from public.pathway_progress p
          join _doomed d on d.level=p.level and d.rung_key=p.rung_key
          join _targets tg on tg.id = p.church_id) = 0
   -- existence, not a magic count (#425): the six renamed spine rungs must be
   -- PRESENT in scope, or every zero above is vacuous (#427).
   and (select count(*) from public.pathway_rungs r join _retitle t
          on t.level=r.level and t.rung_key=r.rung_key
         where r.church_id is null or r.church_id in (select id from _targets)) >= 6
  then 'PASS' else 'FAIL' end                                                as all_ok;
