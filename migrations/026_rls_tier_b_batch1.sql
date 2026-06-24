-- migrations/026_rls_tier_b_batch1.sql
-- Session 46 — RLS-coverage sweep, tier-b batch 1 (13 tables). Inv #208.
-- All have church_id, 0 prior policies, autostamp trigger already attached (014),
-- all accessors JWT. Standard pattern: backfill NULL->Rosehill -> 4 TO authenticated
-- policies on auth_church_id() -> ENABLE. Tables:
--   attendance_self_attest_log, discipler_change_log, library_chapter_progress,
--   library_progress, library_quiz_attempts, ministry_rosters, ministry_roster_members,
--   prayer_intercessions, prayer_list_items, prayer_list_opens, prayer_reminders,
--   prayer_requests, transfers.
-- NOT here: leader_sessions (EF must stamp church_id first -> next), system_settings
-- (anon admin page), and the 8 no-church_id shared-content tables (separate design pass).
-- RUN FLAT (no BEGIN/COMMIT) — Inv #209. Idempotent.

-- ===== attendance_self_attest_log =====
UPDATE public.attendance_self_attest_log SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS attendance_self_attest_log_tenant_select ON public.attendance_self_attest_log;
DROP POLICY IF EXISTS attendance_self_attest_log_tenant_insert ON public.attendance_self_attest_log;
DROP POLICY IF EXISTS attendance_self_attest_log_tenant_update ON public.attendance_self_attest_log;
DROP POLICY IF EXISTS attendance_self_attest_log_tenant_delete ON public.attendance_self_attest_log;
CREATE POLICY attendance_self_attest_log_tenant_select ON public.attendance_self_attest_log FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY attendance_self_attest_log_tenant_insert ON public.attendance_self_attest_log FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY attendance_self_attest_log_tenant_update ON public.attendance_self_attest_log FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY attendance_self_attest_log_tenant_delete ON public.attendance_self_attest_log FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.attendance_self_attest_log ENABLE ROW LEVEL SECURITY;

-- ===== discipler_change_log =====
UPDATE public.discipler_change_log SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS discipler_change_log_tenant_select ON public.discipler_change_log;
DROP POLICY IF EXISTS discipler_change_log_tenant_insert ON public.discipler_change_log;
DROP POLICY IF EXISTS discipler_change_log_tenant_update ON public.discipler_change_log;
DROP POLICY IF EXISTS discipler_change_log_tenant_delete ON public.discipler_change_log;
CREATE POLICY discipler_change_log_tenant_select ON public.discipler_change_log FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY discipler_change_log_tenant_insert ON public.discipler_change_log FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY discipler_change_log_tenant_update ON public.discipler_change_log FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY discipler_change_log_tenant_delete ON public.discipler_change_log FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.discipler_change_log ENABLE ROW LEVEL SECURITY;

-- ===== library_chapter_progress =====
UPDATE public.library_chapter_progress SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS library_chapter_progress_tenant_select ON public.library_chapter_progress;
DROP POLICY IF EXISTS library_chapter_progress_tenant_insert ON public.library_chapter_progress;
DROP POLICY IF EXISTS library_chapter_progress_tenant_update ON public.library_chapter_progress;
DROP POLICY IF EXISTS library_chapter_progress_tenant_delete ON public.library_chapter_progress;
CREATE POLICY library_chapter_progress_tenant_select ON public.library_chapter_progress FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY library_chapter_progress_tenant_insert ON public.library_chapter_progress FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY library_chapter_progress_tenant_update ON public.library_chapter_progress FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY library_chapter_progress_tenant_delete ON public.library_chapter_progress FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.library_chapter_progress ENABLE ROW LEVEL SECURITY;

-- ===== library_progress =====
UPDATE public.library_progress SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS library_progress_tenant_select ON public.library_progress;
DROP POLICY IF EXISTS library_progress_tenant_insert ON public.library_progress;
DROP POLICY IF EXISTS library_progress_tenant_update ON public.library_progress;
DROP POLICY IF EXISTS library_progress_tenant_delete ON public.library_progress;
CREATE POLICY library_progress_tenant_select ON public.library_progress FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY library_progress_tenant_insert ON public.library_progress FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY library_progress_tenant_update ON public.library_progress FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY library_progress_tenant_delete ON public.library_progress FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.library_progress ENABLE ROW LEVEL SECURITY;

