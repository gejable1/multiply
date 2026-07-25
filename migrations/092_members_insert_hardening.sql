-- migrations/092_members_insert_hardening.sql
-- SECURITY. Session 81. Closes the last self-escalation hole in `members`.
--
-- BACKGROUND. Migration 050 hardened DELETE (pastor-only) and UPDATE (a BEFORE
-- UPDATE trigger locks the privilege columns against non-pastors). INSERT was
-- never hardened: `members_insert_own_church` checked ONLY `church_id`. So any
-- authenticated member could INSERT a brand-new row with pipeline_level = 5 and
-- is_platform_admin = true and a NULL member_pin_hash, then call the auth-login
-- `set_pin` action (first-login-only, so a NULL hash accepts it), then log in as
-- that identity. Two escalations in one:
--   (a) instant L5 pastor of their own church, and
--   (b) is_platform_admin = true, which is the ONLY gate on the catalog-publish
--       Edge Function -- the BASE (church_id IS NULL) curriculum lane shared by
--       every tenant church. A church-scoped account could rewrite the global
--       catalog for all of them.
-- Both proven to SUCCEED today on ephemeral PG16 against a faithful replica of
-- the live policy/trigger set, and to be blocked after this migration (#379).
--
-- SECOND HOLE, found while proving the first. The 050 trigger returns early for
-- `auth_level() >= 5`, so is_platform_admin was writable by ANY of the tenant
-- pastors -- a per-church role granting a PLATFORM-wide capability. No app path
-- writes that column (audited: the only three `members` write paths in the repo
-- are MLT saveNewMember and the MD / legacy-MD `l2r` upserts; none send it;
-- migration 036 seeded it by direct SQL). It is now settable ONLY with no JWT
-- (service-role / SQL editor), on INSERT and UPDATE alike.
--
-- WHY THE LEVEL RULE LIVES IN THE TRIGGER, NOT THE POLICY. MD saves members with
-- an upsert (onConflict:'id'). PostgreSQL applies an INSERT policy's WITH CHECK
-- to the row PROPOSED for insertion even when ON CONFLICT resolves to an UPDATE
-- (verified empirically on PG16 -- a policy-side level rule rejected an L3 coach
-- saving the L5 pastor's profile). The trigger can tell the two apart: if a row
-- with that id already exists, the write is really an edit and the UPDATE rules
-- govern it. The trigger also raises a readable message instead of the opaque
-- "new row violates row-level security policy". is_platform_admin is checked in
-- BOTH walls -- it is the crown jewel and no client sends it.
--
-- THE LEVEL RULE: a non-pastor may create a member strictly BELOW their own
-- level. This is exactly the doctrine the clients already implement (MLT caps an
-- L2 LCL at L1 and comments "creating an L2 is pastoral promotion territory";
-- L3+ keep the full dropdown, i.e. up to L2), now enforced server-side where
-- DevTools cannot reach. L5 is unrestricted. Making a leader stays a pastoral act.
--
-- Flat (#209), idempotent, self-verifying (#210), ledger-stamped.

-- (1) INSERT policy: church scope + no platform-admin minting. No level rule
--     here, per the ON CONFLICT note above.
drop policy if exists members_insert_own_church on public.members;
create policy members_insert_own_church on public.members
  for insert to authenticated
  with check (
    church_id = public.auth_church_id()
    and coalesce(is_platform_admin, false) = false
  );

-- (2) One guard function for both verbs -- all privilege doctrine in one place.
create or replace function public.members_guard_privilege_cols()
returns trigger language plpgsql
set search_path = public, pg_temp
as $$
begin
  -- service-role / EF / SQL editor (no JWT): unrestricted, as before.
  if auth_church_id() is null then
    return new;
  end if;

  if tg_op = 'INSERT' then
    -- An upsert's proposed row reaches BEFORE INSERT even when ON CONFLICT
    -- resolves to UPDATE. If the id already exists this is really an edit, so
    -- let the UPDATE branch below govern it.
    if new.id is not null and exists (select 1 from public.members m where m.id = new.id) then
      return new;
    end if;
    if coalesce(new.is_platform_admin, false) then
      raise exception 'members: is_platform_admin is not settable from the app';
    end if;
    if auth_level() < 5 and coalesce(new.pipeline_level, 0) >= auth_level() then
      raise exception 'members: you may only add members below your own level (yours: %, requested: %)',
        auth_level(), coalesce(new.pipeline_level, 0);
    end if;
    return new;
  end if;

  -- UPDATE. Platform admin is a PLATFORM capability, not a church one: no JWT
  -- may change it, pastors included.
  if new.is_platform_admin is distinct from old.is_platform_admin then
    raise exception 'members: is_platform_admin is not settable from the app';
  end if;

  if auth_level() >= 5 then
    return new;
  end if;

  if (new.pipeline_level     is distinct from old.pipeline_level)
     or (new.is_facilitator   is distinct from old.is_facilitator)
     or (new.facilitator_role is distinct from old.facilitator_role) then
    raise exception 'members: only the pastor can change level/role/admin fields';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_members_guard_privilege on public.members;
create trigger trg_members_guard_privilege
  before insert or update on public.members
  for each row execute function public.members_guard_privilege_cols();

-- (3) Pin search_path on the sibling trigger function too (091). No behaviour
--     change; it removes the search_path resolution surface on a security-
--     relevant trigger (is_facilitator is what auth_is_leader() reads, #385).
alter function public.members_derive_facilitator() set search_path = public, pg_temp;

-- (4) Tidy: the 050 rewrite dropped the role list, leaving DELETE as TO public.
--     The USING clause already blocks anon (auth_level() = 0); this only makes
--     the policy set uniform.
drop policy if exists members_delete_own_church on public.members;
create policy members_delete_own_church on public.members
  for delete to authenticated
  using (church_id = public.auth_church_id() and public.auth_level() >= 5);

-- ledger
insert into public.schema_migrations (version, filename, note) values
  ('092','092_members_insert_hardening.sql','SECURITY: members INSERT level rule (upsert-aware trigger) + is_platform_admin locked against all JWTs in policy and trigger; search_path pinned on both member triggers')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

-- SELF-VERIFY -- every column must read true.
select
  (select count(*) from pg_policies
     where schemaname='public' and tablename='members' and cmd='INSERT'
       and with_check ilike '%is_platform_admin%') = 1                               as insert_policy_hardened,
  (select count(*) from pg_policies
     where schemaname='public' and tablename='members' and cmd='DELETE'
       and qual ilike '%auth_level%') = 1                                            as delete_still_pastor_only,
  (select prosrc ilike '%below your own level%'
     from pg_proc where proname='members_guard_privilege_cols')                       as insert_level_rule_present,
  (select prosrc ilike '%is_platform_admin is not settable%'
     from pg_proc where proname='members_guard_privilege_cols')                       as platform_admin_locked,
  (select 'search_path=public, pg_temp' = any(proconfig)
     from pg_proc where proname='members_guard_privilege_cols')                       as guard_search_path_pinned,
  (select 'search_path=public, pg_temp' = any(proconfig)
     from pg_proc where proname='members_derive_facilitator')                         as derive_search_path_pinned,
  (select count(*) from pg_trigger
     where tgname='trg_members_guard_privilege' and not tgisinternal
       and (tgtype & 4) = 4 and (tgtype & 16) = 16) = 1                               as guard_fires_on_insert_and_update,
  (select count(*) from pg_policies
     where schemaname='public' and tablename='members') = 4                           as four_policies;
