-- migrations/126_devo_streak_backfill.sql
-- S113 - Give back devotional streak days that were written on the right day
-- (>= 10 words, last saved the same Manila day) but never credited, because the
-- reflection was only AUTO-saved and the member left without tapping Save or X.
-- (Code fix ships separately: autosave will credit the day too.)
-- Found Nov 3, 2026: 12 days across 11 members (Oct 5 - Oct 31).
-- RUN FLAT (no BEGIN/COMMIT). Idempotent: re-running inserts nothing new.
-- No new tables or views (no GRANTs needed).

-- 1) Insert the missing attendance rows (same shape the app writes)
INSERT INTO public.attendance
  (member_id, member_name, event_type, event_date, event_name, present,
   logged_by, logged_by_id, church_id)
SELECT r.member_id, m.name, 'devotional', r.entry_date, 'Daily devotional', true,
       'Streak backfill (S113)', r.member_id, r.church_id
  FROM public.devotional_reflections r
  JOIN public.members m ON m.id = r.member_id
 WHERE r.entry_date >= DATE '2026-10-01'
   AND r.entry_date <= (now() AT TIME ZONE 'Asia/Manila')::date
   AND array_length(regexp_split_to_array(trim(r.reflection), '\s+'), 1) >= 10
   AND (r.updated_at AT TIME ZONE 'Asia/Manila')::date = r.entry_date
   AND NOT EXISTS (SELECT 1 FROM public.attendance a
                    WHERE a.member_id = r.member_id AND a.event_type = 'devotional'
                      AND a.event_date = r.entry_date);

-- 2) Safety net: if a church-stamp trigger blanked church_id (no JWT in the
--    SQL Editor), copy it from the member's reflection.
UPDATE public.attendance a
   SET church_id = r.church_id
  FROM public.devotional_reflections r
 WHERE a.logged_by = 'Streak backfill (S113)'
   AND a.church_id IS NULL
   AND r.member_id = a.member_id AND r.entry_date = a.event_date;

-- 3) Ledger stamp
INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('126', '126_devo_streak_backfill.sql',
        'S113 give back devotional streak days written same-day (>=10 words) but only autosaved')
ON CONFLICT (version) DO UPDATE
  SET filename = EXCLUDED.filename, note = EXCLUDED.note, applied_at = now();

-- 4) Self-verify (rerun until every row reads PASS)
SELECT 'backfilled rows (expect 12)' AS checkpoint,
       (SELECT count(*) FROM public.attendance WHERE logged_by = 'Streak backfill (S113)')::text AS status
UNION ALL
SELECT 'no uncredited same-day reflections left',
       CASE WHEN NOT EXISTS (
         SELECT 1 FROM public.devotional_reflections r
          WHERE r.entry_date >= DATE '2026-10-01'
            AND array_length(regexp_split_to_array(trim(r.reflection), '\s+'), 1) >= 10
            AND (r.updated_at AT TIME ZONE 'Asia/Manila')::date = r.entry_date
            AND NOT EXISTS (SELECT 1 FROM public.attendance a
                             WHERE a.member_id = r.member_id AND a.event_type = 'devotional'
                               AND a.event_date = r.entry_date))
       THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'backfilled rows have church_id',
       CASE WHEN NOT EXISTS (SELECT 1 FROM public.attendance
                              WHERE logged_by = 'Streak backfill (S113)' AND church_id IS NULL)
            THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'ledger 126',
       CASE WHEN EXISTS (SELECT 1 FROM public.schema_migrations WHERE version = '126') THEN 'PASS' ELSE 'FAIL' END;
