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
- `multiply-schema.json` — read before writing ANY SQL/seed. **LOCAL-only snapshot** of the live DB (gitignored, never pushed); it can lag the live DB — regenerate it from Supabase when the schema changes, and inspect actual stored payloads when unsure.

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
6. **Kind-relative scoping (#164):** `memberKind` = test (wins over guest) / guest / real vs the **viewer's** kind (own `members` row, never the session shim). Operations: real viewer sees all kinds **badged**; test/guest viewers see own kind only. Statistics/counts: `memberKind === viewerKind` only. Report HTMLs keep the strict `is_test_member = false AND is_external_user = false` (#58) until Phase B makes them viewer-aware. Use `_scopedMembers()`/`liveMembers()` helpers, never raw `members`; cross-LCG visibility = `leaderLevel >= 3`.
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

## Working across machines (desktop ↔ laptop)
The repo is the single source of truth — clone it on any machine, any drive/path (nothing hardcodes the path). **Discipline: `git pull` before you start; commit + `push` before you switch machines.** Push before you stand up, pull before you sit down. If a push is rejected, `git pull --rebase` then push.
- **Won't travel (by design):** `multiply-schema.json` is **gitignored** (local-only DB snapshot, #124) — regenerate it from Supabase on the other machine when needed. `CC_SETUP.md` is untracked.
- **Keep the working copy on a plain LOCAL drive — not a cloud-synced folder** (OneDrive/Dropbox/Google Drive). A background sync can overwrite files with a stale cached copy mid-session; let **git** be the only sync. (If on-disk docs ever look reverted while `git log`/GitHub are correct, `git restore <file>` from HEAD fixes it — HEAD + origin are authoritative.)
- `.gitattributes` (#151) enforces LF on every machine — no CRLF surprises.

## Communication
Address him as **"kapatid."** Taglish welcome. He's terse ("go", "agree to all"). Default output =
**numbered prose**, minimal clickable UI, **no wrap-up encouragement** ("let me know if…"). Flag
design trade-offs as numbered options before building; accept corrections without re-arguing.

## When asked "what's next?"
Refresh from `HANDOFF.md`'s PENDING list — don't brainstorm new scope (#43).
**Top item now: BTLI L12 — Understanding My Unique Design** (UNLAD-L2, Eph 2:10, the
assessment-battery lesson) — needs the UNLAD-L2 scan. Also live but waiting on the Pastor's
go: **Prayer/Panalangin Waves 2–4** (W1 landed S35, Inv #165) and **kind-mirroring Phase B**
(reports viewer-aware + centralize helpers → bump `?v=`). (The 4 report HTMLs are already at
`?v=4` — that lockstep is done.)

## Cloud vs desktop sessions
Cloud (claude.ai) sessions on this repo are **read-only** — git push 403, MCP 403, no signing key.
Ship from a cloud session via `git format-patch` → apply + push from the desktop clone (the preferred
push surface). Durable fix pending: grant the Claude GitHub App write on `gejable1/multiply`. Always
**pull-first; ask before push.**
