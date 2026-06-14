# MULTIPLY — HANDOFF.md

**Last updated:** June 14, 2026 (Session 35 — **Prayer / Panalangin Wave 1**: a member-facing prayer-request board on **MMT**. `migrations/003_prayer_wave1.sql` (run + verified in Supabase, `verify_003` `all_ok:true`; rollback on standby, NOT run) creates **4 per-church tables** — `prayer_requests` / `prayer_list_items` / `prayer_list_opens` / `intercessions` (the last serves Waves 2–4). `member_tool.html`: Home Prayer CTA, compose modal (4 audiences — `lcg` / `individuals` / `all` / `discipler_pastor`), kind-scoped feed, save-to-list, My Prayer List (logs opens), mark-answered. Bilingual, **no points/score/badge UI**. `individuals` picker = full **same-kind** church roster (reach outside the LCG); `discipler_pastor` pastor detection keys on `pipeline_level >= 5`, degrades to discipler-only in a guest/test bubble. Kind bubble = Inv #164, helpers local to the prayer block (Phase B: centralize `sameKind` in `multiply_shared.js`). No `multiply_shared.js` change → `?v=4`. **1 invariant added: #165. Count now 165.** Waves W2 (encouragement) / W3 (reminders + auto-expiry) / W4 (silent SVI prayer category) are **HELD until Pastor's go**. Landed via laptop-cloud `format-patch` → applied + pushed from the desktop. Prior this period: **S34** kind-mirroring Phase A (`fc586a1`, Inv #164). Was: Session 33 — **guest/test containment + self-attest past-date + viewer exit**: (1) members **created by a guest/test user inherit that flag** in both insert paths — MD Add Member + MLT `saveNewMember` — so guest-added members never contaminate Rosehill stats (`4c48e83`, Inv #162); (2) **self-attest past-date** — correcting an OLD leader-marked absence now works at **any age** (Option A: window check moved below the dup check; new claims still 7-day-gated) + a native date picker (`b4b792f`, Inv #163, extends #152); (3) **profile_results_viewer** got an always-visible **✕ Close** button that returns to the firing page — tablet/PWA users were stuck (`58944e9`, applies Inv #12). No `multiply_shared.js` change → `?v=4`. **2 invariants added: #162–#163. Count now 163.** Still offered, not done: one-time **backfill** to flag pre-existing guest-added members.)
**Pastor:** Gerry Limoso · Rosehill Christian Church · ~170 members · Manila UTC+8
**System launch date:** May 1, 2026 (production live ~1 month)
**Repo:** github.com/gejable1/multiply (deployed to gejable1.github.io/multiply)
**Supabase project:** tirzeikbflolaclgtket
**Dev surface (NEW — June 4, 2026):** Development has **migrated to Claude Code**. The canonical dev surface is now this **local git clone** — edit here, `git push` to GitHub, and **Pages auto-deploys**. `CLAUDE.md` is the Claude Code project-memory file (read it alongside this HANDOFF each session). The old **manual download / upload-to-GitHub** workflow is **retired**.

---

## 🎯 Jumpstart prompt for next session

> *"Hi Claude, kapatid — fresh session. Please read `HANDOFF.md`, `MULTIPLY_INVARIANTS.md`, `GRACE_PATHWAY.md`, `MULTIPLY_PIPELINE_DIAGRAM.md`, and `BTLI1_LESSON_MAP.md` first. **Session 35 — Prayer / Panalangin Wave 1** (MMT-only): `migrations/003_prayer_wave1.sql` (run + verified, `all_ok:true`) created 4 per-church tables (`prayer_requests` / `prayer_list_items` / `prayer_list_opens` / `intercessions`); `member_tool.html` got the Home Prayer CTA, compose (4 audiences `lcg`/`individuals`/`all`/`discipler_pastor`), kind-scoped feed, save-to-list, My Prayer List, mark-answered — bilingual, **no points UI**, kind-bubbled per Inv #164 (helpers local to the prayer block; Phase B centralizes `sameKind` in `multiply_shared.js`). **Inv #165**, no shared.js change → `?v=4`. **Waves W2/W3/W4 are HELD until your go.** Prior: **S34** kind-mirroring Phase A (`fc586a1`, **Inv #164** — a real viewer/Pastor now SEES guest+test members badged; stats never cross-count kinds). Before that: **Session 33 — guest/test containment + self-attest past-date + viewer exit** (no `multiply_shared.js` change): (1) members **created by a guest/test user inherit that flag** — MD Add Member (NEW only: `checkbox OR (isNew && creatorFlag)`) + MLT `saveNewMember` (reads creator's row from DB) — so guest-added members never contaminate Rosehill stats (`4c48e83`, **Inv #162**); forward-only (a one-time backfill for pre-existing guest-added members is offered, not done). (2) **self-attest past-date** — correcting an OLD leader-marked absence works at **any age** (Option A: dup-check before the window; brand-new claims stay 7-day-gated) + native `<input type=date>` picker (`b4b792f`, **Inv #163**, extends #152). (3) **profile_results_viewer** ✕ Close button → returns to the firing tab; tablet/PWA users were stuck (`58944e9`, applies **Inv #12**). Prior: **S32** MLT pptx-download + MD roster alphabetize + MD guests-visible (#160–#161); **S29–S31** self-attest present-aware, tenancy Phase 1, attendance_admin, Usbong blank-stem + staff-visibility (#152–#159). **TOP OPEN ITEM: BTLI L12 — Understanding My Unique Design** (UNLAD-L2, Eph 2:10) — needs the **UNLAD-L2 scan**. Next major arc = **multi-tenant Phase 2** (and fold member-creation into one `newMemberDefaults(creator)` that also sets `church_id`). When I ask 'what's next?', refresh from this HANDOFF's pending list (Inv #43). **Session-start reminder: upload the latest deployed file(s) before editing (Inv #56); bump `?v=` after any `multiply_shared.js` deploy."*

---

## ✅ COMPLETED JUNE 14, 2026 — SESSION 35 (Prayer / Panalangin Wave 1 — MMT prayer-request board)

Built on a **read-only laptop cloud session** (push blocked → delivered as `git format-patch`, applied + pushed from the desktop). On `main` (`1b3f2c8` → `2ca3411`). `node --check` clean; 22/22 truth-tables per commit. No `multiply_shared.js` change → `?v=4`. **Inv #165 added → count 165.**

### **1. SQL — 4 per-church tables** (`migrations/003_prayer_wave1.sql`, SHIPPED `1b3f2c8`; **run + verified in Supabase**)
- `prayer_requests` (audience model), `prayer_list_items` (saved-to-list, partial `UNIQUE(member_id,request_id) WHERE request_id NOT NULL`), `prayer_list_opens` (logs My-List opens), `intercessions` (exists for Waves 2–4, unused in W1). Each idempotent, nullable `church_id` + FK + indexes (Inv #153–#156), each ends with `DISABLE ROW LEVEL SECURITY` (Inv #5/#10). **`verify_003` JSON `all_ok:true`.** `003_rollback.sql` on standby (NOT run, Inv #157). `003_verify.sql` folds all checks into one JSON row for the mobile editor.
- **Audience model:** `lcg` (requester's LC group via LCL linkage, Inv #1/#46) · `individuals` (`audience_member_ids uuid[]`, GIN-indexed) · `all` (everyone, still kind-bubbled) · `discipler_pastor` (discipler + any L5 pastor).

### **2. MMT surface** — `member_tool.html` (SHIPPED `c9bf718`, adjustments `6551d65`)
- **Home:** prominent **Prayer / Panalangin** CTA card near the top (light relevance badge; **NO points/score/badge UI**, Pastor's standing intent).
- **Compose modal:** 4 audiences, anonymity **off by default**, category, kind-scoped picklist. **Adjustment `6551d65`:** `individuals` picker opens to the **full same-kind church roster** (reach outside the requester's LCG, per spec; `share_with_lc` opt-outs + self excluded) — replaced the prior circle-only scope. `discipler_pastor` pastor detection now keys on **`pipeline_level >= 5`** (mirrors `_isSuperuser` L5; MMT has none), degrading to **discipler-only** in a guest/test bubble.
- **Feed + lists:** feed of visible requests, **Save-to-list**, **mark-answered** (praise note); **My Prayer List** logs a `prayer_list_opens` row on each open.
- **Kind bubble (Inv #164):** `requesterKind === viewerKind` across audiences/picklist/feed, viewer = the member's own `members` row (Inv #162, never the session shim). Helpers **local to the prayer block**; **Phase B:** centralize `sameKind` in `multiply_shared.js`. Fail-closed; no `!inner` (Inv #38); avatars never blank (#93/#133); bilingual EN+TL; no URL leaks.

### **Waves HELD until Pastor's go** (see PENDING)
- **W2** encouragement: prayed-tap "N praying", praise→celebration feed, notify-on-save, soft care-flag, category filter. **W3** reminders + EOLO seeding + auto-expiry (`expires_at`). **W4** silent SVI prayer category (`count_rows` — invisible to members; gamification stays hidden, SVI factors it). The `intercessions` / `prayer_list_items` / `prayer_list_opens` tables exist for these.

---

## ✅ COMPLETED JUNE 12, 2026 — SESSION 34 (kind-mirroring Phase A — Pastor sees test/guest members)

`multiply_dashboard.html` + `lc_leader_tool.html` (SHIPPED `fc586a1`). `node --check` clean; 28/28 truth-table. No `multiply_shared.js` change → `?v=4`. **Inv #164 added → count 164.**

- **Rule (Inv #164):** each kind (real / test / guest) is a self-contained bubble. **`memberKind`** (test wins over guest) vs **`viewerKind`** read from the viewer's own `members` row (never the session shim, Inv #162). **Operations** (`_scopedMembers`, disciples trees, unassigned pool, all member pickers, attendance lists, All Members): a **real** viewer (Pastor) sees **every** kind with a **kind badge** (🧪 Test / 👤 Guest); test/guest viewers see own-kind only. **Statistics** (`liveMembers` chokepoint, scope counts, KPIs, pipeline/zone/EOLO/alert distributions, MLT home stats, dup-check pool): `memberKind === viewerKind` only — kinds never cross-count.
- **This is what makes the Pastor SEE test users in MD.** Generalizes #6/#58/#160/#162. Report HTMLs keep the strict Inv #58 predicate **until Phase B** (which also centralizes the helpers in `multiply_shared.js` → `?v=` bump).

---

## ✅ COMPLETED JUNE 5, 2026 — SESSION 33 (guest/test inheritance · self-attest past-date · viewer Close button)

Deployed files re-read before editing (Inv #56); `node --check` + truth-tables (Inv #105). No `multiply_shared.js` change → all consumers stay `?v=4`.

### **1. Members created by a guest/test user inherit that flag** (Inv #162) — `multiply_dashboard.html` + `lc_leader_tool.html` (SHIPPED `4c48e83`)
- **Problem (Pastor):** guests (invited pastor-friends) add their own members; those defaulted to Rosehill → contaminated stats, forcing manual deduction. **Fix:** a new member inherits the **creator's** `is_external_user` / `is_test_member`. **MD Add Member** — NEW members only (`eid` falsy): `effIsExternal/effIsTest = checkbox OR (isNew && creatorFlag)`, creator read from the global `members` row for `LEADER.leaderId`; a guest can't create a Rosehill member even by unchecking the box (intended containment); edits keep form/lock logic. **MLT `saveNewMember`** — `currentLeader` is a session shim without the flags, so the creator's row is read from the DB; payload now carries both flags; fail-soft. **6/6** truth-table.
- **Forward-only** (Inv #162): pre-existing guest-added members aren't retroactively flagged — a one-time **backfill SQL** (flag members whose discipler is a guest/test) is **offered, not yet run**. **Phase 2:** consolidate both insert paths into one `newMemberDefaults(creator)` that also sets `church_id`.

### **2. Self-attest PAST-date correction** (Inv #163, extends #152) — `member_tool.html` (SHIPPED `b4b792f`)
- **Option A:** correcting an existing **leader-marked absence** is now allowed at **ANY age** — `_doSaveAttest` runs the **dup check first**, so the absent→present flip returns before the window; `SELF_ATTEST_WINDOW_DAYS` (=7) now gates **brand-new claims only** (just before insert). The picker (`openAttestDatePicker`) gained a native `<input type="date">` (max=today) so any past Sunday/Wednesday is reachable; recent-day quick-picks no longer disabled past the window (save logic decides). **6/6** truth-table.

### **3. profile_results_viewer — always-visible ✕ Close** (applies Inv #12) — `profile_results_viewer.html` (SHIPPED `58944e9`)
- The viewer opens in its own tab (`window.open(_blank)`); tablet/PWA users had **no way back** and got stuck. Added a fixed top-right **✕ Close** (on every view) using the standard self-close: `window.close()` → returns to the exact firing tab (scroll/state preserved); fallbacks = same-host referrer (the firing page) → history → safe home (cross-host referrer ignored). Self-contained file (no shared.js). **5/5** fallback harness.

---

## ✅ COMPLETED JUNE 5, 2026 — SESSION 32 (three quick fixes: MLT attachment download · MD roster alphabetize · MD guests visible)

Deployed files re-read before editing (Inv #56); `node --check` + truth-tables (Inv #105). All `multiply_dashboard.html` / `lc_leader_tool.html` — **no `multiply_shared.js` change → `?v=4` unchanged.**

### **1. MLT "My Lessons" — office/binary attachments download on first click** (Inv #161) — `lc_leader_tool.html` (SHIPPED `28722e2`)
- `_openLessonAttachment` always opened the in-app **iframe viewer**; a `.pptx` can't render there → a **blank page** whose "↗ New tab" link did the real download (two steps). Now `_isDownloadAttachment` routes `.pptx/.ppt/.docx/.xlsx/.odp/.ods/.odt/.key/.zip` to a first-click **download** (`_downloadAttachment`): same-origin (decks live in the repo `lessons/**.pptx` → GitHub Pages) via `<a download>` (no tab); cross-origin via `window.open`. HTML/PDF still preview in the viewer. MMT/MD have no such viewer. **12/12** truth-table.

### **2. MD batch roster alphabetized** — `multiply_dashboard.html` (SHIPPED `aa48d90`, `611a79a`)
- `_coRenderRoster` sorted by status→ROLE; now active-first (then graduated, then withdrew) and **alphabetical by name within each status group** (`aa48d90`). The "Pick a member" add-dropdown is also sorted A→Z (`611a79a`). Pure ordering change.

### **3. MD DISCIPLES tab keeps GUESTS visible** (Inv #160) — `multiply_dashboard.html` (SHIPPED `bccdff6`)
- **Bug:** marking a member as a guest (`is_external_user`) made them vanish from their discipler's MD profile DISCIPLES tab. Root cause: `_disciplesDirect` / `_disciplesTree` / `_getUnassignedMembers` lumped guests with **test fixtures** under `_shouldHideTest` (`m.is_test_member || m.is_external_user`). But guests are **real** pastor-friends test-driving — their relationships are operational and must stay visible; only **statistical reports** exclude guests (their own rule, Inv #6). Fix: those 3 operational filters now hide **test fixtures only**. **Left as-is, flagged:** the main-screen scope-count badges (`updateScopeCounts` 1538) + Pastor "All" via `liveMembers()` still exclude guests (anti-inflation headline counts) — pending pastoral review. **5/5** truth-table.

### **⏸ PAUSED mid-session — self-attest past-date correction** (not started; design decision pending — see PENDING)
- The S29 absent→present self-correction works, but only within `SELF_ATTEST_WINDOW_DAYS = 7` (`member_tool.html`), so **old** leader-marked absences can't be flipped. A date picker already exists (last 14 days) but disables anything >7d. The flip logic (`_doSaveAttest`) is date-agnostic — the only blocker is the window. **Config map:** one constant (`:7282`) enforced at 3 points (`memberSelfAttest` :7800, `openAttestDatePicker` :7858/:7893, `_doSaveAttest` :7941); one code path gates ALL plain events. Awaiting the window-policy call (below) before building.

---

## ✅ COMPLETED JUNE 5, 2026 — SESSION 31 (Usbong quiz visible to batch staff, not just L0)

Continuation after the S30 `m.md`. **Bug:** in MMT, a teacher discipling an Usbong batch saw the **lessons** but not the **quizzes**. Deployed files re-read before editing (Inv #56); `node --check` + truth-table verified (Inv #105).

### **Usbong quiz section gate: L0 → "L0 OR live-batch staff"** (Inv #159) — `member_tool.html` (SHIPPED `076d89b`)
- **Trace:** `renderUsbongQuizzes` hid the Pre-Pipeline quiz section whenever the member's own `pipeline_level !== 0` (the Session-5 L0-only gate) and **returned before** calling `eligibilityForMany`. So **Juan dela Cruz** (L2, **teacher** of "Juan Usbong Disciples") was hidden out — even though `MultiplyShared.usbong.eligibilityFor` already grants him via the staff bypass (`multiply_shared.js:1888`). Live SQL confirmed his teacher enrollment is correctly tagged (`usbong_course_code='Usbong 1'`, cohort `active`, program active) → the **shared eligibility gate was NOT the cause**; the **section-display gate** was. Lessons show because lesson visibility is role/enrollment-based, not level-gated.
- **Fix:** added `_isUsbongStaff(memberId)` (mirrors shared.js `_usbongFetchEnrollments`: active staff `cohort_members` → live cohort `active`/`forming` → active program with a `usbong_course_code`; fails closed) and changed the gate to `if (lvl !== 0 && !(await _isUsbongStaff(...))) hide`. **No `multiply_shared.js` change → consumers stay `?v=4`.**
- **MLT:** swept `lc_leader_tool.html` — its only quiz code is the **attendance picker**; there is **no member-facing quiz-taking section** and no L0 gate, so nothing to change there for this bug.
- **Verified:** `node --check` clean; **11/11** truth-table (Juan teacher→show; exclusions: BTLI-only apprentice, participant, non-live cohort, untagged program, no enrollment; L0 always shows).

---

## ✅ COMPLETED JUNE 5, 2026 — SESSION 30 (Usbong quiz blank-stem fix — tolerant reader + data normalization)

Continuation after the Session-29 `m.md`. **Bug:** Usbong quiz showed **questions blank but choices present**. Root cause = the #125 drift pattern, but on the question **STEM** (the option fix never covered it). Deployed files re-read before editing (Inv #56); `node --check` + truth-table verified (Inv #105).

### **1. Tolerant `_qText` stem accessor** (Inv #158) — `usbong_quiz_player.html` + `btli_quiz_player.html` (SHIPPED `0e5fa20`)
- The players read the stem from raw `q.question_en`/`q.question_tl` (no fallback) at BOTH the render (~633) and answer-review (~905) sites; options already used the tolerant `_optText`, which is why **choices rendered but the stem was blank** (`escapeHtml(null)`→`''`). Live SQL confirmed **Usbong 1 lessons 6–10** store the stem under **`stem_en`/`stem_tl`** (`has_question_en_key=false`); lessons 1–5 are canonical `question_en`.
- Added `_qText(q,lang)` mirroring `_optText`: `question_en ?? stem_en ?? en ?? question` (+ `tl`), applied at all **4 sites** (both forks × render+review). Reader-only, no data touched. **Verified:** `node --check` clean on both; **11/11** truth-table (incl. the exact `stem_en` lesson-6 case + `question_en` precedence). No `multiply_shared.js` change.

### **2. Migration 002 — normalize the data to canonical** (Inv #153/#157) — `migrations/002_normalize_usbong_stems.sql` (+ `002_rollback.sql`) (`d93da27`; **run + verified by the Pastor**)
- The tolerant reader unblocks the players, but `lesson_quiz_editor.html` reads `question_en` raw (lines 827–828) → L6–10 stems were also blank there. **Read-only diagnostic confirmed** every L6–10 question has non-empty `stem_en`/`stem_tl` (8×5 = 40, none missing) — a clean key-rename, no re-authoring. The diagnostic's full-question dump also showed options use bare `{en,tl,correct}` — **left as-is** (tolerated by the players' `_optText` and by the editor's own load/save `label_en⇄en` remap), so the migration touches **only the stem keys**.
- `002` renames `stem_en→question_en` / `stem_tl→question_tl` for **Usbong 1 L6–10**, idempotent (`stem_en`-only CASE + `IS DISTINCT FROM` guard), scoped (lessons 1–5 untouched), ending with the #125 verify-SELECT. **Verify result: all 5 lessons `all_have_question_en=true`, `any_stem_en_left=false`.** `002_rollback.sql` reverses it (question→stem, L6–10). SQL human-gated (Pastor ran it in Supabase; CC holds no service-role key).

### **Net:** Usbong quiz blank-question bug fixed on **both layers** — tolerant readers (drift can never blank a stem again) + normalized data (the editor shows them). Smoke-test: Usbong 1 L6 in the player + `lesson_quiz_editor.html` now show the stems.

---

## ✅ COMPLETED JUNE 5, 2026 — SESSION 29 (self-attest present-aware fix · tenancy Phase 1 foundation · attendance_admin LC-Leader filter + mode toggle)

All logic `node --check`-verified with truth-table harnesses (Inv #105); deployed files re-read before editing (Inv #56/#126). SQL is human-gated — the Pastor ran it in Supabase (Inv #153).

### **1. Self-attest present-aware fix** (Inv #152) — `member_tool.html` (SHIPPED `9306ebc`)
- **Bug:** the "I'M HERE AT SERVICE" pill disable was **present-blind** — `byLeader` fired on ANY leader-logged (non-`self_attest`) row for this week's occurrence, **including `present=false`**. The Pastor logs on-site and marks online members **absent** before they self-report → an online member (e.g. **Dennis Nolasco** `76c7cdd4…`, whose target-date rows were confirmed `present=false, lcl_logged` via live SQL) was **locked out** of self-attesting and shown a misleading "✓ by leader."
- **Diff A (render, ~7470/7561):** added `present` to the `_leaderLoggedSlots` select; `byLeader` now requires `present===true`; new `byLeaderAbsent` → the pill stays **enabled** with an honest **"marked absent — tap if you were here" / "naka-absent — i-tap kung dumalo"** hint (no false ✓).
- **Diff B (save, ~7960):** a tap on a leader-marked-absent slot **corrects** the row → `present=true, source='self_attest', logged_by=member`, updated **by `id`** (safe: **UNIQUE(member_id,event_type,event_date)** confirmed live as `attendance_member_id_event_type_event_date_key`). It then surfaces in the leader's **Pending Confirmations** (✓ Confirm / ✕ Dispute).
- **Verified:** `node --check` clean; **12/12** truth-table. Confirmed the confirm path is real, and that self-attest `present=true` **counts immediately** (no `confirmed_by` gate in reports — confirmation is a trust overlay, not a counting gate). **No `multiply_shared.js` change → stays `?v=4`.**

### **2. Devotional streak — WORKING AS DESIGNED (non-bug; draft rolled back)**
- Reported as a bug ("1-day streak" despite 4 days), investigated, confirmed correct. The streak reads **`attendance`** (`event_type='devotional'`, `present=true`) via `loadDevoStreak`/`computeStreak` in **local Manila** time (UTC boundary ruled out). A **catch-up** entry (the 6/2 devotional done on 6/3) legitimately breaks consecutiveness → **"1-day" is correct**. The exploratory draft was **rolled back via `git restore`** (nothing shipped). **Do not re-investigate.**

### **3. Tenancy Phase 1 — foundation DONE (multi-tenant Option A)** (Inv #153–#157)
- **`migrations/001_add_tenancy.sql`** (`baa0250`) **run by the Pastor in Supabase and verified**: created **`churches`** (RLS disabled), seeded **Rosehill** (`slug='rosehill'`), added **nullable `church_id` + index + FK** to the **40 PER-CHURCH** tables (backfilled to Rosehill) and to **`devotionals`** (no backfill; **NULL = shared**).
  - **Verify 6b:** all **41** `has_church_id=true`. **6c:** all 40 backfilled; `devotionals` **52 NULL / 0 set** (correct); sentinel row 1.
  - **Expected NULL trickle (Inv #155):** 8 high-traffic tables showed a small `null_ct` (announcement_acks 10, attendance 10, leader_sessions 9, devotional_reflections 7, usbong_quiz_attempts 2, cohort_members/member_profiles/profile_tokens 1) = live writes that landed **after** the backfill (app doesn't set `church_id` yet). **Expected, harmless, NOT a failure** (a real failure = whole-table `set_ct=0`).
- **`migrations/001_rollback.sql`** (`d24a6a3`) = emergency undo (41 `DROP COLUMN` + `DROP TABLE churches`, derived from 001, idempotent, **NOT run**). **Free tier → no backups**, so the rollback script is the net (Inv #157).
- Established the versioned **`migrations/`** folder; **SQL stays human-gated** (Pastor runs in Supabase; CC holds no service-role key — Inv #153).

### **4. attendance_admin — LC-Leader filter + edit-modal mode toggle** (SHIPPED `b93d752`) — `attendance_admin.html`
- **Filter:** replaced the free-text "LC Group" search with an **"LC Leader" dropdown** populated from members' **discipler** (LCL, Inv #46) — `lc_group` is mostly null but every member has an LCL; `_loadLclIndex()` builds a `member_id→{LCL id,name}` map and `applyFilters` matches each row by its member's LCL (+ a "No LC leader" option).
- **Edit modal:** added a **Face-to-face / Online** select bound to the existing `attendance.attendance_mode` column (the list already rendered its 🌐 badge; the modal just couldn't set it). Save still stamps `source='pastor_admin'`.
- **Verified:** `node --check` clean; **9/9** truth-table for the LCL filter predicate. **No `multiply_shared.js` change → stays `?v=4`.**

### **Deploy notes for Session 29:** `member_tool.html` + `attendance_admin.html` are live (Pages auto-deploys); hard-refresh / relaunch PWA; phone smoke-test (Inv #31). SQL (`001_add_tenancy.sql`) already run + verified by the Pastor; `001_rollback.sql` is on standby, NOT run.

---

## ✅ OPERATIONAL — JUNE 4, 2026 (Claude Code migration + repo housekeeping)

No platform-code / feature changes — operational + housekeeping only.
- **Added `CLAUDE.md` project memory** for Claude Code (`005dbdb`).
- **Added `.gitattributes`** — `* text=auto eol=lf`, explicit `eol=lf` for `html`/`js`/`ts`/`json`/`md`/`svg`/`css`/`sql`, and `binary` for images/`pptx`/`pdf`/fonts; `git add --renormalize` confirmed the index was already **pure LF** (`39289bb`). See Inv #151.
- **Completed the `?v=4` lockstep** — bumped **ALL** shared.js consumers to `?v=4`: the **4 reports** (`v=2→4`) **plus 8 previously-UNVERSIONED** admin/quiz tools (`attendance_admin`, `btli_quiz_admin`, `btli_quiz_player`, `devotional_admin`, `lesson_quiz_editor`, `preaching_admin`, `transfer_management`, `usbong_quiz_player`) that carried a latent stale-cache risk; left the **self-inlined** `profile_results_viewer.html` alone (it does not load shared.js) (`cc328c4`).
- **Repo cleanup** — removed stale BTLI 101 folders `lessons/btli101` + `lessons/btli101_s1_hrwm68` (`616c072`), and two mistakenly-uploaded dupe files `member_tool (14).html` + `multiply_dashboard0.html` (`8f16665`).

---

## ✅ COMPLETED JUNE 3, 2026 — SESSION 28 (preaching swap + alert overhaul; attendance-save fix; MD bulk-enroll)

All logic `node --check`-verified and jsdom-tested (Inv #105); deployed files re-read before editing (Inv #56/#126). No SQL migrations this session.

### **1. MD batch bulk-enroll** (Inv #145) — `multiply_dashboard.html`
- Cohorts → 👥 Roster modal gained a **"⚡ Bulk add"** button. Intermediate modal: filter **Everyone / By Level** (multi-level checkboxes) **/ By LC Leader** (members whose `discipler_id` = the chosen facilitator; leader not auto-included) → a **name-checklist** (default checked; already-enrolled shown disabled with "✓ in batch"; test members + guests excluded) → role select (default participant) → **➕ Enroll N** = one `cohort_members` array insert. No `canEnroll`/Zone-1 gate (Pastor override, Inv #103); pacing still via Model-X lesson unlocks (#84). Cohort member SELECT widened with `discipler_id, is_facilitator, facilitator_role, is_test_member, is_external_user`. 19-point jsdom test green.

### **2. Preaching weekday-derivation + combined banner** (Inv #146, #147) — `multiply_shared.js`
- `wednesday_preaching` has no reliable `service_type` column, so the old code defaulted everything to "Wednesday." Now the service day (Sun=0…Wed=3) is derived from `new Date(preach_date+'T00:00:00').getDay()`; `service_type` is only an optional override. Sunday=morning, else=evening phrasing.
- `renderReminderBanner` now fetches `getUpcomingAllForMember(memberId, 7)` (dropped `.limit(1)` which hid a same-week second engagement). 1 live → single banner; 2+ → ONE **"Preaching This Week"** banner colored by the nearest, each engagement a row with its own 🔄 Swap, single ✕ dismisses all (`dismiss-all`). 7-day window is intentional. 15-point jsdom test green.

### **3. Consolidated swap-request modal** (Inv #148) — `multiply_shared.js` + MMT/MLT/calendar
- New single source `MultiplyShared.preaching.openSwapRequest(assignmentId, preachDate, requesterMemberId, {bilingual, onSent})` lives beside the banner. **"Swap from" picker** (own upcoming, shown only when 2+; default = tapped) + **"Swap with"** filtered ±6 weeks of the selected FROM (re-filters on FROM change). MMT (`MEMBER.memberId`, bilingual), MLT (`LEADER.leaderId`), and calendar (`onSent` → toast+reload) are now **thin wrappers**; the old page-local duplicates were removed. 20-point jsdom test green.

### **4. Calendar identity fix** (Inv #149) — `preaching_calendar.html` (+ openers)
- Root cause of "no Swap from the calendar": it read **`localStorage`** while the app stores sessions in **`sessionStorage`** → `isMine` always false → no "You", no swap buttons (Pastor's Sundays showed only "Mainstay"). Confirmed via console: both `leaderId`/`memberId` came back `undefined` (a session-less tab / wrong store). Fixed to read the shared session store, match a cell as "mine" against **either** the leader or member id, and accept a **`?me=<id>` URL fallback**. MLT's "Preaching Calendar" card and the banner's "View Calendar" now pass `?me=` (critical for a PWA that opens an external browser where `sessionStorage` doesn't carry). Unit test green.

### **5. Attendance save: batched + immediate feedback** (Inv #150) — `lc_leader_tool.html`
- LC `saveAttendance` had no in-progress button state and did **2 sequential awaited round-trips per member** (40–60 serial calls for a 20–30 roster ⇒ 15–30 s on mobile) — users assumed it had saved and left → no data. Now: **"⏳ Saving…"** disabled button on tap (double-tap-guarded, "✅ Saved!" on finish), and a **batched write** — ONE SELECT for existing rows, ONE bulk INSERT for new rows, parallel UPDATEs for the rest. Preserves the Pre-Pipeline present-only skip (#129) and event_name keying; still avoids DELETE (RLS); failure restores the button to allow retry. `saveMinistryAttendance` already used bulk upsert (untouched). 8-point jsdom test green.

### **Deploy order for Session 28:** no SQL. Push the 5 changed files **together** (all `multiply_shared.js?v=4`): `multiply_shared.js`, `lc_leader_tool.html`, `member_tool.html`, `multiply_dashboard.html`, `preaching_calendar.html`. Then **bump the remaining shared.js consumers to `?v=4`** (the four report HTMLs) so the browser caches a single shared.js. Hard-refresh / relaunch PWA; phone smoke-test (Inv #31). Smoke: MD Roster "⚡ Bulk add" by level/LCL with the checklist; the preaching banner shows a combined Wed+Sun when both are within a week; the swap modal shows a "Swap from" picker for a 2-engagement week; the calendar (opened from MLT and from the MMT banner) shows "You" + 🔄 on the Pastor's cells; attendance Save shows "⏳ Saving…" and finishes in ~1–2 s.

---

## ✅ COMPLETED JUNE 1, 2026 — SESSION 27 (fail-closed parity; ?v=2 standardization; faces everywhere; Love Language + Enneagram rebalance; Strengths review/fix; LC-Group field; superuser)

Fail-closed parity on both MMT render-layer eligibility catches (Inv #137). `multiply_shared.js?v=2` standardized across all 7 HTML with a bump-together convention (#138). Faces on every remaining avatar surface — MD modal, MMT celebration+LC, MLT listings (#139, extends #133). Love Language rebalanced (Physical Touch de-loaded to literal touch; Gifts dignified; scoring key byte-preserved) and Enneagram rebalanced (de-glow Type 1; dignify 8/7/9; 63 statements; key preserved), both de-branded (#140); `members.enneagram_type` is INTEGER (#141). Strengths reframed to a "Strengths Reflection" with disclaimer + Gallup link and a NEUTRAL (shuffle) tie-break replacing the alphabetical bias (#142). Late MD: an **LC-Group-name field** (Pastor/superuser + facilitator only, anti-drift guard — #143; fixes the LACR mislabel where a leader's `lc_group` held a person's name) and a **superuser predicate** `_isSuperuser()` = Pastor OR Level-5-with-no-LCL that exempts top-of-tree leaders from the self-edit lock (#144).

## ✅ EARLIER SESSIONS (condensed — full detail in git history + invariants)
- **S26:** Profile photos end-to-end (resize ≤512px JPEG → public `avatars` bucket, `add_member_photo_and_avatars_bucket.sql` run ONCE; DB holds only `photo_url`; initials base + photo overlay, #133/#134); celebration-feed expansion (streaks/perfect-attendance/birthdays, LCG-scoped); MLT batch rename (#132)/delete (#135)/Visible-to-others Pastor-only (#136).
- **S25:** Per-person Usbong unlock by attendance (#128), present-only attendance (#129), per-lesson roster (#130), lesson-unique patterns (#131).
- **S24:** Conflict Style + DISC rebalanced + de-branded (#123/#124); quiz option-key drift fix (#125); L9/L10 quiz rogue-schema rebuild; Usbong quiz Model-X lesson-lock (#127).
- **S23:** SVI Service split (#117), zone-constraint silent-write fix (#118), MD SVI Weights editor (#119), preaching-copy fix (#121), "Care Radar"→"Member Spiritual Vitality Report" (#122).
- **S22:** SVI engine + Care Radar + MAR honesty; private mentoring batches.
- **S12–S20:** BTLI L4–L10 builds; shared slides-nav module (#74); shared font slider (#80); favicons (#81); PPTX render-verify (#82); Model X lock (#84/#85); self-attest shared extraction (#91); weekly attendance gate (#100); MLT boot wall (#101).

---

## 📋 PENDING ITEMS

### **🔝 BTLI L12 — Understanding My Unique Design** (LEAD — the next real build)
- **Effort:** Large (full 8-deliverable lesson). **Status:** Ready — needs the **UNLAD-L2 scan** uploaded.
- Source UNLAD-L2; MV **Ephesians 2:10**; character (proposed) Goodness/Faithfulness — confirm from source (Inv #75). **THE assessment-battery lesson** — build the sequence to take all 6 MULTIPLY assessments (Spiritual Gifts, Strengths, DISC, Enneagram, Love Language, Salvation) into the participant page. Direct build (no Gemini). Library seed FIRST then quiz seed (Inv #84); render-verify PPTX (#82); favicon+slider (#80/#81); browser-verify all (#80).

### **🙏 Prayer / Panalangin — Waves 2–4 (HELD until Pastor's go)** (Inv #165)
Wave 1 (MMT board) landed S35. The tables for the rest already exist (`intercessions`, `prayer_list_items`, `prayer_list_opens`). In order, on the Pastor's word:
1. **W2 — encouragement:** prayed-tap "N praying" (writes `intercessions`), praise→celebration-feed bridge, notify-on-save, soft care-flag (`care_flag_by`), category filter.
2. **W3 — reminders + lifecycle:** prayer reminders, EOLO-name seeding into requests, auto-expiry via `expires_at`.
3. **W4 — silent SVI:** a prayer SVI category (`count_rows`) — **invisible to members** (gamification stays hidden; SVI factors it). LOWERCASE category per Inv (svi_metrics check).
- **Phase B carryover for prayer:** centralize the kind-bubble `sameKind` helper into `multiply_shared.js` (currently local to the MMT prayer block) — fold into the kind-mirroring Phase B below and bump `?v=`.

### **🪞 Kind-mirroring — Phase B** (Inv #164)
Phase A (S34) covered MD + MLT. Phase B: (1) make the **report HTMLs** viewer-aware (`memberKind === viewerKind`), retiring the strict Inv #58 predicate; (2) **centralize** the mirrored helpers (`memberKind`/`viewerKind`/`_kindVisible`/`_sameKind`) + the prayer `sameKind` into `multiply_shared.js` and **bump `?v=` lockstep** (Inv #138). ~30 min per report.

### **🔧 Infra — cloud-session write access (durable fix)**
Laptop **cloud** sessions are read-only (git push 403 + MCP 403 + no signing key) — work had to ship via `git format-patch` → apply/push from the desktop. **Durable fix:** grant the **Claude GitHub App** write on `gejable1/multiply` (Contents + Pull requests) so future cloud sessions push directly. Standing workflow either way: **pull-first; ask before push**; the desktop clone is the preferred push surface.

### **🏗️ Multi-tenant — Phase 2 (next major arc)** (Inv #153–#157)
Phase 1 foundation is done (S29): `churches` + nullable `church_id` on 41 tables, Rosehill backfilled. Phase 2, in order:
1. **Auth Edge Function** — PIN → **church-scoped JWT** (server-trusted `church_id` claim).
2. **App sets `church_id` on every insert** (clears the NULL trickle, Inv #155).
3. **RLS policies** on the 40 per-church tables + the `devotionals` hybrid (NULL=shared).
4. **NOT NULL tightening migration** on `church_id` once inserts populate it (Inv #154).
5. **SECURITY DEFINER view/function audit** — church-scope them (`TENANCY_AUDIT.md` §5: they bypass RLS and would leak across churches).
6. **Super-admin layer** → onboarding UI + per-church branding/config → **pilot one church**.

### **👀 Watch-item: leader on-site log can clobber a member self-attest present** (flip side of the S29 fix)
- The `UNIQUE(member_id,event_type,event_date)` row is shared, so a leader logging on-site **after** a member self-attested present could overwrite that present. Separate future task: leader-log should **not** clobber an existing member `self_attest` present. Not urgent — logged so it isn't lost.

### **✅ Self-attest PAST-date correction — DONE (S33, Option A, `b4b792f`, Inv #163)**
- Shipped: correcting an old leader-marked absence works at any age (dup-check before the window); brand-new claims stay 7-day-gated; native date picker added.

### **🧹 One-time backfill: flag pre-existing guest-added members** (offered S33; not run)
- Inv #162's inheritance is **forward-only**. Members guests added **before** `4c48e83` are still unflagged in Rosehill's numbers. A human-gated, idempotent SQL can flag any member whose **discipler is a guest/test user** (and isn't already flagged), with a read-only diagnostic first + a rollback (Inv #153/#157). Pastor to confirm before running.

### **🧹 Optional tidy from S28**
- **Confirm preaching-row ids** all use the canonical Gerry id (`547ebda6-5126-436e-9890-709f50588ced`) — the `?me=` + both-ids fix made the calendar robust regardless, so this is cosmetic.
- **Calendar dead code:** the now-unused static `#swapModal` markup + `submitSwap`/`closeSwapModal` in `preaching_calendar.html` can be removed whenever convenient (harmless if left).

### **🔁 Assessment re-pilots** (Inv #97/#140 — await member retakes; not actionable until then)
- After members **retake**, re-run each distribution query and confirm the spread widened: **Conflict Style** (no mode avg > ~7, no primary > ~30–35%); **DISC** (D toward 10–20%+, avg_total < ~140); **Love Language** (no language > ~30–35%; Physical Touch falls from 36.5%; Gifts climbs from 4.8%); **Enneagram** (Type 1 falls from 34.8%; 8/7/9 climb — read small cells with care); **Strengths** (neutral tie-break — fairer, not Gallup-grade by design).

### **SVI engine** — ✅ DEPLOYED (S23). Future recomputes still **dry-run first** (`?dry_run=true&member_id=…`, Inv #112).

---

## 📋 PARKED ITEMS
- **Year-One Cohort Evaluation** — ~May 2027 (first formal earning cycle for L2+, Inv #47).
- **Strengths follow-ups** (#142): deepen resolution (more pairs / Likert pass — LARGE, diminishing returns, still not Gallup-grade); a dashboard manual-entry field for official Gallup Top-5 (`strengths_top5` column exists). Parked.
- **Other reports — viewer-aware test containment review** — ~30 min each when next opened (keep strict Rule #58 until reviewed). Low payoff.
- **L1–L6 slides nav retrofit** to shared module — optional (Inv #74).
- **First Usbong batch lifecycle hygiene** — demote/delete any duplicate `forming` batch for "New & Pre-believer's Class."
- **Diagnose RLS policies file** — run `diagnose_rls_policies.sql` to completion; keep if load-bearing, drop if vestigial (Inv #10).
- **Discipler text-fallback tidy in MD** — legacy decorative `discipler` text column.
- **LC meeting-day/time feature** — designed but the `lc_groups` table was **never created** (live-DB verified 2026-06-04: no such relation in any schema). `member_tool.html:5986` is a **fail-soft dead reference** (returns null → skipped; LC card's meeting day never populates). Decide later: build `lc_groups` as a **PER-CHURCH** table within/after the tenancy migration, or remove the dead call. **Left as-is for now.**
- **`_backup_members_diag_zone_2026_05_06`** — backup/temp table (57 rows), **excluded** from tenancy; **drop candidate** once confirmed unused (Inv #156).
- **`leader_sessions` retention cleanup** — the audit table grows unbounded (1936 rows by S28); add a retention/prune policy someday. Low priority.
- **`CC_SETUP.md`** — untracked file sitting in the repo root all session; **decide: commit or delete** (it keeps showing in `git status`).
- **`ministry_roles`** — confirmed **PER-CHURCH** (carries `church_id` since S29); no action, noted for completeness. Low concern.

---

## 🧠 GEMINI SUBCONTRACTING — DECISION RECORD
**Decision (S13, confirmed S14–S20):** Stop subcontracting BTLI lesson builds to Gemini (~25% salvage, ~2× longer, unrecoverable drift). Direct build with Claude is ~2× faster for 100% retention; the non-skippable browser-verification step (Inv #80) closes the silent-bug failure mode. Keep Gemini only for parallel emergencies / custom non-USAD-UNLAD topics.

---

*"A student who is fully trained will be like their teacher." — Luke 6:40*
*Session 28 was about a shepherd not missing his own pulpit, and a leader not losing the count of his flock. The preaching tools learned to read the actual day on the calendar instead of trusting a label that wasn't there, to show both the Sunday and the Wednesday in one breath, and to let a man choose which of his own dates to hand off. The calendar finally recognized its own pastor — it had been looking in the wrong drawer for his name. And the attendance button stopped pretending: it now says "Saving…" out loud and finishes before anyone can walk away, because a record nobody trusts is a record nobody keeps. Small mechanics, but each one removes a quiet way the system used to drop what a faithful leader handed it. Next: BTLI L12 — where the disciple turns the honest mirrors inward and meets the poiema God actually made (Eph 2:10).* ✦
