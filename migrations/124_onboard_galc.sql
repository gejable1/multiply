-- migrations/124_onboard_galc.sql
-- Onboard a new tenant church: God's Agape Love Church (slug 'galc')
-- + its L5 pastor Crisostomo Ragma Padegdeg (member_pin_hash NULL -> first-login set_pin).
-- NOTE: slug is 'galc', NOT 'agape' - 'agape' is already Pastor Jojo Millete's church (028/031).
-- Mirrors 062/051/049: church_id supplied explicitly so trg_set_church_id won't clobber.
-- No new tables (so no GRANTs needed - Supabase Oct 30 change does not apply).
-- FLAT (#209), idempotent, ledger (#212), self-verify rerun-until-true (#210).

-- (1) church
insert into churches (name, slug, timezone) values
  ('God''s Agape Love Church', 'galc', 'Asia/Manila')
on conflict (slug) do nothing;

-- (2) L5 pastor - fresh row, NULL pin (first-login set_pin), inserted only if absent
insert into members (name, pipeline_level, church_id, is_external_user, is_test_member, is_platform_admin, share_with_lc)
select 'Crisostomo Ragma Padegdeg', 5, c.id, false, false, false, true
from churches c
where c.slug = 'galc'
  and not exists (
    select 1 from members m where m.name = 'Crisostomo Ragma Padegdeg' and m.church_id = c.id
  );

-- ledger (#212)
insert into public.schema_migrations (version, filename, note) values
  ('124','124_onboard_galc.sql','onboard God''s Agape Love Church (slug galc) + L5 pastor Crisostomo Ragma Padegdeg (NULL pin, first-login set_pin)')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

-- SELF-VERIFY - rerun until all three read PASS
select 'church present' as checkpoint,
       case when (select count(*) from churches where slug='galc') = 1 then 'PASS' else 'FAIL' end as status
union all
select 'pastor L5 (exactly one)',
       case when (select count(*) from members m join churches c on c.id=m.church_id
                   where c.slug='galc' and m.pipeline_level=5 and m.name='Crisostomo Ragma Padegdeg') = 1
            then 'PASS' else 'FAIL' end
union all
select 'existing Agape church untouched',
       case when (select name from churches where slug='agape') is distinct from 'God''s Agape Love Church'
            then 'PASS' else 'FAIL' end
union all
select 'ledger 124',
       case when exists (select 1 from public.schema_migrations where version='124') then 'PASS' else 'FAIL' end;
