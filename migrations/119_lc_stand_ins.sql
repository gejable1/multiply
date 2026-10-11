-- migrations/119_lc_stand_ins.sql
-- S96 - Stand-in attendance: a trusted member logs Sunday Service / Prayer
-- Meeting / LC Meeting attendance FOR the LC group of an L2 who is temporarily
-- unavailable, so faithful members are not left unrecorded.
-- DECISIONS (Pastor, Oct 11 2026):
--   * Assigned by L3+ (Coach and above) in MD.
--   * Stand-in only LOGS -- members stay under their own leader (discipler_id
--     untouched), so reports keep crediting the leader's group (Inv #167).
--   * Events: Sunday Service, Prayer Meeting, LC Meeting.
--   * The covered leader is exempt from the MMT attendance lock while covered.
-- Rows are written to attendance with source = 'stand_in' (value already in
-- attendance_source_check; reports already count it as leader-authoritative).
-- Retire, never delete: ending a stand-in stamps ended_at; there is no DELETE
-- policy. One ACTIVE stand-in per leader (partial unique index).
-- RUN FLAT (no BEGIN/COMMIT) - Inv #209. Idempotent; rerun-until-true.

-- 1) Table
CREATE TABLE IF NOT EXISTS public.lc_stand_ins (
  id           uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id    uuid        REFERENCES public.churches(id),
  leader_id    uuid        NOT NULL REFERENCES public.members(id) ON DELETE CASCADE,
  stand_in_id  uuid        NOT NULL REFERENCES public.members(id) ON DELETE CASCADE,
  starts_on    date        NOT NULL DEFAULT ((now() AT TIME ZONE 'Asia/Manila')::date),
  ends_on      date,
  note         text,
  created_by   uuid        REFERENCES public.members(id) ON DELETE SET NULL,
  created_at   timestamptz NOT NULL DEFAULT now(),
  ended_at     timestamptz,
  ended_by     uuid        REFERENCES public.members(id) ON DELETE SET NULL,
  CONSTRAINT lc_stand_ins_not_self   CHECK (leader_id <> stand_in_id),
  CONSTRAINT lc_stand_ins_date_order CHECK (ends_on IS NULL OR ends_on >= starts_on)
);

CREATE UNIQUE INDEX IF NOT EXISTS lc_stand_ins_one_active_per_leader
  ON public.lc_stand_ins (leader_id) WHERE ended_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_lc_stand_ins_stand_in ON public.lc_stand_ins (stand_in_id) WHERE ended_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_lc_stand_ins_church   ON public.lc_stand_ins (church_id);

-- 2) Church stamp from the JWT (same trigger as every per-church table, 014)
DROP TRIGGER IF EXISTS trg_set_church_id ON public.lc_stand_ins;
CREATE TRIGGER trg_set_church_id BEFORE INSERT ON public.lc_stand_ins
  FOR EACH ROW EXECUTE FUNCTION public.set_church_id_from_jwt();

-- 3) RLS: everyone in the church may READ (MMT must find "am I a stand-in?",
--    the lock must find "am I covered?"); only L3+ may create / end.
ALTER TABLE public.lc_stand_ins ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS lc_stand_ins_select ON public.lc_stand_ins;
CREATE POLICY lc_stand_ins_select ON public.lc_stand_ins
  FOR SELECT TO authenticated
  USING (church_id = public.auth_church_id());

DROP POLICY IF EXISTS lc_stand_ins_insert ON public.lc_stand_ins;
CREATE POLICY lc_stand_ins_insert ON public.lc_stand_ins
  FOR INSERT TO authenticated
  WITH CHECK (church_id = public.auth_church_id()
              AND public.auth_level() >= 3
              AND created_by = public.auth_member_id());

DROP POLICY IF EXISTS lc_stand_ins_update ON public.lc_stand_ins;
CREATE POLICY lc_stand_ins_update ON public.lc_stand_ins
  FOR UPDATE TO authenticated
  USING      (church_id = public.auth_church_id() AND public.auth_level() >= 3)
  WITH CHECK (church_id = public.auth_church_id() AND public.auth_level() >= 3);

GRANT SELECT, INSERT, UPDATE ON public.lc_stand_ins TO authenticated;

-- 4) Ledger stamp (023 contract)
INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('119', '119_lc_stand_ins.sql',
        'S96 stand-in attendance: lc_stand_ins (L3+ assigns, church-read, retire-never-delete, one active per leader)')
ON CONFLICT (version) DO UPDATE
  SET filename = EXCLUDED.filename, note = EXCLUDED.note, applied_at = now();

-- 5) Self-verify - rerun the whole file until every row reads PASS.
SELECT 'table exists' AS checkpoint,
       CASE WHEN to_regclass('public.lc_stand_ins') IS NOT NULL THEN 'PASS' ELSE 'FAIL' END AS status
UNION ALL
SELECT 'RLS enabled',
       CASE WHEN (SELECT relrowsecurity FROM pg_class WHERE oid = 'public.lc_stand_ins'::regclass)
            THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'policies = 3 (select/insert/update, no delete)',
       CASE WHEN (SELECT COUNT(*) FROM pg_policies WHERE schemaname='public' AND tablename='lc_stand_ins') = 3
             AND NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='lc_stand_ins' AND cmd='DELETE')
            THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'church-stamp trigger',
       CASE WHEN EXISTS (SELECT 1 FROM pg_trigger WHERE tgrelid='public.lc_stand_ins'::regclass AND tgname='trg_set_church_id')
            THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'one-active-per-leader index',
       CASE WHEN EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname='public' AND indexname='lc_stand_ins_one_active_per_leader')
            THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'stand_in is an allowed attendance source',
       CASE WHEN EXISTS (SELECT 1 FROM pg_constraint WHERE conname='attendance_source_check'
                          AND pg_get_constraintdef(oid) LIKE '%stand_in%')
            THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'ledger 119',
       CASE WHEN EXISTS (SELECT 1 FROM public.schema_migrations WHERE version='119') THEN 'PASS' ELSE 'FAIL' END;
