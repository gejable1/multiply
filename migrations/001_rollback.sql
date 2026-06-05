-- ============================================================================
-- migrations/001_rollback.sql
-- EMERGENCY UNDO for 001_add_tenancy.sql. Human-gated (Inv #5/#10) — the PASTOR
-- runs this in the Supabase SQL editor ONLY to reverse the tenancy migration.
-- Claude does NOT run it. Free tier = no DB backups, so this is the manual undo.
--
-- Reverses 001 exactly and idempotently:
--   1. Drops the nullable church_id column from each of the 41 tables 001 added
--      it to (40 PER-CHURCH + devotionals). DROP COLUMN also removes that
--      column's idx_<t>_church_id index AND its FK to churches(id) automatically.
--   2. Drops the churches tenant table.
--
-- Safe to re-run: IF EXISTS everywhere. 001 was additive (church_id nullable,
-- never NOT NULL) so reversal is clean. Table list is DERIVED from
-- 001_add_tenancy.sql, not retyped.
-- ============================================================================


-- ── 1. Drop church_id from the 41 tables 001 touched (drops idx + FK too) ────
ALTER TABLE absence_notices                    DROP COLUMN IF EXISTS church_id;
ALTER TABLE announcement_acks                  DROP COLUMN IF EXISTS church_id;
ALTER TABLE announcement_retraction_dismissals DROP COLUMN IF EXISTS church_id;
ALTER TABLE announcements                      DROP COLUMN IF EXISTS church_id;
ALTER TABLE attendance                         DROP COLUMN IF EXISTS church_id;
ALTER TABLE attendance_self_attest_log         DROP COLUMN IF EXISTS church_id;
ALTER TABLE btli_quiz_attempts                 DROP COLUMN IF EXISTS church_id;
ALTER TABLE cohort_lesson_unlocks              DROP COLUMN IF EXISTS church_id;
ALTER TABLE cohort_members                     DROP COLUMN IF EXISTS church_id;
ALTER TABLE cohorts                            DROP COLUMN IF EXISTS church_id;
ALTER TABLE debrief_records                    DROP COLUMN IF EXISTS church_id;
ALTER TABLE devotional_reflections             DROP COLUMN IF EXISTS church_id;
ALTER TABLE diagnostic_results                 DROP COLUMN IF EXISTS church_id;
ALTER TABLE discipler_change_log               DROP COLUMN IF EXISTS church_id;
ALTER TABLE gifts_diagnostic                   DROP COLUMN IF EXISTS church_id;
ALTER TABLE interventions                      DROP COLUMN IF EXISTS church_id;
ALTER TABLE leader_sessions                    DROP COLUMN IF EXISTS church_id;
ALTER TABLE library_chapter_progress           DROP COLUMN IF EXISTS church_id;
ALTER TABLE library_progress                   DROP COLUMN IF EXISTS church_id;
ALTER TABLE library_quiz_attempts              DROP COLUMN IF EXISTS church_id;
ALTER TABLE member_profiles                    DROP COLUMN IF EXISTS church_id;
ALTER TABLE members                            DROP COLUMN IF EXISTS church_id;
ALTER TABLE ministries                         DROP COLUMN IF EXISTS church_id;
ALTER TABLE ministry_intake                    DROP COLUMN IF EXISTS church_id;
ALTER TABLE ministry_roles                     DROP COLUMN IF EXISTS church_id;
ALTER TABLE ministry_roster_members            DROP COLUMN IF EXISTS church_id;
ALTER TABLE ministry_rosters                   DROP COLUMN IF EXISTS church_id;
ALTER TABLE notifications                      DROP COLUMN IF EXISTS church_id;
ALTER TABLE pipeline_lesson_grants             DROP COLUMN IF EXISTS church_id;
ALTER TABLE preachers                          DROP COLUMN IF EXISTS church_id;
ALTER TABLE preaching_swap_requests            DROP COLUMN IF EXISTS church_id;
ALTER TABLE profile_tokens                     DROP COLUMN IF EXISTS church_id;
ALTER TABLE sermons                            DROP COLUMN IF EXISTS church_id;
ALTER TABLE svi_snapshots                      DROP COLUMN IF EXISTS church_id;
ALTER TABLE svi_weight_profiles                DROP COLUMN IF EXISTS church_id;
ALTER TABLE system_settings                    DROP COLUMN IF EXISTS church_id;
ALTER TABLE transfers                          DROP COLUMN IF EXISTS church_id;
ALTER TABLE usbong_quiz_attempts               DROP COLUMN IF EXISTS church_id;
ALTER TABLE view_log                           DROP COLUMN IF EXISTS church_id;
ALTER TABLE wednesday_preaching                DROP COLUMN IF EXISTS church_id;
ALTER TABLE devotionals                        DROP COLUMN IF EXISTS church_id;

-- ── 2. Drop the tenant table itself ─────────────────────────────────────────
DROP TABLE IF EXISTS churches;


-- ── VERIFY (read-only) ──────────────────────────────────────────────────────
-- (A) No church_id column should remain on ANY public table (expect 0 rows):
SELECT table_name, column_name
FROM information_schema.columns
WHERE table_schema = 'public' AND column_name = 'church_id'
ORDER BY table_name;

-- (B) The churches table should be gone (expect 0 rows):
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public' AND table_name = 'churches';

-- ============================================================================
-- END 001_rollback.sql
-- ============================================================================
