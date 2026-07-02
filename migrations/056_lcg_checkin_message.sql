-- 056_lcg_checkin_message.sql
-- Store the exact check-in message the Pulse composed, so the LC Leader sees the
-- same words (naming the LC meeting) instead of a generic prompt.

ALTER TABLE public.lcg_leader_checkins ADD COLUMN IF NOT EXISTS message text;

INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('056_lcg_checkin_message','056_lcg_checkin_message.sql',
  'Add message column so the LCL reply screen echoes the pastor''s actual check-in text.')
ON CONFLICT (version) DO NOTHING;

-- verify: expect 1
SELECT count(*) AS message_col_should_be_1
FROM information_schema.columns
WHERE table_schema='public' AND table_name='lcg_leader_checkins' AND column_name='message';
