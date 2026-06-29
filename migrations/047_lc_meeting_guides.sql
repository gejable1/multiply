-- ════════════════════════════════════════════════════════════════════
-- migration 047 — lc_meeting_guides  (BYO-AI small-group meeting guides)
-- An LCL generates a prompt from a devotional, runs it in any AI, pastes the
-- result back, MLT parses it into a Facilitator + Participant guide, publishes.
-- RLS: LCL fully controls own rows; members read their own LCL's PUBLISHED guide.
-- FLAT · idempotent · rerun-until-true. (RLS auto-enables on create; we also enable explicitly.)
-- ════════════════════════════════════════════════════════════════════

-- ── helper: the caller's own discipler (LCL), SECURITY DEFINER so it ignores members RLS ──
CREATE OR REPLACE FUNCTION auth_discipler_id()
  RETURNS uuid LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $fn$
  SELECT discipler_id FROM members WHERE id = auth_member_id()
$fn$;

-- ── table ──
CREATE TABLE IF NOT EXISTS lc_meeting_guides (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id      uuid REFERENCES churches(id) ON DELETE CASCADE,        -- autostamped from JWT
  lcl_id         uuid NOT NULL REFERENCES members(id) ON DELETE CASCADE, -- the LC leader
  devotional_id  uuid REFERENCES devotionals(id) ON DELETE SET NULL,
  meeting_date   date NOT NULL,
  facilitator_md text,
  participant_md text,
  raw_paste      text,                                                   -- for fallback / re-parse
  status         text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','published')),
  created_at     timestamptz NOT NULL DEFAULT now(),
  updated_at     timestamptz NOT NULL DEFAULT now()
);

-- one guide per LCL per meeting date → last-wins via upsert on this key
CREATE UNIQUE INDEX IF NOT EXISTS uq_lcmg_lcl_date  ON lc_meeting_guides (church_id, lcl_id, meeting_date);
CREATE INDEX        IF NOT EXISTS ix_lcmg_lcl_status ON lc_meeting_guides (lcl_id, status);

-- autostamp church_id + maintain updated_at
DROP TRIGGER IF EXISTS trg_set_church_id ON lc_meeting_guides;
CREATE TRIGGER trg_set_church_id BEFORE INSERT ON lc_meeting_guides
  FOR EACH ROW EXECUTE FUNCTION set_church_id_from_jwt();
DROP TRIGGER IF EXISTS trg_lcmg_updated ON lc_meeting_guides;
CREATE TRIGGER trg_lcmg_updated BEFORE UPDATE ON lc_meeting_guides
  FOR EACH ROW EXECUTE FUNCTION _set_updated_at();

ALTER TABLE lc_meeting_guides ENABLE ROW LEVEL SECURITY;

-- ── policies ──
-- read: my own rows (any status), OR my LCL's PUBLISHED guide (members)
DROP POLICY IF EXISTS lcmg_select ON lc_meeting_guides;
CREATE POLICY lcmg_select ON lc_meeting_guides FOR SELECT TO authenticated
  USING (
    church_id = auth_church_id() AND (
      lcl_id = auth_member_id()
      OR (status = 'published' AND lcl_id = auth_discipler_id())
    )
  );
-- write: only the LCL, only their own rows
DROP POLICY IF EXISTS lcmg_insert ON lc_meeting_guides;
CREATE POLICY lcmg_insert ON lc_meeting_guides FOR INSERT TO authenticated
  WITH CHECK (lcl_id = auth_member_id() AND church_id = auth_church_id());
DROP POLICY IF EXISTS lcmg_update ON lc_meeting_guides;
CREATE POLICY lcmg_update ON lc_meeting_guides FOR UPDATE TO authenticated
  USING (lcl_id = auth_member_id()) WITH CHECK (lcl_id = auth_member_id());
DROP POLICY IF EXISTS lcmg_delete ON lc_meeting_guides;
CREATE POLICY lcmg_delete ON lc_meeting_guides FOR DELETE TO authenticated
  USING (lcl_id = auth_member_id());

-- ── self-verify (rerun until: t / 4 / 2) ──
SELECT
  (SELECT relrowsecurity FROM pg_class WHERE relname='lc_meeting_guides')                                  AS rls_enabled,
  (SELECT count(*) FROM pg_policies WHERE schemaname='public' AND tablename='lc_meeting_guides')           AS policy_count,
  (SELECT count(*) FROM pg_trigger WHERE tgrelid='lc_meeting_guides'::regclass AND NOT tgisinternal)       AS trigger_count;

-- ── ledger ──
INSERT INTO schema_migrations (version, filename, note)
VALUES ('047','047_lc_meeting_guides.sql','lc_meeting_guides: BYO-AI meeting guides; LCL-own + member-reads-published RLS via auth_discipler_id(); autostamp + updated_at; unique(church,lcl,date)')
ON CONFLICT (version) DO UPDATE SET filename=EXCLUDED.filename, note=EXCLUDED.note, applied_at=now();
