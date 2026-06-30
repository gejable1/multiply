-- ════════════════════════════════════════════════════════════════════
-- migration 046 — rename Agape church (data fix)
-- "Agape Christian Fellowship" → "Agape Christian Church"
-- Branding is dynamic (every surface paints churches.name via the JWT),
-- so this propagates everywhere automatically; no code change needed.
-- FLAT · idempotent · self-verify.
-- ════════════════════════════════════════════════════════════════════

UPDATE churches
   SET name = 'Agape Christian Church', updated_at = now()
 WHERE slug = 'agape';

-- verify (expect: agape · Agape Christian Church)
SELECT id, slug, name FROM churches WHERE slug = 'agape';

-- ledger
INSERT INTO schema_migrations (version, filename, note)
VALUES ('046','046_rename_agape.sql','rename Agape Christian Fellowship -> Agape Christian Church')
ON CONFLICT (version) DO UPDATE SET filename=EXCLUDED.filename, note=EXCLUDED.note, applied_at=now();
