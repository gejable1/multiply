-- 078_lc_meeting_guides_source.sql
-- Generalize the Meeting Prep source: devotional | btli | custom.
-- Additive, flat, rerunnable, self-verifying.

alter table public.lc_meeting_guides add column if not exists source_kind  text;
alter table public.lc_meeting_guides add column if not exists source_title text;
alter table public.lc_meeting_guides add column if not exists source_text  text;

-- existing rows are devotional-sourced
update public.lc_meeting_guides set source_kind = 'devotional' where source_kind is null;

alter table public.lc_meeting_guides alter column source_kind set default 'devotional';
alter table public.lc_meeting_guides alter column source_kind set not null;

-- guard the check so a rerun never errors
do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'lc_meeting_guides_source_kind_check') then
    alter table public.lc_meeting_guides
      add constraint lc_meeting_guides_source_kind_check
      check (source_kind in ('devotional','btli','custom'));
  end if;
end $$;

-- self-verify: expect cols_added = 3, check_present = 1
select
  (select count(*) from information_schema.columns
     where table_schema='public' and table_name='lc_meeting_guides'
       and column_name in ('source_kind','source_title','source_text')) as cols_added,
  (select count(*) from pg_constraint
     where conname='lc_meeting_guides_source_kind_check') as check_present;
