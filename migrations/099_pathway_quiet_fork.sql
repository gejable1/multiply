-- 099_pathway_quiet_fork.sql
-- Session 83. Pathway fork model, Phase 2 of 5 (PATHWAY_FORK_DESIGN.md section 10).
--
-- Gives every church an OWNED copy of the pipeline its members see today, and
-- records that copy as published v1 in pathway_versions. INVISIBLE: under the
-- resolver still deployed, a church row beats its template twin, and the copies
-- are byte-identical to what they replace, so nothing on any screen changes.
--
-- WHAT IT WRITES
--   1. pathway_rungs  -- one owned row per effective rung, per church, with
--      sort_order DENSIFIED to 1..N per level in the exact order members see now.
--   2. pathway_versions -- published v1 per church, doc = that pipeline as JSON.
--   3. pathway_section_order -- order_map cleared, because the order it encoded is
--      now baked into the owned rows' sort_order. ONE order of record per church,
--      not two (#405). pathwayOrder.sort falls back to sort_order when the map is
--      empty (multiply_shared.js:3391), so every reader shipped in S82 is untouched.
--
-- WHAT IT DOES NOT TOUCH
--   * The 6 giving-track rows. member_tool.html:11619 and lc_leader_tool.html:5852
--     read the TEMPLATE lane explicitly (.is('church_id', null)) and filter
--     meta.track='giving'. The Giving Journey is deliberately church-agnostic.
--     Fork them and Phase 3 breaks it for all twelve churches.
--   * Tombstones (church rows with published=false). They are excluded from the
--     effective set, so they are neither copied nor modified. They keep working
--     identically after Phase 3, because own-rows-only still drops published=false.
--   * Any pathway_progress row. Progress is keyed by rung_key text and nothing in
--     the 77-table schema references pathway_rungs.id.
--
-- THE GATE
--   Before signatures are captured into a TEMP table up front, computed with the
--   deployed resolver (template + overlay precedence, order_map then sort_order).
--   After the writes, the same signatures are recomputed from OWNED ROWS ONLY and
--   compared. Any difference RAISES and the whole transaction rolls back.
--   sort_order is deliberately EXCLUDED from the content signature: this migration
--   renumbers it on purpose, and what must be preserved is the ORDER, which the
--   signature captures through the aggregate's sort, not the numeric value.
--
-- Flat (#209), idempotent, self-verifying on its own effects (#403), stamped in the
-- body (#402). Proven on ephemeral PG16 as postgres (#379) against a fixture whose
-- before-diagnostic reproduces production exactly (448 trackable / 1999 reference /
-- 10 identical churches / 4 tombstones / Rosehill's 28-key L0 order map), forward,
-- on rerun, and with the gate deliberately broken to confirm it aborts.

BEGIN;

-- ---------------------------------------------------------------- BEFORE
CREATE TEMP TABLE _fork_before ON COMMIT DROP AS
WITH cand AS (
  SELECT c.id AS cid, r.*
    FROM public.churches c
    JOIN public.pathway_rungs r ON r.church_id IS NULL OR r.church_id = c.id
),
resolved AS (
  SELECT DISTINCT ON (cid, level, rung_key) *
    FROM cand
   WHERE COALESCE(meta->>'track','') <> 'giving'
   ORDER BY cid, level, rung_key, (church_id IS NOT NULL) DESC
),
eff AS (SELECT * FROM resolved WHERE published IS NOT FALSE),
ranked AS (
  SELECT e.*,
         COALESCE(array_position(
           CASE WHEN jsonb_typeof(o.order_map -> e.level::text) = 'array'
                THEN ARRAY(SELECT jsonb_array_elements_text(o.order_map -> e.level::text))
                ELSE ARRAY[]::text[] END, e.rung_key), 2147483647) AS opos,
         concat_ws(chr(1), e.rung_key, e.title_en, COALESCE(e.title_tl,''),
                   COALESCE(e.description_en,''), COALESCE(e.description_tl,''),
                   e.category, e.completion_source, COALESCE(e.auto_source_key,''),
                   e.trackable::text, e.meta::text) AS body
    FROM eff e
    LEFT JOIN public.pathway_section_order o ON o.church_id = e.cid
)
SELECT cid, level,
       count(*) FILTER (WHERE trackable IS NOT FALSE) AS n_track,
       count(*) FILTER (WHERE trackable IS FALSE)     AS n_ref,
       md5(COALESCE(string_agg(rung_key, ',' ORDER BY opos, sort_order, rung_key)
             FILTER (WHERE trackable IS NOT FALSE), '')) AS tsig,
       md5(COALESCE(string_agg(body, '|' ORDER BY opos, sort_order, rung_key)
             FILTER (WHERE trackable IS NOT FALSE), '')) AS tcsig,
       md5(COALESCE(string_agg(rung_key, ',' ORDER BY opos, sort_order, rung_key)
             FILTER (WHERE trackable IS FALSE), ''))     AS rsig,
       md5(COALESCE(string_agg(body, '|' ORDER BY opos, sort_order, rung_key)
             FILTER (WHERE trackable IS FALSE), ''))     AS rcsig
  FROM ranked
 GROUP BY cid, level;

-- ------------------------------------------------- 1. MATERIALISE OWNED ROWS
WITH cand AS (
  SELECT c.id AS cid, r.*
    FROM public.churches c
    JOIN public.pathway_rungs r ON r.church_id IS NULL OR r.church_id = c.id
),
resolved AS (
  SELECT DISTINCT ON (cid, level, rung_key) *
    FROM cand
   WHERE COALESCE(meta->>'track','') <> 'giving'
   ORDER BY cid, level, rung_key, (church_id IS NOT NULL) DESC
),
eff AS (SELECT * FROM resolved WHERE published IS NOT FALSE),
ranked AS (
  SELECT e.*,
         COALESCE(array_position(
           CASE WHEN jsonb_typeof(o.order_map -> e.level::text) = 'array'
                THEN ARRAY(SELECT jsonb_array_elements_text(o.order_map -> e.level::text))
                ELSE ARRAY[]::text[] END, e.rung_key), 2147483647) AS opos
    FROM eff e
    LEFT JOIN public.pathway_section_order o ON o.church_id = e.cid
),
dense AS (
  SELECT r.*, row_number() OVER (PARTITION BY r.cid, r.level
                                 ORDER BY r.opos, r.sort_order, r.rung_key) AS ns
    FROM ranked r
)
INSERT INTO public.pathway_rungs
      (church_id, level, sort_order, rung_key, title_en, title_tl,
       description_en, description_tl, category, completion_source,
       auto_source_key, published, meta, trackable)
SELECT cid, level, ns, rung_key, title_en, title_tl,
       description_en, description_tl, category, completion_source,
       auto_source_key, true, meta, trackable
  FROM dense
ON CONFLICT (church_id, level, rung_key) WHERE church_id IS NOT NULL
DO UPDATE SET sort_order = excluded.sort_order, updated_at = now();

-- ------------------------------------------------- 2. PUBLISHED v1 PER CHURCH
WITH own AS (
  SELECT church_id, level, sort_order, rung_key, title_en, title_tl,
         description_en, description_tl, category, completion_source,
         auto_source_key, trackable, meta
    FROM public.pathway_rungs
   WHERE church_id IS NOT NULL
     AND published IS NOT FALSE
     AND COALESCE(meta->>'track','') <> 'giving'
),
per_level AS (
  SELECT church_id, level,
         jsonb_agg(jsonb_build_object(
           'rung_key', rung_key, 'title_en', title_en, 'title_tl', title_tl,
           'description_en', description_en, 'description_tl', description_tl,
           'category', category, 'completion_source', completion_source,
           'auto_source_key', auto_source_key, 'trackable', trackable,
           'meta', meta) ORDER BY sort_order, rung_key) AS rungs
    FROM own GROUP BY church_id, level
),
docs AS (
  SELECT church_id, jsonb_object_agg(level::text, rungs) AS levels
    FROM per_level GROUP BY church_id
)
INSERT INTO public.pathway_versions
      (church_id, version_no, status, doc, note, published_at, template_synced_at)
SELECT church_id, 1, 'published',
       jsonb_build_object('schema', 1, 'source', 'phase2_fork_v1', 'levels', levels),
       'Phase 2 quiet fork: this church''s effective pipeline at the moment of forking, copied from the shared template plus its own overlays. Order baked into sort_order.',
       now(), now()
  FROM docs
ON CONFLICT (church_id, version_no) DO NOTHING;

-- --------------------------------------- 3. ONE ORDER OF RECORD, NOT TWO
UPDATE public.pathway_section_order
   SET order_map = '{}'::jsonb, updated_at = now()
 WHERE order_map <> '{}'::jsonb;

-- ---------------------------------------------------------------- THE GATE
DO $gate$
DECLARE
  v_bad  int;
  v_miss int;
BEGIN
  CREATE TEMP TABLE _fork_after ON COMMIT DROP AS
  WITH own AS (
    SELECT church_id AS cid, level, rung_key, sort_order, trackable,
           concat_ws(chr(1), rung_key, title_en, COALESCE(title_tl,''),
                     COALESCE(description_en,''), COALESCE(description_tl,''),
                     category, completion_source, COALESCE(auto_source_key,''),
                     trackable::text, meta::text) AS body
      FROM public.pathway_rungs
     WHERE church_id IS NOT NULL
       AND published IS NOT FALSE
       AND COALESCE(meta->>'track','') <> 'giving'
  )
  SELECT cid, level,
         count(*) FILTER (WHERE trackable IS NOT FALSE) AS n_track,
         count(*) FILTER (WHERE trackable IS FALSE)     AS n_ref,
         md5(COALESCE(string_agg(rung_key, ',' ORDER BY sort_order, rung_key)
               FILTER (WHERE trackable IS NOT FALSE), '')) AS tsig,
         md5(COALESCE(string_agg(body, '|' ORDER BY sort_order, rung_key)
               FILTER (WHERE trackable IS NOT FALSE), '')) AS tcsig,
         md5(COALESCE(string_agg(rung_key, ',' ORDER BY sort_order, rung_key)
               FILTER (WHERE trackable IS FALSE), ''))     AS rsig,
         md5(COALESCE(string_agg(body, '|' ORDER BY sort_order, rung_key)
               FILTER (WHERE trackable IS FALSE), ''))     AS rcsig
    FROM own GROUP BY cid, level;

  SELECT count(*) INTO v_bad
    FROM _fork_after a
    FULL JOIN _fork_before b USING (cid, level)
   WHERE a.n_track IS DISTINCT FROM b.n_track
      OR a.n_ref   IS DISTINCT FROM b.n_ref
      OR a.tsig    IS DISTINCT FROM b.tsig
      OR a.tcsig   IS DISTINCT FROM b.tcsig
      OR a.rsig    IS DISTINCT FROM b.rsig
      OR a.rcsig   IS DISTINCT FROM b.rcsig;

  IF v_bad <> 0 THEN
    RAISE EXCEPTION 'FORK GATE FAILED: % church/level pair(s) differ before vs after. Nothing committed.', v_bad;
  END IF;

  SELECT count(*) INTO v_miss
    FROM public.churches c
   WHERE NOT EXISTS (SELECT 1 FROM public.pathway_versions v
                      WHERE v.church_id = c.id AND v.status = 'published');
  IF v_miss <> 0 THEN
    RAISE EXCEPTION 'FORK GATE FAILED: % church(es) have no published version. Nothing committed.', v_miss;
  END IF;
END
$gate$;

-- ------------------------------------------------------- STAMP THIS MIGRATION
INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('099','099_pathway_quiet_fork.sql','Fork model Phase 2/5: every church given an owned copy of its effective pipeline + published v1 in pathway_versions; sort_order densified to the order members already see; order_map cleared so sort_order is the single order of record. Giving-track rows and tombstones deliberately untouched. Gated: before/after effective signatures compared in-transaction, RAISE on any difference.')
ON CONFLICT (version) DO UPDATE SET filename=excluded.filename, note=excluded.note, applied_at=now();

COMMIT;

-- SELF-VERIFY -- expect all_ok = PASS. Asserts only this migration's effects.
SELECT
  (SELECT count(*) FROM public.pathway_versions WHERE status='published')      AS published_versions,
  (SELECT count(*) FROM public.churches)                                       AS churches,
  (SELECT count(*) FROM public.pathway_versions WHERE version_no <> 1)         AS non_v1_rows,
  (SELECT count(*) FROM public.pathway_section_order WHERE order_map <> '{}')  AS nonempty_order_maps,
  (SELECT count(*) FROM public.pathway_rungs WHERE church_id IS NULL)          AS template_rows_left,
  (SELECT count(*) FROM public.pathway_rungs
     WHERE church_id IS NOT NULL AND COALESCE(meta->>'track','')='giving')     AS giving_rows_forked,
  (SELECT count(*) FROM public.schema_migrations WHERE version='099')          AS self_stamped,
  CASE WHEN
       (SELECT count(*) FROM public.pathway_versions WHERE status='published')
         = (SELECT count(*) FROM public.churches)
   AND (SELECT count(*) FROM public.pathway_versions WHERE version_no <> 1) = 0
   AND (SELECT count(*) FROM public.pathway_section_order WHERE order_map <> '{}') = 0
   AND (SELECT count(*) FROM public.pathway_rungs
          WHERE church_id IS NOT NULL AND COALESCE(meta->>'track','')='giving') = 0
   AND (SELECT count(*) FROM public.schema_migrations WHERE version='099') = 1
       THEN 'PASS' ELSE 'FAIL' END                                             AS all_ok;
