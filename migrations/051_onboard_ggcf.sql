-- migrations/051_onboard_ggcf.sql
-- Onboard a new tenant church: Glorious Grace Christian Fellowship (slug 'ggcf')
-- + its L5 pastor Geraldine Minguez (member_pin_hash NULL -> first-login set_pin).
-- Mirrors 049/042: church_id supplied explicitly so trg_set_church_id won't clobber.
-- FLAT (#209), idempotent, ledger (#212), self-verify rerun-until-true (#210).

-- (1) church
insert into churches (name, slug, timezone) values
  ('Glorious Grace Christian Fellowship', 'ggcf', 'Asia/Manila')
on conflict (slug) do nothing;

-- (2) L5 pastor — fresh row, NULL pin (first-login set_pin), inserted only if absent
insert into members (name, pipeline_level, church_id, is_external_user, is_test_member, is_platform_admin, share_with_lc)
select 'Geraldine Minguez', 5, c.id, false, false, false, true
from churches c
where c.slug = 'ggcf'
  and not exists (
    select 1 from members m where m.name = 'Geraldine Minguez' and m.church_id = c.id
  );

-- ledger
insert into public.schema_migrations (version, filename, note) values
  ('051','051_onboard_ggcf.sql','onboard Glorious Grace Christian Fellowship (slug ggcf) + L5 pastor Geraldine Minguez (NULL pin, first-login set_pin)')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

-- SELF-VERIFY — expect church_present=1, pastor_l5=1, and a UUID for ggcf_church_id
select
  (select count(*) from churches where slug='ggcf') as church_present,
  (select count(*) from members m join churches c on c.id=m.church_id
     where c.slug='ggcf' and m.pipeline_level=5) as ggcf_church_id_count,
  (select id from churches where slug='ggcf') as ggcf_church_id;
