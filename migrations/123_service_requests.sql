-- migrations/123_service_requests.sql
-- S109 - Service requests: a member asks the church for pastoral service/presence:
--   house_blessing, business_blessing, vehicle_blessing, child_dedication,
--   wedding, birthday, vow_renewal, funeral (added Oct 21: urgent, never celebrated).
-- DECISIONS (Pastor, Oct 21 2026):
--   * The Pastor (L5) decides; the member's LC leader is informed (notification).
--   * Flow: requested -> scheduled (date/time + who officiates) -> done; or declined.
--     The member may cancel their own request while it is still 'requested'.
--   * When done, it is celebrated in the LC feed ONLY if the member consented
--     (share_consent). The feed reads v_service_celebrations, which exposes no
--     address, contact number, notes or details - only who, what kind, and when.
--   * Lead-time rules are enforced in the member form: wedding = 3 months notice
--     plus pre-marital counseling acknowledgment; everything else = 2 weeks
--     (earlier allowed with a warning); funeral = no notice rule.
--   * Child dedication (Oct 21): complete names of the child, both parents (if
--     applicable) and the sponsors - kept in details (jsonb), enforced in the form.
-- Retire, never delete: no DELETE policy.
-- RUN FLAT (no BEGIN/COMMIT) - Inv #209. Idempotent; rerun-until-true.

-- 1) Table
CREATE TABLE IF NOT EXISTS public.service_requests (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id       uuid        REFERENCES public.churches(id),
  requester_id    uuid        NOT NULL REFERENCES public.members(id) ON DELETE CASCADE,
  requester_name  text,                              -- decorative mirror (Inv #166)
  discipler_id    uuid        REFERENCES public.members(id) ON DELETE SET NULL,
  service_type    text        NOT NULL,
  details         jsonb       NOT NULL DEFAULT '{}'::jsonb,
  preferred_date  date        NOT NULL,
  preferred_time  text,
  alt_date        date,
  location        text,
  contact_number  text,
  notes           text,
  share_consent   boolean     NOT NULL DEFAULT false,
  ack_requirements boolean    NOT NULL DEFAULT false,
  status          text        NOT NULL DEFAULT 'requested',
  scheduled_date  date,
  scheduled_time  text,
  officiant_id    uuid        REFERENCES public.members(id) ON DELETE SET NULL,
  officiant_name  text,
  pastor_note     text,
  decided_by      uuid        REFERENCES public.members(id) ON DELETE SET NULL,
  decided_at      timestamptz,
  done_at         timestamptz,
  cancelled_at    timestamptz,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT service_requests_status_check CHECK (status IN
    ('requested','scheduled','done','declined','cancelled')),
  CONSTRAINT service_requests_scheduled_has_date CHECK (status NOT IN ('scheduled','done') OR scheduled_date IS NOT NULL)
);

-- Type list kept OUTSIDE the CREATE so a rerun upgrades an already-created table
-- (Oct 21: funeral added after the first version was published).
ALTER TABLE public.service_requests DROP CONSTRAINT IF EXISTS service_requests_type_check;
ALTER TABLE public.service_requests ADD CONSTRAINT service_requests_type_check CHECK (service_type IN
  ('house_blessing','business_blessing','vehicle_blessing','child_dedication','wedding','birthday','vow_renewal','funeral'));

CREATE INDEX IF NOT EXISTS idx_service_requests_church_status ON public.service_requests (church_id, status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_service_requests_requester     ON public.service_requests (requester_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_service_requests_discipler     ON public.service_requests (discipler_id);
CREATE INDEX IF NOT EXISTS idx_service_requests_done          ON public.service_requests (church_id, done_at) WHERE status = 'done';

-- 2) Church stamp from the JWT (same trigger as every per-church table, 014)
DROP TRIGGER IF EXISTS trg_set_church_id ON public.service_requests;
CREATE TRIGGER trg_set_church_id BEFORE INSERT ON public.service_requests
  FOR EACH ROW EXECUTE FUNCTION public.set_church_id_from_jwt();

-- 3) updated_at stamp
CREATE OR REPLACE FUNCTION public.service_requests_touch()
RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$fn$;
DROP TRIGGER IF EXISTS trg_service_requests_touch ON public.service_requests;
CREATE TRIGGER trg_service_requests_touch BEFORE UPDATE ON public.service_requests
  FOR EACH ROW EXECUTE FUNCTION public.service_requests_touch();

-- 4) RLS
--   SELECT: the requester, their LC leader (discipler_id), the assigned officiant, or a Pastor (L5).
--   INSERT: a member, for themselves only, status 'requested'.
--   UPDATE: a Pastor (any change), or the requester on their own still-'requested'
--           row (edit or cancel; can never schedule/approve themselves).
ALTER TABLE public.service_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS service_requests_select ON public.service_requests;
CREATE POLICY service_requests_select ON public.service_requests
  FOR SELECT TO authenticated
  USING (church_id = public.auth_church_id()
         AND (requester_id = public.auth_member_id()
              OR discipler_id = public.auth_member_id()
              OR officiant_id = public.auth_member_id()
              OR public.auth_level() >= 5));

