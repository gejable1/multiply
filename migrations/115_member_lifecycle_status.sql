-- migrations/115_member_lifecycle_status.sql
-- S88 -- member lifecycle status: active / inactive / moved / deceased.
--
-- WHY. `members` has never had a lifecycle column, so every soul ever
-- enrolled sits forever in every attendance denominator. An LCG carrying
-- three dormant records can mathematically never celebrate perfect
-- attendance, punishing the celebration culture the church is building.
--
-- SHAPE. Three additive columns, no destructive change anywhere:
--   status            text NOT NULL DEFAULT 'active', CHECK-constrained
--   status_changed_at timestamptz  (set when status changes, app-side)
--   status_note       text         (private shepherding note, leader/admin
--                                   facing only -- NEVER shown to members)
-- The record stays whole: discipler, lc_group, pathway progress, and
-- reflections are all untouched by a status change (deliberate -- clearing
-- fields as a proxy for status is the emptiness-as-proxy trap, #446).
-- Reactivation is a one-column flip.
--
-- PASTORAL RULES this column carries (enforced app-side, recorded here):
--   * Statistical denominators count status='active' ONLY.
--   * Marking non-active is a shepherding decision: LC leader requests,
--     pastor/admin confirms. Never automatic. The system may SUGGEST
--     (12 weeks without attendance) as a conversation starter, never a
--     verdict -- absence is never a verdict.
--   * Dormant members surface as an EOLO pursuit list, not a graveyard.
--
-- FORWARD-ONLY. All existing members backfill to 'active' via the DEFAULT;
-- no history is rewritten.

alter table public.members
  add column if not exists status text not null default 'active';

alter table public.members
  add column if not exists status_changed_at timestamptz;

alter table public.members
  add column if not exists status_note text;

alter table public.members
  drop constraint if exists members_status_check;

alter table public.members
  add constraint members_status_check
  check (status in ('active','inactive','moved','deceased'));

create index if not exists idx_members_status
  on public.members (church_id, status);

insert into public.schema_migrations (version, filename, note) values
  ('115','115_member_lifecycle_status.sql','Member lifecycle status (active/inactive/moved/deceased) + status_changed_at + private status_note. Additive only; all members backfill active; record stays whole on status change (no field clearing, #446). Statistical denominators will count active only; marking non-active is leader-requests-pastor-approves; 12-week no-attendance list is a suggestion surface, never automatic. Dormant list doubles as EOLO pursuit field.')
on conflict (version) do update set filename=excluded.filename, note=excluded.note, applied_at=now();

-- ---- SELF-VERIFY -- asserts only THIS migration's own effects (#403), rerun-safe.
-- Expect: cols_present 3, check_present true, idx_present true,
-- non_active_rows 0 (first run), ledger_stamped true, all_ok PASS.
select
  (select count(*) from information_schema.columns
    where table_schema='public' and table_name='members'
      and column_name in ('status','status_changed_at','status_note'))       as cols_present,
  (select count(*)=1 from pg_constraint
    where conname='members_status_check' and conrelid='public.members'::regclass) as check_present,
  (select count(*)=1 from pg_indexes
    where schemaname='public' and indexname='idx_members_status')            as idx_present,
  (select count(*) from public.members where status <> 'active')             as non_active_rows,
  (select count(*)=1 from public.schema_migrations where version='115')      as ledger_stamped,
  case when
       (select count(*) from information_schema.columns
         where table_schema='public' and table_name='members'
           and column_name in ('status','status_changed_at','status_note')) = 3
   and (select count(*)=1 from pg_constraint
         where conname='members_status_check' and conrelid='public.members'::regclass)
   and (select count(*)=1 from pg_indexes
         where schemaname='public' and indexname='idx_members_status')
   and (select count(*)=1 from public.schema_migrations where version='115')
  then 'PASS' else 'FAIL' end                                                as all_ok;
