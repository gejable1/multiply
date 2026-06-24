-- migrations/032_svi_weight_profiles_rls.sql
-- Session 47 — svi_weight_profiles per-church isolation. Carries church_id since 001
-- (backfilled Rosehill) but never got tenant RLS: read was public USING(true) (cross-church
-- leak) and write was service_role-only (conflicting with MD's client-side saveSviWeights()).
-- Replace both with 4 tenant policies on auth_church_id(). svi_metrics stays GLOBAL (untouched).
-- RLS already enabled live. service_role (compute-svi EF) bypasses RLS. FLAT (#209), self-verify (#210).
UPDATE public.svi_weight_profiles SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS svi_profiles_read  ON public.svi_weight_profiles;
DROP POLICY IF EXISTS svi_profiles_write ON public.svi_weight_profiles;
DROP POLICY IF EXISTS svi_weight_profiles_tenant_select ON public.svi_weight_profiles;
DROP POLICY IF EXISTS svi_weight_profiles_tenant_insert ON public.svi_weight_profiles;
DROP POLICY IF EXISTS svi_weight_profiles_tenant_update ON public.svi_weight_profiles;
DROP POLICY IF EXISTS svi_weight_profiles_tenant_delete ON public.svi_weight_profiles;
CREATE POLICY svi_weight_profiles_tenant_select ON public.svi_weight_profiles FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY svi_weight_profiles_tenant_insert ON public.svi_weight_profiles FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY svi_weight_profiles_tenant_update ON public.svi_weight_profiles FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY svi_weight_profiles_tenant_delete ON public.svi_weight_profiles FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
DROP TRIGGER IF EXISTS trg_set_church_id ON public.svi_weight_profiles;
CREATE TRIGGER trg_set_church_id BEFORE INSERT ON public.svi_weight_profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_church_id_from_jwt();
ALTER TABLE public.svi_weight_profiles ENABLE ROW LEVEL SECURITY;
INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('032','032_svi_weight_profiles_rls.sql','svi_weight_profiles per-church RLS: drop public read-all + service_role-only write, 4 tenant policies on auth_church_id(), autostamp re-assert; svi_metrics left global')
ON CONFLICT (version) DO UPDATE SET filename=EXCLUDED.filename, note=EXCLUDED.note, applied_at=now();
SELECT
  c.relrowsecurity AS rls_enabled,
  (SELECT count(*) FROM pg_policies p WHERE p.schemaname='public' AND p.tablename='svi_weight_profiles') AS policy_count,
  (SELECT count(*) FROM public.svi_weight_profiles WHERE church_id IS NULL) AS null_church,
  (SELECT count(*) FROM pg_policies p WHERE p.schemaname='public' AND p.tablename='svi_weight_profiles' AND p.roles::text ~ '(anon|public)' AND coalesce(p.qual,'')='true') AS allow_all_stubs
FROM pg_class c WHERE c.oid='public.svi_weight_profiles'::regclass;
