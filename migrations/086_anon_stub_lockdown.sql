-- =====================================================================
-- 086_anon_stub_lockdown.sql
-- SECURITY: close two cross-church ANON read/WRITE leaks missed by the S46
-- tenancy sweep. Both interventions and ministry_intake had RLS enabled but
-- their ONLY policy was `Enable all for anon` (ALL, roles={anon}, USING true,
-- WITH CHECK true) — so an UNAUTHENTICATED caller could read and write every
-- church's rows, and authenticated callers had no scoped policy at all.
-- Fix (mirrors 024/026): drop the anon stub, add the 4 church-scoped
-- `authenticated` CRUD policies (church_id = auth_church_id()). Service-role
-- (the SVI EF) bypasses RLS, unchanged. intervention_tracker.html uses the
-- authenticated JWT (getDB), so it now reads/writes ONLY its own church.
--
-- Isolation must be proven IN-BROWSER + a live intervention_tracker save must
-- be re-tested. This migration self-verifies the policy DDL only.
-- Human-gated: run in Supabase SQL Editor (expect all_ok=PASS), commit.
-- =====================================================================

-- ---- interventions ----
ALTER TABLE public.interventions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable all for anon" ON public.interventions;
DROP POLICY IF EXISTS interventions_tenant_select ON public.interventions;
DROP POLICY IF EXISTS interventions_tenant_insert ON public.interventions;
DROP POLICY IF EXISTS interventions_tenant_update ON public.interventions;
DROP POLICY IF EXISTS interventions_tenant_delete ON public.interventions;
CREATE POLICY interventions_tenant_select ON public.interventions FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY interventions_tenant_insert ON public.interventions FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY interventions_tenant_update ON public.interventions FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY interventions_tenant_delete ON public.interventions FOR DELETE TO authenticated USING (church_id = public.auth_church_id());

-- ---- ministry_intake ----
ALTER TABLE public.ministry_intake ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable all for anon" ON public.ministry_intake;
DROP POLICY IF EXISTS ministry_intake_tenant_select ON public.ministry_intake;
DROP POLICY IF EXISTS ministry_intake_tenant_insert ON public.ministry_intake;
DROP POLICY IF EXISTS ministry_intake_tenant_update ON public.ministry_intake;
DROP POLICY IF EXISTS ministry_intake_tenant_delete ON public.ministry_intake;
CREATE POLICY ministry_intake_tenant_select ON public.ministry_intake FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY ministry_intake_tenant_insert ON public.ministry_intake FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY ministry_intake_tenant_update ON public.ministry_intake FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY ministry_intake_tenant_delete ON public.ministry_intake FOR DELETE TO authenticated USING (church_id = public.auth_church_id());

-- ---- ledger ----
INSERT INTO schema_migrations (version, filename, note)
VALUES ('086','086_anon_stub_lockdown.sql','SECURITY: drop Enable-all-for-anon stubs on interventions + ministry_intake; add church-scoped authenticated CRUD policies (S46 sweep pattern)')
ON CONFLICT (version) DO NOTHING;

-- ---- self-verify (rerun until all_ok=PASS) ----
SELECT
  NOT EXISTS(SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename IN ('interventions','ministry_intake') AND policyname='Enable all for anon') AS anon_stubs_dropped,
  (SELECT count(*) FROM pg_policies WHERE schemaname='public' AND tablename='interventions'   AND policyname LIKE 'interventions_tenant_%')   AS interventions_policies,
  (SELECT count(*) FROM pg_policies WHERE schemaname='public' AND tablename='ministry_intake' AND policyname LIKE 'ministry_intake_tenant_%') AS ministry_policies,
  NOT EXISTS(SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename IN ('interventions','ministry_intake') AND qual='true') AS no_allowall_left,
  CASE WHEN
        NOT EXISTS(SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename IN ('interventions','ministry_intake') AND policyname='Enable all for anon')
    AND (SELECT count(*) FROM pg_policies WHERE schemaname='public' AND tablename='interventions'   AND policyname LIKE 'interventions_tenant_%')=4
    AND (SELECT count(*) FROM pg_policies WHERE schemaname='public' AND tablename='ministry_intake' AND policyname LIKE 'ministry_intake_tenant_%')=4
    AND NOT EXISTS(SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename IN ('interventions','ministry_intake') AND qual='true')
       THEN 'PASS' ELSE 'FAIL' END AS all_ok;
