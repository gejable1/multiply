-- ════════════════════════════════════════════════════════════════════
-- migration 045 — enable RLS on ministry_archetypes  (Phase B · part a)
-- The 4 tenant policies already exist (043). No in-app write path exists,
-- and both read paths already filter base-or-mine, so this flip is transparent
-- to the app and simply closes the cross-tenant overlay-read hole at the DB layer.
-- FLAT · idempotent · rerun-until-true.
-- ════════════════════════════════════════════════════════════════════

ALTER TABLE ministry_archetypes ENABLE ROW LEVEL SECURITY;

-- self-verify (rerun until: t / 4)
SELECT
  (SELECT relrowsecurity FROM pg_class WHERE relname='ministry_archetypes')                                       AS rls_enabled,
  (SELECT count(*) FROM pg_policies WHERE schemaname='public' AND tablename='ministry_archetypes')                 AS policy_count;

-- ledger
INSERT INTO schema_migrations (version, filename, note)
VALUES ('045','045_archetypes_rls_enable.sql','enable RLS on ministry_archetypes (Phase B a); 4 tenant policies pre-exist (043)')
ON CONFLICT (version) DO UPDATE SET filename=EXCLUDED.filename, note=EXCLUDED.note, applied_at=now();
