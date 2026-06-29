-- migrations/038_gratitude_entries.sql
-- S52 — daily Gratitude Journal table. Mirrors devotional_reflections + a
-- shared_to_lc bool. Member-own RLS (auth_member_id()) PLUS LC-mates may read
-- rows flagged shared_to_lc=true within the same church; same-LCG narrowing
-- happens client-side in loadCelebrationFeed (matches the existing feed).
-- DELIBERATELY no UNIQUE(member_id, entry_date): multiple entries/day allowed.
-- church_id auto-stamps on insert via trg_set_church_id (#182).
-- FLAT (#209), idempotent, ledger (#212), trailing self-verify (#210).

create table if not exists public.gratitude_entries (
  id            uuid primary key default gen_random_uuid(),
  member_id     uuid not null references public.members(id) on delete cascade,
  entry_date    date not null,
  body          text,
  shared_to_lc  boolean not null default false,
  church_id     uuid references public.churches(id),
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);

alter table public.gratitude_entries add column if not exists shared_to_lc boolean not null default false;
alter table public.gratitude_entries add column if not exists church_id uuid references public.churches(id);

create index if not exists idx_gratitude_member        on public.gratitude_entries using btree (member_id, entry_date desc);
create index if not exists idx_gratitude_church         on public.gratitude_entries using btree (church_id);
create index if not exists idx_gratitude_shared_feed    on public.gratitude_entries using btree (church_id, entry_date desc) where shared_to_lc = true;

drop trigger if exists trg_set_church_id on public.gratitude_entries;
create trigger trg_set_church_id before insert on public.gratitude_entries
  for each row execute function set_church_id_from_jwt();

drop policy if exists gratitude_tenant_select on public.gratitude_entries;
create policy gratitude_tenant_select on public.gratitude_entries for select to authenticated
  using (member_id = auth_member_id()
         or (shared_to_lc = true and church_id = auth_church_id()));

drop policy if exists gratitude_tenant_insert on public.gratitude_entries;
create policy gratitude_tenant_insert on public.gratitude_entries for insert to authenticated
  with check (member_id = auth_member_id() and church_id = auth_church_id());

drop policy if exists gratitude_tenant_update on public.gratitude_entries;
create policy gratitude_tenant_update on public.gratitude_entries for update to authenticated
  using (member_id = auth_member_id())
  with check (member_id = auth_member_id());

drop policy if exists gratitude_tenant_delete on public.gratitude_entries;
create policy gratitude_tenant_delete on public.gratitude_entries for delete to authenticated
  using (member_id = auth_member_id());

alter table public.gratitude_entries enable row level security;

insert into public.schema_migrations (version, filename, note) values
  ('038','038_gratitude_entries.sql','daily Gratitude Journal table mirroring devotional_reflections + shared_to_lc bool; member-own RLS (auth_member_id()) plus same-church read of shared_to_lc=true rows (LCG narrowing client-side in loadCelebrationFeed); church_id auto-stamped via trg_set_church_id (#182); NO unique(member_id,entry_date) — multiple entries/day allowed; 4 tenant policies; RLS enabled.')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

select
  c.relrowsecurity as rls_enabled,
  (select count(*) from pg_policies p
     where p.schemaname='public' and p.tablename='gratitude_entries') as n_policies,
  exists(select 1 from information_schema.columns
     where table_schema='public' and table_name='gratitude_entries' and column_name='shared_to_lc') as has_shared_to_lc,
  exists(select 1 from pg_indexes
     where schemaname='public' and tablename='gratitude_entries'
       and indexdef ilike '%unique%' and indexdef ilike '%member_id, entry_date%') as has_unique_member_date
from pg_class c where c.oid='public.gratitude_entries'::regclass;
