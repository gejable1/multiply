-- migrations/020_members_rls.sql — RLS on `members` (the LAST per-church table)
BEGIN;

-- 1) Drop the two PUBLIC allow-all stubs (Inv #186) — they would defeat isolation on ENABLE.
DROP POLICY IF EXISTS "Allow all operations"    ON public.members;
DROP POLICY IF EXISTS "anon can update members" ON public.members;

-- 2) Backfill every NULL church_id → Rosehill (13 guests + 2 real members).
UPDATE public.members
SET church_id = (SELECT id FROM public.churches WHERE slug = 'rosehill')
WHERE church_id IS NULL;

-- 3) Four church-scoped policies, authenticated only.
CREATE POLICY members_select_own_church ON public.members
  FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY members_insert_own_church ON public.members
  FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY members_update_own_church ON public.members
  FOR UPDATE TO authenticated
  USING (church_id = public.auth_church_id())
  WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY members_delete_own_church ON public.members
  FOR DELETE TO authenticated USING (church_id = public.auth_church_id());

-- 4) Enable.
ALTER TABLE public.members ENABLE ROW LEVEL SECURITY;

COMMIT;
