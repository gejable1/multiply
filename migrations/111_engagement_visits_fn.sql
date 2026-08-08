-- migrations/111_engagement_visits_fn.sql
-- S87 -- the engagement report's visit counts move server-side.
--
-- THE DEFECT THIS CURES. engagement_report.html fetched raw app_sessions rows
-- (member_id, created_at over a 90-day window) and folded counts in JS.
-- PostgREST silently caps that response at 1,000 rows, so every count on the
-- Pastor's screen was "this member's share of the newest ~1,000 sessions
-- church-wide" -- an invisible horizon about one to two weeks back. Verified
-- against live data 2026-08-08: all ten flock rows undercounted (e.g. 45
-- shown vs 267 true; 4 shown vs 76 true). Last-active survived only because
-- the fetch was DESC-ordered. The fix: aggregate where the rows live; ship
-- eleven numbers to the browser, not thousands of rows.
--
-- SECURITY INVOKER, deliberately: the function runs under the caller's RLS,
-- so app_sessions_tenant_select (church_id = auth_church_id()) scopes it to
-- the caller's church exactly as the raw fetch was scoped. No new visibility
-- is created by this migration -- only correct arithmetic over rows the
-- caller could already read one by one.
--
-- The window is a parameter with the page's current value as its default, so
-- the page can call rpc('engagement_visits_90d') bare today and a future
-- per-church window (the svi_metric_overrides pattern) costs no new function.
-- Capped at 366 days: an aggregate over the caller's own church is cheap, but
-- an unbounded interval is an invitation nobody sent.
--
-- Rows with member_id IS NULL are excluded, mirroring the JS fold's
-- `if (!row.member_id) return;` -- the function replaces the fold, so it
-- keeps the fold's rule (#438).
--
-- Flat (#209), idempotent (create or replace), self-verifying on its own
-- effects (#403), ledger stamped (#402). Proved on ephemeral PG16 under real
-- RLS with >1,000 rows and by deliberate failure (#413).

create or replace function public.engagement_visits_90d(p_days int default 90)
returns table(member_id uuid, visits bigint, last_sess timestamptz)
language sql
stable
security invoker
set search_path = public
as $fn$
  select s.member_id,
         count(*)          as visits,
         max(s.created_at) as last_sess
    from public.app_sessions s
   where s.created_at >= now() - make_interval(days => least(greatest(p_days, 1), 366))
     and s.member_id is not null
   group by s.member_id
$fn$;

-- Functions are EXECUTE-able by PUBLIC by default, and on Supabase the
-- project's ALTER DEFAULT PRIVILEGES additionally grants EXECUTE to anon,
-- authenticated and service_role EXPLICITLY at creation -- so revoking from
-- PUBLIC alone leaves anon holding its own grant (caught live by this file's
-- own self-verify, 2026-08-08). Revoke both; keep authenticated (the callers)
-- and service_role (Edge Functions).
revoke execute on function public.engagement_visits_90d(int) from public;
revoke execute on function public.engagement_visits_90d(int) from anon;
grant execute on function public.engagement_visits_90d(int) to authenticated;

-- ---- ledger stamp (#402/#212)
insert into public.schema_migrations (version, filename, note) values
  ('111','111_engagement_visits_fn.sql','engagement_visits_90d(p_days default 90): SECURITY INVOKER server-side visit counts + last session per member over a bounded window, replacing the client-side fold over a PostgREST-capped raw fetch that silently undercounted every member. RLS-scoped via app_sessions_tenant_select; null member_id excluded to mirror the fold it replaces.')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

-- ---- SELF-VERIFY -- asserts only THIS migration's own effects (#403), rerun-safe.
-- Expect: fn_exists 1, is_invoker true, is_stable true, authenticated_can_exec
-- true, anon_cannot_exec true, all_ok PASS.
select
  (select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'engagement_visits_90d')        as fn_exists,
  (select not p.prosecdef from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'engagement_visits_90d')        as is_invoker,
  (select p.provolatile = 's' from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'engagement_visits_90d')        as is_stable,
  (select has_function_privilege('authenticated',
          'public.engagement_visits_90d(int)', 'execute'))                     as authenticated_can_exec,
  (select not has_function_privilege('anon',
          'public.engagement_visits_90d(int)', 'execute'))                     as anon_cannot_exec,
  case when
       (select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace
         where n.nspname = 'public' and p.proname = 'engagement_visits_90d') = 1
   and (select not p.prosecdef from pg_proc p join pg_namespace n on n.oid = p.pronamespace
         where n.nspname = 'public' and p.proname = 'engagement_visits_90d')
   and (select p.provolatile = 's' from pg_proc p join pg_namespace n on n.oid = p.pronamespace
         where n.nspname = 'public' and p.proname = 'engagement_visits_90d')
   and (select has_function_privilege('authenticated',
          'public.engagement_visits_90d(int)', 'execute'))
   and (select not has_function_privilege('anon',
          'public.engagement_visits_90d(int)', 'execute'))
  then 'PASS' else 'FAIL' end                                                  as all_ok;
