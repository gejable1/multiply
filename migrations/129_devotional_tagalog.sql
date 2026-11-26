-- migrations/129_devotional_tagalog.sql
-- S115 - Bilingual devotionals: room for a Tagalog version of each day.
-- Adds nullable *_tl columns to public.devotionals (English stays as-is;
-- a blank Tagalog field means "show the English"). scripture_ref is shared
-- (book names/verse numbers are the same in both languages).
-- Adds public_devotional_tl(date) for the public page (devotional.html).
-- public_devotional() from 125 is NOT changed (SOAR and EPIC use it).
-- RUN FLAT (no BEGIN/COMMIT). Idempotent. No new tables (no GRANTs needed;
-- the existing devotionals RLS policies cover the new columns).

-- 1) Tagalog columns
ALTER TABLE public.devotionals ADD COLUMN IF NOT EXISTS title_tl                text;
ALTER TABLE public.devotionals ADD COLUMN IF NOT EXISTS scripture_text_tl       text;
ALTER TABLE public.devotionals ADD COLUMN IF NOT EXISTS story_tl                text;
ALTER TABLE public.devotionals ADD COLUMN IF NOT EXISTS explanation_tl          text;
ALTER TABLE public.devotionals ADD COLUMN IF NOT EXISTS response_tl             text;
ALTER TABLE public.devotionals ADD COLUMN IF NOT EXISTS prayer_tl               text;
ALTER TABLE public.devotionals ADD COLUMN IF NOT EXISTS reflection_questions_tl text[];
ALTER TABLE public.devotionals ADD COLUMN IF NOT EXISTS weekly_summary_tl       text;
ALTER TABLE public.devotionals ADD COLUMN IF NOT EXISTS tl_status               text;  -- NULL | 'draft' | 'reviewed'

-- 2) Public Tagalog read (same rules as 125: Rosehill, <= today, last 60 days)
CREATE OR REPLACE FUNCTION public.public_devotional_tl(p_date date DEFAULT NULL)
RETURNS TABLE (entry_date date, title_tl text, scripture_text_tl text, story_tl text,
               explanation_tl text, response_tl text, prayer_tl text,
               reflection_questions_tl text[], weekly_summary_tl text)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $fn$
  WITH t AS (SELECT (now() AT TIME ZONE 'Asia/Manila')::date AS today)
  SELECT d.entry_date, d.title_tl, d.scripture_text_tl, d.story_tl, d.explanation_tl,
         d.response_tl, d.prayer_tl, d.reflection_questions_tl, d.weekly_summary_tl
    FROM public.devotionals d, t
   WHERE d.church_id = (SELECT id FROM public.churches WHERE slug = 'rosehill')
     AND d.entry_date = COALESCE(p_date, t.today)
     AND d.entry_date <= t.today
     AND d.entry_date >= t.today - 60
     AND d.tl_status = 'reviewed'
   LIMIT 1;
$fn$;
REVOKE ALL ON FUNCTION public.public_devotional_tl(date) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.public_devotional_tl(date) TO anon, authenticated, service_role;

-- 3) Ledger stamp
INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('129', '129_devotional_tagalog.sql',
        'S115 bilingual devotionals: *_tl columns + tl_status on devotionals; public_devotional_tl(date)')
ON CONFLICT (version) DO UPDATE
  SET filename = EXCLUDED.filename, note = EXCLUDED.note, applied_at = now();

-- 4) Self-verify (every row should read PASS)
SELECT 'tagalog columns (expect 9)' AS checkpoint,
       CASE WHEN (SELECT count(*) FROM information_schema.columns
                   WHERE table_schema='public' AND table_name='devotionals'
                     AND column_name IN ('title_tl','scripture_text_tl','story_tl','explanation_tl',
                                         'response_tl','prayer_tl','reflection_questions_tl',
                                         'weekly_summary_tl','tl_status')) = 9
            THEN 'PASS' ELSE 'FAIL' END AS status
UNION ALL
SELECT 'public_devotional_tl exists',
       CASE WHEN to_regprocedure('public.public_devotional_tl(date)') IS NOT NULL THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'anon may call it',
       CASE WHEN has_function_privilege('anon', 'public.public_devotional_tl(date)', 'EXECUTE') THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'English public function untouched',
       CASE WHEN to_regprocedure('public.public_devotional(date)') IS NOT NULL THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'ledger 129',
       CASE WHEN EXISTS (SELECT 1 FROM public.schema_migrations WHERE version = '129') THEN 'PASS' ELSE 'FAIL' END;
