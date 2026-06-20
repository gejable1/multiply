-- migrations/014_rollback.sql  (rollback for 014_church_id_autostamp_trigger.sql)
-- Removes the auto-stamp trigger from every per-church table, then drops the
-- trigger function. Idempotent. Mirrors 014's table selection exactly so the
-- same set is reached (devotionals + backups were never attached).
-- NOTE: does NOT alter any church_id data already stamped — drop-only.

-- 1) detach the trigger from every table that has church_id
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
  end loop;
end $$;

-- 2) drop the trigger function
drop function if exists public.set_church_id_from_jwt();
