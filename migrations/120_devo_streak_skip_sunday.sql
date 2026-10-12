-- migrations/120_devo_streak_skip_sunday.sql
-- S99/120 - The pathway engine's devotional-streak arm (devo-7 / devo-30 rungs,
-- auto_source 'streak:devotional:N') counted CALENDAR days. The church guide
-- publishes no devotional on Sundays, so no one could ever chain 7 days and the
-- rungs were unreachable. Rule now (Pastor, Oct 12 2026): a Sunday neither
-- counts nor breaks a streak; holidays / gap days still break it. Same rule as
-- member_tool.html (S99).
-- METHOD: surgical. Reads the LIVE engine with pg_get_functiondef, replaces ONLY
-- the streak arm (exact-once anchor, else it STOPS), re-creates it. The other six
-- arms stay byte-for-byte as deployed. Then runs the engine once so members who
-- already earned devo-7 / devo-30 get the rung with the REAL milestone date.
-- RUN FLAT (no BEGIN/COMMIT) - Inv #209. Idempotent; rerun-until-true.

-- 1) Swap the streak arm in the live engine
DO $do$
DECLARE
  def  text;
  oldA text := $arm1$        AND member_id IS NOT NULL AND church_id IS NOT NULL
    ),
    grp AS (
      SELECT member_id, church_id, entry_date,
             entry_date - (row_number() OVER (PARTITION BY member_id ORDER BY entry_date))::int AS g
      FROM qual
    ),
    runs AS (
      SELECT member_id, church_id, min(entry_date) AS start_date, count(*) AS len
      FROM grp GROUP BY member_id, church_id, g
    )
    SELECT member_id, church_id,
           min(start_date + (split_part(e.auto_source_key,':',3)::int - 1)) AS milestone
    FROM runs
    WHERE len >= split_part(e.auto_source_key,':',3)::int
      AND church_id = e.church_id
    GROUP BY member_id, church_id
$arm1$;
  newA text := $arm2$        AND member_id IS NOT NULL AND church_id IS NOT NULL
        AND extract(dow FROM entry_date) <> 0   -- S99/120: Sundays are devotional-free: never counted
    ),
    grp AS (
      -- S99/120: devotional-day index (days since Sun 2000-01-02 minus the Sundays in
      -- between), so Saturday -> Monday are CONSECUTIVE and a Sunday never breaks a run.
      SELECT member_id, church_id, entry_date,
             ((entry_date - DATE '2000-01-02') - ((entry_date - DATE '2000-01-02') / 7))
             - (row_number() OVER (PARTITION BY member_id ORDER BY entry_date))::int AS g
      FROM qual
    ),
    runs AS (
      SELECT member_id, church_id, g, count(*) AS len
      FROM grp GROUP BY member_id, church_id, g
    ),
    nth AS (
      SELECT r.member_id, r.church_id, r.len, x.entry_date,
             row_number() OVER (PARTITION BY r.member_id, r.church_id, r.g ORDER BY x.entry_date) AS k
      FROM runs r JOIN grp x ON x.member_id = r.member_id AND x.church_id = r.church_id AND x.g = r.g
    )
    -- milestone = the date of the Nth devotional day in the earliest qualifying run
    SELECT member_id, church_id, min(entry_date) AS milestone
    FROM nth
    WHERE len >= split_part(e.auto_source_key,':',3)::int
      AND k = split_part(e.auto_source_key,':',3)::int
      AND church_id = e.church_id
    GROUP BY member_id, church_id
$arm2$;
  n    int;
BEGIN
  def := pg_get_functiondef('public.auto_complete_pathway_rungs()'::regprocedure);
  IF position('S99/120: Sundays are devotional-free' IN def) > 0 THEN
    RAISE NOTICE '120: streak arm already patched - nothing to do';
    RETURN;
  END IF;
  n := (length(def) - length(replace(def, oldA, ''))) / length(oldA);
  IF n <> 1 THEN
    RAISE EXCEPTION '120 STOPPED: expected the streak arm exactly once in the live engine, found % - nothing changed. Send this message to Claude.', n;
  END IF;
  EXECUTE replace(def, oldA, newA);
  RAISE NOTICE '120: streak arm replaced (Sundays skipped)';
END
$do$;

GRANT EXECUTE ON FUNCTION public.auto_complete_pathway_rungs() TO service_role;

-- 2) Ledger stamp (023 contract)
INSERT INTO public.schema_migrations (version, filename, note)
VALUES ('120', '120_devo_streak_skip_sunday.sql',
        'S99: pathway devo streak arm skips Sundays (neither counts nor breaks); engine re-run backfills devo-7/devo-30 with real milestone dates')
ON CONFLICT (version) DO UPDATE
  SET filename = EXCLUDED.filename, note = EXCLUDED.note, applied_at = now();

-- 3) Backfill: run the engine once, measuring the STREAK arm's own rows.
--    (The engine runs all arms; any other-arm backlog it clears is reported, not hidden.)
CREATE TEMP TABLE IF NOT EXISTS _m120 (k text PRIMARY KEY, v bigint);
DO $bf$
DECLARE s0 bigint; s1 bigint; tot int;
BEGIN
  IF EXISTS (SELECT 1 FROM _m120 WHERE k = 'streak_before') THEN RETURN; END IF;  -- rerun: keep first measurement
  SELECT count(*) INTO s0 FROM public.pathway_progress WHERE note LIKE 'auto:streak:devotional:%';
  tot := public.auto_complete_pathway_rungs();
  SELECT count(*) INTO s1 FROM public.pathway_progress WHERE note LIKE 'auto:streak:devotional:%';
  INSERT INTO _m120 VALUES ('streak_before', s0), ('streak_after', s1), ('engine_total', tot);
END
$bf$;

-- 4) Self-verify - rows 1-4 must read PASS; rows 5-6 are information.
SELECT 'engine has Sunday-skip arm' AS checkpoint,
       CASE WHEN position('S99/120: Sundays are devotional-free' IN pg_get_functiondef('public.auto_complete_pathway_rungs()'::regprocedure)) > 0
            THEN 'PASS' ELSE 'FAIL' END AS status
UNION ALL
SELECT 'old calendar-day arm gone',
       CASE WHEN position('min(start_date + (split_part' IN pg_get_functiondef('public.auto_complete_pathway_rungs()'::regprocedure)) = 0
            THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'Sat -> Mon are consecutive devotional days',
       CASE WHEN ((DATE '2026-10-12' - DATE '2000-01-02') - ((DATE '2026-10-12' - DATE '2000-01-02') / 7))
               - ((DATE '2026-10-10' - DATE '2000-01-02') - ((DATE '2026-10-10' - DATE '2000-01-02') / 7)) = 1
            THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'ledger 120',
       CASE WHEN EXISTS (SELECT 1 FROM public.schema_migrations WHERE version='120') THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 'INFO devo-streak rungs newly earned',
       (SELECT (max(v) FILTER (WHERE k='streak_after') - max(v) FILTER (WHERE k='streak_before'))::text FROM _m120)
UNION ALL
SELECT 'INFO all rungs added by this engine run',
       (SELECT max(v)::text FROM _m120 WHERE k='engine_total');
