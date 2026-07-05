-- ============================================================================
-- 059_pathway_rungs_meta.sql   ·   Session 58
-- Add a structured `meta jsonb` column to pathway_rungs for rich chip metadata.
--
-- Why: the per-church pipeline authoring surface (MD, L5) lets a pastor enrich a
-- chip (book / training / event / song / movie / ministry / etc.) with
-- AI-researched detail. The short caption stays in description_en/description_tl;
-- the structured payload lives here so the diagram's click-through modal can
-- render it and future rollups (reading-hours per level, filters) stay cheap.
--
-- Conventional keys the authoring UI writes (all optional, absence-tolerant):
--   author, source_type, duration, key_takeaways[], scripture_refs[],
--   external_url, six_sources[] (Grenny — 6 Sources of Influence), builds
--   ('character'|'competency'), ai_researched_at, ai_source (which AI produced it)
--
-- Single additive, non-breaking column; '{}'::jsonb is a NON-VOLATILE default, so
-- on an existing populated table this is a fast metadata-only add (no rewrite).
--
-- FLAT (#209), rerun-safe / IF NOT EXISTS (#210), committed to migrations/ right
-- after running (#242/#252). RLS is UNCHANGED — pathway_rungs already carries the
-- correct base/overlay policies; we do NOT touch RLS on an existing live table.
-- Column verified ABSENT in schema.json before authoring (#223).
-- ============================================================================

alter table public.pathway_rungs
  add column if not exists meta jsonb not null default '{}'::jsonb;

-- ----------------------------------------------------------------------------
-- LEDGER (#212)
-- ----------------------------------------------------------------------------
insert into public.schema_migrations (version, filename, applied_at, note)
values ('059','059_pathway_rungs_meta.sql', now(),
        'Add meta jsonb to pathway_rungs — structured chip metadata (author, source_type, duration, key_takeaways, scripture_refs, external_url, six_sources, builds, ai_researched_at) for the L5 pipeline authoring surface + AI-research chip enrichment')
on conflict (version) do nothing;

-- ----------------------------------------------------------------------------
-- SELF-VERIFY (#210) — rerun until every value below is as expected.
--   Expect: meta_col = 1, meta_type = 'jsonb', meta_notnull = t,
--           meta_default = '{}'::jsonb
-- ----------------------------------------------------------------------------
select
  (select count(*) from information_schema.columns
     where table_schema='public' and table_name='pathway_rungs' and column_name='meta')  as meta_col,
  (select data_type from information_schema.columns
     where table_schema='public' and table_name='pathway_rungs' and column_name='meta')  as meta_type,
  (select is_nullable = 'NO' from information_schema.columns
     where table_schema='public' and table_name='pathway_rungs' and column_name='meta')  as meta_notnull,
  (select column_default from information_schema.columns
     where table_schema='public' and table_name='pathway_rungs' and column_name='meta')  as meta_default;
