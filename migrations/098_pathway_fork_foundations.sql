-- 098_pathway_fork_foundations.sql
-- Session 83. Pathway fork model, Phase 1 of 5 (PATHWAY_FORK_DESIGN.md section 10).
--
-- Adds the authoring surface and the retirement marker. NOTHING READS EITHER YET.
-- Zero user-visible change: no existing row is touched, no policy on an existing
-- table is altered, no reader is switched. The pastor sees nothing until Phase 4.
--
-- WHAT THIS DOES
--   1. pathway_rungs.retired_at  -- retire-never-delete marker (design section 9a).
--      NULL = live. Non-NULL = no longer part of the pathway, but still real, so a
--      member who completed it keeps seeing it. `published` keeps its own meaning
--      (draft visibility); the two are independent.
--   2. pathway_versions          -- the versioned JSON document that IS the pipeline.
--      Publishing regenerates that church's pathway_rungs + pathway_section_order
--      rows in one transaction, so every reader shipped in S82 keeps working.
--
-- WHAT THIS DELIBERATELY DOES NOT DO
--   The design doc (section 7) states pathway_rungs has NO unique constraint on
--   (church_id, level, rung_key) and that a double publish could duplicate a whole
--   pipeline. THAT IS WRONG, verified against schema.json on origin/main. The table
--   carries no unique *constraints*, but it carries two partial unique *indexes*
--   that already cover both lanes completely:
--       pathway_rungs_overlay_uk  UNIQUE (church_id, level, rung_key) WHERE church_id IS NOT NULL
--       pathway_rungs_base_uk     UNIQUE (level, rung_key)            WHERE church_id IS NULL
--   A double publish therefore CANNOT duplicate a church pipeline; it raises. The
--   S82 analysis read the `unique_constraints` array and stopped short of `indexes`.
--   Adding a plain table constraint on (church_id, level, rung_key) would be worse
--   than useless: UNIQUE treats NULLs as distinct, so it would leave the template
--   lane unprotected while duplicating a rule that already exists -- two copies of
--   one rule is exactly #405. No constraint is added here.
--
--   NOTE FOR PHASE 4: because the covering index is PARTIAL, the publish upsert
--   must spell the predicate out for inference to work:
--       INSERT ... ON CONFLICT (church_id, level, rung_key) WHERE church_id IS NOT NULL
--   Omitting the WHERE clause raises "no unique or exclusion constraint matching".
--
--   The template_generation counter named in design section 10 is NOT created.
--   Its only job is to answer "which template rungs are new since this church
--   forked", and pathway_rungs.created_at already answers that exactly. A counter
--   would need a per-rung generation stamp to be useful, i.e. a second source of
--   truth for a fact the row already carries. pathway_versions.template_synced_at
--   holds the fork/sync moment instead: new items = template rungs created after it.
--   No new global object, no coordination problem.
--
-- Flat (#209), idempotent, self-verifying on its own effects only (#403),
-- stamped in the body (#402). Proven on ephemeral PG16 as postgres (#379),
-- forward and on rerun, with RLS exercised as `authenticated` under simulated
-- JWT claims. Production is PostgreSQL 17.6; nothing here is version-sensitive.

-- 1. THE RETIREMENT MARKER ---------------------------------------------------

ALTER TABLE public.pathway_rungs
  ADD COLUMN IF NOT EXISTS retired_at timestamptz;

COMMENT ON COLUMN public.pathway_rungs.retired_at IS
  'Retire-never-delete marker. NULL = live rung. Non-NULL = removed from the pathway but still shown to members who completed it. Independent of published, which governs draft visibility. The progress denominator counts only live trackable rungs, so a retired completion never produces 7/6.';

-- 2. THE AUTHORING SURFACE ---------------------------------------------------

CREATE TABLE IF NOT EXISTS public.pathway_versions (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id          uuid NOT NULL REFERENCES public.churches(id) ON DELETE CASCADE,
  version_no         integer NOT NULL,
  status             text NOT NULL DEFAULT 'draft',
  doc                jsonb NOT NULL DEFAULT '{}'::jsonb,
  note               text,
  template_synced_at timestamptz,
  created_by         uuid REFERENCES public.members(id) ON DELETE SET NULL,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now(),
  published_at       timestamptz,
  CONSTRAINT pathway_versions_status_check
    CHECK (status = ANY (ARRAY['draft'::text,'published'::text,'archived'::text])),
  CONSTRAINT pathway_versions_version_no_check
    CHECK (version_no >= 1),
  CONSTRAINT pathway_versions_published_at_check
    CHECK (status <> 'published' OR published_at IS NOT NULL),
  CONSTRAINT pathway_versions_church_version_uk
    UNIQUE (church_id, version_no)
);

COMMENT ON TABLE public.pathway_versions IS
  'The versioned JSON document that IS a church pipeline. Publishing regenerates that church pathway_rungs and pathway_section_order rows in one transaction. Draft/publish, snapshots and restore all fall out of this one structure. Pastor-only: LCLs and members never read it.';

COMMENT ON COLUMN public.pathway_versions.template_synced_at IS
  'The moment this version last took stock of the shared template. Template rungs with created_at greater than this are the new items offered for per-item opt-in. Replaces the template_generation counter: the created_at already on the row is the same fact without a second source of truth.';

-- One draft and one published version per church (design sections 9.1 and 9.2).
-- Archived versions are unlimited: they are the snapshot history.
CREATE UNIQUE INDEX IF NOT EXISTS pathway_versions_one_draft_uk
  ON public.pathway_versions USING btree (church_id) WHERE (status = 'draft');

CREATE UNIQUE INDEX IF NOT EXISTS pathway_versions_one_published_uk
  ON public.pathway_versions USING btree (church_id) WHERE (status = 'published');

-- 3. RLS ---------------------------------------------------------------------
-- Same shape as pathway_rungs on the church lane, with one tightening: SELECT is
-- pastor-only too, because the draft is the pastor desk (design section 9.2) and a
-- gate that has no reason to be open fails closed (#406). Members and LCLs read
-- pathway_rungs, never this table.

ALTER TABLE public.pathway_versions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS pathway_versions_select ON public.pathway_versions;
CREATE POLICY pathway_versions_select ON public.pathway_versions
  FOR SELECT TO authenticated
  USING ((church_id = auth_church_id()) AND (auth_level() >= 5));

DROP POLICY IF EXISTS pathway_versions_insert ON public.pathway_versions;
CREATE POLICY pathway_versions_insert ON public.pathway_versions
  FOR INSERT TO authenticated
  WITH CHECK ((church_id = auth_church_id()) AND (auth_level() >= 5));

DROP POLICY IF EXISTS pathway_versions_update ON public.pathway_versions;
CREATE POLICY pathway_versions_update ON public.pathway_versions
  FOR UPDATE TO authenticated
  USING ((church_id = auth_church_id()) AND (auth_level() >= 5))
  WITH CHECK ((church_id = auth_church_id()) AND (auth_level() >= 5));

DROP POLICY IF EXISTS pathway_versions_delete ON public.pathway_versions;
CREATE POLICY pathway_versions_delete ON public.pathway_versions
  FOR DELETE TO authenticated
  USING ((church_id = auth_church_id()) AND (auth_level() >= 5));

-- 4. TRIGGERS ----------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_set_church_id ON public.pathway_versions;
CREATE TRIGGER trg_set_church_id
  BEFORE INSERT ON public.pathway_versions
  FOR EACH ROW EXECUTE FUNCTION public.set_church_id_from_jwt();

DROP TRIGGER IF EXISTS trg_pathway_versions_updated_at ON public.pathway_versions;
CREATE TRIGGER trg_pathway_versions_updated_at
  BEFORE UPDATE ON public.pathway_versions
  FOR EACH ROW EXECUTE FUNCTION public._set_updated_at();

-- STAMP THIS MIGRATION -------------------------------------------------------

INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('098','098_pathway_fork_foundations.sql','Fork model Phase 1/5: pathway_rungs.retired_at + pathway_versions (authoring doc, RLS pastor-only, one draft and one published per church). Nothing reads either yet. No unique constraint added: pathway_rungs_overlay_uk and pathway_rungs_base_uk already cover both lanes, so the design doc section 7 gap does not exist. template_generation dropped in favour of template_synced_at.')
ON CONFLICT (version) DO UPDATE SET filename=excluded.filename, note=excluded.note, applied_at=now();

-- SELF-VERIFY -- expect all_ok = PASS. Asserts only this migration's effects.

SELECT
  (SELECT count(*) FROM information_schema.columns
     WHERE table_schema='public' AND table_name='pathway_rungs'
       AND column_name='retired_at')                                    AS retired_at_col,
  (SELECT count(*) FROM information_schema.tables
     WHERE table_schema='public' AND table_name='pathway_versions')     AS versions_table,
  (SELECT count(*) FROM information_schema.columns
     WHERE table_schema='public' AND table_name='pathway_versions')     AS versions_cols,
  (SELECT count(*) FROM pg_class
     WHERE oid = to_regclass('public.pathway_versions')
       AND relrowsecurity)                                              AS versions_rls_on,
  (SELECT count(*) FROM pg_policies
     WHERE schemaname='public' AND tablename='pathway_versions')        AS versions_policies,
  (SELECT count(*) FROM pg_indexes
     WHERE schemaname='public' AND tablename='pathway_versions'
       AND indexname IN ('pathway_versions_one_draft_uk',
                         'pathway_versions_one_published_uk'))          AS versions_partial_uk,
  (SELECT count(*) FROM pg_trigger
     WHERE tgrelid = to_regclass('public.pathway_versions')
       AND NOT tgisinternal)                                            AS versions_triggers,
  (SELECT count(*) FROM public.schema_migrations WHERE version='098')   AS self_stamped,
  CASE WHEN
       (SELECT count(*) FROM information_schema.columns
          WHERE table_schema='public' AND table_name='pathway_rungs'
            AND column_name='retired_at') = 1
   AND (SELECT count(*) FROM information_schema.tables
          WHERE table_schema='public' AND table_name='pathway_versions') = 1
   AND (SELECT count(*) FROM information_schema.columns
          WHERE table_schema='public' AND table_name='pathway_versions') = 11
   AND (SELECT count(*) FROM pg_class
          WHERE oid = to_regclass('public.pathway_versions') AND relrowsecurity) = 1
   AND (SELECT count(*) FROM pg_policies
          WHERE schemaname='public' AND tablename='pathway_versions') = 4
   AND (SELECT count(*) FROM pg_indexes
          WHERE schemaname='public' AND tablename='pathway_versions'
            AND indexname IN ('pathway_versions_one_draft_uk',
                              'pathway_versions_one_published_uk')) = 2
   AND (SELECT count(*) FROM pg_trigger
          WHERE tgrelid = to_regclass('public.pathway_versions')
            AND NOT tgisinternal) = 2
   AND (SELECT count(*) FROM public.schema_migrations WHERE version='098') = 1
       THEN 'PASS' ELSE 'FAIL' END                                      AS all_ok;
