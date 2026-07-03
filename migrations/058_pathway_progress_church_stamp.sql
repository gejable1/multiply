-- ============================================================================
-- 058_pathway_progress_church_stamp.sql   ·   Session 57
-- Attach the platform church-id auto-stamp trigger to pathway_progress.
--
-- Why: pathway_progress.church_id is NOT NULL, and the RLS INSERT policy checks
-- church_id = auth_church_id(). The platform convention (members, attendance,
-- announcements, lcg_leader_checkins) is that CLIENT inserts do NOT supply
-- church_id — the BEFORE INSERT trigger trg_set_church_id (set_church_id_from_jwt,
-- #182) stamps it from the JWT, and that runs before the RLS WITH CHECK. This
-- lets the LCL mark a rung without knowing/sending church_id, unspoofably.
--
-- FLAT (#209), rerun-safe (#210), committed to migrations/ after running
-- (#242/#252). Verified in schema.json: set_church_id_from_jwt() exists;
-- trg_set_church_id is the canonical trigger name on sibling tables.
-- ============================================================================

drop trigger if exists trg_set_church_id on public.pathway_progress;
create trigger trg_set_church_id
  before insert on public.pathway_progress
  for each row execute function set_church_id_from_jwt();

-- ledger (#212)
insert into public.schema_migrations (version, filename, applied_at, note)
values ('058','058_pathway_progress_church_stamp.sql', now(),
        'Attach trg_set_church_id (set_church_id_from_jwt) to pathway_progress — LCL client inserts auto-stamp church_id from JWT (#182)')
on conflict (version) do nothing;

-- self-verify (#210) — expect stamp_trigger = 1
select count(*) as stamp_trigger
from pg_trigger
where tgrelid = 'public.pathway_progress'::regclass
  and tgname = 'trg_set_church_id'
  and not tgisinternal;
