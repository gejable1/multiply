-- migrations/030_system_settings_rls.sql
-- Session 47 — system_settings per-church isolation. Inv #208 (last config table).
CREATE SEQUENCE IF NOT EXISTS public.system_settings_id_seq;
SELECT setval('public.system_settings_id_seq', GREATEST(COALESCE((SELECT MAX(id) FROM public.system_settings),0),1));
ALTER TABLE public.system_settings ALTER COLUMN id SET DEFAULT nextval('public.system_settings_id_seq');
ALTER SEQUENCE public.system_settings_id_seq OWNED BY public.system_settings.id;
-- drop the singleton guard that pins id=1 (blocks per-church rows)
ALTER TABLE public.system_settings DROP CONSTRAINT IF EXISTS single_row;
DO $$ BEGIN
  ALTER TABLE public.system_settings ADD CONSTRAINT system_settings_church_uniq UNIQUE (church_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DROP TRIGGER IF EXISTS trg_set_church_id ON public.system_settings;
CREATE TRIGGER trg_set_church_id BEFORE INSERT ON public.system_settings
  FOR EACH ROW EXECUTE FUNCTION public.set_church_id_from_jwt();
UPDATE public.system_settings SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS "Enable all for anon"              ON public.system_settings;
DROP POLICY IF EXISTS "Allow all operations"             ON public.system_settings;
DROP POLICY IF EXISTS "anon can read system_settings"    ON public.system_settings;
DROP POLICY IF EXISTS "anon can update system_settings"  ON public.system_settings;
DROP POLICY IF EXISTS "anyone can read system_settings"  ON public.system_settings;
DROP POLICY IF EXISTS "anyone can write system_settings" ON public.system_settings;
DROP POLICY IF EXISTS system_settings_tenant_select ON public.system_settings;
DROP POLICY IF EXISTS system_settings_tenant_insert ON public.system_settings;
DROP POLICY IF EXISTS system_settings_tenant_update ON public.system_settings;
DROP POLICY IF EXISTS system_settings_tenant_delete ON public.system_settings;
CREATE POLICY system_settings_tenant_select ON public.system_settings FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY system_settings_tenant_insert ON public.system_settings FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY system_settings_tenant_update ON public.system_settings FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY system_settings_tenant_delete ON public.system_settings FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;
INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('030','030_system_settings_rls.sql','RLS system_settings per-church: id->sequence, drop single_row guard, UNIQUE(church_id), autostamp re-assert, drop public stubs, backfill->Rosehill, 4 tenant policies')
ON CONFLICT (version) DO UPDATE SET filename=EXCLUDED.filename, note=EXCLUDED.note, applied_at=now();
SELECT
  c.relrowsecurity AS rls_enabled,
  (SELECT count(*) FROM pg_policies p WHERE p.schemaname='public' AND p.tablename='system_settings') AS policy_count,
  (SELECT count(*) FROM public.system_settings WHERE church_id IS NULL) AS null_church,
  (SELECT count(*) FROM pg_constraint WHERE conname='system_settings_church_uniq') AS uniq_present,
  (SELECT pg_get_expr(d.adbin,d.adrelid) FROM pg_attrdef d
     JOIN pg_attribute a ON a.attrelid=d.adrelid AND a.attnum=d.adnum
     WHERE d.adrelid='public.system_settings'::regclass AND a.attname='id') AS id_default
FROM pg_class c WHERE c.oid='public.system_settings'::regclass;
