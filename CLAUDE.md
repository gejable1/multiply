# CLAUDE.md — MULTIPLY Discipleship Pipeline

Project memory for Claude Code. **Keep this short.** When you get something wrong and the
Pastor corrects you, add a one-line rule here so it never repeats. Detailed rules live in
`MULTIPLY_INVARIANTS.md`; current state lives in `HANDOFF.md`.

## What this is
A custom web platform for **Rosehill Christian Church** (Pastor Gerry Limoso, ~170 members,
Manila UTC+8) — a 5-level discipleship pipeline (Pre-Pipeline/L0 → L5 Pastor). **Static
HTML/JS on GitHub Pages + Supabase.** No framework, no build step — vanilla JS, one shared module.

- Repo: `github.com/gejable1/multiply` → deploys to `gejable1.github.io/multiply` (Pages auto-deploys on push to `main`).
- Supabase project `tirzeikbflolaclgtket`; the client uses the public anon key (already in code).

## Read these FIRST, every session (they're in the repo)
- **`HANDOFF.md`** — current state, what shipped last, and the PENDING list. Start here.
- **`MULTIPLY_INVARIANTS.md`** — 150 hard rules (canonical record). Don't violate; add new ones when you establish a rule.
- `GRACE_PATHWAY.md`, `MULTIPLY_PIPELINE_DIAGRAM.md` — ministry model + vocabulary.
- `BTLI1_LESSON_MAP.md` — read before ANY BTLI lesson build.
- `schema.json` — read before writing ANY SQL/seed. It can lag the live DB — inspect actual stored payloads when unsure.

## Core files
- `multiply_shared.js` — shared module (sessions, dates, SVI, preaching, swap modal, etc.). Loaded by every tool as `multiply_shared.js?v=N` (**currently v=4**).
- `multiply_dashboard.html` (MD, Pastor) · `lc_leader_tool.html` (MLT, LC leaders) · `member_tool.html` (MMT, members) · `preaching_calendar.html`
- Reports: `lc_attendance_report.html`, `lc_member_report.html`, `lcg_pulse_report.html`, `member_attendance_report.html`
- Assessments: `*_diagnostic.html` / `*_profile.html` (Spiritual Gifts, Salvation, DISC, Enneagram, Love Language, Strengths, Conflict Style).

## Non-negotiable rules (the ones that bite — full set in INVARIANTS)
1. **Read the current/deployed file before editing it. Never edit from memory.** (#56/#126)
2. **`node --check` all JS before shipping.** No new logic without a truth-table/harness. Fail-closed on every error path. (#105)
3. **These files are pure LF.** Never introduce CRLF; splice anchors use `\n`.
4. **`?v=` bump-together:** when `multiply_shared.js` changes, bump `?v=N → N+1` across **ALL** HTML that load it, in one commit. Pages/PWA cache hard — always bump + hard-refresh. (#138)
5. **SQL stays human-gated.** Write idempotent SQL (`WHERE NOT EXISTS` / `ON CONFLICT`); the **Pastor** runs it in the Supabase SQL editor. Do NOT run migrations or use a service-role key. Every `CREATE TABLE` adds `ALTER TABLE … DISABLE ROW LEVEL SECURITY;` until RLS Phase 2. (#10)
6. **Reports exclude** test + guests: `is_test_member = false AND is_external_user = false`. Use `_scopedMembers()` helpers, never `STATE.members` directly; cross-LCG visibility = `leaderLevel >= 3`.
7. **Assessments:** Spiritual Gifts → `gifts_diagnostic`; all others → `member_profiles`. Any "all assessments" query merges BOTH. Standard UI: bilingual EN/TL pills, font slider, auto-save, PDF export (model on `salvation_assurance_diagnostic.html`).
8. **Model X (#84/#85):** lesson visibility = enrollment (grant to PROGRAM); lock = `cohort_lesson_unlocks` (per-batch, participants only); a "live" cohort = `status IN ('active','forming')`.
9. **Preaching (#146–#149):** derive Sun/Wed from the `preach_date` **weekday**, not `service_type`. The swap modal is `MultiplyShared.preaching.openSwapRequest` (one source; MMT/MLT/calendar are thin wrappers). Sessions live in **sessionStorage** (use `getValidSession`/`getValidMemberSession`), not localStorage.
10. **AI surfaces are conversation-starters, not verdicts** — soft framing, no auto-alerts.
11. **PPTX is blind without rendering** — LibreOffice → PDF → PNG inspect before declaring a deck done. (#82)

## Workflow
- Propose design/metadata → **Pastor confirms** → build → verify (`node --check` + harness + browser) → `git commit` + `push`.
- BTLI lesson builds: lock metadata first (memory verse, character anchor, competence anchor, GRACE stage, 5-movement flow), then build all 8 deliverables (participant/facilitator/intern HTML, slides HTML, PPTX, quiz SQL, library SQL, smoke test). Use deployed L(N-1) as the template to avoid drift.
- **Session close:** when the Pastor types `m.md`, regenerate `HANDOFF.md` + `MULTIPLY_INVARIANTS.md` (new invariants, session-completed block, refreshed PENDING list), then commit.
- Shortcuts: `scc` = show clickable choices for that turn only · `linfo` = lesson admin summary (Aim, Scriptures, Duration first) · `fiy` = rebuild the current file and ship without confirmation.

## Deploy
- `git add -A && git commit -m "…" && git push` → Pages auto-deploys (~1 min). Then **hard-refresh / relaunch the PWA**.
- The Pastor smoke-tests on his **phone** (PWA, live Supabase) — that step is his, not yours.

## Communication
Address him as **"kapatid."** Taglish welcome. He's terse ("go", "agree to all"). Default output =
**numbered prose**, minimal clickable UI, **no wrap-up encouragement** ("let me know if…"). Flag
design trade-offs as numbered options before building; accept corrections without re-arguing.

## When asked "what's next?"
Refresh from `HANDOFF.md`'s PENDING list — don't brainstorm new scope (#43).
**Top item now: BTLI L12 — Understanding My Unique Design** (UNLAD-L2, Eph 2:10, the
assessment-battery lesson) — needs the UNLAD-L2 scan. Also pending: bump the 4 report HTMLs to `?v=4`.
