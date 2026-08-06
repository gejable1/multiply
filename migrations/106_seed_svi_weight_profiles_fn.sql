-- migrations/106_seed_svi_weight_profiles_fn.sql
-- S86 -- one home for the seven default SVI weight profiles.
--
-- WHY THIS EXISTS. Rosehill got its profiles in `001`. Agape got them in `034`,
-- and only because seeding revealed two tenancy-blind uniques that had to be
-- rebuilt first. Every church onboarded since -- ten of them -- got NOTHING,
-- because whether a new tenant received profiles depended on whether the person
-- writing its onboarding migration happened to remember. A live scan on
-- 2026-08-06 found all ten dark: `profile_used` null, zone `insufficient`,
-- `metrics_total` 0. The no-profile guard (#282) held, so no church ever carried
-- a wrong score -- but SVI simply never ran for them and nothing said so.
--
-- `034` seeded Agape by COPYING FROM ROSEHILL AT RUNTIME, which means the seven
-- profiles have never existed anywhere except the live database. That is the
-- fragility this closes: the defaults are now literals in a versioned function
-- body, so a later retune of Rosehill's own weights cannot silently change what
-- a new church is born with.
--
-- The values below were dumped from Rosehill's live rows via format() with the
-- %L literal specifier and carried across verbatim, with two corrections:
--   * `is_active` arrived as `t` -- the %s specifier uses the type's OUTPUT
--     FUNCTION, not a ::text cast, so booleans emit t/f. A bare `t` in a VALUES
--     list parses as a column reference. Corrected to `true`.
--   * `level_5`'s note named the platform author. Genericized to the same
--     wording `034` already used for Agape (#29 -- no personal or church names
--     in shared content).
-- The eight em-dashes in the display names are pastor-facing and must match what
-- Rosehill and Agape already render, so they ship as E'' \u2014 escapes: the file
-- stays pure ASCII, the stored value is byte-identical.
--
-- SEEDS NOBODY. Installing the function is the whole migration. Seed a church
-- when its pastor is ready -- see the block at the foot of this file.
--
-- Flat (#209), idempotent, self-verifying on its OWN effects (#403), ledger
-- stamped (#402). Proven on PG16 before shipping.

create or replace function public.seed_svi_weight_profiles(p_church_id uuid)
returns integer
language plpgsql
as $fn$
declare
  v_inserted integer;
begin
  if p_church_id is null then
    raise exception 'seed_svi_weight_profiles: p_church_id must not be null';
  end if;

  if not exists (select 1 from public.churches where id = p_church_id) then
    raise exception 'seed_svi_weight_profiles: no church with id %', p_church_id;
  end if;

  -- Insert only the profile_keys this church is MISSING. A church that has
  -- tuned its own weights must never be reset by a reseed: seeding and
  -- retuning are different operations and stay different. Rerun returns 0.
  insert into public.svi_weight_profiles
    (id, profile_key, display_name, description, applies_to_level,
     weights, zone_thresholds, trend_thresholds, is_active, notes,
     created_at, updated_at, church_id)
  select gen_random_uuid(),
         d.profile_key, d.display_name, d.description, d.applies_to_level,
         d.weights, d.zone_thresholds, d.trend_thresholds, d.is_active, d.notes,
         now(), now(), p_church_id
  from (values
    ('default', E'Default \u2014 All Members', 'Generic baseline. Used as fallback if no level-specific profile is active.', NULL::integer, '{"gather_lc": 15, "gather_sunday": 20, "service_lc_led": 5, "growth_btli_att": 0, "growth_batch_att": 0, "growth_btli_pass": 0, "prayer_opens_14d": 1, "prayer_saved_30d": 1, "service_preaching": 5, "fellowship_lc_rate": 10, "prayer_meeting_att": 5, "service_guide_prep": 2, "mission_eolo_active": 10, "prayer_answered_90d": 1, "gather_sunday_school": 0, "growth_pathway_moves": 0, "service_ministry_role": 5, "fellowship_celebration": 0, "fellowship_meeting_prep": 0, "growth_diagnostic_recent": 10, "prayer_intercessions_30d": 1, "devotional_reflections_4w": 20, "growth_intervention_progress": 10}'::jsonb, '{"warming": 40, "thriving": 70}'::jsonb, '{"up": 5, "down": -5}'::jsonb, true, 'Tweak weights anytime. Edge Function normalizes so they need not sum to 100.'),
    ('level_0', E'Level 0 \u2014 Inquirer / Pre-believer', 'Only Gather + Fellowship measured. We do not expect EOLO, ministry, or diagnostics yet.', 0, '{"gather_lc": 20, "gather_sunday": 30, "growth_btli_att": 0, "growth_batch_att": 0, "growth_btli_pass": 0, "prayer_opens_14d": 1, "prayer_saved_30d": 1, "fellowship_lc_rate": 20, "prayer_meeting_att": 0, "prayer_answered_90d": 1, "gather_sunday_school": 0, "growth_pathway_moves": 0, "fellowship_celebration": 0, "fellowship_meeting_prep": 0, "growth_diagnostic_recent": 0, "prayer_intercessions_30d": 1, "devotional_reflections_4w": 2, "growth_intervention_progress": 0}'::jsonb, '{"warming": 30, "thriving": 60}'::jsonb, '{"up": 5, "down": -5}'::jsonb, true, E'Lower thresholds \u2014 we celebrate even small steps for inquirers.'),
    ('level_1', E'Level 1 \u2014 New Believer', 'Add Word + light Mission. Service still optional.', 1, '{"gather_lc": 20, "gather_sunday": 25, "growth_btli_att": 10, "growth_batch_att": 10, "growth_btli_pass": 8, "prayer_opens_14d": 1, "prayer_saved_30d": 1, "fellowship_lc_rate": 10, "prayer_meeting_att": 10, "mission_eolo_active": 10, "prayer_answered_90d": 1, "gather_sunday_school": 0, "growth_pathway_moves": 10, "service_ministry_role": 3, "fellowship_celebration": 6, "service_multi_ministry": 3, "fellowship_meeting_prep": 0, "growth_diagnostic_recent": 10, "prayer_intercessions_30d": 1, "devotional_reflections_4w": 25, "growth_intervention_progress": 10}'::jsonb, '{"warming": 35, "thriving": 65}'::jsonb, '{"up": 5, "down": -5}'::jsonb, true, 'Devotional habit-formation phase. Word is heaviest non-attendance metric.'),
    ('level_2', E'Level 2 \u2014 Disciple / Team Member', 'All eight metrics balanced. Service expected.', 2, '{"gather_lc": 15, "gather_sunday": 15, "service_lc_led": 10, "growth_btli_att": 10, "growth_batch_att": 8, "growth_btli_pass": 7, "prayer_opens_14d": 1, "prayer_saved_30d": 1, "service_preaching": 10, "fellowship_lc_rate": 10, "prayer_meeting_att": 10, "service_guide_prep": 5, "mission_eolo_active": 15, "prayer_answered_90d": 1, "gather_sunday_school": 0, "growth_pathway_moves": 7, "service_ministry_role": 10, "fellowship_celebration": 3, "service_multi_ministry": 5, "fellowship_meeting_prep": 3, "growth_diagnostic_recent": 10, "prayer_intercessions_30d": 1, "devotional_reflections_4w": 20, "growth_intervention_progress": 5, "multiplication_disciples_advancing": 10}'::jsonb, '{"warming": 40, "thriving": 70}'::jsonb, '{"up": 5, "down": -5}'::jsonb, true, 'Balanced expectations across all dimensions.'),
    ('level_3', E'Level 3 \u2014 Leader', 'Mission and service weighted heavier; word still core.', 3, '{"gather_lc": 15, "gather_sunday": 10, "service_lc_led": 15, "growth_btli_att": 10, "growth_batch_att": 10, "growth_btli_pass": 8, "prayer_opens_14d": 1, "prayer_saved_30d": 1, "service_preaching": 10, "fellowship_lc_rate": 10, "prayer_meeting_att": 10, "service_guide_prep": 5, "mission_eolo_active": 20, "prayer_answered_90d": 1, "gather_sunday_school": 0, "growth_pathway_moves": 0, "service_ministry_role": 15, "fellowship_celebration": 5, "service_multi_ministry": 5, "fellowship_meeting_prep": 5, "growth_diagnostic_recent": 5, "prayer_intercessions_30d": 1, "devotional_reflections_4w": 20, "growth_intervention_progress": 5, "multiplication_disciples_advancing": 10}'::jsonb, '{"warming": 45, "thriving": 75}'::jsonb, '{"up": 5, "down": -5}'::jsonb, true, 'Higher bar for thriving. Leaders should be reproducing disciples (EOLO weight up).'),
    ('level_4', E'Level 4 \u2014 Coach / Leader of Leaders', 'Reproduction and depth weighted highest.', 4, '{"gather_lc": 10, "gather_sunday": 10, "service_lc_led": 15, "growth_btli_att": 5, "growth_batch_att": 5, "growth_btli_pass": 5, "prayer_opens_14d": 1, "prayer_saved_30d": 1, "service_preaching": 5, "fellowship_lc_rate": 10, "prayer_meeting_att": 0, "service_guide_prep": 5, "mission_eolo_active": 25, "prayer_answered_90d": 1, "gather_sunday_school": 0, "growth_pathway_moves": 5, "service_ministry_role": 15, "fellowship_celebration": 5, "service_multi_ministry": 5, "fellowship_meeting_prep": 10, "growth_diagnostic_recent": 5, "prayer_intercessions_30d": 1, "devotional_reflections_4w": 20, "growth_intervention_progress": 5, "multiplication_disciples_advancing": 15}'::jsonb, '{"warming": 50, "thriving": 75}'::jsonb, '{"up": 5, "down": -5}'::jsonb, true, 'Reproduction (EOLO) is highest single weight. Future: add "disciples_made" metric.'),
    ('level_5', E'Level 5 \u2014 Director / Executive', 'Pastoral judgment dominates; metrics are sanity check only.', 5, '{"gather_lc": 10, "gather_sunday": 10, "service_lc_led": 25, "growth_btli_att": 5, "growth_batch_att": 5, "growth_btli_pass": 5, "prayer_opens_14d": 1, "prayer_saved_30d": 1, "service_preaching": 10, "fellowship_lc_rate": 5, "prayer_meeting_att": 10, "service_guide_prep": 5, "mission_eolo_active": 25, "prayer_answered_90d": 1, "gather_sunday_school": 0, "growth_pathway_moves": 0, "service_ministry_role": 25, "fellowship_celebration": 5, "service_multi_ministry": 5, "fellowship_meeting_prep": 5, "growth_diagnostic_recent": 5, "prayer_intercessions_30d": 1, "devotional_reflections_4w": 20, "growth_intervention_progress": 5, "multiplication_disciples_advancing": 15}'::jsonb, '{"warming": 50, "thriving": 75}'::jsonb, '{"up": 5, "down": -5}'::jsonb, true, 'For the church''s executive leader(s). Self-review primarily.')
  ) as d(profile_key, display_name, description, applies_to_level,
         weights, zone_thresholds, trend_thresholds, is_active, notes)
  where not exists (
    select 1 from public.svi_weight_profiles x
    where x.church_id = p_church_id
      and x.profile_key = d.profile_key
  );

  get diagnostics v_inserted = row_count;
  return v_inserted;
end
$fn$;

-- Owner/service_role only. A pastor must not be able to seed another church.
revoke all on function public.seed_svi_weight_profiles(uuid) from public;
revoke all on function public.seed_svi_weight_profiles(uuid) from anon;
revoke all on function public.seed_svi_weight_profiles(uuid) from authenticated;
grant execute on function public.seed_svi_weight_profiles(uuid) to service_role;

-- ---- ledger stamp (#402/#212)
insert into public.schema_migrations (version, filename, note) values
  ('106','106_seed_svi_weight_profiles_fn.sql','seed_svi_weight_profiles(church_id): the 7 default SVI weight profiles as literals in one versioned function body; idempotent per profile_key, never overwrites an existing profile; owner/service_role only. Seeds no church -- installation only.')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

-- ---- SELF-VERIFY -- asserts only THIS migration's own effects (#403).
-- Expect: fn_present 1, returns integer, one uuid arg, keys_in_body 7,
-- exposed_to_clients 0, all_ok PASS. Row counts elsewhere are deliberately
-- NOT asserted: this migration seeds nobody, so nothing else should have moved.
select
  (select count(*) from pg_proc p join pg_namespace n on n.oid=p.pronamespace
    where n.nspname='public' and p.proname='seed_svi_weight_profiles')            as fn_present,
  (select pg_get_function_result(p.oid) from pg_proc p join pg_namespace n on n.oid=p.pronamespace
    where n.nspname='public' and p.proname='seed_svi_weight_profiles')            as returns_type,
  (select pg_get_function_arguments(p.oid) from pg_proc p join pg_namespace n on n.oid=p.pronamespace
    where n.nspname='public' and p.proname='seed_svi_weight_profiles')            as arguments,
  (select count(*) from (values ('default'),('level_0'),('level_1'),('level_2'),
                                ('level_3'),('level_4'),('level_5')) k(key)
    where position(k.key in (
      select pg_get_functiondef(p.oid) from pg_proc p join pg_namespace n on n.oid=p.pronamespace
      where n.nspname='public' and p.proname='seed_svi_weight_profiles')) > 0)    as keys_in_body,
  (select count(*) from (select unnest(array['anon','authenticated','public']) as r) g
    where has_function_privilege(g.r, 'public.seed_svi_weight_profiles(uuid)', 'EXECUTE')) as exposed_to_clients,
  case when
    (select count(*) from pg_proc p join pg_namespace n on n.oid=p.pronamespace
      where n.nspname='public' and p.proname='seed_svi_weight_profiles') = 1
   and (select count(*) from (select unnest(array['anon','authenticated','public']) as r) g
         where has_function_privilege(g.r, 'public.seed_svi_weight_profiles(uuid)', 'EXECUTE')) = 0
  then 'PASS' else 'FAIL' end                                                     as all_ok;

-- ---- TO SEED A CHURCH (run separately, one church at a time) --------------
-- Returns the number of profiles inserted: 7 the first time, 0 on any rerun.
--
--   select public.seed_svi_weight_profiles(id) as inserted
--   from public.churches where slug = 'PUT-SLUG-HERE';
--
-- To see which churches are still dark:
--
--   select c.slug, c.name, count(p.id) as profiles
--   from public.churches c
--   left join public.svi_weight_profiles p on p.church_id = c.id
--   group by c.slug, c.name order by profiles, c.name;
