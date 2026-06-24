-- migrations/025_devotionals_rls.sql
-- Session 46 — RLS-coverage sweep: devotionals (Model A, per-church). Inv #208.
-- Reverses 014's deliberate devotionals exclusion: devotionals are now per-church
-- (each church owns its guide), NOT shared-NULL. Backfill 52 NULL -> Rosehill;
-- re-attach the autostamp trigger so future entries stamp the author's church from the
-- JWT (devotional_admin inserts no church_id -> trigger fills it); drop the 2 public
-- allow-all stubs (Inv #186); 4 TO authenticated policies; ENABLE. Cold-start "sample
-- guide" for new tenants is handled separately by a Load-Sample seeder (church-OWNED
-- copies), NOT shared-NULL rows — keeps isolation intact.
-- RUN FLAT (no BEGIN/COMMIT) — Inv #209. Idempotent.

-- 1) backfill 52 NULL -> Rosehill (Rosehill's in-use guide)
UPDATE public.devotionals SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;

-- 2) re-include devotionals in the church_id autostamp (reverses 014's exclusion)
DROP TRIGGER IF EXISTS trg_set_church_id ON public.devotionals;
CREATE TRIGGER trg_set_church_id BEFORE INSERT ON public.devotionals
  FOR EACH ROW EXECUTE FUNCTION public.set_church_id_from_jwt();

-- 3) drop public allow-all stubs
DROP POLICY IF EXISTS devotionals_read  ON public.devotionals;
DROP POLICY IF EXISTS devotionals_write ON public.devotionals;
DROP POLICY IF EXISTS devotionals_tenant_select ON public.devotionals;
DROP POLICY IF EXISTS devotionals_tenant_insert ON public.devotionals;
DROP POLICY IF EXISTS devotionals_tenant_update ON public.devotionals;
DROP POLICY IF EXISTS devotionals_tenant_delete ON public.devotionals;

-- 4) 4 tenant policies
CREATE POLICY devotionals_tenant_select ON public.devotionals FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY devotionals_tenant_insert ON public.devotionals FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY devotionals_tenant_update ON public.devotionals FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY devotionals_tenant_delete ON public.devotionals FOR DELETE TO authenticated USING (church_id = public.auth_church_id());

-- 5) ENABLE
ALTER TABLE public.devotionals ENABLE ROW LEVEL SECURITY;

-- 6) ledger self-stamp
INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('025','025_devotionals_rls.sql','RLS devotionals (Model A per-church): backfill 52->Rosehill, re-attach autostamp trigger, 4 tenant policies')
ON CONFLICT (version) DO UPDATE SET filename=EXCLUDED.filename, note=EXCLUDED.note, applied_at=now();
