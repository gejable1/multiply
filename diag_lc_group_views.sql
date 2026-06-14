-- ============================================================================
-- READ-ONLY DIAGNOSTIC — lc_group decommission (Inv #166), Session 35.
-- Purpose: expose the GROUP BY keys of the 3 attendance/absence views and find
--          every DB object that consumes them or svi_snapshots.lc_group.
-- SAFE: writes nothing. Run each block in the Supabase SQL editor (it shows only
--       the LAST result grid — run/highlight each query individually) and paste
--       the results back. CC will then say which views are buggy-AND-consumed
--       (need a discipler_id rewrite) vs dormant (defer).
-- ============================================================================


-- 1) Do the 3 views exist, and what are their full definitions (GROUP BY keys)?
SELECT c.relname                       AS view_name,
       CASE c.relkind WHEN 'v' THEN 'view' WHEN 'm' THEN 'matview' END AS kind,
       pg_get_viewdef(c.oid, true)     AS definition
FROM   pg_class c
JOIN   pg_namespace n ON n.oid = c.relnamespace
WHERE  n.nspname = 'public'
  AND  c.relkind IN ('v','m')
  AND  c.relname IN ('v_member_attendance_rates','v_attendance_summary','v_consecutive_absences')
ORDER  BY c.relname;


-- 2) Quick flags — does each definition touch the lc_group family / GROUP BY it?
SELECT c.relname AS view_name,
       (pg_get_viewdef(c.oid,true) ILIKE '%lc_group%')          AS mentions_lc_group,
       (pg_get_viewdef(c.oid,true) ILIKE '%member_lc_group%')   AS mentions_member_lc_group,
       (pg_get_viewdef(c.oid,true) ILIKE '%event_lc_group%')    AS mentions_event_lc_group,
       (pg_get_viewdef(c.oid,true) ILIKE '%group by%lc_group%') AS group_by_lc_group_guess,
       (pg_get_viewdef(c.oid,true) ILIKE '%discipler_id%')      AS already_uses_discipler_id
FROM   pg_class c
JOIN   pg_namespace n ON n.oid = c.relnamespace
WHERE  n.nspname='public' AND c.relkind IN ('v','m')
  AND  c.relname IN ('v_member_attendance_rates','v_attendance_summary','v_consecutive_absences');


-- 3) What DB objects depend ON these 3 views (other views/matviews/rules consuming them)?
--    Empty result = nothing in the DB consumes them (combined with the repo grep
--    finding ZERO frontend/Edge consumers → dormant).
SELECT DISTINCT dependent.relname AS dependent_object,
       CASE dependent.relkind WHEN 'v' THEN 'view' WHEN 'm' THEN 'matview'
            WHEN 'r' THEN 'table' ELSE dependent.relkind::text END AS dependent_kind,
       src.relname               AS references_view
FROM   pg_depend  d
JOIN   pg_rewrite rw       ON rw.oid = d.objid
JOIN   pg_class   dependent ON dependent.oid = rw.ev_class
JOIN   pg_class   src       ON src.oid = d.refobjid
JOIN   pg_namespace n       ON n.oid = src.relnamespace
WHERE  n.nspname='public'
  AND  src.relname IN ('v_member_attendance_rates','v_attendance_summary','v_consecutive_absences')
  AND  dependent.relname <> src.relname
ORDER  BY references_view, dependent_object;


-- 4) Functions whose body references the 3 views OR svi_snapshots + lc_group.
--    (Restricted to SQL/plpgsql so pg_get_functiondef never errors.)
SELECT n.nspname AS schema, p.proname AS function_name
FROM   pg_proc p
JOIN   pg_namespace n ON n.oid = p.pronamespace
JOIN   pg_language  l ON l.oid = p.prolang
WHERE  n.nspname='public' AND p.prokind='f' AND l.lanname IN ('sql','plpgsql')
  AND (pg_get_functiondef(p.oid) ILIKE '%v_member_attendance_rates%'
    OR pg_get_functiondef(p.oid) ILIKE '%v_attendance_summary%'
    OR pg_get_functiondef(p.oid) ILIKE '%v_consecutive_absences%'
    OR (pg_get_functiondef(p.oid) ILIKE '%svi_snapshots%' AND pg_get_functiondef(p.oid) ILIKE '%lc_group%'))
ORDER  BY p.proname;


-- 5) Views with a COLUMN-LEVEL dependency on svi_snapshots.lc_group (i.e. they
--    actually read that column). Empty = nothing groups/reads SVI by lc_group.
SELECT DISTINCT v.relname AS view_name
FROM   pg_depend   d
JOIN   pg_rewrite  rw ON rw.oid = d.objid
JOIN   pg_class    v  ON v.oid  = rw.ev_class
JOIN   pg_class    t  ON t.oid  = d.refobjid
JOIN   pg_attribute a ON a.attrelid = d.refobjid AND a.attnum = d.refobjsubid
JOIN   pg_namespace n ON n.oid = t.relnamespace
WHERE  n.nspname='public' AND t.relname='svi_snapshots' AND a.attname='lc_group'
  AND  v.relname <> 'svi_snapshots'
ORDER  BY view_name;
