-- Phase 2 · Step-1 groundwork. ADDITIVE + IDEMPOTENT. RLS stays OFF.
-- JWT-claim reader helpers that future RLS policies will call. Changes NO table
-- data, enables NO policy. RUN by the Pastor this session as a standalone block;
-- this file records it.
create or replace function public.auth_church_id()
returns uuid language sql stable as $$
  select nullif(current_setting('request.jwt.claims', true)::jsonb ->> 'church_id','')::uuid
$$;

create or replace function public.auth_member_id()
returns uuid language sql stable as $$
  select nullif(current_setting('request.jwt.claims', true)::jsonb ->> 'sub','')::uuid
$$;

create or replace function public.auth_level()
returns int language sql stable as $$
  select coalesce(nullif(current_setting('request.jwt.claims', true)::jsonb ->> 'leader_level','')::int, 0)
$$;

grant execute on function public.auth_church_id() to anon, authenticated;
grant execute on function public.auth_member_id() to anon, authenticated;
grant execute on function public.auth_level()     to anon, authenticated;
-- VERIFY (no JWT in the SQL editor → all NULL/0, which is correct):
-- select public.auth_church_id() AS church, public.auth_member_id() AS mem, public.auth_level() AS lvl;
