-- migrations/107_seed_svi_weight_profiles_all_churches.sql
-- S86 -- seed the seven default SVI weight profiles into EVERY church.
--
-- 106 installed seed_svi_weight_profiles(church_id) and deliberately seeded
-- nobody. This runs it once per church so no tenant is left dark.
--
-- Safe by construction, because the work is all inside the function:
--   * it inserts only the profile_keys a church is MISSING, so Rosehill and
--     Agape (already complete) return 0 and are not touched;
--   * it NEVER overwrites an existing profile, so any pastor who has already
--     tuned his own weights keeps them -- proved on PG16 against a church
--     holding a hand-tuned `default`, which received 6 and kept its own;
--   * rerunning this whole migration inserts nothing.
--
-- No filter on churches.status: a dormant tenant with no members simply gets
-- its profiles early and costs nothing. Filtering would mean this has to be
-- remembered again later, which is the exact failure 106 exists to end.
--
-- Flat (#209), idempotent, self-verifying on its OWN effects (#403), ledger
-- stamped (#402).

-- ---- the seeding ----------------------------------------------------------
select c.slug,
       c.name,
       public.seed_svi_weight_profiles(c.id) as inserted
from   public.churches c
order  by c.name;

-- ---- ledger stamp (#402/#212)
insert into public.schema_migrations (version, filename, note) values
  ('107','107_seed_svi_weight_profiles_all_churches.sql','Run seed_svi_weight_profiles() for every church so no tenant is left without SVI weight profiles; already-complete churches return 0, hand-tuned profiles are never overwritten')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

-- ---- SELF-VERIFY -- asserts only THIS migration's own effects (#403).
-- Expect: churches_total = churches_with_7, churches_short = 0,
-- distinct_key_sets = 1, all_ok = PASS.
-- distinct_key_sets is the real assertion: every church must hold the SAME
-- seven keys, not merely seven of something.
select
  (select count(*) from public.churches)                                as churches_total,
  (select count(*) from (
     select p.church_id from public.svi_weight_profiles p
     group by p.church_id having count(*) = 7) q)                       as churches_with_7,
  (select count(*) from public.churches c
    where (select count(*) from public.svi_weight_profiles p
            where p.church_id = c.id) <> 7)                             as churches_short,
  (select count(*) from (
     select string_agg(p.profile_key, ',' order by p.profile_key) as keyset
     from public.svi_weight_profiles p group by p.church_id) k)         as church_count_by_keyset,
  (select count(distinct keyset) from (
     select string_agg(p.profile_key, ',' order by p.profile_key) as keyset
     from public.svi_weight_profiles p group by p.church_id) k)         as distinct_key_sets,
  case when
       (select count(*) from public.churches c
         where (select count(*) from public.svi_weight_profiles p
                 where p.church_id = c.id) <> 7) = 0
   and (select count(distinct keyset) from (
          select string_agg(p.profile_key, ',' order by p.profile_key) as keyset
          from public.svi_weight_profiles p group by p.church_id) k) = 1
  then 'PASS' else 'FAIL' end                                           as all_ok;
