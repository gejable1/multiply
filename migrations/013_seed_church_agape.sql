-- Phase 2 onboarding · ADDITIVE + IDEMPOTENT. No RLS change.
-- Inserts one tenant row; mirrors the Rosehill seed in 001.
INSERT INTO churches (name, slug, timezone)
VALUES ('Agape Christian Fellowship', 'agape', 'Asia/Manila')
ON CONFLICT (slug) DO NOTHING;
-- VERIFY:
-- SELECT id, name, slug, timezone, status, created_at FROM churches ORDER BY created_at;
