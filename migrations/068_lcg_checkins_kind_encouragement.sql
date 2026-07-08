-- 068_lcg_checkins_kind_encouragement.sql
-- Session 67: extend lcg_leader_checkins.kind to allow 'encouragement' (one-way,
-- status 'sent') so the LCG Pulse "Building Rhythm" tier can send a customized
-- Encouragement distinct from check-ins and celebrations. Flat, rerunnable, self-verifying.

ALTER TABLE public.lcg_leader_checkins DROP CONSTRAINT IF EXISTS lcg_leader_checkins_kind_chk;
ALTER TABLE public.lcg_leader_checkins ADD CONSTRAINT lcg_leader_checkins_kind_chk
  CHECK (kind IN ('checkin','celebration','encouragement'));

INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('068', '068_lcg_checkins_kind_encouragement.sql', 'Extend kind CHECK to allow ''encouragement'' (one-way status ''sent'') for LCG Pulse Building-Rhythm encouragements')
ON CONFLICT (version) DO NOTHING;

-- self-verify (#210): the kind CHECK now includes 'encouragement'.
SELECT conname, pg_get_constraintdef(oid) AS def
FROM pg_constraint
WHERE conrelid = 'public.lcg_leader_checkins'::regclass AND conname = 'lcg_leader_checkins_kind_chk';
