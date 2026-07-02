-- 055_lock_exposed_backups.sql
-- Supabase Security Advisor: a public table had RLS disabled. Lock the leftover
-- backup tables so they're unreachable via the API (still readable in SQL editor).

ALTER TABLE public._backup_devo_attendance_cleanup_20260620 ENABLE ROW LEVEL SECURITY;
ALTER TABLE public._backup_members_diag_zone_2026_05_06     ENABLE ROW LEVEL SECURITY;

INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('055_lock_exposed_backups','055_lock_exposed_backups.sql',
  'Security: enable RLS (no policies) on leftover backup tables flagged by Supabase advisor.')
ON CONFLICT (version) DO NOTHING;

-- verify: both should read rowsecurity = t
SELECT relname, relrowsecurity
FROM pg_class
WHERE relname IN ('_backup_devo_attendance_cleanup_20260620','_backup_members_diag_zone_2026_05_06')
ORDER BY relname;
