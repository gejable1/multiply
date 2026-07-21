-- 081_app_sessions_unified.sql
-- S78 telemetry rebuild: one unified session logbook for ALL logins
-- (members + leaders), replacing the leader-only leader_sessions.
-- Additive, flat (no DO blocks), rerunnable, self-verifying.
--
-- Backfills existing leader_sessions rows (is_leader = true). Does NOT drop
-- leader_sessions - that is the final step (migration 082), to be run only
-- after both Edge Functions are redeployed AND the frontend logout-repoint
-- PR is live. Ledger: Session 78 - app_sessions + reap_expired_sessions().

create table if not exists public.app_sessions (
  id               uuid primary key default gen_random_uuid(),
  member_id        uuid references public.members(id) on delete cascade,
  is_leader        boolean not null default false,
  church_id        uuid references public.churches(id),
  created_at       timestamptz not null default now(),
  expires_at       timestamptz not null,
  ended_at         timestamptz,
  ended_reason     text,
  user_agent_hint  text
);

-- Indexes: active-session lookups, tenant scoping, per-member history, reaper.
create index if not exists idx_app_sessions_active
  on public.app_sessions (member_id) where ended_at is null;
create index if not exists idx_app_sessions_church
  on public.app_sessions (church_id);
create index if not exists idx_app_sessions_member_created
  on public.app_sessions (member_id, created_at desc);
create index if not exists idx_app_sessions_reap
  on public.app_sessions (expires_at) where ended_at is null;

-- RLS: tenant-scoped, mirroring leader_sessions. The EF writes via the service
-- role (bypasses RLS); these policies scope any future authenticated reads.
alter table public.app_sessions enable row level security;

drop policy if exists app_sessions_tenant_select on public.app_sessions;
create policy app_sessions_tenant_select on public.app_sessions
  for select to authenticated using (church_id = auth_church_id());

drop policy if exists app_sessions_tenant_insert on public.app_sessions;
create policy app_sessions_tenant_insert on public.app_sessions
  for insert to authenticated with check (church_id = auth_church_id());

drop policy if exists app_sessions_tenant_update on public.app_sessions;
create policy app_sessions_tenant_update on public.app_sessions
  for update to authenticated using (church_id = auth_church_id())
  with check (church_id = auth_church_id());

drop policy if exists app_sessions_tenant_delete on public.app_sessions;
create policy app_sessions_tenant_delete on public.app_sessions
  for delete to authenticated using (church_id = auth_church_id());

-- Reaper: close any session past its expiry. Reusable by the EF (rpc,
-- opportunistic on each login) and by a future pg_cron schedule.
create or replace function public.reap_expired_sessions()
returns integer
language sql
security definer
set search_path = public
as $$
  with reaped as (
    update public.app_sessions
       set ended_at = now(), ended_reason = 'expired'
     where ended_at is null and expires_at < now()
     returning 1
  )
  select count(*)::int from reaped;
$$;

-- Backfill historical leader_sessions rows (all were leaders). Dedup on
-- (member_id, created_at) with null-safe matching so a rerun never
-- double-inserts.
insert into public.app_sessions
  (member_id, is_leader, church_id, created_at, expires_at, ended_at, ended_reason, user_agent_hint)
select ls.leader_id, true, ls.church_id, ls.created_at, ls.expires_at,
       ls.ended_at, ls.ended_reason, ls.user_agent_hint
  from public.leader_sessions ls
 where not exists (
   select 1 from public.app_sessions a
    where a.member_id is not distinct from ls.leader_id
      and a.created_at = ls.created_at
 );

-- Self-verify: table + reaper exist, and every leader_sessions row has a
-- matching app_sessions row (backfill complete). Returns a single TRUE.
select
  (to_regclass('public.app_sessions') is not null)
  and exists (select 1 from pg_proc where proname = 'reap_expired_sessions')
  and not exists (
    select 1 from public.leader_sessions ls
    where not exists (
      select 1 from public.app_sessions a
      where a.member_id is not distinct from ls.leader_id
        and a.created_at = ls.created_at
    )
  ) as ok;
