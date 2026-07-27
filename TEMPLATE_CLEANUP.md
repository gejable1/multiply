# Template Cleanup — Reviewable Plan

**Purpose:** one pass over the shared template *before* any church forks it. After twelve churches fork, the same fix is twelve conversations.

**Decided by Pastor Gerry:** descriptors render separately but stay rungs · every item keeps its trackable checkbox; the template sets defaults, each church decides · all nine fruit at every level · 30-day devotional · keep FATS · BTLI 101–106 naming · EGR attendance L0, facilitator L1, speaker L2–L5, organizer L3–L5.

---

## A. The rules

Everything below follows from four rules. The rest is mechanical.

1. **Every item stays a rung and keeps its trackable checkbox.** What changes is how it renders: a new `kind` field, `step` or `descriptor`. Steps appear in the step list; descriptors appear in the level profile panel. `trackable` remains independent and church-editable, because some churches track everything as a matter of culture. The template only sets the default.
2. **Each idea appears once per level.** No idea repeats across levels unless the repetition is deliberate formation.
3. **A role is where you serve, not a skill you have.** Roles live in the Ministry column or the serving-roles catalog — never under Competency.
4. **Attending is a step. Serving is a role.**

---

## B. Descriptors render separately — 72 rows

These rows are **not deleted and not moved to another table.** They stay in `pathway_rungs`, gain `kind = 'descriptor'`, and default to `trackable = false`.

| Kind | Rows | Renders as |
|---|---|---|
| Fruit mentions (`ref-character-love` etc.) | 22 | replaced by a full 9 × 6 grid = 54 |
| Character milestones (`no-moral-failure-5-yrs`, `elder-confirmation`) | 19 | level profile |
| Competencies (`vision-casting`, `conflict-mediation`) | 29 | level profile |
| Other `ref-*` | 2 | level profile |

A church whose culture is to track everything simply sets `trackable = true` on these and its LCLs affirm them one at a time, exactly as FATS is affirmed today.

The profile renders as **"What a Level N leader looks like"** — something to aspire to, not a checklist. This is the single biggest change and the reason L0 shrinks from 30 items to 18.

Because descriptors stay rungs, the profile is edited in the same place as everything else — no separate structure, no separate permissions. The earlier question about whether a church may edit its profile answers itself: yes, the same way it edits any rung.

---

## C. The nine fruit at every level

Currently 4 per level (2 at L0), distributed arbitrarily — love appears 5 times, gentleness once, at Director level. Replaced by all nine at every level: **54 entries**, uniform.

This makes the recurrence deliberate, which is what you always intended. A member at any level sees the whole of Galatians 5:22-23, not a rotating subset.

---

## D. Duplicate resources — 19 rows collapse to 8

| Resource | Currently at | Keep at | Why |
|---|---|---|---|
| EGR | L0, L1, L2 | **L0** | attendance is the front door; L1+ is serving, now a role |
| Daily Devotional + Journal | L0, L1, L2 | **L0** | the habit starts once; L1's 30-day streak is the step |
| Church Devotional Guide | L0, L1, L2 | **L0** | a resource, not a repeated task |
| Weekly Gathering Attendance | L0, L1 | **L0** | |
| First Steps Plan | L0, L1 | **L0** | |
| Daily Bible Reading Plan | L0, L1 | **L0** | |
| EGR Follow-up Care | L0, L1 | **L0** | |
| CCF Glorious Hope | L1 (step), L4, L5 | **L1** | already a trackable step at L1 |

Because progress is recorded per level, a member currently re-ticks the same devotional guide at three separate levels.

---

## E. Roles move out of Competency — Ministry stops being empty

| Level | Ministry today | Move in | Becomes |
|---|---|---|---|
| 0 | Join a Life Group | — | Join a Life Group |
| 1 | Serve in a ministry team | — | Serve in a ministry team |
| 2 | *empty* | `lead-lc` | **Life Group Leader** |
| 3 | *empty* | `coach-leaders` | **Coach of LC Leaders** |
| 4 | Direct a ministry | — | Ministry Director |
| 5 | *empty* | `plant` | **Church Planter** |

The roles already existed. They were filed by the skill they require rather than the role they are.

---

## F. Serving-roles catalog — first entries

EGR, from your ladder:

| Role | Opens at |
|---|---|
| EGR participant *(a step, not a role)* | L0 — trackable rung |
| EGR facilitator | L1 |
| EGR speaker | L2 |
| EGR organizer | L3 |

Speaker and organizer stay open at every level above, rather than repeating per level. Each catalog entry carries: role name, level it opens at, gifts that fit, time commitment, who to talk to, and whether it currently needs people.

Rendered as **"Where you could serve"**, placed below the character section — competence follows character in your model, so the layout should say so.

---

## G. Small corrections

| Item | Change |
|---|---|
| `btli1` + `btli-101` | merge into one rung, titled **BTLI 101**. Course code `btli101` untouched — it is already live. |
| BTLI at higher levels | 102–103 (L2), 104 (L3), 105 (L4), 106 (L5) — naming already consistent |
| 90-day devotional streak | corrected to **30-day**, matching the L1 step |
| FATS | rung is already correct; the canonical **docs** say FATLESS and get updated |
| `lifedev-*` under Coaching | moved to resources — a devotional guide is not a coaching relationship |
| EGR at L0 | default becomes **trackable** — it is the evangelism front door |
| Real-Life Discipleship at L0 | template default **reference**, stranded at sort_order 243; Rosehill keeps its own trackable override on fork |

---

## H. What this does not touch

- No member's completion history. Progress is keyed by `rung_key` and survives every change here.
- No course codes, quizzes, cohorts or lesson files.
- No church's existing overlays — this is the template lane only, and it happens **before** any fork.

---

## I. Sequence

1. Approve this plan (and answer the profile-editable question in section B).
2. Add the `kind` field and default every `ref-*` row to `descriptor`. Nothing renders differently yet.
3. Apply the cleanup to the template lane in one proven migration.
4. Seed the serving-roles catalog with EGR plus the six level roles.
5. *Then* the fork model proceeds from a clean template.

Steps 2–4 are invisible to members: the template lane is not what any church currently reads.
