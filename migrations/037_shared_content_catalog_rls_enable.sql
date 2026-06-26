-- migrations/037_shared_content_catalog_rls_enable.sql
-- S49 Phase B — flip RLS ON for the 7 shared-content catalog tables. THE LAST TENANCY ITEM.
-- Policies already in place (033: 4 tenant each; pre-flight confirmed 4/4, 0 stubs, all authenticated).
-- Base authoring routes through the service-role catalog-publish EF (bypasses RLS, stamps church_id=NULL).
-- FLAT (#209), idempotent, ledger (#212), trailing self-verify (#210).

alter table public.btli_quizzes      enable row level security;
alter table public.cohort_programs   enable row level security;
alter table public.library_chapters  enable row level security;
alter table public.library_quizzes   enable row level security;
alter table public.library_resources enable row level security;
alter table public.pipeline_lessons  enable row level security;
alter table public.usbong_quizzes    enable row level security;

insert into public.schema_migrations (version, filename, note) values
  ('037','037_shared_content_catalog_rls_enable.sql','Phase B: RLS ENABLED on the 7 shared-content catalog tables. Policies from 033 (4 tenant each: base-or-mine read, mine-only write); pre-flight 4/4 + 0 stubs. Base authoring via service-role catalog-publish EF. Last tenancy item.')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

with t(name) as (values
  ('btli_quizzes'),('cohort_programs'),('library_chapters'),('library_quizzes'),
  ('library_resources'),('pipeline_lessons'),('usbong_quizzes'))
select t.name as table_name, c.relrowsecurity as rls_enabled,
  (select count(*) from pg_policies p where p.schemaname='public' and p.tablename=t.name) as n_policies,
  (select count(*) from pg_policies p where p.schemaname='public' and p.tablename=t.name
     and (p.roles::text ~ '(anon|public)')
     and (coalesce(p.qual,'')='true' or coalesce(p.with_check,'')='true')) as allow_all_stubs
from t join pg_class c on c.oid=('public.'||t.name)::regclass
order by table_name;
