-- 082_drop_leader_sessions.sql
-- S78 telemetry rebuild - final step. leader_sessions is superseded by the
-- unified app_sessions (migration 081). By this point BOTH Edge Functions
-- (auth-login, token-login) and the frontend (logoutLeader + MD pin-reset,
-- ?v=12) write/close app_sessions only; leader_sessions has zero code
-- readers/writers and zero inbound FKs. Flat (single guarded DO block),
-- rerunnable, self-verifying. Ledger: Session 78 - drop leader_sessions
-- (originally created in migrations 026/027).

-- Guarded so the whole step is a clean no-op once the table is gone (rerun
-- safe). While the table still exists: re-backfill any rows created AFTER
-- migration 081's backfill (e.g. logins on the old EF before its redeploy),
-- null-safe dedup on (member_id, created_at) so nothing is lost, then drop.
do $$
begin
  if to_regclass('public.leader_sessions') is not null then
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
    drop table public.leader_sessions;
  end if;
end $$;

-- Self-verify: the table is gone. Returns a single TRUE.
select to_regclass('public.leader_sessions') is null as ok;
