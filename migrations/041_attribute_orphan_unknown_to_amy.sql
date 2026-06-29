-- migrations/041_attribute_orphan_unknown_to_amy.sql
-- The last 'Unknown' attendance row belongs to a since-removed member in Amy's
-- LCG (Prayer Meeting, 2026-06-17); the LCL trace had no live member row to
-- follow. Pastor-confirmed Amy Franco logged it — attribute that single row.
update attendance
set logged_by    = 'Amy Franco',
    logged_by_id = '49dae17b-c9c8-4dee-ae2f-2f7df6d9eedc',
    updated_at   = now()
where logged_by = 'Unknown';

insert into public.schema_migrations (version, filename, note) values
  ('041','041_attribute_orphan_unknown_to_amy.sql','attribute the final Unknown attendance row (removed-member subject, Amy''s LCG, Prayer Meeting 2026-06-17) to Amy Franco')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

select count(*) as unknown_remaining
from attendance where logged_by = 'Unknown';
