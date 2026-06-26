-- ============================================================
-- Migration 033 — S48 shared-content catalog tenancy (Model 3)
-- Shared base (church_id IS NULL) + per-church overlay (church_id = mine).
-- STRUCTURE ONLY. RLS stays DISABLED — Phase B enables it after the
-- platform publish-lane EF exists (else in-app base authoring locks out).
-- FLAT (#209), idempotent, ledger stamp + trailing self-verify (#210/#212).
-- ============================================================

-- 1) nullable church_id; existing rows stay NULL = canonical base.
--    ON DELETE CASCADE = deprovisioning a church auto-cleans its overlays.
alter table public.btli_quizzes      add column if not exists church_id uuid references public.churches(id) on delete cascade;
alter table public.cohort_programs   add column if not exists church_id uuid references public.churches(id) on delete cascade;
alter table public.library_chapters  add column if not exists church_id uuid references public.churches(id) on delete cascade;
alter table public.library_quizzes   add column if not exists church_id uuid references public.churches(id) on delete cascade;
alter table public.library_resources add column if not exists church_id uuid references public.churches(id) on delete cascade;
alter table public.pipeline_lessons  add column if not exists church_id uuid references public.churches(id) on delete cascade;
alter table public.usbong_quizzes    add column if not exists church_id uuid references public.churches(id) on delete cascade;

-- 2) tenant policies: SELECT = base-or-mine; INSERT/UPDATE/DELETE = mine-only.
drop policy if exists btli_quizzes_tenant_select on public.btli_quizzes;
create policy btli_quizzes_tenant_select on public.btli_quizzes for select to authenticated
  using (church_id is null or church_id = auth_church_id());
drop policy if exists btli_quizzes_tenant_insert on public.btli_quizzes;
create policy btli_quizzes_tenant_insert on public.btli_quizzes for insert to authenticated
  with check (church_id = auth_church_id());
drop policy if exists btli_quizzes_tenant_update on public.btli_quizzes;
create policy btli_quizzes_tenant_update on public.btli_quizzes for update to authenticated
  using (church_id = auth_church_id()) with check (church_id = auth_church_id());
drop policy if exists btli_quizzes_tenant_delete on public.btli_quizzes;
create policy btli_quizzes_tenant_delete on public.btli_quizzes for delete to authenticated
  using (church_id = auth_church_id());

drop policy if exists cohort_programs_tenant_select on public.cohort_programs;
create policy cohort_programs_tenant_select on public.cohort_programs for select to authenticated
  using (church_id is null or church_id = auth_church_id());
drop policy if exists cohort_programs_tenant_insert on public.cohort_programs;
create policy cohort_programs_tenant_insert on public.cohort_programs for insert to authenticated
  with check (church_id = auth_church_id());
drop policy if exists cohort_programs_tenant_update on public.cohort_programs;
create policy cohort_programs_tenant_update on public.cohort_programs for update to authenticated
  using (church_id = auth_church_id()) with check (church_id = auth_church_id());
drop policy if exists cohort_programs_tenant_delete on public.cohort_programs;
create policy cohort_programs_tenant_delete on public.cohort_programs for delete to authenticated
  using (church_id = auth_church_id());

drop policy if exists library_chapters_tenant_select on public.library_chapters;
create policy library_chapters_tenant_select on public.library_chapters for select to authenticated
  using (church_id is null or church_id = auth_church_id());
drop policy if exists library_chapters_tenant_insert on public.library_chapters;
create policy library_chapters_tenant_insert on public.library_chapters for insert to authenticated
  with check (church_id = auth_church_id());
drop policy if exists library_chapters_tenant_update on public.library_chapters;
create policy library_chapters_tenant_update on public.library_chapters for update to authenticated
  using (church_id = auth_church_id()) with check (church_id = auth_church_id());
drop policy if exists library_chapters_tenant_delete on public.library_chapters;
create policy library_chapters_tenant_delete on public.library_chapters for delete to authenticated
  using (church_id = auth_church_id());

drop policy if exists library_quizzes_tenant_select on public.library_quizzes;
create policy library_quizzes_tenant_select on public.library_quizzes for select to authenticated
  using (church_id is null or church_id = auth_church_id());
drop policy if exists library_quizzes_tenant_insert on public.library_quizzes;
create policy library_quizzes_tenant_insert on public.library_quizzes for insert to authenticated
  with check (church_id = auth_church_id());
drop policy if exists library_quizzes_tenant_update on public.library_quizzes;
create policy library_quizzes_tenant_update on public.library_quizzes for update to authenticated
  using (church_id = auth_church_id()) with check (church_id = auth_church_id());
