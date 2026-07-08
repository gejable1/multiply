-- 067_lcg_celebration_member_read.sql
-- Phase 2b of Celebrate-button wiring: an ADDITIVE member-read RLS policy on
-- lcg_leader_checkins. A member may read kind='celebration' rows about their OWN
-- LC leader (leader_member_id = their discipler) — but ONLY once acknowledged
-- (responded_at IS NOT NULL; the leader's "Amen" is the consent gate), church-scoped.
-- Nothing else opens: check-ins, un-acked celebrations, and OTHER leaders' rows stay
-- closed. Additive to the existing lcg_checkins_select (054) — permissive SELECT
-- policies OR together, so this only ADDS the narrow member read.
-- Flat, rerunnable, self-verifying, self-stamping. RLS already ENABLED on the table (054).

DROP POLICY IF EXISTS lcg_checkins_member_read_celebration ON public.lcg_leader_checkins;
CREATE POLICY lcg_checkins_member_read_celebration ON public.lcg_leader_checkins
  FOR SELECT TO authenticated
  USING (
        kind = 'celebration'
    AND responded_at IS NOT NULL
    AND church_id = public.auth_church_id()
    AND leader_member_id = public.auth_discipler_id()
  );

INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('067', '067_lcg_celebration_member_read.sql', 'Additive member-read RLS: a member reads their own LC leader''s ACKNOWLEDGED celebrations (Phase 2b feed badge)')
ON CONFLICT (version) DO NOTHING;

-- self-verify: the new SELECT policy exists with the expected USING predicate.
SELECT polname,
       polcmd,
       pg_get_expr(polqual, polrelid) AS using_expr
FROM pg_policy
WHERE polrelid = 'public.lcg_leader_checkins'::regclass
  AND polname = 'lcg_checkins_member_read_celebration';
