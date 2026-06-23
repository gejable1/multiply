-- migrations/018_rls_sermons.sql
UPDATE public.sermons SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS sermons_tenant_select ON public.sermons;
DROP POLICY IF EXISTS sermons_tenant_insert ON public.sermons;
DROP POLICY IF EXISTS sermons_tenant_update ON public.sermons;
DROP POLICY IF EXISTS sermons_tenant_delete ON public.sermons;
CREATE POLICY sermons_tenant_select ON public.sermons FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY sermons_tenant_insert ON public.sermons FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY sermons_tenant_update ON public.sermons FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY sermons_tenant_delete ON public.sermons FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.sermons ENABLE ROW LEVEL SECURITY;
