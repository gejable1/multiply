-- =====================================================================
-- 085_svi_snapshots_rls_scope.sql
-- FIX a cross-church READ LEAK on svi_snapshots. RLS was enabled but the
-- read policy `svi_snapshots_read` used USING (true) — an allow-all stub —
-- so any authenticated user's SVI report saw EVERY church's snapshots
-- (the "301" the Pastor saw). This table predates the S46 tenancy sweep
-- (its policies were named _read/_write, not _tenant_*), so the sweep missed it.
-- Fix: drop the allow-all read stub, add the standard church-scoped SELECT
-- policy (church_id = auth_church_id()), matching the sweep. Write policy
-- (svi_snapshots_write, service_role only) is left untouched — the EF still
-- writes cross-church, and it reads via service-role which bypasses RLS.
--
-- Isolation must be proven IN-BROWSER (the SQL editor bypasses RLS). This
-- migration self-verifies the POLICY DDL only.
-- Human-gated: run in Supabase SQL Editor (expect all_ok=PASS), commit.
-- =====================================================================

-- 1) Drop the allow-all read stub (the leak).
DROP POLICY IF EXISTS svi_snapshots_read ON public.svi_snapshots;

-- 2) Add the church-scoped SELECT policy (idempotent).
DROP POLICY IF EXISTS svi_snapshots_tenant_select ON public.svi_snapshots;
CREATE POLICY svi_snapshots_tenant_select ON public.svi_snapshots
  FOR SELECT TO authenticated USING (church_id = public.auth_church_id());

-- 3) Stamp the migration ledger.
INSERT INTO schema_migrations (version, filename, note)
VALUES ('085','085_svi_snapshots_rls_scope.sql','Fix svi_snapshots cross-church read leak: drop allow-all svi_snapshots_read (USING true), add church-scoped svi_snapshots_tenant_select')
ON CONFLICT (version) DO NOTHING;

-- 4) Self-verify the policy DDL (rerun until all_ok=PASS).
SELECT
  (SELECT relrowsecurity FROM pg_class WHERE relname='svi_snapshots' AND relnamespace='public'::regnamespace) AS rls_on,
  NOT EXISTS(SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='svi_snapshots' AND policyname='svi_snapshots_read') AS stub_dropped,
  EXISTS(SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='svi_snapshots' AND policyname='svi_snapshots_tenant_select' AND qual LIKE '%auth_church_id%') AS scoped_present,
  NOT EXISTS(SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='svi_snapshots' AND cmd='SELECT' AND qual='true') AS no_allowall_select,
  CASE WHEN
        (SELECT relrowsecurity FROM pg_class WHERE relname='svi_snapshots' AND relnamespace='public'::regnamespace)
    AND NOT EXISTS(SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='svi_snapshots' AND policyname='svi_snapshots_read')
    AND EXISTS(SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='svi_snapshots' AND policyname='svi_snapshots_tenant_select' AND qual LIKE '%auth_church_id%')
    AND NOT EXISTS(SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='svi_snapshots' AND cmd='SELECT' AND qual='true')
       THEN 'PASS' ELSE 'FAIL' END AS all_ok;
