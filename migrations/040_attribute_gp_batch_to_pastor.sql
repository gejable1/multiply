-- migrations/040_attribute_gp_batch_to_pastor.sql
-- The 8 General Purpose Batch (IYM/PID) 'Unknown' rows were all logged by the
-- pastor; ministry batches aren't LCL-traceable, so attribute them explicitly.
update attendance a
set logged_by    = m.name,
    logged_by_id = m.id,
    updated_at   = now()
from members m
where m.id = '547ebda6-5126-436e-9890-709f50588ced'
  and a.logged_by = 'Unknown'
  and a.event_type = 'General Purpose Batch';

insert into public.schema_migrations (version, filename, note) values
  ('040','040_attribute_gp_batch_to_pastor.sql','attribute the 8 Unknown General Purpose Batch (IYM/PID) rows to the pastor (547ebda6) who logged them')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

select
  case when event_type='General Purpose Batch' then 'ministry/GP'
       else 'LC-scoped' end as bucket,
  count(*) as rows
from attendance where logged_by='Unknown'
group by 1
order by rows desc;
