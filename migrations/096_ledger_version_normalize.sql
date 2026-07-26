-- 096_ledger_version_normalize.sql
-- Session 82. Ledger repair 2 of 2 (follows 095).
--
-- Five rows stamped in S52-S56 stored the full migration NAME as the version
-- ('052_devotionals_composite_unique') instead of the number ('052').
-- They evaded every earlier check because lpad(version,3,'0') TRUNCATES a
-- longer string on the right, so the diagnostic rendered them as clean
-- three-digit values. The normalizer was hiding the drift it was written
-- to find. filename is left untouched and already carries the full name.
--
-- No schema change. Flat, idempotent, self-verifying. Proven on PG16.
-- Verify block asserts only THIS migration's effects, never a global total.

UPDATE public.schema_migrations m
   SET version = substring(m.version from '^[0-9]{3}')
 WHERE m.version ~ '^[0-9]{3}_'
   AND NOT EXISTS (
     SELECT 1 FROM public.schema_migrations x
      WHERE x.version = substring(m.version from '^[0-9]{3}')
   );

-- STAMP THIS MIGRATION
INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('096','096_ledger_version_normalize.sql','Ledger repair 2/2: five rows (052-056) stored the full migration name as version; normalized to the 3-digit number. No schema change.')
ON CONFLICT (version) DO UPDATE SET filename=excluded.filename, note=excluded.note, applied_at=now();

-- SELF-VERIFY -- expect all_ok = PASS. Asserts only this migration's effects.
SELECT
  (SELECT count(*) FROM public.schema_migrations WHERE version !~ '^[0-9]{3}$') AS nonstandard_left,
  (SELECT count(*) FROM public.schema_migrations WHERE version IN ('052','053','054','055','056')) AS normalized,
  (SELECT count(*) FROM public.schema_migrations WHERE version = '096') AS self_stamped,
  CASE WHEN (SELECT count(*) FROM public.schema_migrations WHERE version !~ '^[0-9]{3}$') = 0
        AND (SELECT count(*) FROM public.schema_migrations WHERE version IN ('052','053','054','055','056')) = 5
        AND (SELECT count(*) FROM public.schema_migrations WHERE version = '096') = 1
       THEN 'PASS' ELSE 'FAIL' END AS all_ok;
