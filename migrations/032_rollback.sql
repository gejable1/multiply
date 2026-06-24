DROP POLICY IF EXISTS svi_weight_profiles_tenant_select ON public.svi_weight_profiles;
DROP POLICY IF EXISTS svi_weight_profiles_tenant_insert ON public.svi_weight_profiles;
DROP POLICY IF EXISTS svi_weight_profiles_tenant_update ON public.svi_weight_profiles;
DROP POLICY IF EXISTS svi_weight_profiles_tenant_delete ON public.svi_weight_profiles;
CREATE POLICY svi_profiles_read  ON public.svi_weight_profiles FOR SELECT TO public USING (true);
CREATE POLICY svi_profiles_write ON public.svi_weight_profiles FOR ALL TO public USING (auth.role()='service_role') WITH CHECK (auth.role()='service_role');
