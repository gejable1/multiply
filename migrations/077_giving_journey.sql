-- ═══════════════════════════════════════════════════════════════════════════
-- 077_giving_journey.sql   ·   Session 73
-- THE GIVING JOURNEY — Landas ng Pagtitiwala (slice 1 of N: data foundation)
--
-- Creates:
--   1. giving_covenant  — the accountability covenant a DISCIPLE opens with ONE
--      named partner. Member-insert-only. Holds consent + companionship ONLY:
--      NO income, NO percentage, NO amount column, ever. (GIVING_JOURNEY.md,
--      Fourth Conviction: the finance wall; guardrail #331: leader can never open it.)
--   2. six base pathway_rungs (church_id = NULL, one seed for all tenants),
--      woven across pipeline levels L1-L4, marked meta.track='giving' so the metro
--      FILTERS THEM OUT for anyone without an open covenant (absence is not a
--      verdict, #332) and surfaces them only on the opted-in member's own view.
--      category='formation' (formation language, never completion) — this value
--      is NOT in the existing pathway_rungs CHECK, so this migration EXPANDS the
--      CHECK to add it (safe: adding an allowed value never invalidates a row).
--      celebrate_publicly=false and trackable=false: giving is never scored,
--      ranked, or counted toward any aggregate. (Guardrail #2: no dashboard.)
--
-- Render gate (MMT renderGivingJourney + MLT mirror) is slice 2/3, NOT here.
-- Completion mechanics + the on-device calculator are later slices, NOT here.
--
-- FLAT · rerunnable · idempotent · self-verifying (rerun until all guards clean).
-- ═══════════════════════════════════════════════════════════════════════════

-- ── 0. EXPAND THE CATEGORY CHECK TO ALLOW 'formation' ─────────────────────
-- Drop-if-exists + add keeps this idempotent; constraint name confirmed from
-- schema.json (pathway_rungs_category_check). Existing rows all use prior values,
-- so re-validation passes.
alter table public.pathway_rungs drop constraint if exists pathway_rungs_category_check;
alter table public.pathway_rungs add constraint pathway_rungs_category_check
  check (category in
    ('book','training','lesson','ministry','coaching',
     'assessment','character','competency','discipline','formation'));

-- ── 1. THE COVENANT TABLE ─────────────────────────────────────────────────
create table if not exists public.giving_covenant (
  id          uuid primary key default gen_random_uuid(),
  church_id   uuid not null references public.churches(id) on delete cascade,
  member_id   uuid not null references public.members(id)  on delete cascade,  -- the disciple (opener)
  partner_id  uuid not null references public.members(id)  on delete cascade,  -- the ONE named companion
  status      text not null default 'open' check (status in ('open','closed')),
  opened_at   timestamptz not null default now(),
  closed_at   timestamptz,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  constraint giving_covenant_not_self check (member_id <> partner_id)
);

-- One OPEN covenant per member at a time; closed rows are kept as pastoral memory.
create unique index if not exists giving_covenant_one_open_uk
  on public.giving_covenant (member_id) where status = 'open';
-- Partner-side lookup: "which disciples have named me their companion" (open only).
create index if not exists giving_covenant_partner_ix
  on public.giving_covenant (partner_id) where status = 'open';

-- ── 2. RLS: only the two parties, and only the DISCIPLE may open or close ──
alter table public.giving_covenant enable row level security;

drop policy if exists giving_covenant_select on public.giving_covenant;
drop policy if exists giving_covenant_insert on public.giving_covenant;
drop policy if exists giving_covenant_update on public.giving_covenant;

-- SELECT: the disciple sees his own; the named partner sees the ones naming him
-- (so the giving journey renders on the companion's view too). NO leader/pastor
-- broad read exists. No dashboard, no leaderboard. (Guardrail #2 / #332)
create policy giving_covenant_select on public.giving_covenant
  for select to authenticated
  using ( member_id = auth_member_id() or partner_id = auth_member_id() );

-- INSERT: ONLY the disciple, ONLY for himself, ONLY in his own church, ONLY 'open'.
-- The leader can NEVER open it and can never ask why it is not open. (Guardrail #331)
create policy giving_covenant_insert on public.giving_covenant
  for insert to authenticated
  with check (
    member_id = auth_member_id()
    and church_id = auth_church_id()
    and status = 'open'
  );

-- UPDATE: ONLY the disciple — to close (or re-name his companion). The PARTNER
-- cannot close it; no one closes another's. "The door he opened, he can also shut."
create policy giving_covenant_update on public.giving_covenant
  for update to authenticated
  using ( member_id = auth_member_id() )
  with check ( member_id = auth_member_id() );

-- No DELETE policy on purpose: covenants are CLOSED, never erased.

-- ── 3. THE SIX RUNGS — woven across L1-L4, a journey of trust not of amounts ─
-- Idempotent upsert against the partial base unique index (level, rung_key)
-- WHERE church_id IS NULL. Re-running re-asserts the doctrine-safe copy + flags.
insert into public.pathway_rungs
  (church_id, level, sort_order, rung_key, title_en, title_tl,
   description_en, description_tl, category, completion_source, published, trackable, meta)
values
  (null, 1, 90, 'giving-first-fruits', 'First Fruits Giving', 'Kauna-unahang Bahagi',
   'You gave on purpose — a planned gift, not leftovers. Trust is beginning to take root.',
   'Nagbigay ka nang may layunin — hindi tira-tira, kundi handa. Nag-uugat na ang pagtitiwala.',
   'formation', 'manual', true, false,
   '{"track":"giving","celebrate_publicly":false,"anchor":"Proverbs 3:9"}'::jsonb),

  (null, 1, 91, 'giving-rhythm', 'A Rhythm of Giving', 'Palagiang Pagbibigay',
   'Giving is becoming a rhythm, not a mood — set aside first, before life takes the rest.',
   'Nagiging kaugalian na ang pagbibigay, hindi sumpong — inuuna bago maubos ng buhay ang natitira.',
   'formation', 'manual', true, false,
   '{"track":"giving","celebrate_publicly":false,"anchor":"1 Corinthians 16:2"}'::jsonb),

  (null, 2, 90, 'giving-proportional', 'Proportional Giving', 'Bahagi Ayon sa Kita',
   'You know your real percentage — and you chose it. An honest number is a truer mirror than a generous feeling.',
   'Alam mo na ang iyong tunay na porsyento — at ikaw ang pumili. Ang tapat na bilang ay mas totoong salamin kaysa sa magandang pakiramdam.',
   'formation', 'manual', true, false,
   '{"track":"giving","celebrate_publicly":false,"anchor":"1 Corinthians 16:2"}'::jsonb),

  (null, 2, 91, 'giving-tithe', 'The Tithe', 'Ang Ikapu',
   'The tithe is not a command but a trustworthy standard — the sure measure a heart reaches for when it dares not lean on its own feelings. No longer a strain; a starting line.',
   'Ang ikapu ay hindi utos kundi isang mapagkakatiwalaang panukat — ang tiyak na sukatang hinahawakan ng pusong ayaw umasa sa sarili nitong damdamin. Hindi na pabigat; isang panimulang guhit.',
   'formation', 'manual', true, false,
   '{"track":"giving","celebrate_publicly":false,"anchor":"Matthew 23:23"}'::jsonb),

  (null, 3, 90, 'giving-sacrificial', 'Sacrificial Giving', 'Pagbibigay na may Sakripisyo',
   'Your giving has begun to cost you something — this is where trust becomes real.',
   'Nagsisimula nang may halaga ang iyong pagbibigay — dito nagiging totoo ang pagtitiwala.',
   'formation', 'manual', true, false,
   '{"track":"giving","celebrate_publicly":false,"anchor":"2 Corinthians 8:2-3"}'::jsonb),

  (null, 4, 90, 'giving-generous-life', 'A Generous Life', 'Buhay na Bukas-Palad',
   'Money is downstream of a changed heart — hospitality, the poor, the stranger, your EOLO. A generous life is being formed in you.',
   'Ang pera ay bunga lang ng pusong nabago — pagtanggap sa iba, sa dukha, sa dayuhan, sa iyong EOLO. Isang buhay na bukas-palad ang hinuhubog sa iyo.',
   'formation', 'manual', true, false,
   '{"track":"giving","celebrate_publicly":false,"anchor":"2 Corinthians 9:11"}'::jsonb)

on conflict (level, rung_key) where church_id is null do update set
  sort_order        = excluded.sort_order,
  title_en          = excluded.title_en,
  title_tl          = excluded.title_tl,
  description_en    = excluded.description_en,
  description_tl    = excluded.description_tl,
  category          = excluded.category,
  completion_source = excluded.completion_source,
  published         = excluded.published,
  trackable         = excluded.trackable,
  meta              = excluded.meta,
  updated_at        = now();

-- ── 4. LEDGER ─────────────────────────────────────────────────────────────
insert into public.schema_migrations (version, filename, note)
values ('077','077_giving_journey.sql',
        'Giving Journey slice 1: giving_covenant table (member-insert-only RLS, no finance columns); category CHECK expanded with formation; 6 base rungs L1-L4 meta.track=giving, celebrate_publicly=false, trackable=false')
on conflict (version) do nothing;

-- ═══════════════════════════════════════════════════════════════════════════
-- SELF-VERIFY — one JSON cell. Run the file (idempotent) or just this SELECT,
-- then copy the single result cell. CLEAN means:
--   covenant_table=1, covenant_policies=3, rls_enabled=1,
--   giving_rungs=6, formation_ok=6, wrong=0, public_violations=0, rungs=[6 items]
-- ═══════════════════════════════════════════════════════════════════════════
select jsonb_pretty(jsonb_build_object(
  'covenant_table',    (select count(*) from information_schema.tables
                          where table_schema='public' and table_name='giving_covenant'),
  'covenant_policies', (select count(*) from pg_policies
                          where schemaname='public' and tablename='giving_covenant'),
  'rls_enabled',       (select count(*) from pg_class
                          where relname='giving_covenant' and relrowsecurity),
  'giving_rungs',      (select count(*) from public.pathway_rungs
                          where church_id is null and meta->>'track'='giving'),
  'formation_ok',      (select count(*) from public.pathway_rungs
                          where church_id is null and category='formation'
                            and meta->>'track'='giving'),
  'wrong',             (select count(*) from public.pathway_rungs
                          where church_id is null and meta->>'track'='giving'
                            and (category <> 'formation' or trackable <> false
                                 or meta->>'celebrate_publicly' <> 'false'
                                 or level not between 1 and 4)),
  'public_violations', (select count(*) from public.pathway_rungs
                          where meta->>'track'='giving'
                            and meta->>'celebrate_publicly' <> 'false'),
  'rungs',             (select jsonb_agg(
                            jsonb_build_object('lvl',level,'key',rung_key,'tl',title_tl)
                            order by level, sort_order)
                          from public.pathway_rungs
                          where church_id is null and meta->>'track'='giving')
)) as result;
