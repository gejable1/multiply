-- migrations/052_devotionals_unique_per_church.sql
-- Session 55 — FIX: devotionals uniqueness was tenancy-blind. Inv #218.
--
-- ROOT CAUSE of the "Save failed" error in devotional_admin.html for non-Rosehill
-- pastors: the table carried UNIQUE INDEX `devotionals_entry_date_key` on
-- (entry_date) ALONE — a single global row per calendar date across ALL churches.
-- A UNIQUE index is enforced over EVERY row regardless of RLS, so when a second
-- church tries to insert a devotional for a date another church already occupies,
-- Postgres raises 23505 (duplicate key) — for a row the pastor cannot even SEE
-- (RLS hides it). devotional_admin builds `entriesByDate` from an RLS-scoped
-- SELECT, so `existing` is undefined for the hidden cross-church row and the code
-- takes the blind INSERT branch → the collision. Symptom matches exactly:
-- "0 entries" for the viewer's church + save fails.
--
-- FIX: drop the tenancy-blind unique, add the composite UNIQUE(church_id, entry_date)
-- required by Inv #218. Each church keeps at most one devotional per date; two
-- churches may now share a date. No frontend change needed — the insert/update paths
-- already scope by the viewer's own (RLS-filtered) rows.
--
-- SAFE: entry_date was globally unique before, so (church_id, entry_date) is trivially
-- unique already — the new index cannot fail on existing data.
-- RUN FLAT (no BEGIN/COMMIT) — Inv #209. Idempotent — Inv #210.

-- 1) drop the tenancy-blind unique index
DROP INDEX IF EXISTS public.devotionals_entry_date_key;

-- 2) composite per-church unique (Inv #218)
CREATE UNIQUE INDEX IF NOT EXISTS devotionals_church_entry_date_key
  ON public.devotionals (church_id, entry_date);

-- 3) ledger self-stamp
INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('052','052_devotionals_unique_per_church.sql','FIX devotionals uniqueness: drop global UNIQUE(entry_date), add UNIQUE(church_id, entry_date) — Inv #218; unblocks multi-church devotional saves')
ON CONFLICT (version) DO UPDATE SET filename=EXCLUDED.filename, note=EXCLUDED.note, applied_at=now();

-- SELF-VERIFY — expect old_gone=0, composite_present=1, and NO duplicate (church_id, entry_date)
SELECT
  (SELECT count(*) FROM pg_indexes
     WHERE schemaname='public' AND tablename='devotionals'
       AND indexname='devotionals_entry_date_key')            AS old_index_gone_should_be_0,
  (SELECT count(*) FROM pg_indexes
     WHERE schemaname='public' AND tablename='devotionals'
       AND indexname='devotionals_church_entry_date_key')     AS composite_present_should_be_1,
  (SELECT count(*) FROM (
     SELECT church_id, entry_date FROM public.devotionals
     GROUP BY church_id, entry_date HAVING count(*) > 1
   ) d)                                                        AS dup_pairs_should_be_0;
