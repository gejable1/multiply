| # | Scenario | Expected (Nov 4, 11, 18, 25 · Nov 29) | New code | Old code | Result |
|---|---|---|---|---|---|
| 1 | Reported bug: ...R6, R7, M; R12 added recently; >11 rotation Weds in history | R8, R9, M, R10 · R7 | R8, R9, M, R10 · R7 | R7, R8, M, R9 · R4 | ✅ PASS |
| 2 | Swap: last rotation Wed scheduled R5, preached by R9 | R6, R7, M, R8 · R7 | R6, R7, M, R8 · R7 | R2, M, R3, R4 · R3 | ✅ PASS |
| 3 | Removed preacher: newest rotation Wed by X (not in roster), before it R4 | R5, R6, M, R7 · R7 | R5, R6, M, R7 · R7 | R12, M, R2, R3 · R3 | ✅ PASS |
| 4 | On leave: R8 next but on leave until Nov 10 | R9, R10, M, R11 · R7 | R9, R10, M, R11 · R7<br>run 2 rotation: R6, R7, R8, R9, R10, R11… (R8 back ✓) | R2, R3, M, R4 · R3 | ✅ PASS |
| 5 | Fresh start: no history | R2, R3, M, R4 · R2 | R2, R3, M, R4 · R2 | R2, R3, M, R4 · R2 | ✅ PASS |
| 6 | Last-Sunday rotation: ...R5 (Sep), R6 (Oct); Wed pointer elsewhere (..R11, M) | R12, R2, M, R3 · R7 | R12, R2, M, R3 · R7 | R2, R3, M, R4 · R4 | ✅ PASS |
| 7a | Cycle: history ends M, R3 -> rotation, then M | R4, M, R5, R6 · R7 | R4, M, R5, R6 · R7 | R2, R3, M, R4 · R3 | ✅ PASS |
| 7b | Cycle: history ends R3, R4 -> M next | M, R5, R6, M · R7 | M, R5, R6, M · R7 | R2, R3, M, R4 · R3 | ✅ PASS |
| 8 | Existing in-window slot: Nov 4 = R10 hand-assigned (history ...R6, R7, M) | R10*, R11, M, R12 · R7 | R10*, R11, M, R12 · R7 | R10*, R3, M, R4 · R3 | ✅ PASS |
| 9 | Nothing to fill: every preacher on leave through the window | "Nothing to fill…" toast, 0 inserts | Nothing to fill — all upcoming service days already assigned (or all preachers on leave) (0 inserts) | Nothing to fill — all upcoming service days already assigned (or all preachers on leave) (0 inserts) | ✅ PASS |
| 10 | Only mainstay, no rotation (history of M-only Wednesdays) | identical to old code | M, M, M, M · M (16 inserts) | M, M, M, M · M (16 inserts) | ✅ PASS |

**11 passed, 0 failed.** `*` = slot already assigned before auto-fill.
