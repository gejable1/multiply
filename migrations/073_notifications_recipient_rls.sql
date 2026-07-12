-- ============================================================================
-- 073_notifications_recipient_rls.sql   ·   Session 70
-- Tighten notifications RLS from church-scoped to RECIPIENT-scoped.
--
-- WHY: SELECT/UPDATE/DELETE were USING (church_id = auth_church_id()) only, so any
-- authenticated user could read or mutate ANY other member's notifications via the
-- API. Tolerable while only leaders had a UI; unacceptable now that MMT has a
-- member-facing inbox. INSERT stays church-scoped ON PURPOSE -- you must be able to
-- notify OTHER people (that is the entire feature).
--
-- SAFE FOR MD: the dashboard bell already selects with .eq('recipient_id', LEADER.leaderId)
-- and only updates rows it loaded that way. auth_member_id() reads JWT claim 'sub',
-- which BOTH auth-login and token-login set to the member's id (verified in
-- supabase/functions/*/index.ts).
-- VERIFIED IN PROD: a test notification inserted for the Pastor rendered in the MD bell
-- with the tightened policies active.
-- ============================================================================

DROP POLICY IF EXISTS notifications_tenant_select ON public.notifications;
CREATE POLICY notifications_own_select ON public.notifications
  FOR SELECT TO authenticated
  USING (church_id = public.auth_church_id()
         AND recipient_id = public.auth_member_id());

DROP POLICY IF EXISTS notifications_tenant_update ON public.notifications;
CREATE POLICY notifications_own_update ON public.notifications
  FOR UPDATE TO authenticated
  USING      (church_id = public.auth_church_id()
              AND recipient_id = public.auth_member_id())
  WITH CHECK (church_id = public.auth_church_id()
              AND recipient_id = public.auth_member_id());

DROP POLICY IF EXISTS notifications_tenant_delete ON public.notifications;
CREATE POLICY notifications_own_delete ON public.notifications
  FOR DELETE TO authenticated
  USING (church_id = public.auth_church_id()
         AND recipient_id = public.auth_member_id());

-- INSERT policy intentionally UNCHANGED (notifications_tenant_insert).

INSERT INTO public.schema_migrations (version, filename, note)
VALUES (73, '073_notifications_recipient_rls.sql',
        'notifications SELECT/UPDATE/DELETE narrowed from church-scoped to recipient-scoped; INSERT left church-scoped so members can notify others. Prereq for the MMT member notification inbox.')
ON CONFLICT (version) DO NOTHING;

-- SELF-VERIFY (ran clean): expect 4 rows; own_select/own_update/own_delete have
-- recipient_scoped = true, notifications_tenant_insert = false (correct).
SELECT policyname, cmd,
       (COALESCE(qual, '') LIKE '%auth_member_id%') AS recipient_scoped
FROM   pg_policies
WHERE  schemaname = 'public' AND tablename = 'notifications'
ORDER  BY policyname;
