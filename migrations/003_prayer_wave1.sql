-- ============================================================================
-- migrations/003_prayer_wave1.sql
-- Prayer / Panalangin feature — Wave 1 (Foundation + core tables).
--
-- Human-gated (Inv #5/#10): the PASTOR runs this in the Supabase SQL editor.
-- Claude does NOT run migrations and holds no service-role key.
-- Additive & IDEMPOTENT — every step uses IF NOT EXISTS. Safe to re-run.
-- ROLLBACK committed first: migrations/003_rollback.sql (Inv #157).
--
-- WHAT THIS DOES (eyeball before running):
--   1. prayer_requests        — a request/praise authored by a member, with a
--                               kind-/audience-scoped visibility model.
--   2. prayer_list_items      — a member's personal prayer list (saved feed
--                               items, EOLO seeds, free-typed personal items).
--   3. prayer_list_opens      — one row each time a member opens "My Prayer
--                               List" (lightweight SVI signal, Wave 4).
--   4. prayer_intercessions   — a "prayed for this" tap on a request (Wave 2
--                               encouragement; no per-person points).
--
-- TENANCY (Phase 1, Inv #153–#156): every table carries a NULLABLE church_id
-- + FK to churches(id) + index. Brand-new tables start empty, so there is NO
-- backfill step; the app sets church_id from the member's row on insert.
--
-- RLS: each table ends with ALTER TABLE ... DISABLE ROW LEVEL SECURITY; to
-- override the rls_auto_enable event trigger (Inv #10) until RLS Phase 2.
-- ============================================================================


-- ── 1. prayer_requests ──────────────────────────────────────────────────────
-- audience_type:
--   'lcg'              → the requester's LC group (audience_lcl_id = the LCL id)
--   'individuals'      → a hand-picked set (audience_member_ids uuid[])
--   'all'             → everyone (still kind-bubbled in the app)
--   'discipler_pastor' → the requester's discipler + pastor (private care)
-- status: 'open' | 'answered' | 'archived'
CREATE TABLE IF NOT EXISTS prayer_requests (
    id                 uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    requester_id       uuid        REFERENCES members(id),
    requester_name     text,
    body               text        NOT NULL,
    is_anonymous       boolean     NOT NULL DEFAULT false,
    audience_type      text        NOT NULL DEFAULT 'lcg'
                                   CHECK (audience_type IN ('lcg','individuals','all','discipler_pastor')),
    audience_member_ids uuid[],
    audience_lcl_id    uuid        REFERENCES members(id),
    category           text,
    status             text        NOT NULL DEFAULT 'open'
                                   CHECK (status IN ('open','answered','archived')),
    answered_at        timestamptz,
    praise_note        text,
    care_flag          boolean     NOT NULL DEFAULT false,
    care_flag_by       uuid        REFERENCES members(id),
    created_at         timestamptz NOT NULL DEFAULT now(),
    expires_at         timestamptz,
    church_id          uuid        REFERENCES churches(id)
);
CREATE INDEX IF NOT EXISTS idx_prayer_requests_requester   ON prayer_requests(requester_id);
CREATE INDEX IF NOT EXISTS idx_prayer_requests_lcl         ON prayer_requests(audience_lcl_id);
CREATE INDEX IF NOT EXISTS idx_prayer_requests_status      ON prayer_requests(status);
CREATE INDEX IF NOT EXISTS idx_prayer_requests_created     ON prayer_requests(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_prayer_requests_expires     ON prayer_requests(expires_at);
CREATE INDEX IF NOT EXISTS idx_prayer_requests_church_id   ON prayer_requests(church_id);
-- GIN index so the 'individuals' audience membership test (audience_member_ids @> ARRAY[id]) is fast.
CREATE INDEX IF NOT EXISTS idx_prayer_requests_audience_ids ON prayer_requests USING GIN (audience_member_ids);
ALTER TABLE prayer_requests DISABLE ROW LEVEL SECURITY;


-- ── 2. prayer_list_items ────────────────────────────────────────────────────
-- A member's personal prayer list. source: 'saved' (from the feed),
-- 'eolo' (seeded from members.eolo, Wave 3), 'personal' (free-typed).
-- request_id is set only for 'saved' items (links back to the source request).
-- status: 'praying' | 'answered' | 'removed'
CREATE TABLE IF NOT EXISTS prayer_list_items (
    id           uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    member_id    uuid        NOT NULL REFERENCES members(id),
    request_id   uuid        REFERENCES prayer_requests(id),
    source       text        NOT NULL DEFAULT 'saved'
                             CHECK (source IN ('saved','eolo','personal')),
    title        text,
    body         text,
    status       text        NOT NULL DEFAULT 'praying'
                             CHECK (status IN ('praying','answered','removed')),
    answered_at  timestamptz,
    answer_note  text,
    created_at   timestamptz NOT NULL DEFAULT now(),
    church_id    uuid        REFERENCES churches(id)
);
CREATE INDEX IF NOT EXISTS idx_prayer_list_items_member   ON prayer_list_items(member_id);
CREATE INDEX IF NOT EXISTS idx_prayer_list_items_request  ON prayer_list_items(request_id);
CREATE INDEX IF NOT EXISTS idx_prayer_list_items_status   ON prayer_list_items(status);
CREATE INDEX IF NOT EXISTS idx_prayer_list_items_church_id ON prayer_list_items(church_id);
-- Partial-UNIQUE: a member can save any given request only once (NULL request_id
-- rows — personal/eolo items — are exempt, so a member can have many of those).
CREATE UNIQUE INDEX IF NOT EXISTS uq_prayer_list_items_member_request
    ON prayer_list_items(member_id, request_id) WHERE request_id IS NOT NULL;
ALTER TABLE prayer_list_items DISABLE ROW LEVEL SECURITY;


-- ── 3. prayer_list_opens ────────────────────────────────────────────────────
-- One row each time a member opens "My Prayer List". A lightweight engagement
-- signal for the silent SVI (Wave 4). No body — just who + when.
CREATE TABLE IF NOT EXISTS prayer_list_opens (
    id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    member_id  uuid        NOT NULL REFERENCES members(id),
    opened_at  timestamptz NOT NULL DEFAULT now(),
    church_id  uuid        REFERENCES churches(id)
);
CREATE INDEX IF NOT EXISTS idx_prayer_list_opens_member    ON prayer_list_opens(member_id);
CREATE INDEX IF NOT EXISTS idx_prayer_list_opens_opened    ON prayer_list_opens(opened_at DESC);
CREATE INDEX IF NOT EXISTS idx_prayer_list_opens_church_id ON prayer_list_opens(church_id);
ALTER TABLE prayer_list_opens DISABLE ROW LEVEL SECURITY;


-- ── 4. prayer_intercessions ─────────────────────────────────────────────────
-- A "prayed for this" tap on a request (Wave 2). Encouragement only — the
-- requester sees a DISTINCT-member count ("N praying"), never per-person points
-- or a leaderboard. Repeated taps are allowed (each row = one act of prayer);
-- the read layer de-dups by member for the visible count.
CREATE TABLE IF NOT EXISTS prayer_intercessions (
    id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id  uuid        NOT NULL REFERENCES prayer_requests(id),
    member_id   uuid        NOT NULL REFERENCES members(id),
    prayed_at   timestamptz NOT NULL DEFAULT now(),
    church_id   uuid        REFERENCES churches(id)
);
CREATE INDEX IF NOT EXISTS idx_prayer_intercessions_request   ON prayer_intercessions(request_id);
CREATE INDEX IF NOT EXISTS idx_prayer_intercessions_member    ON prayer_intercessions(member_id);
CREATE INDEX IF NOT EXISTS idx_prayer_intercessions_req_mem   ON prayer_intercessions(request_id, member_id);
CREATE INDEX IF NOT EXISTS idx_prayer_intercessions_church_id ON prayer_intercessions(church_id);
ALTER TABLE prayer_intercessions DISABLE ROW LEVEL SECURITY;


-- ============================================================================
-- 5. VERIFY (read-only). Supabase shows only the LAST result grid — highlight
--    + run each query individually.
-- ============================================================================

-- 5a. All four tables exist (expect 4 rows):
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('prayer_requests','prayer_list_items','prayer_list_opens','prayer_intercessions')
ORDER BY table_name;

-- 5b. church_id present on all four (expect 4 rows, has_church_id = true):
SELECT table_name, bool_or(column_name = 'church_id') AS has_church_id
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('prayer_requests','prayer_list_items','prayer_list_opens','prayer_intercessions')
GROUP BY table_name
ORDER BY table_name;

-- 5c. The partial-unique index exists (expect 1 row):
SELECT indexname FROM pg_indexes
WHERE schemaname = 'public' AND indexname = 'uq_prayer_list_items_member_request';

-- 5d. RLS disabled on all four (expect relrowsecurity = false for each):
SELECT relname, relrowsecurity
FROM pg_class
WHERE relname IN ('prayer_requests','prayer_list_items','prayer_list_opens','prayer_intercessions')
ORDER BY relname;

-- ============================================================================
-- END 003_prayer_wave1.sql
-- ============================================================================
