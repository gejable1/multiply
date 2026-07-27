-- 101_auto_rungs_own_lane.sql
-- Session 83. Pathway fork model, Phase 3 -- the database half.
--
-- v_effective_auto_rungs is a SIXTH copy of the overlay resolver, in SQL, and it is
-- the only copy that WRITES: auto_complete_pathway_rungs() joins it to insert rows
-- into pathway_progress. Migration 094 built it with the same precedence rule as the
-- five JS copies:
--
--     SELECT DISTINCT ON (x.level, x.rung_key) x.*
--       FROM public.pathway_rungs x
--      WHERE x.church_id IS NULL OR x.church_id = c.id
--      ORDER BY x.level, x.rung_key, (x.church_id IS NOT NULL) DESC
--
-- After migration 099 every church owns every rung it uses, so the template arm of
-- that WHERE can never win and the DISTINCT ON can never have more than one candidate
-- per key -- pathway_rungs_overlay_uk guarantees it. The precedence logic is now dead
-- weight resolving a race with one runner. This collapses it to the own lane: no
-- churches join, no LATERAL, no DISTINCT ON.
--
-- The self-verify discriminates on LATERAL, not on the WHERE text: Postgres normalises
-- `x.church_id IS NULL OR ...` to `((x.church_id IS NULL) OR ...)`, so a LIKE on the
-- unparenthesised form matches NEITHER view and reports 0 unconditionally.
--
-- AND IT ADDS THE ONE FILTER RETIREMENT NEEDS ON THE WRITE PATH.
-- retired_at landed in migration 098 and is read by nothing. The member-facing arm is
-- frontend work, but the WRITE path is here: without `retired_at IS NULL`, a retired
-- auto rung keeps minting fresh pathway_progress rows forever, every time the
-- auto-completer runs. Retirement would leak the moment Phase 4 shipped a retire
-- button. Existing completions are untouched -- retire never delete.
--
-- THE GATE: the view's full output -- every (church_id, level, rung_key,
-- auto_source_key) tuple -- must be IDENTICAL before and after, because nothing is
-- retired yet. Any difference RAISEs and nothing commits. That is the whole proof
-- that the collapse is an equivalence and not a behaviour change.
--
-- Flat (#209), idempotent, self-verifying on its own effects (#403), stamped in the
-- body (#402). Proven on ephemeral PG16 as postgres (#379) against post-099 forked
-- data, forward, on rerun, and with a rung retired to confirm the new filter bites.

BEGIN;

CREATE TEMP TABLE _auto_before ON COMMIT DROP AS
SELECT church_id, level, rung_key, auto_source_key FROM public.v_effective_auto_rungs;

CREATE OR REPLACE VIEW public.v_effective_auto_rungs AS
SELECT r.church_id, r.level, r.rung_key, r.auto_source_key
  FROM public.pathway_rungs r
 WHERE r.church_id IS NOT NULL
   AND r.retired_at IS NULL
   AND r.completion_source = 'auto'
   AND r.published IS NOT FALSE
   AND r.auto_source_key IS NOT NULL;

ALTER VIEW public.v_effective_auto_rungs SET (security_invoker = true);

COMMENT ON VIEW public.v_effective_auto_rungs IS
  'Auto-completing rungs, own lane only. Each church reads its own rows: after the Phase 2 fork there is no template arm to resolve against, and pathway_rungs_overlay_uk guarantees one row per (church_id, level, rung_key). Excludes retired rungs so retirement stops the write path, not just the read path. Consumed by auto_complete_pathway_rungs().';

DO $gate$
DECLARE v_bad int;
BEGIN
  -- PARENTHESES ARE LOAD-BEARING. EXCEPT and UNION share precedence and associate
  -- left, so without them this parses as ((A EXCEPT B) UNION B) EXCEPT A, which
  -- reconstructs A and subtracts it -- returning 0 however much the sets differ.
  SELECT count(*) INTO v_bad FROM (
    (SELECT church_id, level, rung_key, auto_source_key FROM _auto_before
     EXCEPT ALL
     SELECT church_id, level, rung_key, auto_source_key FROM public.v_effective_auto_rungs)
    UNION ALL
    (SELECT church_id, level, rung_key, auto_source_key FROM public.v_effective_auto_rungs
     EXCEPT ALL
     SELECT church_id, level, rung_key, auto_source_key FROM _auto_before)
  ) d;

  IF v_bad <> 0 THEN
    RAISE EXCEPTION 'AUTO-RUNG GATE FAILED: % tuple(s) differ before vs after. Nothing committed.', v_bad;
  END IF;
END
$gate$;

INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('101','101_auto_rungs_own_lane.sql','Phase 3 (database half): v_effective_auto_rungs collapsed from the overlay resolver to the own lane -- the sixth copy of that rule and the only writing one. Adds retired_at IS NULL so a retired auto rung stops minting pathway_progress rows; without it retirement would leak on the write path the moment a retire button exists. Gated on set-equality of the full view output before vs after.')
ON CONFLICT (version) DO UPDATE SET filename=excluded.filename, note=excluded.note, applied_at=now();

COMMIT;

-- SELF-VERIFY -- expect all_ok = PASS. Asserts only this migration's effects.
SELECT
  (SELECT count(*) FROM pg_views
     WHERE schemaname='public' AND viewname='v_effective_auto_rungs'
       AND definition LIKE '%retired_at%')                                   AS view_filters_retired,
  (SELECT count(*) FROM pg_views
     WHERE schemaname='public' AND viewname='v_effective_auto_rungs'
       AND definition LIKE '%LATERAL%')                                      AS old_resolver_left,
  (SELECT count(*) FROM public.v_effective_auto_rungs)                       AS auto_rungs_now,
  (SELECT count(*) FROM public.v_effective_auto_rungs WHERE church_id IS NULL) AS template_lane_rows,
  (SELECT count(*) FROM public.schema_migrations WHERE version='101')        AS self_stamped,
  CASE WHEN
       (SELECT count(*) FROM pg_views WHERE schemaname='public'
          AND viewname='v_effective_auto_rungs' AND definition LIKE '%retired_at%') = 1
   AND (SELECT count(*) FROM pg_views WHERE schemaname='public'
          AND viewname='v_effective_auto_rungs' AND definition LIKE '%LATERAL%') = 0
   AND (SELECT count(*) FROM public.v_effective_auto_rungs WHERE church_id IS NULL) = 0
   AND (SELECT count(*) FROM public.schema_migrations WHERE version='101') = 1
       THEN 'PASS' ELSE 'FAIL' END                                           AS all_ok;
