# MULTIPLY — HANDOFF.md

**Last updated:** June 3, 2026 (Session 28 — **preaching swap + alert overhaul and an attendance-save fix**: MD batch **bulk-enroll** with a name-checklist review; preaching banner now derives the service day from the **weekday** and shows a **combined Wed+Sun** banner; the swap-request modal was **consolidated into shared.js** with a "Swap from" picker and now serves MMT/MLT/calendar; the calendar's identity bug was fixed (**sessionStorage** + both-ids + `?me=` fallback); and LC **attendance save** is now **batched with immediate "⏳ Saving…" feedback**). No schema migrations this session. Files changed: `multiply_shared.js`, `multiply_dashboard.html` (bulk-enroll), `lc_leader_tool.html` (swap wrapper + `?me=` opener + batched attendance save), `member_tool.html` (swap wrapper), `preaching_calendar.html` (session/id/`?me=` + swap delegation). **All shared.js consumers bumped to `?v=4`. 6 invariants added: #145–#150. Count now 150.**
**Pastor:** Gerry Limoso · Rosehill Christian Church · ~170 members · Manila UTC+8
**System launch date:** May 1, 2026 (production live ~1 month)
**Repo:** github.com/gejable1/multiply (deployed to gejable1.github.io/multiply)
**Supabase project:** tirzeikbflolaclgtket
**Dev surface (NEW — June 4, 2026):** Development has **migrated to Claude Code**. The canonical dev surface is now this **local git clone** — edit here, `git push` to GitHub, and **Pages auto-deploys**. `CLAUDE.md` is the Claude Code project-memory file (read it alongside this HANDOFF each session). The old **manual download / upload-to-GitHub** workflow is **retired**.

---

## 🎯 Jumpstart prompt for next session

> *"Hi Claude, kapatid — fresh session. Please read `HANDOFF.md`, `MULTIPLY_INVARIANTS.md`, `GRACE_PATHWAY.md`, `MULTIPLY_PIPELINE_DIAGRAM.md`, and `BTLI1_LESSON_MAP.md` first. **Session 28 was a preaching-tools + attendance-save session.** Shipped: (1) MD **batch bulk-enroll** — Cohorts→Roster "⚡ Bulk add" with Everyone/By-Level/By-LC-Leader filters and an intermediate name-checklist; test/guests excluded, already-enrolled disabled, no canEnroll gate (Pastor override), pacing still via lesson unlocks (Inv #145). (2) Preaching banner now derives Sun/Wed from the **`preach_date` weekday** not `service_type` (which the table doesn't reliably have — Inv #146), and shows a **combined "Preaching This Week"** banner when 2+ engagements are within the 7-day window, each with its own Swap + a dismiss-all (Inv #147). (3) The swap-request modal was **consolidated** into `MultiplyShared.preaching.openSwapRequest` (MMT/MLT/calendar are thin wrappers) with a **"Swap from" picker** for Wed+Sun weeks and a ±6-week "Swap with" filter (Inv #148). (4) The calendar's "no Swap" bug was root-caused to a **storage mismatch** — it read `localStorage` while the app keeps sessions in **`sessionStorage`**; fixed to read the shared session API, match BOTH leader+member ids, and accept a **`?me=` URL fallback** for PWA→external-browser launches (Inv #149). (5) LC **attendance save** was slow + silent (2 sequential round-trips per member, no button feedback → users assumed it saved and left); now **batched** (1 SELECT + bulk INSERT + parallel UPDATE) with an immediate **"⏳ Saving…"** button state (Inv #150). All shared.js consumers are `?v=4`. **TOP OPEN ITEM: BTLI L12 — Understanding My Unique Design** (UNLAD-L2, Eph 2:10, the assessment-battery lesson) — needs the **UNLAD-L2 scan** uploaded. When I ask 'what's next?', refresh from this HANDOFF's pending list (Inv #43). **Session-start reminder: ask me to upload the latest `multiply_shared.js`, `multiply_dashboard.html`, `lc_leader_tool.html`, `member_tool.html`, `preaching_calendar.html`, and any assessment/quiz/lesson files relevant to the session topic before editing (Inv #56) — GitHub Pages/PWA caches hard, so bump `?v=` and hard-refresh after deploys."*

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

---

## 🧠 GEMINI SUBCONTRACTING — DECISION RECORD
**Decision (S13, confirmed S14–S20):** Stop subcontracting BTLI lesson builds to Gemini (~25% salvage, ~2× longer, unrecoverable drift). Direct build with Claude is ~2× faster for 100% retention; the non-skippable browser-verification step (Inv #80) closes the silent-bug failure mode. Keep Gemini only for parallel emergencies / custom non-USAD-UNLAD topics.

---

*"A student who is fully trained will be like their teacher." — Luke 6:40*
*Session 28 was about a shepherd not missing his own pulpit, and a leader not losing the count of his flock. The preaching tools learned to read the actual day on the calendar instead of trusting a label that wasn't there, to show both the Sunday and the Wednesday in one breath, and to let a man choose which of his own dates to hand off. The calendar finally recognized its own pastor — it had been looking in the wrong drawer for his name. And the attendance button stopped pretending: it now says "Saving…" out loud and finishes before anyone can walk away, because a record nobody trusts is a record nobody keeps. Small mechanics, but each one removes a quiet way the system used to drop what a faithful leader handed it. Next: BTLI L12 — where the disciple turns the honest mirrors inward and meets the poiema God actually made (Eph 2:10).* ✦
