# TENANCY_AUDIT.md — Multi-Tenant Migration Scope Audit (read-only)

**Date:** 2026-06-04 · **Scope:** read-only investigation. **No code, schema, or config was changed.**
**Goal:** map what it would take to run *many churches on one app + one Supabase database*.
**Sources:** `multiply-schema.json` (dump `generated_at: 2026-06-03T23:24:23Z`, 50 tables + 9 views, 790 columns), repo `*.html` / `*.js`, `CLAUDE.md`, `HANDOFF.md`, `MULTIPLY_INVARIANTS.md`.

> **Caveat (Inv #124 / CLAUDE.md):** `schema.json` can lag the live DB. Every claim below that rests only on the repo is tagged **`VERIFY against live DB`**. There are **no `.sql` files in the repo** — all migrations were run directly in the Supabase SQL editor (Inv #10), so DDL/RLS/policy truth is *not* in version control and must be confirmed live.

---

## 1. Table inventory & tenancy classification

50 base tables (+ 9 views, which inherit their base tables' scope, + 1 `_backup_*` table). No table currently has a `church_id` / `tenant_id` / `org_id` column — **every PER-CHURCH table below would need one added** (or a join table). `members` is the natural tenancy anchor: most operational tables carry `member_id` and FK to `members`.

**Counts:** PER-CHURCH **39** · GLOBAL/SHARED **7** · UNSURE **4** · (views 9, scope-inherited).

### PER-CHURCH (39) — holds one church's data → needs a church_id
`members` (anchor, 222 rows), `attendance` (2878), `absence_notices`, `announcements`, `announcement_acks`, `announcement_retraction_dismissals`, `attendance_self_attest_log`, `cohorts`, `cohort_members`, `cohort_lesson_unlocks`, `pipeline_lesson_grants`, `debrief_records`, `diagnostic_results`, `interventions`, `discipler_change_log`, `transfers`, `notifications`, `leader_sessions`, `profile_tokens`, `view_log`, `svi_snapshots` (619), `preachers`, `wednesday_preaching`, `preaching_swap_requests`, `sermons`, `ministries`, `ministry_roles`, `ministry_rosters`, `ministry_roster_members`, `ministry_intake`, `devotional_reflections`, `library_progress`, `library_chapter_progress`, `library_quiz_attempts`, `btli_quiz_attempts`, `usbong_quiz_attempts`, **`gifts_diagnostic`** (50), **`member_profiles`** (297), `_backup_members_diag_zone_2026_05_06`.

- **`ministries` / `ministry_roles` / `ministry_rosters`** classed PER-CHURCH (each church runs its own ministry teams). If churches were meant to share a *ministry-type template*, these move toward UNSURE — flag for the Phase-0 call.
- **`sermons`** is per-church content but currently 0 rows — same content-vs-shared question as `devotionals` (see UNSURE).

### GLOBAL/SHARED (7) — curriculum / quiz catalog all churches could share
`pipeline_lessons` (12 rows — the lesson curriculum), `library_resources` (0), `library_chapters`, `library_quizzes`, `btli_quizzes` (7), `usbong_quizzes` (0), `cohort_programs` (the BTLI/Usbong program/track catalog).
→ These are *definitions* (lessons, quiz questions, programs). A shared library is plausible **only if** all churches teach identical curriculum; if a church can customize/author lessons, these become per-church or need a `church_id IS NULL = global, else override` pattern. See §6 and §7.

### UNSURE (4) — explain
- **`devotionals`** (52 rows) — daily devotional *content*. Could be one shared devotional library OR per-church authored (Rosehill authors its own via `devotional_admin.html`). Member responses live in the separate PER-CHURCH `devotional_reflections`.
- **`system_settings`** (single-row config: `weights, thresholds, zones, interventions, pipeline, fats, meta`) — a platform-wide default OR per-church tunable config. Pastor edits SVI weights in-app, which argues per-church.
- **`svi_metrics`** / **`svi_weight_profiles`** — SVI scoring catalog + weight profiles. Currently RLS-enabled in the dump (see §5). Platform default vs per-church override is a real decision; the in-app SVI Weights editor (Inv #119) suggests per-church tuning.

### ⚠️ Referenced-but-absent table
- **`lc_groups`** is queried in `member_tool.html` (`db.from('lc_groups')`) but **does not appear in `schema.json`**. Either schema-lag (Inv #124) or a renamed/removed object. **VERIFY against live DB** — and classify (likely PER-CHURCH lookup) once confirmed.

---

## 2. Supabase query surface (the church-scoping work)

One singleton client (`db = getDB()` in `multiply_shared.js`, anon key). **441 `db.from(` calls** across the app (plus 9 `sb.from(` and 4 `supabase.from(` in older/debug/lesson files, and 2 `storage.from(` for the `avatars` bucket). Verb totals (fixed-string, repo-wide): **`.select` 351 · `.update` 117 · `.insert` 66 · `.delete` 43 · `.upsert` 14**. (`.from` raw count 580 includes 40 `Array.from`.)

Every one of these is a candidate site that would need a `church_id` predicate (or RLS doing it server-side). Top files by DB-call volume and the tables they touch:

| File | `from()` calls | Tables hit (top) |
|---|---|---|
| `multiply_dashboard.html` | 139 | members(19), system_settings(12), library_chapters(10), ministries(8), library_resources/quizzes(7), cohort_members(7), announcements(7), cohorts(6), pipeline_lessons(5), cohort_programs(5), sermons, pipeline_lesson_grants, notifications, diagnostic_results, gifts_diagnostic, member_profiles … (28 distinct) |
| `lc_leader_tool.html` | 63 | attendance(19), members(9), cohort_members(6), announcements(6), announcement_acks(5), cohorts(4), preachers(2), ministries(2), absence_notices(2), gifts_diagnostic … |
| `member_tool.html` | 58 | attendance(13), members(10), library_progress(6), library_quiz_attempts(4), devotional_reflections(4), devotionals(3), announcements, absence_notices, **lc_groups(1)**, member_profiles … |
| `multiply_shared.js` | 46 | members(14), transfers(9), wednesday_preaching(7), preaching_swap_requests(5), svi_snapshots(2), cohorts, cohort_members, cohort_lesson_unlocks, pipeline_lessons, leader_sessions, attendance, view_log |
| `preaching_admin.html` | 31 | wednesday_preaching(18), preachers(9), preaching_swap_requests(3), members(1) |
| `multiply_shared (7).js` | 17 | (stale dupe of shared.js — **VERIFY / likely should be removed**) |
| `facilitator_debrief_guide.html` | 13 | debrief_records(6), members(3), notifications(2), discipler_change_log, diagnostic_results |
| `btli_quiz_admin.html` | 9 | btli_quizzes(6), members(2), btli_quiz_attempts |
| `attendance_schema_debugger.html` | 7 | (debug tool) |
| `devotional_admin.html` | 6 | devotionals(6) |
| `member_attendance_report.html` | 5 | members / attendance |
| `leader_login.html` | 5 | members(3), leader_sessions(2) |
| `member_login.html` | 3 | members(3) |

Remaining ~20 files (`spiritual_gifts_diagnostic`, `profile_results_viewer`, `preaching_calendar`, `lc_member_report`, `lcg_pulse_report`, `lc_attendance_report`, `strengths_profile`, `disc_profile`, `love_language`, `enneagram_profile`, `conflict_style_profile`, `salvation_assurance_diagnostic`, `ministry_recommender`, `intervention_tracker`, `transfer_management`, `attendance_admin`, `lesson_quiz_editor`, `multiply_reports.js`, etc.) each carry 1–4 calls.

### Existing scope helpers (church-scope layers on top of these)
- **`makeLeaderScope(getMembers)`** — defined in `multiply_shared.js:169`; **7 references**. Views: `disciples` / `tree` (discipler-graph descendants) / `ministry` / `all` (pastor). Sensitivity tiers: `public` / `pastoral` / `sensitive` / `pastor`. **Self-described as UI-only** (see §3 quote).
- **`_scopedMembers(...)`** — **4 references** (report/tool helpers that exclude `is_test_member` + `is_external_user`, Inv #6/#58).
- **`leaderLevel`-based gating** — **64 references**; cross-LCG visibility = `leaderLevel >= 3`; pastor = level 5 (`PASTOR_LEVEL`). `_isSuperuser()` — **6 references** (Inv #144). `memberLevel` — 9. `share_with_lc` — 14 (member-visibility flag).

> Church-scope is **orthogonal** to all of the above: today every helper assumes a single church. A church boundary must wrap *outside* the leader/level/ministry scope (a leader's "tree" must never cross churches).

---

## 3. Auth & session surface (critical)

**Two independent client-side session systems, both in `sessionStorage`, both gated by the shared anon key. There is no server-side identity.**

### Leader session
- Key: **`multiply_leader_session`** (`SESSION_KEY`, `multiply_shared.js:38`).
- `getValidSession()` (`:61`) — reads sessionStorage, requires `leaderId` + unexpired `expiresAt` + `leaderLevel >= 2`. Pure client-side check.
- `gateOrRedirect(loginUrl)` (`:77`) — sets `window.LEADER`, else clears + `location.replace('leader_login.html')`.
- `logoutLeader()` (`:89`) — marks `leader_sessions.ended_at` in DB (audit only), clears storage.
- DB audit table: **`leader_sessions`** (`leader_id, expires_at, ended_at, ip_hint, user_agent_hint`).

### Member session (MMT)
- Key: **`multiply_member_session`** (`MEMBER_SESSION_KEY`, `:39`) — separate so one device can host both a leader and a member.
- `getValidMemberSession()` (`:118`) / `gateMemberOrRedirect()` (`:134`) / `logoutMember()` (`:148`). Shape: `{ memberId, memberName, memberLevel, memberRole, memberLcGroup, memberDisciplerName, expiresAt, sessionStart }`. **No member DB session table** (comment at `:146`).

### Login / PIN
- `leader_login.html` and `member_login.html` both authenticate by querying **`members`** by name and verifying **`member_pin_hash`** via a `verifyPin` helper (`leader_login.html:472`, `member_login.html:462`; hashes also written from `multiply_dashboard.html:1627/1705` and `lc_leader_tool.html:2832/2866`). PIN is stored as `member_pin_hash` on `members` (`member_pin_set_at`, `member_last_login`, `leader_last_login`).

### Supabase anon key
- Hardcoded **once** in `multiply_shared.js:35–36` (`SB_URL` + `SB_KEY`, role `anon`, exp 2092) and re-exported at `:3028`.
- The project URL `tirzeikbflolaclgtket.supabase.co` and/or anon key are **referenced in 25 files** (lesson pages, profile/diagnostic tools, login pages each create their own client). **VERIFY against live DB** that no `service_role` key is present (grep found none — consistent with Inv #10/#5).

### What an authenticated, church-scoped session would have to replace/augment
The current model's own words (`multiply_shared.js:166–168`):
> *"This is UI scoping only. RLS is the proper fix … Phase 1 protects against accidental exposure by honest leaders; it does not stop a determined DevTools user."*

That single sentence is the crux of multi-tenancy: **a shared anon key + client-side-only scoping means any user with DevTools can read the entire database.** With one church that is "honest-leader" containment; with many churches it is a cross-tenant data-exposure hole. A church-scoped session would have to carry a verified `church_id` that the **server** (RLS / Edge Function / authenticated role), not the browser, binds to every query.

### Open questions (map only — no solution proposed)
1. Does login become real Supabase Auth (JWT with a `church_id` claim) or stay custom-PIN with a server-side gate?
2. How is `church_id` proven to the DB so it can't be spoofed client-side (RLS predicate on a JWT claim vs. anon key)?
3. Name+PIN login currently scans **all** `members` — across churches names collide; login must first resolve a church (subdomain? church picker? per-church URL?).
4. `leader_sessions` is leader-only; do members get a parallel audited session under multi-tenant?
5. The anon key is duplicated across 25 files — single source of truth before any key/role change?
6. Do `?me=` URL fallbacks (preaching calendar, Inv #149) leak identity across church boundaries?

---

## 4. Hardcoded church-specific values (must become per-church config)

| Cluster | Where (file:count / line) | Notes |
|---|---|---|
| **Church name "Rosehill"** | `multiply_dashboard.html`(13), `member_tool.html`(5), `multiply_member_dashboard.html`(2), `member_self_edit.html`(2), `member_login.html`(2, incl. footer `:294` "Rosehill Christian Church · MULTIPLY Pipeline" and `:193`), `multiply_reports.js`(2), `lc_attendance_report.html`(2), `transfer_management`, `mlt_manual`, `ministry_intake_form`, `leader_login`, `index.html`, `bulk_send_links`, + many `*_profile`/diagnostic pages (1 each), + **14 files under `lessons/`** | ~40+ files. `multiply_shared.js`'s 2 hits are only invariant-comment references (Inv #46), not runtime strings. |
| **Timezone (Manila / UTC+8)** | `lc_leader_tool.html`(6+: `:1646,1656,3241,3397`), `member_tool.html`(8: `:2659,2686,3039,6607,7208…`), `devotional_admin.html:644`, `lc_attendance_report.html:467`, `member_attendance_report.html:523`, `btli101_s1_facilitator.html:122` | Date math assumes Asia/Manila +08:00. Per-church timezone needed. |
| **Brand colors / theme** | palette in `multiply_shared.js` + `multiply_dashboard.html`: `#1a1612, #2a5c40, #1f6b3a, #9a2727, #b25050, #b8882a, #8a5b2e, #4a90e2, #1a4a6b, #8a2040, #7a5800 …` | This reads as the **MULTIPLY app brand** (likely stays app-level), but a per-church logo/accent override is the likely ask. Decision needed: app-brand vs church-brand. |
| **Logo / favicon / manifest** | `icon_*.png`, `favicon.svg`, `icon_dashboard*.svg`, PWA `manifest` (`member_tool.html:7`) | App-level icons today; per-church logo/PWA identity would need parameterizing. |
| **Contact info** | (not found as a distinct hardcoded block — **VERIFY against live DB / per-page footers**) | |
| **Ministry terminology** | repo-wide counts: `BTLI`(590), `EOLO`(544), `LCG`(399), `LCL`(314), `Usbong`(294), `FATS`(26), `GRACE`(22), level names `L0–L5` via `LEVEL_NAMES` (`multiply_shared.js:40`: Pre-Pipeline, Team Member, Leader, Coach, Director, Executive Leader) | This is the **MULTIPLY pipeline vocabulary**, deeply woven in. Likely shared *platform* vocabulary rather than per-church — but if a church renames levels/LCG, this is a large surface. Flag as a product decision, not a quick config. |

**Lesson-HTML branding:** **NOT yet generic.** `grep` finds **0** files under `lessons/` containing "MULTIPLY Pipeline" but **14** containing "Rosehill"; several root-level lesson files (`btli101_s1_*`, `btli1_l6_*`) also carry "Rosehill". The 35 repo-wide "MULTIPLY Pipeline" hits are mostly in root tool/login footers. → Lessons would need a de-Rosehill / templating pass for shared curriculum. **VERIFY** exact strings per lesson file.

---

## 5. RLS status

- **No `.sql` files in the repo** → DDL/policies are not version-controlled; authoritative RLS state is **live-DB only (VERIFY)**.
- **`MULTIPLY_INVARIANTS.md` (Inv #10):** RLS is **platform-wide DISABLED** until "RLS Phase 2"; every `CREATE TABLE` is expected to add `ALTER TABLE … DISABLE ROW LEVEL SECURITY`. `multiply_shared.js:166–168` and `:153` reference an (unversioned) `RLS_PHASE_2.md`.
- **`schema.json` metadata says otherwise for 7 tables** — a discrepancy to resolve live:
  - `rls_enabled = true` (but `rls_forced = false`, and **`policies = null` everywhere**) for: **`interventions`, `ministry_intake`, `svi_metrics`, `svi_snapshots`, `svi_weight_profiles`, `view_log`, `_backup_members_diag_zone_2026_05_06`**.
  - `rls_enabled = false` for the other **43** tables.
  - RLS-enabled + zero policies + not-forced is normally *deny-all for `anon`*, yet `svi_snapshots` holds 619 rows the app reads — so either the dump's RLS flags lag reality (Inv #124) or access goes through a path not seen in the repo. **VERIFY against live DB.**
- **Implication:** multi-tenant isolation almost certainly hinges on turning RLS **on** with a `church_id` predicate bound to a server-trusted claim. Today's posture (RLS off + shared anon key) gives **no** server-side tenant isolation.

---

## 6. Curriculum linkage (informs shared-library vs per-church-copies)

Linkage fields and their reach (repo-wide reference counts): `pipeline_level`(215), `course_code`(143), `program_id`(55), `lesson_id`(50), `btli_course_code`(25), `usbong_course_code`(17), `category`(70).

- **Programs → cohorts → members:** `cohort_programs` (catalog; `category`, `pipeline_level`, `btli_course_code`, `usbong_course_code`) → `cohorts.program_id` → `cohort_members`. Cohorts/members are PER-CHURCH; the *program definition* is the shared/global candidate.
- **Lesson visibility vs lock (Model X, Inv #84/#85):** visibility = enrollment via **`pipeline_lesson_grants`** (`lesson_id, cohort_id, program_id, member_id`); lock = **`cohort_lesson_unlocks`** (per-batch). Both PER-CHURCH; they *point at* the shared `pipeline_lessons` catalog.
- **Quizzes:** `btli_quizzes` / `usbong_quizzes` keyed by `course_code` + `lesson_number` (+ `lesson_id`, `attendance_event_name_pattern`); attempts (`*_quiz_attempts`) are PER-CHURCH. `library_quizzes` FK `resource_id`/`chapter_id` into the library catalog.
- **Library:** `library_resources` → `library_chapters` → `library_quizzes` (catalog, GLOBAL candidate); `library_progress` / `library_chapter_progress` / `library_quiz_attempts` (PER-CHURCH).
- **Lesson files on disk:** organized under slugged folders (`lessons/btli101_xrw5fg/…`, `lessons/usbong_wm32x9/…`) plus root copies — static HTML, not DB-linked except by `course_code`/`lesson_number` convention.

→ **Decision shape:** a shared curriculum/library is feasible because attempts/progress/grants are already separated from definitions. The blocker is whether a church may *customize* lessons/quizzes (then definitions need a `church_id IS NULL` global-vs-override pattern) and the de-Rosehill lesson pass from §4.

---

## 7. Open decisions for Phase 0 (questions, not answers)

1. **Auth & tenant proof:** Real Supabase Auth (JWT with a server-trusted `church_id` claim) vs. keep custom name+PIN — and how is `church_id` made unspoofable given today's shared anon key + client-only scoping (`shared.js:166`)?
2. **Tenant resolution at login:** subdomain per church / church picker / per-church URL? (Name+PIN currently scans all `members`; names collide across churches.)
3. **RLS turn-on:** Does Phase 0 flip RLS from platform-disabled (Inv #10) to `church_id`-scoped policies on all 39 PER-CHURCH tables — and reconcile the 7 tables the dump already marks `rls_enabled` (§5)?
4. **Shared vs per-church curriculum:** Are `pipeline_lessons`, `library_*`, `btli_quizzes`, `usbong_quizzes`, `cohort_programs` one shared catalog, or can a church fork/author its own (global-default + per-church-override)?
5. **UNSURE-table calls:** `system_settings`, `svi_metrics`, `svi_weight_profiles` (platform default vs per-church tuned — the in-app SVI editor argues per-church); `devotionals`/`sermons` (shared content library vs per-church authored); `ministries`/`ministry_roles`/`ministry_rosters` (per-church instances vs shared template).
6. **Branding scope:** Per-church name + logo + timezone (clearly yes) vs. per-church *theme colors* and *pipeline vocabulary* (LCG/LCL/level names/GRACE/EOLO/FATS) — app-brand or church-brand? Includes a de-Rosehill pass on lesson HTML (§4).
7. **`church_id` carrier:** new column on each PER-CHURCH table vs. a `members.church_id` joined everywhere; and how the `makeLeaderScope` discipler-tree is fenced so it can never cross a church boundary.
8. **Schema-truth & cleanup:** resolve `lc_groups` (referenced, absent from schema), the stale `multiply_shared (7).js` dupe, and the single-source anon key before any tenant work — and re-dump `schema.json` from live (Inv #124).

---

*Read-only audit. Nothing in the platform was modified. All live-DB-dependent claims tagged `VERIFY against live DB`.*
