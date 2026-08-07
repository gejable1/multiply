-- migrations/108_template_ministry_and_output.sql
-- S86 -- the two columns of the original pipeline design that were never built.
--
-- WHY. The MULTIPLY Leadership Pipeline as designed carries five columns:
-- Formation Track, Character, Competence, MINISTRY PLACEMENT and OUTPUT. The
-- database has the first three. Ministry existed as three generic placeholders
-- across all six levels -- "Join a Life Group", "Serve in a ministry team",
-- "Direct a ministry or department" -- and Output did not exist at all. That is
-- why the Ministry column reads empty at L2, L3 and L5: it is empty at EVERY
-- level, and Output was never implemented.
--
-- This adds 46 rows to the SHARED TEMPLATE lane (church_id IS NULL) only.
-- It does not touch a single church lane. That is deliberate: pathway_versions
-- .template_synced_at exists so template rungs with created_at later than a
-- church last sync are offered to that pastor as per-item opt-ins. New rows
-- therefore surface in the editor as things each pastor may accept or ignore,
-- which is the intended path and leaves every published pipeline untouched
-- until its own pastor acts.
--
-- WHAT THE TWO COLUMNS ARE, in the platform owner words, because the names
-- mislead. MINISTRY is the actual ministries a member at that level may JOIN --
-- music, children, youth. It is NOT leadership roles. COMPETENCY is skills to
-- develop, each with training behind it. An earlier plan to retag lead-lc,
-- coach-leaders and plant from competency to ministry was WRONG and withdrawn:
-- those are skills, correctly filed, and moving them would have put leadership
-- roles into a column meant for teams a member joins.
--
--   * Ministry placements are REFERENCE (trackable = false). A member joins one
--     or two, not thirty-one, so they must never be a checklist. Non-trackable
--     rungs render in MLT collapsed "Coaching notes" panel, un-counted.
--   * L0 inherits L1 placements, per the platform owner.
--   * Outputs are TRACKABLE and filed under competency, per the platform owner.
--     Note for later: an output is a STATE that can go backwards ("Leads 3-5
--     members"), unlike a completion. Nothing un-ticks one. If that becomes a
--     problem the fix is an auto_source_key, not a manual tick.
--   * L2 output reads "Leads 3-5 members", amended by the platform owner from
--     the 5-15 on the original design.
--
-- Descriptions ship EMPTY by request -- the platform owner writes them in the
-- editor. title_tl mirrors title_en: these are role names, and inventing
-- Tagalog for them is not this migration job.
--
-- Flat (#209), idempotent, self-verifying on its OWN effects (#403), ledger
-- stamped (#402). Proven on PG16 before shipping.

-- sort_order: append after whatever each level already holds, so nothing that
-- exists moves. Ministry block first, then Output, stable within each by key.
with newrow(level, rung_key, title_en, category, trackable) as (values
    (0, 'ref-ministry-greeter-usher', 'Greeter / Usher', 'ministry', false),
    (0, 'ref-ministry-worship-support', 'Worship Support', 'ministry', false),
    (0, 'ref-ministry-childrens-ministry-volunteer', 'Children''s Ministry Volunteer', 'ministry', false),
    (0, 'ref-ministry-events-crew', 'Events Crew', 'ministry', false),
    (0, 'ref-ministry-media-tech-support', 'Media / Tech Support', 'ministry', false),
    (1, 'ref-ministry-greeter-usher', 'Greeter / Usher', 'ministry', false),
    (1, 'ref-ministry-worship-support', 'Worship Support', 'ministry', false),
    (1, 'ref-ministry-childrens-ministry-volunteer', 'Children''s Ministry Volunteer', 'ministry', false),
    (1, 'ref-ministry-events-crew', 'Events Crew', 'ministry', false),
    (1, 'ref-ministry-media-tech-support', 'Media / Tech Support', 'ministry', false),
    (2, 'ref-ministry-life-community-leader', 'Life Community Leader', 'ministry', false),
    (2, 'ref-ministry-worship-team-leader', 'Worship Team Leader', 'ministry', false),
    (2, 'ref-ministry-devotional-preacher', 'Devotional Preacher', 'ministry', false),
    (2, 'ref-ministry-sunday-school-teacher', 'Sunday School Teacher', 'ministry', false),
    (2, 'ref-ministry-campus-minister', 'Campus Minister', 'ministry', false),
    (2, 'ref-ministry-eolo-campaign-leader', 'EOLO Campaign Leader', 'ministry', false),
    (3, 'ref-ministry-sunday-preacher', 'Sunday Preacher', 'ministry', false),
    (3, 'ref-ministry-seminar-lecturer', 'Seminar Lecturer', 'ministry', false),
    (3, 'ref-ministry-trainer', 'Trainer', 'ministry', false),
    (3, 'ref-ministry-church-council-member', 'Church Council Member', 'ministry', false),
    (3, 'ref-ministry-btli-lecturer', 'BTLI Lecturer', 'ministry', false),
    (3, 'ref-ministry-campus-ministry-coach', 'Campus Ministry Coach', 'ministry', false),
    (4, 'ref-ministry-worship-director', 'Worship Director', 'ministry', false),
    (4, 'ref-ministry-youth-director', 'Youth Director', 'ministry', false),
    (4, 'ref-ministry-childrens-director', 'Children''s Director', 'ministry', false),
    (4, 'ref-ministry-missions-director', 'Missions Director', 'ministry', false),
    (4, 'ref-ministry-btli-faculty', 'BTLI Faculty', 'ministry', false),
    (5, 'ref-ministry-senior-pastor', 'Senior Pastor', 'ministry', false),
    (5, 'ref-ministry-founding-missionary', 'Founding Missionary', 'ministry', false),
    (5, 'ref-ministry-church-planter', 'Church Planter', 'ministry', false),
    (5, 'ref-ministry-denominational-officer', 'Denominational Officer', 'ministry', false),
    (1, 'out-growing-as-a-disciple', 'Growing as a disciple', 'competency', true),
    (1, 'out-attending-consistently', 'Attending consistently', 'competency', true),
    (1, 'out-inviting-eolo', 'Inviting (EOLO)', 'competency', true),
    (2, 'out-leads-3-5-members', 'Leads 3-5 members', 'competency', true),
    (2, 'out-disciples-1-3-people', 'Disciples 1-3 people', 'competency', true),
    (2, 'out-raises-up-team-members', 'Raises up Team Members', 'competency', true),
    (3, 'out-coaches-3-8-leaders', 'Coaches 3-8 leaders', 'competency', true),
    (3, 'out-multiplies-small-groups', 'Multiplies small groups', 'competency', true),
    (3, 'out-trains-other-trainers', 'Trains other trainers', 'competency', true),
    (4, 'out-oversees-multiple-teams', 'Oversees multiple teams', 'competency', true),
    (4, 'out-develops-team-leaders', 'Develops team leaders', 'competency', true),
    (4, 'out-manages-ministry-systems', 'Manages ministry systems', 'competency', true),
    (5, 'out-multiplies-church-planters', 'Multiplies church planters', 'competency', true),
    (5, 'out-shapes-org-culture', 'Shapes org culture', 'competency', true),
    (5, 'out-releases-next-generation', 'Releases next generation', 'competency', true)
),
base as (
  select level, coalesce(max(sort_order), 0) as max_so
  from public.pathway_rungs where church_id is null group by level
),
ranked as (
  select n.*,
         row_number() over (
           partition by n.level
           order by case when n.category = 'ministry' then 0 else 1 end, n.rung_key
         ) as seq
  from newrow n
)
insert into public.pathway_rungs
  (church_id, level, sort_order, rung_key, title_en, title_tl,
   description_en, description_tl, category, completion_source,
   published, trackable, created_at, updated_at)
select null, r.level, coalesce(b.max_so, 0) + r.seq, r.rung_key, r.title_en, r.title_en,
       null, null, r.category, 'manual',
       true, r.trackable, now(), now()
from ranked r
left join base b on b.level = r.level
where not exists (
  select 1 from public.pathway_rungs x
  where x.church_id is null and x.level = r.level and x.rung_key = r.rung_key
);

-- ---- ledger stamp (#402/#212)
insert into public.schema_migrations (version, filename, note) values
  ('108','108_template_ministry_and_output.sql','Template lane only: 31 Ministry Placement reference rungs (trackable=false, L0 inherits L1) and 15 Output rungs (trackable=true, category competency) from the original pipeline design. No church lane touched; new rows surface per-pastor via template_synced_at opt-in.')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

-- ---- SELF-VERIFY -- asserts only THIS migration own effects (#403).
-- Expect: ministry_refs 31, outputs 15, l0_outputs 0, church_rows_touched 0,
-- dup_keys 0, untrackable_outputs 0, trackable_ministry 0, all_ok PASS.
-- church_rows_touched is the one that matters: this migration must be provably
-- confined to the template lane.
select
  (select count(*) from public.pathway_rungs
    where church_id is null and rung_key like 'ref-ministry-%')            as ministry_refs,
  (select count(*) from public.pathway_rungs
    where church_id is null and rung_key like 'out-%')                     as outputs,
  (select count(*) from public.pathway_rungs
    where church_id is null and level = 0 and rung_key like 'out-%')       as l0_outputs,
  (select count(*) from public.pathway_rungs
    where church_id is not null
      and (rung_key like 'ref-ministry-%' or rung_key like 'out-%'))       as church_rows_touched,
  (select count(*) from (
     select level, rung_key from public.pathway_rungs where church_id is null
     group by level, rung_key having count(*) > 1) d)                      as dup_keys,
  (select count(*) from public.pathway_rungs
    where church_id is null and rung_key like 'out-%' and not trackable)   as untrackable_outputs,
  (select count(*) from public.pathway_rungs
    where church_id is null and rung_key like 'ref-ministry-%' and trackable) as trackable_ministry,
  case when
       (select count(*) from public.pathway_rungs where church_id is null and rung_key like 'ref-ministry-%') = 31
   and (select count(*) from public.pathway_rungs where church_id is null and rung_key like 'out-%') = 15
   and (select count(*) from public.pathway_rungs where church_id is null and level = 0 and rung_key like 'out-%') = 0
   and (select count(*) from public.pathway_rungs where church_id is not null and (rung_key like 'ref-ministry-%' or rung_key like 'out-%')) = 0
   and (select count(*) from (select level, rung_key from public.pathway_rungs where church_id is null group by level, rung_key having count(*) > 1) d) = 0
   and (select count(*) from public.pathway_rungs where church_id is null and rung_key like 'out-%' and not trackable) = 0
   and (select count(*) from public.pathway_rungs where church_id is null and rung_key like 'ref-ministry-%' and trackable) = 0
  then 'PASS' else 'FAIL' end                                              as all_ok;

-- ---- what a pastor sees next -----------------------------------------------
-- Nothing changes for any member until a pastor opts in. To review what is now
-- on offer for a given church:
--
--   select t.level, t.rung_key, t.title_en, t.category, t.trackable
--   from public.pathway_rungs t
--   where t.church_id is null
--     and t.created_at > (select max(template_synced_at) from public.pathway_versions
--                          where church_id = (select id from public.churches where name = 'PUT NAME HERE'))
--   order by t.level, t.sort_order;