-- ===== library_quiz_attempts =====
UPDATE public.library_quiz_attempts SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS library_quiz_attempts_tenant_select ON public.library_quiz_attempts;
DROP POLICY IF EXISTS library_quiz_attempts_tenant_insert ON public.library_quiz_attempts;
DROP POLICY IF EXISTS library_quiz_attempts_tenant_update ON public.library_quiz_attempts;
DROP POLICY IF EXISTS library_quiz_attempts_tenant_delete ON public.library_quiz_attempts;
CREATE POLICY library_quiz_attempts_tenant_select ON public.library_quiz_attempts FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY library_quiz_attempts_tenant_insert ON public.library_quiz_attempts FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY library_quiz_attempts_tenant_update ON public.library_quiz_attempts FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY library_quiz_attempts_tenant_delete ON public.library_quiz_attempts FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.library_quiz_attempts ENABLE ROW LEVEL SECURITY;

-- ===== ministry_rosters =====
UPDATE public.ministry_rosters SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS ministry_rosters_tenant_select ON public.ministry_rosters;
DROP POLICY IF EXISTS ministry_rosters_tenant_insert ON public.ministry_rosters;
DROP POLICY IF EXISTS ministry_rosters_tenant_update ON public.ministry_rosters;
DROP POLICY IF EXISTS ministry_rosters_tenant_delete ON public.ministry_rosters;
CREATE POLICY ministry_rosters_tenant_select ON public.ministry_rosters FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY ministry_rosters_tenant_insert ON public.ministry_rosters FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY ministry_rosters_tenant_update ON public.ministry_rosters FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY ministry_rosters_tenant_delete ON public.ministry_rosters FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.ministry_rosters ENABLE ROW LEVEL SECURITY;

-- ===== ministry_roster_members =====
UPDATE public.ministry_roster_members SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS ministry_roster_members_tenant_select ON public.ministry_roster_members;
DROP POLICY IF EXISTS ministry_roster_members_tenant_insert ON public.ministry_roster_members;
DROP POLICY IF EXISTS ministry_roster_members_tenant_update ON public.ministry_roster_members;
DROP POLICY IF EXISTS ministry_roster_members_tenant_delete ON public.ministry_roster_members;
CREATE POLICY ministry_roster_members_tenant_select ON public.ministry_roster_members FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY ministry_roster_members_tenant_insert ON public.ministry_roster_members FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY ministry_roster_members_tenant_update ON public.ministry_roster_members FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY ministry_roster_members_tenant_delete ON public.ministry_roster_members FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.ministry_roster_members ENABLE ROW LEVEL SECURITY;

-- ===== prayer_intercessions =====
UPDATE public.prayer_intercessions SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS prayer_intercessions_tenant_select ON public.prayer_intercessions;
DROP POLICY IF EXISTS prayer_intercessions_tenant_insert ON public.prayer_intercessions;
DROP POLICY IF EXISTS prayer_intercessions_tenant_update ON public.prayer_intercessions;
DROP POLICY IF EXISTS prayer_intercessions_tenant_delete ON public.prayer_intercessions;
CREATE POLICY prayer_intercessions_tenant_select ON public.prayer_intercessions FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY prayer_intercessions_tenant_insert ON public.prayer_intercessions FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY prayer_intercessions_tenant_update ON public.prayer_intercessions FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY prayer_intercessions_tenant_delete ON public.prayer_intercessions FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.prayer_intercessions ENABLE ROW LEVEL SECURITY;

-- ===== prayer_list_items =====
UPDATE public.prayer_list_items SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS prayer_list_items_tenant_select ON public.prayer_list_items;
DROP POLICY IF EXISTS prayer_list_items_tenant_insert ON public.prayer_list_items;
DROP POLICY IF EXISTS prayer_list_items_tenant_update ON public.prayer_list_items;
DROP POLICY IF EXISTS prayer_list_items_tenant_delete ON public.prayer_list_items;
CREATE POLICY prayer_list_items_tenant_select ON public.prayer_list_items FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY prayer_list_items_tenant_insert ON public.prayer_list_items FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY prayer_list_items_tenant_update ON public.prayer_list_items FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY prayer_list_items_tenant_delete ON public.prayer_list_items FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.prayer_list_items ENABLE ROW LEVEL SECURITY;

