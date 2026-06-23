-- migrations/015_rls_canary_debrief_records.sql
-- Phase 2 · FIRST RLS canary. church-scoped RLS on ONE fully-JWT table.
-- RUN ONLY AFTER C3a + C3b-1 are deployed (they are). Idempotent. Rollback = 015_rollback.sql.

-- 0) Safety backfill: any NULL-trickle rows → Rosehill (only Rosehill data exists today;
--    without this a SELECT policy would HIDE NULL-church_id rows).
update public.debrief_records
   set church_id = (select id from public.churches where slug='rosehill')
 where church_id is null;

-- 1) Policies (authenticated only; anon has no policy → denied — that's the isolation).
drop policy if exists deb_sel on public.debrief_records;
drop policy if exists deb_ins on public.debrief_records;
drop policy if exists deb_upd on public.debrief_records;
drop policy if exists deb_del on public.debrief_records;

create policy deb_sel on public.debrief_records for select to authenticated
  using (church_id = public.auth_church_id());
create policy deb_ins on public.debrief_records for insert to authenticated
  with check (church_id = public.auth_church_id());
create policy deb_upd on public.debrief_records for update to authenticated
  using (church_id = public.auth_church_id())
  with check (church_id = public.auth_church_id());
create policy deb_del on public.debrief_records for delete to authenticated
  using (church_id = public.auth_church_id());

-- 2) Turn RLS ON for THIS table only.
alter table public.debrief_records enable row level security;

-- VERIFY:
-- select relrowsecurity from pg_class where relname='debrief_records';                 -- expect true
-- select policyname, cmd from pg_policies where tablename='debrief_records' order by 1; -- 4 rows
-- select count(*) as null_church from public.debrief_records where church_id is null;   -- expect 0
