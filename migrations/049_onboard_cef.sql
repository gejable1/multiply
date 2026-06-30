-- migrations/049_onboard_cef.sql
-- Onboard a new tenant church: Christ's Eminence Fellowship (slug 'cef')
-- + its L5 pastor Arnaldo J Arnaldo (member_pin_hash NULL -> first-login set_pin).
-- Mirrors 042: church_id supplied explicitly so trg_set_church_id won't clobber.
-- FLAT (#209), idempotent, ledger (#212), self-verify rerun-until-true (#210).

-- (1) church
insert into churches (name, slug, timezone) values
  ('Christ''s Eminence Fellowship', 'cef', 'Asia/Manila')
on conflict (slug) do nothing;

-- (2) L5 pastor — fresh row, NULL pin (first-login set_pin), inserted only if absent
insert into members (name, pipeline_level, church_id, is_external_user, is_test_member, is_platform_admin, share_with_lc)
select 'Arnaldo J Arnaldo', 5, c.id, false, false, false, true
from churches c
where c.slug = 'cef'
  and not exists (
    select 1 from members m where m.name = 'Arnaldo J Arnaldo' and m.church_id = c.id
  );

-- ledger
insert into public.schema_migrations (version, filename, note) values
  ('049','049_onboard_cef.sql','onboard Christ''s Eminence Fellowship (slug cef) + L5 pastor Arnaldo J Arnaldo (NULL pin, first-login set_pin)')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

-- SELF-VERIFY — expect church_present=1, pastor_l5=1, and a UUID for cef_church_id
select
  (select count(*) from churches where slug='cef') as church_present,
  (select count(*) from members m join churches c on c.id=m.church_id
     where c.slug='cef' and m.pipeline_level=5) as pastor_l5,
  (select id from churches where slug='cef') as cef_church_id;