-- ===== prayer_list_opens =====
UPDATE public.prayer_list_opens SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS prayer_list_opens_tenant_select ON public.prayer_list_opens;
DROP POLICY IF EXISTS prayer_list_opens_tenant_insert ON public.prayer_list_opens;
DROP POLICY IF EXISTS prayer_list_opens_tenant_update ON public.prayer_list_opens;
DROP POLICY IF EXISTS prayer_list_opens_tenant_delete ON public.prayer_list_opens;
CREATE POLICY prayer_list_opens_tenant_select ON public.prayer_list_opens FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY prayer_list_opens_tenant_insert ON public.prayer_list_opens FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY prayer_list_opens_tenant_update ON public.prayer_list_opens FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY prayer_list_opens_tenant_delete ON public.prayer_list_opens FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.prayer_list_opens ENABLE ROW LEVEL SECURITY;

-- ===== prayer_reminders =====
UPDATE public.prayer_reminders SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS prayer_reminders_tenant_select ON public.prayer_reminders;
DROP POLICY IF EXISTS prayer_reminders_tenant_insert ON public.prayer_reminders;
DROP POLICY IF EXISTS prayer_reminders_tenant_update ON public.prayer_reminders;
DROP POLICY IF EXISTS prayer_reminders_tenant_delete ON public.prayer_reminders;
CREATE POLICY prayer_reminders_tenant_select ON public.prayer_reminders FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY prayer_reminders_tenant_insert ON public.prayer_reminders FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY prayer_reminders_tenant_update ON public.prayer_reminders FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY prayer_reminders_tenant_delete ON public.prayer_reminders FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.prayer_reminders ENABLE ROW LEVEL SECURITY;

-- ===== prayer_requests =====
UPDATE public.prayer_requests SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS prayer_requests_tenant_select ON public.prayer_requests;
DROP POLICY IF EXISTS prayer_requests_tenant_insert ON public.prayer_requests;
DROP POLICY IF EXISTS prayer_requests_tenant_update ON public.prayer_requests;
DROP POLICY IF EXISTS prayer_requests_tenant_delete ON public.prayer_requests;
CREATE POLICY prayer_requests_tenant_select ON public.prayer_requests FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY prayer_requests_tenant_insert ON public.prayer_requests FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY prayer_requests_tenant_update ON public.prayer_requests FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY prayer_requests_tenant_delete ON public.prayer_requests FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.prayer_requests ENABLE ROW LEVEL SECURITY;

-- ===== transfers =====
UPDATE public.transfers SET church_id=(SELECT id FROM public.churches WHERE slug='rosehill') WHERE church_id IS NULL;
DROP POLICY IF EXISTS transfers_tenant_select ON public.transfers;
DROP POLICY IF EXISTS transfers_tenant_insert ON public.transfers;
DROP POLICY IF EXISTS transfers_tenant_update ON public.transfers;
DROP POLICY IF EXISTS transfers_tenant_delete ON public.transfers;
CREATE POLICY transfers_tenant_select ON public.transfers FOR SELECT TO authenticated USING (church_id = public.auth_church_id());
CREATE POLICY transfers_tenant_insert ON public.transfers FOR INSERT TO authenticated WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY transfers_tenant_update ON public.transfers FOR UPDATE TO authenticated USING (church_id = public.auth_church_id()) WITH CHECK (church_id = public.auth_church_id());
CREATE POLICY transfers_tenant_delete ON public.transfers FOR DELETE TO authenticated USING (church_id = public.auth_church_id());
ALTER TABLE public.transfers ENABLE ROW LEVEL SECURITY;

-- ===== ledger self-stamp =====
INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('026','026_rls_tier_b_batch1.sql','RLS tier-b batch 1 (13 tables): attendance_self_attest_log, discipler_change_log, library_chapter_progress, library_progress, library_quiz_attempts, ministry_rosters, ministry_roster_members, prayer_intercessions, prayer_list_items, prayer_list_opens, prayer_reminders, prayer_requests, transfers')
ON CONFLICT (version) DO UPDATE SET filename=EXCLUDED.filename, note=EXCLUDED.note, applied_at=now();
