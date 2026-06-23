-- migrations/016_rls_cohort_lesson_family.sql
-- RLS batch 1: cohort/lesson enrollment + lock family. Mirrors the 015 canary.
-- Backfill via churches.slug (no hardcoded UUID). Idempotent: safe to re-run.

-- ===== cohorts =====
UPDATE public.cohorts SET church_id = (SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS cohorts_tenant_select ON public.cohorts;
DROP POLICY IF EXISTS cohorts_tenant_insert ON public.cohorts;
DROP POLICY IF EXISTS cohorts_tenant_update ON public.cohorts;
DROP POLICY IF EXISTS cohorts_tenant_delete ON public.cohorts;
CREATE POLICY cohorts_tenant_select ON public.cohorts FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY cohorts_tenant_insert ON public.cohorts FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY cohorts_tenant_update ON public.cohorts FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY cohorts_tenant_delete ON public.cohorts FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.cohorts ENABLE ROW LEVEL SECURITY;

-- ===== cohort_members =====
UPDATE public.cohort_members SET church_id = (SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS cohort_members_tenant_select ON public.cohort_members;
DROP POLICY IF EXISTS cohort_members_tenant_insert ON public.cohort_members;
DROP POLICY IF EXISTS cohort_members_tenant_update ON public.cohort_members;
DROP POLICY IF EXISTS cohort_members_tenant_delete ON public.cohort_members;
CREATE POLICY cohort_members_tenant_select ON public.cohort_members FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY cohort_members_tenant_insert ON public.cohort_members FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY cohort_members_tenant_update ON public.cohort_members FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY cohort_members_tenant_delete ON public.cohort_members FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.cohort_members ENABLE ROW LEVEL SECURITY;

-- ===== cohort_lesson_unlocks =====
UPDATE public.cohort_lesson_unlocks SET church_id = (SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS cohort_lesson_unlocks_tenant_select ON public.cohort_lesson_unlocks;
DROP POLICY IF EXISTS cohort_lesson_unlocks_tenant_insert ON public.cohort_lesson_unlocks;
DROP POLICY IF EXISTS cohort_lesson_unlocks_tenant_update ON public.cohort_lesson_unlocks;
DROP POLICY IF EXISTS cohort_lesson_unlocks_tenant_delete ON public.cohort_lesson_unlocks;
CREATE POLICY cohort_lesson_unlocks_tenant_select ON public.cohort_lesson_unlocks FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY cohort_lesson_unlocks_tenant_insert ON public.cohort_lesson_unlocks FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY cohort_lesson_unlocks_tenant_update ON public.cohort_lesson_unlocks FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY cohort_lesson_unlocks_tenant_delete ON public.cohort_lesson_unlocks FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.cohort_lesson_unlocks ENABLE ROW LEVEL SECURITY;

-- ===== pipeline_lesson_grants =====
UPDATE public.pipeline_lesson_grants SET church_id = (SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS pipeline_lesson_grants_tenant_select ON public.pipeline_lesson_grants;
DROP POLICY IF EXISTS pipeline_lesson_grants_tenant_insert ON public.pipeline_lesson_grants;
DROP POLICY IF EXISTS pipeline_lesson_grants_tenant_update ON public.pipeline_lesson_grants;
DROP POLICY IF EXISTS pipeline_lesson_grants_tenant_delete ON public.pipeline_lesson_grants;
CREATE POLICY pipeline_lesson_grants_tenant_select ON public.pipeline_lesson_grants FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY pipeline_lesson_grants_tenant_insert ON public.pipeline_lesson_grants FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY pipeline_lesson_grants_tenant_update ON public.pipeline_lesson_grants FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY pipeline_lesson_grants_tenant_delete ON public.pipeline_lesson_grants FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.pipeline_lesson_grants ENABLE ROW LEVEL SECURITY;