DROP POLICY IF EXISTS service_requests_insert ON public.service_requests;
CREATE POLICY service_requests_insert ON public.service_requests
  FOR INSERT TO authenticated
  WITH CHECK (church_id = public.auth_church_id()
              AND requester_id = public.auth_member_id()
              AND status = 'requested');

DROP POLICY IF EXISTS service_requests_update_pastor ON public.service_requests;
CREATE POLICY service_requests_update_pastor ON public.service_requests
  FOR UPDATE TO authenticated
  USING      (church_id = public.auth_church_id() AND public.auth_level() >= 5)
  WITH CHECK (church_id = public.auth_church_id() AND public.auth_level() >= 5);

DROP POLICY IF EXISTS service_requests_update_own ON public.service_requests;
CREATE POLICY service_requests_update_own ON public.service_requests
  FOR UPDATE TO authenticated
  USING      (church_id = public.auth_church_id()
              AND requester_id = public.auth_member_id()
              AND status = 'requested')
  WITH CHECK (church_id = public.auth_church_id()
              AND requester_id = public.auth_member_id()
              AND status IN ('requested','cancelled'));

REVOKE DELETE ON public.service_requests FROM anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON public.service_requests TO authenticated;

-- 5) Celebration view for the LC feed: only done + consented rows, only safe
--    columns. Runs with the view owner's rights (NOT security_invoker) so LC
--    members can see the win without reading the private request row; the
--    church filter is applied explicitly from the JWT.
CREATE OR REPLACE VIEW public.v_service_celebrations AS
SELECT r.requester_id, r.service_type, r.done_at
  FROM public.service_requests r
 WHERE r.status = 'done'
   AND r.share_consent = true
   AND r.done_at IS NOT NULL
   AND r.church_id = public.auth_church_id();
REVOKE ALL ON public.v_service_celebrations FROM anon;
GRANT SELECT ON public.v_service_celebrations TO authenticated;

-- 6) Ledger stamp (023 contract)
INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('123', '123_service_requests.sql',
        'S109 service requests: 8 types incl. funeral, requested/scheduled/done/declined/cancelled, Pastor decides, LCL informed, consented wins via v_service_celebrations')
ON CONFLICT (version) DO UPDATE
  SET filename = EXCLUDED.filename, note = EXCLUDED.note, applied_at = now();

-- 7) Self-verify - rerun the whole file until every row reads PASS.
SELECT 'table exists' AS checkpoint,
       CASE WHEN to_regclass('public.service_requests') IS NOT NULL THEN 'PASS' ELSE 'FAIL' END AS status
UNION ALL
SELECT 'RLS enabled',
       CASE WHEN (SELECT relrowsecurity FROM pg_class WHERE oid = 'public.service_requests'::regclass)
            THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'policies = 4 (select/insert/2 update, no delete)',
       CASE WHEN (SELECT COUNT(*) FROM pg_policies WHERE schemaname='public' AND tablename='service_requests') = 4
             AND NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='service_requests' AND cmd='DELETE')
            THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'church-stamp trigger',
       CASE WHEN EXISTS (SELECT 1 FROM pg_trigger WHERE tgrelid='public.service_requests'::regclass AND tgname='trg_set_church_id')
            THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'celebration view (3 safe columns)',
       CASE WHEN (SELECT COUNT(*) FROM information_schema.columns
                   WHERE table_schema='public' AND table_name='v_service_celebrations') = 3
            THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'type list includes funeral',
       CASE WHEN EXISTS (SELECT 1 FROM pg_constraint
                          WHERE conrelid='public.service_requests'::regclass
                            AND conname='service_requests_type_check'
                            AND pg_get_constraintdef(oid) LIKE '%funeral%')
            THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'ledger 123',
       CASE WHEN EXISTS (SELECT 1 FROM public.schema_migrations WHERE version='123') THEN 'PASS' ELSE 'FAIL' END;
