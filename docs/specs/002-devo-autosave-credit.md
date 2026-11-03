# Spec 002 — Devotional streak: auto-save also credits the day

**File:** `member_tool.html` (MMT) only. **No `multiply_shared.js` change** (no `?v=` bump).  
**SQL:** `migrations/126_devo_streak_backfill.sql` (gives back the days already missed). The **Pastor runs it** in the Supabase SQL Editor; it is already on this branch. Do not run it.

## Why
On Sat, Oct 31, the Pastor wrote a 64-word reflection that same morning, but his streak broke.
In the reader, a day is credited (`markDevoReadSilent()` → `attendance` row, event_type `devotional`)
**only** from `saveDevoReflection()` (Save button) or `closeDevoReader()` (✕).
The S51 silent auto-save (`ref.addEventListener('input', …)` → `_persistDevoReflection({silent:true})`
after 1.5s) saves the words but **never credits the day**. A member who types and then leaves
(Home button, phone locks, app switch, tab closed) keeps the words but loses the streak day.
A check on Nov 3 found **12 such days across 11 members** in October.

## What to build
1. In the auto-save timer callback (currently
   `_devoAutosaveTimer = setTimeout(() => { _persistDevoReflection({silent:true}); }, 1500);`),
   after a **successful** persist, credit the day when BOTH are true:
   - `currentReaderEntry.entry_date === todayIso()` (today's devotional only, never catch-ups), and
   - `_wordCount(currentReflection) >= 10` (Inv #62 + the 10-word rule, same as Save/✕).
   Then call `markDevoReadSilent()`. It is already idempotent (no double rows).
2. When the auto-save credit actually advances the streak (`markDevoReadSilent()` returns true),
   show the **same streak toast** the Save button shows ("🔥 Day N — keep going!" / Tagalog),
   once. Don't show anything when it returns false.
3. Guard against overlapping saves: if an auto-save credit is in flight, a Save/✕ in the same
   moment must not create a second attendance row (the existing `maybeSingle()` check plus the
   in-flight guard is enough; do not add DB constraints).
4. Leave the reflection-reminder modal, the 10-word modal on ✕, and the home reminder gate unchanged.

## Must NOT change
- `computeStreak`, `heldStreak`, the Sunday skip, the gap-day rule, the 10-word rule.
- Catch-up entries (past dates) still never credit a streak day.
- No change to how/where reflections are stored.
- No other HTML files; no `multiply_shared.js` change.

## Test scenarios (practice/test members only, never real data)
1. Today's devotional, type 12 words, wait 2s, then close the tab **without** Save/✕ → reopen →
   streak includes today; exactly **one** attendance row for today.
2. Same, but only 8 words → no credit; home reminder still shows "Almost there".
3. Type 12 words, wait for auto-save credit (toast shows once), then tap Save → no second toast,
   still one row.
4. Type 12 words and tap ✕ immediately (before 1.5s) → credited once (existing path), no duplicate.
5. Open a **past** day's devotional, write 50 words, leave → **no** credit for that day or today.
6. Sunday / no devotional today → nothing changes.
7. Phone width 390px and desktop: reader still works; toast doesn't cover the text box.
Put the results and screenshots (test member only) in the PR.

## Pastor's manual steps
1. **Before merge:** run `migrations/126_devo_streak_backfill.sql` in Supabase SQL Editor →
   all checks PASS, "backfilled rows" = **12**. (Your streak should show 8 days afterwards.)
2. Merge the PR; hard-refresh MMT.
3. Tomorrow, write the devotional and leave the app without tapping Save or ✕ — the streak should still advance.
