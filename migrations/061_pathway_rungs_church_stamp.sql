-- ============================================================================
-- 061_pathway_rungs_church_stamp.sql   ·   Session 58
-- Attach the existing base-safe church-stamp trigger to pathway_rungs so the L5
-- pipeline editor's OVERLAY inserts auto-stamp church_id from the JWT — without
-- the client ever handling church_id, and without touching multiply_shared.js.
--
-- Safe for the Model-3 base rows: set_church_id_from_jwt() (migration 014) only
-- stamps WHEN NEW.church_id IS NULL, setting it to auth_church_id() — which is
-- NULL for owner / service-role / migration inserts (no JWT). So base seeds stay
-- church_id NULL; only JWT-borne client overlay inserts get stamped. RLS's INSERT
-- check (church_id = auth_church_id() AND auth_level() >= 5) then confirms tenancy
-- + pastor-gate server-side. pathway_rungs post-dates migration 014's bulk attach,
-- which is why it lacked the trigger until now.
--
-- FLAT (#209), rerun-safe (drop-if-exists + on-conflict, #210), commit to
-- migrations/ right after running (#242). No RLS change (already correct + on).
-- ============================================================================

drop trigger if exists trg_set_church_id on public.pathway_rungs;
create trigger trg_set_church_id
  before insert on public.pathway_rungs
  for each row execute function public.set_church_id_from_jwt();

-- ----------------------------------------------------------------------------
-- LEDGER (#212)
-- ----------------------------------------------------------------------------
insert into public.schema_migrations (version, filename, applied_at, note)
values ('061','061_pathway_rungs_church_stamp.sql', now(),
        'Attach base-safe trg_set_church_id (set_church_id_from_jwt) to pathway_rungs — L5 editor overlay inserts auto-stamp church_id from JWT; base church_id NULL preserved')
on conflict (version) do nothing;

-- ----------------------------------------------------------------------------
-- SELF-VERIFY (#210) — expect stamp_trigger = 1
-- ----------------------------------------------------------------------------
select count(*) as stamp_trigger
from pg_trigger
where tgrelid = 'public.pathway_rungs'::regclass
  and tgname  = 'trg_set_church_id'
  and not tgisinternal;
