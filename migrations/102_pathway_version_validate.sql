-- 102_pathway_version_validate.sql
-- Session 84. Pathway fork model, Phase 4a. READ-ONLY: creates three functions, writes
-- no rows, changes no existing object.
--
-- WHY THIS COMES BEFORE THE EDITOR
--
-- auto_complete_pathway_rungs() is SECURITY DEFINER and processes ALL TWELVE CHURCHES
-- in a single pass. Its devotional arm parses the key with
-- split_part(e.auto_source_key,':',3)::int. A rung whose auto_source_key is
-- 'streak:devotional:weekly' therefore raises invalid input syntax for type integer
-- and aborts the whole function -- so ONE church's malformed rung silently stops
-- auto-completion for EVERY church. Nothing validates those keys today.
--
-- pathway_auto_source_options() is the vocabulary, expanded to concrete choices. It
-- exists so the editor can offer a PICKLIST rather than a free-text box, making a
-- malformed key impossible rather than merely detectable, and so validation and the
-- form read the same list instead of two drifting copies (#405).
--
-- pathway_version_validate() is the pre-publish check. It will be called twice: by
-- the editor to show problems, and by publish as a hard gate -- one implementation,
-- so a stale tab cannot publish a document that never passed.
--
-- All three are SECURITY INVOKER: the caller's JWT flows through, so pathway_versions
-- RLS (own church, level >= 5) and pathway_progress RLS decide what is readable. No
-- service role, no manual church_id stamping, fail-closed by construction (#406).
--
-- ---------------------------------------------------------------------------
-- CORRECTION vs the version run in Session 83 -- three changes, one root cause
-- ---------------------------------------------------------------------------
--
-- The S83 run reported 13 bad auto-source keys on production and was WRONG (#416).
-- The vocabulary was enumerated by reading migration 094 for a lesson arm, and the
-- reading stopped at the FIRST one. 094 has TWO: btli_quizzes at :97-117 and
-- usbong_quizzes at :119-138, byte-identical apart from the table prefix, both
-- deriving the key as lower(replace(course_code,' ','')). Every legitimate Usbong
-- rung was therefore reported unknown. A migration to "fix" those 13 rungs was
-- drafted and NOT run, which is the only reason this is a correction and not an
-- incident.
--
-- (1) THE LESSON ARM NOW UNIONS BOTH QUIZ TABLES, and derives the key ONCE over the
--     union rather than once per table -- so a course code that appears in both, or
--     twice with different spacing, yields exactly one option row. Grouping is by the
--     DERIVED code, because the derived code is what the consumer matches on
--     (094:115 and :136, split_part(e.auto_source_key,':',2) = p.cc).
--
--     TWO tables, not three. public.library_quizzes / library_quiz_attempts exist in
--     the schema and are deliberately EXCLUDED: 094 does not reference them once, so
--     the auto-completer cannot honour a library lesson key. Offering one would be the
--     same defect pointed the other way -- a rung that validates green and then never
--     completes, forever, with nothing to show the pastor why.
--
-- (2) THE ACCEPTANCE RULE NOW HAS ONE HOME, pathway_auto_source_ok(text) (#405). It
--     was written twice in the S83 version -- in the validator's auto_source_unknown
--     arm and again in the self-verify -- and the two copies DISAGREED: the validator
--     rejected 'streak:devotional:0', the self-verify accepted it. Checked against the
--     consumer: 0 does not raise, it silently completes for every member with any
--     qualifying devotional day, dated start_date - 1 (094:162-164). Nonsense, not a
--     crash. Blocking it is correct, so the validator's stricter copy is the one that
--     survives. Publish (104) calls the same function, so the rule cannot drift again.
--
-- (3) THE PRODUCTION GATE NOW COUNTS WHAT THE CONSUMER CAN ACTUALLY REACH. The S83
--     self-verify scanned all of pathway_rungs, including the 210 template rows and
--     every retired row. Post-101 the consumer reads v_effective_auto_rungs, which is
--     own-lane AND retired_at IS NULL AND published AND auto. A malformed key outside
--     that view cannot abort anything. live_bad_auto_keys is therefore measured on the
--     view and is the blocking number; all_lane_bad_auto_keys reports the wider set as
--     information only, so a latent template-lane key is visible without failing a gate
--     it does not belong to.
--
-- THE VOCABULARY, lifted from migration 094 rather than invented:
--   assessment:gifts | assessment:salvation | assessment:disc
--   assessment:strengths | assessment:conflict     (exact, five; 094:65-95, the last
--                                                   three from one arm via CASE)
--   lesson:<course>:all       -- btli_quizzes UNION usbong_quizzes, active only
--   streak:devotional:<n>     -- n MUST cast to int and MUST NOT be 0
--
-- Flat (#209), idempotent (CREATE OR REPLACE), self-verifying on its own effects
-- (#403), stamped (#402). Proven on ephemeral PG16 as postgres (#379) against
-- post-101 forked data, INCLUDING deliberate failure of every gate below (#413).

BEGIN;

-- ---------------------------------------------------------------- vocabulary
CREATE OR REPLACE FUNCTION public.pathway_auto_source_options()
RETURNS TABLE(key text, label_en text, kind text)
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public
AS $fn$
  SELECT v.key, v.label_en, v.kind
    FROM (VALUES
      ('assessment:gifts',     'Spiritual Gifts assessment completed', 'assessment'),
      ('assessment:salvation', 'Salvation diagnostic completed',       'assessment'),
      ('assessment:disc',      'DISC assessment completed',            'assessment'),
      ('assessment:strengths', 'Strengths assessment completed',       'assessment'),
      ('assessment:conflict',  'Conflict style assessment completed',  'assessment')
    ) v(key, label_en, kind)
  UNION ALL
  -- BOTH lesson tables, mirroring the TWO arms in 094 (:97-117, :119-138).
  -- library_quizzes is excluded deliberately -- see header note (1).
  SELECT 'lesson:' || q.cc || ':all',
         'All active lessons passed: ' || min(q.course_code),
         'lesson'
    FROM (
      SELECT lower(replace(course_code, ' ', '')) AS cc, course_code
        FROM public.btli_quizzes   WHERE is_active IS TRUE
      UNION ALL
      SELECT lower(replace(course_code, ' ', '')) AS cc, course_code
        FROM public.usbong_quizzes WHERE is_active IS TRUE
    ) q
   GROUP BY q.cc
  UNION ALL
  SELECT 'streak:devotional:' || s.n,
         'Devotional streak reached ' || s.n || ' days',
         'streak'
    FROM (VALUES (7),(14),(21),(30),(40),(60),(90),(100),(365)) s(n);
$fn$;

COMMENT ON FUNCTION public.pathway_auto_source_options() IS
  'The auto-complete vocabulary, expanded to concrete choices. Feeds the editor picklist AND pathway_auto_source_ok, so the rule has one home. Must stay in step with auto_complete_pathway_rungs() (migration 094), which is where these strings are actually consumed -- INCLUDING BOTH of its lesson arms, btli_quizzes and usbong_quizzes. Reading only the first arm is what produced the 13 false positives in Session 83 (#416).';

-- ------------------------------------------------------------ acceptance rule
-- One home for "is this auto_source_key one the consumer can actually honour?"
-- Called by the validator, by the self-verify below, and by publish in 104.
-- STABLE, not IMMUTABLE: it reads tables.
CREATE OR REPLACE FUNCTION public.pathway_auto_source_ok(p_key text)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public
AS $fn$
  SELECT COALESCE(p_key,'') <> ''
     AND (
          EXISTS (SELECT 1 FROM public.pathway_auto_source_options() o WHERE o.key = p_key)
          OR (p_key LIKE 'streak:devotional:%'
              AND split_part(p_key, ':', 3) ~ '^[0-9]+$'
              AND split_part(p_key, ':', 3) <> '0')
         );
$fn$;

COMMENT ON FUNCTION public.pathway_auto_source_ok(text) IS
  'Single home for the auto-complete acceptance rule. TRUE when auto_complete_pathway_rungs() (migration 094) can actually honour this key. Broader than the picklist on purpose: any positive integer devotional streak is honoured by 094:164, not only the nine offered. Called by pathway_version_validate, by 102 self-verify, and by publish in 104 -- one rule, three callers, no drift (#405).';

-- ---------------------------------------------------------------- validator
CREATE OR REPLACE FUNCTION public.pathway_version_validate(p_version_id uuid)
RETURNS TABLE(severity text, code text, lvl int, rung_key text, message text)
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public
AS $fn$
WITH v AS (
  SELECT pv.id, pv.church_id, pv.doc FROM public.pathway_versions pv WHERE pv.id = p_version_id
),
lv AS (
  SELECT v.church_id, (k.key)::int AS lvl, k.value AS rungs
    FROM v, LATERAL jsonb_each(COALESCE(v.doc->'levels', '{}'::jsonb)) k(key, value)
),
r AS (
  SELECT lv.church_id, lv.lvl,
         (e.ord - 1)              AS pos,
         e.item->>'rung_key'      AS rung_key,
         e.item->>'title_en'      AS title_en,
         e.item->>'category'      AS category,
         COALESCE(e.item->>'completion_source','manual') AS completion_source,
         e.item->>'auto_source_key' AS auto_source_key,
         COALESCE((e.item->>'trackable')::boolean, true) AS trackable
    FROM lv, LATERAL jsonb_array_elements(lv.rungs) WITH ORDINALITY e(item, ord)
)
-- ============================ BLOCKING ============================
SELECT 'block', 'no_doc', NULL::int, NULL::text,
       'This version has no document to publish.'
  FROM v WHERE COALESCE(jsonb_typeof(v.doc->'levels'),'') <> 'object'
UNION ALL
SELECT 'block', 'level_no_trackable', r.lvl, NULL,
       'Level ' || r.lvl || ' has no trackable item, so nobody can make progress in it.'
  FROM r GROUP BY r.lvl HAVING count(*) FILTER (WHERE r.trackable) = 0
UNION ALL
SELECT 'block', 'duplicate_rung_key', r.lvl, r.rung_key,
       'Level ' || r.lvl || ' uses the key "' || r.rung_key || '" ' || count(*) || ' times. Keys must be unique within a level.'
  FROM r GROUP BY r.lvl, r.rung_key HAVING count(*) > 1
UNION ALL
SELECT 'block', 'missing_rung_key', r.lvl, NULL,
       'Level ' || r.lvl || ' has an item at position ' || (r.pos + 1) || ' with no key.'
  FROM r WHERE COALESCE(r.rung_key,'') = ''
UNION ALL
SELECT 'block', 'missing_title', r.lvl, r.rung_key,
       'Item "' || r.rung_key || '" at level ' || r.lvl || ' has no English title.'
  FROM r WHERE COALESCE(r.title_en,'') = ''
UNION ALL
SELECT 'block', 'bad_category', r.lvl, r.rung_key,
       'Item "' || r.rung_key || '" has category "' || COALESCE(r.category,'(none)') || '", which is not one of the allowed categories.'
  FROM r WHERE COALESCE(r.category,'') NOT IN
       ('book','training','lesson','ministry','coaching','assessment','character','competency','discipline','formation')
UNION ALL
SELECT 'block', 'bad_completion_source', r.lvl, r.rung_key,
       'Item "' || r.rung_key || '" has completion source "' || r.completion_source || '"; it must be manual or auto.'
  FROM r WHERE r.completion_source NOT IN ('manual','auto')
UNION ALL
SELECT 'block', 'bad_level', r.lvl, NULL,
       'Level ' || r.lvl || ' is outside the range 0 to 5.'
  FROM r WHERE r.lvl < 0 OR r.lvl > 5 GROUP BY r.lvl
UNION ALL
SELECT 'block', 'auto_without_key', r.lvl, r.rung_key,
       'Item "' || r.rung_key || '" auto-completes but has no source, so it can never complete.'
  FROM r WHERE r.completion_source = 'auto' AND COALESCE(r.auto_source_key,'') = ''
UNION ALL
-- The one that protects every other church: an unrecognised key reaches
-- auto_complete_pathway_rungs(), and a non-numeric devotional tail aborts the whole
-- cross-tenant pass with a cast error. The rule itself lives in
-- pathway_auto_source_ok() so this arm, the self-verify and publish cannot drift.
SELECT 'block', 'auto_source_unknown', r.lvl, r.rung_key,
       'Item "' || r.rung_key || '" uses the auto source "' || r.auto_source_key
       || '", which nothing recognises. Choose one from the list -- an unrecognised source can stop auto-completion for every church.'
  FROM r
 WHERE r.completion_source = 'auto'
   AND COALESCE(r.auto_source_key,'') <> ''
   AND NOT public.pathway_auto_source_ok(r.auto_source_key)
-- ============================ WARNINGS ============================
UNION ALL
SELECT 'warn', 'retire_with_history', pr.level, pr.rung_key,
       CASE WHEN c.n = 1 THEN '1 member has completed "' || COALESCE(pr.title_en, pr.rung_key)
            ELSE c.n || ' members have completed "' || COALESCE(pr.title_en, pr.rung_key) END
       || '". Publishing keeps their record and removes it from the pathway.'
  FROM v
  JOIN public.pathway_rungs pr
    ON pr.church_id = v.church_id AND pr.retired_at IS NULL AND pr.published IS NOT FALSE
   AND COALESCE(pr.meta->>'track','') <> 'giving'
  JOIN LATERAL (SELECT count(*) AS n FROM public.pathway_progress pp
                 WHERE pp.church_id = v.church_id AND pp.level = pr.level
                   AND pp.rung_key = pr.rung_key) c ON c.n > 0
 WHERE NOT EXISTS (SELECT 1 FROM r WHERE r.lvl = pr.level AND r.rung_key = pr.rung_key)
UNION ALL
SELECT 'warn', 'empty_level', g.lvl, NULL,
       'Level ' || g.lvl || ' has nothing in it.'
  FROM (SELECT lv.lvl, jsonb_array_length(lv.rungs) AS n FROM lv) g
 WHERE g.n = 0;
$fn$;

COMMENT ON FUNCTION public.pathway_version_validate(uuid) IS
  'Pre-publish sanity check over a pathway_versions document. Called by the editor for display AND by publish as a hard gate, so a stale tab cannot publish a document that never passed. Blocking rows must be cleared; warn rows are informational (notably retire_with_history, which carries the completion count the design asks for).';

GRANT EXECUTE ON FUNCTION public.pathway_auto_source_ok(text)      TO authenticated;
GRANT EXECUTE ON FUNCTION public.pathway_auto_source_options()     TO authenticated;
GRANT EXECUTE ON FUNCTION public.pathway_version_validate(uuid)    TO authenticated;

INSERT INTO public.schema_migrations (version, filename, note) VALUES
  ('102','102_pathway_version_validate.sql','Phase 4a: pathway_auto_source_ok() (single home for the acceptance rule), pathway_auto_source_options() (the auto-complete vocabulary, expanded to concrete choices, feeding the editor picklist AND the validator) and pathway_version_validate() (pre-publish check; blocks on unknown auto sources, which matters because auto_complete_pathway_rungs is SECURITY DEFINER across all 12 churches and casts the devotional tail to int, so one malformed key aborts the whole cross-tenant pass). Corrects the S83 run: the lesson vocabulary missed 094 second lesson arm over usbong_quizzes and reported 13 legitimate Usbong rungs as unknown (#416). Read-only, no rows written.')
ON CONFLICT (version) DO UPDATE SET filename=excluded.filename, note=excluded.note, applied_at=now();

COMMIT;

-- SELF-VERIFY -- expect all_ok = PASS and live_bad_auto_keys = 0.
--
-- lesson_options vs lesson_courses_live is the regression check for #416 itself: the
-- right-hand side is written out INDEPENDENTLY here rather than reusing the function
-- under test, because a check that calls the thing it is checking proves nothing
-- (#415). Drop either lesson arm from the vocabulary and these two numbers diverge and
-- all_ok reads FAIL. Under the S83 version they would have read (btli only) vs (both),
-- and the bug would have announced itself on the first run instead of on production.
SELECT
  (SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='public' AND p.proname='pathway_auto_source_ok')               AS fn_ok,
  (SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='public' AND p.proname='pathway_auto_source_options')          AS fn_options,
  (SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='public' AND p.proname='pathway_version_validate')             AS fn_validate,
  (SELECT count(*) FROM public.pathway_auto_source_options())                      AS options_offered,
  (SELECT count(*) FROM public.pathway_auto_source_options() WHERE kind='lesson')  AS lesson_options,
  (SELECT count(DISTINCT lower(replace(course_code,' ','')))
     FROM (SELECT course_code FROM public.btli_quizzes   WHERE is_active IS TRUE
           UNION ALL
           SELECT course_code FROM public.usbong_quizzes WHERE is_active IS TRUE) z)
                                                                                   AS lesson_courses_live,
  -- BLOCKING number: only what auto_complete_pathway_rungs() can actually reach.
  (SELECT count(*) FROM public.v_effective_auto_rungs e
    WHERE NOT public.pathway_auto_source_ok(e.auto_source_key))                    AS live_bad_auto_keys,
  -- INFORMATION only: template lane and retired rows, which cannot abort the pass.
  (SELECT count(*) FROM public.pathway_rungs
    WHERE completion_source='auto' AND COALESCE(auto_source_key,'')<>''
      AND NOT public.pathway_auto_source_ok(auto_source_key))                      AS all_lane_bad_auto_keys,
  (SELECT count(*) FROM public.pathway_rungs
    WHERE completion_source='auto' AND COALESCE(auto_source_key,'')='')            AS live_auto_without_key,
  (SELECT count(*) FROM public.schema_migrations WHERE version='102')              AS self_stamped,
  CASE WHEN
       (SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
         WHERE n.nspname='public' AND p.proname='pathway_auto_source_ok') = 1
   AND (SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
         WHERE n.nspname='public' AND p.proname='pathway_auto_source_options') = 1
   AND (SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
         WHERE n.nspname='public' AND p.proname='pathway_version_validate') = 1
   AND (SELECT count(*) FROM public.pathway_auto_source_options() WHERE kind='assessment') = 5
   AND (SELECT count(*) FROM public.pathway_auto_source_options() WHERE kind='streak') = 9
   AND (SELECT count(*) FROM public.pathway_auto_source_options() WHERE kind='lesson')
     = (SELECT count(DISTINCT lower(replace(course_code,' ','')))
          FROM (SELECT course_code FROM public.btli_quizzes   WHERE is_active IS TRUE
                UNION ALL
                SELECT course_code FROM public.usbong_quizzes WHERE is_active IS TRUE) z)
   AND (SELECT count(*) FROM public.v_effective_auto_rungs e
         WHERE NOT public.pathway_auto_source_ok(e.auto_source_key)) = 0
   AND (SELECT count(*) FROM public.schema_migrations WHERE version='102') = 1
       THEN 'PASS' ELSE 'FAIL' END                                                 AS all_ok;
