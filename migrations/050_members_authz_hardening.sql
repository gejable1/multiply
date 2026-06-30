-- migrations/050_members_authz_hardening.sql
-- SECURITY HOTFIX. members RLS was tenant-scoped with NO level check, so ANY
-- authenticated member of a church could (1) DELETE every member row, and
-- (2) UPDATE their own pipeline_level/is_platform_admin/is_facilitator and
-- re-login as pastor. This closes both. FLAT, idempotent, ledger-stamped,
-- self-verifying. Service-role/EF calls carry no JWT (auth_church_id() is null)
-- so they're unaffected; pastors (auth_level() >= 5) retain full control.

-- (1) DELETE -> pastor-only (was: church_id = auth_church_id(), no level check)
drop policy if exists members_delete_own_church on public.members;
create policy members_delete_own_church on public.members
  for delete
  using (church_id = auth_church_id() and auth_level() >= 5);

-- (2) Privilege-column lock: a logged-in non-pastor may not CHANGE the columns
--     that determine level/admin status. Same-value writes pass (is distinct
--     from), so profile self-edit and assessment saves are unaffected.
create or replace function public.members_guard_privilege_cols()
returns trigger language plpgsql as $$
begin
  if auth_church_id() is null or auth_level() >= 5 then
    return new;  -- service-role/EF (no JWT) or pastor: unrestricted
  end if;
  if (new.is_platform_admin is distinct from old.is_platform_admin)
     or (new.pipeline_level   is distinct from old.pipeline_level)
     or (new.is_facilitator   is distinct from old.is_facilitator)
     or (new.facilitator_role is distinct from old.facilitator_role) then
    raise exception 'members: only the pastor can change level/role/admin fields';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_members_guard_privilege on public.members;
create trigger trg_members_guard_privilege
  before update on public.members
  for each row execute function public.members_guard_privilege_cols();

-- ledger
insert into public.schema_migrations (version, filename, note) values
  ('050','050_members_authz_hardening.sql','SECURITY: members DELETE -> pastor-only; lock privilege cols vs non-pastor UPDATE')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

-- SELF-VERIFY — expect delete_has_level_check=1 AND guard_trigger=1
select
  (select count(*) from pg_policies
     where schemaname='public' and tablename='members' and cmd='DELETE'
       and qual ilike '%auth_level%') as delete_has_level_check,
  (select count(*) from pg_trigger
     where tgname='trg_members_guard_privilege' and not tgisinternal) as guard_trigger;
