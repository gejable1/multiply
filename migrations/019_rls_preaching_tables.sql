-- migrations/019_rls_preaching_tables.sql
-- RLS batch 3 (remainder): preachers / wednesday_preaching / preaching_swap_requests.
-- Anon path closed by the preaching_calendar.html boot gate (commit 841a8bf). Mirrors 016/017/018.

-- ===== preachers =====
UPDATE public.preachers SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS preachers_tenant_select ON public.preachers;
DROP POLICY IF EXISTS preachers_tenant_insert ON public.preachers;
DROP POLICY IF EXISTS preachers_tenant_update ON public.preachers;
DROP POLICY IF EXISTS preachers_tenant_delete ON public.preachers;
CREATE POLICY preachers_tenant_select ON public.preachers FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY preachers_tenant_insert ON public.preachers FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY preachers_tenant_update ON public.preachers FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY preachers_tenant_delete ON public.preachers FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.preachers ENABLE ROW LEVEL SECURITY;

-- ===== wednesday_preaching =====
UPDATE public.wednesday_preaching SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS wednesday_preaching_tenant_select ON public.wednesday_preaching;
DROP POLICY IF EXISTS wednesday_preaching_tenant_insert ON public.wednesday_preaching;
DROP POLICY IF EXISTS wednesday_preaching_tenant_update ON public.wednesday_preaching;
DROP POLICY IF EXISTS wednesday_preaching_tenant_delete ON public.wednesday_preaching;
CREATE POLICY wednesday_preaching_tenant_select ON public.wednesday_preaching FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY wednesday_preaching_tenant_insert ON public.wednesday_preaching FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY wednesday_preaching_tenant_update ON public.wednesday_preaching FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY wednesday_preaching_tenant_delete ON public.wednesday_preaching FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.wednesday_preaching ENABLE ROW LEVEL SECURITY;

-- ===== preaching_swap_requests =====
UPDATE public.preaching_swap_requests SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS preaching_swap_requests_tenant_select ON public.preaching_swap_requests;
DROP POLICY IF EXISTS preaching_swap_requests_tenant_insert ON public.preaching_swap_requests;
DROP POLICY IF EXISTS preaching_swap_requests_tenant_update ON public.preaching_swap_requests;
DROP POLICY IF EXISTS preaching_swap_requests_tenant_delete ON public.preaching_swap_requests;
CREATE POLICY preaching_swap_requests_tenant_select ON public.preaching_swap_requests FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY preaching_swap_requests_tenant_insert ON public.preaching_swap_requests FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY preaching_swap_requests_tenant_update ON public.preaching_swap_requests FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY preaching_swap_requests_tenant_delete ON public.preaching_swap_requests FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.preaching_swap_requests ENABLE ROW LEVEL SECURITY;
