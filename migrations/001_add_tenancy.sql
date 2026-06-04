-- ============================================================================
-- migrations/001_add_tenancy.sql
-- Phase 1: add tenancy schema (churches + nullable church_id), ADDITIVE & IDEMPOTENT.
--
-- Human-gated (Inv #5/#10): the PASTOR runs this in the Supabase SQL editor.
-- Claude does NOT run migrations and holds no service-role key. Read-safe to
-- re-run: every step uses IF NOT EXISTS / ON CONFLICT / WHERE church_id IS NULL.
--
-- WHAT THIS DOES (eyeball this list before running):
--   1. Creates `churches` (tenant table), RLS disabled (Phase 2 adds RLS).
--   2. Seeds one church: Rosehill Christian Church (slug 'rosehill').
--   3. Adds a NULLABLE `church_id uuid REFERENCES churches(id)` + a
--      `idx_<t>_church_id` index to the 40 PER-CHURCH tables below, then
--      backfills each to the Rosehill id.
--   4. Adds the same nullable column + index to `devotionals` (GLOBAL/SHARED)
--      but does NOT backfill it — NULL = shared/global content, by design.
--   5. Verify-SELECTs at the end.
--
-- NO column is made NOT NULL (deferred: the app does not yet set church_id on
-- insert). Phase 2 will turn on RLS + church-scoped policies and tighten this.
--
-- TABLES THAT GET church_id (41 total):
--   • 40 PER-CHURCH (added + backfilled to Rosehill):
--       absence_notices, announcement_acks, announcement_retraction_dismissals,
--       announcements, attendance, attendance_self_attest_log, btli_quiz_attempts,
--       cohort_lesson_unlocks, cohort_members, cohorts, debrief_records,
--       devotional_reflections, diagnostic_results, discipler_change_log,
--       gifts_diagnostic, interventions, leader_sessions, library_chapter_progress,
--       library_progress, library_quiz_attempts, member_profiles, members,
--       ministries, ministry_intake, ministry_roles, ministry_roster_members,
--       ministry_rosters, notifications, pipeline_lesson_grants, preachers,
--       preaching_swap_requests, profile_tokens, sermons, svi_snapshots,
--       svi_weight_profiles, system_settings, transfers, usbong_quiz_attempts,
--       view_log, wednesday_preaching
--   • 1 GLOBAL (added + indexed, NOT backfilled — stays NULL = shared):
--       devotionals
--
-- TABLES INTENTIONALLY EXCLUDED (no church_id):
--   • _backup_members_diag_zone_2026_05_06  -- backup/temp; drop candidate (Inv/AUDIT)
--   • GLOBAL/SHARED catalog (8): pipeline_lessons, library_resources,
--       library_chapters, library_quizzes, btli_quizzes, usbong_quizzes,
--       cohort_programs, svi_metrics
--
-- Source of truth: TENANCY_AUDIT.md §1 + PHASE1_PREP.md §1 (live-DB confirmed
-- 2026-06-04). gen_random_uuid() is built-in on PostgreSQL 13+ (Supabase = PG15).
-- ============================================================================


-- ── 1. churches (tenant table) ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS churches (
    id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    name       text        NOT NULL,
    slug       text        UNIQUE NOT NULL,
    timezone   text        NOT NULL DEFAULT 'Asia/Manila',
    branding   jsonb       NOT NULL DEFAULT '{}'::jsonb,
    settings   jsonb       NOT NULL DEFAULT '{}'::jsonb,
    status     text        NOT NULL DEFAULT 'active',
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Phase 1 keeps the DB layer open; Phase 2 introduces RLS + church-scoped policies.
ALTER TABLE churches DISABLE ROW LEVEL SECURITY;


-- ── 2. Seed the first church: Rosehill ─────────────────────────────────────
INSERT INTO churches (name, slug, timezone)
VALUES ('Rosehill Christian Church', 'rosehill', 'Asia/Manila')
ON CONFLICT (slug) DO NOTHING;


-- ── 3. PER-CHURCH tables: add nullable church_id + index (40 tables) ────────
-- (FK is added inline; ADD COLUMN IF NOT EXISTS makes the whole step a no-op on re-run.)
ALTER TABLE absence_notices                    ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_absence_notices_church_id                    ON absence_notices(church_id);

ALTER TABLE announcement_acks                  ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_announcement_acks_church_id                  ON announcement_acks(church_id);

ALTER TABLE announcement_retraction_dismissals ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_announcement_retraction_dismissals_church_id ON announcement_retraction_dismissals(church_id);

ALTER TABLE announcements                      ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_announcements_church_id                      ON announcements(church_id);

ALTER TABLE attendance                         ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_attendance_church_id                         ON attendance(church_id);

ALTER TABLE attendance_self_attest_log         ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_attendance_self_attest_log_church_id         ON attendance_self_attest_log(church_id);

ALTER TABLE btli_quiz_attempts                 ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_btli_quiz_attempts_church_id                 ON btli_quiz_attempts(church_id);

ALTER TABLE cohort_lesson_unlocks              ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_cohort_lesson_unlocks_church_id              ON cohort_lesson_unlocks(church_id);

ALTER TABLE cohort_members                     ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_cohort_members_church_id                     ON cohort_members(church_id);

ALTER TABLE cohorts                            ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_cohorts_church_id                            ON cohorts(church_id);

ALTER TABLE debrief_records                    ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_debrief_records_church_id                    ON debrief_records(church_id);

ALTER TABLE devotional_reflections             ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_devotional_reflections_church_id             ON devotional_reflections(church_id);

ALTER TABLE diagnostic_results                 ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_diagnostic_results_church_id                 ON diagnostic_results(church_id);

ALTER TABLE discipler_change_log               ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_discipler_change_log_church_id               ON discipler_change_log(church_id);

ALTER TABLE gifts_diagnostic                   ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_gifts_diagnostic_church_id                   ON gifts_diagnostic(church_id);

ALTER TABLE interventions                      ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_interventions_church_id                      ON interventions(church_id);

ALTER TABLE leader_sessions                    ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_leader_sessions_church_id                    ON leader_sessions(church_id);

ALTER TABLE library_chapter_progress           ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_library_chapter_progress_church_id           ON library_chapter_progress(church_id);

ALTER TABLE library_progress                   ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_library_progress_church_id                   ON library_progress(church_id);

ALTER TABLE library_quiz_attempts              ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_library_quiz_attempts_church_id              ON library_quiz_attempts(church_id);

ALTER TABLE member_profiles                    ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_member_profiles_church_id                    ON member_profiles(church_id);

ALTER TABLE members                            ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_members_church_id                            ON members(church_id);

ALTER TABLE ministries                         ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_ministries_church_id                         ON ministries(church_id);

ALTER TABLE ministry_intake                    ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_ministry_intake_church_id                    ON ministry_intake(church_id);

ALTER TABLE ministry_roles                     ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_ministry_roles_church_id                     ON ministry_roles(church_id);

ALTER TABLE ministry_roster_members            ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_ministry_roster_members_church_id            ON ministry_roster_members(church_id);

ALTER TABLE ministry_rosters                   ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_ministry_rosters_church_id                   ON ministry_rosters(church_id);

ALTER TABLE notifications                      ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_notifications_church_id                      ON notifications(church_id);

ALTER TABLE pipeline_lesson_grants             ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_pipeline_lesson_grants_church_id             ON pipeline_lesson_grants(church_id);

ALTER TABLE preachers                          ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_preachers_church_id                          ON preachers(church_id);

ALTER TABLE preaching_swap_requests            ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_preaching_swap_requests_church_id            ON preaching_swap_requests(church_id);

ALTER TABLE profile_tokens                     ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_profile_tokens_church_id                     ON profile_tokens(church_id);

ALTER TABLE sermons                            ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_sermons_church_id                            ON sermons(church_id);

ALTER TABLE svi_snapshots                      ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_svi_snapshots_church_id                      ON svi_snapshots(church_id);

ALTER TABLE svi_weight_profiles                ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_svi_weight_profiles_church_id                ON svi_weight_profiles(church_id);

ALTER TABLE system_settings                    ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_system_settings_church_id                    ON system_settings(church_id);

ALTER TABLE transfers                          ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_transfers_church_id                          ON transfers(church_id);

ALTER TABLE usbong_quiz_attempts               ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_usbong_quiz_attempts_church_id               ON usbong_quiz_attempts(church_id);

ALTER TABLE view_log                           ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_view_log_church_id                           ON view_log(church_id);

ALTER TABLE wednesday_preaching                ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_wednesday_preaching_church_id                ON wednesday_preaching(church_id);


-- ── 4. GLOBAL/SHARED: devotionals — add column + index, NO backfill ─────────
-- NULL church_id = shared/global content, by design (PHASE1_PREP §1).
ALTER TABLE devotionals                        ADD COLUMN IF NOT EXISTS church_id uuid REFERENCES churches(id);
CREATE INDEX IF NOT EXISTS idx_devotionals_church_id                        ON devotionals(church_id);


-- ── 5. Backfill the 40 PER-CHURCH tables to Rosehill ───────────────────────
-- Idempotent: only fills rows still NULL, so a re-run is a no-op.
UPDATE absence_notices                    SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE announcement_acks                  SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE announcement_retraction_dismissals SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE announcements                      SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE attendance                         SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE attendance_self_attest_log         SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE btli_quiz_attempts                 SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE cohort_lesson_unlocks              SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE cohort_members                     SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE cohorts                            SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE debrief_records                    SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE devotional_reflections             SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE diagnostic_results                 SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE discipler_change_log               SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE gifts_diagnostic                   SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE interventions                      SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE leader_sessions                    SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE library_chapter_progress           SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE library_progress                   SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE library_quiz_attempts              SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE member_profiles                    SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE members                            SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE ministries                         SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE ministry_intake                    SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE ministry_roles                     SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE ministry_roster_members            SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE ministry_rosters                   SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE notifications                      SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE pipeline_lesson_grants             SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE preachers                          SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE preaching_swap_requests            SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE profile_tokens                     SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE sermons                            SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE svi_snapshots                      SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE svi_weight_profiles                SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE system_settings                    SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE transfers                          SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE usbong_quiz_attempts               SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE view_log                           SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
UPDATE wednesday_preaching                SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL;
-- (devotionals is intentionally NOT backfilled — see step 4.)


-- ============================================================================
-- 6. VERIFY (read-only). Supabase shows only the LAST result grid, so
--    highlight + run each verify query below individually.
-- ============================================================================

-- 6a. Rosehill church row exists (expect exactly 1 row):
SELECT id, name, slug, timezone, status FROM churches WHERE slug = 'rosehill';

-- 6b. Confirm church_id column now exists on all 41 touched tables
--     (expect 41 rows, has_church_id = true for every one):
SELECT table_name, bool_or(column_name = 'church_id') AS has_church_id
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN (
    'absence_notices','announcement_acks','announcement_retraction_dismissals',
    'announcements','attendance','attendance_self_attest_log','btli_quiz_attempts',
    'cohort_lesson_unlocks','cohort_members','cohorts','debrief_records',
    'devotional_reflections','diagnostic_results','discipler_change_log',
    'gifts_diagnostic','interventions','leader_sessions','library_chapter_progress',
    'library_progress','library_quiz_attempts','member_profiles','members',
    'ministries','ministry_intake','ministry_roles','ministry_roster_members',
    'ministry_rosters','notifications','pipeline_lesson_grants','preachers',
    'preaching_swap_requests','profile_tokens','sermons','svi_snapshots',
    'svi_weight_profiles','system_settings','transfers','usbong_quiz_attempts',
    'view_log','wednesday_preaching','devotionals')
GROUP BY table_name
ORDER BY table_name;

-- 6c. Per-table NULL vs non-NULL church_id counts.
--     Expect: the 40 PER-CHURCH tables show null_ct = 0 (all backfilled);
--             `devotionals` shows set_ct = 0 (all NULL = shared/global);
--             the sentinel `~ churches(rosehill) exists` row shows set_ct = 1.
SELECT * FROM (
  SELECT '~ churches(rosehill) exists'           AS table_name, 0::bigint AS null_ct, count(*) AS set_ct FROM churches WHERE slug='rosehill'
  UNION ALL SELECT 'absence_notices',                    count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM absence_notices
  UNION ALL SELECT 'announcement_acks',                  count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM announcement_acks
  UNION ALL SELECT 'announcement_retraction_dismissals', count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM announcement_retraction_dismissals
  UNION ALL SELECT 'announcements',                      count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM announcements
  UNION ALL SELECT 'attendance',                         count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM attendance
  UNION ALL SELECT 'attendance_self_attest_log',         count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM attendance_self_attest_log
  UNION ALL SELECT 'btli_quiz_attempts',                 count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM btli_quiz_attempts
  UNION ALL SELECT 'cohort_lesson_unlocks',              count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM cohort_lesson_unlocks
  UNION ALL SELECT 'cohort_members',                     count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM cohort_members
  UNION ALL SELECT 'cohorts',                            count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM cohorts
  UNION ALL SELECT 'debrief_records',                    count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM debrief_records
  UNION ALL SELECT 'devotional_reflections',             count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM devotional_reflections
  UNION ALL SELECT 'diagnostic_results',                 count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM diagnostic_results
  UNION ALL SELECT 'discipler_change_log',               count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM discipler_change_log
  UNION ALL SELECT 'gifts_diagnostic',                   count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM gifts_diagnostic
  UNION ALL SELECT 'interventions',                      count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM interventions
  UNION ALL SELECT 'leader_sessions',                    count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM leader_sessions
  UNION ALL SELECT 'library_chapter_progress',           count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM library_chapter_progress
  UNION ALL SELECT 'library_progress',                   count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM library_progress
  UNION ALL SELECT 'library_quiz_attempts',              count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM library_quiz_attempts
  UNION ALL SELECT 'member_profiles',                    count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM member_profiles
  UNION ALL SELECT 'members',                            count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM members
  UNION ALL SELECT 'ministries',                         count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM ministries
  UNION ALL SELECT 'ministry_intake',                    count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM ministry_intake
  UNION ALL SELECT 'ministry_roles',                     count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM ministry_roles
  UNION ALL SELECT 'ministry_roster_members',            count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM ministry_roster_members
  UNION ALL SELECT 'ministry_rosters',                   count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM ministry_rosters
  UNION ALL SELECT 'notifications',                      count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM notifications
  UNION ALL SELECT 'pipeline_lesson_grants',             count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM pipeline_lesson_grants
  UNION ALL SELECT 'preachers',                          count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM preachers
  UNION ALL SELECT 'preaching_swap_requests',            count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM preaching_swap_requests
  UNION ALL SELECT 'profile_tokens',                     count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM profile_tokens
  UNION ALL SELECT 'sermons',                            count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM sermons
  UNION ALL SELECT 'svi_snapshots',                      count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM svi_snapshots
  UNION ALL SELECT 'svi_weight_profiles',                count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM svi_weight_profiles
  UNION ALL SELECT 'system_settings',                    count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM system_settings
  UNION ALL SELECT 'transfers',                          count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM transfers
  UNION ALL SELECT 'usbong_quiz_attempts',               count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM usbong_quiz_attempts
  UNION ALL SELECT 'view_log',                           count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM view_log
  UNION ALL SELECT 'wednesday_preaching',                count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM wednesday_preaching
  UNION ALL SELECT 'devotionals (GLOBAL: expect set_ct=0)', count(*) FILTER (WHERE church_id IS NULL), count(*) FILTER (WHERE church_id IS NOT NULL) FROM devotionals
) q
ORDER BY table_name;

-- 6d. Explicit devotionals all-NULL confirmation (expect non_null = 0):
SELECT count(*) AS total,
       count(church_id) AS non_null,
       count(*) - count(church_id) AS nulls
FROM devotionals;

-- ============================================================================
-- END 001_add_tenancy.sql  — additive, idempotent, NOT NULL deferred to a later
-- migration once the app sets church_id on every insert. Phase 2 = RLS + policies.
-- ============================================================================
