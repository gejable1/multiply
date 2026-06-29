-- migrations/039_backfill_attendance_logged_by.sql
-- One-time: attribute LC-scoped 'Unknown' attendance rows to the subject's LCL
-- (= subject.discipler_id). Excludes General Purpose Batch (ministry-logged,
-- not traceable via LCL), no-discipler subjects, and self-discipled (top-of-tree).
-- The going-forward fix (PR #60, _liveLeaderIdName) stops new 'Unknown' at source.

update attendance a
set logged_by    = disc.name,
    logged_by_id = disc.id,
    updated_at   = now()
from members subj
join members disc on disc.id = subj.discipler_id
where a.member_id = subj.id
  and a.logged_by = 'Unknown'
  and a.event_type <> 'General Purpose Batch'
  and subj.discipler_id is not null
  and subj.discipler_id <> subj.id
  and coalesce(disc.name,'') <> '';

insert into public.schema_migrations (version, filename, note) values
  ('039','039_backfill_attendance_logged_by.sql','backfill LC-scoped Unknown attendance recorders to subject discipler (LCL); excludes GP batch, no-discipler, self-discipled')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

select
  case when event_type='General Purpose Batch' then 'ministry/GP (left as-is)'
       else 'LC-scoped still Unknown (no discipler / self / unnamed)' end as bucket,
  count(*) as rows
from attendance where logged_by='Unknown'
group by 1
order by rows desc;
