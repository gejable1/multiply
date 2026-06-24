-- migrations/027_leader_sessions_rls.sql
-- Session 46 — RLS-coverage sweep: leader_sessions (bucket B). Inv #208.
-- PRE-REQ: the patched auth-login EF (stamps church_id on the leader_sessions insert) is
-- REDEPLOYED before running this. The EF runs as service-role (bypasses RLS) and carries no
-- JWT, so the autostamp trigger can't fill church_id — the EF must set it explicitly, else new
-- rows are NULL and invisible to the JWT client.
-- Pattern: backfill NULL->Rosehill -> 4 TO authenticated policies -> ENABLE.
-- RUN FLAT (no BEGIN/COMMIT) — Inv #209. Idempotent. Ends with a self-verify SELECT (Inv #210):
-- rerun the whole block until you see rls_enabled=true, policy_count=4, null_church=0.

UPDATE public.leader_sessions SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS leader_sessions_tenant_select ON public.leader_sessions;
DROP POLICY IF EXISTS leader_sessions_tenant_insert ON public.leader_sessions;
DROP POLICY IF EXISTS leader_sessions_tenant_update ON public.leader_sessions;
DROP POLICY IF EXISTS leader_sessions_tenant_delete ON public.leader_sessions;
CREATE POLICY leader_sessions_tenant_select ON public.leader_sessions FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY leader_sessions_tenant_insert ON public.leader_sessions FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY leader_sessions_tenant_update ON public.leader_sessions FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY leader_sessions_tenant_delete ON public.leader_sessions FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.leader_sessions ENABLE ROW LEVEL SECURITY;

INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('027','027_leader_sessions_rls.sql','RLS leader_sessions: EF now stamps church_id, backfill->Rosehill, 4 tenant policies')
ON CONFLICT (version) DO UPDATE SET filename=EXCLUDED.filename, note=EXCLUDED.note, applied_at=now();

-- self-verify (Inv #210) — rerun the whole block until this reads true / 4 / 0
SELECT c.relrowsecurity AS rls_enabled,
  (SELECT count(*) FROM pg_policies p WHERE p.schemaname='public' AND p.tablename='leader_sessions') AS policy_count,
  (SELECT count(*) FROM public.leader_sessions WHERE church_id IS NULL) AS null_church
FROM pg_class c WHERE c.oid='public.leader_sessions'::regclass;
