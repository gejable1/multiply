-- 104_publish_pathway_version.sql
-- Session 84. Pathway fork model, Phase 4b. READ-ONLY: creates/replaces three
-- functions, writes no rows, changes no existing object.
--
-- WHAT PUBLISH IS
--
-- "Publish is a regeneration, not a diff" (PATHWAY_FORK_DESIGN.md s6). For one church:
-- upsert every rung the document contains, retire every own rung it does not, write the
-- flat order, archive the previously published version. All in ONE transaction. Safe
-- precisely because nothing references pathway_rungs.id -- pathway_progress is keyed by
-- (church_id, member_id, level, rung_key) TEXT with no FK, so rung rows can be rebuilt
-- freely and no member ever loses a completion.
--
-- WHY SECURITY INVOKER
--
-- pathway_rungs, pathway_versions and pathway_section_order each grant INSERT/UPDATE/
-- DELETE to authenticated WHERE church_id = auth_church_id() AND auth_level() >= 5. The
-- pastor's own JWT therefore carries exactly the authority publish needs, and carries it
-- no further: the template lane (church_id IS NULL) is unwritable by any pastor, so the
-- Giving Journey's six rows are protected by RLS itself. No service role, no manual
-- church_id stamping, fail-closed by construction (#406).
--
-- THREE THINGS THE SCHEMA DICTATES, each confirmed before this was written
--
--   1. The covering index is PARTIAL (pathway_rungs_overlay_uk, UNIQUE (church_id,
--      level, rung_key) WHERE church_id IS NOT NULL), so the upsert must spell the
--      predicate out or inference fails with "no unique or exclusion constraint
--      matching the ON CONFLICT specification". Design s7 records both forms executed.
--
--   2. pathway_versions_one_published_uk is UNIQUE (church_id) WHERE status='published'.
--      It is checked per statement, not deferred, so the previous version must be
--      archived BEFORE the new one is marked published. Reversing those two statements
--      raises.
--
--   3. ORDER OF RECORD. multiply_shared.js:3391 sorts by order_map FIRST and falls
--      through to sort_order only for keys the map omits -- so a stale non-empty map
--      silently overrides anything publish writes. Migration 099 cleared the map and
--      made sort_order the single order of record (#405). Publish therefore writes
--      sort_order and CLEARS any map it finds, rather than writing a second order.
--      This supersedes design s6's line "pathway_section_order <-- flat order written
--      from the doc", which predates 099.
--
-- WHY pathway_version_items() EXISTS
--
-- Flattening the document into rung rows was written once inside
-- pathway_version_validate (migration 102) and publish needs the identical flattening
-- three times. Two copies of that rule would drift the first time the document format
-- gains a field -- publish would honour it and validation would not. So the flattener
-- moves to one function and the validator is REPLACED here to call it (#405). Migration
-- 102's file stays as history; this migration supersedes its validator body, which is
-- ordinary for a later migration and is why 102 was written CREATE OR REPLACE.
--
-- The move also closes two crash paths 102 carried: a non-numeric level key raised on
-- the (k.key)::int cast, and a level whose value was not an array raised inside
-- jsonb_array_elements. Both now report as blocking rows instead of aborting the check.
--
-- TOMBSTONES ARE NOT RETIRED. Production carries four church rows with
-- published=false that mask a base rung. They were materialised by the Phase 2 fork
-- but are absent from every document, so a naive retire arm would have retired all
-- four on the first publish -- writes on a publish that must change nothing. The
-- design doc reasons they are harmless because they "sit on trackable=false bases";
-- that premise is wrong (all four are trackable=true) but the conclusion survives for
-- a different reason: all three readers drop published=false BEFORE testing trackable,
-- so a tombstone never reaches a denominator. Design s10 should be corrected to name
-- the real protection.
--
-- Flat (#209), idempotent, self-verifying on its own effects (#403), stamped (#402).
-- Proven on ephemeral PG16 as postgres (#379), every gate failed on purpose (#413).

BEGIN;

-- ------------------------------------------------------------ the flattener
CREATE OR REPLACE FUNCTION public.pathway_version_items(p_version_id uuid)
RETURNS TABLE(church_id uuid, lvl int, pos int, rung_key text, title_en text, title_tl text,
              description_en text, description_tl text, category text,
              completion_source text, auto_source_key text, trackable boolean, meta jsonb)
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public
AS $fn$
  SELECT pv.church_id,
         (k.key)::int                                        AS lvl,
         (e.ord - 1)::int                                    AS pos,
         e.item->>'rung_key',
         e.item->>'title_en',
         e.item->>'title_tl',
         e.item->>'description_en',
         e.item->>'description_tl',
         e.item->>'category',
         COALESCE(e.item->>'completion_source','manual'),
         e.item->>'auto_source_key',
         COALESCE((e.item->>'trackable')::boolean, true),
         CASE WHEN jsonb_typeof(e.item->'meta') = 'object' THEN e.item->'meta' ELSE NULL END
    FROM public.pathway_versions pv
    CROSS JOIN LATERAL jsonb_each(COALESCE(pv.doc->'levels','{}'::jsonb)) k(key, value)
    -- a level whose value is not an array yields no items rather than raising; the
    -- validator reports it as bad_level_shape
    CROSS JOIN LATERAL jsonb_array_elements(
      CASE WHEN jsonb_typeof(k.value) = 'array' THEN k.value ELSE '[]'::jsonb END
    ) WITH ORDINALITY e(item, ord)
   WHERE pv.id = p_version_id
     -- a non-numeric level key yields no items rather than raising on the cast; the
     -- validator reports it as bad_level_key
     AND k.key ~ '^-?[0-9]+$';
$fn$;

COMMENT ON FUNCTION public.pathway_version_items(uuid) IS
  'Flattens a pathway_versions document into rung rows. THE single flattening: pathway_version_validate reads it and publish_pathway_version reads it three times, so the document format has one interpretation rather than two that drift (#405). Malformed levels yield no rows here and are reported by the validator instead of raising.';

-- ------------------------------------------------------------ validator (replaced)
CREATE OR REPLACE FUNCTION public.pathway_version_validate(p_version_id uuid)
RETURNS TABLE(severity text, code text, lvl int, rung_key text, message text)
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public
AS $fn$
WITH v AS (
  SELECT pv.id, pv.church_id, pv.doc FROM public.pathway_versions pv WHERE pv.id = p_version_id
),
lv AS (
  SELECT v.church_id, k.key AS lvl_key, k.value AS rungs
    FROM v, LATERAL jsonb_each(COALESCE(v.doc->'levels', '{}'::jsonb)) k(key, value)
),
r AS (
  SELECT * FROM public.pathway_version_items(p_version_id)
)
-- ============================ BLOCKING ============================
SELECT 'block', 'no_doc', NULL::int, NULL::text,
       'This version has no document to publish.'
  FROM v WHERE COALESCE(jsonb_typeof(v.doc->'levels'),'') <> 'object'
UNION ALL
SELECT 'block', 'bad_level_key', NULL, NULL,
       'The document has a level named "' || lv.lvl_key || '", which is not a number.'
  FROM lv WHERE lv.lvl_key !~ '^-?[0-9]+$'
UNION ALL
SELECT 'block', 'bad_level_shape', NULL, NULL,
       'Level "' || lv.lvl_key || '" is not a list of items.'
  FROM lv WHERE jsonb_typeof(lv.rungs) <> 'array'
UNION ALL
SELECT 'block', 'level_no_trackable', r.lvl, NULL,
       'Level ' || r.lvl || ' has no trackable item, so nobody can make progress in it.'
  FROM r GROUP BY r.lvl HAVING count(*) FILTER (WHERE r.trackable) = 0
UNION ALL
SELECT 'block', 'duplicate_rung_key', r.lvl, r.rung_key,
       'Level ' || r.lvl || ' uses the key "' || r.rung_key || '" ' || count(*) || ' times. Keys must be unique within a level.'
  FROM r GROUP BY r.lvl, r.rung_key HAVING count(*) > 1
UNION ALL
SELECT 'block', 'missing_rung_key', r.lvl, NULL,
       'Level ' || r.lvl || ' has an item at position ' || (r.pos + 1) || ' with no key.'
  FROM r WHERE COALESCE(r.rung_key,'') = ''
UNION ALL
SELECT 'block', 'missing_title', r.lvl, r.rung_key,
       'Item "' || r.rung_key || '" at level ' || r.lvl || ' has no English title.'
  FROM r WHERE COALESCE(r.title_en,'') = ''
UNION ALL
SELECT 'block', 'bad_category', r.lvl, r.rung_key,
       'Item "' || r.rung_key || '" has category "' || COALESCE(r.category,'(none)') || '", which is not one of the allowed categories.'
  FROM r WHERE COALESCE(r.category,'') NOT IN
       ('book','training','lesson','ministry','coaching','assessment','character','competency','discipline','formation')
UNION ALL
SELECT 'block', 'bad_completion_source', r.lvl, r.rung_key,
       'Item "' || r.rung_key || '" has completion source "' || r.completion_source || '"; it must be manual or auto.'
  FROM r WHERE r.completion_source NOT IN ('manual','auto')
UNION ALL
SELECT 'block', 'bad_level', r.lvl, NULL,
       'Level ' || r.lvl || ' is outside the range 0 to 5.'
  FROM r WHERE r.lvl < 0 OR r.lvl > 5 GROUP BY r.lvl
UNION ALL
SELECT 'block', 'auto_without_key', r.lvl, r.rung_key,
       'Item "' || r.rung_key || '" auto-completes but has no source, so it can never complete.'
  FROM r WHERE r.completion_source = 'auto' AND COALESCE(r.auto_source_key,'') = ''
UNION ALL
SELECT 'block', 'auto_source_unknown', r.lvl, r.rung_key,
       'Item "' || r.rung_key || '" uses the auto source "' || r.auto_source_key
       || '", which nothing recognises. Choose one from the list -- an unrecognised source can stop auto-completion for every church.'
  FROM r
 WHERE r.completion_source = 'auto'
   AND COALESCE(r.auto_source_key,'') <> ''
   AND NOT public.pathway_auto_source_ok(r.auto_source_key)
UNION ALL
-- Publishing a Giving Journey key would fork a lane that is deliberately shared.
SELECT 'block', 'giving_rung_in_doc', r.lvl, r.rung_key,
       'Item "' || r.rung_key || '" belongs to the Giving Journey, which is shared by every church and cannot be part of one church''s pipeline.'
  FROM r
  JOIN public.pathway_rungs t
    ON t.church_id IS NULL AND t.level = r.lvl AND t.rung_key = r.rung_key
 WHERE COALESCE(t.meta->>'track','') = 'giving'
-- ============================ WARNINGS ============================
UNION ALL
SELECT 'warn', 'retire_with_history', pr.level, pr.rung_key,
       CASE WHEN c.n = 1 THEN '1 member has completed "' || COALESCE(pr.title_en, pr.rung_key)
            ELSE c.n || ' members have completed "' || COALESCE(pr.title_en, pr.rung_key) END
       || '". Publishing keeps their record and removes it from the pathway.'
  FROM v
  JOIN public.pathway_rungs pr
    ON pr.church_id = v.church_id AND pr.retired_at IS NULL AND pr.published IS NOT FALSE
   AND COALESCE(pr.meta->>'track','') <> 'giving'
  JOIN LATERAL (SELECT count(*) AS n FROM public.pathway_progress pp
                 WHERE pp.church_id = v.church_id AND pp.level = pr.level
                   AND pp.rung_key = pr.rung_key) c ON c.n > 0
 WHERE NOT EXISTS (SELECT 1 FROM r WHERE r.lvl = pr.level AND r.rung_key = pr.rung_key)
UNION ALL
SELECT 'warn', 'empty_level', (lv.lvl_key)::int, NULL,
       'Level ' || lv.lvl_key || ' has nothing in it.'
  FROM lv
 WHERE lv.lvl_key ~ '^-?[0-9]+$' AND jsonb_typeof(lv.rungs) = 'array'
   AND jsonb_array_length(lv.rungs) = 0;
$fn$;

COMMENT ON FUNCTION public.pathway_version_validate(uuid) IS
  'Pre-publish sanity check over a pathway_versions document. Called by the editor for display AND by publish_pathway_version as a hard gate, so a stale tab cannot publish a document that never passed. Replaced in migration 104 to read pathway_version_items() rather than flatten the document itself (#405), which also turned two crash paths (non-numeric level key, non-array level) into blocking rows.';

-- ------------------------------------------------------------ publish
CREATE OR REPLACE FUNCTION public.publish_pathway_version(p_version_id uuid)
RETURNS TABLE(church uuid, version int, upserted int, retired int, restored int,
              archived_previous int, order_map_cleared int)
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $fn$
DECLARE
  v_church uuid; v_no int; v_status text;
  n_block int; n_up int := 0; n_ret int := 0; n_res int := 0; n_arch int := 0; n_om int := 0;
BEGIN
  -- RLS decides visibility: another church's version simply is not found.
  SELECT pv.church_id, pv.version_no, pv.status
    INTO v_church, v_no, v_status
    FROM public.pathway_versions pv
   WHERE pv.id = p_version_id;

  IF v_church IS NULL THEN
    RAISE EXCEPTION 'publish: version % was not found, or is not yours to publish.', p_version_id;
  END IF;
  IF v_status = 'archived' THEN
    RAISE EXCEPTION 'publish: version % is archived. Load it as a draft first, then publish that draft -- archived versions stay as the undo history.', p_version_id;
  END IF;

  -- HARD GATE. The same validator the editor renders, so a stale tab cannot publish a
  -- document that never passed (#405).
  SELECT count(*) INTO n_block
    FROM public.pathway_version_validate(p_version_id)
   WHERE severity = 'block';
  IF n_block > 0 THEN
    RAISE EXCEPTION 'publish: % blocking problem(s) must be cleared before this version can be published.', n_block;
  END IF;

  -- How many retired rungs is this document bringing back? Counted before the upsert
  -- un-retires them, purely for the report.
  SELECT count(*) INTO n_res
    FROM public.pathway_rungs r
    JOIN public.pathway_version_items(p_version_id) i
      ON i.lvl = r.level AND i.rung_key = r.rung_key
   WHERE r.church_id = v_church AND r.retired_at IS NOT NULL;

  -- 1. UPSERT everything the document contains.
  --    The WHERE on DO UPDATE is what makes republishing an unchanged document a true
  --    no-op: without it every row's updated_at churns on every publish. meta is
  --    deliberately not written on update -- it carries system flags the editor does
  --    not author, and overwriting it would erase them.
  WITH ins AS (
    INSERT INTO public.pathway_rungs
      (church_id, level, sort_order, rung_key, title_en, title_tl,
       description_en, description_tl, category, completion_source,
       auto_source_key, published, trackable, retired_at, updated_at)
    SELECT v_church, i.lvl, i.pos + 1, i.rung_key, i.title_en, i.title_tl,
           i.description_en, i.description_tl, COALESCE(i.category,'lesson'),
           i.completion_source, i.auto_source_key, true, i.trackable, NULL, now()
      FROM public.pathway_version_items(p_version_id) i
    ON CONFLICT (church_id, level, rung_key) WHERE church_id IS NOT NULL
    DO UPDATE SET
         sort_order        = EXCLUDED.sort_order,
         title_en          = EXCLUDED.title_en,
         title_tl          = EXCLUDED.title_tl,
         description_en    = EXCLUDED.description_en,
         description_tl    = EXCLUDED.description_tl,
         category          = EXCLUDED.category,
         completion_source = EXCLUDED.completion_source,
         auto_source_key   = EXCLUDED.auto_source_key,
         published         = true,
         trackable         = EXCLUDED.trackable,
         retired_at        = NULL,
         updated_at        = now()
      WHERE (pathway_rungs.sort_order, pathway_rungs.title_en, pathway_rungs.title_tl,
             pathway_rungs.description_en, pathway_rungs.description_tl,
             pathway_rungs.category, pathway_rungs.completion_source,
             pathway_rungs.auto_source_key, pathway_rungs.published,
             pathway_rungs.trackable, pathway_rungs.retired_at)
         IS DISTINCT FROM
            (EXCLUDED.sort_order, EXCLUDED.title_en, EXCLUDED.title_tl,
             EXCLUDED.description_en, EXCLUDED.description_tl,
             EXCLUDED.category, EXCLUDED.completion_source,
             EXCLUDED.auto_source_key, true,
             EXCLUDED.trackable, NULL::timestamptz)
    RETURNING 1)
  SELECT count(*) INTO n_up FROM ins;

  -- 2. RETIRE, never delete. A retired rung stays visible to the member who completed
  --    it -- it is part of their story -- and pathway_progress is untouched.
  WITH ret AS (
    UPDATE public.pathway_rungs r
       SET retired_at = now(), updated_at = now()
     WHERE r.church_id = v_church
       AND r.retired_at IS NULL
       -- A TOMBSTONE IS A MASK, NOT A PATHWAY ITEM. A church row with
       -- published=false says "hide this base rung for my church", which is a
       -- different statement from "this is no longer part of the pathway".
       -- Retiring it conflates the two and writes rows on a publish that should
       -- change nothing. All three readers drop published=false before they look
       -- at anything else (member_tool.html:11460, lc_leader_tool.html:4144,
       -- multiply_dashboard.html:3475), so a tombstone is invisible either way --
       -- retiring it buys nothing and costs the no-op. If a pastor re-adds the
       -- rung through the editor the upsert sets published=true and it returns,
       -- so nothing is stranded.
       AND r.published IS NOT FALSE
       AND NOT EXISTS (SELECT 1 FROM public.pathway_version_items(p_version_id) i
                        WHERE i.lvl = r.level AND i.rung_key = r.rung_key)
    RETURNING 1)
  SELECT count(*) INTO n_ret FROM ret;

  -- 3. ONE ORDER OF RECORD. sort_order was written by the upsert; a stale order_map
  --    would silently outrank it in multiply_shared.js:3391, so it is cleared.
  WITH om AS (
    UPDATE public.pathway_section_order
       SET order_map = '{}'::jsonb, updated_at = now()
     WHERE church_id = v_church
       AND order_map IS NOT NULL
       AND order_map <> '{}'::jsonb
    RETURNING 1)
  SELECT count(*) INTO n_om FROM om;

  -- 4. Archive the outgoing version BEFORE marking this one published --
  --    pathway_versions_one_published_uk is checked per statement.
  WITH arc AS (
    UPDATE public.pathway_versions
       SET status = 'archived', updated_at = now()
     WHERE church_id = v_church AND status = 'published' AND id <> p_version_id
    RETURNING 1)
  SELECT count(*) INTO n_arch FROM arc;

  UPDATE public.pathway_versions
     SET status       = 'published',
         published_at = COALESCE(published_at, now()),
         updated_at   = now()
   WHERE id = p_version_id
     AND (status <> 'published' OR published_at IS NULL);

  RETURN QUERY SELECT v_church, v_no, n_up, n_ret, n_res, n_arch, n_om;
END;
$fn$;

COMMENT ON FUNCTION public.publish_pathway_version(uuid) IS
  'Renders a pathway_versions document into the live tables: upsert present rungs, retire absent ones (never delete -- pathway_progress is text-keyed with no FK, so no member loses a completion), clear any stale order_map so sort_order stays the one order of record, archive the outgoing version. SECURITY INVOKER, so RLS confines it to the caller''s own church and the shared template lane is unwritable. Republishing an unchanged document is a true no-op: the ON CONFLICT DO UPDATE carries a row-differs WHERE, so nothing is written and no updated_at churns.';

GRANT EXECUTE ON FUNCTION public.pathway_version_items(uuid)     TO authenticated;
GRANT EXECUTE ON FUNCTION public.publish_pathway_version(uuid)   TO authenticated;

INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('104','104_publish_pathway_version.sql','Phase 4b: publish_pathway_version() renders a version document into pathway_rungs (upsert present, retire absent, clear stale order_map, archive the outgoing version) in one transaction, gated on pathway_version_validate having no blocking rows. Adds pathway_version_items() as THE single document flattener and REPLACES the 102 validator to read it, so publish and validation cannot drift (#405); that also turns two 102 crash paths -- non-numeric level key, non-array level -- into blocking rows, and adds a giving_rung_in_doc block so a church cannot fork the shared Giving Journey lane. SECURITY INVOKER throughout. Republishing an unchanged document is a true no-op by construction. Read-only migration, no rows written.')
ON CONFLICT (version) DO UPDATE SET filename=excluded.filename, note=excluded.note, applied_at=now();

COMMIT;

-- SELF-VERIFY -- expect all_ok = PASS.
--
-- would_change / would_retire are the NO-OP GATE, computed WITHOUT writing: they count
-- exactly what publish_pathway_version would do if every church republished the version
-- it already has published. If the Phase 2 fork was faithful, both are 0 -- which is the
-- stated acceptance condition for this migration, proved here read-only rather than
-- asserted. A non-zero number is not necessarily a fault; it means a rung drifted away
-- from its published document since the fork, and wants looking at before anyone
-- presses publish.
SELECT
  (SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='public' AND p.proname='pathway_version_items')                  AS fn_items,
  (SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='public' AND p.proname='publish_pathway_version')                AS fn_publish,
  (SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='public' AND p.proname='pathway_version_validate')               AS fn_validate,
  (SELECT count(*) FROM public.pathway_versions WHERE status='published')            AS published_versions,
  (SELECT count(*) FROM public.pathway_versions pv
     CROSS JOIN LATERAL public.pathway_version_items(pv.id) i
    WHERE pv.status='published')                                                     AS items_total,
  (SELECT count(*) FROM public.pathway_versions pv
     CROSS JOIN LATERAL public.pathway_version_items(pv.id) i
     LEFT JOIN public.pathway_rungs r
       ON r.church_id = pv.church_id AND r.level = i.lvl AND r.rung_key = i.rung_key
    WHERE pv.status='published'
      AND (r.id IS NULL
        OR (r.sort_order, r.title_en, r.category, r.completion_source,
            r.auto_source_key, r.published, r.trackable, r.retired_at)
           IS DISTINCT FROM
           (i.pos + 1, i.title_en, COALESCE(i.category,'lesson'), i.completion_source,
            i.auto_source_key, true, i.trackable, NULL::timestamptz)))               AS would_change,
  (SELECT count(*) FROM public.pathway_versions pv
     JOIN public.pathway_rungs r
       ON r.church_id = pv.church_id AND r.retired_at IS NULL
      AND r.published IS NOT FALSE
    WHERE pv.status='published'
      AND NOT EXISTS (SELECT 1 FROM public.pathway_version_items(pv.id) i
                       WHERE i.lvl = r.level AND i.rung_key = r.rung_key))           AS would_retire,
  (SELECT count(*) FROM public.pathway_versions pv
     JOIN public.pathway_rungs r
       ON r.church_id = pv.church_id AND r.retired_at IS NULL AND r.published IS FALSE
    WHERE pv.status='published'
      AND NOT EXISTS (SELECT 1 FROM public.pathway_version_items(pv.id) i
                       WHERE i.lvl = r.level AND i.rung_key = r.rung_key))           AS tombstones_left_alone,
  (SELECT count(*) FROM public.pathway_section_order
    WHERE order_map IS NOT NULL AND order_map <> '{}'::jsonb)                        AS stale_order_maps,
  (SELECT count(*) FROM public.schema_migrations WHERE version='104')                AS self_stamped,
  CASE WHEN
       (SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
         WHERE n.nspname='public' AND p.proname='pathway_version_items') = 1
   AND (SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
         WHERE n.nspname='public' AND p.proname='publish_pathway_version') = 1
   AND (SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
         WHERE n.nspname='public' AND p.proname='pathway_version_validate') = 1
   AND (SELECT count(*) FROM public.pathway_versions pv
          CROSS JOIN LATERAL public.pathway_version_items(pv.id) i
         WHERE pv.status='published') > 0
   AND (SELECT count(*) FROM public.schema_migrations WHERE version='104') = 1
       THEN 'PASS' ELSE 'FAIL' END                                                   AS all_ok;
