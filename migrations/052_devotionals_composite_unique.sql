-- 052_devotionals_composite_unique.sql
-- Tenant-scope the devotionals uniqueness. The old UNIQUE(entry_date) was a
-- single-church leftover; under multi-tenant it let the FIRST church to seed a
-- date block every OTHER church from ever using that date. Fix -> per-church.
-- Composite unique is strictly more permissive, so no existing row can violate it.

ALTER TABLE public.devotionals
  DROP CONSTRAINT IF EXISTS devotionals_entry_date_key;

DROP INDEX IF EXISTS public.devotionals_entry_date_key;

ALTER TABLE public.devotionals
  ADD CONSTRAINT devotionals_church_entry_date_key UNIQUE (church_id, entry_date);

INSERT INTO public.schema_migrations (version, filename, note)
VALUES (
  '052_devotionals_composite_unique',
  '052_devotionals_composite_unique.sql',
  'Tenant-scope devotionals unique: entry_date -> (church_id, entry_date). Fixes cross-church insert collisions.'
)
ON CONFLICT (version) DO NOTHING;

-- self-verify: expect old_should_be_0 = 0 and new_should_be_1 = 1. Rerun until true.
SELECT
  (SELECT count(*) FROM pg_constraint WHERE conname = 'devotionals_entry_date_key')       AS old_should_be_0,
  (SELECT count(*) FROM pg_constraint WHERE conname = 'devotionals_church_entry_date_key') AS new_should_be_1;
