-- ════════════════════════════════════════════════════════════════════
-- migration 044 — creative_arts base archetype + finish Rosehill tagging
-- Adds 1 base archetype (creative_arts) and tags the last 3 ministries.
-- FLAT · idempotent · rerun-until-true. Depends on 043.
-- ════════════════════════════════════════════════════════════════════

-- ── 1. New BASE archetype: creative_arts (church_id NULL) ──
INSERT INTO ministry_archetypes (church_id, archetype_key, name, summary, scoring, display_order, active) VALUES
  (NULL, 'creative_arts', 'Creative Arts', 'Dance, visual arts, drama, and creative expression in worship.', '{"adv": [{"src": "TALENT", "sig": "Creative & Aesthetic strong (≥8)", "w": 3, "key": "talent_creative_strong", "reason": "Core — creative arts is aesthetic expression."}, {"src": "TALENT", "sig": "Physical & Maintenance strong (≥8)", "w": 2, "key": "talent_physical_strong", "reason": "Dance and movement arts are physical."}, {"src": "GIFT", "sig": "Service/Helps strong (≥18)", "w": 2, "key": "gift_service_strong", "reason": "Serves the congregation through artistry."}, {"src": "GIFT", "sig": "Encouragement strong (≥18)", "w": 2, "key": "gift_exhortation_strong", "reason": "Art lifts and stirs the heart toward God."}, {"src": "GIFT", "sig": "Hospitality strong (≥18)", "w": 1, "key": "gift_hospitality_strong", "reason": "Beauty welcomes people into worship."}, {"src": "GIFT", "sig": "Faith strong (≥18)", "w": 1, "key": "gift_faith_strong", "reason": "Creative expression takes faith and risk."}, {"src": "DISC", "sig": "I primary or secondary", "w": 2, "key": "disc_I", "reason": "Expressive, performative energy."}, {"src": "DISC", "sig": "S primary or secondary", "w": 1, "key": "disc_S", "reason": "Reliable through long rehearsal seasons."}, {"src": "ENN", "sig": "Type 4 (Individualist)", "w": 3, "key": "enn_4", "reason": "The artist''s heart — depth and aesthetic sensibility."}, {"src": "ENN", "sig": "Type 7 (Enthusiast)", "w": 1, "key": "enn_7", "reason": "Joyful energy fuels performance."}, {"src": "STR", "sig": "Ideation", "w": 2, "key": "str_Ideation", "reason": "Generates fresh creative concepts."}, {"src": "STR", "sig": "Adaptability", "w": 2, "key": "str_Adaptability", "reason": "Choreography and staging shift constantly."}, {"src": "STR", "sig": "Communication", "w": 1, "key": "str_Communication", "reason": "Performance is a language of its own."}, {"src": "STR", "sig": "Positivity", "w": 1, "key": "str_Positivity", "reason": "Uplifting presence on and off stage."}], "risk": [{"src": "TALENT", "sig": "Creative & Aesthetic weak (≤4)", "w": 3, "key": "talent_creative_weak", "reason": "Central mismatch — the art won''t land."}, {"src": "ENN", "sig": "Type 5 (Investigator)", "w": 1, "key": "enn_5", "reason": "Detached from expressive performance."}, {"src": "DISC", "sig": "C primary (very high)", "w": 1, "key": "disc_C_high", "reason": "Perfectionism can stifle creative flow."}], "profile": {"primary": ["service", "exhortation"], "secondary": ["hospitality", "faith"]}}'::jsonb, 17, true)
ON CONFLICT (archetype_key) WHERE church_id IS NULL DO UPDATE SET
  name=EXCLUDED.name, summary=EXCLUDED.summary, scoring=EXCLUDED.scoring, display_order=EXCLUDED.display_order, active=EXCLUDED.active, updated_at=now();

-- ── 2. Tag the last 3 Rosehill ministries (Chorale→worship, Dance→creative_arts, Engaging→hospitality) ──
UPDATE ministries m SET archetype_key = v.k
FROM (VALUES
  ('Chorale','worship'),
  ('Dance','creative_arts'),
  ('Engaging','hospitality')
) AS v(mname, k)
WHERE m.church_id = '724f4826-0f83-4ce8-bfc0-83698b79ce6f'::uuid AND m.name = v.mname;

-- ── 3. Self-verify (rerun until: 17 / 0 / worship / creative_arts / hospitality) ──
SELECT
  (SELECT count(*) FROM ministry_archetypes WHERE church_id IS NULL)                                          AS base_count,
  (SELECT count(*) FROM ministries WHERE church_id='724f4826-0f83-4ce8-bfc0-83698b79ce6f'::uuid AND archetype_key IS NULL)                  AS untagged,
  (SELECT archetype_key FROM ministries WHERE church_id='724f4826-0f83-4ce8-bfc0-83698b79ce6f'::uuid AND name='Chorale')                    AS chorale_key,
  (SELECT archetype_key FROM ministries WHERE church_id='724f4826-0f83-4ce8-bfc0-83698b79ce6f'::uuid AND name='Dance')                      AS dance_key,
  (SELECT archetype_key FROM ministries WHERE church_id='724f4826-0f83-4ce8-bfc0-83698b79ce6f'::uuid AND name='Engaging')                   AS engaging_key;

-- ── 4. Ledger stamp ──
INSERT INTO schema_migrations (version, filename, note)
VALUES ('044','044_creative_arts_archetype.sql','creative_arts base archetype; tag Chorale/Dance/Engaging — Rosehill fully tagged')
ON CONFLICT (version) DO UPDATE SET filename=EXCLUDED.filename, note=EXCLUDED.note, applied_at=now();
