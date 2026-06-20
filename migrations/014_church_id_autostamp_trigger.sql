-- migrations/014_church_id_autostamp_trigger.sql
-- Phase 2 · church_id-on-insert via BEFORE INSERT trigger. ADDITIVE + IDEMPOTENT. RLS stays OFF.
-- Sets church_id from the authenticated request's JWT claim only when left NULL.

-- 1) trigger function
create or replace function public.set_church_id_from_jwt()
returns trigger language plpgsql as $$
begin
  if new.church_id is null then
    new.church_id := public.auth_church_id();
  end if;
  return new;
end $$;

-- 2) attach to every per-church table (has church_id), EXCEPT devotionals (NULL=shared) + backups
do $$
declare t text;
begin
  for t in
    select c.table_name
    from information_schema.columns c
    join information_schema.tables tb
      on tb.table_schema=c.table_schema and tb.table_name=c.table_name
    where c.table_schema='public' and c.column_name='church_id'
      and tb.table_type='BASE TABLE'
      and c.table_name <> 'devotionals'
      and c.table_name not like '\_backup%'
  loop
    execute format('drop trigger if exists trg_set_church_id on public.%I', t);
    execute format(
      'create trigger trg_set_church_id before insert on public.%I
         for each row execute function public.set_church_id_from_jwt()', t);
  end loop;
end $$;
