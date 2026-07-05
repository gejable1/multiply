-- migrations/062_onboard_truenorth.sql
-- Onboard a new tenant church: True North (slug 'truenorth')
-- + its L5 pastor Timothy (member_pin_hash NULL -> first-login set_pin).
-- Mirrors 051/049/042: church_id supplied explicitly so trg_set_church_id won't clobber.
-- FLAT (#209), idempotent, ledger (#212), self-verify rerun-until-true (#210).

-- (1) church
insert into churches (name, slug, timezone) values
  ('True North', 'truenorth', 'Asia/Manila')
on conflict (slug) do nothing;

-- (2) L5 pastor Timothy — fresh row, NULL pin (first-login set_pin), inserted only if absent
insert into members (name, pipeline_level, church_id, is_external_user, is_test_member, is_platform_admin, share_with_lc)
select 'Timothy', 5, c.id, false, false, false, true
from churches c
where c.slug = 'truenorth'
  and not exists (
    select 1 from members m where m.name = 'Timothy' and m.church_id = c.id
  );

-- ledger (#212)
insert into public.schema_migrations (version, filename, note) values
  ('062','062_onboard_truenorth.sql','onboard True North (slug truenorth) + L5 pastor Timothy (NULL pin, first-login set_pin)')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

-- SELF-VERIFY — expect church_present=1, pastor_l5=1, and a UUID for truenorth_church_id
select
  (select count(*) from churches where slug='truenorth')                                    as church_present,
  (select count(*) from members m join churches c on c.id=m.church_id
     where c.slug='truenorth' and m.pipeline_level=5)                                        as pastor_l5,
  (select id from churches where slug='truenorth')                                           as truenorth_church_id;
