-- ============================================================================
-- 116_devotionals_ref_split_guard.sql
-- Session 89: devotionals.scripture_ref boundary guard
--
-- DEFECT (Sept 2026): guide docs merge "Romans 1:1-17 (NIV)" and the passage
-- into one paragraph; ingestion stored the whole paragraph in scripture_ref.
-- Browse cards and every ref line render scripture_ref as a summary (some
-- uppercased), so the entire chapter exploded onto summary surfaces. Cured
-- once by hand for September/Rosehill; Agape surfaced the same bloat because
-- devotionals are PER-CHURCH rows (025) seeded at different times.
--
-- ROOT FIX: a BEFORE INSERT OR UPDATE trigger splits any bloated ref at the
-- translation marker "(NIV)"-style boundary: reference stays in
-- scripture_ref, passage body backfills scripture_text ONLY when empty.
-- Every future seed -- any church, any month, any author (MD admin, SQL
-- paste, CC) -- is normalized at the database boundary. The one-time sweep
-- below routes existing bloated rows through the SAME trigger (touch-update),
-- so the split logic exists in exactly one place.
--
-- Idempotent: CREATE OR REPLACE + DROP TRIGGER IF EXISTS + sweep matches
-- nothing once clean. Flat. Self-verifying via probe row: the trailing
-- SELECT inserts nothing new -- the probe is inserted, proven split by the
-- trigger, and deleted inside the verification itself.
-- ============================================================================

-- 1) The split function (single source of truth)
CREATE OR REPLACE FUNCTION public.devotionals_split_ref()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
  v_body text;
BEGIN
  IF NEW.scripture_ref IS NOT NULL
     AND length(NEW.scripture_ref) > 60
     AND NEW.scripture_ref ~ '\([A-Z]{2,5}\)' THEN
    v_body := btrim(regexp_replace(NEW.scripture_ref, '^.*?\([A-Z]{2,5}\)\s*', ''));
    NEW.scripture_ref := btrim(substring(NEW.scripture_ref from '^(.*?\([A-Z]{2,5}\))'));
    IF coalesce(btrim(NEW.scripture_text), '') = '' AND v_body <> '' THEN
      NEW.scripture_text := v_body;
    END IF;
  END IF;
  RETURN NEW;
END;
$fn$;

-- 2) Attach: fires on INSERT and UPDATE
DROP TRIGGER IF EXISTS trg_devotionals_split_ref ON public.devotionals;
CREATE TRIGGER trg_devotionals_split_ref
BEFORE INSERT OR UPDATE ON public.devotionals
FOR EACH ROW EXECUTE FUNCTION public.devotionals_split_ref();

-- 3) One-time sweep: touch every currently-bloated row (any church, any
--    month) so the trigger itself performs the split -- one code path.
UPDATE public.devotionals
SET updated_at = now()
WHERE scripture_ref IS NOT NULL
  AND length(scripture_ref) > 60
  AND scripture_ref ~ '\([A-Z]{2,5}\)';

-- 4) Ledger self-stamp
INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('116', '116_devotionals_ref_split_guard.sql',
        'S89: devotionals scripture_ref boundary guard -- BEFORE INSERT/UPDATE trigger splits ref from passage at (NIV)-style marker, backfills empty scripture_text; church-blind touch-sweep cures existing bloat through the same trigger')
ON CONFLICT (version) DO NOTHING;

-- 5) Self-verify -- must show all_ok = PASS.
--    The probe row proves the trigger by firing it: inserted bloated,
--    must come back split; deleted inside this same statement chain.
INSERT INTO public.devotionals (entry_date, title, scripture_ref)
VALUES (DATE '1900-01-01', '__m116_probe__',
        'Probe 1:1-2 (NIV)  1 This probe body is deliberately longer than sixty characters so the guard must fire.');

WITH probe AS (
  DELETE FROM public.devotionals
  WHERE title = '__m116_probe__'
  RETURNING scripture_ref, scripture_text
)
SELECT
  CASE WHEN
       (SELECT count(*) FROM probe
         WHERE scripture_ref = 'Probe 1:1-2 (NIV)'
           AND scripture_text LIKE '1 This probe body%') = 1
   AND (SELECT count(*) FROM pg_trigger
         WHERE tgname = 'trg_devotionals_split_ref'
           AND tgrelid = 'public.devotionals'::regclass
           AND tgenabled <> 'D') = 1
   AND (SELECT count(*) FROM public.devotionals
         WHERE length(coalesce(scripture_ref,'')) > 60
           AND scripture_ref ~ '\([A-Z]{2,5}\)') = 0
  THEN 'PASS' ELSE 'FAIL' END                                    AS all_ok,
  (SELECT scripture_ref  FROM probe)                             AS probe_ref_after_trigger,
  (SELECT count(*) FROM public.devotionals
    WHERE length(coalesce(scripture_ref,'')) > 60)               AS long_refs_left_anywhere;
