# Spec 004 — Bilingual devotionals (English + Tagalog)

**Files:** `member_tool.html` (MMT), `lc_leader_tool.html` (MLT), `devotional.html` (public page),
`devotional_admin.html`. **No `multiply_shared.js` change** (no `?v=` bump).
**SQL:** `migrations/129_devotional_tagalog.sql` is already on this branch (tested twice locally).
The **Pastor runs it**. Do not run it.

## Why
Many of our members read Tagalog more comfortably. Each month Claude (in the MULTIPLY project) will
translate the English guide into Tagalog. The Pastor reviews it, and it is then loaded into the same
`devotionals` rows. Today the apps only know the English columns. This spec makes every place that
shows the devotional ready for the Tagalog version, while English stays exactly as it is.

## Data (from migration 129)
- New nullable columns on `devotionals`: `title_tl`, `scripture_text_tl`, `story_tl`, `explanation_tl`,
  `response_tl`, `prayer_tl`, `reflection_questions_tl text[]`, `weekly_summary_tl`.
- `scripture_ref` is shared by both languages. There is no `_tl` column for it.
- `tl_status`: `NULL` (no Tagalog), `'draft'` (loaded but not yet reviewed), or `'reviewed'` (Pastor approved).
  **Members, leaders and the public see Tagalog only when `tl_status = 'reviewed'`.**
- New `public_devotional_tl(p_date)` returns the Tagalog fields for the public page, only for `'reviewed'` rows.
  `public_devotional()` (used by SOAR and EPIC) is unchanged.
- **Rule everywhere: field-by-field fallback.** If a `_tl` field is blank, show the English field.
- **If migration 129 hasn't been run:** selecting `_tl` columns errors. Every read must still work. Select `*`,
  or catch the error and re-select the English columns, and simply show English.

## What to build
1. **MMT reader** (`loadTodaysDevo` and the reader render, plus the browse-month/catch-up entries):
   - When the entry is reviewed Tagalog, show a small **EN | TL** pill toggle at the top of the reader.
     Default: TL if `body.lang-tl`, otherwise EN. Tapping the pill switches only the devotional text, not
     the app language. Remember the choice in localStorage `mmt_devo_lang` (wrap it in try/catch).
   - Hide the pill when there is no reviewed Tagalog. In that case show English as today.
   - Title, scripture text, story, explanation, response, prayer, reflection questions and weekly summary all
     switch. The reflection box, the 10-word rule, auto-save, the streak and the Share button are unchanged.
   - The home devotional card title follows the same choice.
2. **MLT meeting prep** (`mpLoadDevotional` / `mpBuildPrompt`):
   - Select the `_tl` columns too (with the fallback if 129 hasn't been run).
   - When the devotional is reviewed Tagalog, add a block to the prompt right after `DEVOTIONAL`, headed
     `DEVOTIONAL (TAGALOG VERSION — use this wording for FACILITATOR_TL and PARTICIPANT_TL)`, with the same fields.
   - Leave the English block, the timed flow, the rules and the fences exactly as they are.
3. **Public page** (`devotional.html`):
   - After `public_devotional`, also call `public_devotional_tl` for the same date. If it returns a row, show
     the same **EN | TL** pill. Default EN. Remember the choice in localStorage `pub_devo_lang` (try/catch).
   - If the RPC is missing (129 not run) or returns nothing, there is no pill and the page shows English only,
     with no error shown.
   - The share text uses the language currently shown.
4. **Devotional Admin** (`devotional_admin.html`):
   - In the single-entry editor, add a collapsible **"Tagalog version"** section with a textarea for each `_tl`
     field. Reflection questions go one per line, like the English. Add a status selector: *None / Draft / Reviewed*.
   - Saving writes the `_tl` fields and `tl_status`.
   - Add a status badge on the entry list: **TL draft** (amber) or **TL ✓** (green).
   - **The English bulk import must never touch `_tl` columns** (its update payload stays English-only).
     Add a comment saying so.
   - If 129 hasn't been run, hide the Tagalog section and show a one-line note: "Run migration 129 to add Tagalog."

## Must NOT change
- English text, the parser, the bulk import behaviour, `public_devotional()`, and the SOAR/EPIC cards.
- The reflection storage, the streak rules, the Spec 002/003 save and credit logic.
- Multi-church scoping (devotionals are per church; Canlubang just gets English until it has Tagalog).
- No `multiply_shared.js` change.

## Test scenarios (practice data only; set Tagalog on a test date with SQL or the admin editor)
1. **No Tagalog** (`tl_status` NULL): MMT, MLT and the public page look exactly like today, with no pill.
2. **Draft only:** the admin shows a TL draft badge. Members, leaders and the public still see English only.
3. **Reviewed, complete:** the MMT pill appears. With the app in Tagalog it opens in TL. Toggle to EN and back:
   every section switches, and the reflection text stays.
4. **Reviewed, partial** (only title_tl and story_tl filled): TL shows those two in Tagalog and the rest in English.
5. **MLT:** prep a meeting on a reviewed date. The prompt contains the Tagalog block, and the English block is
   unchanged. On a non-Tagalog date the prompt is byte-identical to today's.
6. **Public page:** EN default, the pill works and the share text follows the language. With the RPC missing:
   English only, and the console shows no uncaught error.
7. **Admin:** edit Tagalog, save, reload and it persists. Run an English bulk re-import with "replace" on that date:
   the Tagalog is still there.
8. **Before 129 is run** (point at a DB without the columns, or stub the error): every screen loads in English
   and the admin shows the note.
9. Very long Tagalog story (3,000+ words): no sideways scroll at 360/390 px, and the pill is at least 40 px tall.
10. `node --check` on all extracted scripts. Screenshots at 360, 390 and desktop width for MMT (EN and TL),
    the public page (TL) and the admin editor.

## Pastor's manual steps (after merge)
1. Run `migrations/129_devotional_tagalog.sql` in the Supabase SQL Editor. All rows should read PASS.
2. Claude will send each month's Tagalog as a migration that loads it as **draft**.
   Review the days in Devotional Admin and set them to **Reviewed**, or ask Claude for the "mark reviewed" SQL.
