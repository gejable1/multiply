# MULTIPLY — INVARIANTS

**Purpose:** This file is the durable, canonical record of all standing rules, technical patterns, and pastoral principles that govern the MULTIPLY platform. It is **not operational state** (that lives in `HANDOFF.md`). Items here are RULES OF THE SYSTEM that Claude must read at session start and preserve across all future builds.

**Standing rule:** An invariant is removed from this file ONLY when explicitly retired by Pastor Gerry. HANDOFF.md rewrites must NEVER drop, summarize, or rephrase items from this list.

**Last reviewed:** June 20, 2026 (Session 40 — #180 Path-1 custom HS256 JWT auth (legacy shared secret), #181 `auth-login` EF contract (verify_jwt OFF + bcrypt), #182 JWT-claim SQL helpers + `church_id` auto-stamp trigger, #183 DB client must carry the JWT for RLS, #184 `multiply_shared.js` has 19 consumers, #185 RLS rollout / per-table canary discipline; **count now 185**). Earlier: June 19, 2026 (Session 38 — #169 embed-async LEADER re-sync, #170 EF 150s limit → bulk-prefetch, #171 SVI LC-meeting scoring, #172 preaching Auto-fill anchored to schedule-end; **count now 172** — same-session follow-up: **#170 RESOLVED** (bulk-prefetch shipped + EF redeployed, compute now runs in seconds) and **#171 now LIVE** (LC-meeting scoring in effect)). Earlier: June 1, 2026 (Session 27); count **144** (running history in the dated footers below — #128–#131 added this session: per-person Usbong unlock, present-only attendance, per-lesson roster filter, lesson-unique attendance patterns). Earlier: Session 21 added Invariants **#98–#105**. **#98** (Usbong lesson-lock bridges on the literal track string `'Usbong'`, NOT `'Pre-Pipeline'`), **#99** (habit-nudge forcefulness tuned to audience — forceful-with-escape for leaders, gentle for members; all fail-soft), **#100** (weekly attendance gate: service-window model, always backward-looking, dated labels, LCG rolling-7-day + waivable), **#101** (MLT boot wall is ONE merged modal: attendance + unread announcements), **#102** (announcement unread surfacing must load at boot, not only inside `openAnnouncements`), **#103** (BTLI Zone-1 salvation-assurance gate in `canEnroll`, BTLI-scoped, all enrollers; MD override bypasses by not calling canEnroll), **#104** (MLT enroll pickers show ALL members with advisory badges, never hide the ineligible), **#105** (whole-file `node --check` after any structural JS edit; the "Leader Name/?/empty" screen has two causes — inline throw OR shared.js not loading; mind the cache). **Count now 105.** Session 20 added #95 (`no_gate` fail-closed), #96 (cross-source self-attest guard), #97 (pending notes are hypotheses — verify against live data). Session 19 added #91 (DONE — shared lesson-attest extraction), #92 (self-attest date-snap), #93 (dark-hex on light surfaces), #94 (MD audience picker labels). Earlier:  Invariants #90 (MMT self-attest event parity + lesson sub-picker + member-facing LCG attendance report; plus Prayer of the Day, LCG name fallback, flock fix, count+YOU — all in one cumulative `member_tool.html`) and #91 (lesson-attest resolution is a shared-extraction candidate — logic to shared.js, UI per-file) added. Session 17 added #88 (BTLI L10 Ministry shipped) and #89 (BTLI quiz-gate audit: full-form attendance patterns + lesson_id linkage). Session 16 added #87 (BTLI L9 Evangelism shipped). Invariant #50 stale-clause retired (USAD/UNLAD are BTLI 1 source halves, not separate quiz curricula). Sessions 12–15 added #74–#86: shared slides navigation module (#74), USAD virtues palette ≠ Galatians fruit cycle (#75), USAD 4-movement maps to BTLI 5-movement (#76), USAD-L6 Praying Hands belongs in TUGON (#77), Karamay theology priority (#78), FIY working command (#79), shared font slider is BYO-markup not auto-injecting (#80), inline SVG favicons role-coded (#81), PPTX render-before-ship (#82), L7 shipped (#83), Model X participant lesson/quiz lock final (#84), lesson+quiz gates share live-cohort set (#85), L8 shipped (#86), L9 shipped (#87), L10 shipped (#88), quiz-gate audit (#89). Invariant count: 91 through Session 18; 92–94 Session 19; 95–97 Session 20; 98–105 Session 21 → **now 105**.

---

## 🛠️ SCHEMA & DATA INVARIANTS

### **1. LC group naming is sparse — key off LC Leaders, not text fields**
The `lc_group` text field on `members` is unreliable as a source of group identity. Any group-level feature (attendance reports, compliance dashboards, audience filters, etc.) MUST derive group membership from LC Leader records using `is_facilitator` / `facilitator_role`. Never trust `lc_group` alone.

### **10. RLS posture — mostly DISABLED today; Phase 2 turns it ON everywhere**
Until RLS Phase 2, new public tables are created RLS-**disabled**:
```sql
ALTER TABLE <name> DISABLE ROW LEVEL SECURITY;
```
**Correction (2026-06-04, live-DB verified — see `TENANCY_AUDIT.md` §5):** the schema is **not** uniformly open. Of 50 public tables, **43 are RLS-disabled** but **7 are RLS-ENABLED with no policies and `rls_forced = false`** — `_backup_members_diag_zone_2026_05_06`, `interventions`, `ministry_intake`, `svi_metrics`, `svi_snapshots`, `svi_weight_profiles`, `view_log`. Enabled + no-policy + not-forced = **deny-all for `anon`**: direct anon reads of those 7 return zero rows, so the app reaches them only via owner-privileged (SECURITY DEFINER) views/functions that bypass RLS. The old "always DISABLE" wording was inaccurate for those 7. **The multi-tenant migration (Phase 2) supersedes this rule entirely: RLS will be turned ON across all per-church tables with `church_id`-scoped policies** — at which point "disable on every new table" no longer applies. Run `fix_rls_audit.sql` (idempotent, in outputs folder) to re-check live state when in doubt.

### **27. BTLI Quiz System schema — `course_code` and `intro_text`**
The `btli_quizzes` table uses `course_code` (text) and `intro_text` (text) — not `course_id`/`intro_en`. Confirm schema in `/mnt/project/schema.json` before writing seed SQL. Best-of-three attempts, 70% pass threshold, LCG attendance soft-gate, rank reveal at course completion.

### **30. Curriculum identifier conventions**
Curriculum identifiers use natural names with a space and a number — `BTLI 1`, `BTLI 2`, `Usbong 1`, `Usad 1`, `Unlad 1`. Do NOT use hyphens (`BTLI-1`), do NOT remap one curriculum's identifier into another's numbering scheme (no `BTLI 0` for `Usbong 1`). Each curriculum keeps its own pastoral identity in its name.

### **35. Hybrid BTLI gate is the canonical pattern**
BTLI Quiz eligibility uses a hybrid gate:
```
eligible = enrolled_in_active_cohort_of_matching_course OR attendance_pattern_matches
drop_in  = eligible AND NOT enrolled
```
This pattern is the single source of truth via `MultiplyShared.btli.eligibilityFor` / `eligibilityForMany`. Never bypass it from caller code. Future curricula needing similar gating SHOULD use the same hybrid pattern (cohort path + attendance fallback). *Confirmed May 18, 2026 (Session 5):* Usbong follows this pattern via `MultiplyShared.usbong.eligibilityFor` / `eligibilityForMany`, with `cohort_programs.usbong_course_code` as the linkage column (parallel to Invariant #36).

### **36. Schema column for BTLI-cohort linkage**
`cohort_programs.btli_course_code` (text, nullable, indexed) — populated when `category='BTLI'`, otherwise NULL. The link target is the course_code in `btli_quizzes` (e.g., `'BTLI 1'`). Used by the hybrid gate predicate. Do NOT add a foreign key to `btli_quizzes`; course codes are conventionally stable but not normalized.

*Updated May 18, 2026 (Session 5):* Parallel column added — `cohort_programs.usbong_course_code` (text, nullable, indexed via `cohort_programs_usbong_course_idx`) — populated when a program teaches an Usbong course. NEVER reuse one column for the other curriculum; that would conflate two formation tracks per Invariant #50.

### **37. `cohorts.owner_id` is NOT NULL and is stamped on insert ONLY**
`cohorts.owner_id uuid NOT NULL REFERENCES members(id)`. The owner is stamped on row creation (via `_coSaveCohort` for Pastor-created cohorts or via MLT's batch-create flow for LCL-created cohorts) and is NEVER overwritten on update. This preserves LCL ownership of their batches even when Pastor edits them. Verify with partial index `cohorts_owner_id_active_idx`.

### **38. NO PostgREST `!inner` embedded joins in MULTIPLY queries**
Under this Supabase configuration, embedded `!inner(...)` joins return HTTP 400 silently for unknown reasons (suspected: nested column-name resolution). The catch block masks the failure and returns empty arrays, looking like "0 rows" when the table is actually populated. **Use separate queries + client-side stitching instead.** Catches MUST throw — never swallow errors as empty arrays.

### **39. Match unique-constraint violations by code, not message**
PostgREST unique-violation errors should be matched by `error.code === '23505'` (Postgres standard for `unique_violation`), NOT by parsing the error message string. Message formats vary across PostgreSQL versions and Supabase library updates.

### **41. Five canonical batch roles — `cohort_members.role`**

`cohort_members.role` is a text column with a CHECK constraint enforcing exactly **five values**:

| Role | Meaning | Attachment rank |
|---|---|---|
| `teacher` | Delivers the lesson | 2 (sees teacher+ attachments) |
| `co-teacher` | Assists the teacher; observes the master flow | 2 |
| `apprentice` | Teacher-in-training; delivers when rotated in | 1 by default, **promoted to 2** when their cohort has a `cohort_lesson_unlocks` row for the lesson |
| `participant` | The disciple being trained — the reason the batch exists. **The default role for new enrollments** (added May 17, 2026) | 0 (sees only `'all'` attachments) |
| `observer` | Watching to learn the format; future apprentice candidate | 0 |

**Default behavior:** Both MD's Add-Member picker and MLT's C2 Add-Member flow default to `participant`. The previous default (`'apprentice'`) was a mis-fit that caused mislabeling — every new enrollee was marked teacher-in-training when most are simply disciples being trained.

**The DB column default** is `'participant'::text` (changed from `'apprentice'::text` on May 17, 2026 via `cohort_members_participant_role_migration.sql`).

**The CHECK constraint** is `cohort_members_role_check` enforcing the five values. Inserts of other values (including capitalization variants) WILL be rejected by the database.

**Role per Sunday is not modeled.** A person can functionally swap between `co-teacher` and `apprentice` from Sunday to Sunday. The `role` field captures their **dominant function** per cohort enrollment, not per session.

**`'apprentice+'` is a separate concept** — it is a `role_required` *threshold name* used in lesson-attachment metadata (`pipeline_lessons.attachments[].role_required`), NOT a `cohort_members.role` value. They share the word but they aren't the same thing. The four threshold names are: `'all'` / `'apprentice+'` / `'teacher+'` / `'pastor_only'` (see `ROLE_RANK` in `multiply_shared.js`).

### **42. Always check `schema.json` before claiming "no DB constraint"**

The `/mnt/project/schema.json` file in project knowledge contains every table's CHECK constraints, defaults, foreign keys, and indexes — pulled from the live Supabase project. Before claiming "no DB constraint enforces this" or "the column accepts any value," READ `schema.json`. Many bugs that look like UI bugs are actually CHECK constraint violations being silently swallowed by callers that don't surface `23514` errors clearly.

### **50. Pre-Pipeline quiz infrastructure is parallel to BTLI, not shared**

Each curriculum that needs comprehension quizzes gets its **own pair of tables** (`<curriculum>_quizzes` + `<curriculum>_quiz_attempts`) mirroring `btli_quizzes` and `btli_quiz_attempts` 1:1 in column shape. Each gets its **own player file** (forked from `btli_quiz_player.html`). Each gets its **own MMT surface section** (parallel to "BTLI Comprehension Quizzes"). Each gets its **own grade-rollup views** (`v_<curriculum>_lesson_grade`, `v_<curriculum>_course_grade`).

**Established May 18, 2026 (Session 4):**
- `usbong_quizzes` + `usbong_quiz_attempts` + `v_usbong_lesson_grade` + `v_usbong_course_grade` (shipped via `usbong_quizzes_migration.sql`)

**Revised May 22, 2026 (Session 16) — stale-clause retirement (was on pending list):**
- The original draft named "Future: `usad_quizzes`, `unlad_quizzes` follow the same pattern." **This is retired as stale.** Per the Session 10 clarification, USAD and UNLAD are NOT separate Pre-Pipeline curricula — they are the *source materials* for BTLI 1's two halves (USAD = L1–L10, UNLAD = L11–L20). BTLI 1 lessons (incl. L9) use the existing `btli_quizzes` table keyed `course_code='BTLI 1'`; they do NOT get their own `usad_quizzes`/`unlad_quizzes` tables. Usbong 1 remains the only Pre-Pipeline curriculum with its own parallel quiz infrastructure.
- The parallel-not-shared **principle below still holds** for any genuinely new *separate curriculum* Pastor introduces in the future (e.g., a new Pre-Pipeline book), just not for USAD/UNLAD.

**Why parallel and not shared:**
- Invariant #25 says Pre-Pipeline ≠ BTLI. Sharing a quizzes table would technically work but conceptually conflate two different formation tracks. The pastoral truth becomes a database truth.
- Each curriculum has its own pace, its own pedagogy, its own evaluation rhythm. Forcing them into one schema with a discriminator column would constrain future divergence.
- Grade rollups become curriculum-scoped naturally.
- The cost is acceptable: ~80% column overlap means quiz player code is ~85% copyable across curricula, but the data lineage stays clean.

**Implication for new curricula:** if Pastor adds Usad quizzes, the work is (1) `usad_quizzes_migration.sql` (mirror shape), (2) `usad_quiz_player.html` (fork from BTLI), (3) `MultiplyShared.usad.eligibilityFor` helper, (4) MMT section, (5) extend MLT attendance pickers to recognize the new curriculum, (6) extend `_cohortsListVisibleToLeader`'s programs SELECT to include the new course_code column. *Updated May 18, 2026 (Session 5)* to include MLT attendance pickers (step 5) and the shared.js SELECT extension (step 6).

### **51. BTLI uses sealed-cohort graduation; Usbong uses rolling-intake graduation**

Two parallel graduation affordances exist in MLT — both correct for their curriculum:

- **`_batchesGraduateAll`** (MLT, BTLI-shaped) — bulk graduation. Marks every active member as `graduated` AND marks the batch itself as `graduated`. One-way; batch closes; new batch must be created for next cycle. Correct for BTLI where ~10 people journey together for 12 weeks.

- **`_batchesGraduate`** (MLT, Pre-Pipeline-shaped, added Session 5) — individual graduation. Marks ONE `cohort_members` row as `graduated` and **leaves the batch active**. Other members keep going; new members keep enrolling. Correct for Usbong's rolling-intake reality.

**Pastoral implication:** Both UIs are right; the schema serves both. When designing future cohort features, ask which shape the curriculum lives in — *do disciples finish together, or at their own pace?* — and gate the affordances accordingly. Don't force one shape onto the other.

**Established May 18, 2026 (Session 5).**

### **52. shared.js curriculum-generic helpers use an optional discriminator param, defaulting to `'btli'` for backwards compatibility**

When `multiply_shared.js` exposes a helper that needs to work across multiple curricula (BTLI, Usbong, future Usad/Unlad), prefer **one generic function with an optional `curriculum` parameter** over parallel `*Btli*` / `*Usbong*` clones. The discriminator MUST default to `'btli'` so existing callers continue to work without changes.

**Canonical example — `_cohortsListActiveByCourseCode`:**

```js
async function _cohortsListActiveByCourseCode(actor, courseCode, curriculum) {
  const _curriculum = (curriculum || 'btli').toLowerCase();
  let _columnName;
  if (_curriculum === 'btli')   _columnName = 'btli_course_code';
  else if (_curriculum === 'usbong') _columnName = 'usbong_course_code';
  else { console.warn('unknown curriculum', curriculum); return []; }
  // ... filter on cohort_programs[_columnName] === courseCode
}
```

**Contrast with Invariant #50:** Invariant #50 governs the *data layer* — separate tables, separate views, separate eligibility namespaces. Invariant #52 governs *thin shared-helper code* on top of that parallel data — DRY when the only difference is which column name to filter on.

**When NOT to use this pattern:** If the curriculum-specific behavior diverges (different join logic, different filter conditions, different return shape), fork the helper. Don't bend a generic function into a maze of `if (curriculum === 'btli') { ... } else if (curriculum === 'usbong') { ... }` branches.

**Established May 18, 2026 (Session 5).**

### **53. Canonical event_name format for quiz-gating attendance rows**

Attendance rows that need to unlock comprehension quizzes via the hybrid eligibility gate (Invariant #35) MUST use this canonical `event_name` format:

```
{course_code} · L{lesson_number} · {lesson_title}
```

- **Separator:** U+00B7 middle dot (`·`), with single ASCII spaces on either side
- **Course code:** Exactly as stored in `<curriculum>_quizzes.course_code` per Invariant #30 (e.g., `'BTLI 1'`, `'Usbong 1'`)
- **Lesson number:** Prefixed with capital `L` (e.g., `L1`, `L12`)
- **Lesson title:** Verbatim from `<curriculum>_quizzes.lesson_title`

**Examples:**
- `BTLI 1 · L1 · Pananalangin`
- `Usbong 1 · L1 · Sino Ang Diyos?`

**The eligibility helpers lowercase both sides** (the stored event_name and the quiz's `attendance_event_name_pattern`) and substring-match. So a quiz with `attendance_event_name_pattern='usbong 1 · l1'` correctly matches an attendance row with `event_name='Usbong 1 · L1 · Sino Ang Diyos?'`.

**Established May 18, 2026 (Session 5).**

### **54. Per-cohort role scoping in shared.js gate predicate**

`fetchVisibleLessons` in `multiply_shared.js` MUST scope role-rank evaluation per-cohort, never flatten across all cohorts. The required pattern uses TWO data structures built in parallel:

1. **`myCohortPrograms: Set<program_id>`** — flat set of all programs the viewer is enrolled in. Used for the audience-level visibility check (does any of my cohorts grant this program?).
2. **`cohortProgramMap: Map<cohort_id, program_id>`** — per-cohort lookup. Used for the role-rank evaluation in the granting-cohort walk.

The granting-cohort walk MUST use `cohortProgramMap.get(cm.cohort_id) === g.program_id`, NOT `myCohortPrograms.has(g.program_id)`. The latter flattens role-rank across unrelated curricula and causes role-leak bugs (e.g., apprentice rank from one cohort leaking into a participant view in another curriculum).

**Established May 18, 2026 (Session 6)** — fix triggered by the **Juana dela Cruz case**.

### **55. LCL-owned batches auto-enroll the owner as `teacher`**

When an LCL creates a batch via MLT's "+ Create my own batch" flow, `_batchesSaveCreate()` (in `lc_leader_tool.html`) inserts BOTH:

1. A `cohorts` row with `owner_id = L.leaderId` (administrative ownership)
2. A `cohort_members` row with `{member_id: L.leaderId, role: 'teacher', status: 'active'}` (functional teaching role)

Both inserts are required — they serve different purposes. `owner_id` marks who can administratively edit/delete the batch (per Invariant #37). `cohort_members.role='teacher'` is what unlocks teacher-rank attachment access via the shared.js gate (per Invariants #33 and #54). Without the second insert, the LCL owns a batch where they cannot see the facilitator content of lessons taught to that batch — a structural absurdity.

**The two-step is intentionally NOT transactional.** If the cohort INSERT succeeds but the cohort_members INSERT fails:
- The batch IS preserved (not rolled back)
- A warning toast surfaces: *"Batch created, but could not auto-enroll you as teacher: [reason] — please enroll manually."*
- The LCL can fix manually via the roster UI

**Duplicate-key (`error.code === '23505'`) is treated as success.**

**Future creation paths must mirror this dual-insert pattern.** Any new affordance that creates a cohort owned by a leader (bulk-create, template-clone, programmatic API, etc.) MUST also create the `cohort_members` row with `role='teacher'` for the owner.

**Established May 18, 2026 (Session 6).**

### **56. Read `schema.json` before writing any seed SQL — never assume column names from memory**

**Mandatory pre-flight check for ANY seed SQL, migration, or `INSERT` / `UPDATE` against an unfamiliar (or even familiar) table:**

1. **`view /mnt/project/schema.json`** first. Find the target table.
2. **Confirm exact column names** — including the difference between `lesson_no` (wrong) vs `lesson_number` (right), `pass_pct` (wrong) vs `passing_score` (right), `intro_en` (wrong) vs `intro_text` (right).
3. **Confirm column types** — especially `text` vs `jsonb`. A text column will reject `jsonb_build_object()`; a jsonb column will accept text but at the cost of `::jsonb` casts littering the SQL.
4. **Confirm NOT NULL columns** — missing required columns cause immediate insert failure (e.g., `lesson_title text NOT NULL` on `usbong_quizzes` will reject any insert that omits it).
5. **Confirm unique constraints / indexes** — determines whether `ON CONFLICT (col1, col2) DO UPDATE` is available. If only a non-unique index exists on the candidate key, fall back to defensive `WHERE NOT EXISTS` pattern.
6. **Confirm CHECK constraints** — for columns with enumerated allowed values (`audience` in `pipeline_lessons` allows only `'pastor_only'|'cohort_only'|'lc_leaders'|'all_members'`, etc.).

**Why this is a recurring failure mode:**
- Column-name recall from session memory is unreliable — Claude has been wrong on at least three independent BTLI Quiz Admin SQL builds (documented in earlier sessions) and the L6 quiz seed in Session 7 (forcing a full rewrite of 5 SQL files).
- The cost of `view`-ing `schema.json` is ~10 seconds.
- The cost of a failed deploy + corrective rewrite is 15+ minutes plus erosion of Pastor's trust in shipped SQL.
- The math is not close.

**Discipline pattern:**
- For SQL touching a table Claude has used before: `view` the relevant section anyway. Confidence is the failure mode.
- For SQL touching an unfamiliar table: `view` PLUS run a `SELECT * FROM <table> LIMIT 1` diagnostic to confirm the schema matches what Claude infers from the json.
- For complex inserts (e.g., into a 20-column table like `pipeline_lessons`): ship a **diagnostic SQL first** (read-only), let the actual production data shape the insert SQL. The Session 7 `study_usbong_pipeline_lessons.sql` is the canonical example.

**Companion to Invariant #42** which says "always check `schema.json` before claiming no DB constraint exists." Invariant #42 governs *diagnostic claims*; Invariant #56 governs *write-side discipline*.

**Established May 18, 2026 (Session 7)** — triggered by `lesson_no`/`lesson_number` failure in the L6 quiz seed, which required a full rewrite of 5 SQL files mid-session.

---

## 🛠️ ADDITIONAL TECHNICAL INVARIANTS

### **31. Smoke-test convention**
Every Priority-level ship must be smoke-tested by Pastor in production before being marked closed. The smoke test path is documented in the session HANDOFF entry. "Looks right in DevTools" is NOT a smoke test.

### **32. Cross-level program category**
Programs with `pipeline_level=NULL` are cross-level — they accept enrollees from any pipeline level. Used for items like "EOLO Training" that span multiple discipleship stages. Enrollment match is `member.pipeline_level === program.pipeline_level OR program.pipeline_level IS NULL`.

### **33. Lesson attachment role-required gating**
`pipeline_lessons.attachments[].role_required` uses a four-rank threshold system:
- `'all'` = rank 0 (everyone enrolled sees it)
- `'apprentice+'` = rank 1 (apprentices, teachers, co-teachers, pastor)
- `'teacher+'` = rank 2 (teachers, co-teachers, pastor)
- `'pastor_only'` = rank 3 (pastor only)

`MultiplyShared._userRoleRankForLesson` maps the viewer's batch role (from `cohort_members.role`) to a rank number. Pastor always = 3. Leaders not in a cohort = 0. The five canonical roles per Invariant #41 map as:
- `teacher`, `co-teacher` → 2
- `apprentice` → 1 (promoted to 2 with cohort-lesson unlock)
- `participant`, `observer` → 0

NOTE: `'apprentice+'` is a *threshold name* (a role_required value); it is NOT a `cohort_members.role` value.

### **34. AI flag soft framing on all surfaces**
Every UI surface displaying an AI flag MUST include a framing banner reinforcing "this is a conversation starter, not a verdict." See Invariant #16 (the pastoral principle this enforces).

---

## 🧭 PASTORAL DESIGN PRINCIPLES

### **16. AI as conversation starter, NOT verdict**
This is a **pastoral design principle** for MULTIPLY, not just a feature decision. The salvation diagnostic AI prompt explicitly says "Do NOT make a verdict on the person's salvation."

All UI surfaces displaying AI flags MUST:
- Reinforce soft framing with banners
- Avoid auto-alerts or notifications that turn AI into a triage system
- Let Pastor review on his own initiative — never push flags AT him

Defend this principle in future feature requests. AI surfaces information; the pastor pastors.

---

## 🗣️ COMMUNICATION INVARIANTS (PASTOR PREFERENCES)

### **22. Numbered options in prose, NOT clickable choice tools**
Pastor reads longer-form recommendations and reasoning. When presenting options:
- Use plain numbered lists in prose
- Include reasoning with each option
- Always label the honest recommendation explicitly with WHY
- Do NOT use `ask_user_input_v0` or any clickable choice tool

### **23. No rest/sleep/wrap-up encouragement language**
Do NOT mention rest, sleep, "huge day," "you've earned a break," or wrap-up encouragement. Just flag context space when nearing compaction risk and let Pastor decide whether to continue or wrap.

### **17. Context-space watch — session_compaction risk**
Large multi-file builds risk mid-build compaction. When context feels "full" (often after ~3–4 hours of work or after multi-thousand-line file outputs), flag the situation, write HANDOFF.md, and let Pastor start fresh session for the next major build. Do NOT silently continue into compaction territory.

### **18. Project file upload request at start of session**
At the start of every new conversation, remind Pastor Gerry to upload the latest deployed files relevant to the session topic. Default set:
- `multiply_dashboard.html`
- `lc_leader_tool.html`
- `member_tool.html`
- `multiply_shared.js`
- Topic-specific files (e.g., `lcg_pulse_report.html`, `attendance_admin.html`, assessment files)

This avoids regressions from working off stale or memory-only versions.

### **43. "What else can we do?" → refresh from HANDOFF pending list**

When Pastor asks any variant of *"what's next?"*, *"what else can we do?"*, *"what can we work on?"*, *"what else can we do with available space?"*, Claude does NOT brainstorm new ideas or invent features. Instead, Claude:

1. **Pulls from `HANDOFF.md`'s pending, parked, and blocked sections** — those items are the candidate set
2. **Refreshes Pastor's memory honestly** — what each item is, when it was logged, why it was deferred, what it would cost to ship now
3. **Ranks by value-per-minute with an honest lean** — not a neutral list, an opinion with reasoning
4. **Flags genuinely stale items** — if something's been parked for 3+ sessions and the world has shifted, Claude says so and asks whether it should be re-prioritized, re-scoped, or dropped
5. **Is patient about repetition** — items accumulate over many sessions and Pastor cannot reasonably hold them all in working memory; reminding Pastor across multiple sessions is part of Claude's job, not a burden

Established May 17, 2026 (Session 2).

The implication for HANDOFF.md structure: pending items SHOULD carry enough metadata to support quick triage — title, when logged, effort estimate, status (Ready / Parked-why / Blocked-on), and a one-line memory refresher. The new HANDOFF template (May 17 Session 2 forward) reflects this.

### **Brief by default; Taglish welcomed; address as "kapatid"**
- Brief by default for ordinary questions
- Taglish is welcomed in responses
- Address Pastor Gerry as "kapatid"
- Honest pushback before risky changes — even when it's just a feeling
- Dismissed items are NOT re-raised (PWA was dismissed; don't pitch again)
- Proactively consult project knowledge before asking clarifying questions
- Consolidated file outputs per session — ship full working files, not diffs
- Pastor handles content (transcripts, quiz drafts, ministry decisions, lesson theology); Claude handles structure (parsing, formatting, code, layout)

---

## 📱 PWA / PLATFORM INVARIANTS

### **15. Samsung One UI PWA install conflict — proactively warn**
On Samsung One UI devices, installing a second PWA from the same domain may not show on the home screen. Workaround: uninstall the existing PWA → install the new one → reinstall the original. Mention this proactively whenever Pastor adds another PWA target (member tool, leader tool, dashboard) from `gejable1.github.io/multiply`.

---

## 📋 CONTENT / FORMAT INVARIANTS

### **5. Lesson admin info summary — three required leading fields**
When Pastor asks for "lesson admin info" or a lesson summary for any BTLI lesson, the response MUST begin with these three fields in this order:
1. **Aim / Objective** of the lesson
2. **Scriptures used**
3. **Duration** of the lesson

Additional fields are welcome but these three come first.

**`linfo` shortcut convention** (Session 6, May 18, 2026): When Pastor types just `linfo` after a lesson build, Claude responds with exactly these three fields — no preamble, no additional sections, no narrative. The Aim should fit within 25 words. The shortcut is the Pastor-driven quick-reference form of this invariant; the full lesson admin info request still gets the longer treatment with extras. Tested across Usbong L3, L4, L5 builds in Session 6 — works cleanly as a stable convention.

### **20. L1 BTLI Lesson Map — current canonical**
- **L1 · Pananalangin (Prayer)** · status: shipped (6 deliverables)
- **L2 · Bible Meditation** · status: per lesson map
- **L3 · Pagsuko / Surrender** · character anchor: **Joy** (revised from skeleton default Self-Control). Grounded in Romans 12:1, mercy received, "O the joy of full salvation!" Load-bearing artifact: Three-Sangkap Personal Inventory + signed-paper commitment ritual.

### **25. Pre-Pipeline ≠ BTLI structurally, not just verbally**
Pre-Pipeline (Usbong, future Usad/Unlad) is the formation stage BEFORE the leadership pipeline. BTLI is the leadership pipeline itself. They are NOT the same thing renamed. Their data, infrastructure, UI surfaces, evaluation rhythms, and pastoral framing are all distinct. Future builds that try to merge them MUST be challenged with this invariant.

### **Pre-Pipeline character spine — Usbong 1 LOCKED across all 10 lessons** (Session 7, May 18, 2026)

The Usbong 1 (Pre-Pipeline first book) curriculum has a character spine locked across its 10 lessons:

| Lesson | Title | Character Anchor | Memory Verse |
|---|---|---|---|
| L1 | Sino ang Diyos? | Reverence | Jeremias 29:13 |
| L2 | Tao: Sino Ka Para Sa Kaniya? | Pagtanggap ng Pag-ibig | Awit 8:4 |
| L3 | Kasalanan: Anong Nasira? | Kapakumbabaan | Roma 3:23 |
| L4 | Kaligtasan: May Sumaklolo Sa Atin | Pagtanggap ng Biyaya | Efeso 2:8-9 |
| L5 | Hesukristo: Sino Ka? | Pananabik kay Kristo | Juan 14:6 |
| L6 | Pananampalataya | Pagsuko / Surrender | Hebreo 11:1 |
| L7 | Pagsisisi | Kababaang-loob ng Nagsisisi | 2 Corinto 7:10 |
| L8 | Katiyakan ng Kaligtasan | Katatagan | 1 Juan 5:11 |
| L9 | Bagong Buhay | Bagong Pagkakakilanlan kay Kristo | 2 Corinto 5:17 |
| L10 | Bautismo | Pagsunod / Obedience | Mateo 28:19 |

The arc moves from foundational truth (L1–L5) into operational discipleship (L6–L10). L10's final beat is the baptism scheduling worksheet. **NOTE:** Pagsuko in L6 is initial surrender (act); Pagsuko in BTLI 1 L3 (per Invariant #20) is ongoing posture (Joy-anchored). The two are not the same artifact — context matters.

Future revisions to character anchors REQUIRE explicit Pastor approval before locking. Skeleton defaults from the source PDFs are NOT authoritative; lived pastoral truth IS authoritative.

---

## 🗃️ DOCUMENTATION INVARIANTS

### **3. Quiz player only renders `mc` and `tf` question types**

The deployed quiz player (both BTLI and Usbong forks) only renders question types `mc` (multiple choice) and `tf` (true/false). Any `reflection` type in a `questions` jsonb is silently skipped. Do NOT seed `reflection` questions — they will not surface to the disciple.

If reflection-style prompts are pastorally important for a lesson, embed them in the participant HTML's reflection textareas (with localStorage save) — NOT in the quiz seed.

**⚠️ Updated May 20, 2026 (Session 11):** The original "working spec" sentence said *"5 MC + 2 TF + 1 reflection = 8 questions"* with reflection removed yielding 6 MC + 2 TF = 8. That count was Claude's invention based on the original (pre-reflection-removal) spec and was followed for L4. **Pastor flagged that L1–L3 all use 10 questions (8 MC + 2 TF) and confirmed that 10 is the standard.** L4 was patched to 10 same-session. **The canonical question count for all BTLI 1 quizzes is 10 (8 MC + 2 TF), per Invariant #73.** This invariant retains the type-restriction rule (no reflection); the count clause is superseded.

### **9. Idempotency in all migrations**
Every SQL migration file MUST be safe to re-run. Use `DROP CONSTRAINT IF EXISTS`, `CREATE TABLE IF NOT EXISTS`, `ON CONFLICT DO NOTHING / UPDATE`, etc. Pastor frequently re-runs migrations to confirm they applied; this MUST not duplicate rows or error out.

**When `ON CONFLICT` isn't available (no unique constraint):** Fall back to defensive `WHERE NOT EXISTS (SELECT 1 FROM <table> WHERE <candidate-key match>)` per-row INSERT. Trade-off honestly flagged in delivery: re-runs won't update fields (use UPDATE statement separately for that).

### **11. WhatsApp deep links use `api.whatsapp.com/send?phone=`**
Use `https://api.whatsapp.com/send?phone=<number>&text=<encoded>` — NOT `wa.me/`. The `wa.me/` form has caused SSL handshake errors on some Samsung devices.

### **12. Back button pattern for `_blank` tabs**
Pages opened in a new tab via `target="_blank"` MUST use this pattern for the back button:
1. Try `window.close()` first.
2. If still alive after ~150ms (close was blocked by browser), try `history.back()` if same-host referrer.
3. Else navigate to `multiply_dashboard.html` directly.

### **13. Multi-table assessment fetch pattern — gifts_diagnostic + member_profiles merge**
**CRITICAL:** Spiritual Gifts results save to `gifts_diagnostic` (dedicated table). ALL other assessments (Salvation, DISC, Enneagram, Love Language, Strengths, Conflict) save to `member_profiles` (shared row per member). Any query fetching "all assessments for a member" MUST merge BOTH tables. Single-table queries WILL miss data.

---

## 🌳 PASTORAL STRUCTURE INVARIANTS

### **40. The MULTIPLIERS character framework (5 character anchors)**
Each pipeline level has a corresponding character anchor in the MULTIPLIERS framework:
- Level 1 (Team Member): TBD per BTLI 1 build
- Level 2 (Leader): TBD
- Level 3 (Coach): TBD
- Level 4 (Director): TBD
- Level 5 (Executive Leader): TBD

The Pre-Pipeline character anchors (L0 stage) are documented under "Pre-Pipeline character spine" above. They are NOT part of the MULTIPLIERS framework — they precede it.

### **44. Newly-promoted Level 2 members may have zero disciples temporarily**

When a member is promoted from Level 1 → Level 2 (Team Member → Leader), they are commissioned as a new LCG Leader / discipler. **It is expected and acceptable** for them to have zero disciples for a transient window until the Transfer Management v2 flow propagates incoming transfers from the LCG Champion.

A zero-disciple Level 2 member is NOT broken; they are in commissioning. Do not auto-flag, auto-demote, or visually mark them as deficient.

**However:** if a Level 2+ member has zero disciples for **>90 days** AND no pending incoming transfer, surface as a soft flag in Pastor's view ("Leaders without disciples for >90 days"). This is a pastoral conversation trigger, not an auto-action. (See HANDOFF pending: "Grace-period flag" item.)

### **45. Destination for transfers is LCL identity (uuid), not lc_group text**

When the Transfer Management v2 flow proposes moving a disciple between LCGs, the **destination** is identified by the receiving LCL's `members.id` (uuid), NOT by `members.lc_group` text. The receiving-shepherds pool is defined as members with `pipeline_level >= 2`. This is the canonical "I want to transfer Maria from John's LCG to Sarah's LCG" target — Sarah's uuid, not "Sarah's group name."

This protects against:
- Typos / capitalization drift in the `lc_group` text field
- Receivers who don't yet have an `lc_group` text assignment but ARE active Level 2+ leaders

### **46. Discipler = LCL — they are the same role in Rosehill practice**

In Pastor Gerry's pastoral framing, the discipler relationship and the LCG Leader relationship are the same role wearing two hats. A disciple's `discipler_id` should match their `lcg_leader_id` (which itself is derived from LCG membership). The Transfer Management v2 flow honors this: proposing a transfer for Maria means transferring her shepherd-LCL identity, which automatically updates her discipler identity.

This is NOT a universal church practice. Pastor's specific theology: *the person who shepherds you weekly is the person who disciples you.* Future church features that try to split these roles MUST be challenged with this invariant.

### **47. `pipeline_level` is currently a functional placeholder for many members**

As of May 18, 2026 (Session 3), many members sitting at `pipeline_level >= 2` have not been formally evaluated for that level. The system needs them at Level 2+ for them to be valid transfer destinations (per Invariant #45), so the value is functional, but it is not yet earned through a formal evaluation cycle.

The **Year-One L2 Evaluation framework** (parked, scheduled ~May 2027) will be the first formal earning cycle. Until then, current `pipeline_level` values are functional placeholders.

### **48. Two unrelated symptoms can share a root cause — when state feels "frozen at the wrong moment," check scope vs evaluation timing**

A debugging heuristic surfaced in Session 6:

The MD lesson-modal access-picker bug and the shared.js role-leak bug both surfaced in Session 6 and felt unrelated. They actually shared a deeper theme: *state baked at one render-time stays stale if the world changes after render.* In MD, the inner content was baked when the editor opened and never re-rendered on dropdown change. In shared.js, the "granting cohorts" set was computed with a too-permissive predicate that flattened per-cohort scope into a global "any program" check. Both bugs were one-line fixes once the shape was named.

**When state feels "frozen at the wrong moment," ask which scope is being captured vs which should be evaluated dynamically.**

The visual symptoms differ, and the debugging discipline (grep for the *definition*, not just the use) is the same in spirit but different in target.

### **49. Verify schema-level enforcement, don't assume application-level checks suffice**

Companion to Invariants #42 and #56. When a UI feature appears to "work most of the time" but breaks in edge cases (e.g., a value that should be rejected is silently accepted), the bug is often that application-level validation is the only layer enforcing it — and one code path skips that layer. The fix is usually to add the constraint at the DB level (CHECK constraint, NOT NULL, unique index) so any code path through any layer hits the same wall.

**Established May 18, 2026 (Session 5).**

---

### **57. MMT/MLT must never display internal URLs, file paths, or randomized folder slugs in user-facing text**

Lesson attachment slugs and folder paths (e.g. `btli101_xrw5fg`, `usbong_wm32x9`) are **intentionally obscure** to deter URL-guessing bypass of audience gates. Surfacing them in human-readable text — even as a small "URL" subtitle on an attachment viewer — defeats that protection.

**Rule:**
- `href` and `src` attributes may carry the slug (the browser needs them to fetch the resource)
- Visible text may NEVER include the slug, the path, or any URL fragment
- Show only human labels: "Participant Guide", "Facilitator Guide", "Slides"

Applies to:
- All lesson viewer modals in MMT (`_mmtOpenLessonViewerModal` canonical site)
- All attachment viewers in MLT
- All embed wrappers (PDF viewers, HTML iframes)
- All future lesson builds

**Established May 19, 2026 (Session 8)** after MMT attachment viewer was found exposing slugs in its subtitle line.

### **58. ALL statistical reports must exclude Test members AND Guests**

The canonical predicate is:
```sql
WHERE is_test_member = false AND is_external_user = false
```

**Definitions:**
- Test member = `is_test_member = true` (internal QA dummies; never count toward any tally)
- Guest = `is_external_user = true` (existing column; no separate `is_guest` field needed). James Quimpo is the canonical Guest example (`afdf68c2-a2dc-4e6d-8bfe-9862bd6ad433`).

**Applies to:**
- LC Attendance Report
- LCG Pulse Report
- Member Attendance Breakdown Report
- All dashboard counts
- All intervention queues
- All future reports

**"Show all including inactive" toggles** still exclude Test + Guest unless explicitly opted in — the toggle expands membership scope (e.g., to include graduated members), not exclusion exemptions.

When fixing or building any report, **keep this predicate inline at point of use** (not buried in a memory or a helper function) so future Claude/Pastor sees the rule when reading the code.

**Established May 19, 2026 (Session 8).** Applied retroactively to LC Attendance Report in the same session (was previously missing the `is_external_user` filter — silent bug).

### **59. LCG grouping is keyed by LCL ID, never by `lc_group` text**

Companion to Invariant #1 (LC group naming is sparse). The canonical pattern, established in LC Attendance Report and now binding on all reports:

**Identity rules:**
- An LCL = `members.is_facilitator = true` OR `facilitator_role` non-null
- Disciples assigned to their LCL's group via `discipler_id` matching an LCL's `id`
- Leaders are NOT counted in their own LCG's flock (they're the facilitator, not a flock member)
- Leaders ARE counted in their upline's LCG (e.g., Jane appears as a flock member in Pastor's LCG, while her own LCG card lists her L3 disciples without her)
- A self-discipled leader (where `discipler_id == id`) is treated as unassigned (would double-count)

**Display name fallback:**
```js
function lcgDisplayName(leader){
  if (!leader) return '(unassigned)';
  const lcg = (leader.lc_group || '').trim();
  if (lcg) return lcg;
  const first = (leader.name || '').split(/\s+/)[0] || leader.name || '(LCL)';
  return `${first}'s LCG`;
}
```

**Note on `facilitator_id`:** Currently decorative — schema column exists but is not displayed in any form to be filled. Do NOT key grouping off `facilitator_id`. Use `discipler_id` per the pattern above.

**Established May 19, 2026 (Session 8)** — codifying what LC Attendance Report (lines 585-665) already does in production. Applied to Member Attendance Breakdown Report.

### **60. `attendance_mode` column is meaningful only for Sunday Service + Prayer Meeting**

The `attendance.attendance_mode` column (`text NOT NULL DEFAULT 'in_person' CHECK ('in_person','online')`) captures whether a member attended a **livestreamed gathering** in person or by online watch-receipt.

**Rules:**
- Only Sunday Service and Prayer Meeting are livestreamed at Rosehill
- All other event types (`LC Meeting`, `BTLI`, `Pre-Pipeline`, `Ministry`, `Sunday School`, `Youth Gathering`, `Team Building`, `Outing`, `Other`, ministry names, `'devotional'`) save with the default `'in_person'` and **never read this field**
- The MLT attendance form shows the per-row 🏛️/🌐 toggle ONLY when `event_type === 'Sunday Service' || 'Prayer Meeting'` (per Invariant #61)
- Reports that surface the f2f/online split (`lc_attendance_report.html`, `member_attendance_report.html`) only break it out for these two event_types

If a future church practice introduces livestreaming for another event type (e.g., a special service), this invariant must be **explicitly amended**, not silently broken.

**Established May 19, 2026 (Session 8)** with the migration shipping 1,229 historical rows backfilled to `'in_person'`.

### **61. Per-row attendance-mode toggle is the canonical UI pattern for livestreamed events**

The first design (Session 8 morning) used a **global mode toggle** above the attendance form — one mode applied to the whole batch. Pastor field-tested and found it confusing for real Sundays, which are typically mixed (some members in person, some online). Real-world attendance mode is **per member**, not per batch.

**The canonical pattern (Session 8 afternoon ship):**

For Sunday Service + Prayer Meeting attendance forms:
- Each member row shows a small inline 🏛️/🌐 toggle pill on the right side
- Default state per row: in_person (🏛️ visible, dim styling)
- LCL taps the pill to flip a single member to online (🌐 visible, gold-tinted background + gold border)
- Tap stops event propagation so the row's main present/absent click doesn't fire
- State persists in localStorage draft (`modeState` field) — accidental tab death doesn't lose flags
- State persists in DB via `attendance.attendance_mode` column
- On edit (re-opening saved attendance), 🌐 pills are restored from the DB SELECT
- On event-type change or form reset, all per-row mode flags clear

**State variable:** `attendanceModeState[memberId] = 'online'` (absence from the map = in_person default)

**Critical:** DO NOT introduce a global "apply to all" mode toggle alongside the per-row pills. The per-row UI is the source of truth. A global toggle would make the mental model "is this whole batch online or mixed?" which is exactly the confusion the redesign eliminated.

**Established May 19, 2026 (Session 8).**

### **62. Devotional denominator = period_days − sundays_in_period**

Daily devotional engagement (logged in MMT as `event_type='devotional'`, `present=true` once per day on completion of the reflection) is expected daily **except Sunday** per Rosehill pastoral convention. The denominator for any "devotional compliance %" metric is:

```
denominator = total_days_in_period - count_of_sundays_in_period
```

**Example:**
- 90-day window with 13 Sundays → denominator = 77
- A member with 65 devotional rows in the window → 65/77 = 84%
- A member with 0 devotional rows → 0/77 = 0% (correctly shows "no engagement," not "—")

**Why this formula:**
- Devotional rows are present-only (no absent rows are ever written — MMT only logs completion)
- A per-member "rostered sessions" denominator would always equal the present count (100%, useless)
- The flat formula treats devotional as an expected daily discipline, with the percentage becoming a growth indicator over time

**Per-member effective denominators (e.g., counting from `enrolled_date`) are intentionally NOT applied.** Pastoral convention: every member faces the same expectation; the metric is honest about new members starting at low percentages and growing over time.

Applies to: Member Attendance Breakdown Report (Devotional column + Devotional summary card). Future reports surfacing devotional engagement MUST use this same denominator.

**Established May 19, 2026 (Session 8).**

### **63. Standalone HTML pages must load Supabase CDN before `multiply_shared.js`**

Standalone Pastor/LCL-facing pages that use `MultiplyShared.getDB()` (e.g., `lesson_quiz_editor.html`, `member_attendance_report.html`, all report pages) MUST include the Supabase JavaScript client CDN **before** loading `multiply_shared.js`:

```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script src="multiply_shared.js"></script>
```

Without this order, `MultiplyShared.getDB()` returns null and the page silently fails to load data (or throws a "Cannot read property 'from' of null" error). This was caught after the initial `lesson_quiz_editor.html` shipped without the CDN line.

`multiply_dashboard.html`, `lc_leader_tool.html`, and `member_tool.html` already have this load order. New standalone pages MUST replicate it.

**Established May 19, 2026 (Session 8).**

### **64. Shared JS modules for lesson HTMLs use cache-busted versioned src + data-attribute config**

When a piece of lesson-HTML behavior is identical across many files (e.g., the font-size slider), extract it into a shared JS file at the repo root and load it via:

```html
<script src="../multiply_lesson_slider.js?v=N"
        data-font-key="<curriculum>_l<N>_<role>_fontscale"></script>
```

**Rules:**
- Shared file lives at the **repo root** (`gejable1.github.io/multiply/`) alongside `multiply_shared.js` and `multiply_reports.js`
- Lessons in `lessons/<slug>/` reference it as `../multiply_lesson_slider.js` (one folder up)
- **Cache-busting via `?v=N`** — bump the integer whenever the shared file's behavior changes. GitHub Pages caches aggressively; the query string forces a fresh fetch on supported clients
- **Per-file config via `data-*` attributes** on the script tag itself — the shared module reads its own `currentScript`'s attributes. Keeps per-file customization (FONT_KEY, etc.) without globals
- Module must handle BOTH early-load (DOM not yet ready) AND late-load (DOM ready) initialization via `document.readyState` check + `DOMContentLoaded` listener
- Globals exposed by shared modules (e.g., `changeFontScale`) should match the inline pattern's surface area exactly, so existing `onclick` handlers in HTML continue to work unchanged

**Adoption convention:** New lessons (BTLI L4+, Usad, future curricula) use the shared module from the start. Already-shipped inline files (the 19 patched in Session 9) stay inline — retrofit is **optional, not required**. Mixing is fine; the two implementations don't depend on each other.

**Established May 19, 2026 (Session 9).**

### **65. Announcement acks use 3-state model — Unread (implicit), Acknowledged, Archived**

The `announcement_acks` table represents per-member announcement state via a `state text NOT NULL DEFAULT 'archived' CHECK (state IN ('acknowledged','archived'))` column.

**State semantics:**
- **Unread** = no `announcement_acks` row exists for that (announcement_id, member_id). Implicit, never written explicitly. Contributes to the unread badge.
- **Acknowledged** = row with `state='acknowledged'`. Visible in MLT's Inbox-Active sub-view. Does **NOT** contribute to the unread badge — that's the whole point of this state.
- **Archived** = row with `state='archived'`. Visible only in MLT's Inbox-Archived sub-view. Retrievable via the ↩ Unarchive button, which returns it to **acknowledged** (never to unread — the leader has clearly seen it).

**The migration backfilled all pre-Session-9 rows to `'archived'`** via the column DEFAULT. This preserves the original "Got it = dismissed forever" semantics: those entries stay hidden from Active and are retrievable from Archived.

**State transitions** are always written via `upsert` on the composite primary key `(announcement_id, member_id)`. Direct `INSERT` would fail on the existing rows; direct `UPDATE` would fail on first-time acks. The shared helper `_setAnnouncementState(annId, newState)` is the canonical write path in MLT; never bypass.

**MMT intentionally does NOT implement the 3-state model** (Session 9 Pastor's call). Members see pinned cards on Home with the legacy single ✓ Got it button — which writes a row with `state='archived'` via the same DEFAULT mechanism. Future MMT extension to the full model is a parked item.

**Retraction notices use a separate table** (`announcement_retraction_dismissals`) and are unaffected by this model. Their state is intentionally binary (Got it = dismissed forever).

**Established May 19, 2026 (Session 9).**

### **66. Web App Badging API is a best-effort enhancement, never the primary signal**

The `navigator.setAppBadge()` / `navigator.clearAppBadge()` API paints unread counts on installed PWAs' home-screen icons. MLT calls it on every state change (via `_updateAppBadge()` inside `_updateAnnQuickActionBadge()`) and on `visibilitychange`.

**Honest support reality:**
- ✅ iOS 16.4+ Safari PWA — reliable
- ✅ Pixel / stock Android Chrome PWA — works
- ✅ Recent Samsung One UI — mostly works
- ⚠ Xiaomi/MIUI, Realme, OnePlus — inconsistent by version
- ✗ Older Android / non-installed PWAs — silent no-op

**Implementation rules:**
- The call is wrapped in `try { if ('setAppBadge' in navigator) ... } catch { }` — silent failure on unsupported platforms is intentional
- **The in-app badge (red dot on the quick-action card and the count on the Inbox tab button) is the universal fallback.** It must always render correctly regardless of OS-badge support
- A `visibilitychange` listener re-applies the badge when the user switches back to MLT — handles iOS's auto-clear behavior and out-of-sync states from other tabs
- Badge updates **only fire while the app is running or backgrounded**, not while fully closed. True "push the badge when something happens" requires push notifications (separate, much larger feature)

**Pastoral framing for leaders with unsupported phones:** "Pray hard for a new one" 😄 (Pastor's call). No app-side workaround attempted — the cost of feature-detection complexity to handle each launcher exceeds the benefit.

**Future curricula (MMT, MD) MAY add this same enhancement** following the same try-catch + best-effort pattern. The current MLT implementation is the canonical reference.

**Established May 19, 2026 (Session 9).**

### **67. Scope-gate threshold for cross-LCG visibility is pipeline_level >= 3 (Coach+)**

Reports and tools that surface cross-LCG aggregates (e.g., Member Attendance Report's "All LCGs" view) MUST gate this on `LEADER.leaderLevel >= 3`.

**Rules:**
- **Pipeline Level >= 3** (Coach, Director, Executive Leader, Pastor): can toggle between "All LCGs (Coach+ view)" and "My LCG only"
- **Pipeline Level == 2** (Leader / LCL): LOCKED to "My LCG only" — UI control is hidden, value is forced server-side or client-side
- **Anything else** (shouldn't happen in normal flow — leader gate is L2+ at quick-action level, but defensive): treated like Level 2 (locked to own LCG)

**UI conventions:**
- Dropdown options labelled "All LCGs (Coach+ view)" — NOT "Pastor view" (the threshold is Coach+, not Pastor-only)
- When locked, the dropdown is `style.display='none'` and the value forced to 'mine'
- The view should surface scope status to locked viewers (e.g., topMeta line includes `· Showing: My LCG only`) so they always know what they're looking at

**Pastoral framing:** An LCL does not need cross-LCG visibility into other people's flocks. Coaches and above oversee multiple LCGs (or all of them) and need the bigger picture.

**Honorary roles caveat:** If a member functionally operates as a Coach but is stored with `pipeline_level=2`, they won't see the toggle. Fix is to migrate their `pipeline_level` value (per Invariant #47 the values are functional anyway until Year-One Evaluation), NOT to widen the gate.

**Currently applies to:** Member Attendance Breakdown Report (`member_attendance_report.html`). Future cross-LCG reports (LC Member Report, etc.) MUST honor the same threshold.

**Established May 19, 2026 (Session 9).**

### **68. `_scopedMembers()` is the canonical query for scope-aware member iteration**

Any report or tool that derives data from a member set AND respects an LCG-scope toggle MUST iterate over a scoped-helper function, never `STATE.members` directly. Direct iteration over the unscoped member list is a Session-9-shaped latent bug — the Member Attendance Report's summary cards AND CSV export both did this and silently leaked church-wide aggregates into what users thought was a scoped view.

**Canonical pattern (from `member_attendance_report.html`):**

```javascript
function _viewerCanSeeAllLCGs(){
  const lvl = (window.LEADER && window.LEADER.leaderLevel) || 0;
  return lvl >= 3;  // per Invariant #67
}

function _resolveScope(){
  if (!_viewerCanSeeAllLCGs()) return 'mine';
  const el = document.getElementById('scopeSel');
  return (el && el.value === 'mine') ? 'mine' : 'all';
}

function _scopedMembers(){
  if (_resolveScope() === 'all') return STATE.members;
  const myId = (window.LEADER && window.LEADER.leaderId) || null;
  if (!myId) return [];
  // My LCG = members whose discipler_id == my id, PLUS me if I'm an LCL.
  // The summary count includes me because a fresh L2 with 0 disciples
  // showing "0 tracked" is brutally honest; including the LCL avoids that.
  return STATE.members.filter(m => m.discipler_id === myId || m.id === myId);
}
```

**Rules:**
- All scope-aware consumers (summary cards, on-screen rendering, CSV export, any future aggregate) MUST use `_scopedMembers()` not `STATE.members`
- The LCG card render layer may still apply Memory #17's leader-exclusion (the LCL is not shown in their own flock) — `_scopedMembers` is a different layer; the two coexist correctly
- The helpers are file-scoped — when a new report needs scope-aware iteration, define its own equivalent or factor up into `multiply_shared.js` if the pattern needs to be reused across reports

**Why the LCL is included in `_scopedMembers` but excluded from the flock render:**
- The summary count answers "how many members am I responsible for in this scope?" — includes self (the LCL is part of the count)
- The flock render answers "who are my disciples?" — excludes self (the LCL is the facilitator, not a disciple of themselves)
- Both layers serve different pastoral questions; the canonical helper supports the summary question, Memory #17 governs the render question

**Established May 19, 2026 (Session 9).**

---

### **69. Test-data containment in pastoral-context surfaces (MD pattern)**

**The rule:** statistical and pastoral-context surfaces hide test members + guests by default, with two exceptions that unlock test data:

1. **Viewer is `is_test_member`** — they're smoke-testing as an LCL inside the test universe
2. **The modal subject is `is_test_member`** — Pastor explicitly opened a test record to inspect/edit/delete its flock

Administrative discovery surfaces (the MD Members screen, login search, edit-modal lookups) are NOT bound by this rule — they show ALL members with their test/guest pills so Pastor can always find and click into any record.

**Canonical helpers (MD):**

```javascript
function _viewerIsTestMember(){
  const myId = (window.LEADER && window.LEADER.leaderId) || null;
  if(!myId) return false;
  const me = members.find(m => m.id === myId);
  return !!(me && me.is_test_member);
}

function _shouldHideTest(){
  // Exception 1: test viewer (smoke-test mode)
  if(_viewerIsTestMember()) return false;
  // Exception 2: subject of open modal is a test record (inspection mode)
  if(eid){
    const subject = members.find(m => m.id === eid);
    if(subject && subject.is_test_member) return false;
  }
  return true;
}
```

**Surfaces in MD that use this rule (Session 10):**
- `_disciplesDirect(rootId)` — member modal DISCIPLES tab (Direct)
- `_disciplesTree(rootId)` — member modal DISCIPLES tab (Whole Tree)
- `_getUnassignedMembers()` — bulk-assign candidate pool
- `updateScopeCounts()` — scope tab counters (uses viewer-only test check; no `eid` context)

**Surfaces explicitly NOT bound by this rule:**
- Statistical reports (LC Attendance Report, LCG Pulse, Member Attendance Breakdown beyond MAR) → bound by **Rule #58 strictly** until each report gets explicit pastoral review
- The MD Members screen → administrative discovery, must show all
- The login search → administrative
- The edit-modal lookup → administrative

**Reports may opt in case-by-case** (MAR was the first in Session 10 — see implementation notes there). The opt-in pattern: replace strict `!is_test_member && !is_external_user` filter with viewer-aware check; guests stay always-excluded; reports typically have NO inspection exception (different mental model than modals).

**Why the asymmetry between modal-subject exception (yes for MD) and report-subject exception (no for MAR):**
- A modal is an **inspection surface** — Pastor explicitly clicked into a specific record signaling intent to see its contents
- A report is an **aggregation surface** — it answers "show me everyone in scope X". Adding inspection exceptions blurs the line between "real data" and "test data" in ways that make reports unreliable for pastoral decisions

**Established May 20, 2026 (Session 10).**

---

### **70. MMT reading-column cap at 520px — canonical full-screen padding pattern**

Every full-screen surface in MMT (`member_tool.html`) MUST use the centered-column padding pattern. Flat side padding is the anti-pattern — on tablets and desktops, it lets content sprawl edge-to-edge, breaking the reading column that the rest of MMT carefully maintains.

**Canonical pattern:**

```css
padding-left:  max(20px, calc((100vw - 520px) / 2));
padding-right: max(20px, calc((100vw - 520px) / 2));
```

Floors vary by surface intent — `.content` and most main bodies use **20px**; `.reader-topbar` uses **16px**; `.reader-body` uses **22px**; the FAB control rail uses a slight offset (`max(14px, calc((100vw - 520px) / 2 + 14px))`). The 520px ceiling is fixed — that's MMT's reading column width, chosen to deliver comfortable line lengths (~70-75 characters at default font scale).

**Behavior at breakpoints:**
- **Phones (≤520px viewport):** `(100vw - 520px) / 2` is negative; `max(min_pad, negative)` resolves to `min_pad`. So phones keep their minimum side padding (16-22px), content fills the screen as before
- **Just above 520px:** padding grows smoothly as viewport widens
- **Tablet (768px):** padding ~124px each side; content locked at 520px wide, centered
- **Desktop (1280px+):** padding 380px+ each side; content stays at 520px

**Surfaces using this pattern (Session 10 sweep complete):**
- `.content` — main MMT body container (home / pipeline / assess / eolo / profile screens)
- `.reader-topbar` — devotional reader topbar
- `.reader-body` — devotional reader body
- `.fab-controls` — font-slider FAB + language pill
- `page-sermons` topbar + content body
- `page-lessons` topbar (content body already wraps `.content` correctly)

**Surfaces explicitly NOT bound by this rule:**
- Modal dialogs (preaching swap, etc.) — inner cards already capped at 440-480px via `max-width`
- Lesson viewer iframe modal — iframe content manages its own width
- Loading screen — centered spinner, no content to cap

**When adding a new full-screen surface to MMT:**
1. Wrap its content in `<div class="content">` and let the existing class handle padding — preferred path
2. Or if you need custom padding semantics, apply the `max(X, calc((100vw - 520px) / 2))` pattern explicitly. Do not use flat `padding:14px 16px 12px` style — that's the anti-pattern that caused the Session 10 sermons sprawl bug

**Known mild artifact (logged, not fixed):** `_renderSermonsScreen()` renders cards with internal `padding:0 1rem 1rem`. Combined with the outer cap, sermons screen has ~488px visible reading width instead of full 520px — a 16px aesthetic difference, not functional. If touched in future, dropping the inner 1rem brings sermons to full 520px parity with other screens. See HANDOFF parked list "Path-B sermons screen padding cleanup".

**Established May 20, 2026 (Session 10).**

---

### **71. Always confirm folder slug before generating one for lesson asset deployment**

When building a new lesson's HTML/PPTX deliverables that will be deployed to `gejable1.github.io/multiply/lessons/<slug>/`, Claude MUST ask Pastor for the folder slug BEFORE writing any SQL that references it. Never generate a random slug and assume.

**Why this rule exists:** During Session 11's BTLI L4 build, Claude generated `btli101_q3p8mw` for L4 without asking, treating "one slug per lesson" as the assumed pattern. Pastor's actual convention is **one slug per curriculum cohort** — all four BTLI 1 lessons (L1–L4) live in the single `btli101_xrw5fg` folder. The mistake required a same-session UPDATE patch (`btli1_l2_l3_l4_library_patch.sql`) to fix all 5 L4 attachment URLs.

**The convention going forward:**

Pastor's working slug pattern is `<curriculum><course_number>_<6char-random>` — e.g.:
- `btli101_xrw5fg` — currently holds BTLI 1 lessons L1, L2, L3, L4
- A future BTLI 2 cohort would get its own slug (`btli201_xxxxxx`)
- A future Usbong 2 would get its own (`usbong2_xxxxxx`)

**Required ask at lesson build:** Before writing `lesson_library_seed.sql` or any attachment-URL-referencing SQL, Claude asks:
> *"Saang folder slug ko ilalagay ang L<N>? Same folder as L<N-1>, or new slug?"*

**URL-leak prevention rule (memory line) still applies:** The 6-character random suffix is intentionally obscure to deter URL-guessing bypass of role gates. Never display the slug in MMT/MLT human-readable text.

**Established May 20, 2026 (Session 11).**

---

### **72. Per-lesson `pipeline_lessons` library seed is a hard close requirement**

Every BTLI lesson build session MUST close with the lesson's row INSERTed into the `pipeline_lessons` table. If the row is not seeded, the lesson will not appear in MD's Lesson Library, MMT's lesson list, or MLT's attachment picker — even though the HTML files and quiz are otherwise correctly deployed.

**Why this rule exists:** During Session 11, Pastor's diagnostic query revealed that L2 and L3 had been built and quizzed in Sessions 21/22 (per past chats) but **were never INSERTed into `pipeline_lessons`**. The result: BTLI Lesson Library showed only L1 and L4, hiding L2 + L3 from cohort visibility for ~5 days. Required a backfill patch shipped same session.

**The 8-deliverable close requirement (revised from Session 11's 6-deliverable original):**

Every BTLI lesson build session MUST ship these 8 artifacts before declaring the build complete:
1. `btli1_l<N>_participant.html`
2. `btli1_l<N>_facilitator.html` (4-mode toggle: Lesson Plan / Facilitator View / Debrief / LCG Weekly)
3. `btli1_l<N>_intern.html` (5 pre-session briefing cards + per-movement observation)
4. `btli1_l<N>_slides.html` (with NOTES array + keyboard nav)
5. `btli1_l<N>_slides.pptx` (16 slides, speaker notes baked in)
6. `btli1_l<N>_quiz_seed.sql` — 10 questions (8 MC + 2 TF) per Invariant #73
7. **`btli1_l<N>_lesson_library_seed.sql`** — INSERT into `pipeline_lessons` with the 5-attachment array
8. `btli1_l<N>_smoke_test.md` — deploy checklist

**Pre-session diagnostic SQL (run by Pastor at session open):**

```sql
SELECT lesson_number, level, track, title_en, audience, published,
       jsonb_array_length(attachments) AS attachment_count
FROM pipeline_lessons
WHERE track = 'BTLI' ORDER BY lesson_number;
```

If a previous lesson is missing from the result, treat the gap as an issue to be patched during the current session — do not silently let it persist.

**Established May 20, 2026 (Session 11).**

---

### **73. BTLI 1 quiz count is 10 questions (8 MC + 2 TF) — supersedes Invariant #3's "8" working spec**

All BTLI 1 lesson quizzes use exactly **10 questions per quiz: 8 multiple-choice + 2 true-false**. No reflection questions (per Invariant #3). Passing score 70% (so 7/10 correct passes). Best-of-three attempts.

**Why this rule exists:** Invariant #3 was originally written with the count clause "6 MC + 2 TF = 8 questions" based on Claude's read of the pre-reflection-removal spec. In practice L1–L3 all shipped with 10 questions. L4 was built with 8 in Session 11; Pastor flagged the inconsistency; resolved same-session by adding 2 MC questions to L4. **The standing rule is the deployed pattern, not the original spec text.**

**The canonical question shape (verified against deployed L1–L4):**

```json
[
  // 8 MC questions
  { "type": "mc",
    "question_en": "...", "question_tl": "...",
    "options": [
      { "en": "...", "tl": "...", "correct": true|false },
      { "en": "...", "tl": "...", "correct": true|false },
      { "en": "...", "tl": "...", "correct": true|false },
      { "en": "...", "tl": "...", "correct": true|false }
    ],
    "points": 1
  },
  // ... 7 more MC ...
  // 2 TF questions
  { "type": "tf",
    "question_en": "...", "question_tl": "...",
    "correct": true|false,
    "points": 1
  }
  // ... 1 more TF
]
```

**Required fields in every `btli_quizzes` INSERT (verified against schema.json May 20, 2026):**

- `course_code` TEXT NOT NULL — `'BTLI 1'` (with space, per Invariant #30)
- `lesson_number` INT NOT NULL
- `lesson_title` TEXT NOT NULL — Tagalog or English per Pastor's choice (L1 uses `'Pananalangin'`, L4 uses `'Personal Holiness'` — both acceptable)
- `passing_score` INT NOT NULL DEFAULT 70 — always 70 unless explicitly overridden
- `attendance_event_name_pattern` TEXT — per Invariant #53 format: `'BTLI 1 · L<N> · <lesson_title>'` with U+00B7 middle dot separator
- `intro_text` TEXT — Taglish framing for the disciple before starting
- `outro_pass_text` TEXT — Taglish congratulation + 1-line scriptural callback
- `outro_fail_text` TEXT — Taglish encouragement (never condemnation) + retry guidance
- `questions` JSONB NOT NULL — the 10-question array above
- `is_active` BOOL NOT NULL DEFAULT true

**Required pattern in the INSERT statement (idempotency per Invariant #9):**

```sql
INSERT INTO btli_quizzes (...)
VALUES (...)
ON CONFLICT (course_code, lesson_number) DO UPDATE
SET lesson_title = EXCLUDED.lesson_title,
    passing_score = EXCLUDED.passing_score,
    attendance_event_name_pattern = EXCLUDED.attendance_event_name_pattern,
    intro_text = EXCLUDED.intro_text,
    outro_pass_text = EXCLUDED.outro_pass_text,
    outro_fail_text = EXCLUDED.outro_fail_text,
    questions = EXCLUDED.questions,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();
```

**Required pattern for the `pipeline_lessons` INSERT (defensive WHERE NOT EXISTS — no unique constraint on `(track, lesson_number)`):**

```sql
INSERT INTO pipeline_lessons (
  level, track, lesson_number,
  title_en, title_tl, aim, scripture_refs,
  duration_minutes, materials_needed,
  attachments, audience, published
)
SELECT 1, 'BTLI', <N>, ...
WHERE NOT EXISTS (
  SELECT 1 FROM pipeline_lessons
  WHERE track = 'BTLI' AND lesson_number = <N>
);

-- Plus a matching UPDATE so re-runs refresh the row even if it exists:
UPDATE pipeline_lessons
SET title_en = ..., title_tl = ..., aim = ..., scripture_refs = ...,
    duration_minutes = ..., materials_needed = ...,
    attachments = ..., audience = 'cohort_only', published = true,
    updated_at = NOW()
WHERE track = 'BTLI' AND lesson_number = <N>;
```

**Required attachment array shape (5 entries, mirroring L1 pattern):**

```json
[
  { "url": "https://gejable1.github.io/multiply/lessons/<slug>/btli1_l<N>_participant.html",  "label": "Participant Guide",  "role_required": "all" },
  { "url": "https://gejable1.github.io/multiply/lessons/<slug>/btli1_l<N>_intern.html",       "label": "Apprentice Guide",   "role_required": "apprentice+" },
  { "url": "https://gejable1.github.io/multiply/lessons/<slug>/btli1_l<N>_facilitator.html", "label": "Facilitator Guide",  "role_required": "teacher+" },
  { "url": "https://gejable1.github.io/multiply/lessons/<slug>/btli1_l<N>_slides.html",      "label": "HTML Slides",        "role_required": "teacher+" },
  { "url": "https://gejable1.github.io/multiply/lessons/<slug>/btli1_l<N>_slides.pptx",      "label": "Powerpoint Slides",  "role_required": "apprentice+" }
]
```

The `<slug>` per Invariant #71 is asked from Pastor before generating.

**Established May 20, 2026 (Session 11).**

---

### **74. Slides navigation is a shared module via `multiply_slides_nav.js`**

All NEW slides.html files for any MULTIPLY lesson curriculum (BTLI, future Usbong/Usad/Unlad slide sets) load navigation chrome via the shared module instead of inlining the nav code:

```html
<script src="../multiply_slides_nav.js?v=1" data-notes-label="BTLI 1 · L<N>"></script>
```

**What the shared module owns:**
- CSS for `.slides-nav-controls`, `.nav-btn`, `.nav-info`, `.nav-dots`, `.nav-dot`, `.slides-nav-notes`
- HTML markup for the floating control pill + bottom-left notes overlay (injected into `<body>` at DOMContentLoaded)
- All event handlers — prev/next, dot click, keyboard (arrows, Space, Home, End, N, F), touch swipe, fullscreen, hover-reveal
- Active-slide tracking, dot row state sync, notes content sync per slide

**What per-lesson slides.html still owns:**
- The 16 `<div class="slide">...</div>` blocks
- All slide-content CSS (palette variables, typography, layout helpers)
- The inline `const NOTES = [...]` array (one entry per slide)
- The single `<script src="../multiply_slides_nav.js?v=1">` tag

**Configurable via `data-*` attributes on the script tag:**
- `data-notes-label` — short label in the notes panel header (e.g. `"BTLI 1 · L6"`). Defaults to `"Lesson"`.
- `data-notes-var` — name of the global notes array if not `NOTES`. Defaults to `"NOTES"`.
- `data-hover-reveal` — `"false"` to keep controls always visible. Defaults to `"true"`.

**Keyboard contract (locked across all lessons):** `→` Space PageDown → next · `←` PageUp → prev · `Home`/`End` → first/last · `N` → toggle notes · `F` → toggle fullscreen.

**Touch contract:** horizontal swipe ≥50px (with horizontal-dominance check) → next/prev.

**Why this rule exists:** Sessions 1-11 saw repeated drift between L1's rich navigation (hover-pill, dot row, fullscreen) and later lessons (L4-L6 inline navigation lost dots + fullscreen entirely). Pastor flagged this during Session 13 L6 review. Extracting to a shared file eliminates drift the same way Invariant #64 did for the font slider.

**Versioning:** Bump `?v=N` when shared behavior changes. Existing L1-L6 stay inline-patched per the font-slider precedent (Invariant #64) — retrofit is optional but recommended when each lesson is next touched. L7+ MUST use the shared module.

**Sibling files at repo root** (lessons load with `../`):
- `multiply_lesson_slider.js` (font slider — Invariant #64)
- `multiply_slides_nav.js` (slides navigation — this invariant)

**Established May 21, 2026 (Session 13).**

---

### **75. USAD lessons use a broader Christian virtues palette — NOT restricted to Galatians 5:22-23**

When selecting a character anchor for any **USAD-sourced** BTLI 1 lesson (L1-L10), the anchor can be any Christian virtue named in Scripture — humility, prayer, surrender, holiness, patience, brotherly love, etc. It is **NOT required** to be a fruit of the Spirit from Galatians 5:22-23.

**The Galatians fruit cycle is reserved for UNLAD lessons (L11-L20).** Mapping each of the 9 fruits across the 10 UNLAD lessons (with one repeating where pedagogically useful) is the planned UNLAD spine.

**Why this rule exists:** During Session 13's L6 build, the lesson map skeleton proposed "Kindness" (a Galatians fruit) as L6's anchor. Reading the USAD-L6 source carefully revealed the lesson is built around **Brotherly Love (philadelphia · Pagmamahalan ng Magkakapatid)** — Hebrews 13:1, NOT a Galatians fruit. Pastor surfaced the rule explicitly: USAD's L1-L10 lessons cover the broader spiritual disciplines and use a virtue-palette appropriate to each lesson's source content; the Galatians fruit cycle does not start until UNLAD/L11.

**Implications for future USAD lesson builds (L7-L10):**
- L7 Church Worship Service — anchor TBD from USAD-L7 source (not forced to be a Galatians fruit)
- L8 Stewardship — anchor TBD from USAD-L8 source
- L9 Evangelism at Discipleship — anchor TBD
- L10 Ministry — anchor TBD

**Implications for the BTLI1_LESSON_MAP.md skeleton entries:** The "Character (proposed)" field in unbuilt-lesson rows is a **first-draft skeleton**, not a binding commitment. Final character anchors are confirmed during the actual build from honest reading of the source material. Pastor's standing precedent (from L4 + L6): Claude proposes 2-3 alternatives with rationale, Pastor confirms.

**Documentation requirement for built lessons:** The Apprentice Guide (intern.html) for each USAD-sourced lesson should briefly document the chosen anchor's reasoning, including the USAD vs UNLAD distinction so future interns understand why this lesson's anchor may not be a Galatians fruit.

**Established May 21, 2026 (Session 13).**

---

### **76. USAD source is 4-movement; BTLI maps to 5-movement by wrapping with PUKAW + DALHIN**

Every USAD lesson source (L1-L10 spine) has a **4-movement structure**: TANAW · TUKLAS · TALAKAY · TUGON. BTLI lessons use a **5-movement structure**: PUKAW · TUKLAS · TALAKAY · TUGON · DALHIN.

**The mapping:**

| BTLI Movement | Source | Role |
|---|---|---|
| **PUKAW** (~8 min) | Claude-authored hook | Hook · L<N-1> callback · 1-10 snapshot · transition into the USAD content. May absorb USAD's TANAW opening activity (e.g., L6's Connection Quiz lives in PUKAW). |
| **TUKLAS** (~15 min) | USAD's TANAW + TUKLAS combined | Core teaching content from USAD. |
| **TALAKAY** (~12 min) | USAD's TALAKAY (verbatim questions) | Discussion of the USAD-authored questions. **Preserve USAD's questions; do not substitute Claude-authored alternatives** unless Pastor explicitly approves. |
| **TUGON** (~15 min) | USAD's TUGON (response activity) | The USAD-authored carry-out activity (e.g., L6's Appreciation Message + prayer for Box 4 person, L4's silent prayer write). May also include Claude-added quote/scripture cap (e.g., L6's Bonhoeffer quote at TUGON open). |
| **DALHIN** (~10 min) | Claude-authored carry-home | 7-day journal/watch · EOLO bridge · memory verse memorize · Pangako Ko spoken aloud · end snapshot · L<N+1> preview. |

**Why this rule exists:** Session 13's Gemini-supplied L6 facilitator HTML mapped USAD's 4-movement directly without the PUKAW/DALHIN wrappers — resulting in a facilitator guide that didn't match the participant or slides (which had been built with 5-movement). Same drift would happen on every USAD-sourced lesson without explicit codification.

**Six Sources of Influence mapping:** The 5-movement structure aligns with Joseph Grenny's six-sources framework — PUKAW (Personal Motivation) · TUKLAS (Personal Ability) · TALAKAY (Social Motivation) · TUGON (Social Ability + Structural Motivation) · DALHIN (Structural Ability). This mapping is documented in the Facilitator Guide's Lesson Plan mode for every BTLI 1 lesson per Gem instructions.

**Required timing:** Total ~60 min. Adjust ratios per lesson; total stays at 60. Facilitator Guide's timing should match Participant Guide's timing within ±1 min — never have facilitator at 8+5+20+15+10 and participant at 8+15+12+15+10 for the same lesson.

**Established May 21, 2026 (Session 13).**

---

### **77. USAD-L6 specific: Praying Hands story belongs in TUGON, not Talakay**

In BTLI 1 Lesson 6 (Christian Fellowship), the Albrecht Dürer / Albert Dürer "Praying Hands" story belongs in **TUGON**, not TALAKAY. The source USAD-L6 places it in TUGON; both Gemini and early Claude drafts initially misplaced it in Talakay because of the pattern-matching shortcut "story = discussion-prompt = Talakay."

**Why this rule exists:** During Session 13's L6 build, both Gemini's draft and Claude's first review put the story in Talakay. The USAD source scan was re-read carefully and the correct placement was identified. Pastor flagged this as a load-bearing source-fidelity issue — the story is the **narrative landing-place of the whole lesson**, not a discussion prompt. Placing it in TUGON anchors the carry-home in a memorable image (Albert's sacrificed hands), which is what the source intended.

**General principle this codifies:** **Always read the USAD source carefully for movement placement; do not pattern-match story-format to discussion-movement.** The USAD source's own structural choices about where activities and stories go reflect its pedagogical authors' intent. Override only when there is an explicit pastoral or structural reason, and document the override.

**For future USAD lesson builds:** Whenever there is a story, video, or activity in the source material, **first identify which USAD movement it lives in**, then keep it in the BTLI-mapped equivalent (per Invariant #76). Don't shift activities across movements just because a different placement "feels more natural."

**Established May 21, 2026 (Session 13).**

---

### **78. Karamay theology priority: co-suffering primary (1 Cor 12:26); material giving secondary (Rom 12:13, 15:26)**

In BTLI 1 Lesson 6's 4-K framework, the third K (**Karamay**) is anchored primarily in **1 Corinto 12:26**: *"Kung ang isang sangkap ay magdusa, ang lahat ng mga sangkap ay nakikiramay."* Co-suffering with the kapatid is the load-bearing meaning. Material giving (Roma 12:13, 15:26) is **one expression** of karamay, not the whole thing.

**Why this rule exists:** Both Gemini's draft and early Claude versions led with Romans 15:26 (the Macedonian/Achaean material contribution to Jerusalem) as the primary anchor for Karamay. While Rom 15:26 is the same Greek root *koinonia*, the lesson's pastoral target is the **emotional/spiritual solidarity** of the church members in their hardships — not primarily their wallet behavior. Leading with material giving makes Karamay sound transactional. Leading with co-suffering makes it relational.

**Theological reasoning preserved for future reference:**
- 1 Corinto 12:26 (*sympathetai*) — every part of the body suffers together; this is structural, not optional
- Romans 12:13 — share with God's people in need (verb *koinōnountes*); material is named alongside hospitality
- Romans 15:26 — Macedonian contribution; material is named as a specific historical instance, not the universal pattern

**Pastoral application:** In LCG practice, this means Karamay is first practiced through **emotional presence and prayer** for a suffering kapatid; then material help follows as a natural expression. Reversing the order makes karamay performative; preserving the order makes it sustainable.

**Implications beyond L6:** Future lessons that touch the same Greek root *koinonia* (likely L7 Church Worship Service, L9 Evangelism at Discipleship, L10 Ministry) should preserve this priority. If a future BTLI build inverts it, that's a flag — re-read the source.

**Established May 21, 2026 (Session 13).**

---

### **79. FIY ("Fix It Yourself") is Pastor's standing one-word working command**

When Pastor types **"FIY"** (or "fiy") in a chat, the meaning is: **rebuild the file currently under discussion, applying all the corrections Claude has identified in the review above.** No further confirmation required. Claude proceeds to rebuild and ships the corrected file via `present_files`.

**Why this rule exists:** During Session 13's Gemini subcontracting experiment, the working pattern emerged: Pastor pastes Gemini's output → Claude reviews against standing rules + source material → Claude identifies fixes needed → Pastor says "FIY" → Claude rebuilds. This loop happened 7 times in one session. Codifying "FIY" as a standing one-word command saves the back-and-forth.

**Scope of FIY:**
- Applies to the most recently-discussed file or output
- Includes ALL fixes Claude flagged in the immediately-preceding review
- Includes typo corrections, structural rebuilds, palette repaints, source-fidelity restorations
- Preserves any explicitly-good elements Claude identified in the review (don't throw out the baby)

**What FIY does NOT include:**
- New feature requests not in the review
- Architectural changes that should be discussed separately
- Decisions about whether to ship — that's a separate Pastor decision after the rebuild

**Convention going forward:** Even for direct Claude builds (no Gemini), if Pastor reviews Claude's output and Claude identifies multiple fixes, "FIY" is the shortcut to apply them all without re-confirming each one.

**Established May 21, 2026 (Session 13).**

---

### **80. Shared font slider is BYO-markup — script tag alone is a silent no-op**

The shared `multiply_lesson_slider.js` module (Invariant #64) only **wires up event handlers and persists state**. It does NOT inject DOM elements. Lesson HTMLs that load the script MUST also include the canonical font-toggle widget markup in the body, or the slider will silently fail with no visible effect.

**Why this rule exists:** Discovered May 21, 2026 (Session 13 post-deploy) when Pastor opened L6 participant in the browser and observed no slider visible. Investigation revealed that BTLI L4, L5, AND L6 all included the `<script src="../multiply_lesson_slider.js?v=1">` tag but **omitted the widget markup**. The shared module loaded, looked for `#ft-down` / `#ft-label` / `#ft-up`, found nothing, and silently no-op'd via its safe `if (lbl)` / `if (dn)` / `if (up)` guards. Three lessons shipped over ~10 days with invisible/non-functional font sliders. **The module's safety guards masked the defect across multiple builds.**

**The canonical widget markup** (copy verbatim into every lesson HTML, anywhere in the body):

```html
<div class="font-bar">
  <div class="font-toggle" role="group" aria-label="Font size">
    <button class="ft-btn" id="ft-down" onclick="changeFontScale(-1)" aria-label="Decrease text size">A−</button>
    <span class="ft-label" id="ft-label">100%</span>
    <button class="ft-btn" id="ft-up" onclick="changeFontScale(1)" aria-label="Increase text size">A+</button>
  </div>
</div>
```

**The canonical CSS** (adapt color variables per lesson palette):

```css
.font-bar{display:flex;justify-content:center;padding:14px 0 4px;background:transparent;}
.font-toggle{display:inline-flex;align-items:center;gap:14px;background:var(--paper);border:1.5px solid var(--gold);border-radius:999px;padding:6px 16px;}
.font-toggle .ft-btn{background:none;border:none;font-family:'Playfair Display',serif;font-size:1rem;font-weight:700;color:var(--ink);cursor:pointer;width:26px;height:26px;display:flex;align-items:center;justify-content:center;border-radius:50%;transition:background .15s;}
.font-toggle .ft-btn:hover:not(:disabled){background:rgba(184,136,42,.12);}
.font-toggle .ft-btn:disabled{opacity:.35;cursor:not-allowed;}
.font-toggle .ft-label{font-family:'DM Sans',sans-serif;font-size:.78rem;font-weight:600;color:var(--muted);min-width:38px;text-align:center;font-variant-numeric:tabular-nums;}
```

**The three canonical element IDs** (locked — do not rename):
- `ft-down` — the A− button
- `ft-label` — the % display
- `ft-up` — the A+ button

**Required positioning** (locked — matches L1's deployed pattern):
- Inline pill in document flow, **NOT** fixed-position corner rail
- Centered horizontally via `.font-bar` flexbox wrapper
- Placed right after the page header / sticky topbar, before the main content
- Scrolls away with the page

**Why inline-pill (not fixed-corner):** Fixed-bottom-right placement conflicts with lesson surfaces that have fixed save-bars, FAB buttons, or sticky footers (e.g., L6 participant's "I-save Lahat" bar). Inline placement has no such conflicts and scales naturally across all lesson types.

**Validation step in future builds:** When loading the shared module, ALWAYS visually verify the slider renders by opening the deployed HTML in a browser. The module's safety guards mean a missing markup contract will NOT throw any console error — the slider simply doesn't appear.

**Retrofit status (May 21, 2026):**
- L4 participant/facilitator/intern — defective; retrofit recommended
- L5 participant/facilitator/intern — defective; retrofit recommended
- L6 participant/facilitator/intern — patched in Session 13 post-deploy

**Cross-reference:** Invariant #64 established the shared module; this invariant codifies the markup contract that #64 omitted.

**Established May 21, 2026 (Session 13 post-deploy).**

---

### **81. Lesson HTMLs use inline SVG favicons with role-coded color + letter**

Every lesson HTML file (participant, facilitator, intern, slides) MUST include an inline SVG favicon via `<link rel="icon" href="data:image/svg+xml,...">` in the `<head>`. This gives browser tabs immediate visual recognition when Pastor or facilitators have multiple MULTIPLY tabs open simultaneously — a common scenario during lesson preparation.

**Why this rule exists:** Discovered May 21, 2026 (Session 13) — Pastor observed that L5 files default to the generic Chrome document icon, making it nearly impossible to distinguish 7+ MULTIPLY tabs at a glance. Gemini's L6 output included inline SVG favicons (one of the few clearly-positive contributions from the subcontracting experiment), and the practice should become standard across all lesson HTMLs going forward.

**The role-coded color + letter scheme** (canonical):

| Role | Background | Letter | Letter Color |
|---|---|---|---|
| Participant | BTLI green `#2a5c40` | **P** | BTLI gold `#b8882a` |
| Facilitator | BTLI green `#2a5c40` | **F** | BTLI gold `#b8882a` |
| Intern | intern-blue `#2d4a6b` | **I** | BTLI gold `#b8882a` |
| Slides | BTLI green `#2a5c40` | **S** | BTLI gold `#b8882a` |

**The canonical favicon SVG template** (substitute `<BG_HEX>` and `<LETTER>` per role):

```html
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Crect width='100' height='100' rx='18' fill='%23<BG_HEX>'/%3E%3Ctext x='50' y='68' font-family='Georgia,serif' font-size='54' font-weight='700' text-anchor='middle' fill='%23b8882a'%3E<LETTER>%3C/text%3E%3C/svg%3E">
```

For L6 participant, this becomes: `fill='%232a5c40'` (green background) + `<LETTER>` becomes `P`.

**Design rationale:**
- **Letters not emojis** — cross-browser consistency (emojis vary wildly in rendering)
- **Role-coded backgrounds** — Participant + Facilitator share BTLI green (both are user-facing teaching surfaces); Intern blue distinguishes the apprentice perspective; Slides shares green but the **S** letter is the differentiator
- **Inline SVG (data URL)** — no separate file to deploy, no 404 risk, no cache-busting needed
- **Georgia serif font + rounded square (18px radius)** — Pastor's preferred typography family for MULTIPLY surfaces
- **Single gold color for all letters** — visual consistency across the role-color set; fixes the prior bright-gold/muted-gold inconsistency in early L6 builds

**Retrofit status (May 21, 2026):**
- L4 participant/facilitator/intern/slides — missing favicons; retrofit recommended when next touched
- L5 participant/facilitator/intern/slides — missing favicons; retrofit recommended when next touched
- L6 participant/facilitator/intern/slides — already present (kept from Gemini's good calls), one slides-gold inconsistency to be cleaned next touch
- L1, L2, L3 — favicon status unknown; check + retrofit if missing when next touched

**Going forward:** All new lesson HTML files (L7+) MUST include the role-coded inline SVG favicon as part of the standard `<head>` template. Add to the Gem instructions / lesson build template.

**Cross-reference:** This is a polish-tier convention sibling to Invariant #80 (font slider markup) — both were discovered in the same post-deploy review session and codify "things that should be in every lesson HTML's `<head>` and body."

**Established May 21, 2026 (Session 13 post-deploy).**

---

### **82. PPTX layout is blind without rendering — always render + visually inspect before shipping**

A generated `.pptx` (via python-pptx) MUST be rendered to images (LibreOffice → PDF → PNG) and visually inspected slide-by-slide BEFORE the deliverable is declared done. Code-level validation (slide count, notes count, JSON shape) is necessary but **NOT sufficient** for PPTX — layout defects are invisible to code inspection.

**Why this rule exists:** Discovered May 21, 2026 (Session 14) during the L7 PPTX build. The HTML slides file passed every structural check, but the PPTX export had **5 layout defects invisible to code**: (1) center-vs-left alignment on a numbered list, (2) dark-on-dark contrast on two-column boxes, (3) multi-line title overflowing into the verse box, (4) element render-order bug ("EOLO Bridge:" appearing after its paragraphs instead of before), and (5) a **transparency trap** where a fill with `transparency > 0.85` made the text inside render invisible (Pangako Ko slide came out completely blank). All five were caught only by rendering + viewing each slide.

**The transparency trap specifically:** python-pptx shapes with `fill.transparency` high (≥0.85) + text colored the same family as the slide background → text washes out to invisible in LibreOffice's PDF export. **Fix pattern:** use SOLID fills (no transparency) with explicitly high-contrast text color for any box that contains text (verse boxes, callout blocks, the Pangako Ko block).

**The render command** (available in the build environment):
```bash
libreoffice --headless --convert-to pdf <file>.pptx --outdir /tmp/render
# then rasterize pages with pymupdf (fitz) get_pixmap(dpi=110) and view each PNG
```

**Discipline:** This is the PPTX sibling of the browser-verify rule for HTML. Claude's solo builds drift exactly like the Gemini-subcontracting builds did if not visually verified. Render every PPTX that uses non-trivial layout (boxes, columns, multi-line titles, transparency).

**Established May 21, 2026 (Session 14).**

---

### **83. BTLI 1 Lesson 7 shipped — Sama-Samang Pagsamba**

L7 (Church Worship Service / Sama-Samang Pagsamba) is COMPLETE and deployed as the full 8-deliverable set in `lessons/btli101_xrw5fg/` (same cohort folder, per Invariant #71).

**Locked row:**
- Title: "Church Worship Service / Sama-Samang Pagsamba"
- Memory verse: **Hebreo 10:25**
- Character anchor: **Pananagutan (Responsibility)** — NOT a Galatians fruit (per Invariant #75, USAD uses the broader virtues palette)
- Competence anchor: **4-P Worship Anchor** (Pananagutan · Palusot · Pangangailangan · Pagganyak — mapped 1:1 to the four phrases of Hebreo 10:25)
- GRACE stage: A→C
- Flow: 5-movement PUKAW(8)/TUKLAS(18)/TALAKAY(12)/TUGON(12)/DALHIN(10) = 60 min (USAD's 4-movement TANAW/TUKLAS/TALAKAY/TUGON wrapped with Claude-added PUKAW + DALHIN per Invariant #76)

**Distinctive content:** Pang-CAT joke as TUKLAS cold open; 6 Pew-2018 excuses with biblical rebuttals; Church Worship Service Commitment Form in TUGON; 7-Sunday Watch + EOLO church-invite bridge in DALHIN; Pangako Ko (line 3 "Susulpot ako sa Linggo").

**8 deliverables:** participant.html, facilitator.html (4-mode toggle), intern.html, slides.html (16 slides, shared nav module per Inv #74), slides.pptx (16 slides, render-verified per Inv #82), quiz_seed.sql (8 MC + 2 TF, canonical shape per Inv #73; TF Q9=false, Q10=true), library_seed.sql (5 attachments, audience cohort_only), smoke_test.md.

**Quiz lesson_id:** Linked via the Session 14 migration (Invariant #84) — L7 quiz `lesson_id` = `504cfd93-eff8-4d85-ac58-62d47d584042`.

**Next build:** L8 Stewardship (lesson map drives sequencing).

**Established May 21, 2026 (Session 14).**

---

### **84. Model X — participant lesson/quiz lock (FINAL, supersedes earlier unlock semantics)**

Lesson and BTLI/Usbong quiz access for cohort members follows a three-layer model. This is the **settled, final** behavior — it supersedes the pre-Model-X unlock meaning (which promoted apprentices to teacher materials).

| Member's batch role | **Visibility** | **Lock** | **Materials** |
|---|---|---|---|
| **Participant** | by enrollment | gated by per-lesson unlock | `role_required` (sees only `'all'`) |
| **Apprentice** | by enrollment | **never locked** | `role_required` × rank 1 — **unlock never promotes** |
| **Teacher / co-teacher** | by enrollment | never locked | `role_required` × rank 2 |

**The principle in one line:** Unlock is a **participant-only** gate. It has ZERO effect on what teachers/apprentices see — their materials are governed purely and permanently by `role_required` × batch role. Visibility is by enrollment for everyone; the lock holds participants only.

**Mechanism:**
- **Visibility** = `pipeline_lesson_grants` (grant to **program** → all batches see it listed; do NOT split grants per batch — Invariant #71 cohort-folder reasoning applies to grants too).
- **Lock** = `cohort_lesson_unlocks` row, keyed `(cohort_id, lesson_id)` — **per batch**. One lesson, independent batch lock state, no duplication. An unlock is "live" if `unlocked_at` set OR `scheduled_for` passed.
- **Quiz inherits its lesson's lock** via `btli_quizzes.lesson_id` (FK added by the Session 14 migration `btli_quizzes_lesson_id_migration.sql`, backfilled from `(course_code → track+level, lesson_number)` → `pipeline_lessons.id`). Lesson + quiz move in true lockstep.

**Gate locations (the single sources of truth):**
- Lessons: `MultiplyShared.lessons.fetchVisibleLessons` returns `participantLocked = (bestRole === 'participant' && !cohortUnlockedForThisLesson)` per lesson.
- Quizzes: `MultiplyShared.btli.eligibilityFor*` → `_btliComputeOne` returns `reason: 'lesson_locked'` for a locked participant. Staff bypass via `e.role` check. Helper `_btliFetchUnlockKeys` fetches live unlock keys (`${cohort_id}::${lesson_id}`).
- Rank: `_userRoleRankForLesson` — apprentice **always returns 1** (the promotion-on-unlock was removed in Session 14; this was the load-bearing fix for Juan dela Cruz seeing teacher materials on unlocked L1).

**MMT render:** locked participant sees the lesson LISTED (title/meta/aim/scripture) with a 🔒 Locked corner chip + "Opens when your facilitator releases this lesson" (TL: "Bubukas kapag inilabas ito ng iyong facilitator"); materials blocked. Quiz card shows the same message when `reason === 'lesson_locked'`. The old apprentice "🔓 Unlocked" badge was removed (it falsely implied promoted access).

**MD control surface:** the 🔓 Lesson unlocks panel inside the cohort **Roster** view (path: MORE ▾ → 🎓 Batches → program → batch → 👥 Roster → scroll to 🔓 Lesson unlocks). Panel copy + tooltips + confirm dialogs state participant-only effect.

**Fail-open:** if `cohort_lesson_unlocks` can't be read (DB error), `_btliFetchUnlockKeys` returns empty → nobody is locked out. Locking is a deliberate state, never a failure state.

**Known minor gap:** `btli_quiz_player.html` (not touched Session 14) needs `lesson_id` added to its quiz SELECT to enforce the lock on direct deep-links; the MMT card lock holds for the normal flow.

**Established May 22, 2026 (Session 14).**

---

### **85. Lesson gate and quiz gates share ONE definition of a "live" cohort: `active` + `forming`**

The lesson gate (`fetchVisibleLessons`) and the BTLI + Usbong quiz gates (`_btliFetchEnrollments`, `_usbongFetchEnrollments`) MUST agree on which `cohorts.status` values count as "live." The canonical set is **`['active', 'forming']`**. They may never diverge on cohort-status strictness.

**Why this rule exists:** This drift bit twice in Session 14. Originally the lesson gate applied NO cohort-status filter (so lessons opened on a `forming` batch) while the quiz gates used strict `.eq('status', 'active')` (so quizzes stayed locked on the same `forming` batch). Result: lesson opened, quiz didn't — a confusing lesson-vs-quiz desync. Fixed by loosening both quiz gates to `.in('status', ['active', 'forming'])`, matching the lesson gate's permissiveness.

**Scope of the rule:**
- **Cohort liveness** (`cohorts.status`): `active` + `forming` both count as live, in ALL gates. Loosen here.
- **Member enrollment validity** (`cohort_members.status`): stays strict `.eq('status', 'active')` — an exited/inactive member should NOT get access. Do NOT loosen the `cohort_members` filters; they are a different concept (enrollment validity, not batch liveness).

**The four `cohort_members` status filters left strict** (lines ~415, ~1080, ~1373, ~1736 as of Session 14) are correct as-is. Only the `cohorts` status filters were loosened.

**Going forward:** any new gate or report that filters cohorts by status uses `['active', 'forming']`. If a future feature needs a stricter "only fully-launched batches" view, introduce an explicit named set rather than silently using `.eq('active')` (which would re-introduce drift).

**Established May 22, 2026 (Session 14).**

---

### **86. BTLI 1 Lesson 8 shipped — Pagiging Tapat na Katiwala**

L8 (Stewardship: Faithful Trustee / Pagiging Tapat na Katiwala) is COMPLETE as the full 8-deliverable set in `lessons/btli101_xrw5fg/` (same cohort folder, per Invariant #71). Built direct with Claude (no Gemini), browser-verified (Inv #80) and PPTX render-verified (Inv #82) before close.

**Locked row:**
- Title: "Stewardship: Faithful Trustee / Pagiging Tapat na Katiwala"
- Memory verse: **1 Corinto 4:2** — *"Ang katiwala'y kailangang maging tapat sa kanyang Panginoon."*
- Character anchor: **Generosity (Pagkabukas-palad)** — a broad Christian virtue, NOT a Galatians fruit (per Invariant #75, USAD uses the broader virtues palette). *Skeleton had proposed "Self-Control"; revised to Generosity at build-time from honest source reading + Pastor's call — the Pagbibigay section + closing GENEROUS Word Art tree make generosity the visual climax.*
- Competence anchor: **Owner-Manager Stewardship** — the source's own 3 pillars: **Pundasyon** (May-ari ang Diyos) · **Pera** (alipin hindi amo) · **Pagbibigay** (PUSO higit sa PURSIYENTO, Channel not Vessel). *Skeleton's "Three-Bucket Give/Save/Live" was demoted to an optional TUGON tool, not the main competence.*
- GRACE stage: A→C
- Flow: 5-movement PUKAW(8)/TUKLAS(18)/TALAKAY(12)/TUGON(12)/DALHIN(10) = 60 min (USAD's 4-movement TANAW/TUKLAS/TALAKAY/TUGON wrapped with Claude-added PUKAW + DALHIN per Invariant #76)

**Distinctive content:** Nicolas Cage "Asiong Aksaya" cold open; Andrew Murray quote ("Ano'ng meron ka?" vs "Paano mo ito ginamit?"); "Boom basag!" (1 Cor 4:7); PUSO-higit-sa-PURSIYENTO; Channel-not-Vessel; Macedonian Christians (2 Cor 8:2-3); the 6-question Financial Stewardship Quiz; GENEROUS Word Art Top-3 picker (capped at exactly 3, slots auto-fill); 7-Araw Generosity Watch; Pangako Ko ("Hindi ako owner — manager ako…").

**8 deliverables:** participant.html, facilitator.html (4-mode toggle), intern.html (5 briefing cards + per-movement obs + self-reflection), slides.html (16 slides, shared nav module per Inv #74), slides.pptx (16 slides + 16 speaker notes, render-verified per Inv #82), quiz_seed.sql (8 MC + 2 TF, canonical shape per Inv #73; TF Q9=false, Q10=true), lesson_library_seed.sql (5 attachments, audience cohort_only), smoke_test.md. Plus btli1_l8_pptx_gen.py (re-runnable generator).

**Quiz lesson_id linkage (Model X, Inv #84):** the quiz seed includes a post-INSERT UPDATE setting `lesson_id` from `pipeline_lessons` by (track+level, lesson_number). **Run order matters: lesson_library_seed.sql FIRST, then quiz_seed.sql** — otherwise `lesson_id` is NULL (re-run quiz seed to fix; idempotent).

**Next build:** L9 Evangelism at Discipleship (lesson map drives sequencing; memory verse Mateo 28:19).

**Established May 22, 2026 (Session 15).**

---

### **87. BTLI 1 Lesson 9 shipped — Evangelism at Discipleship**

L9 (Evangelism & Discipleship / Evangelism at Discipleship: Ano ang Bahagi Ko sa Ispiritwal na Pag-usbong at Pag-usad ng Ibang Tao?) is COMPLETE as the full 8-deliverable set in `lessons/btli101_xrw5fg/` (same cohort folder, per Invariant #71). Built direct with Claude (no Gemini), browser-verified (Inv #80) and PPTX render-verified (Inv #82) before close, against the deployed L7 templates (Pastor's uploaded copies) for zero drift.

**Locked row:**
- Title: "Evangelism & Discipleship / Evangelism at Discipleship: Ano ang Bahagi Ko sa Ispiritwal na Pag-usbong at Pag-usad ng Ibang Tao?"
- Memory verse: **Mateo 28:19–20** — the Great Commission.
- Character anchor: **Katapatan (Faithfulness)** — a broad Christian virtue, source-deep, NOT a Galatians-cycle lock (per Invariant #75). *Skeleton had proposed "Love"; revised to Katapatan at build-time from honest source reading + Pastor's call — the sin the source warns against is **abandonment** ("hindi ka magsisilang ng bata para lang makita itong manghina at mawala"), and Love was over-subscribed (L19, L20). 2 Timoteo 2:2 anchors the multiplication mark.*
- Competence anchor: **One Verse Evangelism (Navigators, Roma 6:23)** — native to the source (TUGON → Appendix A), framed inside the source's own two-part map: **PAGHAYO (Evangelism — sugo/saksi)** + **PAGHUBOG (Discipleship — spiritual parenthood, Ina/Ama, 3 verbs Pagpapayo/Pagpapalakas/Paghamon).** The "two-sides-of-one-coin" hinge is the conceptual spine.
- GRACE stage: **C→E** (Cultivate → Extend — the multiplication hand-off lesson; first lesson where the disciple looks down-pipeline at making disciples who make disciples).
- Flow: 5-movement PUKAW(8)/TUKLAS(18)/TALAKAY(12)/TUGON(12)/DALHIN(10) = 60 min (USAD's 4-movement TANAW/TUKLAS/TALAKAY/TUGON wrapped with Claude-added PUKAW + DALHIN per Invariant #76).

**Three Circles deferral (Pastor decision, Option 2):** Three Circles (Designed/Damaged/Restored) is NOT taught in L9 — only a one-line courtesy mention deferring it to **L20** (Telling the Good News), which has room for a full second method and pairs it with its existing *Personal Story Crafting* competence. L9 teaches One Verse Evangelism only. Note this against the L20 row when L20 is built.

**Distinctive content:** the abandoned-baby TANAW story used as a **delayed reveal** (its spiritual-abandonment meaning is withheld until DALHIN's "may spiritual infant ba na *ikaw* ang nag-iwan?" — the emotional peak); "Hindi ka iniligtas para lang pumunta sa kalangitan" big idea; S.S.S. Christianity rebuttal; sugo/saksi (2 Cor 5:20 / Gawa 1:8 / Efeso 6:15 footgear); 1 Tes 2:7-12 Ina/Ama; "People don't care how much you know until they know how much you care"; the One Verse Evangelism Roma 6:23 drawing (kabayaran/kasalanan/kamatayan ✝ kaloob/Diyos/buhay); Pangako Ko ("Hindi ako magiging S.S.S. Christian…").

**Pastoral-care guardrail (new content concern, codified here):** the abandonment theme can trigger real wounds (abandonment, miscarriage, estranged child). Both the facilitator and intern guides carry rose pastoral-care boxes mandating **conviction tungo sa pag-asa, hindi guilt-trip**, and private follow-up for anyone affected. Any future lesson touching abandonment/loss/grief themes should carry the same guardrail.

**8 deliverables:** participant.html, facilitator.html (4-mode toggle + 6-Sources-of-Influence grid), intern.html (5 briefing cards incl. emotional-sensitivity card + 5 per-movement obs + 3 critical-watch [2 amber + 1 rose care] + 5 self-reflect), slides.html (16 slides, shared nav module per Inv #74), slides.pptx (16 slides + 16 speaker notes, render-verified per Inv #82), btli1_l9_quiz_seed.sql (8 MC + 2 TF, canonical shape per Inv #73; TF Q9=false, Q10=true; lesson_id linkage per Inv #84), btli1_l9_lesson_library_seed.sql (5 attachments, audience cohort_only), smoke_test.md. Plus btli1_l9_pptx_gen.py (re-runnable generator).

**Deploy order:** run `btli1_l9_lesson_library_seed.sql` FIRST (creates the pipeline_lessons row), then `btli1_l9_quiz_seed.sql` (links `lesson_id` back to it). Out-of-order → lesson_id NULL; re-run quiz seed (idempotent).

**Next build:** L10 Ministry — Paglilingkod sa Diyos at Kapwa (lesson map drives sequencing; memory verse per L10 row).

**Established May 22, 2026 (Session 16).**

---

### **88. BTLI 1 Lesson 10 shipped — Ministry: Paglilingkod sa Dios at Kapwa**

L10 (Ministry: Serving God & Others / Paglilingkod sa Dios at Kapwa: Ano ang Tunay na Kahulugan ng Paglilingkod?) is COMPLETE as the full 8-deliverable set in `lessons/btli101_xrw5fg/` (same cohort folder, per Invariant #71). Built direct with Claude (no Gemini), browser-verified (Inv #80) and PPTX render-verified (Inv #82) before close, against the deployed L7 templates (Pastor's uploaded copies) for zero drift. **This is the finale of the BTLI 1 first half (USAD spine, L1-L10); L11 begins the leadership-formation half (UNLAD spine).**

**Locked row:**
- Title: "Ministry: Serving God & Others / Paglilingkod sa Dios at Kapwa: Ano ang Tunay na Kahulugan ng Paglilingkod?"
- Memory verse: **Marcos 10:45** (the source's own cover + closing verse — corrected from the skeleton's leftover Mt 28:19).
- Character anchor: **Goodness (Kabutihan)** — a broad Christian virtue, NOT a Galatians-cycle lock (per Invariant #75). *Skeleton had proposed "Self-Control"; revised to Goodness at build-time from honest source reading + Pastor's standing instruction. The lesson's heart is glad, whole-hearted service made **useful to others** (1 Pet 4:10 "para sa benefit ng iba"; 1 Cor 6:20 buhay/lakas/talino "upang maparangalan ang Diyos"), not restraint. This honors Pastor's own lesson-map flag ("L10 could move to Goodness — good works prepared beforehand"). Self-Control was rejected (symptom, not heart); Faithfulness rejected (just used at L9); Joy rejected (already L3+L11).*
- Competence anchor: **The Bondservant Path** — 4 steps: **Suriin → Tuklasin → Itugma → Ipangako**. Routes the platform's Spiritual Gift Survey + SGA (Appendix B) + Ministry Covenant (Appendix C) through the source's own bondservant theology (4 servant classes: Slave/Hireling/Servant/Bondservant; bondservant = Paul's self-title, Exo 21:5-6).
- GRACE stage: **C→E** (Cultivate → Extend — the BTLI-1-first-half finale; hands off to gift-aligned ministry / BTLI 2).
- Flow: 5-movement PUKAW(8)/TUKLAS(18)/TALAKAY(12)/TUGON(12)/DALHIN(10) = 60 min (USAD's 4-movement TANAW/TUKLAS/TALAKAY/TUGON wrapped with Claude-added PUKAW + DALHIN per Invariant #76).

**Three Circles decision (Pastor gave the call, Claude declined for L10):** Three Circles is NOT taught in L10 — it stays parked at L20 exactly where L9 deferred it. Rationale: L10 is a ministry/service lesson, not evangelism — a topical mismatch. The Jim Elliot / 5 Auca martyrs story (DALHIN) carries the "service unto death → multiplication" weight that closes the USAD half. This confirms the "Self-Control ×3 over-distribution" worry from the lesson map is now fully dissolved: L8 shipped as **Generosity**, L10 now **Goodness** — Self-Control no longer over-assigned.

**Distinctive content:** Polycarp martyrdom (PUKAW, "mamatay-naglilingkod o mabuhay-tumatalikod?"); DNA ng Ministry (diakoneo + douleuo); Roma 12:11 *maningas*; 4 servant classes with gold-highlighted bondservant; volunteer-vs-servant contrast ("walang 'quit' sa diksyunaryo"); 4 reasons (binigyang-buhay/kalayaan/pagpapala/halimbawa); the Bondservant Path; "Kailan Pa?" Papuri Singers prayer of commitment; Jim Elliot quote ("Hindi mangmang ang taong nag-aalay…"); EOLO "S" = Serve (BLESS) bridge; 7-Araw Service Watch; Pangako Ko ("Bondservant ako ni Cristo… walang 'quit'").

**8 deliverables:** participant.html, facilitator.html (4-mode toggle + 6-Sources-of-Influence grid), intern.html (5 briefing cards incl. Goodness-vs-Self-Control rationale card + emotional-sensitivity card + 5 per-movement obs + 3 critical-watch [2 amber + 1 rose pastoral-care] + 5 self-reflect), slides.html (16 slides, shared nav module per Inv #74, data-notes-label "BTLI 1 · L10"), slides.pptx (16 slides + 16 speaker notes, render-verified per Inv #82 — solid fills, no transparency trap), btli1_l10_quiz_seed.sql (8 MC + 2 TF, canonical shape per Inv #73; TF Q9=false, Q10=true; lesson_id linkage per Inv #84), btli1_l10_lesson_library_seed.sql (5 attachments, audience cohort_only), smoke_test.md. Plus btli1_l10_pptx_gen.js (re-runnable generator).

**Deploy order:** run `btli1_l10_lesson_library_seed.sql` FIRST (creates the pipeline_lessons row), then `btli1_l10_quiz_seed.sql` (links `lesson_id` back to it). Out-of-order → lesson_id NULL; re-run quiz seed (idempotent).

**Established May 22, 2026 (Session 17).**

---

### **89. BTLI quiz-gate audit — attendance patterns MUST be full-form (no `%`), and every quiz MUST link lesson_id**

Two systemic data-hygiene rules for `btli_quizzes`, learned by debugging a real incident (Session 17): an unenrolled member saw L9's quiz unlocked.

**Root cause chain (instructive — keep in mind for every new quiz seed):**
1. **The eligibility gate uses JavaScript `String.includes(pattern)`, NOT SQL `LIKE`.** So `attendance_event_name_pattern` must be a literal **substring** of the real attendance `event_name`. A `%` in the pattern is a literal percent character there — it matches nothing. L5/L6/L7 had `%`-wildcard patterns (`BTLI 1 · L5%`) that silently disabled their drop-in (attendance fallback) gate. Fixed to full form.
2. **A BLANK `attendance_event_name_pattern` triggers the `no_gate` escape hatch** (shared.js `_btliComputeOne`, "historically always-unlocked"): it returns `eligible: true` for **every unenrolled member**. L9's pattern was NULL → that's why an unenrolled member saw "Take Quiz" on L9 (and only L9 — the one with the blank pattern). Fixed by setting the pattern.
3. **A NULL `lesson_id` makes the Model X participant lesson-lock inert** (Inv #84): an enrolled participant's quiz is supposed to be gated by the linked lesson's unlock, but with no `lesson_id` there's nothing to lock against, so it falls through to "always open for enrolled." L8, L9, L10 all had NULL `lesson_id`. Back-linked all three.

**The rules (apply to every quiz row, every new seed):**
- **Attendance pattern convention is FULL FORM:** `BTLI 1 · L<n> · <Title>` (e.g. `BTLI 1 · L9 · Evangelism at Discipleship`). The `·` is **U+00B7 MIDDOT** — must match the live attendance event-name convention exactly (verified against the only real lesson-attendance row on file, `BTLI 1 · L1 · Pananalangin`). NEVER use `%`. NEVER leave blank (blank = unlocked-for-all-unenrolled).
- **Full form (with title) also prevents substring cross-matching:** the stem `BTLI 1 · L1` is a substring of `BTLI 1 · L10`, so a stem-only pattern would let L1 attendance unlock L10. The title suffix makes each pattern unambiguous under `includes()`.
- **Every quiz MUST have `lesson_id` linked** to its `pipeline_lessons` row (by track+level, lesson_number). The L10 seed template does this in a post-INSERT UPDATE; copy that pattern for all future seeds.
- **Audit query** (run after any quiz seed): `SELECT lesson_number, attendance_event_name_pattern, lesson_id, (attendance_event_name_pattern LIKE '%\%%' ESCAPE '\') AS has_literal_percent FROM btli_quizzes WHERE course_code='BTLI 1' ORDER BY lesson_number;` — expect `has_literal_percent=false` and non-null `lesson_id` for every row.

**Known still-open (Session 17, not blocking):** the `no_gate` escape hatch itself still exists in `_btliComputeOne` (a blank pattern still means unlocked-for-all). Defended for now by ensuring every quiz has a pattern, but a future hardening could make `no_gate` default to **blocked** instead of eligible — a platform-wide shared.js change, to be diffed and shown before touching. Also: 3 generic `BTLI` attendance rows (no lesson number) exist and match nothing (safe).

**Also fixed Session 17 (not invariant-worthy, logged in HANDOFF):** MLT Add Member now refetches via `loadMyMembers()` on save success (replacing a fragile optimistic `myMembers.unshift` that vanished on the next re-scope, causing users to think the save failed and create duplicates); L9's lesson **attachments** were reinserted by mirroring L7's exact shape (fields `url`/`label`/`role_required`, values `all`/`apprentice+`/`teacher+` — NO `kind` field).

**Established May 22, 2026 (Session 17).**

---

### **90. MMT self-attest event parity + lesson sub-picker + LCG attendance report (member-facing)**

Session 18 brought MMT's "I'm here" self-attest card to parity with MLT's attendance events, and added a member-facing LCG attendance report. All in `member_tool.html`. These are now standing behaviors:

**Event list (member-facing self-attest):** the picker offers a **fixed 9-event list** — 7 plain (Sunday Service, LC Meeting, Sunday School, Prayer Meeting, Youth Gathering, Team Building, Outing) + 2 lesson-bearing (BTLI, Pre-Pipeline). It **mirrors MLT's 10-event list minus "Other"** (a leader catch-all, meaningless for self-attest, per Pastor's call). The list is **defined in MMT code** (`ATTEST_EVENT_TYPES`), NOT read from `system_settings.meta.attendance_event_types` anymore — the meta config was partial, and a hard list guarantees MMT/MLT match. (Each entry carries `label_en`/`label_tl` resolved fresh per render so language toggle is live.)

**Lesson sub-picker + enrollment gate (the load-bearing rule):** BTLI and Pre-Pipeline are **mutually exclusive per member** and **enrollment-gated** — a pill is HIDDEN entirely unless the member has ≥1 attestable lesson in that track (the L0→Pre-Pipeline / L1+→BTLI rule means only one is ever populated). "Attestable" reuses the SAME quiz-fetch + `eligibilityForMany` pattern as `renderBtliQuizzes`/`renderUsbongQuizzes` (the "My Lessons" filter), and the gate is precisely **`elig.enrolled === true && elig.reason === 'enrolled'`** — i.e. enrolled AND unlocked. `reason==='lesson_locked'` (enrolled but batch hasn't released) and any non-enrolled reason are EXCLUDED ("only unlocked", Pastor's explicit rule). Tapping a lesson pill opens a sub-picker of those lessons; picking one routes through the normal confirm/save with the canonical `event_name` carried via a module-level `_pendingAttestEventName` var (set by `_pickAttestLesson`, read+cleared in `_doSaveAttest` — never threaded through inline onclick to avoid middot/apostrophe escaping bugs).

**Canonical event_name on lesson self-attest:** `${course_code} · L${lesson_number} · ${lesson_title}` with **U+00B7 middot** (Inv #53), built from the quiz row — byte-identical to MLT's, so the quiz-gate (Inv #89) fires the same. Member-scoped, **no batch** (Pastor's Option 1 — self-attest = "I was there"; batch state stays the LCL's job). Dup-check includes `event_name` for lesson events (two lessons can share a date); plain events keep `(member_id, event_type, event_date)`.

**LCG attendance report (member-facing, "team spirit alive"):** lives in the LC detail sheet (opened from the LCG card) as an **LC ATTENDANCE** section. Echoes MLT's attendance report (2) — period chips (This Month / Last 30 / Last 90), LCG-wide rate headline, per-member rate rows ranked desc with color bars (green ≥80, gold ≥50, red below), no-data members last, viewer's own row tagged **YOU**. Collapsed by default (`_lcAttExpanded`), tap to expand. Scoped to the **You-inclusive LCG roster** (`memberRow` + `lcMembers`, already privacy-filtered by `share_with_lc` and test/guest-contained from Inv #69-derived logic). **Read-only — NO CSV** (export stays a leader tool). Re-renders on language toggle only when the sheet is open.

**Also shipped Session 18 (same cumulative `member_tool.html`):** Prayer of the Day card (replaced "Verse of the week" — 30-prayer local pool, God's Word prayed back in first person, the member's active EOLO name woven in via `{name}` slot, rotates daily by day-of-year, fallback "my EOLO"/"EOLO ko" when no EOLO names; pure-local, no DB call); LCG card name fallback to LCL's name (#59-aligned — `_lcgDisplayName()`: lc_group text else "{discipler first name}'s LCG"); LCG flock fix (dropped a stale `pipeline_level >= 1` gate that was hiding Pre-Pipeline co-disciples, + viewer-aware test containment via `_viewerIsTestMember()`, + guest exclusion); member count now includes the viewer (+1) with a YOU row in the family list and correct singular/plural ("1 member" not "1 members"; TL "miyembro" never pluralized).

**Established May 23, 2026 (Session 18).**

---

### **91. Lesson-attest resolution logic is SHARED in `multiply_shared.js` — UI stays per-file (DONE, Session 19)**

The same self-attest logic was about to be copied from MMT into MLT's L5 pastoral-staff card; Pastor flagged the duplication. **Done as of Session 19 (May 25, 2026):**

- **EXTRACTED to `multiply_shared.js`** as `MultiplyShared.attest.attestableLessons(memberId)` → `{ 'BTLI': [...], 'Pre-Pipeline': [...] }`, each lesson `{event_name, lesson_number, lesson_title, course_code}`, included iff `eligibility.enrolled === true && eligibility.reason === 'enrolled'` (Pastor's "only unlocked" rule). Runs the real `btli`/`usbong` `eligibilityForMany` (so Model X lesson-lock Inv #84, forming-cohort lockstep Inv #85, U+00B7 event_name Inv #53 all hold). Fails open-as-empty, never throws.
- **Also exported `MultiplyShared.attest.EVENT_TYPES`** — the canonical 9-event list (MLT's 10 minus "Other"). Single source of truth so MMT/MLT never drift (Inv #90 moved MMT off the partial `system_settings.meta.attendance_event_types`; this replaces it for both).
- **And `MultiplyShared.attest.defaultEventDate(eventTypeKey)`** — see Invariant #92.
- **UI stays per-file** (Inv #56): MMT keeps its card + 14-day picker; MLT L5 keeps its cream-on-dark card + date field + sub-picker. Both now thin-wrap the shared helper (MMT `_loadAttestableLessons`, MLT `_loadL5AttestableLessons`), each with a defensive inline fallback if a stale shared.js is deployed first.
- **Write semantics unchanged & still divergent:** MMT `insert` + `source:'self_attest'` + LCL confirm/nudge flow; MLT L5 `upsert` on `(member_id,event_type,event_date)`, no `source`, no nudge — pastoral attendance final.
- **MLT L5 upgrade shipped:** date field (today default, pickable), 9-event list, BTLI/Pre-Pipeline lesson sub-picker gated on enrolled+unlocked.

**Deploy order:** `multiply_shared.js` FIRST, then the HTML files (fallbacks make order non-fatal, but shared-first guarantees the canonical path).

**Established May 23 (Session 18) as candidate; DONE May 25, 2026 (Session 19).**

---

### **92. Self-attest event DATE snaps to the most-recent-past occurrence — never blind "today"**

**The bug (Session 19):** members tapped "I'm here" on **Monday** for **Sunday Service**, so the row saved with `event_date = Monday` instead of Sunday. Root cause: MMT's `_attestLastTypicalDay()` (and MLT's `_l5LastTypicalDay()`) had been **stubbed to always return today**, ignoring the typical-day argument the pills faithfully passed. Three mis-dated rows accumulated in Pastor's LCG alone before it was caught.

**The rule (canonical helper `MultiplyShared.attest.defaultEventDate(eventTypeKey)`):**
- Fixed-weekday events carry a `snap_day` (JS `getDay()`: 0=Sun … 6=Sat) on `EVENT_TYPES`: **Sunday Service → 0, Sunday School → 0, Prayer Meeting → 3 (Wed)**. The helper returns the most-recent-past occurrence of that weekday **including today** (tap on the day itself → today; never a future date).
- Events **without** `snap_day` (LC Meeting — day varies per group; Youth Gathering / Team Building / Outing — one-offs; BTLI / Pre-Pipeline — variable lesson days) → default to **today**, corrected via the visible picker.
- Always **local-time** date (never `toISOString()` — Manila UTC+8 returns yesterday before 8 AM PHT).

**Option-3 UX (both tools):** the snapped date is the *default*, but the date stays **visible and editable** — MMT via its confirm dialog + 14-day "Different date?" picker (typical day starred, `SELF_ATTEST_WINDOW_DAYS = 7` forces the picker when out of window); MLT L5 via its date field, which auto-snaps on pill tap UNLESS the leader manually edited it (`_l5DateManuallySet` flag respects explicit choice).

**NEVER re-stub these to "always today."** If a "tap while at the event" simplification is ever wanted again, gate it behind a flag — do not delete the snap.

**Established May 25, 2026 (Session 19).**

---

### **93. On hardcoded light/white surfaces in MLT/MMT, text MUST use dark hex — never `var(--text)`/`var(--muted)`**

MLT/MMT run a **dark** theme (`--text: #f0f0f8`, `--muted: #8888a8`). Any element with a hardcoded light background (`background:#fff`, cream gradients, `var(--paper)` light cards) that sets its text to `var(--text)` renders **light-on-light = invisible**. This trap has now bitten **four** times: the May 16 fix, the L5 buttons (Session 19), the Pending Confirmations member name + dispute-modal reason buttons/input (Session 19), and counting.

**Rule:** on any light/white surface, use **dark hex** for text: `#1a1612` (primary ink), `#6b6b80` (muted), `#7a5800`/`#3a2c0a` (cream-card browns). Reserve `var(--text)`/`var(--muted)` for elements on `var(--surface)`/`var(--bg)` (genuinely dark) surfaces. When adding a white-bg button, **always** set an explicit `color:` — inheritance defaults to the near-white `--text`.

Verified contrast on the Session 19 fix: `#1a1612` on white = **17.99:1** (WCAG AA needs 4.5:1).

**Established May 25, 2026 (Session 19).**

---

### **94. MD audience picker: human labels only, combined A–Z, filter-aware Select All**

The Compose & Publish audience picker (MD) and its chips show **human labels, never raw ids/slugs** (Inv #87 family). Specifics, as built Session 19:
- **Virtual LCL groups** (an LCL's flock with no `lc_group` set) are labelled **`{first name}'s LCG`** via `_lclLcgLabel(name)` — Inv #59's fallback — with correct possessive for trailing-s names (`James' LCG`, not `James's`). Set at the **source** (`_ensureAudPickerCache`) so the picker list, the chip, and the recipient summary always agree. Chip fallback (pre-cache) resolves the LCL's name too, or `an LCG` last-resort — **never a uuid**. `openPastorAnnComposer` primes the cache so labels are correct on first paint (reopened drafts).
- The picker list is **combined A–Z** (real + virtual interleaved by display label, case-insensitive); **no `(virtual)` tag**.
- **Filter-aware "Select all"** header (`_audPickerSelectAllVisible`) toggles only currently-visible rows (respects the search box → doubles as "select all matching"); union preserves selections hidden by the filter. Generic across lc_groups / member_ids / ministries.

**Established May 25, 2026 (Session 19).**

---

### **95. `no_gate` quiz eligibility fails CLOSED on misconfiguration; fails OPEN only on infra error**

The hybrid eligibility gate (Inv #35) has a `no_gate` branch for quizzes with a NULL/empty `attendance_event_name_pattern`. Two distinct failure modes must be handled oppositely:

- **Misconfiguration** (a real quiz row with no attendance pattern AND the member is not enrolled): `_btliComputeOne` / `_usbongComputeOne` MUST return **`eligible: false, dropIn: false, reason: 'no_gate'`**. An access gate must lock OUT when misconfigured, never IN. *(Before Session 20 this returned `eligible: true` — the latent hole from Inv #89's Christine incident. The data layer happened to be clean, MMT trusts `elig.eligible` with no enrollment backstop, so a single NULL-pattern quiz seed would have unlocked it for every member.)*
- **Infra error** (the eligibility call itself THROWS — DB outage, network): the caller's catch (MMT `renderBtliQuizzes`/`renderUsbongQuizzes`, `btli_quiz_player.html`) MAY fail OPEN (`eligible: true`) — per Inv #84, "locking is a deliberate state, never a failure state." Don't punish the whole church for a transient outage.

**The `reason: 'no_gate'` value is RETAINED** (not collapsed into `'blocked'`) so a misconfigured quiz is diagnosable in logs/UI, distinct from a correctly-gated lockout. MMT's generic lock branch renders both identically to the member.

**Rule for future curricula / gates:** every new eligibility helper must make the no-pattern-and-not-enrolled case fail closed, and reserve fail-open strictly for thrown infra errors in the caller.

**Established May 25, 2026 (Session 20).**

---

### **96. Self-attest duplicate guard is source-agnostic and fails CLOSED; LCL log is authoritative**

A member can self-attest an event their LCL also logged. The `attendance` UNIQUE key is `(member_id, event_type, event_date)` and **ignores `source`**, so the dup-check must too. MMT `_doSaveAttest`:

- The dup-check query filters by `member_id + event_type + event_date` (plus `event_name` for lesson events) with **NO `source` filter** — an existing row of ANY source blocks the insert.
- It **FAILS CLOSED**: if the dup query throws, abort the insert ("couldn't verify, try again") rather than `catch → proceed`. A duplicate-guard that inserts-on-error is no guard.
- When the existing row is **leader-logged** (`source !== 'self_attest'`): show "✓ your leader already recorded this — nothing more to do" (TL: "Naitala na ito ng leader mo…") and **skip the nudge** (the LCL who logged it needs no ping). **LCL log is authoritative; self-attest is backup — never overwrite an `lcl_logged` row.**
- The member's home picker loads leader-logged slots separately (`_leaderLoggedSlots`, fail-soft) so a slot the LCL already filled renders as a dimmed, non-tappable "by leader ✓" tile, not an inviting button. The member's own self-attest pill still takes precedence.

Companion to Inv #92 (date-snap fixed the *date*; this fixes the *cross-source double*).

**Established May 25, 2026 (Session 20).**

---

### **97. Pending/parked notes are hypotheses, not facts — verify against live data and deployed files before acting**

HANDOFF pending/parked notes and the lesson-map skeleton age. Production data heals, files get retrofitted, and "known gaps" get closed in ways the note never captured. **Before acting on any note, verify it against the live source of truth** — a read-only DB query, the deployed file, or `schema.json` (Inv #42/#56).

**Session 20 evidence (four notes retired-by-investigation, zero work needed):**
- "BTLI L11 needs building / upload UNLAD-L11 scan" → L11 was already shipped (mislabeled as L1); the real task was a rename. There is no UNLAD-L11 (UNLAD spine is L1–L10 → BTLI L11–L20).
- "L2 Usbong row has `level=NULL`; L2 has no quiz" → data self-healed (all 10 rows `level=0`, all 10 have quizzes).
- "L4/L5 have the slider script but no widget" → L4 was already fully retrofitted.
- "`btli_quiz_player.html` deep-link lock is a known gap" → the lock was already enforced; only the blocked-state message was wrong.
- Also: `schema.json` itself can be stale (generated May 20; missed the Session-14 `btli_quizzes.lesson_id` column) — confirm doubtful columns with a live `SELECT`.

**The cost math (per Inv #56):** a verification query/read costs ~10 seconds; acting on a stale note costs a wrong edit, a regression, or churn on a non-bug. **When a note and the live system disagree, the live system wins** — then update the note. Retiring a stale note is a legitimate, valuable session outcome, equal to a ship.

**Established May 25, 2026 (Session 20).**

---

### **98. Usbong lesson-lock bridges on `(track='Usbong', lesson_number)` — the track string is literally `'Usbong'`, NOT `'Pre-Pipeline'`**

`usbong_quizzes` has NO `lesson_id` column (unlike `btli_quizzes`). To enforce Model X participant lesson-lock for Usbong, `_usbongComputeOne` bridges quiz→lesson via `pipeline_lessons` matched on `(track = 'Usbong', lesson_number)`. **The `pipeline_lessons.track` value is the literal string `'Usbong'`** — even though the curriculum is *labelled* "Pre-Pipeline" everywhere in human text. Using `'Pre-Pipeline'` as the track string silently returns an empty lesson-id map → every Usbong quiz fails OPEN (re-opens for all enrolled, defeating the lock). This is a silent footgun: wrong string, no error, wrong behavior — the same class as the `%`-wildcard attendance trap (Inv #89).

- The bridge relies on `lesson_number` being unique/1:1 within the Usbong track.
- **Durable fix someday:** add a `usbong_quizzes.lesson_id` FK (mirroring `btli_quizzes`) and drop the bridge. Until then, never "correct" `'Usbong'` to `'Pre-Pipeline'`.
- Participant lock mirrors BTLI: staff (teacher/co-teacher/apprentice) bypass; an unresolved lesson (not in the map) falls back to enrolled-open, never staff-open.

**Established May 28, 2026 (Session 21).**

---

### **99. Habit-nudge forcefulness is tuned to audience: forceful-with-escape for leaders, gentle for members**

The platform now has three boot-time habit nudges. Their assertiveness is deliberately calibrated to who they address, and **none is ever a hard, un-escapable block** (a data-read bug must never lock out a whole audience):

- **Leaders (MLT) — forceful-with-escape.** The weekly attendance gate (Inv #100) confronts the L2+ leader on open with what's unlogged, reappears each open while items remain, but always carries an "I'll do this later" escape. Leaders are accountable; the nudge is insistent.
- **Members (MMT) — gentle.** The devotional-reflection reminder is a warm, dismissible modal — same *visual idiom* as the leader wall (centered card) for cross-app consistency, but encouraging in tone ("A space for your heart"), with a prominent "Maybe later." Members are in a more tender place; a hard block on a devotional habit reads as guilt, not care.

**Universal rule for all nudges: fail-soft.** If the underlying check errors, show NO nudge — never nag on data you couldn't actually read. Dismissals are session-only (not persisted): a fresh open is a fresh gentle invitation, never permanent silence.

**Established May 28, 2026 (Session 21).**

---

### **100. Weekly attendance gate (MLT, L2+) uses a service-WINDOW model, always backward-looking; LCG is rolling-7-day + waivable**

The MLT boot gate (`runWeeklyAttendanceGate` in `lc_leader_tool.html`) checks three things THIS leader personally logged (`logged_by_id = me`, `present = true`), each a separate `attendance` query:

| Check | `event_type` | Window | Waiver |
|---|---|---|---|
| **Sunday** | `Sunday Service` | opens Sun **12 noon**, closes next Sun **8 AM** (1h before 9 AM service) | none |
| **Wednesday** | `Prayer Meeting` | opens Wed **10 PM**, closes next Wed **6 PM** (1h before 7 PM service) | none |
| **LC meeting** | `LC Meeting` | rolling **last 7 days** | "No LC meeting this week" → localStorage, expires next Sun 00:00 Manila |

- **Service-window model (config in `WAG_SERVICES`):** each service has `{dow, openMin, closeMin}`. The active obligation is the most recent occurrence of that weekday whose window is currently open. **Always backward-looking** — fixes the original "defaults forward" bug where Sunday+3 pointed at a *future* Wednesday on Mon/Tue.
- **Quiet gap:** on the service day between the prior window's close and the new window's open (Wed 6–10 PM, Sun 8 AM–noon), the resolver returns null → that line is HIDDEN (no nag during/just-after the service).
- **Dated labels:** each line names the actual date ("Sunday service — June 7") so the leader knows exactly which meeting to log.
- **Scope decisions (Pastor, Session 21):** any attendance the leader *personally* logged for their members counts (`logged_by_id` match, not "any record exists"); each of the three is independent (clearing one doesn't clear others); forceful-with-escape, not a hard block.
- All Manila-local (UTC+8); event-type strings are the canonical `Sunday Service` / `Prayer Meeting` (Wednesday!) / `LC Meeting`.

**Established May 28, 2026 (Session 21).**

---

### **101. The MLT boot wall is ONE merged modal: attendance + unread announcements (Tier-2)**

To avoid stacking two separate boot modals on an L2+ leader, the weekly attendance gate and the unread-announcements alert are merged into a single modal (`_wagRenderModal` takes `missing` + `unreadAnns`). It shows if EITHER section has items; the announcements section lists unread items with "✓ Acknowledge" buttons that write via the canonical `announcement_acks` upsert (Inv #65, state `acknowledged`) and re-run the gate. One shared "I'll do this later" escape.

- **Boot order matters:** `_loadInbox()` runs FIRST (also lights the 📣 quick-action badge — Inv #102), THEN `runWeeklyAttendanceGate()` (in a `.finally`), so the gate can read the already-loaded `_annInbox` for unread items.
- Boot-wall ack uses a dedicated `_wagAckAnnouncement` (NOT `_setAnnouncementState`, which calls the inbox-modal renderer that isn't open at boot).

**Established May 28, 2026 (Session 21).**

---

### **102. Announcement unread surfacing must load at BOOT, not only inside `openAnnouncements()`**

`_loadInbox()` + `_updateAnnQuickActionBadge()` originally ran only inside `openAnnouncements()`, so the unread badge never appeared until a leader had already opened the inbox — useless as a nudge (the leader who never opens it sees nothing). They now also run at MLT boot (L2+, fail-soft, after `renderHome` paints the `.qa-btn` the badge anchors to). The badge system itself (count, "9+" cap, PWA app-icon badge) was already built; the bug was purely that it was never triggered at startup. **Any "unread/pending count" surface must be computed at boot, not lazily on first open of the thing it's notifying about.**

**Established May 28, 2026 (Session 21).**

---

### **103. BTLI participants must be Zone 1 (salvation-assured); gate lives in `canEnroll`, scoped to BTLI, applies to all enrollers; MD override bypasses by NOT calling canEnroll**

BTLI enrollment requires the candidate's `diagnostic_zone === 1`. Because `diagnostic_zone` IS the salvation-assurance diagnostic result (the field and the "zone" are the same thing — `lc_leader_tool.html` line ~1140 maps salvation→`diagnostic_zone`), this single check enforces BOTH of Pastor's requirements at once: (a) the diagnostic has been taken (field is set) AND (b) the result is the assured tier (Zone 1; Zones 2–4 escalate toward needing pastoral care).

- **Pastoral basis (Pastor, Session 21):** disciple those assured of and bearing the fruits of their salvation, so we don't push the not-yet-assured through the pipeline (the John-the-Baptist principle). The path forward for a blocked disciple is the existing **debrief → remedial → retake** loop, NOT a bypass. This honors the "AI is a conversation starter, not a verdict" principle because the diagnostic is a shared, transparent checkpoint the LCL and disciple work toward together — not a silent AI judgment.
- **Scope:** the gate fires ONLY for BTLI programs (identified by `program.btli_course_code` being non-null). Usbong and all other programs are untouched — new converts haven't done the diagnostic yet, which is the *point* of Usbong. The level-match check (Inv #84/program level) still fires first.
- **Applies to everyone via `canEnroll`, including Pastor** — there is NO `isPastor` bypass inside the gate. Even the one LCL who hasn't taken the diagnostic must reach Zone 1 before classes.
- **Pastor's MD override works by a DIFFERENT mechanism:** MD's `_coAddRosterMember` inserts directly into `cohort_members` and **never calls `canEnroll`**, so it bypasses this gate entirely. This is the *only* way to enroll L2+ leaders as BTLI participants (for re-formation "as though starting over") — the hard level-match in `canEnroll` would block them too. The gate therefore affects the **MLT LCL pickers only**, exactly as Pastor intended ("gate affects only the LCL picker, not me").
- **Candidate object footgun:** every `canEnroll` call site must build its candidate with `diagnostic_zone` (alongside `id`, `pipeline_level`). Omitting it makes the gate see `undefined` and wrongly block EVERY BTLI enrollment — even legitimately Zone-1 disciples. All four MLT call sites now pass it (per-disciple picker build + save re-check; batch picker build + save).

**Established May 28, 2026 (Session 21).**

---

### **104. MLT enroll pickers show ALL scoped members with advisory eligibility badges — never hide the ineligible**

The batch→members picker (`_renderBatchesAddMember`, reached via My Batches → Manage → Add Member) classifies EVERY scoped member via `canEnroll` and renders them all, instead of filtering to only-eligible. Eligible → green "+ Enroll"; blocked → a dimmed card with an advisory badge + the next shepherding step:

- **NEEDS L1** (level mismatch) → "Open their Profile → ✎ change level to set L1" (the common "just flip them" case — Inv re: L0↔L1 LCL toggle).
- **✝️ NEEDS ZONE 1** → "debrief + remedial, then retake" (or "send the diagnostic after Usbong" if none taken).
- **ALREADY ENROLLED** → so nothing is mysteriously missing.

Sort order: eligible → actionable-level → zone → enrolled. Header shows the eligible count. **Rationale (Pastor, Session 21):** hiding ineligible members leaves the LCL puzzled ("No eligible members" dead-end); showing them with a reason turns the gate into a conversation starter and surfaces the cases that just need an L1 flip. The per-disciple picker (`openEnrollPicker`) carries the same spirit via `levelMismatch` + `needsZone1` hint boxes in both render states.

**Established May 28, 2026 (Session 21).**

---

### **105. After ANY structural (brace-level) JS edit, run a whole-file `node --check` of the inline script — targeted greps are not enough**

Session 21 shipped a `lc_leader_tool.html` that crashed on boot: a new `z1HintHtml` block was inserted *between* an `if(!eligible...)` opening and its body, collapsing `_renderEnrollPicker`'s brace structure. Targeted greps + jsdom-parse all passed (the broken token was syntactically ambiguous until end-of-function), but the file threw at load → "Leader Name / ? avatar / empty zone stats" (script halted before `renderHome`). **Verification discipline:** after any edit that moves or adds braces/template literals, extract the inline `<script>` blocks and run `node --check` on each separately (block 1 = main script) BEFORE shipping. This is Inv #80's spirit (verify, don't assume) applied to JS structure, not just rendering. A clean syntax check is necessary though not sufficient — also boot-test in jsdom when feasible to catch runtime throws (note: external `<script src>` like `multiply_shared.js` won't load in jsdom, so `MultiplyShared is not defined` there is expected, not the bug).

**Corollary — the identical failure screen has two causes:** "Leader Name / ? / empty zones" appears for BOTH (a) a syntax/runtime throw in MLT's inline script AND (b) `multiply_shared.js` failing to load (stale, missing, or mismatched deploy). When diagnosing, check both; and remember GitHub Pages + PWAs cache aggressively, so always hard-refresh / bump `?v=` before concluding the file itself is broken.

**Established May 28, 2026 (Session 21).**

---

### **106. Date KEYS are local-component; `MultiplyShared.dates` is the single source of truth**

Any `YYYY-MM-DD` date **key** (devotional `entry_date`, attendance default dates, report range bounds, browse-month) must be built from **local** date components via **`MultiplyShared.dates`** — `toYMD`, `todayYMD`, `parseYMD` (local midnight), `countDays`, `countWeekday`, `weeksBetween`, `mostRecentWeekday`. NEVER `toISOString().slice(0,10)` for a key (it's UTC: after ~4PM Manila it returns *tomorrow*; before 8AM it returns *yesterday* — the devotional-streak bug), and NEVER bare `new Date('YYYY-MM-DD')` (parsed as UTC midnight). `toISOString()` is correct ONLY for true **instants** (`*_at` timestamp columns) and server-side engine cutoffs. MMT/MLT/MAR consumers prefer the shared helpers with a local fallback; call sites untouched, only bodies swapped. **Established May 29, 2026 (Session 22).**

---

### **107. `MultiplyShared.svi` is the SVI read engine; the Care Radar is read-only — "care, not grade"**

`MultiplyShared.svi` exposes the zones — 🟢 thriving / 🟡 warming / 🔴 dormant / ⚪ onboarding — plus `actionFor(zone,trend)` (the action matrix), `careRank`/`sortByCare`, and `fetchLatest` (paginated to the newest `week_start`). The MD **Care Radar** READS `svi_snapshots` only — it never writes, and there is **NO `pastoral_override` column** (the design doc aspired to it; the migration never shipped it). Every SVI surface uses soft framing: a score or zone is a **conversation starter, never a verdict**. **Established May 29, 2026 (Session 22).**

---

### **108. Member Attendance Report denominator model + 100% clamp**

MAR rates use per-type denominators: **Sunday** = #Sundays in window; **Wednesday (Prayer)** = #Wednesdays; **LC** = #weeks (LC is weekly); **BTLI / Pre-Pipeline** = full **course size** (count of `btli_quizzes` / `usbong_quizzes` rows for the `course_code` — auto-grows as lessons ship); **Devotional** = days − Sundays (Inv #62); **Ministry** = rostered sessions. All percentages **clamped at 100%**. Lesson counts via head-count queries, fail-soft to "—". **Established May 29, 2026 (Session 22).**

---

### **109. Any bulk Supabase select that can exceed 1000 rows MUST paginate**

PostgREST hard-caps a response at **1000 rows**. An unpaginated `attendance` pull (211 members × 90 days, daily devotionals) silently truncated and **dropped real attendance** (the "doesn't tally for Marlon" bug — a genuine Sunday vanished). Paginate in 1000-row pages ordered by a stable key (e.g. `id`) until exhausted. Applies to every high-volume read; post-fix, real totals jump UP. **Established May 29, 2026 (Session 22).**

---

### **110. LC participation is TWO distinct roles — never conflate; never auto-credit *leading* into Gather**

A member's LC involvement splits into **learner** (being discipled in the *upline's* LC → **Gather** / `gather_lc`, logged by the upline) and **server/leader** (running *their own* LC → **Service** / `service_ministry_role`). The Session-22 "LC-leader auto-credit" (writing the leader present in their own LC) was **BUILT then RETIRED** because it (a) mis-credited *leading* into the *Gather* bucket and (b) collided with the leader's real *learner* row on the shared key. Leadership is already counted via Service; `gather_lc` stays learner-only. A healthy leader scores on **both** (Mac Lake: a leader is still being led). **Established May 29, 2026 (Session 22).**

---

### **111. Attendance unique key = `(member_id, event_type, event_date)`, extended with `event_name` for lesson/batch types**

Same-key writes are **last-write-wins** — a later "absent" can overwrite a true "present" (the two-LCs-same-day collision). To keep records from colliding, give them a **distinct `event_type`** or a **distinct `event_name`**. BTLI/Pre-Pipeline rows carry `event_name = "<course> · L# · <title>"`; **General Purpose Batch** rows carry `event_name = <batch name>`. The save loop's existence-check `.eq('event_name', …)` MUST include every event_name-keyed type, or distinct sessions silently merge. **Established May 29, 2026 (Session 22).**

---

### **112. SVI engine — missing-data exclusion, the no-meeting caveat, and the data-sufficiency floor (`compute-svi-weekly` / `index.ts`)**

- **Missing-data exclusion (the inflation lever):** a metric whose `raw` is **null** is **dropped** from the weighted average — only non-null scores accumulate `totalWeight`. Attendance/devotional return **0** (not null) when absent, so they DO count negatively; the inflation comes from null-returning metrics (no diagnostic, no intervention) for higher levels. Whether a given null metric should instead count as 0 is a per-metric judgment, NOT a blanket change.
- **No-meeting caveat (group basis = the *discipler's* LC):** a learner with `gather_lc` raw 0 → query the discipler's LC meetings (`event_type='LC Meeting'`, `logged_by_id = member.discipler_id`) over the same adaptive window (shared `effectiveCutoff()` helper). 0 distinct dates held → tag `metric_scores.gather_lc.note = 'no_meeting_held'` (**score stays low** — Pastor's call), else `'skipped'`. MD Care Radar shows a "⚠ no LC meeting held" badge — accountability points UP at the upline, not the member.
- **Data-sufficiency floor:** count real **observations** (`attendance` present + `devotional_reflections`, trailing 56 days); if `< svi_min_observations` (from `system_settings.meta.svi_min_observations`, default **4**) → force `zone='onboarding'` even when a total computed (so 1–2 data points can't mint a confident green). The empty-state zone `'insufficient'` was renamed `'onboarding'` (one ⚪ state). Snapshot now also stores `observations` + `min_observations`.
- **A live recompute overwrites ALL snapshots — always `?dry_run=true&member_id=…` first.** **Established May 29, 2026 (Session 22).**

---

### **113. Member PIN reset = CLEAR the hash, never set one**

Resetting a member's login PIN sets `member_pin_hash` + `member_pin_set_at` to **null**; `member_login.html` routes a null hash to the **"Set up your PIN (first time)"** flow, so the member chooses their own new PIN and the LCL **never sees or sets it**. The MLT "🔑 Reset PIN" button lives in the member-detail action bar, gated to the member's **facilitator/discipler or Pastor** (same gate as Enroll, re-checked on click), and audit-logs a `pin_reset` view event. MLT still never *reads* the hash (privacy posture intact). RLS disabled → the anon-key UPDATE works. An active session persists until expiry; the reset bites at next login. **Established May 29, 2026 (Session 22).**

---

### **114. `cohorts.visible_to_others` — per-batch privacy (private grouping vs shared)**

`false` = **private** grouping (owner-only — gather the people you minister to without others enrolling); `true` = **shared** (other leaders see it in enroll/attendance pickers). The DB column is `NOT NULL DEFAULT true` (preserves every existing batch and any create path not yet updated — **no regression**). Both the MLT and MD create checkboxes start **UNCHECKED** and explicitly write `false`, so newly-made batches are **private by default**. The `listVisibleToLeader` filter: a non-owner sees a batch only if it's **Pastor-owned AND `visible_to_others !== false`** (the `!== false` keeps legacy/default rows visible); the **owner always sees their own**; Pastor sees all. **One filter governs both** the enroll picker and the attendance batch picker. MD's batch editor can also toggle visibility on an existing batch. Migration: `migration_cohort_visibility.sql`. **Established May 29, 2026 (Session 22).**

---

### **115. MLT batch-create program list: Pastor sees ALL programs (parity with MD); other leaders see `is_active` only**

MD loads `cohort_programs` with **no** `is_active` filter (shows retired programs too, labeled inactive); MLT historically filtered to active. Now MLT applies `is_active=true` **only for non-Pastor actors** — Pastor sees every program (inactive ones labeled "(inactive)") so he can create private mentoring/coaching batches under any program type, while regular leaders' pickers stay clean. **Established May 29, 2026 (Session 22).**

---

### **116. "General Purpose Batch" attendance type — log any non-lesson batch without colliding with LC meetings**

MLT attendance chip `data-type="General Purpose Batch"` (displayed **"Gen. Purpose Batch"**; stored spelled-out). Selecting it shows a batch picker of the leader's **visible, live (active/forming), non-BTLI/non-Pre-Pipeline** batches (via `listVisibleToLeader` → per-leader scope; Pastor sees all, each LCL+ sees their own). The chosen batch's members become the roster; `event_name = <batch name>`; rows are keyed by `event_name` (Inv #111), so the distinct `event_type` **never collides** with `'LC Meeting'` and two batches the same day stay separate. It is a **standalone log** — deliberately NOT wired into the SVI dimensions or the MAR fixed columns (lands in "other"). Reusable by every LCL+ for their own mentoring/coaching groups.

**Corollary — a program's NAME is display-only and safe to rename.** Cohort→program links by `program_id`; quiz/lesson gating by `btli_course_code` / `usbong_course_code` (separate fields, NOT the name); the GP-batch filter by `category` / `status`; and `event_name` never contains the program name. Renaming a program is purely cosmetic — no links sever, no quizzes un-gate, no history goes stale. (To change which quiz course a program feeds, use the **"BTLI Course"** field, not the name.) **Established May 29, 2026 (Session 22).**

---

### **117. SVI Service is a two-metric split with MUTUAL NULL-EXCLUSION — reward the work, not the title (B2 / "option D")**

Refines the Service mechanism of Inv #110. A member's **Service** category rests on **exactly one** metric, selected by role:
- **LC leaders** (`is_facilitator = true` OR `facilitator_role` set) → **`service_lc_led`** ("LC Meetings Led"): distinct `event_type='LC Meeting'` dates where **`logged_by_id = member.id`** (meetings they personally ran), rate-based over the 8-week window (`rate = led / expectedWeeks`, clamped 1.0). A facilitator with **0** meetings led → raw 0 → score 0 — the intended bite: a titled-but-coasting leader drops on Service. Returns **null** for non-facilitators (excluded via Inv #112 missing-data rule).
- **Non-leaders** → **`service_ministry_role`** (the has-a-serving-role boolean). Returns **null** for facilitators.

Each metric returns null for the *other's* population, so **no member is ever scored on both** — Service is single-sourced, never double-counted. The same meeting log still hands the flock their **Gather** credit (`gather_lc`, Inv #110), and the leader keeps their own learner `gather_lc` (two-role, Inv #110/#111). Chosen over a single role-aware metric (messy dual `score_rules`) and over add-only (weaker on intent).

**Corollary — `svi_metrics.category` values are LOWERCASE in the DB.** `svi_metrics_category_check` allows only `gather|word|prayer|fellowship|mission|growth|service|stewardship`. `SVI_DESIGN.md` documents Title-Case categories — **the doc is wrong, the DB is right**; seeding `service_lc_led` as `'Service'` was rejected, it must be `'service'`. Any engine code switching on category compares **`String(metric.category).toLowerCase()`** (the learner no-meeting-caveat detector was tightened to `=== 'gather'` for exactly this). Migrations: `svi_service_lc_led_metric.sql` → `svi_service_lc_led_weights.sql` (self-referential: sets each profile's `service_lc_led` weight = its existing `service_ministry_role` weight, preserving per-role Service weight, no magic numbers). **Established May 30, 2026 (Session 23).**

---

### **118. A write path must SCREAM, not whisper — and a CHECK-constrained enum migrates in lockstep with the engine (the zone-constraint silent-write-failure)**

The Session-22 engine renamed the empty-state zone `insufficient → onboarding` (Inv #112) but the **`svi_snapshots.zone` CHECK constraint was never updated** (still only `thriving|warming|dormant|insufficient`). So **every upsert batch containing an `onboarding` row failed**, and because `writeSnapshots` merely `console.error`'d, the function returned `snapshots_written: 0` with **error_count 0** — a totally silent failure. "SVI deploy = done" was a mirage built on this; stored snapshots were a week stale. Two standing rules:
1. **When the engine introduces a new value for a CHECK-constrained / enum column, the table constraint MUST migrate in the SAME change.** Fix: `fix_svi_zone_constraint.sql` (drop + re-add allowing `thriving|warming|dormant|onboarding|insufficient`).
2. **Write paths surface failures, never swallow them.** Hardened `writeSnapshots` returns `{ written, writeErrors }`; on a batch failure it **salvages row-by-row** and collects per-row errors (member + zone + message, capped 25). The function response now exposes **`write_failed`, `write_error_count`, `write_errors`**, and every caller (the report's "⚡ Compute now" **and** the new Save & Recompute) READS them and shows a ⚠ instead of a false success. Hardened engine = `index.ts` (759 lines). Post-fix live recompute is clean (Dennis 37→27 under the new Service logic, Charina holds 85.5). **Established May 30, 2026 (Session 23).**

---

### **119. SVI weights are RELATIVE; the MD "SVI Weights & Zones" editor (Settings, Pastor-only) is the single tuning surface**

The engine computes `total = (Σ score×weight / Σ weight) × 10` **over the metrics that have data for that member** (nulls drop out, Inv #112). So weights are pure **relative ratios** — `gather_sunday=2` counts exactly twice `gather_lc=1`; 2/1, 20/10, 200/100 are identical, and they need not sum to anything. Pastor tunes them in MD → **Settings → "⚖️ SVI Weights & Zones"** (Pastor-only; `LeaderScope.isPastor()` gate; section `display:none` otherwise): per-level **tabs** (Default · L0–L5); a number input per metric **applicable at that level** (`min_pipeline_level ≤ lvl ≤ max_pipeline_level`) with a live **"= X%"** share; that level's **zone thresholds** (Thriving ≥ / Warming ≥; below = Dormant). Writes `svi_weight_profiles.weights` + `zone_thresholds`; **Save & Recompute** invokes `compute-svi-weekly` and surfaces `write_failed` (Inv #118). Both Service metrics (Inv #117) **appear configurable** at L2+, but per-member only one is ever live — the "%" is the share *if that metric has data*. Render-verified in a stubbed Chromium harness. **Established May 30, 2026 (Session 23).**

---

### **120. MULTIPLY front-end source files are pure LF — splice anchors MUST match the file's existing line endings**

`multiply_dashboard.html` and the other front-ends are stored with **`\n` (LF)** endings, zero `\r`. A Python splice that builds **multi-line anchors with `\r\n`** will **silently fail to match** (count 0) on an LF file — this cost two failed passes this session before a byte check (`open(...,'rb').count(b'\r')==0`) settled it. Discipline, extending Inv #105/#56: before structural splices, **verify the file's line endings** and use the same (`\n` here); **single-line anchors are line-ending-agnostic** and safest; never `.replace('\n','\r\n')` on inserted content. After splicing, whole-file `node --check` the inline app script (wrap in `(async()=>{…})()` to neutralize any top-level await). **Established May 30, 2026 (Session 23).**

---

### **121. Preaching reminder copy is computed from the ACTUAL day-count — a hardcoded label is not a timezone bug**

`MultiplyShared.preaching.renderReminderBanner` shows up to **7 days** before an assignment (`daysAhead = 7`; banner appears for `diff` 0–7), in three stages: **7d** (4–7 days, gold "this coming Sunday/Wednesday — start preparing"), **3d** (**1–3 days**, orange), **0d** (today, red). The day-math is correct **local-midnight** (`new Date(preachDateStr + 'T00:00:00')` vs `today.setHours(0,0,0,0)` — deliberately NO `toISOString`/`Z`, Inv #106). The bug was **copy, not time**: the `'3d'` bucket spans 1–3 days but its text + title were **hardcoded "3 days"**, so a sermon **1 day out announced "3 days."** Fixed: the `'3d'` message + title are built from the real `diffDays` — `isTomorrow` → "Tomorrow you preach (…)" / "Reminder · Tomorrow"; else "N days until you preach (…)" / "Reminder · N Days" (EN + TL). Lesson: when a banner buckets a *range* into one stage, the copy must reflect the **actual** value, not the bucket's name — reach for the data before blaming the clock. The 7-day window was **left at 7** (Pastor confirmed; not 5). **Established May 30, 2026 (Session 23).**

---

### **122. The SVI report's user-facing name is "Member Spiritual Vitality Report"; the internal identifier stays `careRadar`**

The MD surface formerly labeled **"❤️ Care Radar"** is **displayed** as **"Member Spiritual Vitality Report"** — renamed in the view header, both nav entries (mobile + drawer), and the error / recompute-status strings. **Everything internal is unchanged** (names-are-display-only, cf. Inv #116 corollary): `panel-careRadar`, `data-nav="careRadar"`, `_navTo('careRadar', …)`, `loadCareRadar` / `renderCareRadar` / `sviComputeNow`, and the `cr-*` CSS. `multiply_shared.js` still says "Care Radar" in code comments (documenting the internal id) — leave those. Same surface read-described in Inv #107; data posture unchanged (read-only, "care, not grade," no `pastoral_override` column). An MLT SVI view, if it ever ships, renames separately. **Established May 30, 2026 (Session 23).**

---

**Established May 30, 2026 (Session 23). Invariants #117–#122 added — count now 122.**

---

### **123. Assessment instruments must be psychometrically balanced — diagnose from live response data first, then equalize option attractiveness and de-halo virtue-aligned dimensions**

Before revising any MULTIPLY assessment, **pull the live response distribution** (`member_profiles.results`, or the dedicated table) and look for a piled-up primary or a flat spread — the fingerprint of biased *items*, not real personality. Two failure modes surfaced Session 24: **forced-choice halo** (Conflict Style, n=39 — 64% landed on Collaborating because "win-win" reads holiest in a church; avg top-mode 9.51/12) and **directional Likert keying** (DISC, n=51 — S/C virtue-glowing and inflated, D abrasive and suppressed to a single 2% respondent). The fix rules, applied to every instrument: (1) within each forced-choice pair, both options must be **equally attractive, equally confident, behaviour-based** — no justifying qualifier on the "bad" option, no hedge on the "humble" one; (2) **de-halo** the socially-desirable dimension (frame it as costly/slow) and **dignify** the suppressed ones; (3) for normative Likert, add **reverse-keyed items** per dimension with reverse-aware scoring (`rev ? 6-v : v`); (4) keep the stored result shape **byte-identical** so history stays comparable. A revision isn't done until a **re-pilot** shows the distribution widening — no mode/dimension dominating. **Established May 30, 2026 (Session 24).**

---

### **124. Every assessment instrument is generically branded "MULTIPLY Pipeline" — no church name anywhere (scope clarification of Inv #26)**

When revising any assessment, strip **all** church-specific references (e.g. "Rosehill Christian Church") from cover badges, PDF headers/footers, and body copy; use only the generic **"MULTIPLY Pipeline"** branding. The platform is built to be reusable by other churches, so an instrument must never hardcode one congregation's name. Applied to **Conflict Style + DISC** (Session 24); **Love Languages + Enneagram still pending** the same pass when each is next revised. **Established May 30, 2026 (Session 24).**

---

### **125. Canonical quiz data shape: `question_en`/`question_tl` + `options:[{label_en,label_tl,correct}]`; consumers read `label_en` with an `en` fallback; every seed ends with a NOT-NULL verify-SELECT**

Both `btli_quizzes` and `usbong_quizzes` store all questions + options in a single `questions` jsonb. The **one canonical shape**: each question has `question_en` / `question_tl`; MC options are `{correct:bool, label_en, label_tl}`; TF carries its answer at the **question level** (`correct:bool`). Readers (the editor + both players) must use a **tolerant accessor** (`opt.label_en ?? opt.en`) because legacy rows drifted to bare `en`/`tl` — the Session-24 "blank options" bug was exactly this (data stored `label_en`, code read `.en`). Every quiz **seed SQL must end with a verify-SELECT asserting `question_en IS NOT NULL`** (and option text non-empty): the L9/L10 rebuild caught seeds that were structurally valid but had null `question_en` under a *rogue* schema. **Established May 30, 2026 (Session 24).** **Addendum (Session 30 — see #158):** the same drift later hit the question **STEM** (`stem_en`/`stem_tl` on Usbong 1 L6–10) — stems get the tolerant-reader (`_qText`) treatment too, and drifted stem data is normalized via `migrations/002`.

---

### **126. Inspect the actual stored payload before reconstructing anything — a header comment claiming "canonical" is not evidence**

Twice in Session 24 a file's own header lied: the BTLI L9/L10 quiz seeds were labelled "Inv #73 canonical" but stored a **rogue schema** (`q`/`question` keys, string options, `answer`/`correct_index`); the attest helper's comment claimed it "mirrors MMT's deployed SELECT exactly" while MMT's Usbong SELECT had **no `lesson_id`** at all. Rule: when debugging data, **dump the real rows and diff them against the reader's actual accessors** — never trust a comment, a filename, or memory of "what it should be." This extends Inv #56 (read the deployed file) down to the *data layer*: read the deployed **payload**, not the story told about it. **Established May 30, 2026 (Session 24).**

---

### **127. Usbong quizzes carry `lesson_id` and inherit the Model X lock exactly like BTLI; a quiz gate fails CLOSED on infra error OR missing linkage**

The Usbong quiz gate (`_usbongComputeOne`) shipped in Session 5 **without any lesson-lock** — an enrolled member was `eligible:true` for *every* Usbong quiz regardless of which lessons their batch had unlocked (the all-quizzes-open bug). BTLI got the Model X participant lock in Session 14 via `btli_quizzes.lesson_id`; Usbong never had the column. Session 24 added `usbong_quizzes.lesson_id` (linked to `pipeline_lessons` track `Usbong` / level 0 by `lesson_number`) and **ported the lock**: a participant is locked until their batch unlocks the linked lesson (`cohort_lesson_unlocks`); staff (teacher/co-teacher/apprentice) bypass. Two standing rules, extending Inv #84/#89/#95: (1) the **two curricula stay in lockstep** — any lock/unlock mechanic added to one is back-ported to the other; (2) a quiz gate **fails CLOSED** — on an unlock-read error *and* on a missing/unresolvable `lesson_id`, a participant is **locked, never opened**. Usbong now does this; **BTLI still falls through *open* on a null `lesson_id`** — a latent parallel hole flagged for a future parity pass. All three render/player eligibility catches (MMT BTLI + Usbong, Usbong player) were also flipped fail-open → **fail-closed**. **Established May 30, 2026 (Session 24).**

---

**Established May 30, 2026 (Session 24). Invariants #123–#127 added — count now 127.**

---

### **128. Usbong unlocks PER-PERSON by attendance; BTLI stays per-batch — a deliberate, scoped divergence from the Inv #127 lockstep**

For `track='Usbong'` lessons, a PARTICIPANT's lesson (and its inheriting quiz) opens once that disciple is marked **present** for it — the present `attendance` row IS the unlock signal, matched by substring against the lesson's `usbong_quizzes.attendance_event_name_pattern` (→ `lesson_id` → `pipeline_lessons.id`). **No separate progress/unlock table — attendance is the single source of truth.** The per-batch `cohort_lesson_unlocks` row remains the Pastor **"open it for everyone"** override (either path opens it). Wired in `multiply_shared.js`: `fetchVisibleLessons` (`participantLocked = participant && !batchUnlock && !(isUsbong && attendedThisLesson)`) and `_usbongComputeOne` (`anyOpen` gains `if (attendanceMatch) return true`). **This is an intentional EXCEPTION to Inv #127(1)'s "two curricula stay in lockstep":** Usbong is a rolling, staggered, per-disciple track (people start in different weeks/months) ⇒ unlock per-person; BTLI is cohort-synchronous (a batch moves together) ⇒ stays per-batch. The lockstep rule still governs the *per-batch Model X lock*; only the *unlock-by-attendance* layer is Usbong-only. **Fail-CLOSED preserved:** a missing pattern, unreadable attendance, or unreadable `usbong_quizzes` ⇒ `attendedThisLesson=false` ⇒ stays locked (relies on the batch override) — a per-person path never opens MORE on error. "MMT is review-not-preview" preserved: a lesson opens only AFTER the disciple was taught (marked present for) it. **Established May 31, 2026 (Session 25).**

---

### **129. Usbong attendance is PRESENT-ONLY — never write a spurious "absent" row**

In a staggered per-person track "absent" is meaningless (a disciple who hasn't reached lesson N isn't "absent" from it). `saveAttendance` (MLT), scoped to `event_type='Pre-Pipeline'`: an UNCHECKED member with **no existing row** is **skipped** (no write) — the fix for the false-absence bug (a not-yet-started disciple was being recorded `present:false`, e.g. Julius on Usbong L2). An unchecked member **with** an existing row is still written `present:false` = an explicit **UNDO**, which — because progress is attendance-derived (Inv #128) — **re-locks** the lesson + quiz for that person. Checked members write `present:true`. All other event types (Sunday, Prayer, LC, BTLI, General Purpose) keep recording absences. **Established May 31, 2026 (Session 25).**

---

### **130. Usbong attendance roster is per-lesson (due-filtered); the GATE fails closed but the ROSTER errs toward visible**

The MLT Pre-Pipeline attendance roster for lesson N shows only disciples **due** for it — `maxAttended >= N-1` (their next lesson OR one already attended, so re-marking is always possible) — computed from `MultiplyShared.usbong.memberProgress` (highest present Usbong `lesson_number` per member, attendance-derived). A **"Show all enrolled"** toggle bypasses the filter (catch-up / fix-a-forgotten-mark). **Posture distinction (important):** the access GATE fails CLOSED (Inv #127/#128 — locked on error), but the ROSTER fails toward VISIBLE — on a progress-read error it shows everyone, because a roster that HIDES a person is worse than a full one (a leader can decline to check someone, but cannot mark someone they cannot see). **Established May 31, 2026 (Session 25).**

---

### **131. Attendance-pattern substring matching requires a LESSON-UNIQUE pattern with a trailing delimiter (the l1/l10 trap)**

The quiz/lesson attendance match is `event_name.toLowerCase().includes(pattern)`. Because lesson numbers nest as substrings, a bare pattern `usbong 1 · l1` is contained in the L10 event name `usbong 1 · l10 · …`, so attending L10 falsely matched L1 — a latent drop-in bug, and it would have mis-fired the Session-25 per-person unlock. **Rule:** every `attendance_event_name_pattern` MUST carry a trailing delimiter (e.g. `usbong 1 · l1 ·`) so no lesson-number is a prefix of another; before relying on any attendance→lesson match, **audit that no pattern is a prefix of another's event name** (l1/l10, l2/l20, …). Generalizes Inv #89 (full-form patterns). Normalized via idempotent `UPDATE usbong_quizzes SET attendance_event_name_pattern = attendance_event_name_pattern || ' ·' WHERE … NOT LIKE '% ·'` (Session 25). **Established May 31, 2026 (Session 25).**

---

### **132. Attendance is keyed by `event_name` TEXT (no `cohort_id`) — renaming a batch must cascade; batch-meeting vs lesson attendance use different name conventions**

The `attendance` table has **no `cohort_id`**. A batch's general MEETING attendance is written with `event_name = batch.name` exactly (the MLT group-attendance context), while LESSON attendance uses the Inv#30 canonical `event_name` (`Program · Lx · Title`, middle-dot, single spaces) — never a bare batch name. Consequences: (a) renaming a batch orphans its meeting-attendance history **unless** you also `UPDATE attendance SET event_name=new WHERE event_name=old` (exact-match is safe — lesson names always contain `·` and can't equal a bare batch name, so the cascade can't touch lesson rows); (b) the per-person Usbong unlock (Inv #128) keys off the lesson pattern, so a rename never affects unlocks or quiz gates. Batch names aren't unique-enforced — keep them distinct (a shared name makes attendance ambiguous). **Established June 1, 2026 (Session 26).**

---

### **133. A member avatar NEVER renders blank — initials+colour are the always-present base layer; the photo is an OVERLAY that falls back on load error**

Rendering a photo by *replacing* initials is a bug: a truthy-but-broken `photo_url` (404/403/slow/wrong-policy) then leaves an empty circle (the "Roce" regression). Rule: initials + level colour are **always rendered first**; the photo overlays — in MD via `<img onerror="this.remove()">` (container `position:relative`; img `border-radius:inherit; object-fit:cover; inset:0`), in MMT via a preload-probe in `_applyAvatar` (apply the background-image only on `Image.onload`; keep initials on `onerror`). A broken/slow photo therefore shows initials, never a blank. The facilitator ⭐ sits OUTSIDE the circle, so the container gets `position:relative` **without** `overflow:hidden` (the img clips itself via `border-radius:inherit`). **Established June 1, 2026 (Session 26).**

---

### **134. Profile-photo BYTES live in Supabase Storage (public `avatars` bucket); the DB stores only `members.photo_url`; resize client-side; MD reads it but never writes it**

`members.photo_url text` holds the public URL (+`?t=` cache-bust, since uploads upsert to a fixed `{memberId}.jpg`). Client resizes to **≤512px JPEG (~0.82)** before upload ⇒ ~80–120 KB each — bytes in Storage, not the DB (~17 MB for 170; watch the 5 GB egress before the storage cap). The bucket is **public** with anon read/write policies (PIN-auth members use the anon key — Phase-1 RLS posture; tighten in Phase 2; run `add_member_photo_and_avatars_bucket.sql` once). MD's `r2l` maps `photo` from `photo_url`, but `l2r` does **NOT** write it — so MD member edits never clobber an MMT-uploaded photo. **Established June 1, 2026 (Session 26).**

---

### **135. `cohort_members` + `cohort_lesson_unlocks` are ON DELETE CASCADE; `attendance` has no cohort FK — deleting a batch clears roster + unlocks but PRESERVES attendance history**

So `db.from('cohorts').delete().eq('id',…)` is sufficient — no manual child deletion — and meeting/attendance rows remain (keyed by name, Inv #132). Delete is the supported way to rebind a batch's program (see Inv #136). Because attendance survives by name, a recreated batch with the **same** name re-inherits the old attendance — rename or vary the name when rebinding to keep histories separate. Delete is gated to owner/Pastor (`MultiplyShared.cohorts.canEdit`) and uses a consequence-listing confirm (active members un-enrolled, history kept, irreversible). **Established June 1, 2026 (Session 26).**

---

### **136. In MLT a batch's program/level are LOCKED (display-only); only the NAME is editable (owner/Pastor); `cohorts.visible_to_others` is Pastor-only**

Changing a batch's program changes who QUALIFIES to enroll, conflicting with already-enrolled members — so MLT never lets an LCL edit program/level; to rebind, **delete + recreate** (Inv #135). The roster header offers a pencil to edit only the name (which cascades attendance per Inv #132). The create-form **"Visible to others"** checkbox renders only for Pastor and the save double-guards with `LeaderScope.isPastor()`, so LCL-created batches are always private — shared batches (e.g. a BTLI class) are Pastor-set. **Established June 1, 2026 (Session 26).**

---

**Established June 1, 2026 (Session 26). Invariants #132–#136 added — count now 136.**

---

### **137. Both render-layer eligibility catches (Usbong AND BTLI) in MMT fail CLOSED**

`member_tool.html` has two `try/catch` blocks that call `MultiplyShared.{usbong,btli}.eligibilityForMany` and render quiz cards. The catch is the ERROR path only — the real gate (incl. the Usbong attendance-unlock of Inv #128 and the BTLI hybrid attendance fallback of Inv #35) runs INSIDE the `try` and returns normally on success, so the catch never fires in the happy path. On a genuine throw, BOTH catches now set every quiz `eligible:false, reason:'gate_error', dropIn:false` — never `eligible:true/'no_gate'`. Flipping the catch therefore changes ONLY error behaviour, never attendance unlocks. Completes Inv #127/#89's fail-closed posture (the Session-24 story that "both render-layer catches were flipped" was false for the deployed file — verified and corrected). Reason `'gate_error'` falls through to the generic locked-state copy (not `'lesson_locked'`), so rendering is unaffected. **Established June 1, 2026 (Session 27).**

---

### **138. `multiply_shared.js` is included with a `?v=` on EVERY HTML and the version is bumped TOGETHER across all files on each shared.js change**

GitHub Pages/PWA caches hard; an un-versioned `<script src="multiply_shared.js">` can serve a stale shared.js (the MMT symptom: "Leader Name/?/empty" or wrong shared behaviour). Rule: every HTML that loads shared.js (`member_tool.html`, `multiply_dashboard.html`, `lc_leader_tool.html`, and all reports — `lc_attendance_report.html`, `lc_member_report.html`, `lcg_pulse_report.html`, `member_attendance_report.html`, …) includes it as `multiply_shared.js?v=N` with the SAME N, and N is incremented across ALL of them together whenever shared.js changes. **Baseline set to `?v=2` (Session 27).** (Corrected the stale note that MD/MLT already carried `?v=` — only `lc_member_report.html` had `?v=1`.) **Established June 1, 2026 (Session 27).**

---

### **139. Avatar photo overlay for innerHTML-built lists uses a null-safe per-tool helper — extends Inv #133 to all face surfaces**

For avatars rendered via innerHTML strings (not a persistent element), each tool has a helper returning the photo overlay `<img loading="lazy" onerror="this.remove()" style="position:absolute;inset:0;…;object-fit:cover;border-radius:inherit;">`: `mdAvImg(m)` (MD), `_mmtAvImg(url)` (MMT), `mltAvImg(m|url)` (MLT). The caller always renders initials FIRST as the base, inside a `position:relative` circle (no `overflow:hidden`; the img clips via `border-radius:inherit`). The helper is **null-safe** — no `photo_url` ⇒ returns `''` ⇒ initials show, never a blank. `photo_url` must be added to the member SELECT of any query feeding a face surface. Face surfaces now covered: MD member-edit modal (`#mav`); MMT celebration feed (face + win-type emoji badge), LC-detail (discipler/You/mates); MLT member cards, home avatar, member-detail header, attendance rosters, AI-insights, per-member report header. MD `l2r` still never writes `photo_url` (Inv #134). The MMT topbar/profile avatars keep the preload-probe `_applyAvatar` (Inv #133); the helper pattern is the innerHTML-list equivalent. **Established June 1, 2026 (Session 27).**

---

### **140. Assessment-rebalance discipline: preserve the SCORING KEY byte-identical; rewrite ONLY item wording; verify the key before writing; re-pilot after retake**

When rebalancing any assessment for social-desirability / construct / self-image bias (Conflict Style, DISC, Love Language, Enneagram, …): the SCORING KEY is sacred and stays byte-identical — for forced-choice that is the per-option category tags AND the pairing composition (which categories are paired, and how many times each appears); for Likert that is the item→category mapping AND the count of items per category. Only the EN/TL wording of items/descriptors changes. ALWAYS extract the original key sequence and assert it equals the new one BEFORE writing the file (a programmatic build that fails the assert aborts). De-brand to "MULTIPLY Pipeline" (Inv #26) in the same pass. Existing saved results stay structurally comparable. The revision is **not verified until a re-pilot** after members retake confirms the distribution widened (Inv #97 — the pending note is a hypothesis until live data confirms). **Established June 1, 2026 (Session 27).**

---

### **141. `members.enneagram_type` is an INTEGER (1–9), not text**

The Enneagram assessment saves the type NUMBER as an integer to `members.enneagram_type` (and `member_profiles` with `profile_type:'enneagram'`). SQL must NOT compare it to `''` (`AND enneagram_type <> ''` throws `22P02 invalid input syntax for type integer`); use `IS NOT NULL` only. Contrast `members.love_language_primary` etc. which are TEXT. **Established June 1, 2026 (Session 27).**

---

### **142. The in-app Strengths instrument is a SELF-REFLECTION tool, NOT official CliftonStrengths — present it honestly; tie-break must be neutral**

`strengths_profile.html` is a 102-pair forced-choice across all 34 themes, scored by a simple tally (each theme appears exactly 6×, score 0–6). It CANNOT match Gallup's 177-item, IRT-scored, norm-referenced CliftonStrengths® — the top-5 ranking has large error (coarse 0–6 resolution ⇒ constant ties; outcome dominated by which 6 opponents each theme faces). Therefore: (a) it is framed as a "Strengths Reflection," never claims official-CliftonStrengths top-5 fidelity, carries a disclaimer banner, and tells the reader to **trust the 4-Domain pattern over the exact theme rank**, linking to gallup.com/cliftonstrengths for accuracy; (b) ties are broken NEUTRALLY — shuffle the theme keys once, then stable-sort by score — NEVER by `Object.keys` (alphabetical) order, which systematically displaced genuine late-alphabet themes (Learner, Ideation, Futuristic) in favour of early ones (Achiever, Activator). For leadership placement that needs accuracy (Pipeline C3), use the official Gallup assessment and record it (optionally via a dashboard manual-entry field — not yet built). PAIRS (102) and THEMES (34) are the scoring data — never silently altered. **Established June 1, 2026 (Session 27).**

---

**Established June 1, 2026 (Session 27). Invariants #137–#142 added — count now 142.**

---

### **143. `lc_group` labels the group a LEADER leads; MD's LC-Group-name field is Pastor/superuser + facilitator only, with an anti-drift guard**

The LACR derives each LCG's **title** from the leader's `lc_group` text and the **"Led by"** from the flagged facilitator (`is_facilitator`/`facilitator_role`), with membership by `discipler_id`. When `lc_group` is set to a *person's name* (e.g. a member putting their LCL's name there), the report mislabels the group (the Lyza-Jane case: her group titled "Gloria Jacob"). Therefore: (a) MD's member form exposes an **"LC Group Name"** input that is shown ONLY when the viewer is Pastor/superuser AND the member is a facilitator — because the label names the group the leader *leads*, not a group they belong to (member→group moves stay the transfer workflow via `pending_lc_group`); (b) on save it warns when the entered value exactly matches another member's name; (c) `l2r` writes `lc_group` preserve-on-omit (`m.lc_group===''?null:(m.lc_group??null)`) so routine/partial saves never wipe it; (d) blank ⇒ null ⇒ LACR shows "[FirstName] LC". `saveMember` is the only place that intentionally sets it from the field. **Established June 1, 2026 (Session 27).**

---

### **144. `_isSuperuser()` — top-of-tree leaders edit anything in any profile, with no self-edit lock**

A superuser = the Pastor account (`LeaderScope.isPastor()`) OR any **Level-5 leader with no LCL/discipler** above them (no `discipler_id`). MD's `_isSuperuser()` encodes this. Superusers: (a) are NEVER put under the self-edit lock — `openEdit` applies `_applySelfEditLock()` only when `_selfEditMode && !_isSuperuser()` (fixes "locked out of my own profile"); (b) are not force-preserved in `saveMember`'s self-edit defense block; (c) may edit all Pastor-managed profile fields — pipeline level, assigned discipler, test-member and external-user flags, and the LC-Group name (`_canManage = _isPastor || _isSuper`). This is intentionally a **client-side convenience** gate, consistent with every other MD gate until RLS Phase 2 — it is not server-side authorization. A spouse/co-leader must have a Level-5 record with no discipler to qualify. Reset-PIN remains gated to `isPastor()` only (a credential action, not a profile field) unless explicitly extended. **Established June 1, 2026 (Session 27).**

---

**Established June 1, 2026 (Session 27, late additions). Invariants #143–#144 added — count now 144.**

---

### **145. MD batch bulk-enroll: filter → name-checklist review → commit**

The Cohorts → 👥 Roster modal has a **"⚡ Bulk add"** that enrolls many members at once instead of one-by-one. Filter scope = **Everyone / By Level** (multi-level checkboxes) **/ By LC Leader** (members whose `discipler_id` = the chosen facilitator — the leader is NOT auto-included; LCLs are members with `is_facilitator || facilitator_role`). An **intermediate review modal** lists every matching candidate as a checkbox (default checked, name · level · LC group); already-enrolled members are shown **disabled** with a "✓ in batch" tag and are never re-inserted (`cohort_members_unique`); **test members + guests are excluded entirely** (`is_test_member`/`is_external_user`). Commit = a single `cohort_members` **array insert** with the chosen role (default `participant`; the five canonical roles, Inv #41). There is intentionally **NO `canEnroll`/Zone-1 gate** — bulk-add is the Pastor MD override (Inv #103); lesson pacing is still controlled per-batch by lesson unlocks (Model X, Inv #84). The cohort module's member SELECT was widened to carry `discipler_id, is_facilitator, facilitator_role, is_test_member, is_external_user`. **Established June 3, 2026 (Session 28).**

---

### **146. Preaching service-day is derived from `preach_date`'s weekday — never from `service_type`**

`wednesday_preaching` columns are `id, preach_date, preacher_member_id, original_preacher_member_id, notes, created_at, updated_at`. The deployed DB **may** also carry a `service_type` (schema.json can lag — Inv #124), but code MUST NOT depend on it. Derive Sunday vs Wednesday (and any weekday) from `new Date(preach_date + 'T00:00:00').getDay()` (0 = Sunday … 3 = Wednesday) — local parse only, never `toISOString()` (Manila UTC+8 off-by-ones). `service_type`, if present, is treated as an optional override. This fixed the bug where everything defaulted to "Wednesday" (and Sundays were mislabeled) because the column the code keyed on did not exist. Time-of-service phrasing follows the weekday: Sunday = morning ("this morning"), every other service = evening ("tonight"). **Established June 3, 2026 (Session 28).**

---

### **147. Preaching reminder banner surfaces ALL upcoming engagements in the window; 2+ → ONE combined banner**

`MultiplyShared.preaching.renderReminderBanner` fetches `getUpcomingAllForMember(memberId, 7)` — **no `.limit(1)`**. The old single-fetch hid a same-week second engagement, which read to the Pastor as "the Wednesday alert is broken" when he had both a Sunday and a Wednesday. Each upcoming row gets a stage (`0d`/`3d`/`7d` via `computeReminderStage`) and is dropped if dismissed. **1 live engagement → the familiar single banner; 2+ live → ONE combined "Preaching This Week" banner**, urgency colored by the nearest engagement, each engagement rendered as its own row with its own 🔄 Swap button, and a single ✕ that dismisses ALL shown engagements (carried in `data-preach-keys` = `preach_date|stage,…`; handled by the `dismiss-all` action). The **7-day window is intentional** — an engagement farther out (e.g., next month's Wednesday) will not appear in the banner until it enters the window, even though the swap modal (which loads all upcoming) can see it. **Established June 3, 2026 (Session 28).**

---

### **148. One consolidated swap-request modal: `MultiplyShared.preaching.openSwapRequest`**

The swap-**request** modal lives ONCE in shared.js's `preaching` module (beside the banner/alert), signature `openSwapRequest(myAssignmentId, myPreachDate, requesterMemberId, { bilingual, onSent })`. **MMT, MLT, and `preaching_calendar` are thin wrappers** that pass their own session id + a bilingual flag; `onSent(targetName)` lets the calendar toast + reload while MMT/MLT fall back to the default `alert`. The modal includes a **"Swap from" picker** = the requester's own upcoming assignments, shown only when there are **2+** (so a preacher with both a Wednesday and a Sunday chooses which engagement to give away; default = the tapped one), and a **"Swap with"** list filtered to **±6 weeks of the selected FROM**, re-filtered whenever FROM changes. Submit inserts `preaching_swap_requests` with `requester_assignment_id` = the chosen FROM, `target_*` = the chosen WITH. Numeric-string ids (the calendar passes a dataset string) are coerced so the FROM row is not double-added. The old page-local `openPreachingSwapRequest` / `openPreachingSwapRequestMMT` duplicates were deleted. **Established June 3, 2026 (Session 28).**

---

### **149. Calendar identity: read `sessionStorage` (not localStorage), match BOTH leader+member ids, with a `?me=` URL fallback**

The whole app keeps its session in **`sessionStorage`** via `MultiplyShared.getValidSession()` (leader) / `getValidMemberSession()` (member) — NOT `localStorage`. `preaching_calendar` must read the same store; its original `localStorage` read returned `undefined`, so `isMine` was always false → no "You" badge and no swap buttons (the Pastor's Sundays showed only "Mainstay"). An Exec. Leader may hold BOTH a leader and a member session whose ids differ, so the calendar collects **all** candidate ids and a cell is "mine" if its `preacher_member_id` matches **any** of them. Because `sessionStorage` does NOT carry to a context that does not share it — a PWA launching an **external browser**, or a bare URL / bookmark — every calendar **opener passes `?me=<id>`** (MLT's "Preaching Calendar" card via `LEADER.leaderId`; the banner's "View Calendar" via the banner's `memberId`) and the calendar reads `?me=` as a fallback. The swap requester id passed from a calendar cell = that row's own `preacher_member_id` (already confirmed to be one of the user's ids). **Established June 3, 2026 (Session 28).**

---

### **150. Attendance save is batched and gives immediate button feedback**

MLT `saveAttendance` must do two things the old version did not. (a) **Immediate feedback:** lock the Save button to **"⏳ Saving…"** (disabled, double-tap-guarded) the instant the write starts, and restore it / set "✅ Saved!" on completion. The old button had NO in-progress state, and combined with a slow write users assumed it had already saved and left → nothing saved at all. (b) **Batched write:** NOT 2 sequential awaited round-trips per member (a 20–30-person roster = 40–60 serial calls ⇒ 15–30 s of dead time on mobile). Instead: **ONE** SELECT for existing rows (`.in('member_id', ids)` for this date+type), **ONE** bulk `insert` for the new rows, and **parallel** `update`s for the rest. Preserve the Pre-Pipeline **present-only skip** (unchecked + no existing row ⇒ skip — never write a spurious absence, Inv #129) and the BTLI/Pre-Pipeline/General-Purpose **event_name keying**. Still avoids DELETE (RLS). On failure: surface "Saved X, failed Y" and **restore the button** so they can retry (never fail silently). `saveMinistryAttendance` already uses a single bulk `upsert` and is fine. **Established June 3, 2026 (Session 28).**

---

### **151. The repo enforces LF via `.gitattributes` — never remove it**

The repository root carries a `.gitattributes` that pins line endings: `* text=auto eol=lf`, explicit `text eol=lf` for `*.html`/`*.js`/`*.ts`/`*.json`/`*.md`/`*.svg`/`*.css`/`*.sql`, and `binary` for images/`*.pptx`/`*.pdf`/fonts. **Never remove or weaken it.** It is what makes **Rule #3 (these files are pure LF)** hold on *every* machine regardless of a developer's local `core.autocrlf` — git stores and checks out LF for all text files, so the splice anchors (`\n`) stay valid no matter who clones or edits. (At introduction, `git add --renormalize` confirmed the index was already pure LF; the file's job is to keep it that way forever.) **Established June 4, 2026 (operational — Claude Code migration).**

---

### **152. Self-attest disable must be present-aware (a leader ABSENCE never blocks self-correction)**

The member "I'M HERE AT SERVICE" pill (`member_tool.html`) may show the non-tappable "✓ by leader" state ONLY when a leader-logged row for this week's occurrence is `present=true`. A leader-marked **ABSENCE** (`present=false`) must NEVER disable the pill — online members are routinely marked absent on-site **before** they self-report, and blocking them would silently lose real attendance. When a leader-absent row exists, the pill stays **ENABLED** with an honest "marked absent — tap if you were here" / "naka-absent — i-tap kung dumalo" hint (no false ✓). Tapping **corrects** the row: flip to `present=true, source='self_attest', logged_by=member`, updated by `id` (safe — `UNIQUE(member_id,event_type,event_date)` = `attendance_member_id_event_type_event_date_key`). The correction surfaces in the leader's **Pending Confirmations** (✓ Confirm / ✕ Dispute). Self-attest `present=true` **counts immediately** in attendance stats — confirmation is a trust overlay, NOT a counting gate (reports do not filter on `confirmed_by`). **Established June 5, 2026 (Session 29).** **Addendum (Session 33 — see #163):** correcting an **OLD** leader-marked absence is allowed at **any age** (not just the latest occurrence); only brand-new self-reports keep the 7-day window.

---

### **153. Migrations are versioned, additive + idempotent, human-gated, and ship with a rollback**

Schema changes live as numbered files in **`migrations/`** (e.g. `001_add_tenancy.sql`). Every migration is **ADDITIVE + IDEMPOTENT** (`IF NOT EXISTS` / `ON CONFLICT` / `WHERE … IS NULL`) and **human-gated**: the **Pastor runs it in the Supabase SQL editor** — Claude Code holds **no service-role key** and never runs migrations (extends #5/#10). Every migration ships with a matching **`NNN_rollback.sql`** (derived from the forward migration, idempotent, NOT run unless undoing). **Established June 5, 2026 (Session 29).**

---

### **154. `church_id` is NULLABLE in Phase 1 — NOT NULL is deferred**

The tenancy `church_id` column added in `001_add_tenancy.sql` is **nullable** with an FK → `churches(id)`. NOT NULL is **deliberately deferred** to a post-Phase-2 tightening migration, applied ONLY once the app sets `church_id` on **every** insert. Adding NOT NULL before then would break live writes (which don't yet populate it). **Established June 5, 2026 (Session 29).**

---

### **155. A post-backfill NULL trickle on high-write tables is expected, not a failure**

After a one-time backfill, rows inserted **after** the backfill ran carry `church_id=NULL` until the app populates it on insert (Phase 2). On high-traffic tables this shows as a small `null_ct` (S29: announcement_acks 10, attendance 10, leader_sessions 9, devotional_reflections 7, …) — **expected and harmless**, NOT a backfill failure. A **true** failure looks different: a whole table with `set_ct=0` (nothing backfilled at all). Re-running the idempotent backfill (`WHERE church_id IS NULL`) mops up the trickle if ever needed. **Established June 5, 2026 (Session 29).**

---

### **156. Tenancy table classification (which tables carry `church_id`)**

**41 tables carry `church_id`:** **40 PER-CHURCH** (backfilled to the church) + **`devotionals`** (HYBRID — `church_id` nullable, **NULL = shared/global** content, not backfilled). **9 tables are EXCLUDED:** 8 GLOBAL catalog — `pipeline_lessons`, `library_resources`, `library_chapters`, `library_quizzes`, `btli_quizzes`, `usbong_quizzes`, `cohort_programs`, `svi_metrics` — plus `_backup_members_diag_zone_2026_05_06` (backup/temp, drop candidate). Source of truth: `TENANCY_AUDIT.md` + `PHASE1_PREP.md` (live-DB confirmed). **Established June 5, 2026 (Session 29).**

---

### **157. Supabase Free tier has NO backups — a rollback script is mandatory before any mutating migration**

The project is on Supabase **Free tier → no automatic database backups**. Therefore every mutating migration MUST ship its **`_rollback.sql`** (#153) BEFORE it is run, and that rollback is the **only** safety net if a migration goes wrong — there is no "restore from backup" fallback. **Established June 5, 2026 (Session 29).**

---

### **158. Quiz STEMS drift like options did (#125) — players read via tolerant `_qText`; drifted DATA must be normalized**

Companion to #125 (the tolerant OPTION reader `_optText`). The question STEM drifts the same way: canonical is `question_en`/`question_tl`, but live **Usbong 1 lessons 6–10** stored it under **`stem_en`/`stem_tl`**, so any reader using raw `q.question_en` rendered a **BLANK stem with the choices intact** (`escapeHtml(null)`→`''`). (a) **Both quiz players must read the stem via a tolerant `_qText(q,lang)`** = `question_en ?? stem_en ?? en ?? question` (+ `tl` variants), at BOTH the render and answer-review sites in `usbong_quiz_player.html` and `btli_quiz_player.html`, mirroring `_optText`. Never read a raw `q.question_en`. (b) **`lesson_quiz_editor.html` reads canonical `question_en` only**, so drifted rows stay blank there until the DATA is normalized — therefore stem drift MUST also be fixed at the source with a migration (S30 `migrations/002_normalize_usbong_stems.sql`: `stem_en→question_en` for Usbong 1 L6–10, idempotent + scoped, ending with the #125 verify-SELECT; `002_rollback.sql` is the undo). Tolerant readers + normalized data = belt and suspenders. **Established June 5, 2026 (Session 30).**

---

### **159. Pre-Pipeline quiz visibility = L0 OR live-batch staff — never gate a staff surface on the staff member's own pipeline level**

The MMT Usbong (Pre-Pipeline) quiz section (`renderUsbongQuizzes`) was hidden whenever the **member's own** `pipeline_level !== 0` (the Session-5 L0-only gate), and it **returned BEFORE** the eligibility check — so a teacher/co-teacher/apprentice discipling a live Usbong batch (who is L2+) saw the **lessons** (role/enrollment-based) but NOT the **quizzes**, even though `MultiplyShared.usbong.eligibilityFor` already grants them via the staff bypass (#84/#85, `multiply_shared.js:1888`). **Rule:** a quiz/lesson surface meant for STAFF must be gated by the member's **batch role**, never by their own pipeline level. The section now shows when `pipeline_level === 0` **OR** the member is **staff in a live Usbong batch** — `_isUsbongStaff` in `member_tool.html` mirrors `_usbongFetchEnrollments` (active staff `cohort_members` row → live cohort `active`/`forming` → active program with a `usbong_course_code`; fails closed). The shared eligibility gate was NOT the cause (live SQL confirmed the teacher's enrollment was correctly tagged); the section-display gate was. `lc_leader_tool.html` (MLT) has no member-facing quiz-taking section, so nothing to change there. **Established June 5, 2026 (Session 31).**

---

### **160. Guests (`is_external_user`) are OPERATIONALLY visible — only statistical reports exclude them; never gate a relationship/operational view on `is_external_user`**

`is_test_member` and `is_external_user` are NOT the same and must not be lumped together. **Test members** are fake fixtures → hidden from operational surfaces. **Guests** are *real people* (e.g. invited pastor-friends test-driving MMT/MLT/MD) who are kept off **Rosehill's statistics** so they don't contaminate counts — but otherwise get the **same UX as any member**, and their relationships are real. Therefore: **operational/relationship/assignment surfaces must show guests** (disciples tree, flock lists, member pickers, the guest's own MMT/MLT/MD experience). **Only statistical reports exclude guests** — and those already have their own strict rule (`is_test_member = false AND is_external_user = false`, Inv #6). The recurring bug is filtering an operational view on `(m.is_test_member || m.is_external_user)`: that wrongly hides guests. S32 fix — MD's DISCIPLES tab (`_disciplesDirect`, `_disciplesTree`, `_getUnassignedMembers`) now hide **test fixtures only**. (Open: the MD scope-count badges `updateScopeCounts`/`liveMembers()` still exclude guests as anti-inflation headline counts — a deliberate, flagged exception pending pastoral review.) **Established June 5, 2026 (Session 32).**

---

### **161. MLT lesson attachments: office/binary types download on first click; only HTML/PDF use the in-app viewer**

`lc_leader_tool.html`'s "My Lessons" opened EVERY attachment in a full-screen iframe viewer. HTML/PDF render there, but a `.pptx` cannot → a blank page whose "↗ New tab" link did the real download (two steps). `_openLessonAttachment` now routes non-iframe-renderable types — `.pptx/.ppt/.docx/.xlsx/.odp/.ods/.odt/.key/.zip` (`_isDownloadAttachment`) — to a **first-click download**: same-origin (lesson decks live on GitHub Pages) via an `<a download>` (no tab), cross-origin via `window.open`. HTML/PDF still preview in the viewer. Lesson decks are committed to the repo (`lessons/**.pptx`), i.e. same-origin, so `download` is honored. **Established June 5, 2026 (Session 32).**

---

**Established June 3, 2026 (Session 28). Invariants #145–#150 added — count now 150.**

**Established June 4, 2026 (operational — Claude Code migration). Invariant #151 added — count now 151.**

**Established June 5, 2026 (Session 29). Invariants #152–#157 added — count now 157.**

**Established June 5, 2026 (Session 30). Invariant #158 added — count now 158.**

### **162. A member CREATED by a guest/test user inherits that flag (both insert paths)**

Companion to #160. When a guest (`is_external_user`) or test (`is_test_member`) user **creates** a member, the new record **inherits the creator's flag**, so guest/test-added members never leak into Rosehill's stats and Pastor never has to deduct by hand. Both member-insert paths enforce it: **MD Add Member** (`multiply_dashboard.html`) — NEW members only (`eid` falsy): `effIsExternal/effIsTest = explicitCheckbox OR (isNew && creatorFlag)`, creator read from the global `members` row for `LEADER.leaderId`; a guest therefore **cannot create a Rosehill member even by unchecking the box** (intended containment); edits keep the form/lock logic. **MLT Add Member** (`lc_leader_tool.html` `saveNewMember`) — `currentLeader` is a session shim without these flags, so the creator's row is read from the DB; the payload carries `is_external_user`/`is_test_member`; fail-soft to non-guest/non-test on lookup error. **Forward-only:** members created before this rule are not retroactively flagged (a one-time backfill handles those). **Phase 2:** fold both paths into one shared `newMemberDefaults(creator)` that also stamps `church_id` (Inv #153–#157). **Established June 5, 2026 (Session 33).**

---

### **163. Self-attest: correcting a leader-marked ABSENCE is allowed at ANY age; only brand-new self-reports are window-gated**

Extends #152. The `SELF_ATTEST_WINDOW_DAYS` (=7) guard in `member_tool.html` must NOT block a member from flipping an **old** leader-marked absence — that's a correction, and the leader still confirms it via Pending Confirmations. So `_doSaveAttest` runs the **duplicate check FIRST**: an existing leader-marked-absent row → flip to present **at any age** (returns before the window); the window applies **ONLY to a brand-new claim** (no existing row), just before insert, so members can't fabricate ancient attendance. The picker (`openAttestDatePicker`) gained a native `<input type="date">` (max=today) so any past Sunday/Wednesday (or other plain event) is reachable, and recent-day quick-picks are no longer disabled past the window (the save logic decides correction-vs-claim). One code path gates all plain events. **Established June 5, 2026 (Session 33).**

---

**Established June 5, 2026 (Session 31). Invariant #159 added — count now 159.**

**Established June 5, 2026 (Session 32). Invariants #160–#161 added — count now 161.**

**Established June 5, 2026 (Session 33). Invariants #162–#163 added — count now 163.**

### **164. KIND-MIRRORING: member visibility and counts are relative to the VIEWER's kind (real / guest / test) — operations show all kinds badged to a real viewer; statistics never cross-count kinds**

Generalizes #160/#162 into one rule. **`memberKind(m)`** = `'test'` (`is_test_member`; **wins when both flags are set**) | `'guest'` (`is_external_user`) | `'real'`, always read from the member's **own** flags. **`_viewerKind()`** is read from the **viewer's own `members` row** (per #162 the session shim does NOT carry these flags — never trust it); if the row isn't loaded, default `'real'` (the pre-#164 behavior). Two predicates, two surface classes:

- **OPERATIONS** (`_kindVisible`): rosters, trees (`_disciplesDirect`/`_disciplesTree`), `_getUnassignedMembers`, member pickers, attendance lists, All Members. A **real** viewer sees **real + guest + test** — still subject to the LeaderScope level gate — with every non-real row carrying a **kind badge** (🧪 Test / 👤 Guest pill via `_kindBadge`, or the plain-text `_kindOptTag` inside `<option>`s; the badge rule is PART of this invariant — an unbadged foreign-kind row is a bug). A **test** viewer sees **test-kind only**; a **guest** viewer sees **guest-kind only** (their containment is now total: they no longer see Rosehill's real members, and Pastor sees their universe badged).
- **STATISTICS** (`_sameKind`): every count/distribution — MD `liveMembers()` (the chokepoint), `updateScopeCounts`, KPIs, pipeline/zone/EOLO/alert distributions, MLT `updateScopeCountsMobile` + home stats, the MLT duplicate-name check pool — includes ONLY members whose kind **equals** the viewer's kind. Kinds never inflate each other's numbers, in any direction.

Phase A (S34) applied this inside `multiply_dashboard.html` + `lc_leader_tool.html` (each carries its own mirrored helper set; no `multiply_shared.js` change → `?v=4`). **Phase B (queued):** generalize the report HTMLs' strict inline predicate (#58 stays binding on them until then) to viewer-aware `memberKind === viewerKind`, and centralize the helpers in `multiply_shared.js` (bump `?v=`). This retires #160's open exception (the MD scope-count badges excluding guests is now the rule, not an exception) without weakening #160 itself: guest relationships remain operationally visible to real viewers. **Established June 12, 2026 (Session 34).**

---

**Established June 12, 2026 (Session 34). Invariant #164 added — count now 164.**

### **165. PRAYER / PANALANGIN — audience-and-kind-scoped requests; Wave-1 surface is MMT-only, no gamification UI**

Prayer ("Panalangin") is a member-facing prayer-request board. **Wave 1** (landed `1b3f2c8`→`2ca3411`, **Session 35**, on `main`) shipped the SQL + the **MMT** surface; the MD/MLT surfaces are later waves.

- **Schema** — `migrations/003_prayer_wave1.sql` (run + verified in Supabase, `verify_003` JSON `all_ok:true`; rollback `003_rollback.sql`, NOT run). **Four** per-church tables, each idempotent and ending with `DISABLE ROW LEVEL SECURITY` (Inv #5/#10), each with nullable `church_id` + FK + indexes (Inv #153–#156): **`prayer_requests`** (`audience_type ∈ {lcg, individuals, all, discipler_pastor}`; `audience_lcl_id` for LCG, `audience_member_ids uuid[]` GIN-indexed for the individuals set; anonymity, category, status, `care_flag_by`, `expires_at`), **`prayer_list_items`** (saved-to-list, partial `UNIQUE(member_id,request_id) WHERE request_id NOT NULL`), **`prayer_list_opens`** (logs each My-List open), **`intercessions`** (exists for Waves 2–4; unused in W1).
- **Audience semantics:** `lcg` = requester's LC group (LCL linkage, Inv #1/#46, never `lc_group` text); `individuals` = a hand-picked set drawn from the **full same-kind church roster** (reach outside the requester's LCG, per spec — `share_with_lc` opt-outs + self excluded); `all` = everyone (still kind-bubbled); `discipler_pastor` = the requester's discipler **plus** any pastor, where pastor detection keys on **`pipeline_level >= 5`** (L5 Pastoral Staff, mirrors `_isSuperuser`'s L5 rule — MMT has no `_isSuperuser`), degrading to **discipler-only** inside a guest/test bubble with no L5.
- **Kind bubble (Inv #164):** every audience, picklist, and feed row is bounded by `requesterKind === viewerKind`, viewer read from the member's own `members` row (Inv #162 — never the session shim). Helpers are **local to the prayer block** in `member_tool.html`; **Phase B:** centralize a shared `sameKind` in `multiply_shared.js`.
- **No gamification UI (Pastor's standing intent):** the prayer surface shows **no points / score / badges**. Wave 4 will feed an **invisible** SVI prayer category (`count_rows`) — gamification stays hidden; SVI factors it silently.
- **Wave 1 bugfixes (S36):** (1) **"Mark answered" is requester-only** — in the feed, only `viewer.id === requester_id` sees it; My-List saved items (request_id NOT NULL) get a **read-only badge** driven by the linked request's status, never a saver button (`2133d79`). (2) **Answer propagates to savers** — on requester-answer, `prayer_list_items` for that request are stamped answered (`answer_note = COALESCE(praise, answer_note)`); saving an already-answered request stamps the new item answered at insert (keeps the W4 `prayers_answered` signal correct) (`2133d79`). (3) **No active action on a non-open request** — answered/archived show the read-only "Answered 🙌" state; Save + Mark-answered are gated to `status==='open'` (`84b134d`). (4) **Single answered indicator** — the gold "✦ ANSWERED" panel is canonical; the duplicate green pill was dropped (`486c3eb`). (5) **My-List is a layered overlay** over the Requests sheet (like compose), so closing it returns to the main sheet; the main sheet closes only via its Close button, not a backdrop tap (`9877dbe`, `938ad3f`).
- **Wave 2 SHIPPED (S36, `7daca68`)** — encouragement layer, all in `member_tool.html`, no SQL (tables already existed), no `?v=` bump: 🙏 **intercession** ("Prayed" tap → `prayer_intercessions` row; aggregate "N praying" = COUNT(DISTINCT member_id), no names/leaderboard); **pull aggregates** for the requester ("💾 saved by N · 🙏 N praying", read in-feature, no inbox); **praise → celebration feed** (answered+praise becomes a computed celebration win, anonymity preserved); **soft care flag** (`care_flag`/`care_flag_by` + a `kind='prayer_care'` notification to the requester's discipler + same-kind pastors, Inv #16 soft; anonymity exception names the requester to discipler/pastor only); **My-List category filter** (saved items by linked-request category; personal/EOLO bucketed). Counts are same-kind by construction (kind-bubbled visibility).
- **Phase-2 RLS flag (cross-member writes):** intercession insert, care flag + notification, and answer-propagation write OTHER members' rows — fine now under RLS-disabled, but under Phase-2 RLS they must route through **`SECURITY DEFINER` RPCs**. Logged for the tenancy arc.
- **W3 still HELD until Pastor's go:** reminders + EOLO seeding + auto-expiry via `expires_at`. **W4** = silent SVI prayer category (`count_rows`, lowercase). No `multiply_shared.js` change → consumers stay `?v=4`.

**Established June 14, 2026 (Session 35; Wave 2 + bugfixes S36). Invariant #165 added — count now 165.**

### **166. DENORMALIZED TEXT MIRRORS are DECORATIVE — canonical grouping, matching & display is ALWAYS `id` → current record, never stored text**

`lc_group` (member text label), `member_lc_group` and `event_lc_group` (attendance snapshot columns) are **display-only**. They are sparse (most are NULL), drift on transfer, and are NULL on **self-attest** rows. They must **NEVER** be used for **grouping, matching, filtering, counting, joining, or categorizing**. The single canonical key for "which LC group" is the member's **`discipler_id` → LC Leader (LCL)** (generalizes Inv #1/#16/#45/#59).

- **GENERAL RULE (S37): this applies to EVERY stored text mirror, not just the lc_group family** — `discipler_name`, `member_name`, `facilitator_name`, `member_lc_group`, `event_lc_group`, `pending_lc_group`, the legacy `discipler` column, etc. They are **snapshots that go stale** on renames / transfers / drift. Canonical resolution for grouping, matching, AND display is ALWAYS the **id → the current record** (`discipler_id`/`facilitator_id`/`member_id` → live `members` row). Never trust a stored name/label for a decision; for display, resolve `id` → current name where practical. **Evidence (S37):** a `discipler_name`-vs-`discipler_id` diagnostic found 2 members (John Vincent Cayabo, Yuan Kyle Ambrocio) whose `discipler_name` still read "Melvin Aquino" after that leader renamed to "Choti Aquino" — `discipler_id` correct, stored text stale. Harmless (decorative) but illustrates the rule.
- **Allowed (DISPLAY):** showing a group's name. Even then, prefer resolving the name via `discipler_id` → LCL → display name (`leader.lc_group` if set, else `"{FirstName}'s LCG"`), not a member's stale stored text.
- **Forbidden (BUG):** `.eq('lc_group', …)` / `.eq('member_lc_group', …)` as a query scope; building group buckets keyed by an lc_group string; matching attendance to a leader by `event_lc_group`/`member_lc_group`; `GROUP BY member_lc_group|event_lc_group|lc_group` in any SQL view/function; counting audience membership via `lc_groups.includes(m.lc_group)`. Transfer state is decided by `pending_facilitator_id` vs `facilitator_id`, **never** `pending_lc_group !== lc_group`.
- **Root case (S35):** the LACR grouped members by `discipler_id` but **matched** attendance by `event_lc_group`/`logged_by_id`. Self-attest rows (lc_group NULL, logged_by_id = the member) never matched → groups falsely shown "Awaiting Your Heartbeat." Fixed by attributing each attendance row via the **attended member's** `discipler_id` (`lc_attendance_report.html`, `e23554f`).
- **Decommission — ✅ COMPLETE (S35–S37):**
  - **Tier 1 ✅** attendance reports re-attributed by member `discipler_id` — LACR (`e23554f`) + LCG Pulse (`bca7871`); both gained the three-state heartbeat (Inv #167) and now exclude test+guest (Inv #15).
  - **Tier 2 ✅** repo-wide classified audit + read-only `diag_lc_group_views.sql` (`ba8d647`).
  - **Tier 3 ✅** announcement LCG targeting → `lcl:<leaderId>` keys + `discipler_id` matching across MD + MLT + MMT (`e889be1`); legacy text drafts fall back; new ones reach null/stale-`lc_group` flocks.
  - **Tier 4 ✅** absence-notice heads-up filtered by live `discipler_id` (own disciples only, no church-wide bleed) (`dc15c8f`); transfer-state by `pending_facilitator_id !== facilitator_id` (MLT + transfer_management) and MMT LC-family by `discipler_id` (`0dfc641`).
  - **SQL (S37):** **`migrations/004` RUN** by the Pastor — `promote_pending_lc_transfers()` now promotes by `facilitator_id`/`discipler_id` (the old fn moved only decorative text and never the LCL pointers). **`005` RUN** — the 6 dormant lc_group indexes dropped. **`006` REMOVED (moot):** the 3 target views (`v_member_attendance_rates`/`v_attendance_summary`/`v_consecutive_absences`) **never existed** — confirmed live (`pg_views` 0 rows, `pg_class`/`pg_namespace` no relation of any kind). Phantom from a schema-dump name-list comment.
  - **Transfer mis-attribution check (S37 — no remediation):** the `discipler_name`-vs-`discipler_id` diagnostic returned **2 rows** (Cayabo, Ambrocio) — both the **name-change artifact** above (leader Melvin→Choti Aquino; `discipler_id` correct), NOT a buggy promote. No evidence the old text-only function was ever used → **no past damage, nothing to fix**.
  - **Tier 4C (deferred, cosmetic):** `index.ts` (compute-svi-weekly) writes `lc_group` into `svi_snapshots` as a **passenger** column (`v_svi_latest` keys on `member_id` — decorative). Changing to `discipler_id` needs an Edge redeploy; defer unless full purity wanted.
- **Optional cosmetic backlog (human-gated, NOT required):** a one-shot refresh to clear stale denormalized names — `migrations/007_refresh_stale_discipler_names.sql` (sync `members.discipler_name` to the current leader's name). At the Pastor's discretion; purely cosmetic (canonical decisions already use `discipler_id`).

**Established June 14, 2026 (Session 35; sweep completed S36; generalized to all denormalized text + DONE S37). Invariant #166 added — count now 166.**

### **167. ATTENDANCE REPORTS use the three-state heartbeat, attributed by the member's `discipler_id`**

LACR + LCG Pulse classify each LCG/week by a three-state heartbeat (generalizes #166 for the attendance-report family):
- **Logged** — ≥1 leader-authoritative attendance row (`source ∈ {lcl_logged, stand_in, pastor_admin, backfill}`).
- **Self-Attested · Awaiting Confirmation (N/M)** — no leader row but ≥1 `self_attest` present row → the group/week met but awaits the leader's log; shown distinctly (LACR section + tile; Pulse purple heatmap cell), counted as "met" so it is **not** falsely flagged.
- **Awaiting Your Heartbeat** — no attendance of any source.

Every row is attributed by the **attended member's `discipler_id` → LCL** (Inv #16/#166), never `event_lc_group`/`logged_by_id`/text. Present/absent counts include ALL sources. Both reports exclude **test AND guests** (Inv #15) — the Pulse was test-only before S36 (latent guest-inflation gap, now closed). The attendance `UNIQUE(member_id,event_type,event_date)` means counts never exceed the member count.

**Established June 14, 2026 (Session 36). Invariant #167 added — count now 167.**

### **168. DEVOTIONAL reflection nag is EXISTENCE-GATED — never fires on a devo-less day**

The MMT gentle reflection reminder (`loadReflectionGap`) fires only when **(a)** a `devotionals` row exists for **today's** date AND **(b)** the member has no non-empty reflection for today. No devotional today (Sundays / gaps / holidays) → suppressed entirely (the home card already shows the gentle "no devotional today" state). The gap query runs in parallel with `loadTodaysDevo`, so it does its OWN existence query rather than reading the `todayDevo` global. Date basis = device-local YMD (Manila on a Manila phone, Inv #12) — not UTC. Completion is **today-only** (the existence gate retired the old yesterday-lookback workaround). Fail-soft: a read error never nags (`c0f41aa`).

**Established June 14, 2026 (Session 36). Invariant #168 added — count now 168.**

---

### **169. EMBED-MODE session arrives async — never read `LEADER`/`isPastor()` synchronously at script-load**

In the unified shell, MD and MLT load as **iframes** (`?embed=1`) and the session is delivered **async via postMessage AFTER** `const LEADER = window.LEADER || {}` binds. At script-load time in embed, `LEADER` is `{}` (`leaderLevel` undefined, `isPastor()` false). Any synchronous IIFE, scope check, or tab-reveal that reads `LEADER.leaderLevel` / `isPastor()` at load runs **too early** and gets the wrong answer — symptoms seen: SVI report scoped to 'your disciples · 0' for the Pastor, the '🔓 All Members' tab hidden, My-Ministry nav wrong. **Standalone is unaffected** (the gate runs synchronously first). **Rule:** in embed, after `const LEADER`, run an embed-only re-sync — `if (MultiplyShared.isEmbedMode?.()){ MultiplyShared.embedSessionReady(<ms>).then(()=>{ const s=MultiplyShared.getValidSession(); if(s) Object.assign(LEADER,s); /* re-run boot fns */ }); }` — that mutates `LEADER` **in place** and **re-runs the boot IIFEs**. To make them re-callable, convert anonymous boot IIFEs to **named hoisted functions** (e.g. `revealPastorTab`, `_refreshMyMinistryNav`, the scope-count setter). Confirmed live in the iframe console: `LEADER.lvl=undefined | isPastor=true | sess.lvl=5 | embed=true`.

**Established June 19, 2026 (Session 38). Invariant #169 added — count now 169.**

---

### **170. Supabase Edge Functions have a ~150s wall-clock hard limit — bulk-prefetch, never per-member sequential queries**

The `compute-svi-weekly` Edge Function (repo-root `index.ts`) must finish a full **231-member** compute inside Supabase's **~150-second wall-clock hard limit**. A per-member loop with ~10 sequential `await supabase.from()` round-trips (~2,500 queries) **exceeds it** — observed `⏱150,201ms→546` / `⏱152,105ms→504`, the function is killed, and **no `svi_snapshots` are written** (so any new scoring silently never takes effect). The OPTIONS 200s are just CORS preflights; a test-panel '500 Cannot read … (error)' is the panel choking on the killed function, not a code bug. **Rule:** prefetch **every** data source **ONCE** at the top (paginating past PostgREST's **1000-row cap**), build per-member maps, and read them **in-memory** inside the per-member loop. **No `await supabase.from()` may remain inside the per-member loop.** Aggregation/rate/score math must stay **byte-identical** to the per-query version (verify by dry-running the same 2–3 members before/after — scores must match exactly, Inv #112). Stopgap offset-batching was rejected in favor of this durable bulk-precompute (Pastor: 'I can wait').

**Established June 19, 2026 (Session 38). Invariant #170 added — count now 170.**

**✅ RESOLVED (June 19, 2026, same session):** the `svi-ef-bulk-prefetch` refactor shipped + the EF was redeployed — the full 231-member compute now finishes in **seconds**. Verified on `main`: bulk prefetch fully paginated (`fetchAllPaged`/`.range()`), `computeMemberSnapshot` **synchronous with zero `await supabase.from()` in the per-member loop**; dry-run parity = expected (no drift). The RULE above stays binding for all future Edge-Function work.

---

### **171. SVI LC-meeting scoring — member's OWN LC-Meeting attendance, L2+ only, with no-meeting softening**

The SVI `service_lc_led`, `gather_lc`, and `fellowship_lc_rate` metrics are driven by **LC-Meeting attendance**, precomputed once into a `meetingsHeld` Map (`Map<lcKey, Set<date>>`) from the unfiltered member map × an 8-week window of **present** LC-Meeting rows, where `lcKeyOf(m)` = the member's own id if **L2+** else `discipler_id`. A 'meeting held' = **≥1 group member present**.
- `service_lc_led`: **L<2 → `{raw:null, score:null}`** (NOT counted — null is excluded from the SVI denominator, ≠ score 0 which IS counted). For **L2+**, raw = `meetingsHeld.get(member.id).size` → `applyScoreRules` (`linear_threshold` tiers 7→10, 5→7, 3→4, 1→2, 0→0). The EF special-cases this metric **by metric_key** (a vestigial `compute_config.computed:lc_meetings_led` is harmless).
- `gather_lc` / `fellowship_lc_rate`: if the member's LC **did not meet** that window → `score = compute_config.no_meeting_floor_score` (= **4**) + note `no_meeting_held` (partial softening, **not** full 0). A **real low score is kept** when the LC met but the member was absent. Source = the **member's own** LC-meeting attendance, **not** the LCL's. `migrations/010_lc_meeting_scoring.sql` set the tiers + merged the floor (RUN + verified by the Pastor). ✅ **Now LIVE (June 19, 2026)** — the bulk-prefetch refactor (Inv #170) shipped and the EF was redeployed, so LC-meeting scoring takes effect; observed scores shifted as designed (e.g. May Ann fell below 70.67 as `service_lc_led` counted / gather-fellowship softened).

**Established June 19, 2026 (Session 38). Invariant #171 added — count now 171.**

---

### **172. Preaching Auto-fill window anchors to the END of the schedule, never a rolling-from-today window**

`autofillNext12()` in `preaching_admin.html` anchors its 84-day fill window to the **end of the current schedule**, not to `today`. Compute `lastAssigned` = max `preach_date` in `wednesday_preaching`; set `startDate = the later of (lastAssigned, today)` (never backfill the past); `windowEnd = startDate + 84d`. Each Auto-fill press therefore always extends a **full 12 weeks past the schedule's end** (a rolling `today+84` window shrinks the new coverage as the schedule grows — wrong). **Gaps BEFORE the last-assigned date are intentionally skipped** (forward-extend only — Pastor-confirmed; normal sequential schedules have none). Rotation continuity is preserved because the pointers (Wed '2 then mainstay', Sun 'last-of-month rotates') are computed from DB history `< winStart` and the chronological walk advances them through already-assigned slots; the recurring-pattern past-lookup uses `startStr` (not `todayStr`). The confirm popup prepends a **'From … to …'** span so the affected range is visible. All rotation/leave/insert logic stays byte-identical to the prior window.

**Established June 19, 2026 (Session 38). Invariant #172 added — count now 172.**

---

### **173. Devotional streak + SVI credit require a ≥10-WORD reflection — never a bare reader-close**

`member_tool.html` `closeDevoReader()` must NOT write a devotional `attendance` row (`event_type='devotional'`) on reader-close alone — that inflated streaks/SVI off pure reads and violated Inv #62 (a devotional row = reflection COMPLETION). A devotional counts (streak advances, SVI credit, home-nag clears) ONLY when **today's** reflection has **≥10 words** — `_wordCount()` splits on `\s+`; `_devoCompleteToday()` is the single source of truth (also used by `loadReflectionGap`). Closing with <10 words shows an exit-reminder modal ("Keep writing" / "Exit anyway"): the partial text is still saved, but no streak/SVI credit. Historical inflated rows were cleaned by `migrations/011` (diagnostic + cleanup + rollback), **RUN by the Pastor** (today-inclusive, idempotent), backup table `_backup_devo_attendance_cleanup_20260620`; deleted rows were all 0-word reads, lowest kept = 18 words (clean separation).

**Established June 20, 2026 (Session 39). Invariant #173 added — count now 173.**

---

### **174. LC Celebration feed — streak floor 6 + the LC leader's own streak is an always-on modeling win**

In `member_tool.html` `loadCelebrationFeed()`/`renderCelebrationFeed()`: streak celebrations show **continuously while the streak is ≥6 days** (floor was 7), group badge reads "6+". The **LC leader's own streak** is pushed as a modeling win with a **👑 LC LEADER** tag and is **always-on** — it ignores `share_with_lc` (the leader models the habit for the flock). Self appears as "You"/"Ikaw" when they have a qualifying win.

**Established June 20, 2026 (Session 39). Invariant #174 added — count now 174.**

---

### **175. LC Celebration feed — self-anchor only for no-discipler pastoral staff who lead a flock**

The feed is scoped to an LC. For **top-of-tree pastoral staff with no discipler** (`!memberRow.discipler_id || discipler_id===self`) who **lead a flock** (a count of members with `discipler_id===self` > 0), anchor the feed to **self** (`lcLeaderId = MEMBER.memberId`) so they see their own LC's wins. **Normal LCLs who have an upline keep seeing the LC they belong to** (`lcLeaderId = memberRow.discipler_id`) — do NOT anchor every LCL to self. The flock query, eligible filter, and leaderRow all key on `lcLeaderId`; `streakIds = [...new Set([...lcIds, leaderRow.id])]`.

**Established June 20, 2026 (Session 39). Invariant #175 added — count now 175.**

---

### **176. Inside a `zoom:var(--fs)` container, centered-column padding must divide 100vw by var(--fs)**

When a container carries `zoom:var(--fs)` (MMT A−/A+ font slider on `.content-wrap`/`.reader-body`), its available width becomes `100vw ÷ fs`, but a centered-column padding written as `calc((100vw − 520px)/2)` still uses the **un-zoomed** 100vw → at fs>1 the padding exceeds the shrunken width and content collapses to a 1-letter-per-line sliver. **Rule:** every centered-column padding **inside** a zoomed element must use `100vw / var(--fs, 1)` (the four inside-zoom sites in MMT were fixed; native chrome **outside** the zoom — topbar, tabbar, reader-topbar, fab-controls — stays unchanged).

**Established June 20, 2026 (Session 39). Invariant #176 added — count now 176.**

---

### **177. Shared Close affordance lives in a sibling module `multiply_close.js` — NOT in multiply_shared.js**

Standalone pages (assessments, viewers) get their ✕ Close from repo-root `multiply_close.js?v=1` — an Inv #74-style **sibling module** with **independent `?v=`** (like `multiply_slides_nav.js`). It self-injects a fixed top-right ✕ Close (idempotent, bilingual `.tl-text`/`.en-text`) and returns to the launcher **without closing it** (Inv #12): `window.close()` → same-host `history.back()` → referrer → safe home (`data-home`, default `index.html`); exposes `window.MultiplyClose={mount,close}`; auto-mounts (handles early/late load). It is **deliberately NOT folded into `multiply_shared.js`** — none of the 7 assessments load shared.js, so folding it in would add a shared.js+Supabase dependency to 7 files AND force a lockstep `?v=` bump across all ~15 shared.js consumers (Inv #138) for ~10 lines of DB-free logic. **Launch contract:** MD opens assessments via `window.open(getProfileUrl(...), '_blank')` (NEW TAB → `window.close()` returns to MD with the modal intact); MMT opens them same-frame via `location.href = a.file+'?id='+id`. All 7 assessment instruments now load the module.

**Established June 20, 2026 (Session 39). Invariant #177 added — count now 177.**

---

### **178. MMT lands back on the launching screen (Discover) after an assessment — sessionStorage + pageshow**

Because MMT opens assessments same-frame (Inv #177), Close → `history.back()` returns to MMT but a reload boots to the default Home — the active screen is SPA state, not in the URL. Fix (all in `member_tool.html`): `goTo(pageName)` persists `sessionStorage.mmt_current_screen`; `openAssessment()` stamps `sessionStorage.mmt_return_screen` (= current, fallback `'assess'`) before navigating; a top-level `pageshow` listener does a **one-shot** restore — read `mmt_return_screen`, remove it, `goTo()` it — so MMT returns to **Discover** (`page-assess`). Covers both full reloads AND bfcache restores; because the key is set only by `openAssessment` and consumed once, fresh logins still land on Home. MD is unaffected (separate file/tab).

**Established June 20, 2026 (Session 39). Invariant #178 added — count now 178.**

---

### **179. Assessment font-slider standard = `document.body.style.zoom`, 5 steps, per-instrument key — only safe on max-width-centered pages**

Every assessment's A−/A+ slider applies `document.body.style.zoom = scale` with steps `[0.90, 1.00, 1.10, 1.25, 1.40]` (idx 1 = 100%), a unique localStorage key `multiply_<instrument>_fontscale`, label `Math.round(scale*100)+'%'`, A− disabled at idx 0 / A+ at idx 4. This is **only safe on pages centered by `max-width + margin:auto`** (the assessments) — never on vw-padding layouts (cf. Inv #176, which is why MMT uses container-`zoom` + `100vw/var(--fs)` instead). `body.style.zoom` is a style, so it survives a `setLanguage()` `body.className` reset. **Enneagram parity (this session):** its language toggle was moved top-right → **bottom-right floating** to clear the ✕ Close, and the missing font slider was added — so **all 7 instruments now have Close + font + language parity**.

**Established June 20, 2026 (Session 39). Invariant #179 added — count now 179.**

---

### **180. Tenancy auth = Path 1 — custom HS256 JWT signed with the LEGACY shared secret**

The project's CURRENT signing key is **ECC P-256 (asymmetric)** and its private key is **not exportable**, so we cannot custom-sign with it. The **Legacy HS256 shared secret is "previous" but still in the verify set** — so the `auth-login` Edge Function mints a custom **HS256** JWT signed with it (EF secret `JWT_SECRET` = the Legacy JWT Secret). **NEVER revoke the legacy key** while this is in use. If Supabase ever drops legacy verification, migrate to the GoTrue **custom-access-token-hook (Path 2)** — rejected for now as too heavy. RLS then reads the church from `public.auth_church_id()`.

**Established June 20, 2026 (Session 40). Invariant #180 added — count now 180.**

---

### **181. `auth-login` Edge Function contract — verify_jwt OFF, bcrypt PIN, claim set**

`auth-login` is the LOGIN endpoint → deployed with **Verify JWT = OFF** (there is no token yet at call time; it does its own PIN auth). It reads the member via the **service-role key**, verifies the PIN with **`npm:bcryptjs@2.4.3` `compareSync`** (must stay byte-compatible with the browser's bcryptjs 2.4.3 `$2a$` cost-10 hashes), and mints `{sub:member.id, role:'authenticated', aud:'authenticated', church_id, leader_level, name, is_test, is_guest, iat, exp(+8h)}` (djwt HS256, key from env `JWT_SECRET`). Returns `{token, expires_at, profile}`. **Uniform `invalid_login` 401 on every failure** (never reveal id-vs-PIN). CORS `Allow-Origin: *`. `SESSION_HOURS = 8`.

**Established June 20, 2026 (Session 40). Invariant #181 added — count now 181.**

---

### **182. JWT-claim SQL helpers + the `church_id` auto-stamp trigger**

`public.auth_church_id()` / `auth_member_id()` / `auth_level()` read `request.jwt.claims` and are **NULL-safe** (no claim → NULL/0 = anon behavior; in the SQL editor they return NULL/0, which is correct). RLS policies key on `church_id = public.auth_church_id()`. `church_id`-on-insert is **centralized** in the **`set_church_id_from_jwt()` BEFORE INSERT trigger**, attached **dynamically (DO-loop)** to every per-church table that has a `church_id` column **EXCEPT `devotionals`** (NULL = shared/global) and `_backup%` (45 tables as of Session 40). It sets `church_id` from the claim **only when the row left it NULL**; service-role/anon inserts (no claim) stay NULL (unchanged). **Do NOT edit per-page insert sites to set `church_id`** — the trigger owns it.

**Established June 20, 2026 (Session 40). Invariant #182 added — count now 182.**

---

### **183. The DB client MUST carry the JWT for RLS (the mixed-client rule)**

RLS only scopes a request that **presents the church-scoped JWT**. `MultiplyShared.getDB()` attaches `Authorization: Bearer <sessionStorage.multiply_jwt.token>` when present/unexpired, else falls back to anon (C2). **MLT, MMT, and MD all route through `getDB()`** (MD was switched off its own anon client in C3a). **Any standalone page that builds its OWN `supabase.createClient` is ANON** and must **inline-attach** the JWT (`_readTenancyJwt()` + `opts.global.headers.Authorization`) **before** RLS touches any table it uses, or it gets locked out. Known own-anon pages still pending before their tables' RLS: the **3 assessment instruments** (token-flow — no login, so no JWT), the **2 login pages** (anon pre-auth — special), and **2 debug tools** (ignore).

**Established June 20, 2026 (Session 40). Invariant #183 added — count now 183.**

---

### **184. `multiply_shared.js` has 19 consumers (lockstep `?v=`) — corrected from the stale "8"**

Any change to `multiply_shared.js` bumps `?v=` in **lockstep across ALL 19** referencing files (Inv #138). The canonical set (deployed at `?v=7` as of Session 40): `attendance_admin`, `btli_quiz_admin`, `btli_quiz_player`, `devotional_admin`, `index`, `lc_attendance_report`, `lc_leader_tool`, `lc_member_report`, `lcg_pulse_report`, `lesson_quiz_editor`, `member_attendance_report`, `member_tool`, `multiply_dashboard`, `preaching_admin`, `preaching_calendar`, `quiz_scores_report`, `shell_harness`, `transfer_management`, `usbong_quiz_player`. **Verify "zero stragglers" by scanning every repo HTML**, never by memory. (Standalone pages that load only `multiply_close.js` are NOT consumers — see Inv #177.)

**Established June 20, 2026 (Session 40). Invariant #184 added — count now 184.**

---

### **185. RLS rollout discipline (per-table canary) — supersedes "always DISABLE RLS" for migrated tables**

Before enabling RLS on a per-church table: **(a)** confirm EVERY read/write path carries the JWT (Inv #183) — else those paths are locked out; **(b)** backfill `church_id IS NULL` → the owning church (else a SELECT policy hides those rows); **(c)** create SELECT/INSERT/UPDATE/DELETE policies `TO authenticated` on `church_id = auth_church_id()`; **(d)** `ENABLE ROW LEVEL SECURITY`; **(e)** keep a one-line `DISABLE` rollback ready (free tier = no backups). **Test isolation via a browser/curl JWT, NEVER the SQL editor** — the postgres owner bypasses non-forced RLS, so the editor always "sees everything" and will give a false all-clear. Once a table is RLS-scoped, the old **Inv #10 "DISABLE on every new table" no longer applies to it**. First canary: `debrief_records` (Session 40) — isolation proven (Agape token → `[]` vs Rosehill → 5 rows), reads + writes confirmed (a new debrief was created in-app AND revisited to confirm it persisted).

**Established June 20, 2026 (Session 40). Invariant #185 added — count now 185.**

---

### **186. Purge allow-all stubs + verify EXACTLY 4 policies around ENABLE (the `absence_notices` lesson)**

A per-church table can carry **dormant pre-existing policies** while RLS is disabled; `ENABLE` activates them. PERMISSIVE policies for the same command are **OR-combined**, so any leftover **allow-all** policy (`TO public`/`anon` with `USING(true)` and/or `WITH CHECK(true)`) **defeats** the church-scoped policy (`true OR church_id=auth_church_id()` = always true) → cross-church leak. **Before ENABLE, run CHECK B:** `SELECT ... FROM pg_policies WHERE tablename IN (...)` and **DROP any PERMISSIVE `public`/`anon` policy with `qual=true`/`with_check=true`**. **After ENABLE, the structural verify must show `policy_count = 4` EXACTLY (not >=4)** — a count of 6 on `absence_notices` (Session 41) caught two stale `*_read`/`*_write` allow-all stubs silently bypassing isolation; dropping them restored `[]` for the foreign token. The CC pre-RLS audit now includes this `pg_policies` scan alongside the JWT-path grep.

**Established June 21, 2026 (Session 41). Invariant #186 added - count now 186.**

---

### **187. RLS batch-migration pattern (016-019) - extends #185**

Each safe-now batch follows one shape: **(a)** CC read-only audit (JWT-path grep + Inv #186 `pg_policies` scan); **(b)** migration per table - `UPDATE ... SET church_id = (SELECT id FROM churches WHERE slug='rosehill') WHERE church_id IS NULL` (**slug subquery, never a hardcoded UUID**), `DROP POLICY IF EXISTS` x4, `CREATE POLICY` x4 `TO authenticated` on `church_id = public.auth_church_id()`, `ALTER TABLE ... ENABLE ROW LEVEL SECURITY`; **(c)** structural verify (`relrowsecurity=true`, `policy_count=4`, `null_church=0`); **(d)** app smoke (re-login -> the live app still reads/writes as the owning church); **(e)** isolation curl (foreign token -> `[]`, owning token -> rows). **One representative table per batch is sufficient** for the curl - all tables in a batch share the identical `auth_church_id()` predicate. **Migrations shipped Session 41:** `016` cohort family (cohorts, cohort_members, cohort_lesson_unlocks, pipeline_lesson_grants); `017` communication family (announcements, announcement_acks, announcement_retraction_dismissals, absence_notices, notifications); `018` sermons; `019` preaching (preachers, wednesday_preaching, preaching_swap_requests). **Diagnostic:** `HTTP 000` from curl = a connection/network/curl-side issue (browser unaffected) - **never** an RLS or auth signal; the app-load smoke is the authoritative no-lockout proof when curl is flaky.

**Established June 21, 2026 (Session 41). Invariant #187 added - count now 187.**

---

### **188. A logged-out/`?me=` anon page must be JWT-gated BEFORE its tables get RLS (Option A); writes must be authenticated**

If a page has any **logged-out path** (no `sessionStorage` -> `getDB()` is anon - e.g. the `preaching_calendar.html` `?me=` bookmark/external/PWA/`noopener` fallback, Inv #149), enabling RLS on the tables it reads/writes would break that path (empty reads, rejected inserts). **Fix before RLS = gate the whole page on a valid JWT at boot:** an **inline** `_hasValidTenancyJwt()` (mirror of `_readTenancyJwt`, kept inline to avoid a `?v=` bump) -> no JWT renders a "Please log in" panel and makes **zero** DB calls; a valid JWT loads normally. **Writes under tenancy must be authenticated** - a bare `?me=` id alone must never authorize an insert (the swap-submit gate now also requires the JWT). Same-origin `window.open` launches from gated pages carry the JWT and are unaffected. Shipped Session 41 (`841a8bf`). Deferred note: the calendar also reads `members` anon - handle before `members` RLS.

**Established June 21, 2026 (Session 41). Invariant #188 added - count now 188.**

---

### **189. CC prompts are always a single pastable fenced code block**

Every Claude-Code prompt is delivered as **one triple-backtick fenced code block** - never blockquotes or prose - so the Pastor copies + pastes in a single action with no markdown artifacts. Applies to every CC prompt by default, not just `gmp`/session-close. (Pastor preference, Session 41.)

**Established June 21, 2026 (Session 41). Invariant #189 added - count now 189.**

---

*"A student who is fully trained will be like their teacher." — Luke 6:40*
