-- 100_truenorth_multiplication_typo.sql
-- Session 83. A one-word correction, done now because it stops being one-word soon.
--
-- True North owns a net-new L2 rung keyed `x-the-muliplication-effect-idxd` --
-- "muliplication", missing a t. Rosehill's equivalent, `x-the-multiplication-effect-gyzg`,
-- is spelled correctly. Cosmetic on a wall poster; not cosmetic in the schema, because
-- rung_key IS the progress key: pathway_progress is keyed by
-- (church_id, member_id, level, rung_key) as TEXT. Rename it later and every completion
-- recorded against it is orphaned.
--
-- THREE HOMES, and the third exists only because of Phase 2:
--   1. pathway_rungs.rung_key      -- the rung itself (plus any display text carrying it)
--   2. pathway_progress.rung_key   -- completions, keyed by text, no FK
--   3. pathway_versions.doc        -- the published v1 written by migration 099. Miss this
--      and the next publish regenerates the typo from the document.
--
-- NOT touched: v_effective_auto_rungs is a VIEW over pathway_rungs and follows for free.
-- pathway_section_order.order_map is empty platform-wide after 099. Nothing in the repo
-- hardcodes the string (checked with git grep on origin/main).
--
-- MATCHING: the discriminator is the substring `uliplication`, which appears in both
-- `muliplication` and `Muliplication` but NOT in the correct `multiplication`
-- (which contains `ultiplication`). So the gate can assert on it without false positives.
--
-- THE GATE: after the writes, `uliplication` must appear in NO row of pathway_rungs,
-- pathway_progress, pathway_versions, pathway_section_order or system_settings -- including
-- the two jsonb homes this migration does NOT write. If it survives somewhere unexpected,
-- the migration RAISEs and rolls back rather than leaving a half-finished rename, which is
-- worse than no rename. The gate also asserts the completion count carried across intact.
--
-- Flat (#209), idempotent (a second run matches nothing and the gate still passes),
-- self-verifying on its own effects (#403), stamped in the body (#402).
-- Proven on ephemeral PG16 as postgres (#379) against post-099 forked data.

BEGIN;

CREATE TEMP TABLE _typo_before ON COMMIT DROP AS
SELECT (SELECT count(*) FROM public.pathway_rungs    WHERE rung_key LIKE '%uliplication%') AS n_rungs,
       (SELECT count(*) FROM public.pathway_progress WHERE rung_key LIKE '%uliplication%') AS n_prog;

-- 1. the rung row: key and any display text
UPDATE public.pathway_rungs
   SET rung_key       = replace(rung_key, 'muliplication', 'multiplication'),
       title_en       = replace(replace(title_en,       'Muliplication', 'Multiplication'), 'muliplication', 'multiplication'),
       title_tl       = replace(replace(title_tl,       'Muliplication', 'Multiplication'), 'muliplication', 'multiplication'),
       description_en = replace(replace(description_en, 'Muliplication', 'Multiplication'), 'muliplication', 'multiplication'),
       description_tl = replace(replace(description_tl, 'Muliplication', 'Multiplication'), 'muliplication', 'multiplication'),
       updated_at     = now()
 WHERE rung_key                     LIKE '%uliplication%'
    OR COALESCE(title_en,'')        LIKE '%uliplication%'
    OR COALESCE(title_tl,'')        LIKE '%uliplication%'
    OR COALESCE(description_en,'')  LIKE '%uliplication%'
    OR COALESCE(description_tl,'')  LIKE '%uliplication%';

-- 2. completions recorded against the old key
UPDATE public.pathway_progress
   SET rung_key = replace(rung_key, 'muliplication', 'multiplication')
 WHERE rung_key LIKE '%uliplication%';

-- 3. the published document, so the next publish cannot resurrect it
UPDATE public.pathway_versions
   SET doc = replace(replace(doc::text, 'Muliplication', 'Multiplication'), 'muliplication', 'multiplication')::jsonb,
       updated_at = now()
 WHERE doc::text LIKE '%uliplication%';

-- ---------------------------------------------------------------- THE GATE
DO $gate$
DECLARE
  v_left int;
  v_prog_before int;
  v_prog_now    int;
BEGIN
  SELECT (SELECT count(*) FROM public.pathway_rungs
            WHERE rung_key LIKE '%uliplication%'
               OR COALESCE(title_en,'')       LIKE '%uliplication%'
               OR COALESCE(title_tl,'')       LIKE '%uliplication%'
               OR COALESCE(description_en,'') LIKE '%uliplication%'
               OR COALESCE(description_tl,'') LIKE '%uliplication%')
       + (SELECT count(*) FROM public.pathway_progress      WHERE rung_key LIKE '%uliplication%')
       + (SELECT count(*) FROM public.pathway_versions      WHERE doc::text LIKE '%uliplication%')
       + (SELECT count(*) FROM public.pathway_section_order WHERE order_map::text LIKE '%uliplication%')
       + (SELECT count(*) FROM public.system_settings
            WHERE COALESCE(pipeline::text,'')      LIKE '%uliplication%'
               OR COALESCE(meta::text,'')          LIKE '%uliplication%'
               OR COALESCE(weights::text,'')       LIKE '%uliplication%'
               OR COALESCE(thresholds::text,'')    LIKE '%uliplication%'
               OR COALESCE(zones::text,'')         LIKE '%uliplication%'
               OR COALESCE(interventions::text,'') LIKE '%uliplication%'
               OR COALESCE(fats::text,'')          LIKE '%uliplication%')
    INTO v_left;

  IF v_left <> 0 THEN
    RAISE EXCEPTION 'TYPO GATE FAILED: % row(s) still carry the misspelling, including homes this migration does not write. Nothing committed.', v_left;
  END IF;

  SELECT n_prog INTO v_prog_before FROM _typo_before;
  SELECT count(*) INTO v_prog_now
    FROM public.pathway_progress WHERE rung_key = 'x-the-multiplication-effect-idxd';

  IF v_prog_now < v_prog_before THEN
    RAISE EXCEPTION 'TYPO GATE FAILED: % completion(s) went in, only % came out. Nothing committed.',
                    v_prog_before, v_prog_now;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.pathway_progress p
                  WHERE p.rung_key LIKE '%uliplication%')
     AND EXISTS (SELECT 1 FROM public.pathway_progress p
                  LEFT JOIN public.pathway_rungs r
                    ON r.church_id = p.church_id AND r.level = p.level AND r.rung_key = p.rung_key
                 WHERE p.rung_key = 'x-the-multiplication-effect-idxd' AND r.id IS NULL)
  THEN
    RAISE EXCEPTION 'TYPO GATE FAILED: renamed completions no longer match any rung. Nothing committed.';
  END IF;
END
$gate$;

-- ------------------------------------------------------- STAMP THIS MIGRATION
INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('100','100_truenorth_multiplication_typo.sql','Corrected True North rung_key x-the-muliplication-effect-idxd -> x-the-multiplication-effect-idxd across all three homes: pathway_rungs, pathway_progress (rung_key is the progress key, text, no FK) and pathway_versions.doc (written by 099 -- missing it would let the next publish regenerate the typo). Gated: the substring uliplication must survive nowhere, including jsonb homes this migration does not write, and the completion count must carry across.')
ON CONFLICT (version) DO UPDATE SET filename=excluded.filename, note=excluded.note, applied_at=now();

COMMIT;

-- SELF-VERIFY -- expect all_ok = PASS. Asserts only this migration's effects.
SELECT
  (SELECT count(*) FROM public.pathway_rungs    WHERE rung_key LIKE '%uliplication%')      AS rungs_left,
  (SELECT count(*) FROM public.pathway_progress WHERE rung_key LIKE '%uliplication%')      AS progress_left,
  (SELECT count(*) FROM public.pathway_versions WHERE doc::text LIKE '%uliplication%')     AS docs_left,
  (SELECT count(*) FROM public.pathway_rungs
     WHERE rung_key = 'x-the-multiplication-effect-idxd')                                  AS corrected_rung,
  (SELECT count(*) FROM public.pathway_progress
     WHERE rung_key = 'x-the-multiplication-effect-idxd')                                  AS corrected_progress,
  (SELECT count(*) FROM public.schema_migrations WHERE version='100')                      AS self_stamped,
  CASE WHEN
       (SELECT count(*) FROM public.pathway_rungs    WHERE rung_key LIKE '%uliplication%')  = 0
   AND (SELECT count(*) FROM public.pathway_progress WHERE rung_key LIKE '%uliplication%')  = 0
   AND (SELECT count(*) FROM public.pathway_versions WHERE doc::text LIKE '%uliplication%') = 0
   AND (SELECT count(*) FROM public.pathway_rungs
          WHERE rung_key = 'x-the-multiplication-effect-idxd') = 1
   AND (SELECT count(*) FROM public.schema_migrations WHERE version='100') = 1
       THEN 'PASS' ELSE 'FAIL' END                                                          AS all_ok;
