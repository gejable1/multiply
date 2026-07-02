-- 054_lcg_leader_checkins.sql
-- Shepherd's check-in loop: a coach/pastor sends an in-app check-in to an LC Leader
-- whose LCG has gone quiet; the LCL taps a reason in MLT; the pastor reads the reason
-- back as a chip in the LCG Pulse report. Fully in-app, self-reported (shepherd-not-spy).
-- Tenant + per-member RLS, church_id auto-stamped from JWT. FLAT + idempotent.

CREATE TABLE IF NOT EXISTS public.lcg_leader_checkins (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id        uuid NOT NULL,
  leader_member_id uuid NOT NULL,
  sent_by          uuid,
  sent_at          timestamptz NOT NULL DEFAULT now(),
  reason_code      text,
  note             text,
  responded_at     timestamptz,
  status           text NOT NULL DEFAULT 'awaiting',
  pastor_seen_at   timestamptz,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.lcg_leader_checkins DROP CONSTRAINT IF EXISTS lcg_checkins_status_chk;
ALTER TABLE public.lcg_leader_checkins ADD CONSTRAINT lcg_checkins_status_chk
  CHECK (status IN ('awaiting','answered','resolved'));

ALTER TABLE public.lcg_leader_checkins DROP CONSTRAINT IF EXISTS lcg_checkins_reason_chk;
ALTER TABLE public.lcg_leader_checkins ADD CONSTRAINT lcg_checkins_reason_chk
  CHECK (reason_code IS NULL OR reason_code IN
    ('met_forgot_log','overwhelmed','need_coleader','unsure_meeting','scheduling','personal','okay'));

CREATE INDEX IF NOT EXISTS idx_lcg_checkins_church_leader ON public.lcg_leader_checkins (church_id, leader_member_id);
CREATE INDEX IF NOT EXISTS idx_lcg_checkins_church_status ON public.lcg_leader_checkins (church_id, status);

DROP TRIGGER IF EXISTS trg_set_church_id ON public.lcg_leader_checkins;
CREATE TRIGGER trg_set_church_id BEFORE INSERT ON public.lcg_leader_checkins
  FOR EACH ROW EXECUTE FUNCTION set_church_id_from_jwt();

ALTER TABLE public.lcg_leader_checkins ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS lcg_checkins_select ON public.lcg_leader_checkins;
CREATE POLICY lcg_checkins_select ON public.lcg_leader_checkins FOR SELECT
  USING (church_id = auth_church_id() AND (leader_member_id = auth_member_id() OR auth_level() >= 3));

DROP POLICY IF EXISTS lcg_checkins_insert ON public.lcg_leader_checkins;
CREATE POLICY lcg_checkins_insert ON public.lcg_leader_checkins FOR INSERT
  WITH CHECK (church_id = auth_church_id() AND auth_level() >= 3);

DROP POLICY IF EXISTS lcg_checkins_update ON public.lcg_leader_checkins;
CREATE POLICY lcg_checkins_update ON public.lcg_leader_checkins FOR UPDATE
  USING (church_id = auth_church_id() AND (leader_member_id = auth_member_id() OR auth_level() >= 3))
  WITH CHECK (church_id = auth_church_id() AND (leader_member_id = auth_member_id() OR auth_level() >= 3));

DROP POLICY IF EXISTS lcg_checkins_delete ON public.lcg_leader_checkins;
CREATE POLICY lcg_checkins_delete ON public.lcg_leader_checkins FOR DELETE
  USING (church_id = auth_church_id() AND auth_level() >= 3);

INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('054_lcg_leader_checkins','054_lcg_leader_checkins.sql',
  'LCG leader check-in loop: table + tenant/per-member RLS + church_id auto-stamp trigger.')
ON CONFLICT (version) DO NOTHING;

-- self-verify: expect table=1, rls=true, policies=4, triggers=1. Rerun until all correct.
SELECT
  (SELECT count(*) FROM information_schema.tables WHERE table_schema='public' AND table_name='lcg_leader_checkins') AS table_should_be_1,
  (SELECT relrowsecurity FROM pg_class WHERE oid='public.lcg_leader_checkins'::regclass) AS rls_should_be_true,
  (SELECT count(*) FROM pg_policies WHERE schemaname='public' AND tablename='lcg_leader_checkins') AS policies_should_be_4,
  (SELECT count(*) FROM pg_trigger WHERE tgrelid='public.lcg_leader_checkins'::regclass AND NOT tgisinternal) AS triggers_should_be_1;
