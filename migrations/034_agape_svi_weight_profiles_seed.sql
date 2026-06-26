-- migrations/034_agape_svi_weight_profiles_seed.sql
-- S48 — (A) fix two tenancy-blind uniques -> composite on church_id,
--        (B) seed Agape a copy-as-template of Rosehill's 7 (genericized level_5 note).
-- FLAT (#209), idempotent (drop-then-add; seed guarded), ledger + self-verify (#210/#212).

-- ---- (A) repair tenancy-blind constraints --------------------------------
alter table public.svi_weight_profiles drop constraint if exists svi_weight_profiles_profile_key_key;
alter table public.svi_weight_profiles drop constraint if exists svi_weight_profiles_church_profilekey_uq;
alter table public.svi_weight_profiles
  add  constraint svi_weight_profiles_church_profilekey_uq unique (church_id, profile_key);

drop index if exists public.uq_svi_profile_active_level;
create unique index uq_svi_profile_active_level
  on public.svi_weight_profiles (church_id, applies_to_level)
  where (is_active = true);

-- ---- (B) seed Agape from Rosehill (genericize level_5 note) ---------------
with agape as (
  select id from public.churches
  where slug = 'agape' or name ilike '%agape%'
  order by (slug = 'agape') desc
  limit 1
),
rosehill as (
  select id from public.churches
  where slug = 'rosehill' or name ilike '%rosehill%'
  order by (slug = 'rosehill') desc
  limit 1
)
insert into public.svi_weight_profiles
  (id, profile_key, display_name, description, applies_to_level,
   weights, zone_thresholds, trend_thresholds, is_active, notes,
   created_at, updated_at, church_id)
select
  gen_random_uuid(),
  src.profile_key, src.display_name, src.description, src.applies_to_level,
  src.weights, src.zone_thresholds, src.trend_thresholds, src.is_active,
  case when src.profile_key = 'level_5'
       then 'For the church''s executive leader(s). Self-review primarily.'
       else src.notes end,
  now(), now(),
  (select id from agape)
from public.svi_weight_profiles src
where src.church_id = (select id from rosehill)
  and exists (select 1 from agape)
  and not exists (
    select 1 from public.svi_weight_profiles x
    where x.church_id = (select id from agape)
      and x.profile_key = src.profile_key
  );

-- ---- ledger stamp (#212)
insert into public.schema_migrations (version, filename, note) values
  ('034','034_agape_svi_weight_profiles_seed.sql','Fix two tenancy-blind uniques (profile_key; active applies_to_level) to composite on church_id; seed Agape copy-as-template of Rosehill 7 profiles, genericized level_5 note')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

-- ---- SELF-VERIFY — expect BOTH churches: 7, keys = default, level_0..level_5
select c.slug as church,
       count(*) as n_profiles,
       string_agg(s.profile_key, ', ' order by s.profile_key) as keys
from public.svi_weight_profiles s
join public.churches c on c.id = s.church_id
where c.slug in ('rosehill','agape') or c.name ilike '%agape%' or c.name ilike '%rosehill%'
group by c.slug
order by c.slug;
