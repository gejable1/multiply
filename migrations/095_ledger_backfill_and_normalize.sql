-- 095_ledger_backfill_and_normalize.sql
-- Session 82. Ledger repair 1 of 2 (Inv #399 pre-flight).
--
-- Part A: four rows were stamped unpadded ('73'..'76') instead of '073'..'076',
--         which made ORDER BY version (a text sort) float them above '094'.
-- Part B: migrations 078-082 ran in S76-S79 but their bodies contained NO
--         schema_migrations INSERT at all, so they were applied and never
--         recorded. All five were confirmed live against schema.json before
--         backfilling (source_* columns, mlt_delete_empty_member, the 'other'
--         reason_code, app_sessions present, leader_sessions absent).
--
-- No schema change. Flat, idempotent, self-verifying.
-- NOTE: as originally executed this file asserted a GLOBAL row count of 94,
-- which every later migration invalidates. The verify block below asserts
-- only THIS migration's own effects, so it stays true on any future rerun.

-- PART A -- pad only where the padded form is not already taken
UPDATE public.schema_migrations m
   SET version = lpad(m.version, 3, '0')
 WHERE m.version ~ '^[0-9]{1,2}$'
   AND NOT EXISTS (
     SELECT 1 FROM public.schema_migrations x
      WHERE x.version = lpad(m.version, 3, '0')
   );

-- PART B -- backfill the five applied-but-unstamped migrations.
-- applied_at is deliberately NOT touched on conflict: these ran weeks ago.
INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('078','078_lc_meeting_guides_source.sql','Backfilled S82: applied (source_kind/source_title/source_text live) but body carried no stamp'),
  ('079','079_mlt_delete_empty_member.sql','Backfilled S82: applied (function live, body matches file) but no stamp'),
  ('080','080_checkins_reason_add_other.sql','Backfilled S82: applied (lcg_checkins_reason_chk allows other) but no stamp'),
  ('081','081_app_sessions_unified.sql','Backfilled S82: applied (app_sessions live) but no stamp'),
  ('082','082_drop_leader_sessions.sql','Backfilled S82: applied (leader_sessions absent) but no stamp')
ON CONFLICT (version) DO UPDATE SET filename=excluded.filename, note=excluded.note;

-- STAMP THIS MIGRATION
INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('095','095_ledger_backfill_and_normalize.sql','Ledger repair 1/2: padded 073-076; backfilled stamps for 078-082. No schema change.')
ON CONFLICT (version) DO UPDATE SET filename=excluded.filename, note=excluded.note, applied_at=now();

-- SELF-VERIFY -- expect all_ok = PASS. Asserts only this migration's effects.
SELECT
  (SELECT count(*) FROM public.schema_migrations WHERE version ~ '^[0-9]{1,2}$') AS unpadded_left,
  (SELECT count(*) FROM public.schema_migrations WHERE version IN ('078','079','080','081','082')) AS backfilled,
  (SELECT count(*) FROM public.schema_migrations WHERE version = '095') AS self_stamped,
  CASE WHEN (SELECT count(*) FROM public.schema_migrations WHERE version ~ '^[0-9]{1,2}$') = 0
        AND (SELECT count(*) FROM public.schema_migrations WHERE version IN ('078','079','080','081','082')) = 5
        AND (SELECT count(*) FROM public.schema_migrations WHERE version = '095') = 1
       THEN 'PASS' ELSE 'FAIL' END AS all_ok;
