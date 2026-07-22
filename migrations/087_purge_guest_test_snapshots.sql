-- =====================================================================
-- 087_purge_guest_test_snapshots.sql
-- The SVI compute historically scored GUESTS (is_external_user) — only test
-- members were excluded — so svi_snapshots accumulated guest rows, inflating
-- the report count (e.g. Rosehill 215 instead of ~170). The EF is being fixed
-- to exclude guests from both member loads; this one-time purge removes the
-- guest (and any stray test-member) snapshots that already exist, so the
-- report drops immediately rather than aging out over a week.
-- Idempotent (rerun deletes 0). Cross-church (editor bypasses RLS by design).
-- Human-gated: run in Supabase SQL Editor (expect all_ok=PASS), commit.
-- =====================================================================

DELETE FROM svi_snapshots s
USING members m
WHERE s.member_id = m.id
  AND (m.is_external_user = true OR m.is_test_member = true);

INSERT INTO schema_migrations (version, filename, note)
VALUES ('087','087_purge_guest_test_snapshots.sql','Purge svi_snapshots rows for guests (is_external_user) + test members; EF now excludes guests from both member loads')
ON CONFLICT (version) DO NOTHING;

SELECT
  (SELECT count(*) FROM svi_snapshots s JOIN members m ON m.id = s.member_id
     WHERE m.is_external_user = true OR m.is_test_member = true) AS guest_test_snaps_remaining,
  CASE WHEN (SELECT count(*) FROM svi_snapshots s JOIN members m ON m.id = s.member_id
     WHERE m.is_external_user = true OR m.is_test_member = true) = 0
       THEN 'PASS' ELSE 'FAIL' END AS all_ok;
