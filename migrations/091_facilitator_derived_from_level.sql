-- 091_facilitator_derived_from_level.sql
-- Session 80: is_facilitator is DERIVED from pipeline_level, not a manual toggle.
--
-- Doctrine (Pastor's call): advancing L1->L2 now requires having disciples, so
-- L2+ and "is a facilitator/leader" are the same thing. is_facilitator is what
-- auth_is_leader() reads (migration 069) -- it gates meeting-guide LIBRARY
-- access -- and what MD reads to show the leader badge, the discipler picker,
-- the announcement audience, etc. Several tenant PASTORS (L5) were never flagged
-- and were silently locked out of their own church library. This couples the two
-- for good, in both directions (fully derived):
--
--   is_facilitator := (pipeline_level >= 2)
--
-- and, when flagging ON and the role is empty, a level-aware default role:
--   L5+  -> 'Pastor'
--   L2-4 -> 'LC Leader'
-- An existing non-empty facilitator_role is NEVER overwritten.
--
-- Enforced by a BEFORE INSERT OR UPDATE trigger so EVERY write path (MD, MLT,
-- bulk, EF, direct SQL) obeys it and it can never drift. Composes with the 050
-- privilege-guard trigger: only a pastor (L5) can change pipeline_level, so the
-- coupling only ever fires on a pastor's edit -- no conflict.
--
-- Flat (#209), idempotent, self-verifying (#210). PG16-proven (#379).

-- the coupling function
CREATE OR REPLACE FUNCTION public.members_derive_facilitator()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF COALESCE(NEW.pipeline_level, 0) >= 2 THEN
    NEW.is_facilitator := true;
    IF NULLIF(NEW.facilitator_role, '') IS NULL THEN
      NEW.facilitator_role := CASE WHEN NEW.pipeline_level >= 5 THEN 'Pastor' ELSE 'LC Leader' END;
    END IF;
  ELSE
    NEW.is_facilitator := false;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_members_derive_facilitator ON public.members;
CREATE TRIGGER trg_members_derive_facilitator
  BEFORE INSERT OR UPDATE ON public.members
  FOR EACH ROW EXECUTE FUNCTION public.members_derive_facilitator();

-- one-time backfill: align every existing row to the rule.
UPDATE public.members
   SET is_facilitator = true,
       facilitator_role = COALESCE(
         NULLIF(facilitator_role, ''),
         CASE WHEN pipeline_level >= 5 THEN 'Pastor' ELSE 'LC Leader' END)
 WHERE COALESCE(pipeline_level, 0) >= 2
   AND (is_facilitator IS NOT true OR NULLIF(facilitator_role, '') IS NULL);

UPDATE public.members
   SET is_facilitator = false
 WHERE COALESCE(pipeline_level, 0) < 2
   AND is_facilitator IS true;

INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('091','091_facilitator_derived_from_level.sql','S80: is_facilitator derived from pipeline_level (>=2) via trigger + backfill; L5 role=Pastor, L2-4=LC Leader when empty')
ON CONFLICT (version) DO NOTHING;

SELECT
  (SELECT count(*) FROM pg_trigger
     WHERE tgname='trg_members_derive_facilitator' AND NOT tgisinternal) = 1        AS trigger_exists,
  (SELECT count(*) FROM public.members
     WHERE COALESCE(pipeline_level,0) >= 2 AND is_facilitator IS NOT true) = 0       AS all_l2plus_flagged,
  (SELECT count(*) FROM public.members
     WHERE COALESCE(pipeline_level,0) < 2 AND is_facilitator IS true) = 0            AS no_sub_l2_flagged,
  (SELECT count(*) FROM public.members
     WHERE COALESCE(pipeline_level,0) >= 2 AND NULLIF(facilitator_role,'') IS NULL) = 0 AS all_l2plus_have_role;
