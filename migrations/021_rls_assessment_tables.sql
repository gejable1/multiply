-- migrations/021_rls_assessment_tables.sql
-- Session 42 (applied) — RLS on the two assessment tables: member_profiles + gifts_diagnostic.
-- VERSION-OF-RECORD reconstruction (Session 46): this RLS is ALREADY LIVE (applied via dashboard
-- in S42, isolation-proven). This file mirrors the live state so the migrations/ folder matches the
-- DB; it is a no-op on re-run. Pattern mirrors 016–025: drop the old anon allow-all stubs +
-- any prior tenant policies -> 4 TO authenticated policies on auth_church_id() -> ENABLE.
-- Autostamp (trg_set_church_id) is already attached via 014 (both tables have church_id, not excluded).
-- RUN FLAT (no BEGIN/COMMIT) — Inv #209. Idempotent.

-- ===== member_profiles =====
UPDATE public.member_profiles SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS "Enable all for anon" ON public.member_profiles;
DROP POLICY IF EXISTS member_profiles_select ON public.member_profiles;
DROP POLICY IF EXISTS member_profiles_insert ON public.member_profiles;
DROP POLICY IF EXISTS member_profiles_update ON public.member_profiles;
DROP POLICY IF EXISTS member_profiles_delete ON public.member_profiles;
CREATE POLICY member_profiles_select ON public.member_profiles FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY member_profiles_insert ON public.member_profiles FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY member_profiles_update ON public.member_profiles FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY member_profiles_delete ON public.member_profiles FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.member_profiles ENABLE ROW LEVEL SECURITY;

-- ===== gifts_diagnostic =====
UPDATE public.gifts_diagnostic SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS "Enable all for anon" ON public.gifts_diagnostic;
DROP POLICY IF EXISTS gifts_diagnostic_select ON public.gifts_diagnostic;
DROP POLICY IF EXISTS gifts_diagnostic_insert ON public.gifts_diagnostic;
DROP POLICY IF EXISTS gifts_diagnostic_update ON public.gifts_diagnostic;
DROP POLICY IF EXISTS gifts_diagnostic_delete ON public.gifts_diagnostic;
CREATE POLICY gifts_diagnostic_select ON public.gifts_diagnostic FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY gifts_diagnostic_insert ON public.gifts_diagnostic FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY gifts_diagnostic_update ON public.gifts_diagnostic FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY gifts_diagnostic_delete ON public.gifts_diagnostic FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.gifts_diagnostic ENABLE ROW LEVEL SECURITY;

-- ===== ledger: replace the provisional '(file pending)' row with the real filename =====
INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('021','021_rls_assessment_tables.sql','RLS assessment tables: member_profiles + gifts_diagnostic (applied S42, file committed S46)')
ON CONFLICT (version) DO UPDATE SET filename=EXCLUDED.filename, note=EXCLUDED.note, applied_at=now();
