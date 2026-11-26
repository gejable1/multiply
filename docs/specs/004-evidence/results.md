# Spec 004 — test results (practice data only)

Run: `node browser004.js <repo> <main's lc_leader_tool.html> <out>`
The REAL `member_tool.html`, `lc_leader_tool.html`, `devotional.html` and `devotional_admin.html` in Chromium
against a local fake Supabase (test member `TEST-MEMBER-1`, practice devotionals, practice pastor session).
Nothing touched the live DB. **Migration 129 was not run.** "Before 129" is simulated by the fake DB rejecting
any `_tl`/`tl_status` column (Postgres 42703 / PGRST204) and answering `public_devotional_tl` with 404 (PGRST202).

| # | Scenario | Result |
|---|----------|--------|
| 1 | No Tagalog (`tl_status` NULL) | PASS — no pill on MMT or public page; MLT prompt **byte-identical to main's** (4,240 chars) |
| 2 | Draft only | PASS — admin shows **TL draft** (amber); MMT (even with app in TL), MLT and public stay English |
| 3 | Reviewed, complete | PASS — app in TL → reader opens in TL; EN tap switches all 7 sections, back to TL switches again; reflection text kept; `mmt_devo_lang` stored; app language unchanged; home card title follows; pill 40 px |
| 3b | Save on a TL day | PASS — reflection saves and credits ("🔥 Araw 8") — Spec 002/003 path untouched |
| 3c | Defaults | PASS — app EN + no choice → EN; stored TL choice wins |
| 4 | Reviewed, partial (title_tl + story_tl) | PASS — those two in Tagalog, passage/explanation/response/prayer/summary in English |
| 5 | MLT | PASS — Tagalog block right after `DEVOTIONAL`; prompt minus the block === main's prompt; non-Tagalog date byte-identical; partial block falls back field by field. Sample: `mlt_prompt_reviewed.txt` |
| 6 | Public page | PASS — EN default, pill 40 px, TL tap switches text, note kept, `pub_devo_lang` stored; share text follows language; RPC missing → English only, no pill, no uncaught error |
| 7 | Admin | PASS — edit Tagalog + status Reviewed, save, reload: persists, badge **TL ✓**; English bulk re-import with "replace" updates English only (PATCH payload has no `_tl`/`tl_status` keys) and the Tagalog survives |
| 8 | Before 129 | PASS — MMT English; MLT catches the `_tl` select error, re-selects English, prompt byte-identical; public English; admin hides the section and shows "Run migration 129 to add Tagalog."; English save still works |
| 9 | 3,200-word Tagalog story at 360/390 | PASS — no sideways scroll on MMT reader or public page; pills 40 px |
| 10 | `node --check` + screenshots | PASS — all 8 inline script blocks; no CRLF; 16 PNGs; 0 uncaught page errors |

Screenshots: MMT `mmt_{en,tl}_{360,390,desktop}.png`, `mmt_tl_long_360.png`; public `public_tl_{360,390,desktop}.png`;
admin `admin_editor_{360,390,desktop}.png`, `admin_calendar_badges_{390,desktop}.png`, `admin_pre129.png`.
