-- migrations/122_ai_usage_log.sql
-- S106 - MULTIPLY AI pilot (Meeting Prep on the Claude API). One row per AI call,
-- written ONLY by the meeting-prep-ai Edge Function (service role). Used for the
-- per-leader daily cap, the per-church monthly cap, and the Pastor's cost view.
-- No prompt or reply text is stored - only who, when, which model, and token counts.
-- RLS: pastors (L5) of the same church may READ; nobody writes from the browser.
-- RUN FLAT (no BEGIN/COMMIT). Idempotent; rerun-until-true.

CREATE TABLE IF NOT EXISTS public.ai_usage_log (
  id            bigserial    PRIMARY KEY,
  church_id     uuid         REFERENCES public.churches(id),
  member_id     uuid         REFERENCES public.members(id) ON DELETE SET NULL,
  feature       text         NOT NULL,
  model         text,
  input_tokens  integer,
  output_tokens integer,
  ok            boolean      NOT NULL DEFAULT false,
  error         text,
  created_at    timestamptz  NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_ai_usage_member_day ON public.ai_usage_log (member_id, feature, created_at);
CREATE INDEX IF NOT EXISTS idx_ai_usage_church_month ON public.ai_usage_log (church_id, created_at);

ALTER TABLE public.ai_usage_log ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS ai_usage_log_pastor_select ON public.ai_usage_log;
CREATE POLICY ai_usage_log_pastor_select ON public.ai_usage_log
  FOR SELECT TO authenticated
  USING (church_id = public.auth_church_id() AND public.auth_level() >= 5);
REVOKE INSERT, UPDATE, DELETE ON public.ai_usage_log FROM anon, authenticated;
GRANT SELECT ON public.ai_usage_log TO authenticated;

INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('122', '122_ai_usage_log.sql',
        'S106: ai_usage_log for the Meeting Prep AI pilot (caps + cost view; no prompt/reply text stored; pastor-read only)')
ON CONFLICT (version) DO UPDATE
  SET filename = EXCLUDED.filename, note = EXCLUDED.note, applied_at = now();

SELECT 'table exists' AS checkpoint,
       CASE WHEN to_regclass('public.ai_usage_log') IS NOT NULL THEN 'PASS' ELSE 'FAIL' END AS status
UNION ALL
SELECT 'RLS enabled',
       CASE WHEN (SELECT relrowsecurity FROM pg_class WHERE oid='public.ai_usage_log'::regclass) THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'one policy, SELECT only',
       CASE WHEN (SELECT count(*) FROM pg_policies WHERE schemaname='public' AND tablename='ai_usage_log') = 1
             AND (SELECT cmd FROM pg_policies WHERE schemaname='public' AND tablename='ai_usage_log') = 'SELECT'
            THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'browser cannot write',
       CASE WHEN NOT has_table_privilege('authenticated','public.ai_usage_log','INSERT')
             AND NOT has_table_privilege('anon','public.ai_usage_log','INSERT') THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'ledger 122',
       CASE WHEN EXISTS (SELECT 1 FROM public.schema_migrations WHERE version='122') THEN 'PASS' ELSE 'FAIL' END;
