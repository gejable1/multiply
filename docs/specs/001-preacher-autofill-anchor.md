# Spec 001 — Preacher Auto-fill: continue from the LAST preacher, not a history count

**File:** `preaching_admin.html` (opened from the Pastor's Dashboard → Preacher's Schedule).  
**Function:** `autofillNext12()`, PASS 2 ("Compute pointers from DB history").  
**SQL:** none. No schema change.

## Why
Auto-fill for November 2026 restarted the Wednesday rotation at **John Kenneth Zonio (roster #7)**,
who had already preached on Oct 21. It should have continued with **Audie C. Suante (#8)**.

Root cause: PASS 2 picks the next rotation preacher with
`histRotationWedCount % rotation.length`, i.e. it counts every rotation Wednesday in the whole
history and takes the remainder. The remainder is only right if the roster never changed. It drifts when:
1. preachers are **added or removed** (e.g. Moreto Valiao added as #12), since the divisor changes;
2. slots are **swapped**, because history is read by `preacher_member_id` (who actually preached),
   not `original_preacher_member_id` (who was scheduled);
3. a past preacher is **no longer active or in the roster**, so their past Wednesdays are dropped from the count;
4. slots are **assigned by hand** outside the order.

The same count-based approach is used for the last-Sunday rotation (`histLastSunRotationCount`),
and for the Wednesday 2-then-mainstay cycle (`histWedSlotsInCycle % 3`).

## What to build
Replace the three count-based pointers with **anchor-based** pointers. Keep everything else in
`autofillNext12()` exactly as it is.

### A. Wednesday rotation pointer (`wedRotationIdx`)
1. From the history before `winStart`, take Wednesday rows (weekday = Wednesday, per Inv #146: derive
   Sun/Wed from the `preach_date` weekday, not `service_type`). Newest first.
2. For each row, use the **scheduled** person: `original_preacher_member_id ?? preacher_member_id`.
3. Skip rows where that person is the mainstay or a recurring-pattern preacher.
4. The first row whose person **is in the current `rotation` list** is the anchor.
   `wedRotationIdx` = (anchor's index in `rotation`) + 1, wrapped.
5. If no row matches (fresh install, or nobody in history is still on the roster),
   `wedRotationIdx = 0` (start at the top of the roster).

### B. Last-Sunday rotation pointer (`sunRotationIdx`)
Same as A, but only rows on the **last Sunday of a month** (`isLastSundayOfMonth`), skipping the
mainstay. Anchor → next index, else 0.

### C. Wednesday cycle position (`wedCyclePos`, the "2 rotation then mainstay" pattern)
1. Walk the non-recurring Wednesday history newest-first.
2. Count how many consecutive **non-mainstay** Wednesdays come after the most recent **mainstay**
   Wednesday (use the scheduled person, `original_preacher_member_id ?? preacher_member_id`).
3. `wedCyclePos` = min(that count, 2). So 0 → next is rotation, 1 → next is rotation, 2 → next is mainstay.
4. If there's no mainstay Wednesday in history, fall back to the current formula
   (`histWedSlotsInCycle % 3`).

### D. Existing slots inside the window
Keep the current PASS 3 behaviour: existing assignments in the window advance the pointers. But when
an existing in-window slot holds a rotation preacher, set the pointer to **that preacher's index + 1**
(anchor), instead of just `+1`. Use the scheduled person (`original_preacher_member_id ?? preacher_member_id`)
for that too.

### E. History query
The PASS 2 history query must select `original_preacher_member_id` as well
(`preach_date, service_type, preacher_member_id, original_preacher_member_id`).

## Must NOT change
- Who counts as mainstay / recurring / rotation, the on-leave skipping, PASS 1 (recurring preachers),
  the confirm() message, the insert payload, `loadAssignments()` / `renderCalendar()` afterwards.
- Roster screen, Swap Requests tab, Clear… button, calendar rendering.
- `multiply_shared.js` (no `?v=` bump needed — this file only).
- No other HTML files.

## Test scenarios (practice data only, never real members)
Build a small harness (Node or a test page) that feeds `autofillNext12()`'s pointer logic with fake
roster + history, and checks the first picks. Then test in the browser against a **test church /
test members** if available; otherwise harness-only, and say so in the PR.

Roster for tests: M (mainstay, #1), then rotation R2…R12 in order (11 people), unless stated.

1. **The reported bug.** History Wednesdays: … R6, R7, M (last three in order, R7 = Oct 21, M = Oct 28).
   History has more rotation Wednesdays than 11, and R12 was added recently.
   Expect the next Wednesdays: **R8, R9, M, R10**. (Old code gives R7 first.)
2. **Swap.** Last rotation Wednesday was scheduled for R5 (`original_preacher_member_id` = R5) but
   R9 preached (`preacher_member_id` = R9, swap). Expect next rotation = **R6**, not R10.
3. **Removed preacher.** The newest rotation Wednesday belongs to a person no longer in the roster;
   the one before it is R4. Expect next = **R5**.
4. **On leave.** The next person in line (R8) has `on_leave_until` after the slot date.
   Expect **R9** for that slot, and R8 is picked again once the leave is over (current on-leave behaviour).
5. **Fresh start.** No history at all. Expect the first rotation Wednesday = **R2**, and the
   2-then-mainstay pattern starts at position 0.
6. **Last-Sunday rotation.** Last-Sunday history: … R5 (Sep), R6 (Oct). Expect November's last Sunday
   = **R7**, independent of the Wednesday pointer.
7. **Cycle position.** History Wednesdays end with M, R3 → expect next = rotation, then M.
   End with R3, R4 → expect next = **M**.
8. **Existing in-window slots.** November already has Nov 4 = R10 hand-assigned. Expect Nov 11 = **R11**
   (continues after the hand-assigned person), and the cycle stays correct.
9. **Nothing to fill.** All slots already assigned → same "Nothing to fill" toast as today.
10. **Only mainstay, no rotation.** Behaviour unchanged from today.

For each: show the expected vs actual first 4 Wednesday picks + the last-Sunday pick in the PR.
Screenshots of the calendar at **390px** and computer width, with test data only.

## Pastor's manual steps (after merge)
1. Dashboard → Preacher's Schedule → go to **November 2026** → **Clear…** → clear November only.
2. Tap **Auto-fill**. Expect Nov 4 = Audie C. Suante, Nov 11 = Fernan V. Lacerna, Nov 18 = Gerry Limoso,
   Nov 25 = Marlon Sigua (Fhel is on leave until Dec 31, so she's skipped), and
   Nov 29 (last Sunday) = John Kenneth Zonio.
   (If Nov 1 was already assigned, it stays.)
3. If any name looks wrong, screenshot the Roster tab and the October + November calendar and send them.
