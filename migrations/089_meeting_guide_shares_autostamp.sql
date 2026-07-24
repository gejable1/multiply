-- 089_meeting_guide_shares_autostamp.sql
-- Session 80 HOTFIX for 088.
--
-- Migration 014 attached trg_set_church_id to every table that had a church_id
-- AT THAT TIME. Tables created later must attach it explicitly -- 025, 030 and
-- 047 all do. 088 did not, so lc_meeting_guide_shares had no autostamp.
--
-- MLT does not load multiply_tenancy.js, so the client cannot supply church_id.
-- The row therefore arrived with church_id NULL, and lcmgs_insert's
-- WITH CHECK (church_id = auth_church_id()) compared against NULL and failed --
-- surfacing as 42501 "new row violates row-level security policy", NOT as a
-- NOT NULL error, because the policy check bites first. The Assign button in
-- MLT failed for EVERY member (nothing to do with test vs real members).
--
-- The trigger only fills church_id when it is NULL and never overwrites, so a
-- forged foreign church_id is still rejected by WITH CHECK. Proven on PG16.
--
-- Flat (#209), idempotent, self-verifying (#210).

DROP TRIGGER IF EXISTS trg_set_church_id ON public.lc_meeting_guide_shares;
CREATE TRIGGER trg_set_church_id BEFORE INSERT ON public.lc_meeting_guide_shares
  FOR EACH ROW EXECUTE FUNCTION public.set_church_id_from_jwt();

INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('089','089_meeting_guide_shares_autostamp.sql','S80 hotfix: attach trg_set_church_id to lc_meeting_guide_shares (088 omitted it; Assign failed 42501)')
ON CONFLICT (version) DO NOTHING;

SELECT
  (SELECT count(*) FROM pg_trigger t
     JOIN pg_class c ON c.oid = t.tgrelid
    WHERE c.relname = 'lc_meeting_guide_shares'
      AND t.tgname  = 'trg_set_church_id'
      AND NOT t.tgisinternal) = 1                                        AS trigger_attached,
  (SELECT count(*) FROM pg_proc WHERE proname = 'set_church_id_from_jwt') = 1 AS fn_present,
  (SELECT count(*) FROM public.lc_meeting_guide_shares
    WHERE church_id IS NULL) = 0                                          AS no_null_church_rows,
  (SELECT count(*) FROM pg_policies
    WHERE tablename = 'lc_meeting_guide_shares') = 3                      AS policies_intact;
