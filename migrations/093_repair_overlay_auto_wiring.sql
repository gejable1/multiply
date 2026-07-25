-- migrations/093_repair_overlay_auto_wiring.sql
-- REPAIR. Session 81. Restores the auto-wiring the poster editor silently dropped.
--
-- ROOT CAUSE. leadership_pipeline.html's customizeBase() builds its overlay row
-- from four form fields only -- { title_en, description_en, trackable, published,
-- meta } -- and never carries completion_source or auto_source_key from the base
-- rung it overrides. The strings 'completion_source' and 'auto_source_key' do not
-- appear anywhere in that file. So the DB defaults applied: completion_source
-- became 'manual' and auto_source_key became NULL. A pastor who merely retitled a
-- rung silently un-wired it from the auto-completion engine. Nobody chose that.
--
-- WHY IT WAS INVISIBLE. Migration 084's engine joins BASE rungs only
-- (r.church_id IS NULL), so it kept ticking those rungs from the base definition
-- and members still saw their checkmarks. The engine's own base-only bug was
-- masking the editor's bug. Auto-completion v2 (which honours the overlay) would
-- have exposed it as a REGRESSION -- existing members keeping a tick that new
-- members could never earn -- so this repair must land BEFORE v2.
--
-- SCOPE. Live diagnostic (read-only, run by the Pastor) found exactly 2 damaged
-- rows, both Rosehill: L2 'conflict' (base auto:assessment:conflict) and L2 'disc'
-- (base auto:assessment:disc). The 131 pathway_progress rows already written for
-- them are LEGITIMATE -- those members really did take the assessments -- and are
-- deliberately left untouched. This migration repairs catalog wiring only; it
-- writes nothing to pathway_progress.
--
-- The UPDATE is written generically (any church, any rung) because the editor
-- offers no way to deliberately turn a base auto rung manual -- there is no such
-- control in the UI -- so every row matching this shape is editor damage.
--
-- Flat (#209), idempotent, self-verifying (#210), ledger-stamped. PG16-proven (#379).

UPDATE public.pathway_rungs o
   SET completion_source = b.completion_source,
       auto_source_key   = b.auto_source_key,
       updated_at        = now()
  FROM public.pathway_rungs b
 WHERE o.church_id IS NOT NULL
   AND b.church_id IS NULL
   AND b.level    = o.level
   AND b.rung_key = o.rung_key
   AND b.completion_source = 'auto'
   AND b.auto_source_key IS NOT NULL
   AND o.completion_source = 'manual'
   AND o.auto_source_key IS NULL;

INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('093','093_repair_overlay_auto_wiring.sql','REPAIR: restore completion_source + auto_source_key on overlay rungs the poster editor silently un-wired (2 rows: Rosehill L2 conflict + disc); pathway_progress untouched')
ON CONFLICT (version) DO UPDATE SET filename=excluded.filename, note=excluded.note, applied_at=now();

-- SELF-VERIFY -- expect damaged_rows_remaining = 0 and all_ok = PASS.
SELECT
  (SELECT count(*) FROM public.pathway_rungs o
     JOIN public.pathway_rungs b
       ON b.church_id IS NULL AND b.level = o.level AND b.rung_key = o.rung_key
    WHERE o.church_id IS NOT NULL
      AND b.completion_source = 'auto' AND b.auto_source_key IS NOT NULL
      AND o.completion_source = 'manual' AND o.auto_source_key IS NULL)      AS damaged_rows_remaining,
  (SELECT count(*) FROM public.pathway_rungs
    WHERE church_id IS NOT NULL AND completion_source = 'auto')              AS overlay_auto_rungs_now,
  (SELECT count(*) FROM public.pathway_progress WHERE note LIKE 'auto:%')    AS auto_progress_rows_untouched,
  CASE WHEN (SELECT count(*) FROM public.pathway_rungs o
               JOIN public.pathway_rungs b
                 ON b.church_id IS NULL AND b.level = o.level AND b.rung_key = o.rung_key
              WHERE o.church_id IS NOT NULL
                AND b.completion_source = 'auto' AND b.auto_source_key IS NOT NULL
                AND o.completion_source = 'manual' AND o.auto_source_key IS NULL) = 0
       THEN 'PASS' ELSE 'FAIL' END                                           AS all_ok;
