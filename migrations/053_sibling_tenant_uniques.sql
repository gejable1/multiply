-- 053_sibling_tenant_uniques.sql
-- Same bug class as 052: single-column UNIQUEs on per-church tables that ignore
-- church_id, letting the first church to use a value block every other church.
-- Confirmed per-church by the pastor. Each -> tenant-scoped composite.
--   wednesday_preaching: UNIQUE(preach_date) -> UNIQUE(church_id, preach_date)
--   ministries:          UNIQUE(name)        -> UNIQUE(church_id, name)
--   preachers:           UNIQUE(sequence)    -> UNIQUE(church_id, sequence)
--   (preachers.member_id unique stays as-is: a member maps to one church.)

-- wednesday_preaching
ALTER TABLE public.wednesday_preaching DROP CONSTRAINT IF EXISTS wednesday_preaching_date_unique;
DROP INDEX IF EXISTS public.wednesday_preaching_date_unique;
ALTER TABLE public.wednesday_preaching ADD CONSTRAINT wednesday_preaching_church_date_unique UNIQUE (church_id, preach_date);

-- ministries
ALTER TABLE public.ministries DROP CONSTRAINT IF EXISTS ministries_name_key;
DROP INDEX IF EXISTS public.ministries_name_key;
ALTER TABLE public.ministries ADD CONSTRAINT ministries_church_name_key UNIQUE (church_id, name);

-- preachers
ALTER TABLE public.preachers DROP CONSTRAINT IF EXISTS preachers_sequence_unique;
DROP INDEX IF EXISTS public.preachers_sequence_unique;
ALTER TABLE public.preachers ADD CONSTRAINT preachers_church_sequence_unique UNIQUE (church_id, sequence);

INSERT INTO public.schema_migrations (version, filename, note)
VALUES (
  '053_sibling_tenant_uniques',
  '053_sibling_tenant_uniques.sql',
  'Tenant-scope sibling uniques: wednesday_preaching(preach_date), ministries(name), preachers(sequence) -> composite with church_id.'
)
ON CONFLICT (version) DO NOTHING;

-- self-verify: expect every _old = 0 and every _new = 1. Rerun until true.
SELECT
  (SELECT count(*) FROM pg_constraint WHERE conname='wednesday_preaching_date_unique')       AS wp_old_0,
  (SELECT count(*) FROM pg_constraint WHERE conname='wednesday_preaching_church_date_unique') AS wp_new_1,
  (SELECT count(*) FROM pg_constraint WHERE conname='ministries_name_key')                    AS min_old_0,
  (SELECT count(*) FROM pg_constraint WHERE conname='ministries_church_name_key')             AS min_new_1,
  (SELECT count(*) FROM pg_constraint WHERE conname='preachers_sequence_unique')              AS pr_old_0,
  (SELECT count(*) FROM pg_constraint WHERE conname='preachers_church_sequence_unique')       AS pr_new_1;
