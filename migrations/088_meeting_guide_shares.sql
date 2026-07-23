-- 088_meeting_guide_shares.sql
-- Session 80: let an LC leader delegate ONE meeting to a member of their own
-- flock (typically an L1 being raised up) so that member can open the
-- FACILITATOR guide -- without promoting them to L2 (Inv #33 stays intact:
-- level certifies churchwide, this share is per-guide and revocable).
--
-- Decisions (Pastor Gerry, Session 80):
--   1. published guides only -- a draft is still being written
--   2. the share PERSISTS after the meeting (a leader-in-training may review)
--   3. delegation is to the LCL's own flock -- enforced in the MLT picker;
--      the DB stays church-scoped (a UI rule, not a security boundary)
--
-- NOTE on recursion: lcmg_select must NOT inline an EXISTS against
-- lc_meeting_guide_shares, because that table's own SELECT policy references
-- lc_meeting_guides back (so an LCL can see who they granted) -> Postgres
-- raises "infinite recursion detected in policy". We route through a
-- SECURITY DEFINER helper instead, matching auth_is_leader() / auth_discipler_id().
--
-- Flat (#209), idempotent, self-verifying (#210). PG16-proven, 22/22 (#379).

CREATE TABLE IF NOT EXISTS public.lc_meeting_guide_shares (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id  uuid NOT NULL REFERENCES public.churches(id)          ON DELETE CASCADE,
  guide_id   uuid NOT NULL REFERENCES public.lc_meeting_guides(id) ON DELETE CASCADE,
  member_id  uuid NOT NULL REFERENCES public.members(id)           ON DELETE CASCADE,
  granted_by uuid          REFERENCES public.members(id)           ON DELETE SET NULL,
  note       text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT lc_meeting_guide_shares_guide_member_key UNIQUE (guide_id, member_id)
);

CREATE INDEX IF NOT EXISTS lcmgs_member_idx ON public.lc_meeting_guide_shares (member_id);
CREATE INDEX IF NOT EXISTS lcmgs_guide_idx  ON public.lc_meeting_guide_shares (guide_id);

GRANT SELECT, INSERT, DELETE ON public.lc_meeting_guide_shares TO authenticated;

CREATE OR REPLACE FUNCTION auth_can_facilitate_guide(p_guide uuid)
  RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $fn$
  SELECT EXISTS (
    SELECT 1 FROM lc_meeting_guide_shares
     WHERE guide_id = p_guide AND member_id = auth_member_id()
  )
$fn$;

ALTER TABLE public.lc_meeting_guide_shares ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS lcmgs_select ON public.lc_meeting_guide_shares;
CREATE POLICY lcmgs_select ON public.lc_meeting_guide_shares FOR SELECT TO authenticated
  USING (
    church_id = auth_church_id() AND (
      member_id = auth_member_id()
      OR EXISTS (SELECT 1 FROM public.lc_meeting_guides g
                  WHERE g.id = guide_id AND g.lcl_id = auth_member_id())
    )
  );

DROP POLICY IF EXISTS lcmgs_insert ON public.lc_meeting_guide_shares;
CREATE POLICY lcmgs_insert ON public.lc_meeting_guide_shares FOR INSERT TO authenticated
  WITH CHECK (
    church_id = auth_church_id()
    AND granted_by = auth_member_id()
    AND EXISTS (SELECT 1 FROM public.lc_meeting_guides g
                 WHERE g.id = guide_id AND g.lcl_id = auth_member_id())
  );

DROP POLICY IF EXISTS lcmgs_delete ON public.lc_meeting_guide_shares;
CREATE POLICY lcmgs_delete ON public.lc_meeting_guide_shares FOR DELETE TO authenticated
  USING (
    church_id = auth_church_id()
    AND EXISTS (SELECT 1 FROM public.lc_meeting_guides g
                 WHERE g.id = guide_id AND g.lcl_id = auth_member_id())
  );

DROP POLICY IF EXISTS lcmg_select ON public.lc_meeting_guides;
CREATE POLICY lcmg_select ON public.lc_meeting_guides FOR SELECT TO authenticated
  USING (
    church_id = auth_church_id() AND (
      lcl_id = auth_member_id()
      OR (status = 'published' AND lcl_id = auth_discipler_id())
      OR (status = 'published' AND shared_to_library = true AND auth_is_leader())
      OR (status = 'published' AND auth_can_facilitate_guide(id))
    )
  );

INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('088','088_meeting_guide_shares.sql','S80: lc_meeting_guide_shares + auth_can_facilitate_guide(); per-guide facilitator delegation branch on lcmg_select')
ON CONFLICT (version) DO NOTHING;

SELECT
  (SELECT count(*) FROM information_schema.tables
     WHERE table_schema='public' AND table_name='lc_meeting_guide_shares') = 1        AS has_table,
  (SELECT count(*) FROM pg_proc WHERE proname='auth_can_facilitate_guide') = 1        AS has_fn,
  (SELECT count(*) FROM pg_policies WHERE tablename='lc_meeting_guide_shares') = 3    AS has_3_share_policies,
  (SELECT count(*) FROM pg_policies
     WHERE tablename='lc_meeting_guides' AND policyname='lcmg_select'
       AND qual LIKE '%auth_can_facilitate_guide%') = 1                               AS guide_policy_extended,
  (SELECT count(*) FROM pg_policies
     WHERE tablename='lc_meeting_guide_shares' AND (qual = 'true' OR with_check = 'true')) = 0 AS no_allow_all;