drop policy if exists library_quizzes_tenant_delete on public.library_quizzes;
create policy library_quizzes_tenant_delete on public.library_quizzes for delete to authenticated
  using (church_id = auth_church_id());

drop policy if exists library_resources_tenant_select on public.library_resources;
create policy library_resources_tenant_select on public.library_resources for select to authenticated
  using (church_id is null or church_id = auth_church_id());
drop policy if exists library_resources_tenant_insert on public.library_resources;
create policy library_resources_tenant_insert on public.library_resources for insert to authenticated
  with check (church_id = auth_church_id());
drop policy if exists library_resources_tenant_update on public.library_resources;
create policy library_resources_tenant_update on public.library_resources for update to authenticated
  using (church_id = auth_church_id()) with check (church_id = auth_church_id());
drop policy if exists library_resources_tenant_delete on public.library_resources;
create policy library_resources_tenant_delete on public.library_resources for delete to authenticated
  using (church_id = auth_church_id());

drop policy if exists pipeline_lessons_tenant_select on public.pipeline_lessons;
create policy pipeline_lessons_tenant_select on public.pipeline_lessons for select to authenticated
  using (church_id is null or church_id = auth_church_id());
drop policy if exists pipeline_lessons_tenant_insert on public.pipeline_lessons;
create policy pipeline_lessons_tenant_insert on public.pipeline_lessons for insert to authenticated
  with check (church_id = auth_church_id());
drop policy if exists pipeline_lessons_tenant_update on public.pipeline_lessons;
create policy pipeline_lessons_tenant_update on public.pipeline_lessons for update to authenticated
  using (church_id = auth_church_id()) with check (church_id = auth_church_id());
drop policy if exists pipeline_lessons_tenant_delete on public.pipeline_lessons;
create policy pipeline_lessons_tenant_delete on public.pipeline_lessons for delete to authenticated
  using (church_id = auth_church_id());

drop policy if exists usbong_quizzes_tenant_select on public.usbong_quizzes;
create policy usbong_quizzes_tenant_select on public.usbong_quizzes for select to authenticated
  using (church_id is null or church_id = auth_church_id());
drop policy if exists usbong_quizzes_tenant_insert on public.usbong_quizzes;
create policy usbong_quizzes_tenant_insert on public.usbong_quizzes for insert to authenticated
  with check (church_id = auth_church_id());
drop policy if exists usbong_quizzes_tenant_update on public.usbong_quizzes;
create policy usbong_quizzes_tenant_update on public.usbong_quizzes for update to authenticated
  using (church_id = auth_church_id()) with check (church_id = auth_church_id());
drop policy if exists usbong_quizzes_tenant_delete on public.usbong_quizzes;
create policy usbong_quizzes_tenant_delete on public.usbong_quizzes for delete to authenticated
  using (church_id = auth_church_id());

-- 3) keep RLS OFF (intentional — Phase B flips this, after publish lane).
alter table public.btli_quizzes      disable row level security;
alter table public.cohort_programs   disable row level security;
alter table public.library_chapters  disable row level security;
alter table public.library_quizzes   disable row level security;
alter table public.library_resources disable row level security;
alter table public.pipeline_lessons  disable row level security;
alter table public.usbong_quizzes    disable row level security;

-- 4) ledger stamp (#212)
insert into public.schema_migrations (version, filename, note) values
  ('033','033_shared_content_catalog_tenancy.sql','Model 3 shared-content catalog tenancy: nullable church_id (NULL=global base) + 4 tenant policies (base-or-mine read, mine-only write) on 7 catalog tables; RLS left DISABLED pending Phase B publish-lane')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

-- 5) SELF-VERIFY — expect every row: has_church_id=true, n_policies=4, rls_enabled=false
with tbls as (
  select unnest(array[
    'btli_quizzes','cohort_programs','library_chapters','library_quizzes',
    'library_resources','pipeline_lessons','usbong_quizzes'
  ]) as t
)
select
  tbls.t as table_name,
  exists (select 1 from information_schema.columns c
          where c.table_schema='public' and c.table_name=tbls.t
            and c.column_name='church_id')                          as has_church_id,
  (select count(*) from pg_policies p
     where p.schemaname='public' and p.tablename=tbls.t)            as n_policies,
  cls.relrowsecurity                                                as rls_enabled
from tbls
join pg_class cls on cls.oid = ('public.'||tbls.t)::regclass
order by table_name;
