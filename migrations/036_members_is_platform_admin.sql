-- migrations/036_members_is_platform_admin.sql
-- S49 Phase B — platform-author flag (decoupled from any tenant church).
-- The catalog-publish EF gates base-curriculum writes on this flag (service-role lookup by JWT sub).
-- FLAT (#209), idempotent, ledger (#212), trailing self-verify (#210).

alter table public.members
  add column if not exists is_platform_admin boolean not null default false;

-- SEED — platform author = Gerry Limoso (Rosehill, L5). Decoupled from church_id by design.
update public.members set is_platform_admin = true
 where id = '547ebda6-5126-436e-9890-709f50588ced';

insert into public.schema_migrations (version, filename, note) values
  ('036','036_members_is_platform_admin.sql','Platform-author flag: members.is_platform_admin (default false), seeded the platform author (Gerry, 547ebda6) only. Gates the catalog-publish EF base-write lane; decouples platform authorship from tenant church_id.')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

select id, name, church_id, pipeline_level, is_platform_admin
from public.members where is_platform_admin = true;
