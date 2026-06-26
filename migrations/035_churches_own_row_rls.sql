-- migrations/035_churches_own_row_rls.sql
-- S48 — churches registry isolation: own-row-only SELECT + enable RLS.
-- Verified: NO client surface reads/writes churches (all 8 app files); church
-- identity flows via JWT (token-login). EFs are service-role -> bypass RLS, so
-- login/onboarding are unaffected. authenticated SELECT = own row only; writes
-- denied for authenticated/anon (no write policy) -> service-role/owner-only.
-- In-browser leak test (Agape JWT) returned exactly 1 row (Agape), Rosehill invisible.
-- FLAT (#209), idempotent, ledger (#212), trailing self-verify (#210).

-- own-row SELECT (everything else: no policy = denied for authenticated/anon)
drop policy if exists churches_tenant_select on public.churches;
create policy churches_tenant_select on public.churches for select to authenticated
  using (id = auth_church_id());

-- enable RLS
alter table public.churches enable row level security;

-- ledger stamp (#212)
insert into public.schema_migrations (version, filename, note) values
  ('035','035_churches_own_row_rls.sql','churches registry isolation: own-row-only SELECT (id = auth_church_id()) for authenticated; writes service-role/owner-only; RLS enabled. No client surface touches churches (verified all 8 app files); login resolves church via JWT/EF. Leak-tested in-browser: Agape JWT sees 1 row.')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

-- SELF-VERIFY — expect: rls_enabled=true, n_policies=1, policy = SELECT (id = auth_church_id()), allow_all_stubs=0
select
  c.relrowsecurity as rls_enabled,
  (select count(*) from pg_policies p
     where p.schemaname='public' and p.tablename='churches') as n_policies,
  (select string_agg(p.policyname||' ['||p.cmd||'] '||coalesce(p.qual,'∅'), ' | ')
     from pg_policies p
     where p.schemaname='public' and p.tablename='churches') as policy_detail,
  (select count(*) from pg_policies p
     where p.schemaname='public' and p.tablename='churches'
       and p.roles::text ~ '(anon|public)' and coalesce(p.qual,'')='true') as allow_all_stubs
from pg_class c where c.oid='public.churches'::regclass;
