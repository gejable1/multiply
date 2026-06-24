-- migrations/023_schema_migrations_ledger.sql
-- Session 46 — schema_migrations ledger + reconcile-on-open foundation (Inv #208 sweep groundwork).
-- A GLOBAL metadata table (no church_id, deliberately OUTSIDE the tenancy sweep) that every
-- migration self-stamps, so the "dashboard-run-not-committed" gap becomes self-detecting:
-- diff applied rows here vs the migrations/ folder at session open.
-- RUN FLAT (no BEGIN/COMMIT) — Inv #209. Idempotent: CREATE IF NOT EXISTS; DROP POLICY IF EXISTS
-- before CREATE; backfill ON CONFLICT DO NOTHING (never clobbers a later real stamp); self-stamp
-- ON CONFLICT DO UPDATE; ENABLE re-run is a no-op.

-- 1) ledger table (global infra — NOT church-stamped)
CREATE TABLE IF NOT EXISTS public.schema_migrations (
  version    text PRIMARY KEY,
  filename   text NOT NULL,
  applied_at timestamptz NOT NULL DEFAULT now(),
  note       text
);

-- 2) RLS — read-only to authenticated; writes happen only as owner/service-role (migrations)
ALTER TABLE public.schema_migrations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS schema_migrations_read ON public.schema_migrations;
CREATE POLICY schema_migrations_read ON public.schema_migrations
  FOR SELECT TO authenticated USING (true);

-- 3) backfill applied history (DO NOTHING = insert-if-missing, never overwrite a real stamp)
INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('001','001_add_tenancy.sql','tenancy columns'),
  ('002','002_normalize_usbong_stems.sql','usbong stem normalize'),
  ('003','003_prayer_wave1.sql','prayer wave 1 tables'),
  ('004','004_promote_pending_lc_transfers_by_id.sql','promote pending transfers by id'),
  ('005','005_drop_dormant_lc_group_indexes.sql','drop dormant lc_group indexes'),
  ('007','007_refresh_stale_discipler_names.sql','cosmetic discipler_name refresh (Inv #166)'),
  ('008','008_prayer_reminders.sql','prayer reminders'),
  ('009','009_svi_prayer.sql','svi prayer category'),
  ('010','010_lc_meeting_scoring.sql','LC-meeting SVI scoring'),
  ('011','011_devo_reflection_streak_cleanup.sql','devo reflection >=10-word streak cleanup'),
  ('012','012_tenancy_jwt_helpers.sql','auth_church_id/member_id/level helpers'),
  ('013','013_seed_church_agape.sql','seed Agape church'),
  ('014','014_church_id_autostamp_trigger.sql','church_id BEFORE INSERT autostamp'),
  ('015','015_rls_canary_debrief_records.sql','RLS canary debrief_records'),
  ('016','016_rls_cohort_lesson_family.sql','RLS cohort/lesson family'),
  ('017','017_rls_communication_family.sql','RLS communication family'),
  ('018','018_rls_sermons.sql','RLS sermons'),
  ('019','019_rls_preaching_tables.sql','RLS preaching family'),
  ('020','020_members_rls.sql','RLS members (last per-church table, S44)'),
  ('021','(file pending)','assessment RLS member_profiles+gifts_diagnostic — applied S42, file not yet committed (next-up #3)'),
  ('022','022_rls_quiz_attempts_and_view_invoker.sql','RLS quiz attempts + 6 view invoker flips')
ON CONFLICT (version) DO NOTHING;

-- 4) self-stamp this migration
INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('023','023_schema_migrations_ledger.sql','create ledger + backfill history + reconcile foundation')
ON CONFLICT (version) DO UPDATE
  SET filename = EXCLUDED.filename, note = EXCLUDED.note, applied_at = now();

-- 5) verify (read-only)
-- SELECT version, filename, note FROM public.schema_migrations ORDER BY version;
