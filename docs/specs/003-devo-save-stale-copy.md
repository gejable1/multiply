# Spec 003 — Devotional save: no more "duplicate key" (stale app copy)

**Files:** `multiply-sw.js`, `member_tool.html` (MMT). **No `multiply_shared.js` change** (no `?v=` bump).
**SQL:** `migrations/128_devo_streak_backfill_nov.sql` (gives back November days already lost). It is
already on this branch, tested locally. The **Pastor runs it**. Do not run it.

## Why
On Nov 17 a member tapped Save and got:
`Could not save reflection: duplicate key value violates unique constraint "devotional_reflections_member_id_entry_date_key"`.
The save failed, so the day was not credited and his streak broke. It has happened to him twice, weeks apart.

The current code **cannot** make this error. `_persistDevoReflection()` updates by `id`, or upserts on
`(member_id, entry_date)`. That upsert was added in S93 (PR #324, Oct 2). The plain `.insert()` that
causes this error only exists in builds from **before Oct 2**. (A test on local Postgres confirmed that the
upsert never gives a duplicate-key error. Under RLS it gives a different error.)

So his phone ran an **old copy of member_tool.html** from the service worker cache:
- `multiply-sw.js` (`CACHE_VERSION 'multiply-shell-v18-2026-09-30'`) precached `member_tool.html` at
  install time (Sep 30 build on older phones).
- The cache key is the full URL. The shell opens `member_tool.html?embed=1`, so the network refreshes
  that key and only that key. The plain `member_tool.html` key stays at the install-time copy forever.
  The plain URL is opened by `index.html` (`location.replace('member_tool.html')` for level < 2) and by
  `profile_results_viewer.html`.
- `networkFirst()` serves the cache when the network takes longer than 3.5 s. On a weak signal the
  phone gets the Sep 30 page, and its old `.insert()` hits the row that the auto-save already wrote.

## What to build
1. **Service worker: one cache entry per page, always the newest.** In `multiply-sw.js`, for HTML
   (the `isDoc` branch), use a cache key **without the query string**: `url.origin + url.pathname`
   (`member_tool.html?embed=1` and `member_tool.html` share one entry). Use it for both
   `cache.put` and `caches.match`. JS keeps its full URL (the `?v=` cache-busting depends on it).
2. **Bump `CACHE_VERSION`** to `'multiply-shell-v19-2026-11-18'`. On activate, every older cache is
   deleted, including the Sep 30 copies. Do not change the strategy (network-first, the 3.5 s timeout,
   cache-first for images). Do not touch `service-worker.js` or `service-worker-member.js` (kill-switch stubs).
3. **member_tool.html: a safety net in `_persistDevoReflection()`.** If the upsert or update returns
   Postgres code `23505` (duplicate key), re-read the row by `(member_id, entry_date)`. Then **update** it
   by `id`, set `currentReflectionRow`, and treat it as a success. Do this once, with no loop.
4. **A friendly message on any remaining failure** (non-silent calls only). Replace the raw error toast with:
   EN "Not saved yet — your words are still here. Check your signal and tap Save again."
   TL "Hindi pa na-save — nandito pa ang isinulat mo. Tingnan ang signal at i-tap muli ang Save."
   Still write the raw error to `console.error`. Never clear the textbox on failure.
5. **Credit after success.** When step 3 recovers, Save and ✕ continue as usual: the 10-word rule,
   today's entry only, `markDevoReadSilent()`, and the streak toast.

## Must NOT change
- `computeStreak`, `heldStreak`, the Sunday skip, the gap-day rule, the 10-word rule, catch-up entries
  that never credit.
- The Spec 002 auto-save credit. The reminder modals.
- No other HTML file. No `multiply_shared.js` change. No DB change in code.

## Test scenarios (practice/test members only, never real data)
1. **Normal:** write 12 words today and tap Save. You should see one reflection row, one attendance row,
   and the streak toast.
2. **Duplicate recovery:** in the console, set `currentReflectionRow = null` after an auto-save wrote the row,
   then edit and tap Save. Expect: saved (updated, not inserted), no error toast, one row, day credited.
   Force a 23505 by stubbing the upsert to reject `{code:'23505'}` once, and confirm the fallback updates.
3. **Hard failure:** go offline (DevTools) and tap Save. You should see the friendly EN message, and the TL
   message with Tagalog on. The text stays in the box. Go back online and tap Save: it saves and credits.
4. **Service worker:** with DevTools → Application, after the new SW activates, only `multiply-shell-v19-…`
   exists. Load `member_tool.html?embed=1` (via the shell), then go offline and open plain `member_tool.html`.
   It serves the same fresh copy (the build that contains the new friendly message).
5. **Throttled network** ("Slow 3G" plus a 4 s delay): the page still loads from the cache, and Save still works
   when the request gets through.
6. Phone 360/390 px: the toast wraps and doesn't overflow. Leader (MLT) and dashboard still load through the shell.
7. `node --check` on extracted scripts and `multiply-sw.js`.

## Pastor's manual steps (after merge)
1. Run `migrations/128_devo_streak_backfill_nov.sql` in the Supabase SQL Editor. Every row should read PASS.
2. Ask the member to fully close the app once and reopen it, so the new service worker takes over.
