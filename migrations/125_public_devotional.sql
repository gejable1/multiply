-- migrations/125_public_devotional.sql
-- S111 - Public daily devotional (no login) for the school apps SOAR and EPIC.
-- DECISIONS (Pastor, Oct 29 2026): same devotional for everyone; credited to
-- Rosehill Christian Church. Read-only: only Rosehill's PUBLISHED-TO-DATE
-- entries (entry_date <= today, Manila) and only the last 60 days. Future
-- entries the Pastor has prepared in advance are NEVER exposed. No member data.
-- Implemented as two SECURITY DEFINER functions so the devotionals table and
-- its RLS stay exactly as they are (members-only).
-- RUN FLAT (no BEGIN/COMMIT) - Inv #209. Idempotent; rerun-until-true.

-- 1) One day's devotional (default: today in Manila)
CREATE OR REPLACE FUNCTION public.public_devotional(p_date date DEFAULT NULL)
RETURNS TABLE (entry_date date, title text, scripture_ref text, scripture_text text,
               story text, explanation text, response text, prayer text,
               reflection_questions text[], weekly_summary text, author text, source_note text)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $fn$
  WITH t AS (SELECT (now() AT TIME ZONE 'Asia/Manila')::date AS today)
  SELECT d.entry_date, d.title, d.scripture_ref, d.scripture_text, d.story, d.explanation,
         d.response, d.prayer, d.reflection_questions, d.weekly_summary, d.author, d.source_note
    FROM public.devotionals d, t
   WHERE d.church_id = (SELECT id FROM public.churches WHERE slug = 'rosehill')
     AND d.entry_date = COALESCE(p_date, t.today)
     AND d.entry_date <= t.today
     AND d.entry_date >= t.today - 60
   LIMIT 1;
$fn$;

-- 2) Which recent days have a devotional (for previous / next navigation)
CREATE OR REPLACE FUNCTION public.public_devotional_dates(p_days int DEFAULT 60)
RETURNS TABLE (entry_date date, title text)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $fn$
  WITH t AS (SELECT (now() AT TIME ZONE 'Asia/Manila')::date AS today)
  SELECT d.entry_date, d.title
    FROM public.devotionals d, t
   WHERE d.church_id = (SELECT id FROM public.churches WHERE slug = 'rosehill')
     AND d.entry_date <= t.today
     AND d.entry_date >= t.today - LEAST(GREATEST(COALESCE(p_days, 60), 1), 60)
   ORDER BY d.entry_date DESC;
$fn$;

-- 3) Explicit grants (Supabase Oct 30 change: always state access explicitly)
REVOKE ALL ON FUNCTION public.public_devotional(date)       FROM PUBLIC;
REVOKE ALL ON FUNCTION public.public_devotional_dates(int)  FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.public_devotional(date)      TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.public_devotional_dates(int) TO anon, authenticated, service_role;

-- 4) Ledger stamp (023 contract)
INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('125', '125_public_devotional.sql',
        'S111 public devotional for SOAR/EPIC: public_devotional(date) + public_devotional_dates(int), Rosehill only, <= today, last 60 days, anon-executable')
ON CONFLICT (version) DO UPDATE
  SET filename = EXCLUDED.filename, note = EXCLUDED.note, applied_at = now();

-- 5) Self-verify - rerun the whole file until every row reads PASS.
SELECT 'functions exist' AS checkpoint,
       CASE WHEN to_regprocedure('public.public_devotional(date)') IS NOT NULL
             AND to_regprocedure('public.public_devotional_dates(integer)') IS NOT NULL
            THEN 'PASS' ELSE 'FAIL' END AS status
UNION ALL
SELECT 'anon may call them',
       CASE WHEN has_function_privilege('anon','public.public_devotional(date)','EXECUTE')
             AND has_function_privilege('anon','public.public_devotional_dates(integer)','EXECUTE')
            THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'devotionals table still closed to anon',
       CASE WHEN NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='devotionals'
                              AND 'anon' = ANY(roles))
            THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'never returns a future day',
       CASE WHEN NOT EXISTS (SELECT 1 FROM public.public_devotional_dates(60)
                              WHERE entry_date > (now() AT TIME ZONE 'Asia/Manila')::date)
             AND NOT EXISTS (SELECT 1 FROM public.public_devotional(((now() AT TIME ZONE 'Asia/Manila')::date + 1)))
            THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'ledger 125',
       CASE WHEN EXISTS (SELECT 1 FROM public.schema_migrations WHERE version='125') THEN 'PASS' ELSE 'FAIL' END;

-- INFO (not a gate): how many recent days the school apps can show right now
SELECT count(*) AS days_available_last_60 FROM public.public_devotional_dates(60);
