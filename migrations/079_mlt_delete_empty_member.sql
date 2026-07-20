-- 079_mlt_delete_empty_member.sql
-- Empty-only guarded member delete for LCLs (the duplicate-name case).
-- An LCL may delete a member ONLY IF that member has zero non-telemetry
-- footprint anywhere in the schema (i.e. a fresh duplicate with no history).
-- Catalog-driven: scans every live FK into public.members, so new tables are
-- auto-covered. Blocks on ANY formation/record row; ignores pure telemetry
-- (view-log, sessions, tokens, notifications, ack/dismissal, open-log,
-- self-attest-log) and pre-clears the NO-ACTION telemetry rows so a clean
-- delete cannot FK-fail. Returns jsonb the client turns into a friendly message.
-- SECURITY DEFINER: does its OWN authorization via auth_member_id().
-- Flat, idempotent (create or replace), self-verifying.
-- NOTE: auth_* helpers return NULL in the SQL editor (no JWT), so this can only
--       be exercised end-to-end in-browser with a live leader login.

create or replace function public.mlt_delete_empty_member(p_member_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $fn$
declare
  v_caller       uuid    := public.auth_member_id();
  v_church       uuid    := public.auth_church_id();
  v_caller_admin boolean := false;
  v_name         text;
  v_disc         uuid;
  v_tchurch      uuid;
  v_fk           record;
  v_cnt          bigint;
  v_blockers     jsonb   := '[]'::jsonb;
  v_cleanup      jsonb   := '[]'::jsonb;
  v_clean        jsonb;
  -- tables whose references are pure telemetry: never block a delete
  v_skip_tables  text[]  := array[
    'view_log','leader_sessions','profile_tokens','notifications',
    'announcement_acks','announcement_retraction_dismissals',
    'prayer_list_opens','attendance_self_attest_log'
  ];
begin
  -- must be a logged-in caller
  if v_caller is null then
    return jsonb_build_object('ok', false, 'reason', 'no_session');
  end if;

  -- target must exist
  select name, discipler_id, church_id
    into v_name, v_disc, v_tchurch
    from public.members
   where id = p_member_id;
  if v_name is null then
    return jsonb_build_object('ok', false, 'reason', 'not_found');
  end if;

  -- never delete yourself
  if p_member_id = v_caller then
    return jsonb_build_object('ok', false, 'reason', 'cannot_delete_self', 'name', v_name);
  end if;

  select coalesce(is_platform_admin, false)
    into v_caller_admin
    from public.members
   where id = v_caller;

  -- scope: caller is the target's own discipler, OR a platform admin
  if not (v_disc = v_caller or v_caller_admin) then
    return jsonb_build_object('ok', false, 'reason', 'not_your_member', 'name', v_name);
  end if;

  -- tenancy belt-and-braces (cross-church deletes go through MD)
  if v_church is not null and v_tchurch is distinct from v_church then
    return jsonb_build_object('ok', false, 'reason', 'wrong_church', 'name', v_name);
  end if;

  -- catalog-driven scan of every inbound FK into members
  for v_fk in
    select ns.nspname   as sch,
           cl.relname   as tbl,
           att.attname  as col,
           con.confdeltype as deltype
      from pg_constraint con
      join pg_class     cl  on cl.oid  = con.conrelid
      join pg_namespace ns  on ns.oid  = cl.relnamespace
      join pg_class     rcl on rcl.oid = con.confrelid
      join pg_namespace rns on rns.oid = rcl.relnamespace
      join lateral unnest(con.conkey) as k(attnum) on true
      join pg_attribute att on att.attrelid = con.conrelid and att.attnum = k.attnum
     where con.contype = 'f'
       and rns.nspname = 'public'
       and rcl.relname = 'members'
  loop
    if v_fk.tbl = any(v_skip_tables) then
      -- telemetry: never blocks; queue NO-ACTION/RESTRICT rows for pre-clear
      if v_fk.deltype in ('a','r') then
        v_cleanup := v_cleanup || jsonb_build_object('sch', v_fk.sch, 'tbl', v_fk.tbl, 'col', v_fk.col);
      end if;
      continue;
    end if;

    -- any non-telemetry footprint blocks deletion
    execute format('select count(*) from %I.%I where %I = $1', v_fk.sch, v_fk.tbl, v_fk.col)
      into v_cnt using p_member_id;
    if v_cnt > 0 then
      v_blockers := v_blockers || jsonb_build_object('table', v_fk.tbl, 'count', v_cnt);
    end if;
  end loop;

  if jsonb_array_length(v_blockers) > 0 then
    return jsonb_build_object('ok', false, 'reason', 'has_history', 'name', v_name, 'blockers', v_blockers);
  end if;

  -- clean disposable NO-ACTION telemetry, then delete the empty member
  for v_clean in select * from jsonb_array_elements(v_cleanup)
  loop
    execute format('delete from %I.%I where %I = $1',
                   v_clean->>'sch', v_clean->>'tbl', v_clean->>'col') using p_member_id;
  end loop;

  delete from public.members where id = p_member_id;

  return jsonb_build_object('ok', true, 'name', v_name);
end;
$fn$;

grant execute on function public.mlt_delete_empty_member(uuid) to anon, authenticated;

-- self-verify: expect fn_exists = t, can_exec = t
select
  (to_regprocedure('public.mlt_delete_empty_member(uuid)') is not null) as fn_exists,
  has_function_privilege('authenticated', 'public.mlt_delete_empty_member(uuid)', 'execute') as can_exec;
