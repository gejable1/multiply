-- ════════════════════════════════════════════════════════════════════
-- migration 048 — lc_meeting_responses  (interactive participant answers)
-- A member answers their study's durable commitments on their device; saved so the
-- next week's "Look Back" can revisit them. Three fields: i_will, reach_person, notes.
-- Private by default; an optional shared_with_leader flag lets the LCL see them for follow-up.
-- RLS: member fully controls own rows; the LCL reads their disciples' SHARED answers.
-- FLAT · idempotent · rerun-until-true.
-- ════════════════════════════════════════════════════════════════════

-- ── helper: the discipler (LCL) of a given member; SECURITY DEFINER bypasses members RLS ──
CREATE OR REPLACE FUNCTION discipler_of(p_member uuid)
  RETURNS uuid LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $fn$
  SELECT discipler_id FROM members WHERE id = p_member
$fn$;

-- ── table ──
CREATE TABLE IF NOT EXISTS lc_meeting_responses (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id          uuid REFERENCES churches(id) ON DELETE CASCADE,           -- autostamped
  member_id          uuid NOT NULL REFERENCES members(id) ON DELETE CASCADE,    -- the responder
  guide_id           uuid NOT NULL REFERENCES lc_meeting_guides(id) ON DELETE CASCADE,
  i_will             text,
  reach_person       text,
  notes              text,
  shared_with_leader boolean NOT NULL DEFAULT false,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now()
);

-- one answer-set per member per guide → last-wins via upsert
CREATE UNIQUE INDEX IF NOT EXISTS uq_lcmr_member_guide ON lc_meeting_responses (member_id, guide_id);
CREATE INDEX        IF NOT EXISTS ix_lcmr_guide_shared ON lc_meeting_responses (guide_id, shared_with_leader);

-- autostamp church_id + maintain updated_at
DROP TRIGGER IF EXISTS trg_set_church_id ON lc_meeting_responses;
CREATE TRIGGER trg_set_church_id BEFORE INSERT ON lc_meeting_responses
  FOR EACH ROW EXECUTE FUNCTION set_church_id_from_jwt();
DROP TRIGGER IF EXISTS trg_lcmr_updated ON lc_meeting_responses;
CREATE TRIGGER trg_lcmr_updated BEFORE UPDATE ON lc_meeting_responses
  FOR EACH ROW EXECUTE FUNCTION _set_updated_at();

ALTER TABLE lc_meeting_responses ENABLE ROW LEVEL SECURITY;

-- ── policies ──
-- read: my own answers (any time), OR my disciple's answers IF they shared them (I'm their LCL)
DROP POLICY IF EXISTS lcmr_select ON lc_meeting_responses;
CREATE POLICY lcmr_select ON lc_meeting_responses FOR SELECT TO authenticated
  USING (
    church_id = auth_church_id() AND (
      member_id = auth_member_id()
      OR (shared_with_leader = true AND discipler_of(member_id) = auth_member_id())
    )
  );
-- write: only my own answers
DROP POLICY IF EXISTS lcmr_insert ON lc_meeting_responses;
CREATE POLICY lcmr_insert ON lc_meeting_responses FOR INSERT TO authenticated
  WITH CHECK (member_id = auth_member_id() AND church_id = auth_church_id());
DROP POLICY IF EXISTS lcmr_update ON lc_meeting_responses;
CREATE POLICY lcmr_update ON lc_meeting_responses FOR UPDATE TO authenticated
  USING (member_id = auth_member_id()) WITH CHECK (member_id = auth_member_id());
DROP POLICY IF EXISTS lcmr_delete ON lc_meeting_responses;
CREATE POLICY lcmr_delete ON lc_meeting_responses FOR DELETE TO authenticated
  USING (member_id = auth_member_id());

-- ── self-verify (rerun until: t / 4 / 2) ──
SELECT
  (SELECT relrowsecurity FROM pg_class WHERE relname='lc_meeting_responses')                              AS rls_enabled,
  (SELECT count(*) FROM pg_policies WHERE schemaname='public' AND tablename='lc_meeting_responses')       AS policy_count,
  (SELECT count(*) FROM pg_trigger WHERE tgrelid='lc_meeting_responses'::regclass AND NOT tgisinternal)   AS trigger_count;

-- ── ledger ──
INSERT INTO schema_migrations (version, filename, note)
VALUES ('048','048_lc_meeting_responses.sql','lc_meeting_responses: member i_will/reach/notes per guide; member-own + LCL-reads-shared RLS via discipler_of(); unique(member,guide)')
ON CONFLICT (version) DO UPDATE SET filename=EXCLUDED.filename, note=EXCLUDED.note, applied_at=now();
