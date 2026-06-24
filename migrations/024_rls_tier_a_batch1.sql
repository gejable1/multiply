-- migrations/024_rls_tier_a_batch1.sql
-- Session 46 — RLS-coverage sweep, tier-a batch 1 (6 tables). Inv #208.
-- Pattern (per table, mirrors 016–022): backfill NULL church_id -> Rosehill ->
-- DROP every allow-all stub (Inv #186) -> 4 TO authenticated policies on
-- auth_church_id() -> ENABLE. Tables: ministries, ministry_roles,
-- devotional_reflections, diagnostic_results, attendance, profile_tokens.
-- NOT here: devotionals (NULL=shared -> 025) and system_settings (anon admin page -> deferred).
-- RUN FLAT (no BEGIN/COMMIT) — Inv #209. Idempotent: UPDATE touches only NULLs;
-- DROP POLICY IF EXISTS before CREATE; ENABLE re-run is a no-op.

-- ===== ministries (0 NULL) =====
UPDATE public.ministries SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS ministries_read  ON public.ministries;
DROP POLICY IF EXISTS ministries_write ON public.ministries;
DROP POLICY IF EXISTS ministries_tenant_select ON public.ministries;
DROP POLICY IF EXISTS ministries_tenant_insert ON public.ministries;
DROP POLICY IF EXISTS ministries_tenant_update ON public.ministries;
DROP POLICY IF EXISTS ministries_tenant_delete ON public.ministries;
CREATE POLICY ministries_tenant_select ON public.ministries FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY ministries_tenant_insert ON public.ministries FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY ministries_tenant_update ON public.ministries FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY ministries_tenant_delete ON public.ministries FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.ministries ENABLE ROW LEVEL SECURITY;

-- ===== ministry_roles (0 NULL) =====
UPDATE public.ministry_roles SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS ministry_roles_read  ON public.ministry_roles;
DROP POLICY IF EXISTS ministry_roles_write ON public.ministry_roles;
DROP POLICY IF EXISTS ministry_roles_tenant_select ON public.ministry_roles;
DROP POLICY IF EXISTS ministry_roles_tenant_insert ON public.ministry_roles;
DROP POLICY IF EXISTS ministry_roles_tenant_update ON public.ministry_roles;
DROP POLICY IF EXISTS ministry_roles_tenant_delete ON public.ministry_roles;
CREATE POLICY ministry_roles_tenant_select ON public.ministry_roles FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY ministry_roles_tenant_insert ON public.ministry_roles FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY ministry_roles_tenant_update ON public.ministry_roles FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY ministry_roles_tenant_delete ON public.ministry_roles FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.ministry_roles ENABLE ROW LEVEL SECURITY;

-- ===== devotional_reflections (537 NULL -> Rosehill) =====
UPDATE public.devotional_reflections SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS reflections_read  ON public.devotional_reflections;
DROP POLICY IF EXISTS reflections_write ON public.devotional_reflections;
DROP POLICY IF EXISTS devotional_reflections_tenant_select ON public.devotional_reflections;
DROP POLICY IF EXISTS devotional_reflections_tenant_insert ON public.devotional_reflections;
DROP POLICY IF EXISTS devotional_reflections_tenant_update ON public.devotional_reflections;
DROP POLICY IF EXISTS devotional_reflections_tenant_delete ON public.devotional_reflections;
CREATE POLICY devotional_reflections_tenant_select ON public.devotional_reflections FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY devotional_reflections_tenant_insert ON public.devotional_reflections FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY devotional_reflections_tenant_update ON public.devotional_reflections FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY devotional_reflections_tenant_delete ON public.devotional_reflections FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.devotional_reflections ENABLE ROW LEVEL SECURITY;

-- ===== diagnostic_results (17 NULL -> Rosehill) =====
UPDATE public.diagnostic_results SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS "Enable all for anon" ON public.diagnostic_results;
DROP POLICY IF EXISTS diagnostic_results_tenant_select ON public.diagnostic_results;
DROP POLICY IF EXISTS diagnostic_results_tenant_insert ON public.diagnostic_results;
DROP POLICY IF EXISTS diagnostic_results_tenant_update ON public.diagnostic_results;
DROP POLICY IF EXISTS diagnostic_results_tenant_delete ON public.diagnostic_results;
CREATE POLICY diagnostic_results_tenant_select ON public.diagnostic_results FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY diagnostic_results_tenant_insert ON public.diagnostic_results FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY diagnostic_results_tenant_update ON public.diagnostic_results FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY diagnostic_results_tenant_delete ON public.diagnostic_results FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.diagnostic_results ENABLE ROW LEVEL SECURITY;

-- ===== attendance (1670 NULL -> Rosehill) =====
UPDATE public.attendance SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS att_select_anon ON public.attendance;
DROP POLICY IF EXISTS att_insert_anon ON public.attendance;
DROP POLICY IF EXISTS att_update_anon ON public.attendance;
DROP POLICY IF EXISTS att_delete_anon ON public.attendance;
DROP POLICY IF EXISTS attendance_tenant_select ON public.attendance;
DROP POLICY IF EXISTS attendance_tenant_insert ON public.attendance;
DROP POLICY IF EXISTS attendance_tenant_update ON public.attendance;
DROP POLICY IF EXISTS attendance_tenant_delete ON public.attendance;
CREATE POLICY attendance_tenant_select ON public.attendance FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY attendance_tenant_insert ON public.attendance FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY attendance_tenant_update ON public.attendance FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY attendance_tenant_delete ON public.attendance FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;

-- ===== profile_tokens (10 NULL -> Rosehill; token-login EF is service-role, bypasses RLS) =====
UPDATE public.profile_tokens SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS "anyone can insert profile_tokens" ON public.profile_tokens;
DROP POLICY IF EXISTS "anyone can read profile_tokens"   ON public.profile_tokens;
DROP POLICY IF EXISTS "anyone can write profile_tokens"  ON public.profile_tokens;
DROP POLICY IF EXISTS profile_tokens_tenant_select ON public.profile_tokens;
DROP POLICY IF EXISTS profile_tokens_tenant_insert ON public.profile_tokens;
DROP POLICY IF EXISTS profile_tokens_tenant_update ON public.profile_tokens;
DROP POLICY IF EXISTS profile_tokens_tenant_delete ON public.profile_tokens;
CREATE POLICY profile_tokens_tenant_select ON public.profile_tokens FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY profile_tokens_tenant_insert ON public.profile_tokens FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY profile_tokens_tenant_update ON public.profile_tokens FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY profile_tokens_tenant_delete ON public.profile_tokens FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.profile_tokens ENABLE ROW LEVEL SECURITY;

-- ===== ledger self-stamp =====
INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('024','024_rls_tier_a_batch1.sql','RLS tier-a batch 1: ministries, ministry_roles, devotional_reflections, diagnostic_results, attendance, profile_tokens')
ON CONFLICT (version) DO UPDATE SET filename=EXCLUDED.filename, note=EXCLUDED.note, applied_at=now();
