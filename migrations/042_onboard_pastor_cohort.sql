-- migrations/042_onboard_pastor_cohort.sql
-- Pre-seed 7 tenant churches + their L5 pastors.
--   • Joey Sison (07eccb0f…): RE-STAMP his existing Rosehill guest row -> Saturate,
--     L5, un-guest. No delete (he has child rows; delete would hit a FK). Keeps PIN.
--   • Jerome Abogado + 5 others: fresh L5 rows, member_pin_hash NULL (first-login set_pin).
-- Skips Rosehill (#1) and Agape (#4, slug 'agape', onboarded in 028).
-- church_id supplied explicitly → trg_set_church_id won't clobber (sets only when NULL).
-- FLAT (#209), idempotent, ledger (#212), self-verify (#210).

-- (1) churches
insert into churches (name, slug, timezone) values
  ('His Presence Church Saturate',                       'saturate','Asia/Manila'),
  ('His Presence Church NC',                             'hpcinc',  'Asia/Manila'),
  ('Abundant Life Church Caloocan',                      'alc',     'Asia/Manila'),
  ('Montalban Christian Fellowship',                     'mcf',     'Asia/Manila'),
  ('Freedom in Christ Church',                           'fcc',     'Asia/Manila'),
  ('OB Christian Ministry Phil. Inc.',                   'obcc',    'Asia/Manila'),
  ('Cornerstone International Christian Church of Llano', 'ciccl',   'Asia/Manila')
on conflict (slug) do nothing;

-- (2) Joey — re-stamp existing row to Saturate, L5, un-guest (by exact id; no delete)
update members
set church_id      = (select id from churches where slug='saturate'),
    pipeline_level = 5,
    is_external_user = false,
    updated_at     = now()
where id = '07eccb0f-3935-45b6-a2fb-f2938d5669e1';

-- (3) the other 6 fresh L5 pastors (inserted only if not already present in that church)
insert into members (name, pipeline_level, church_id, is_external_user, is_test_member, is_platform_admin, share_with_lc)
select v.pastor, 5, c.id, false, false, false, true
from (values
  ('hpcinc',  'Adet Colitoy'),
  ('alc',     'Jerome Abogado'),
  ('mcf',     'Edmund Donato'),
  ('fcc',     'Francis Madison'),
  ('obcc',    'Gijeon Tuazon'),
  ('ciccl',   'Marissa Derla')
) as v(slug, pastor)
join churches c on c.slug = v.slug
where not exists (
  select 1 from members m where m.name = v.pastor and m.church_id = c.id
);

-- ledger
insert into public.schema_migrations (version, filename, note) values
  ('042','042_onboard_pastor_cohort.sql','pre-seed 7 churches + L5 pastors: Joey re-stamped Rosehill->Saturate (kept history+PIN), Jerome+5 fresh (NULL pin, first-login set_pin); skips Rosehill+Agape')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

-- SELF-VERIFY — expect churches_present=7, l5_pastors=7, and Joey on Saturate
select
  (select count(*) from churches where slug in ('saturate','hpcinc','alc','mcf','fcc','obcc','ciccl')) as churches_present,
  (select count(*) from members m join churches c on c.id=m.church_id
     where c.slug in ('saturate','hpcinc','alc','mcf','fcc','obcc','ciccl') and m.pipeline_level=5) as l5_pastors,
  (select c.slug from members m join churches c on c.id=m.church_id
     where m.id='07eccb0f-3935-45b6-a2fb-f2938d5669e1') as joey_church;
