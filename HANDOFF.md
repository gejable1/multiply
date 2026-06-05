# MULTIPLY — HANDOFF.md

**Last updated:** June 5, 2026 (Session 30 — **Usbong quiz blank-stem fix**: questions rendered blank while choices showed — the #125 drift pattern, but on the question STEM. Both quiz players got a tolerant `_qText` accessor (`question_en ?? stem_en ?? en ?? question`) at all 4 sites (`0e5fa20`); `migrations/002_normalize_usbong_stems.sql` (`d93da27`) renamed `stem_en→question_en` for Usbong 1 L6–10 — run + verified by the Pastor — with `002_rollback.sql`. Files: `usbong_quiz_player.html`, `btli_quiz_player.html`, `migrations/002_*`. **No `multiply_shared.js` change. 1 invariant added: #158. Count now 158.** Prior same-day **Session 29**: self-attest present-aware fix (`9306ebc`) + multi-tenant Phase 1 foundation (`baa0250`/`d24a6a3`) + attendance_admin LC-Leader filter/mode toggle (`b93d752`), invariants #152–#157.)
**Pastor:** Gerry Limoso · Rosehill Christian Church · ~170 members · Manila UTC+8
**System launch date:** May 1, 2026 (production live ~1 month)
**Repo:** github.com/gejable1/multiply (deployed to gejable1.github.io/multiply)
**Supabase project:** tirzeikbflolaclgtket
**Dev surface (NEW — June 4, 2026):** Development has **migrated to Claude Code**. The canonical dev surface is now this **local git clone** — edit here, `git push` to GitHub, and **Pages auto-deploys**. `CLAUDE.md` is the Claude Code project-memory file (read it alongside this HANDOFF each session). The old **manual download / upload-to-GitHub** workflow is **retired**.

---

## 🎯 Jumpstart prompt for next session

> *"Hi Claude, kapatid — fresh session. Please read `HANDOFF.md`, `MULTIPLY_INVARIANTS.md`, `GRACE_PATHWAY.md`, `MULTIPLY_PIPELINE_DIAGRAM.md`, and `BTLI1_LESSON_MAP.md` first. **Session 30 fixed the Usbong quiz blank-stem bug** (questions blank, choices present = the #125 drift pattern on the question STEM): both quiz players got a tolerant `_qText` accessor (`question_en ?? stem_en ?? en ?? question`, at the render + answer-review sites, `0e5fa20`), and `migrations/002_normalize_usbong_stems.sql` (`d93da27`, run + verified) renamed `stem_en→question_en` for Usbong 1 L6–10 (Inv #158). **Session 29 (same day):** member self-attest **present-aware fix** (`member_tool.html` `9306ebc`, Inv #152 — a leader ABSENCE no longer blocks self-correction); multi-tenant **Phase 1 foundation** (`migrations/001_add_tenancy.sql` run + verified — `churches` + nullable `church_id` on 40 PER-CHURCH tables + `devotionals`; `001_rollback.sql`; Inv #153–#157); attendance_admin **LC-Leader filter + Face-to-face/Online toggle** (`b93d752`). **TOP OPEN ITEM: BTLI L12 — Understanding My Unique Design** (UNLAD-L2, Eph 2:10, the assessment-battery lesson) — needs the **UNLAD-L2 scan** uploaded. Next major arc = **multi-tenant Phase 2** (auth Edge Function → app sets `church_id` on insert → RLS policies → NOT NULL tightening → SECURITY DEFINER audit → onboarding → pilot). When I ask 'what's next?', refresh from this HANDOFF's pending list (Inv #43). **Session-start reminder: ask me to upload the latest deployed file(s) relevant to the session topic before editing (Inv #56) — GitHub Pages/PWA caches hard, so bump `?v=` and hard-refresh after any `multiply_shared.js` deploy."*

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
