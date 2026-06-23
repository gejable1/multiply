-- migrations/022_rls_quiz_attempts_and_view_invoker.sql
-- Closes the SECURITY DEFINER view audit (Session 45): RLS on the 2 quiz-attempt base
-- tables + flip all 6 owner-views to security_invoker so they respect the caller's RLS.
-- All consumers (quiz players/admin/report, member_tool) use getDB() (JWT-attached).
-- RUN FLAT (no BEGIN/COMMIT): an earlier all-or-nothing wrap rolled back on a transient
-- error; statement-by-statement applied clean. Idempotent (DROP IF EXISTS before CREATE;
-- UPDATE touches only NULLs; ENABLE/ALTER VIEW re-runs are no-ops).

-- ===== 6 view flips (respect caller RLS) =====
ALTER VIEW public.v_btli_course_grade    SET (security_invoker = true);
ALTER VIEW public.v_btli_member_best     SET (security_invoker = true);
ALTER VIEW public.v_usbong_course_grade  SET (security_invoker = true);
ALTER VIEW public.v_usbong_lesson_grade  SET (security_invoker = true);
ALTER VIEW public.v_pending_transfers    SET (security_invoker = true);
ALTER VIEW public.v_svi_latest           SET (security_invoker = true);

-- ===== btli_quiz_attempts =====
UPDATE public.btli_quiz_attempts SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS btli_quiz_attempts_tenant_select ON public.btli_quiz_attempts;
DROP POLICY IF EXISTS btli_quiz_attempts_tenant_insert ON public.btli_quiz_attempts;
DROP POLICY IF EXISTS btli_quiz_attempts_tenant_update ON public.btli_quiz_attempts;
DROP POLICY IF EXISTS btli_quiz_attempts_tenant_delete ON public.btli_quiz_attempts;
CREATE POLICY btli_quiz_attempts_tenant_select ON public.btli_quiz_attempts FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY btli_quiz_attempts_tenant_insert ON public.btli_quiz_attempts FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY btli_quiz_attempts_tenant_update ON public.btli_quiz_attempts FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY btli_quiz_attempts_tenant_delete ON public.btli_quiz_attempts FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.btli_quiz_attempts ENABLE ROW LEVEL SECURITY;

-- ===== usbong_quiz_attempts =====
UPDATE public.usbong_quiz_attempts SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS usbong_quiz_attempts_tenant_select ON public.usbong_quiz_attempts;
DROP POLICY IF EXISTS usbong_quiz_attempts_tenant_insert ON public.usbong_quiz_attempts;
DROP POLICY IF EXISTS usbong_quiz_attempts_tenant_update ON public.usbong_quiz_attempts;
DROP POLICY IF EXISTS usbong_quiz_attempts_tenant_delete ON public.usbong_quiz_attempts;
CREATE POLICY usbong_quiz_attempts_tenant_select ON public.usbong_quiz_attempts FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY usbong_quiz_attempts_tenant_insert ON public.usbong_quiz_attempts FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY usbong_quiz_attempts_tenant_update ON public.usbong_quiz_attempts FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY usbong_quiz_attempts_tenant_delete ON public.usbong_quiz_attempts FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.usbong_quiz_attempts ENABLE ROW LEVEL SECURITY;
