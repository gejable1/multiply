-- 063_pathway_section_order.sql · S58 3b — per-church pipeline section order (full-interleave reorder)
create table if not exists public.pathway_section_order (
  id uuid primary key default gen_random_uuid(),
  church_id uuid not null unique,
  order_map jsonb not null default '{}'::jsonb,   -- {"level|category": ["rung_key", ...]}
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.pathway_section_order enable row level security;

drop policy if exists pathway_section_order_select on public.pathway_section_order;
create policy pathway_section_order_select on public.pathway_section_order
  for select to authenticated using (church_id = auth_church_id());
drop policy if exists pathway_section_order_insert on public.pathway_section_order;
create policy pathway_section_order_insert on public.pathway_section_order
  for insert to authenticated with check (church_id = auth_church_id() and auth_level() >= 5);
drop policy if exists pathway_section_order_update on public.pathway_section_order;
create policy pathway_section_order_update on public.pathway_section_order
  for update to authenticated
  using (church_id = auth_church_id() and auth_level() >= 5)
  with check (church_id = auth_church_id() and auth_level() >= 5);
drop policy if exists pathway_section_order_delete on public.pathway_section_order;
create policy pathway_section_order_delete on public.pathway_section_order
  for delete to authenticated using (church_id = auth_church_id() and auth_level() >= 5);

drop trigger if exists trg_set_church_id on public.pathway_section_order;
create trigger trg_set_church_id before insert on public.pathway_section_order
  for each row execute function public.set_church_id_from_jwt();

insert into public.schema_migrations (version, filename, applied_at, note)
values ('063','063_pathway_section_order.sql', now(),
        'Per-church pipeline section order (order_map jsonb) for full-interleave reorder — RLS L5 own-church + church-stamp trigger')
on conflict (version) do nothing;

select
  (select count(*) from information_schema.tables where table_schema='public' and table_name='pathway_section_order') as table_present,
  (select relrowsecurity from pg_class where oid='public.pathway_section_order'::regclass) as rls_on,
  (select count(*) from pg_policies where schemaname='public' and tablename='pathway_section_order') as policy_count,
  (select count(*) from pg_trigger where tgrelid='public.pathway_section_order'::regclass and tgname='trg_set_church_id' and not tgisinternal) as stamp_trigger;