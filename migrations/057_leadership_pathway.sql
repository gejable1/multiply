-- ============================================================================
-- 057_leadership_pathway.sql   ·   Session 57
-- Leadership pathway: per-level "rungs" a member completes to advance a level.
--
--   pathway_rungs     = catalog (Model 3): church_id NULL = MULTIPLY base,
--                       church_id set = per-church overlay. Partial-unique
--                       base + overlay (#253 — a plain composite unique fails
--                       here because NULLs are distinct).
--   pathway_progress  = per-member marks. LCL-only writes in v1 (decision).
--                       RLS: member reads own; LCL reads/writes own disciples
--                       via discipler_of(); L3+ coach reads church-wide;
--                       L5 pastor writes any (#254 auth_member_id in leader
--                       sessions makes the LCL gate work).
--
-- FLAT (#209), rerun-until-true / self-verifying (#210), committed to
-- migrations/ right after running (#242/#252). Helpers verified present in
-- schema.json: auth_church_id(), auth_member_id(), auth_level(),
-- discipler_of(p_member uuid).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. CATALOG: pathway_rungs
-- ----------------------------------------------------------------------------
create table if not exists public.pathway_rungs (
  id                uuid primary key default gen_random_uuid(),
  church_id         uuid references public.churches(id) on delete cascade,   -- NULL = base
  level             int  not null check (level between 0 and 5),
  sort_order        int  not null default 0,
  rung_key          text not null,
  title_en          text not null,
  title_tl          text,
  description_en    text,
  description_tl    text,
  category          text not null check (category in
                      ('book','training','lesson','ministry','coaching',
                       'assessment','character','competency','discipline')),
  completion_source text not null default 'manual'
                      check (completion_source in ('manual','auto')),
  auto_source_key   text,
  published         boolean not null default true,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

-- Partial uniques (#253): one base row per (level, rung_key); one overlay row
-- per (church_id, level, rung_key). Keeps NULL-church base from duplicating.
create unique index if not exists pathway_rungs_base_uk
  on public.pathway_rungs (level, rung_key)
  where church_id is null;

create unique index if not exists pathway_rungs_overlay_uk
  on public.pathway_rungs (church_id, level, rung_key)
  where church_id is not null;

create index if not exists pathway_rungs_lookup_ix
  on public.pathway_rungs (level, church_id) where published;

-- ----------------------------------------------------------------------------
-- 2. PROGRESS: pathway_progress  (one row = one completed rung for one member)
-- ----------------------------------------------------------------------------
create table if not exists public.pathway_progress (
  id           uuid primary key default gen_random_uuid(),
  church_id    uuid not null references public.churches(id) on delete cascade,
  member_id    uuid not null references public.members(id)  on delete cascade,
  level        int  not null check (level between 0 and 5),
  rung_key     text not null,
  completed_at timestamptz not null default now(),
  marked_by    uuid references public.members(id) on delete set null,
  note         text,
  created_at   timestamptz not null default now(),
  unique (church_id, member_id, level, rung_key)
);

create index if not exists pathway_progress_member_ix
  on public.pathway_progress (church_id, member_id);

-- ----------------------------------------------------------------------------
-- 3. RLS — pathway_rungs (catalog: base readable by all; overlay = pastor own)
-- ----------------------------------------------------------------------------
alter table public.pathway_rungs enable row level security;

drop policy if exists pathway_rungs_select on public.pathway_rungs;
create policy pathway_rungs_select on public.pathway_rungs
  for select to authenticated
  using (church_id is null or church_id = auth_church_id());

drop policy if exists pathway_rungs_insert on public.pathway_rungs;
create policy pathway_rungs_insert on public.pathway_rungs
  for insert to authenticated
  with check (church_id = auth_church_id() and auth_level() >= 5);

drop policy if exists pathway_rungs_update on public.pathway_rungs;
create policy pathway_rungs_update on public.pathway_rungs
  for update to authenticated
  using      (church_id = auth_church_id() and auth_level() >= 5)
  with check (church_id = auth_church_id() and auth_level() >= 5);

drop policy if exists pathway_rungs_delete on public.pathway_rungs;
create policy pathway_rungs_delete on public.pathway_rungs
  for delete to authenticated
  using (church_id = auth_church_id() and auth_level() >= 5);

-- ----------------------------------------------------------------------------
-- 4. RLS — pathway_progress (member reads own; LCL marks own disciples)
-- ----------------------------------------------------------------------------
alter table public.pathway_progress enable row level security;

drop policy if exists pathway_progress_select on public.pathway_progress;
create policy pathway_progress_select on public.pathway_progress
  for select to authenticated
  using (
    church_id = auth_church_id() and (
      member_id = auth_member_id()
      or auth_level() >= 3
      or discipler_of(member_id) = auth_member_id()
    )
  );

drop policy if exists pathway_progress_insert on public.pathway_progress;
create policy pathway_progress_insert on public.pathway_progress
  for insert to authenticated
  with check (
    church_id = auth_church_id() and (
      auth_level() >= 5
      or discipler_of(member_id) = auth_member_id()
    )
  );

drop policy if exists pathway_progress_update on public.pathway_progress;
create policy pathway_progress_update on public.pathway_progress
  for update to authenticated
  using (
    church_id = auth_church_id() and (
      auth_level() >= 5 or discipler_of(member_id) = auth_member_id()
    )
  )
  with check (
    church_id = auth_church_id() and (
      auth_level() >= 5 or discipler_of(member_id) = auth_member_id()
    )
  );

drop policy if exists pathway_progress_delete on public.pathway_progress;
create policy pathway_progress_delete on public.pathway_progress
  for delete to authenticated
  using (
    church_id = auth_church_id() and (
      auth_level() >= 5 or discipler_of(member_id) = auth_member_id()
    )
  );

-- ----------------------------------------------------------------------------
-- 5. SEED — MULTIPLY base rungs (church_id NULL). Rerun-safe via ON CONFLICT
--    against the base partial-unique index.
-- ----------------------------------------------------------------------------
insert into public.pathway_rungs
  (church_id, level, sort_order, rung_key, title_en, title_tl, category, completion_source, auto_source_key)
values
  -- L0  New Believer -> L1
  (null,0,1,'usbong1',            'Complete Usbong 1 (10 lessons)',        'Tapusin ang Usbong 1 (10 aralin)',   'lesson',    'auto','lesson:usbong1:all'),
  (null,0,2,'salvation',          'Salvation assurance diagnostic',        'Pagtiyak sa kaligtasan',             'assessment','auto','assessment:salvation'),
  (null,0,3,'basic-christianity', 'Read "Basic Christianity" (Stott)',     'Basahin ang "Basic Christianity"',   'book',      'manual',null),
  (null,0,4,'baptism',            'Water baptism',                         'Bautismo sa tubig',                  'character', 'manual',null),
  (null,0,5,'devo-7',             'Start daily devotional (7-day streak)', 'Simulan ang debosyonal (7-araw)',    'discipline','auto','streak:devotional:7'),
  (null,0,6,'join-lc',            'Join a Life Group',                     'Sumali sa Life Group',               'ministry',  'manual',null),
  -- L1  Team Member -> L2
  (null,1,1,'btli1',              'Complete BTLI 1 (20 lessons)',          'Tapusin ang BTLI 1 (20 aralin)',     'lesson',    'auto','lesson:btli1:all'),
  (null,1,2,'gifts',              'Spiritual gifts diagnostic',            'Diagnostic ng espirituwal na kaloob','assessment','auto','assessment:gifts'),
  (null,1,3,'leading-yourself',   'Read "Leading Yourself" (Mac Lake)',    'Basahin ang "Leading Yourself"',     'book',      'manual',null),
  (null,1,4,'devo-30',            '30-day devotional streak',              '30-araw na debosyonal',              'discipline','auto','streak:devotional:30'),
  (null,1,5,'serve-ministry',     'Serve in a ministry team',              'Maglingkod sa isang ministeryo',     'ministry',  'manual',null),
  (null,1,6,'fats',               'FATS affirmed by leader',               'FATS, kinilala ng lider',            'character', 'manual',null),
  (null,1,7,'glorious-hope',      'Attend CCF Glorious Hope',              'Dumalo sa CCF Glorious Hope',        'training',  'manual',null),
  (null,1,8,'eolo-1',             'Disciple one person (EOLO)',            'Mag-disciple ng isa (EOLO)',         'competency','manual',null),
  -- L2  Leader -> L3
  (null,2,1,'leading-others',     'Read "Leading Others" (Mac Lake)',      'Basahin ang "Leading Others"',       'book',      'manual',null),
  (null,2,2,'lead-lc',            'Lead a Life Group consistently',        'Mamuno ng Life Group nang tuloy-tuloy','competency','manual',null),
  (null,2,3,'disc',               'DISC working-style assessment',         'DISC na pagsusuri ng istilo',        'assessment','auto','assessment:disc'),
  (null,2,4,'conflict',           'Conflict-style assessment',             'Pagsusuri sa istilo sa alitan',      'assessment','auto','assessment:conflict'),
  (null,2,5,'six-sources',        'Six Sources life-transformation plan',  'Plano gamit ang Six Sources',        'coaching',  'manual',null),
  (null,2,6,'apprentice',         'Raise one apprentice leader',           'Magpalago ng isang apprentice',      'competency','manual',null),
  (null,2,7,'fruit-review',       'Fruit of the Spirit review with coach', 'Pagsusuri sa bunga ng Espiritu',     'character', 'manual',null),
  -- L3  Coach -> L4
  (null,3,1,'leading-leaders',    'Read "Leading Leaders" (Mac Lake)',     'Basahin ang "Leading Leaders"',      'book',      'manual',null),
  (null,3,2,'coach-leaders',      'Coach 2+ Life Group leaders',           'Mag-coach ng 2+ na LC leaders',      'competency','manual',null),
  (null,3,3,'strengths',          'CliftonStrengths / Enneagram',          'CliftonStrengths / Enneagram',       'assessment','auto','assessment:strengths'),
  (null,3,4,'coaching-cohort',    'Complete a life-coaching cohort',       'Tapusin ang coaching cohort',        'coaching',  'manual',null),
  (null,3,5,'cluster-plan',       'Leadership dev-plan for your cluster',  'Dev-plan para sa iyong cluster',     'competency','manual',null),
  (null,3,6,'apiis',              'Attend APIIS Masters (preachers)',      'Dumalo sa APIIS Masters',            'training',  'manual',null),
  -- L4  Director -> L5
  (null,4,1,'leading-dept',       'Read "Leading a Department/Ministry"',  'Basahin ang "Leading a Department"', 'book',      'manual',null),
  (null,4,2,'direct-ministry',    'Direct a ministry or department',       'Mamahala ng ministeryo/departamento','ministry', 'manual',null),
  (null,4,3,'dept-pipeline',      'Build a pipeline within your department','Magtayo ng pipeline sa departamento','competency','manual',null),
  (null,4,4,'mentor-director',    'Mentor a future director',              'Mag-mentor ng magiging director',    'competency','manual',null),
  (null,4,5,'strategic',          'Lead strategic planning + stewardship', 'Mamuno sa strategic planning',       'competency','manual',null),
  -- L5  Executive -> ongoing / completion
  (null,5,1,'leading-org',        'Read "Leading an Organization/Church"', 'Basahin ang "Leading an Organization"','book',    'manual',null),
  (null,5,2,'mult-effect',        'Read "The Multiplication Effect"',      'Basahin ang "The Multiplication Effect"','book',   'manual',null),
  (null,5,3,'plant',              'Plant or lead a church / major unit',   'Magtatag/mamuno ng simbahan o yunit','competency','manual',null),
  (null,5,4,'successor',          'Legacy plan: name + develop a successor','Legacy: pumili + hubugin ang kahalili','competency','manual',null),
  (null,5,5,'luke640',            'Model Luke 6:40 + Gal 5:22-23 (ongoing)','Maging huwaran ng Luke 6:40',        'character', 'manual',null)
on conflict (level, rung_key) where church_id is null do nothing;

-- ----------------------------------------------------------------------------
-- 6. LEDGER (#212)
-- ----------------------------------------------------------------------------
insert into public.schema_migrations (version, filename, applied_at, note)
values ('057','057_leadership_pathway.sql', now(),
        'Leadership pathway: pathway_rungs catalog (partial-unique base+overlay #253) + pathway_progress per-member (LCL-marked, RLS via discipler_of/#254) + L0-L5 base seed')
on conflict (version) do nothing;

-- ----------------------------------------------------------------------------
-- 7. SELF-VERIFY (#210) — rerun until every value below is as expected.
--    Expect: base_rungs=37, levels_seeded=6, rungs_rls=t, progress_rls=t,
--            rungs_policies=4, progress_policies=4
-- ----------------------------------------------------------------------------
select
  (select count(*) from public.pathway_rungs where church_id is null)                          as base_rungs,
  (select count(distinct level) from public.pathway_rungs where church_id is null)             as levels_seeded,
  (select relrowsecurity from pg_class where relname='pathway_rungs' and relnamespace='public'::regnamespace)    as rungs_rls,
  (select relrowsecurity from pg_class where relname='pathway_progress' and relnamespace='public'::regnamespace) as progress_rls,
  (select count(*) from pg_policies where schemaname='public' and tablename='pathway_rungs')    as rungs_policies,
  (select count(*) from pg_policies where schemaname='public' and tablename='pathway_progress') as progress_policies;
