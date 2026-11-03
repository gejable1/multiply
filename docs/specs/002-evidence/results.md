| # | Scenario | Expected | Actual (new code) | Result |
|---|---|---|---|---|
| 1 | 12 words, auto-save, tab closed, reopen | streak 8 (incl. today), 1 row | streak 8, rows today 1, words saved true, toast "🔥 Day 8 — keep going!" | ✅ PASS |
| 1-old | same steps on OLD code (bug repro) | streak 7, 0 rows (bug) | streak 7, rows today 0, words saved true | ✅ PASS |
| 2 | 8 words, auto-save, tab closed, reopen | no credit (streak 7, 0 rows); "Almost there" reminder | streak 7, rows today 0, reminder: "Almost there" shown | ✅ PASS |
| 3 | 12 words, auto credit toast, then Save | 1 streak toast, then "Reflection saved ✓"; 1 row | toasts: 🔥 Day 8 — keep going! → Reflection saved ✓; rows today 1 | ✅ PASS |
| 4 | 12 words, ✕ immediately (<1.5s) | 1 credit via ✕ path, no duplicate | streak toasts 1 (🔥 Day 8 — keep going!), rows today 1 | ✅ PASS |
| 4b | race: Save tapped right as auto-save fires | 1 row, 1 streak toast | rows today 1, streak toasts 1 | ✅ PASS |
| 5 | past day (Oct 24), 50 words, leave | no credit for Oct 24 or today; words saved | rows Oct 24 0, rows today 0, streak toasts 0, words saved true | ✅ PASS |
| 6 | Sunday Nov 8 (no devotional today), write on Sat entry | no reminder, no new rows, streak unchanged | reminder none, new rows 0, streak 0→0, streak toasts 0 | ✅ PASS |
| 7 | reader at 390px + desktop; toast vs text box | reader works; toast clear of the text box | toast vs text box at 390: textbox y 664-844, toast y 14-49 (viewport 844); toast vs text box at desktop: textbox y 671-851, toast y 14-49 (viewport 900) | ✅ PASS |
