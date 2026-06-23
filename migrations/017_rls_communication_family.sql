-- migrations/017_rls_communication_family.sql
-- RLS batch 2: announcements / acks / retraction_dismissals / absence_notices / notifications.
-- Mirrors 016. Backfill via churches.slug. Idempotent.

-- ===== announcements =====
UPDATE public.announcements SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS announcements_tenant_select ON public.announcements;
DROP POLICY IF EXISTS announcements_tenant_insert ON public.announcements;
DROP POLICY IF EXISTS announcements_tenant_update ON public.announcements;
DROP POLICY IF EXISTS announcements_tenant_delete ON public.announcements;
CREATE POLICY announcements_tenant_select ON public.announcements FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY announcements_tenant_insert ON public.announcements FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY announcements_tenant_update ON public.announcements FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY announcements_tenant_delete ON public.announcements FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;

-- ===== announcement_acks =====
UPDATE public.announcement_acks SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS announcement_acks_tenant_select ON public.announcement_acks;
DROP POLICY IF EXISTS announcement_acks_tenant_insert ON public.announcement_acks;
DROP POLICY IF EXISTS announcement_acks_tenant_update ON public.announcement_acks;
DROP POLICY IF EXISTS announcement_acks_tenant_delete ON public.announcement_acks;
CREATE POLICY announcement_acks_tenant_select ON public.announcement_acks FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY announcement_acks_tenant_insert ON public.announcement_acks FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY announcement_acks_tenant_update ON public.announcement_acks FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY announcement_acks_tenant_delete ON public.announcement_acks FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.announcement_acks ENABLE ROW LEVEL SECURITY;

-- ===== announcement_retraction_dismissals =====
UPDATE public.announcement_retraction_dismissals SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS ard_tenant_select ON public.announcement_retraction_dismissals;
DROP POLICY IF EXISTS ard_tenant_insert ON public.announcement_retraction_dismissals;
DROP POLICY IF EXISTS ard_tenant_update ON public.announcement_retraction_dismissals;
DROP POLICY IF EXISTS ard_tenant_delete ON public.announcement_retraction_dismissals;
CREATE POLICY ard_tenant_select ON public.announcement_retraction_dismissals FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY ard_tenant_insert ON public.announcement_retraction_dismissals FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY ard_tenant_update ON public.announcement_retraction_dismissals FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY ard_tenant_delete ON public.announcement_retraction_dismissals FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.announcement_retraction_dismissals ENABLE ROW LEVEL SECURITY;

-- ===== absence_notices =====
UPDATE public.absence_notices SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS absence_notices_tenant_select ON public.absence_notices;
DROP POLICY IF EXISTS absence_notices_tenant_insert ON public.absence_notices;
DROP POLICY IF EXISTS absence_notices_tenant_update ON public.absence_notices;
DROP POLICY IF EXISTS absence_notices_tenant_delete ON public.absence_notices;
CREATE POLICY absence_notices_tenant_select ON public.absence_notices FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY absence_notices_tenant_insert ON public.absence_notices FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY absence_notices_tenant_update ON public.absence_notices FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY absence_notices_tenant_delete ON public.absence_notices FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.absence_notices ENABLE ROW LEVEL SECURITY;

-- ===== notifications =====
UPDATE public.notifications SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS notifications_tenant_select ON public.notifications;
DROP POLICY IF EXISTS notifications_tenant_insert ON public.notifications;
DROP POLICY IF EXISTS notifications_tenant_update ON public.notifications;
DROP POLICY IF EXISTS notifications_tenant_delete ON public.notifications;
CREATE POLICY notifications_tenant_select ON public.notifications FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY notifications_tenant_insert ON public.notifications FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY notifications_tenant_update ON public.notifications FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY notifications_tenant_delete ON public.notifications FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
