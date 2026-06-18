-- ============================================================================
-- migrations/008_prayer_reminders.sql
-- Prayer / Panalangin — Wave 3 (Proactive): per-member "pray today" reminder.
--
-- Human-gated (Inv #5/#10): the PASTOR runs this in the Supabase SQL editor.
-- Additive & IDEMPOTENT (IF NOT EXISTS). Safe to re-run. Rollback committed
-- first: migrations/008_rollback.sql (Inv #157).
--
-- One row per member = their opt-in reminder preference. The MMT "pray today"
-- surface is CLIENT-SIDE: it reads this row + the member's active prayer-list
-- items and decides locally whether a (conservative, no-nag) nudge is due.
-- Until this table exists, the MMT read FAILS CLOSED (silent — no surface),
-- so shipping the MMT before this runs is safe.
--
-- TENANCY (Phase 1): nullable church_id + FK + index (set from the member row
-- on upsert). RLS disabled here (Inv #10) until RLS Phase 2.
-- ============================================================================

CREATE TABLE IF NOT EXISTS prayer_reminders (
    id               uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    member_id        uuid        NOT NULL UNIQUE REFERENCES members(id),
    enabled          boolean     NOT NULL DEFAULT false,   -- opt-in (off by default)
    cadence          text        NOT NULL DEFAULT 'daily'
                                 CHECK (cadence IN ('daily','weekly')),
    last_prompted_at timestamptz,                          -- last time the surface showed
    church_id        uuid        REFERENCES churches(id),
    created_at       timestamptz NOT NULL DEFAULT now(),
    updated_at       timestamptz NOT NULL DEFAULT now()
);
-- member_id already UNIQUE (the upsert conflict target); add the church_id index.
CREATE INDEX IF NOT EXISTS idx_prayer_reminders_church_id ON prayer_reminders(church_id);
CREATE INDEX IF NOT EXISTS idx_prayer_reminders_enabled   ON prayer_reminders(enabled);
ALTER TABLE prayer_reminders DISABLE ROW LEVEL SECURITY;


-- ============================================================================
-- VERIFY — ONE batch, ONE JSON result (Supabase mobile shows only the last grid).
-- all_ok = true means every check passed.
--   exists, has member_id UNIQUE, has church_id, rls disabled.
-- ============================================================================
WITH t AS (
  SELECT 1 FROM information_schema.tables
  WHERE table_schema='public' AND table_name='prayer_reminders'
),
cols AS (
  SELECT bool_or(column_name='church_id') AS has_church_id,
         bool_or(column_name='enabled')   AS has_enabled,
         bool_or(column_name='cadence')   AS has_cadence
  FROM information_schema.columns
  WHERE table_schema='public' AND table_name='prayer_reminders'
),
uq AS (
  SELECT count(*) AS n FROM pg_indexes
  WHERE schemaname='public' AND tablename='prayer_reminders'
    AND indexdef ILIKE '%UNIQUE%' AND indexdef ILIKE '%member_id%'
),
r AS (
  SELECT relrowsecurity FROM pg_class WHERE relkind='r' AND relname='prayer_reminders'
)
SELECT jsonb_pretty(jsonb_build_object(
  'table_exists',      (SELECT count(*) FROM t) = 1,
  'has_church_id',     (SELECT has_church_id FROM cols),
  'has_enabled',       (SELECT has_enabled FROM cols),
  'has_cadence',       (SELECT has_cadence FROM cols),
  'member_id_unique',  (SELECT n >= 1 FROM uq),
  'rls_disabled',      (SELECT relrowsecurity IS FALSE FROM r),
  'all_ok',
    ( (SELECT count(*) FROM t) = 1
      AND (SELECT has_church_id AND has_enabled AND has_cadence FROM cols)
      AND (SELECT n >= 1 FROM uq)
      AND (SELECT relrowsecurity IS FALSE FROM r) )
)) AS verify_008;
-- ============================================================================
-- END 008_prayer_reminders.sql
-- ============================================================================
