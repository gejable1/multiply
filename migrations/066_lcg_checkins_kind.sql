-- 066_lcg_checkins_kind.sql
-- Phase 1 of Celebrate-button wiring: add a `kind` discriminator to lcg_leader_checkins
-- so the same table can hold shepherd check-ins (two-way) and pastor celebrations
-- (one-way, status 'sent'). Flat, rerunnable, self-verifying.

-- 1) kind discriminator (checkin | celebration), default preserves existing rows as check-ins.
ALTER TABLE public.lcg_leader_checkins ADD COLUMN IF NOT EXISTS kind text NOT NULL DEFAULT 'checkin';
ALTER TABLE public.lcg_leader_checkins DROP CONSTRAINT IF EXISTS lcg_leader_checkins_kind_chk;
ALTER TABLE public.lcg_leader_checkins ADD CONSTRAINT lcg_leader_checkins_kind_chk CHECK (kind IN ('checkin','celebration'));

-- 2) Extend the status CHECK to allow 'sent' — celebrations are one-way (no reply
--    lifecycle), so they log as status 'sent'. Without this, the celebration INSERT
--    violates lcg_checkins_status_chk (originally IN ('awaiting','answered','resolved')).
ALTER TABLE public.lcg_leader_checkins DROP CONSTRAINT IF EXISTS lcg_checkins_status_chk;
ALTER TABLE public.lcg_leader_checkins ADD CONSTRAINT lcg_checkins_status_chk
  CHECK (status IN ('awaiting','answered','resolved','sent'));

INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('066', '066_lcg_checkins_kind.sql', 'Add kind (checkin|celebration) + allow status ''sent'' on lcg_leader_checkins for one-way celebration logging')
ON CONFLICT (version) DO NOTHING;

-- self-verify (#210): expect kind row -> is_nullable=NO, default begins with 'checkin';
-- and the status CHECK now includes 'sent'.
SELECT column_name, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'lcg_leader_checkins' AND column_name = 'kind';

SELECT conname, pg_get_constraintdef(oid) AS def
FROM pg_constraint
WHERE conrelid = 'public.lcg_leader_checkins'::regclass AND conname = 'lcg_checkins_status_chk';
