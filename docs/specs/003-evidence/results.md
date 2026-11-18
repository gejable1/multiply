# Spec 003 — test results (practice data only)

Run: `node browser003.js <repo> <dir with main's member_tool.html + multiply-sw.js> <out>`
Real `member_tool.html` + real `multiply-sw.js` in Chromium. Supabase is a local fake
(test member `TEST-MEMBER-1`, `is_test_member: true`); nothing touched the live DB.
Migration 128 was **not** run.

| # | Scenario | Result |
|---|----------|--------|
| 1 | Normal: 12 words, tap Save | PASS — 1 reflection, 1 attendance row, "🔥 Day 8 — keep going!" |
| 2a | `currentReflectionRow = null` after auto-save wrote the row, edit, Save | PASS — 1 row with the latest text, no error toast, credited once |
| 2b | Upsert rejected once with Postgres **23505** | PASS — re-read by (member_id, entry_date), PATCH by id (`refl-existing`), text updated, no error toast, credited + streak toast; one retry only |
| 3 | Offline Save (EN, then TL) | PASS — friendly EN + TL toasts, raw error only in console, all 12 words stay, ✕ keeps the reader open; back online Save credits Day 8 |
| 4-old | **Bug repro** on main's v18 worker | PASS (repro) — after `?embed=1` loads fresh, offline plain `member_tool.html` serves the stale install-time copy |
| 4 | New v19 worker | PASS — only `multiply-shell-v19-2026-11-18` exists; one cache key `/member_tool.html`; after `?embed=1` loads build "BUILD-2" online, offline plain URL, offline `?embed=1` and an offline navigation all serve BUILD-2 |
| 5a | Every Supabase call delayed 4 s, tap Save | PASS — Save completes and credits |
| 5b | HTML delayed 4 s | PASS — served from cache in 3.5 s; background fetch refreshes the cache (next load has BUILD-3) |
| 6 | Toast at 360 / 390 px | PASS — wraps inside the screen (x 90–270 of 360; 98–293 of 390), see PNGs |
| 6b | MLT, dashboard, shell through the new worker | PASS — all 200 |
| 7 | `node --check` | PASS — multiply-sw.js + all 3 inline script blocks of member_tool.html; no CRLF |

Screenshots: `offline_toast_en_360.png`, `offline_toast_en_390.png`, `offline_toast_tl_390.png`.
