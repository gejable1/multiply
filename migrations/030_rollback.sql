ALTER TABLE public.system_settings DISABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS system_settings_tenant_select ON public.system_settings;
DROP POLICY IF EXISTS system_settings_tenant_insert ON public.system_settings;
DROP POLICY IF EXISTS system_settings_tenant_update ON public.system_settings;
DROP POLICY IF EXISTS system_settings_tenant_delete ON public.system_settings;
-- full structural revert (only if needed):
-- ALTER TABLE public.system_settings DROP CONSTRAINT IF EXISTS system_settings_church_uniq;
-- ALTER TABLE public.system_settings ALTER COLUMN id SET DEFAULT 1;
