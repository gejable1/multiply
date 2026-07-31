# MULTIPLY — INVARIANTS

**Purpose:** This file is the durable, canonical record of all standing rules, technical patterns, and pastoral principles that govern the MULTIPLY platform. It is **not operational state** (that lives in `HANDOFF.md`). Items here are RULES OF THE SYSTEM that Claude must read at session start and preserve across all future builds.

**Standing rule:** An invariant is removed from this file ONLY when explicitly retired by Pastor Gerry. HANDOFF.md rewrites must NEVER drop, summarize, or rephrase items from this list.

**Last reviewed:** July 7, 2026 (Session 60 — #273 Step 4 (AI-research chip) LIVE (S59, reconciled), #274 session = sessionStorage/8h/verbatim-handshake/no-refresh, #275 in-app report embed via `_openLessonViewerModal`+`?embed=1`+hideNewTab, #276 SW `networkFirst` 3.5s timeout (wake white-screen fix), #277 MMT poll fetch-once+visibility-gate, #278 raw.githubusercontent CDN staleness; **count now 278**). July 6, 2026 (Session 58 — #265 Full-Unify catalog (`trackable`+`meta`), #266 overlay writes send no church_id (stamp trigger `061`), #267 partial-index overlay cannot be PostgREST-upserted (manual insert-or-update), #268 `noopener` strips sessionStorage (redirect loop), #269 `churches` SELECT-only (EF or dedicated table), #270 `pathway_section_order` interleave by rung_key, #271 Pulse Building-Rhythm partition + solo weak-guard, #272 commit migrations immediately (uncommitted breaks CC greps); **count now 272**). June 29, 2026 (Session 51 — #227 MLT "+ Add Member" pastor-gated via `churches.settings.mlt_add_member` (MD writes through the `church-settings-flag` EF, `pipeline_level>=5` server-enforced; MLT shows-always / enabled-when-on with a visible "· off" state + an `openAddMember` guard, level read via `_liveLeaderLevel()` to survive the embed `currentLeader` snapshot freeze); also: MLT repainted near-black -> slate-blue, mobile member-footer made horizontally scrollable so Delete is reachable, MMT Journey icon ladder -> footprints (tofu fix); **count now 227**). June 26, 2026 (Session 50 — #222 dynamic church-name branding painted from `churches.name` with an anti-leak no-name fallback, #223 authoritative auto-refreshed structure-only `schema.json` at repo root, #224 dashboard-editor EFs default Verify-JWT ON (secret-gated S2S calls 401 at the gateway until `--no-verify-jwt`/toggled off), #225 "Re-run jobs" replays the pinned stale SHA (push-rejected) — use "Run workflow" for a fresh run from current main, #226 never key JS on positional `:nth-child()` for structural sections — give them stable ids; **count now 226**). June 26, 2026 (Session 49 — #219 base shared-content authoring routes through a service-role publish-lane EF (client JWTs write overlays only), #220 platform author = `members.is_platform_admin` flag (decoupled from any church UUID), #221 literal-string greps miss dynamic `db.from(<var>)` table refs — audit variable table names when sweeping; **count now 221**). June 26, 2026 (Session 48 — #217 session number is claimed at first BUILD, read-in/reconcile is unnumbered "Pre-flight (post-S## reconcile)", #218 per-church tables enforce uniqueness as composite `UNIQUE(church_id, <key>)` not a bare single-column unique; **count now 218**). June 25, 2026 (Session 47 — #213 preflight dumps CHECK constraints (not just policies), #214 async-auth visibility gates must be symmetric (show-if-allowed/hide-if-not), #215 cut CC branches from current origin/main + back-check the diff vs origin/main, #216 client-side per-church writes need tenant policies not service_role-only; **count now 216**). June 24, 2026 (Session 46 — #210 self-verifying migrations / rerun-until-true, #211 EF/service-role inserts must explicitly set church_id, #212 schema_migrations ledger + reconcile-on-open; **count now 212**). Earlier: June 23, 2026 (Session 42 — #190 `token-login` EF (cold-page JWT mint), #191 `multiply_tenancy.js` standalone module, #192 `bootstrap()` `?token=`-cold vs `?id=`-in-app, #193 render-before-tenancy (resume ordering), #194 `?id=`-cold = anon = RLS-blocked, #195 cold share `?token=` / in-app `?id=` / one-token-per-member, #196 no raw-URL previews, #197 recommend elegant+scalable; **member_profiles + gifts_diagnostic RLS-live -> 16 tables**; **count now 197**). Earlier: June 20, 2026 (Session 40 — #180 Path-1 custom HS256 JWT auth (legacy shared secret), #181 `auth-login` EF contract (verify_jwt OFF + bcrypt), #182 JWT-claim SQL helpers + `church_id` auto-stamp trigger, #183 DB client must carry the JWT for RLS, #184 `multiply_shared.js` has 19 consumers, #185 RLS rollout / per-table canary discipline; **count now 185**). Earlier: June 19, 2026 (Session 38 — #169 embed-async LEADER re-sync, #170 EF 150s limit → bulk-prefetch, #171 SVI LC-meeting scoring, #172 preaching Auto-fill anchored to schedule-end; **count now 172** — same-session follow-up: **#170 RESOLVED** (bulk-prefetch shipped + EF redeployed, compute now runs in seconds) and **#171 now LIVE** (LC-meeting scoring in effect)). Earlier: June 1, 2026 (Session 27); count **144** (running history in the dated footers below — #128–#131 added this session: per-person Usbong unlock, present-only attendance, per-lesson roster filter, lesson-unique attendance patterns). Earlier: Session 21 added Invariants **#98–#105**. **#98** (Usbong lesson-lock bridges on the literal track string `'Usbong'`, NOT `'Pre-Pipeline'`), **#99** (habit-nudge forcefulness tuned to audience — forceful-with-escape for leaders, gentle for members; all fail-soft), **#100** (weekly attendance gate: service-window model, always backward-looking, dated labels, LCG rolling-7-day + waivable), **#101** (MLT boot wall is ONE merged modal: attendance + unread announcements), **#102** (announcement unread surfacing must load at boot, not only inside `openAnnouncements`), **#103** (BTLI Zone-1 salvation-assurance gate in `canEnroll`, BTLI-scoped, all enrollers; MD override bypasses by not calling canEnroll), **#104** (MLT enroll pickers show ALL members with advisory badges, never hide the ineligible), **#105** (whole-file `node --check` after any structural JS edit; the "Leader Name/?/empty" screen has two causes — inline throw OR shared.js not loading; mind the cache). **Count now 105.** Session 20 added #95 (`no_gate` fail-closed), #96 (cross-source self-attest guard), #97 (pending notes are hypotheses — verify against live data). Session 19 added #91 (DONE — shared lesson-attest extraction), #92 (self-attest date-snap), #93 (dark-hex on light surfaces), #94 (MD audience picker labels). Earlier:  Invariants #90 (MMT self-attest event parity + lesson sub-picker + member-facing LCG attendance report; plus Prayer of the Day, LCG name fallback, flock fix, count+YOU — all in one cumulative `member_tool.html`) and #91 (lesson-attest resolution is a shared-extraction candidate — logic to shared.js, UI per-file) added. Session 17 added #88 (BTLI L10 Ministry shipped) and #89 (BTLI quiz-gate audit: full-form attendance patterns + lesson_id linkage). Session 16 added #87 (BTLI L9 Evangelism shipped). Invariant #50 stale-clause retired (USAD/UNLAD are BTLI 1 source halves, not separate quiz curricula). Sessions 12–15 added #74–#86: shared slides navigation module (#74), USAD virtues palette ≠ Galatians fruit cycle (#75), USAD 4-movement maps to BTLI 5-movement (#76), USAD-L6 Praying Hands belongs in TUGON (#77), Karamay theology priority (#78), FIY working command (#79), shared font slider is BYO-markup not auto-injecting (#80), inline SVG favicons role-coded (#81), PPTX render-before-ship (#82), L7 shipped (#83), Model X participant lesson/quiz lock final (#84), lesson+quiz gates share live-cohort set (#85), L8 shipped (#86), L9 shipped (#87), L10 shipped (#88), quiz-gate audit (#89). Invariant count: 91 through Session 18; 92–94 Session 19; 95–97 Session 20; 98–105 Session 21 → **now 105**.

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

**Addendum (Session 84 — the `Usbong 1` -> `Usbong` rename).** A number belongs in a curriculum identifier only when the curriculum is part of a **series**. A curriculum with no sibling volume -- none shipped and none planned -- carries no number: `Usbong`, not `Usbong 1`. `BTLI` keeps its number because `BTLI 2` is anticipated and the cohort-slug convention (`btli201_xxxxxx`) already reserves it; renaming `BTLI 1` today would only have to be undone. The test is whether a second volume exists **or is planned**, not how many exist right now. `Usad 1` and `Unlad 1` are struck from the list above: per the Session 10 clarification they are not curricula at all but the source materials for BTLI 1's two halves (USAD = L1-L10, UNLAD = L11-L20), and they never appear as a `course_code`. Renaming a curriculum is never a data-only change -- the code is embedded in `attendance_event_name_pattern` and in every historical `attendance.event_name`, and the eligibility helpers substring-match those against each other, so the code, the pattern and the event names must move in ONE transaction or historical attendance silently stops matching (migration 103, #418, #421).

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

### **190. `token-login` Edge Function — mints a church-scoped JWT from a `profile_tokens` token (the cold-page credential)**

For cold-capable pages (the 7 assessment instruments + `member_self_edit.html`) opened with **no session**, the `profile_tokens` token IS the credential. The **`token-login` EF** (`verify_jwt` **OFF**; reuses the SAME `JWT_SECRET` as `auth-login` — no new secret) takes `{token}`, validates it server-side with the **service role** against `profile_tokens` (exists + `expires_at` in the future), resolves the member's `church_id` from `members`, and mints a short-lived **(+2h)** HS256 JWT with the **same claim shape as `auth-login`** (`sub`, `role`/`aud`=`authenticated`, `church_id`, `leader_level`, `name`, `is_test`, `is_guest`). Returns `{token, church_id, member_id, expires_at}` and bumps `used_count`. Like `auth-login`, it is **dashboard-deployed, NOT in the repo** (commit gap to close). Proven for BOTH Rosehill + Agape tokens (Session 42).

**Established June 23, 2026 (Session 42). Invariant #190 added - count now 190.**

---

### **191. `multiply_tenancy.js` — the standalone tenancy-bootstrap module for cold-capable pages (extends #11)**

A **classic-script UMD module** (`?v=2`, its OWN version) loaded by every cold-capable page AFTER the supabase UMD script — a sibling of `multiply_close.js`. It is deliberately **NOT folded into `multiply_shared.js`** (that would force a `?v=` lockstep across all 19 shared.js consumers, Inv #11/#184). Exposes `window.MultiplyTenancy`: `await tokenLogin(token)` (POST the `token-login` EF, store the JWT in `sessionStorage.multiply_jwt`), **synchronous** `getDB()` (attaches `Authorization: Bearer` when a valid `multiply_jwt` is present, else anon — mirrors `multiply_shared.js` getDB), `await bootstrap()`, plus `readJwt`/`currentMemberId`/`churchId`/`hasValidSession`. The `multiply_jwt` sessionStorage key is **shared** with `multiply_shared.js` getDB (interop by design).

**Established June 23, 2026 (Session 42). Invariant #191 added - count now 191.**

---

### **192. `MultiplyTenancy.bootstrap()` resolves the member by URL mode — `?token=` cold vs `?id=` in-app (hybrid, not always-token)**

`bootstrap()` branches on the URL. **`?token=`** (cold, no session) -> `tokenLogin()` -> returns the **token's** member (`currentMemberId()`), **ignoring any `?id=`**; on token failure it replaces the page body with a bilingual "Link expired or invalid" notice and **throws** (halts the page). **No `?token=`** (in-app) -> returns `?id=` unchanged; the existing login JWT already attaches via `getDB()`. The **hybrid was chosen over always-`?token=` deliberately** — it avoids an EF round-trip + a `profile_tokens` insert on every in-app open (hot-path scalability at 170+ members), per Inv #197.

**Established June 23, 2026 (Session 42). Invariant #192 added - count now 192.**

---

### **193. Render BEFORE tenancy resolution — the autosave/resume ordering invariant**

A cold-capable page's render/build (e.g. `buildQuestions`/`buildPairs`) MUST run **synchronously FIRST** in the init, BEFORE the awaited `bootstrap()`/member-load. Reason: the autosave/resume IIFE (`initIdle.../start()`) runs on `DOMContentLoaded` and **attaches the `saveProgress` `change`/`input` listeners to the question inputs** + calls `loadProgress()` (the resume banner). An async init that `await`s `bootstrap()` **before** building yields at the await, so `start()` runs while the inputs **don't yet exist** -> listeners attach to nothing -> no draft is ever written -> **resume silently breaks** (no banner on return). Caught on the **disc canary (Session 42) before fan-out**; render-first is the fix AND the wiring pattern for all cold-capable pages. (Static-HTML-question pages — conflict, salvation — satisfy this automatically.)

**Established June 23, 2026 (Session 42). Invariant #193 added - count now 193.**

---

### **194. `?id=` opened cold = anon = RLS-blocked; cold writes need `?token=`**

After RLS, an `?id=` assessment link opened **without a session** (incognito / bookmark / not-logged-in) resolves the member but carries **no JWT** -> `getDB()` is anon -> INSERT rejected: **"new row violates row-level security policy for table …"**. This is **RLS working correctly** — and it **proves the allow-all anon stub was dropped** (with the stub, the anon insert would have *succeeded*). In-app `?id=` works only because a session JWT is present; **cold sharing MUST use `?token=`** (Inv #192/#195). Fast discriminator: `sessionStorage.getItem('multiply_jwt')` in the page console (long object = JWT present; `null` = anon). Watch for a **double-`??` typo** in a hand-edited URL (`disc_profile.html??token=…`) — the stray `?` makes the param key `?token`, so `get('token')` returns null and no JWT is minted.

**Established June 23, 2026 (Session 42). Invariant #194 added - count now 194.**

---

### **195. Cold assessment SHARE links use `?token=`; in-app "Take" stays `?id=`; one token per member (reuse-or-mint)**

The assessment URL getters (`getProfileUrl`/`getGiftsUrl`/`getDiagUrl` in MD; `file+'?id='` in MLT) are **shared** between in-app "Take" (`window.open` `?id=`, session present) and cold share — so they are **left as `?id=`**. Only the **share path** tokenizes: MLT `sendLink_` and MD `copyProfileLink`/`copyGiftsLink`/`copyDiagLink` (-> `sendAssessmentLink`) mint/reuse a member token via **`getOrCreateMemberToken(memberId)`** (SELECT a non-expired `profile_tokens` row for the member and reuse it; mint only if none) and build `<file>?token=<tok>`, dropping `&name=` (the page resolves member+name from the token via `bootstrap()`). **One token per member, reused across self-edit + all 7 assessments** (design decision #1). Lives in EACH tool (MD + MLT), never `multiply_shared.js` (avoid `?v=` lockstep). **Never** alter the getters or the in-app Take/Open paths.

**Established June 23, 2026 (Session 42). Invariant #195 added - count now 195.**

---

### **196. Never render a raw `?id=`/`?token=` URL as copyable text (footgun + URL-leak principle)**

A modal/tab must **not** display a raw internal assessment URL as visible/copyable text. Post-RLS a manually-copied `?id=` link is cold-broken, and showing the URL invites exactly that copy (it also differs from what the tokenized Send button actually copies). Show a **hint** ("Click 'Send Personalized Link' …") + the tokenized Send button instead; the share modal MAY show the **tokenized** URL it actually shares. Extends the existing MMT/MLT URL-leak-prevention rule to MD. (Session 42: removed the `${diagUrl}` `?id=` preview in the MD salvation tab.)

**Established June 23, 2026 (Session 42). Invariant #196 added - count now 196.**

---

### **197. Standing recommendation rule — recommend the most ELEGANT + SCALABLE option, never the easiest**

When Claude (chat) recommends among options (design, architecture, tooling — anything), it **defaults to the most elegant and scalable** option and **justifies on elegance + scalability grounds**, never on "simpler / less work." Ease is a **tiebreaker at most**, never the primary criterion. (Pastor directive, Session 42.)

**Established June 23, 2026 (Session 42). Invariant #197 added - count now 197.**

---

### **198. `member_self_edit.html` is JWT-attached via `MultiplyTenancy` — own-anon gate closed**

`member_self_edit.html` dropped its own anon `createClient` + `esm.sh` module; it now loads UMD supabase + `multiply_tenancy.js?v=2` (classic), resolves the member via `MultiplyTenancy.bootstrap()` (cold `?token=` → `token-login` mint; in-app `?id=` → existing JWT), and reads/writes `members` through the JWT-attached `getDB()`. The per-save `profile_tokens` `used_count` bump was removed (the `token-login` EF owns "used" on each fresh session); one **read-only** `profile_tokens` lookup remains for the expiry / saved-banner display. Smoke-proven cold on `gejable1.github.io`: `token-login` 200, `members` GET + PATCH both carry `Authorization: Bearer`, 200. This closes one of the two client-side anon `members` readers that blocked `members` RLS.

**Established June 23, 2026 (Session 43). Invariant #198 added - count now 198.**

---

### **199. `auth-login` is the consolidated login surface — `search` / `login` / `set_pin` (all anon-callable)**

`auth-login` routes on a body `action` field, all three actions anon-callable (pre-auth): **`search`** `{q}` → name-search directory for the login picker (`ilike`, min 2 chars, limit 8) returning `id/name/pipeline_level/facilitator_role/lc_group/discipler_name/is_test/is_guest` + **`has_pin`** — **NEVER** `member_pin_hash`; **`login`** `{member_id,pin}` (**DEFAULT when `action` is absent** — backward-compatible, identical `{token,expires_at,profile}` response as before) → bcrypt-verify via the **service role** + mint an 8h church JWT + best-effort `member_last_login` stamp; **`set_pin`** `{member_id,pin}` → first-login claim, **only when no hash exists** (else `409 pin_already_set`), bcrypt-hash + store + auto-mint the JWT. Deploying it does **not** break current login (no `action` = `login`). The PIN hash never leaves the server.

**Established June 23, 2026 (Session 43). Invariant #199 added - count now 199.**

---

### **200. C3b inline-Bearer for standalone leader-launched `esm.sh` pages (`bulk_send_links`)**

`bulk_send_links.html` attaches the leader's church JWT via the **C3b inline pattern** (read `sessionStorage.multiply_jwt` → if non-expired, `createClient` with `global.headers.Authorization: 'Bearer ' + jwt`; else anon) — **NOT** `multiply_shared.js`, **NOT** `MultiplyTenancy` (it is leader-launched in-app, not cold `?token=`). Same pattern as `ministry_recommender` / `profile_results_viewer`. Under `members` RLS the anon fallback yields an empty list, which **implicitly leader-gates** this admin tool. **Backlog flagged:** its WhatsApp message hardcodes "Rosehill Christian Church" (a multi-tenancy bug once Agape uses it); its `profile_tokens` insert does not stamp `church_id` (matters when `profile_tokens` gets RLS).

**Established June 23, 2026 (Session 43). Invariant #200 added - count now 200.**

---

### **201. `members` RLS REQUIRES server-side login — the anon pre-auth special case**

The login pages' name picker does a **pre-auth anon `members` read** (no JWT can exist before login) **and** downloads `member_pin_hash` to do **client-side bcrypt** verification. Both are fundamentally incompatible with `members` RLS: a `TO authenticated` church-scoped policy returns `[]` to anon (empty picker → lockout), and no anon-readable policy preserves isolation (anon has no church scope). Therefore `members` RLS **requires** moving member-lookup + PIN-verify + PIN-set + last-login fully into `auth-login` (`search`/`login`/`set_pin`, Inv #199) so the login pages touch `members` **zero times** from the client. This also closes a real pre-existing vulnerability (anon download of every PIN hash). `auth-login` (service role) bypasses RLS, so login survives the ENABLE. **Designed Session 43** (the `member_login` + `leader_login` rewire blueprint, in HANDOFF); `leader_login` adds a `stamp:'leader'` flag so the EF also sets `leader_last_login`.

**Established June 23, 2026 (Session 43). Invariant #201 added - count now 201.**

---

### **202. Edge Functions are version-controlled at `supabase/functions/<name>/index.ts`**

`auth-login` + `token-login` are now committed to the repo (`supabase/functions/auth-login/index.ts`, `supabase/functions/token-login/index.ts`) — closing the **dashboard-only gap** (Inv #190 / S40). The repo is **version-control-of-record**; **deploy stays a Supabase dashboard step** (the committed source must be kept in sync with the deployed function by hand on each change). Import-style drift to standardize later: `auth-login` uses `npm:`, `token-login` uses `esm.sh` for supabase-js (both work on Deno; `jsr:` is the preferred form).

**Established June 23, 2026 (Session 43). Invariant #202 added - count now 202.**

---

### **203. Multi-machine git — reconcile clones with `reset --hard origin/main`, never assume `pull`**

Pastor works across a home desktop + a laptop (+ CC web). `main` can be **history-rewritten** from one machine (force-push / rebase / squash), leaving another clone an **orphan history** with no common ancestor — `git pull` then fails ("divergent / refusing to merge unrelated histories"). Reconcile with `git fetch origin` → `git stash -u` (seatbelt) → `git reset --hard origin/main`, **never** a plain pull. The **"sync"** command produces this CC prompt at machine switch. Claude (chat) stays current automatically by curling authoritative `raw.githubusercontent.com/.../main` per the repo-pull rule — only CC's clone needs syncing. (Bit us Session 43: CC's local `main` was a stale orphan at `cb632d6` vs `origin` `9f0979d`; `reset --hard` recovered it, then committed `5e21d25`.)

**Established June 23, 2026 (Session 43). Invariant #203 added - count now 203.**

---

### **204. Unified shell = one login door (`member_login`) for ALL levels; `leader_login` is legacy fallback**

`index.html` is the single entry shell. Boot: no session → `member_login.html?next=index.html`, so **every level (L0–L5) logs in through the member picker** — which is why both a Pre-Pipeline member and the Pastor appear in its search. It then calls `MultiplyShared.ensureBothSessions()`: a member-only session with `memberLevel >= 2` **mints the leader-session counterpart** from the member fields (level < 2 → no-op, fail-closed). L<2 → straight to MMT; L≥2 → role-toolbar shell with MMT/MLT/MD as `?embed=1` iframes, each served the session via the postMessage handshake. Consequence: **`leader_login.html` is bypassed in the unified flow** — reachable only by a direct bookmark or a standalone MD/MLT `gateOrRedirect`. It stays as a rewired, RLS-safe fallback (do NOT delete; retiring it means re-pointing every gate's default redirect — deferred). The `stamp:'leader'` path (`leader_last_login` + `leader_sessions` insert) therefore rarely fires; this is NOT a regression (the old `leader_login`'s anon writes were already shell-bypassed). One church-scoped JWT (minted by member-login; carries `church_id` + `leader_level`) serves MMT/MLT/MD under RLS regardless of role — the leader *session* is only a client-side gate shim, never the RLS scope. **Verified Session 44**: `members` RLS isolation proven in-browser — L5 Rosehill = 236 own-church rows, Agape test member = 1 own row, zero cross-church leakage.

**Established June 23, 2026 (Session 44). Invariant #204 added - count now 204.**

---

### **205. Logout clears ALL session state via `_clearSessionState()`; gate-FAIL paths deliberately do not**

`logoutLeader` + `logoutMember` (`multiply_shared.js`) both route through one private `_clearSessionState()` helper that removes **all three** keys — `multiply_leader_session`, `multiply_member_session`, AND `multiply_jwt` — because a unified-shell leader (Inv #204) holds both session keys + one shared church JWT, so logout from any role tears the whole presence down (fresh login re-mints cleanly); one source of truth → scalable. `leader_login.html`'s `logoutAndRestart` (legacy page, can't load shared.js) inlines the same three `removeItem`s. The **gate-fail paths** (`gateOrRedirect`/`gateMemberOrRedirect`) are deliberately NOT routed through the helper — they fire on session *expiry*, not intentional logout, and on a standalone leader tool a member-session expiry must not nuke a JWT the tool still needs; JWT-clear belongs only at explicit logout. No stranding risk (every logout `location.replace`s away; sessionStorage is per-tab). `?v=7→?v=8` across all 19 consumers. (PRs #13/#15; browser-proven — sessionStorage empty after logout.)

**Established June 23, 2026 (Session 45). Invariant #205 added - count now 205.**

---

### **206. Public views bypass RLS by default — every view must be `security_invoker = true` (or church-filtered)**

A Postgres view runs underlying table access with the **OWNER's** rights by default (`security_invoker=false`); owner here is `postgres` (superuser → **bypasses RLS**), so an owner-view over a per-church table returns **every church's rows** to any caller. Fix: `ALTER VIEW public.<v> SET (security_invoker = true)` → view reads as the *caller*, RLS applies. Audit: `SELECT relname, reloptions FROM pg_class WHERE relkind='v' AND relnamespace='public'::regnamespace` (flag any WITHOUT `security_invoker=true`) + Supabase **Security Advisor → "Security Definer View"**. **New views default to owner-bypass — always set invoker.** (S45 audit: 6 owner-views flipped in `022`.) Parallel surface: `SECURITY DEFINER` *functions* (`pg_proc.prosecdef=true`) — S45 found **zero** in `public` (clean; auth helpers read the JWT GUC, not tables, so they need no DEFINER).

**Established June 23, 2026 (Session 45). Invariant #206 added - count now 206.**

---

### **207. A view's invoker flip only closes the leak if its BASE tables are RLS-enabled — fix the table, not just the view**

`security_invoker=true` makes a view read base tables as the caller — but a base table with **RLS OFF** still returns all rows (no policy = no restriction). A leaky reporting view is a *symptom*; the disease is the unprotected base table. S45: the 4 quiz-grade views read `btli_quiz_attempts`/`usbong_quiz_attempts`, which were per-church (`church_id uuid`) but **RLS-off, 0 policies** — `022` enabled RLS on both (4 `TO authenticated` policies on `auth_church_id()`) AND flipped the views. Always trace a flagged view to its base tables (`pg_get_viewdef`) and confirm each is RLS-enabled before declaring it safe.

**Established June 23, 2026 (Session 45). Invariant #207 added - count now 207.**

---

### **208. Multi-tenancy is NOT yet complete — ~22 church-stamped tables remain RLS-off (corrects the S44 "wall complete" claim)**

S44 declared "every per-church table enforces tenancy / the wall is complete." **Premature.** A full `pg_class` RLS audit (S45) found ~22 tables with a `church_id` column but **`relrowsecurity=false`**, two tiers: **(a) latent — policies written, never `ENABLE`d** (`attendance` 4!, `profile_tokens` 3, `devotionals`/`devotional_reflections`/`ministries`/`ministry_roles`/`system_settings` 2 each, `diagnostic_results` 1) → quick wins after an Inv #186 stub-check; **(b) unstarted — `church_id`, 0 policies** (`transfers`, all 5 `prayer_*`, the `library_*` set, `ministry_roster*`, `attendance_self_attest_log`, `discipler_change_log`, `leader_sessions`). **No active cross-tenant leak today** only because Rosehill is the sole church with real data ("all rows" ≈ "Rosehill rows") — the exposure **activates when Agape onboards real data**, so it is a hard prereq for Agape go-live. Special-care (don't blind-enable): `devotionals` was deliberately excluded from the autostamp trigger (special `church_id` semantics); `profile_tokens`/`leader_sessions` sit on pre-auth EF paths (service-role bypasses RLS so EFs survive — verify client paths). The **RLS-coverage sweep** (batched like 016–019, per-table stub pre-flight + in-browser isolation) is an open arc.

**Established June 23, 2026 (Session 45). Invariant #208 added - count now 208.**

---

### **209. Run large dashboard SQL FLAT (statement-by-statement), never wrapped in one `BEGIN…COMMIT`**

A single `BEGIN…COMMIT` around a multi-statement migration is **all-or-nothing**: if any statement throws (even transiently), the whole block rolls back and the `COMMIT` silently becomes a rollback — **zero trace**, verify shows nothing changed (S45: `022`'s wrapped first run rolled back invisibly — `rls_enabled=false`, un-backfilled NULLs, views still `(none)`). Run flat: each statement commits on its own, so the **exact failing statement** surfaces in red and everything before it **stays applied**. Idempotent design (`DROP POLICY IF EXISTS` before `CREATE`, `UPDATE … WHERE … IS NULL`, no-op re-`ENABLE`) makes a flat re-run safe. The committed version-of-record file must match the form actually run (flat, no `BEGIN/COMMIT`).

**Established June 23, 2026 (Session 45). Invariant #209 added - count now 209.**


### **210. Every migration ships with a trailing self-verify SELECT; rerun-until-true is the safe landing pattern**

The Supabase SQL editor sometimes executes only PART of a pasted multi-statement block (the statement under the cursor, or just the last query) — and a FLAT run (Inv #209) can partial-apply if a statement throws. In both cases the symptom is identical: the verify shows the change didn't fully land. The fix is also identical and safe: because every migration is IDEMPOTENT (Inv #209 — `DROP POLICY IF EXISTS` before `CREATE`, `UPDATE … WHERE … IS NULL`, no-op re-`ENABLE`, `ON CONFLICT DO UPDATE` stamps), **rerunning the whole block simply completes whatever didn't apply — never double-applies, never harms.** So every migration now ENDS with a trailing read-only self-verify SELECT (e.g. `rls_enabled` / `policy_count` / `null_church`), and the Pastor's loop is: run → read column 2 → if not the expected value, rerun the same block → repeat until correct. The trailing SELECT is KEPT in the committed version-of-record file (harmless read; makes every future run self-check; matches the form actually run, Inv #209).

**Established June 24, 2026 (Session 46). Invariant #210 added - count now 210.**

---

### **211. Edge Functions (service-role) MUST explicitly set church_id on per-church inserts — the autostamp trigger can't help them**

The `trg_set_church_id` BEFORE-INSERT trigger (014) fills `church_id` from `auth_church_id()` (the JWT claim) ONLY. An Edge Function using the SERVICE-ROLE key carries NO JWT, so `auth_church_id()` is NULL → the trigger leaves `church_id` NULL → and service-role BYPASSES RLS so the insert still succeeds, silently producing a NULL-`church_id` row that is then INVISIBLE to every JWT client (matches no `auth_church_id()`). Therefore any EF that inserts into a per-church table MUST set `church_id` EXPLICITLY from the member/context it already knows. Caught Session 46: `auth-login`'s `leader_sessions` insert lacked `church_id` → patched to pass it through `stampLogin` (PR #23). Audit every current + future EF write path against this BEFORE enabling RLS on the target table.

**Established June 24, 2026 (Session 46). Invariant #211 added - count now 211.**

---

### **212. `schema_migrations` ledger + reconcile-on-open makes the dashboard-run-not-committed gap self-detecting**

A global metadata table `public.schema_migrations` (`version` PK = zero-padded numeric prefix, `filename`, `applied_at`, `note`; NO `church_id` — global infra, OUTSIDE the tenancy sweep; RLS-on with one `SELECT TO authenticated USING(true)` read policy, writes owner/service-role only). EVERY migration ends with a self-stamp trailer: `INSERT INTO public.schema_migrations(version,filename,note) VALUES(...) ON CONFLICT (version) DO UPDATE SET filename=EXCLUDED.filename, note=EXCLUDED.note, applied_at=now();`. **Reconcile-on-open:** run `SELECT string_agg(version,',' ORDER BY version) FROM public.schema_migrations` and diff the applied set vs the `migrations/` folder (excluding `_rollback`/`_verify`/`_diagnostic`) → buckets {in-sync, applied-not-committed, committed-not-applied}. Run it at the top of any session that will touch migrations (or as a health check). v2 north-star = a GitHub Action running the same query+diff at push time. Created `023`; closed its own first gap (021) end-to-end Session 46.

**Established June 24, 2026 (Session 46). Invariant #212 added - count now 212.**

---

### **213. Preflight every RLS/structural migration by dumping BOTH policies AND check constraints — a `single_row` singleton guard blocks per-church conversion**

The pre-migration audit must list `pg_policies` AND `pg_constraint WHERE contype='c'` for the target table — not policies alone. A "global config" table (one row pinned to `id=1`) commonly carries a singleton CHECK named `single_row` that hard-forces one row; it is INVISIBLE to a policy-only preflight and the per-church seed INSERT then fails `23514 violates check constraint "single_row"` (S47: `system_settings`). The `ALTER TABLE … DROP CONSTRAINT IF EXISTS <guard>` belongs IN the migration's structural section (the committed version-of-record must carry it for faithful replay on a fresh DB). Companion trap on the same table class: a `DEFAULT 1` (non-sequence) PK collides on the 2nd church's insert → convert `id` to a sequence-backed default in the same migration.

**Established June 25, 2026 (Session 47). Invariant #213 added - count now 213.**

---

### **214. Visibility gates tied to async auth MUST be symmetric (show-if-allowed / hide-if-not) — a hide-only gate permanently hides on a slow auth resolve**

A gate written `if(!LeaderScope.isPastor()) sec.style.display='none'` is HIDE-ONLY: it never re-shows. When the auth identity resolves AFTER the gate's run window, the element stays hidden forever (there is no "else show"). This is acute in the unified-shell iframe, where the leader session arrives via postMessage AFTER the gate's `0/500/1500ms` timers — so `isPastor()` is briefly false, the gate hides, and the actual pastor never sees it (S47: four pastor-only MD Settings sub-sections — Ministries/Diagnostic/Heads-Up/Greetings — vanished; data was fine). Fix pattern: make every such gate symmetric (`el.style.display = allowed ? '' : 'none'` on every run) AND re-assert load + visibility when the panel is navigated to (auth reliably settled by then) — wired via the panel's nav side-effect (`_navTo('settings', initSettingsPanel)`, PR #29). Symptom signature: sections present in DOM but `getComputedStyle().display === 'none'`, revealed by clearing inline display.

**Established June 25, 2026 (Session 47). Invariant #214 added - count now 214.**

---

### **215. Every CC branch MUST be cut from current `origin/main`; back-check the diff against `origin/main`, never the branch's self-reported stat**

A CC clone on a STALE base produces a branch that, against current `main`, silently REVERTS already-merged work — while CC truthfully reports a clean small diff against its own stale base. S47: the first render-fix branch was cut pre-#28 and, vs current `main`, re-added the deleted `system_settings.html`, deleted migrations `030`/`031`, and restored the old `.eq('id',1)` reads + `.update().eq('id',1)` writes — yet CC reported "+22/−2". Caught ONLY by `git diff --name-only origin/main` + content diff during back-check. RULES: (1) CC hard-syncs first (`git fetch origin && git checkout main && git reset --hard origin/main`) before cutting any branch; (2) the human back-check diffs against `origin/main` (clone the branch, `git fetch --depth 1 origin main`, `git diff FETCH_HEAD HEAD`), never the branch's self-stat; (3) recovery prompts carry base-sanity guards that assert post-merge markers exist (e.g. `test -f migrations/030_*.sql`, `system_settings.html` absent) before patching. This is the same orphan-history class as the machine-switch `sync` (Inv #203).

**Established June 25, 2026 (Session 47). Invariant #215 added - count now 215.**

---

### **216. A per-church table whose UI writes CLIENT-SIDE needs TENANT write policies, not `service_role`-only**

`write = USING(auth.role()='service_role')` silently BLOCKS every client-side save: a leader/member JWT carries role `authenticated`, never `service_role`, so the `.update()`/`.insert()` is rejected with no error surfaced — the save just no-ops. S47: `svi_weight_profiles` had `read=public USING(true)` (cross-church leak) + `write=service_role-only` while MD's `saveSviWeights()` writes client-side via the leader JWT → saves had been silently failing. Fix (`032`): replace the pair with the standard 4 `TO authenticated` tenant policies on `auth_church_id()` (service_role still BYPASSES RLS for the compute EF, so it keeps working — no explicit service_role policy needed). DISTINGUISH from a deliberately GLOBAL catalog (`svi_metrics`: no `church_id`; `public`-read + `service_role`-write is correct and stays). UI-gating (pastor-only editor) is NOT a substitute for the DB policy, but a church-scoped tenant policy + UI gating matches the other 21 swept tables (no RLS-level role-gating unless the data demands it).

**Established June 25, 2026 (Session 47). Invariant #216 added - count now 216.**

---

### **217. Session number is claimed at first BUILD — the read-in/reconcile phase is UNNUMBERED ("Pre-flight (post-S## reconcile)")**

The read-in/reconcile phase at session start is backward-looking — it confirms the PRIOR session's close — so claiming the session number there makes an opening session look like a DUPLICATE re-run of the session that just closed (S47-vs-S48 confusion was the trigger). RULE (Pastor's choice, Option 1): the read-in/reconcile phase is UNNUMBERED — label it **"Pre-flight (post-S## reconcile)"**. The session number is claimed ONLY when Pastor points Claude at the first real BUILD, and the session title becomes **"S## — <the build that defines it>"** (build-named, set by what actually shipped, stamped into HANDOFF at `m.md` close). The number tracks builds that LAND, never read-ins.

**Established June 26, 2026 (Session 48). Invariant #217 added - count now 217.**

---

### **218. A per-church table must enforce uniqueness as a COMPOSITE `UNIQUE(church_id, <key>)` — never a bare single-column unique on the per-church key**

A single-column `UNIQUE(<key>)` (or a partial unique index on `<key>` alone) bakes in a SINGLE-TENANT assumption: it asserts "only one `<key>` in the WHOLE database" when the real rule is "only one `<key>` PER CHURCH." The defect is INVISIBLE while only one church has rows, then explodes the instant a 2nd church reuses a key. S48: seeding Agape's `svi_weight_profiles` hit `23505 duplicate key … svi_weight_profiles_profile_key_key` on `level_0` — that constraint was a global `UNIQUE(profile_key)`; a full constraint+index dump surfaced a SECOND landmine, `uq_svi_profile_active_level` = `UNIQUE(applies_to_level) WHERE is_active` (also global). Fix (`034`): drop both, rebuild as `UNIQUE(church_id, profile_key)` + `UNIQUE(church_id, applies_to_level) WHERE is_active`, then seed. This is the SVI sibling of the `system_settings` `single_row` CHECK / `DEFAULT 1` PK footgun (Inv #213 family). RULE: when isolating OR creating any per-church table, dump ALL constraints AND indexes (not just policies/CHECKs) and convert every tenancy-blind unique to a composite on `church_id`.

**Established June 26, 2026 (Session 48). Invariant #218 added - count now 218.**

---

### **219. Base shared-content (`church_id IS NULL`) is authored ONLY through a service-role publish-lane EF — client JWTs can write overlays, never base**

Once RLS is enabled on a Model-3 catalog table, the `033` tenant write policies (`INSERT/UPDATE/DELETE` with `church_id = auth_church_id()`) make BASE rows unwritable by ANY church JWT — a non-null `auth_church_id()` can never equal `NULL`. So canonical/base curriculum must be authored by a **service-role Edge Function** (`catalog-publish`) that bypasses RLS and **explicitly stamps `church_id = NULL`** (the #211 sibling). The lane is BASE-ONLY: insert/upsert force `church_id = NULL`; update/delete are scoped `.is('church_id', null)` so the platform lane can NEVER touch a tenant's overlay row. Clients route base writes through `MultiplyShared.catalogWrite(table, op, {id?, payload?, onConflict?})`; per-church overlay writes (`church_id = mine`, a future capability) stay client-side. S49: 23 dashboard/admin/editor call sites swapped to the helper BEFORE `037` flipped RLS — never flip RLS on a catalog table while a client still writes its base rows directly.

**Established June 26, 2026 (Session 49). Invariant #219 added - count now 219.**

---

### **220. The platform author is a per-member flag (`members.is_platform_admin`) — NEVER a hardcoded church UUID**

"Who may publish base curriculum" must be decoupled from "which church am I." `catalog-publish` verifies the caller's HS256 JWT, then gates on **`members.is_platform_admin = true`** for the token's `sub` (service-role lookup) — that single boolean is THE gate; a tenant JWT (even a level-5 pastor, even the level-5 Agape test member) is rejected `403 not_platform_admin`. The rejected alternative — gating on Rosehill's `church_id` — would give a tenant's pastor god-mode over every church's shared catalog and bake a church UUID into the trust boundary. Seed the flag TRUE for the platform author(s) ONLY; `036` flagged exactly Gerry (`547ebda6`).

**Established June 26, 2026 (Session 49). Invariant #220 added - count now 220.**

---

### **221. Literal-string greps for table writes MISS dynamic `db.from(<var>)` refs — audit variable table names when sweeping**

A literal `grep "from('usbong_quizzes')"` found only `.select()` and suggested usbong was read-only — but `lesson_quiz_editor.html` is a unified editor that writes BOTH `usbong_quizzes` and `btli_quizzes` through a dynamic `db.from(TABLE_MAP[STATE.table].table)` the literal grep never saw. Missing it would have left usbong off the publish-lane allowlist and broken the editor's usbong save the instant `037` flipped RLS. RULE: when sweeping for writes to a SET of tables, also grep `from(<identifier>)` / `from(tbl)` and trace the variable's domain; a literal-only sweep is incomplete.

**Established June 26, 2026 (Session 49). Invariant #221 added - count now 221.**

---

---

### **222. User-visible church identity is painted at RUNTIME from `churches.name` — the static fallback carries NO church name (anti-leak)**

Church identity in chrome, signatures, PDF/CSV titles, and in-app banners is NEVER hardcoded — it is painted at runtime from the JWT-scoped `churches.name` (own-row-only via `035`). Two mechanisms: `paintChurchName()` for the MD header (boot + the #169 embed re-sync), and the standalone **`multiply_brand.js`** UMD module (sibling of `multiply_close.js`, `?v=1`, NOT in shared.js) which auto-paints any `[data-church-tmpl]` element by substituting `{church}`/`{CHURCH}`/`{slug}`/`{SLUG}` and exposes `MultiplyBrand.churchName()`/`church()` promises. **Anti-leak rule:** the static/pre-resolve fallback carries NO church name — only the neutral "MULTIPLY" — and upgrades to the real name ONLY after the JWT resolves, so a pre-auth or wrong-tenant render can never flash another church's name. Pages already holding a JWT'd client (ESM/diagnostic pages) resolve the name from that client directly rather than loading brand.js. Canonical/base curriculum chrome stays "MULTIPLY" (the publisher, Model 3), NOT the tenant name.

**Established June 26, 2026 (Session 50). Invariant #222 added - count now 222.**

---

### **223. `schema.json` at repo root is the AUTHORITATIVE schema, auto-refreshed by a GitHub Action — read it, never guess columns**

A structure-only `schema.json` lives at repo root as the single source of truth for table/column shape. It is regenerated by `.github/workflows/refresh-schema.yml`, which fires on push to `migrations/**` or `supabase/functions/**`, a weekly safety-net cron, and manual `workflow_dispatch`. The runner curls the `schema-dump` EF (a GitHub runner CAN reach `supabase.co`; Claude/CC bash CANNOT — that asymmetry is the whole reason the Action exists), validates `table_count ≥ 1`, **strips the volatile `generated_at` + per-table `est_rows`** so a re-dump with no schema change is byte-identical (clean diffs = a real migration changelog, no cron commit-spam, and no row counts pushed — honors #124), then commits only on real change. RULE: at session start Claude pulls `schema.json` alongside the 5 canonical docs and reads column shape from it; the old "guess `churches.name` then verify" detective work is retired. The committed `schema.json` (structure-only) is distinct from the gitignored local `multiply-schema.json` (#124).

**Established June 26, 2026 (Session 50). Invariant #223 added - count now 223.**

---

### **224. A dashboard-editor Edge Function defaults to Verify-JWT ON — secret-gated server-to-server callers get 401 at the gateway before the function code runs**

Supabase's API gateway enforces JWT verification IN FRONT OF the function. A function created through the dashboard "Deploy via editor" path has **Verify JWT = ON** by default, so a server-to-server caller that authenticates with its OWN scheme (e.g. a custom `x-schema-secret` header, no Supabase auth token) is rejected `401` at the gateway — the function's own secret check never even runs. The dashboard's built-in "Test" panel MASKS this because it auto-attaches a login token (the "Role" dropdown). S50: the `schema-dump` Action 401'd for exactly this reason while the dashboard test of the SAME function returned 200. FIX: for any secret-gated S2S function, deploy `--no-verify-jwt` (CLI) OR toggle **Verify JWT off** in the function's Settings tab (no redeploy needed). DISTINGUISH 401 (gateway/JWT gate) from the function's OWN auth failures — the EFs here return 403 for a secret/role mismatch inside the code (e.g. `not_platform_admin`, #220).

**Established June 26, 2026 (Session 50). Invariant #224 added - count now 224.**

---

### **225. A workflow that commits+pushes to `main` must run from the CURRENT tip — "Re-run jobs" replays the pinned stale SHA and gets push-rejected; use "Run workflow"**

GitHub's **"Re-run jobs"** replays a run against the EXACT commit it was originally triggered on (pinned SHA). For a workflow that builds an artifact and `git push`es it to `main`, that means pushing from a stale base — and if `main` has advanced since (e.g. mid-session merges), the push is rejected `! [rejected] main -> main (fetch first)` even though the commit itself succeeded. S50: the schema Action's commit step logged a clean commit (`1 file changed, create mode 100644 schema.json`), then died only at push for this reason. RULE: to land a commit-to-main workflow on the latest base, trigger a FRESH run via **"Run workflow"** (workflow_dispatch), which checks out current `main` — never "Re-run jobs". Optional hardening: `git pull --rebase` immediately before `git push` so the job can never be out-of-date regardless of trigger.

**Established June 26, 2026 (Session 50). Invariant #225 added - count now 225.**

---

### **226. Never key JS on positional `:nth-child()` for structural page sections — give sections stable ids; removing a sibling silently re-targets the selector**

A selector like `#panel-settings .ss:nth-child(3)` is POSITIONAL — it points at "whatever the 3rd `.ss` happens to be." Delete or reorder an earlier sibling and the selector silently re-targets a DIFFERENT section, with no error thrown. S50 (#36 regression, fixed PR #40): removing the obsolete Access-Control Settings section shifted `.ss:nth-child(3)` off the ministries manager and onto Pastor Tools — the ministries code then clobbered Pastor Tools, and the real ministries section rendered a raw unsubstituted `${ROSEHILL_MINISTRIES_PLACEHOLDER}`. FIX: give every structural section a stable `id` (`id="ministriesSettingsSection"`) and key JS on the id, not its position. RULE: positional child selectors are fine for purely visual/leaf styling, never for sections that JS reads or writes.

**Established June 26, 2026 (Session 50). Invariant #226 added - count now 226.**

---

### **227. MLT "+ Add Member" is pastor-gated via `churches.settings.mlt_add_member` (MD writes through the `church-settings-flag` EF; MLT enforces, reading level LIVE not from the frozen embed session snapshot)**

Member-adding from the LC Leader tool duplicates fast when ungoverned, so it is gated by a per-church flag the Pastor toggles in MD. **Storage:** a key in the existing `churches.settings` jsonb (`mlt_add_member`, default off) - no new column. **Write path:** `churches` has only a SELECT policy (no UPDATE), so the toggle CANNOT be a client write - it routes through a new **`church-settings-flag` Edge Function** (deployed Verify-JWT-OFF, internal HS256 verify with `JWT_SECRET`, mirroring `catalog-publish`) that derives the church from the JWT claim, looks the caller up server-side and requires `pipeline_level >= 5` (Pastor) of THAT church, then merges ONLY the one key so `name`/`branding`/other settings survive. The MD control sits in the Settings panel, gated by `isPastor` (`LeaderScope.isPastor()` = `leaderLevel >= PASTOR_LEVEL`, =5). **Enforcement (MLT):** reads the flag via its own `churches_tenant_select` SELECT; shows "+ Add Member" always for L2+ but ENABLED only when on (a clearly visible "+ Add Member · off" slate pill when off), with a matching fail-closed guard in `openAddMember`; the existing `_checkAddMemberDup` soft dup-check still backs save. This is an **honest-leader governance gate** (client-enforced), not a hard server lock - adequate for accidental-duplicate prevention; route member-insert through an EF if hard enforcement is ever needed. **Embed gotcha (extends #169):** MLT's `currentLeader` is a one-time `const` snapshot of `window.LEADER` built at parse time, so in the shell it freezes at level-0 until the postMessage session lands - the gate/guard therefore read level via `_liveLeaderLevel()` (`getValidSession()`-first) and re-paint on the embed re-sync, never trusting the frozen snapshot. Same session also: MLT background repainted near-black -> slate-blue (4-token swap, light text + gold/green accents preserved) with the disabled add-member state made visible; the mobile member-modal footer made horizontally scrollable (<=640px) so Delete is reachable on phones; the MMT Journey nav icon swapped ladder -> footprints (the ladder emoji rendered as a tofu box on many devices). Shipped via PRs #48 (centralized devo-reflection helper), #50/#51 (MD toggle + embed-init re-sync), #52/#53 (MLT enforce + live-level), #54 (slate theme + visible off-state), #55 (footer scroll), plus the journey-icon direct-to-main push; #47/#49 were no-ops (HANDOFF docs / EF-source already on main).

**Established June 29, 2026 (Session 51). Invariant #227 added - count now 227.**

---

### **228. Home action cards collapse into the shared `lc-detail` CTA + bottom-sheet pattern; the sheet dismisses only via Close/✕, never a backdrop tap**

The MMT Home surface standardizes every member action card onto one pattern: a collapsed `prayer-cta-card` button (icon · title · meta · ›, optional `pcc-badge`) that opens a `lc-detail-backdrop`/`lc-detail` bottom-sheet (✕ `pr-top-close`, `<h2>`, `lc-detail-meta`, body, `lc-detail-close`). `open*Sheet()` adds class `show`; `close*Sheet(e){ if(e) return; … }` removes it — a tap on the dimmed backdrop must NEVER dismiss (only the Close/✕ buttons), mirroring `closePrayerSheet`. S52 collapsed both Thanksgiving (PR #57) and "I'm here" self-attest (PR #59) onto this, joining Prayer — so all three read identically and new cards have a template to follow. RULE: a new Home action = a CTA button + a `lc-detail` sheet, backdrop-tap-inert.

**Established June 29, 2026 (Session 52). Invariant #228 added - count now 228.**

---

### **229. Relocating inline content into a sheet: PRESERVE the ids its render functions target, and DE-SCOPE descendant CSS that assumed the old parent**

When collapsing an inline card into a sheet, two things silently break unless guarded. (1) **Ids:** keep the exact element ids the existing render/logic functions read/write (`#attestCard`/`#attestPickerRow`/`#attestStatusRow` for `renderAttestCard`; `#gratitudeInput`/`#gratitudeShare`/`#gratitudeStatus` for `_persistGratitude`) so the logic stays untouched — relocate the nodes, don't rename them. (2) **CSS:** descendant-scoped rules (`.gratitude-card .gc-input{…}`) stop matching once the element leaves `.gratitude-card` for `.lc-detail` — styles vanish with no error (PR #57's share-row + "Saved ✓"-flash regression). FIX: de-scope to class-only (`.gc-input{…}`) and drop the now-unused wrapper rule. RULE: a "move it into the sheet" change is an id-preservation + CSS-scope audit, not just a markup cut-paste.

**Established June 29, 2026 (Session 52). Invariant #229 added - count now 229.**

---

### **230. The celebration feed excludes the LC leader from `eligible`/`lcIds`; to surface a leader's OWN shared content, query the leader-inclusive id set + resolve via `leaderRow`**

`loadCelebrationFeed` builds `eligible` (and `lcIds`) with `m.id !== lcLeaderId` — the LC leader is deliberately omitted from the peer-win set and modeled separately (the always-on streak subject `leaderRow`/`streakIds`). So any win-type keyed only on `lcIds` will NEVER show the leader's own row — and since a no-discipler pastor IS `lcLeaderId`, their own shared item never appears to them OR their flock. S52's gratitude win (PR #58) hit exactly this: a shared "To God be the glory!" never surfaced. FIX: query the leader-inclusive id set (`streakIds = [...lcIds, leaderRow.id]`) and resolve the subject via `eligibleById.get(id) || (leaderRow && id===leaderRow.id ? leaderRow : null)`. The render already maps `w.memberId === MEMBER.memberId → "You"/"Ikaw"`, so a leader's own shared win auto-reads "You". RULE: for any shared-content win a leader can also post, scope to leader-inclusive ids, not bare `lcIds`.

**Established June 29, 2026 (Session 52). Invariant #230 added - count now 230.**

---

### **231. Celebration win labels use non-conjugating PAST tense ("gave thanks"), so both "You …" and "<Name> …" render grammatically**

The feed renders `${name} ${label_en}` where name is "You" (self) or a member's name. A present-tense verb conjugates wrong for one of them — "You **gives** thanks" (S52 bug). Every other win label already dodges this with past tense ("completed", "discovered", "found"), invariant across persons. FIX: gratitude label `gives thanks → gave thanks` (TL `nagpapasalamat → nagpasalamat`). RULE: win/feed labels that get a subject prefix must use a verb form correct for both "You" and a third-person name — past tense is the safe default.

**Established June 29, 2026 (Session 52). Invariant #231 added - count now 231.**

---

### **232. Attendance writes resolve the recorder from the LIVE session (`_liveLeaderIdName`), never the frozen `currentLeader` snapshot (extends #169)**

MLT's `currentLeader` is a one-time `const` shim of `window.LEADER` built at parse time; in the unified shell it is EMPTY until the postMessage session lands. Three attendance write paths (main roster save, Sunday quick-mark, ministry batch) stamped `logged_by`/`logged_by_id` from `currentLeader?.name/id` → so every batch/quick-mark save recorded **'Unknown' / null** (the recorder identity was never captured). FIX (PR #60): a live resolver `_liveLeaderIdName()` (getValidSession → window.LEADER → shim, mirroring `_liveLeaderLevel`) feeds all three sites. RULE: anything that must carry the acting leader's identity at write time reads it live, never from the frozen parse-time shim.

**Established June 29, 2026 (Session 52). Invariant #232 added - count now 232.**

---

### **233. Attendance recorder traceability + backfill: LC-scoped → subject's `discipler_id` (LCL); GP/ministry batches are NOT LCL-traceable; removed-member subjects attribute by attendance `id`; never stamp a guessed recorder**

When backfilling historical 'Unknown' recorders (rows logged before #232), the recorder is recoverable for **LC-scoped** rows (LC Meeting / devotional / Sunday) = the subject's `discipler_id` (the LCL logging their own flock) — but **General-Purpose / ministry batches are NOT** (logged by one ministry leader across many LCGs, so the subject's LCL is the wrong answer; attribute to the confirmed logger). A **removed-member** subject has no live `members` row to trace — attribute by the attendance row's own `id`. CRITICAL: never stamp a guessed recorder — an honest 'Unknown' beats a wrong name, because the confirm / dispute / pastor-resolve audit keys on `logged_by_id`. S52 closed 288 rows (279 → LCLs `039`, 8 GP → pastor `040`, 1 orphan → Amy `041`), 0 Unknown left. RULE: always preview the trace (read-only) and split LC-scoped vs ministry before any backfill UPDATE.

**Established June 29, 2026 (Session 52). Invariant #233 added - count now 233.**

---

### **234. The GP-batch ATTENDANCE picker is owner-scoped (`owner_id === live leader`); programs stay visible to all, batches don't — Settings/My Batches keeps the full list**

Architecture: the pastor makes **programs** (`cohort_programs`); LCLs make **batches** (`cohorts`, `owner_id` = the LCL) under them. `_gpLoadBatches` was listing every batch visible to the leader (own + others' `visible_to_others` + pastor's), so the General-Purpose-Batch attendance dropdown buried the leader's own. FIX (PR #62): add `c.owner_id === L.leaderId` to the attendance-picker filter — own batches only when reporting. Program visibility is a SEPARATE loader (`cohort_programs` in 🎓 My Batches) and is untouched, so LCLs still see all programs to create batches under; the full visible-batch list also stays in My Batches / Settings. RULE: scope batches to their owner in the attendance flow; keep programs church-visible for creation. (BTLI/Usbong lesson-batch pickers are separate, left as-is.)

**Established June 29, 2026 (Session 52). Invariant #234 added - count now 234.**

---

### **235. Multi-church pastor onboarding: seed church `ON CONFLICT (slug) DO NOTHING` + an L5 pastor with `member_pin_hash = NULL` (first-login `set_pin`); supply `church_id` explicitly; PREFER re-stamp over delete**

Pre-seeding a tenant cohort (S52: 7 churches + L5 pastors, `042`): each church is `INSERT INTO churches (name,slug,timezone) … ON CONFLICT (slug) DO NOTHING`; each pastor is a `members` row with `pipeline_level=5`, `is_external_user=false`, `is_platform_admin=false` (only the platform author is), no discipler, and **`member_pin_hash = NULL`** — they claim their own PIN privately via the bcrypt `set_pin` first-login action (`auth-login`), so no password is handed out or guessed. Supply `church_id` EXPLICITLY: the `set_church_id_from_jwt` BEFORE-INSERT trigger fills it only when NULL, so a SQL-editor insert (no JWT) won't get clobbered. When a pastor already exists as a guest of another church, **re-stamp their `church_id` (move them)** rather than delete-and-recreate: a member with child rows (`announcement_acks`, `attendance`, …) CANNOT be deleted (FK has no cascade — the delete is rejected), and re-stamp preserves history. RULE: onboard by additive seed + targeted re-stamp; never hard-delete a member who has history.

**Established June 29, 2026 (Session 52). Invariant #235 added - count now 235.**

---

### **236. BYO-AI Meeting Prep: devotional → fixed prompt → any AI → fenced parse + fallback → LCL review → publish**

The weekly LC study is prepared by a **Bring-Your-Own-AI** loop, zero server-side AI cost/keys: the LCL picks a devotional (today's or any `entry_date`), MLT's `mpBuildPrompt` assembles a FIXED prompt from the devotional fields, the LCL runs it in any AI they trust, pastes the reply, MLT parses it into a **Facilitator's Guide** + **Participant's Guide**, the LCL reviews/edits, then publishes. The LCL is the **doctrinal guardrail** — nothing reaches the group until a human approves it (AI drafts, it does not teach). Guides live in `lc_meeting_guides` keyed `UNIQUE(church_id, lcl_id, meeting_date)`, last-wins via explicit upsert (select-then-update-or-insert). `lcl_id` = `_liveLeaderIdName().id` (embed-safe, #169), never the frozen `currentLeader`.

**Established June 30, 2026 (Session 53). Invariant #236 added - count now 236.**

---

### **237. Parsing arbitrary AI output: enforce a fenced contract in the PROMPT, split on it, fall back to manual**

When ingesting free-form AI text, do not guess structure — make the GENERATED PROMPT require a strict machine-parseable contract and split on it: `===FACILITATOR===` / `===PARTICIPANT===` / `===END===`, extract by `indexOf` between fences. If the fences are absent or garbled, **fall back gracefully** to a manual two-box split (show the raw paste, let the human place each part) rather than failing or losing the work. Control the output format via the prompt so the parse is deterministic; never trust an LLM to be consistent without a contract.

**Established June 30, 2026 (Session 53). Invariant #237 added - count now 237.**

---

### **238. The one-hour LC meeting (7 timed segments) is the discipleship spine; generated guides bind to it**

The meeting model: **Welcome+Win (8) → Connect to God (7) → Look Back (3) → The Word (20) → "I Will" (10) → Pray (9) → Send-off (3)** = 60 min. It synthesizes the strongest parts of named systems — the **Four Ws** (cell church, Neighbour/Comiskey), **sermon-based/alignment** groups (North Point, Life.Church), the **3/3 Group / Discovery Bible Study** Look-Back/Up/Forward (Watson, T4T), **Up·In·Out** (Breen, 3DM), and **HOST** low-bar leadership (Saddleback) — with four deliberate strengthenings: the Word stays a question-led conversation (not a sermon), the "I Will" is captured + revisitable (not evaporated), leader prep is AI-light, and every meeting opens with a celebrated win. The facilitator guide prompt is shaped to this timed flow; EOLO/empty-chair is woven through every meeting, not a separate event.

**Established June 30, 2026 (Session 53). Invariant #238 added - count now 238.**

---

### **239. Cross-member RLS reads use SECURITY DEFINER discipler helpers (`auth_discipler_id()` / `discipler_of(uuid)`)**

For "a member reads their LCL's published X" and "an LCL reads their disciples' shared Y" policies, use SECURITY DEFINER SQL helpers that bypass `members` RLS rather than inline subqueries (which are subject to the queried table's own RLS and can silently return nothing): **`auth_discipler_id()`** = the caller's own discipler (`SELECT discipler_id FROM members WHERE id = auth_member_id()`); **`discipler_of(p_member)`** = a given member's discipler. Both key off `auth_member_id()` so they expose nothing the caller shouldn't see. Pattern: `lc_meeting_guides` member-read = `status='published' AND lcl_id = auth_discipler_id()`; `lc_meeting_responses` LCL-read = `shared_with_leader AND discipler_of(member_id) = auth_member_id()`.

**Established June 30, 2026 (Session 53). Invariant #239 added - count now 239.**

---

### **240. Member self-data is private-by-default with opt-in share-to-leader (shepherd-not-spy, RLS-enforced)**

Interactive member responses (`lc_meeting_responses`: `i_will` / `reach_person` / `notes`) default `shared_with_leader = false`. The LCL sees a member's answer ONLY if the member ticks "share with my leader." This extends the AI-as-pastoral-tool principle: visibility serves care, never surveillance. RLS enforces it structurally — member-own write (`member_id = auth_member_id()`), LCL reads only shared rows of their own disciples (#239). The UI toggle is off unless chosen; follow-up should feel like care.

**Established June 30, 2026 (Session 53). Invariant #240 added - count now 240.**

---

### **241. CC prompts are a single self-contained Python patch (one delimiter, anchors as triple-quoted literals)**

Multi-heredoc-fragment `.sh` assembly is fragile: a fragment that does not end in a newline glues the closing delimiter onto its last content line (e.g. `}OPENOLD`), so bash never matches the delimiter and the first heredoc swallows the rest of the script — nothing runs (caught by CC, Session 53). RULE: generate every CC prompt as ONE `python3 - <<'PYEOF'` block, with old/new blocks as triple-quoted Python literals inside; before shipping, verify the embedded content has no `'''`/`"""` and no line equal to the delimiter, then RUN the embedded patch against a copy and `diff` it against the fragment-built expected. One delimiter you control directly = no gluing, no swallowing.

**Established June 30, 2026 (Session 53). Invariant #241 added - count now 241.**

---

### **242. Commit each migration to the repo immediately after running it (proactively close the #212 lag)**

The dashboard-run-but-not-yet-committed gap (#212) makes `schema.json` lag, so CC repeatedly (and correctly, from the repo's view) reports "table X doesn't exist" for a table that is in fact live — a recurring false alarm (043/044, 047, 048). RULE: the moment a migration goes green in Supabase, commit it to `migrations/` as its own tiny version-of-record PR BEFORE building the dependent feature, so `refresh-schema.yml` refreshes `schema.json` and CC reads ground truth. Claude itself stays current by curling authoritative `origin/main`; only the repo record + CC's view need the commit.

**Established June 30, 2026 (Session 53). Invariant #242 added - count now 242.**

---

### **243. Date-keyed features use LOCAL date components, never `toISOString()` UTC**

`new Date().toISOString().slice(0,10)` returns the UTC date — off-by-one for Manila (UTC+8) in the morning, so a record saved "today" can be keyed to a different calendar day than the revisit default, and a date-keyed lookup silently misses (surfaced by the Meeting Prep revisit bug). RULE: derive date keys from local components — `getFullYear()` / `getMonth()+1` / `getDate()`. Companion robustness for date-keyed resumes: default to the most-recent existing record's date (not blindly "today"), clear stale UI state when the date changes, and surface load errors with a toast instead of a silent `catch{}`.

**Established June 30, 2026 (Session 53). Invariant #243 added - count now 243.**

---

### **244. Ministry Recommender = each church's own `ministries` ⋈ a shared archetype library, overlay-wins-by-key**

The recommender reads each church's OWN `ministries` rows joined to a shared `ministry_archetypes` library (Model 3: `church_id = NULL` = canonical base curriculum, non-NULL = per-church overlay; scoring in a jsonb `{adv, risk, profile}`). Each ministry maps to an archetype via the `ministries.archetype_key` column; scoring resolves **overlay-wins-by-key**. Pastors map their ministries to archetypes in MD Settings (async dropdown, base + own overlay); unmapped ministries are excluded with a gentle note. There is NO hardcoded ministry array — that dead per-church-profile pattern was removed (PR #65). 17 base archetypes seeded + a Rosehill `interior_design` overlay; partial unique indexes split base/overlay (honors #218).

**Established June 30, 2026 (Session 53). Invariant #244 added - count now 244.**

---

### **245. Render-verify inline SVG diagrams (rasterize → eyeball) before shipping; prefix diagram classes to avoid leaks**

Extends #82 (PPTX render-before-ship) to inline SVG: hand-authored diagrams must be rasterized (cairosvg → PNG contact sheet) and visually inspected for overflow, overlap, and broken arrows before shipping manual/visual content — code inspection alone misses layout defects. Two SVG gotchas: (a) a per-SVG `<defs><style>` is NOT scoped — it leaks document-wide, so a short SVG class can collide with an HTML class of the same name (an HTML `class="m"` inherited an SVG `.m { font-size:9.5px }`); prefix diagram classes (e.g. `mp-*`) or keep them SVG-only and never reuse the name in HTML; (b) give each `<marker>` a unique id across all SVGs on the page.

**Established June 30, 2026 (Session 53). Invariant #245 added - count now 245.**

---

### **246. The `auth-login`/`token-login` Edge Functions are now in the repo — read the EF source before building on an action**

The `supabase/functions/auth-login/index.ts` + `token-login` sources are committed; the old "dashboard-only, not in repo" exception (a carve-out in the file-pull rule) is RETIRED — pull and read them like any other file. RULE: before designing a feature on an EF action, READ the EF source to confirm the exact contract (which body fields, which guards, which error codes). A verbal/one-word confirmation of an action's behavior is NOT a substitute for reading the code — assuming `set_pin` overwrote an existing PIN (it does not) produced a dead-on-arrival PIN-change build; CC's pre-apply contract read caught it before it shipped.

**Established July 1, 2026 (Session 54). Invariant #246 added - count now 246.**

---

### **247. `set_pin` is first-login-only; `change_pin` is the member-initiated PIN-change path**

auth-login `set_pin` returns `pin_already_set` (409) when a hash already exists — it is a first-login claim only. Member-initiated PIN changes use the dedicated **`change_pin`** action: `{member_id, current_pin, new_pin}` → bcrypt-verify the current PIN **server-side** → overwrite, **no session minted** (the caller is already logged in). Verifying the current PIN inside the EF keeps it the auth boundary — a direct call still needs the current PIN, so an unattended logged-in session can't silently re-key the account. NEVER write `member_pin_hash` from the client; the hash never leaves the server.

**Established July 1, 2026 (Session 54). Invariant #247 added - count now 247.**

---

### **248. An EF change is a separate human-gated dashboard deploy — land it with/before the frontend that needs it**

Merging a PR ships the frontend (Pages auto-deploys), but a NEW Edge-Function action does not exist until the Pastor redeploys the function in the Supabase dashboard (with **Verify-JWT OFF** for anon-callable EFs like `auth-login`). Until then the feature **fails safe**: an unknown `action` falls through to the default `login` branch → `missing_credentials` (400) → the frontend's generic error, no misbehaviour. RULE: deploy the EF FIRST, then merge the frontend. Verify the deploy with a console contract-probe (`200 {ok:true}` = live; `400 {error:'missing_credentials'}` = not deployed yet).

**Established July 1, 2026 (Session 54). Invariant #248 added - count now 248.**

---

### **249. Tenant-only RLS without a level check is a self-escalation hole — gate privileged ops by level, not just church (`members` hotfix `050`)**

`members` had church-scoped INSERT/UPDATE/DELETE policies with NO level gate, so any authenticated member could DELETE every member in their church AND self-promote via UPDATE (`pipeline_level=5` / `is_platform_admin=true`) then re-login as pastor. FIX (`050`): DELETE now requires `auth_church_id()` match AND `auth_level() >= 5`; a BEFORE UPDATE trigger (`members_guard_privilege_cols`) blocks non-pastor changes to the privilege columns `is_platform_admin` / `pipeline_level` / `is_facilitator` / `facilitator_role`, bypassing only for service-role (`auth_church_id()` IS NULL) or L5. Validated 3/3 in-browser as a live L2 (normal update OK; self-promote BLOCKED 400; delete BLOCKED 0 rows). RULE: audit every per-church table's policies for a missing LEVEL gate, not just church scoping. Console RLS tests run in the dashboard frame via `MultiplyShared.getDB()`; the SQL editor bypasses RLS as owner and is useless for this. Still open (Phase 2): members INSERT is unguarded; the broad members UPDATE also lets a member edit ANOTHER member's row.

**Established July 1, 2026 (Session 54). Invariant #249 added - count now 249.**

---

### **250. SVI is SEVEN dimensions — Prayer is LIVE (the "W4 silent-SVI-prayer held" note is retired)**

Migration `009` is RUN and the `compute-svi-weekly` EF is computing the `prayer` category — confirmed live: 4 prayer metrics active, 14 weight-profiles carry the prayer weights, **458 recent snapshots scoring prayer**. The SVI blends SEVEN dimensions: **Gather · Word · Prayer · Fellowship · Mission · Growth · Service**. Prayer is weighted modestly (1 each across `prayer_saved_30d` / `prayer_opens_14d` / `prayer_answered_90d` / `prayer_intercessions_30d`), tunable live in MD → SVI Weights. The Pastor's Manual now documents seven (heading/intro/list/diagram/glossary). Any prior "W4 held / silent" note in HANDOFF is STALE — Prayer ships.

**Established July 1, 2026 (Session 54). Invariant #250 added - count now 250.**

---

### **251. `m.md` now drops the two full canonical files for manual upload (supersedes the net-additions/CC-splice flow)**

From Session 54 on, `m.md` = Claude pulls the current `HANDOFF.md` + `MULTIPLY_INVARIANTS.md` from `main`, applies the net additions IN PLACE (new invariant blocks + new COMPLETED section + updated Jumpstart + Last-updated prepend), and drops BOTH complete files for the Pastor to upload to GitHub manually — no CC splice prompt. The Session-52 "net additions only, CC splices" procedure is retired.

**Established July 1, 2026 (Session 54). Invariant #251 added - count now 251.**

---

### **252. MULTIPLY migrations live in the `migrations/` folder, never repo root — commit the byte-exact run SQL there for ledger parity**

Existing migrations (`049_onboard_cef.sql`, `051_onboard_ggcf.sql`, …) all live under `migrations/`. S55 twice authored 052/053 CC prompts that placed the file at repo ROOT (off-convention), and once let a stale index-based `migrations/052_devotionals_unique_per_church.sql` reach `main` alongside the correct root-level constraint version, leaving TWO conflicting 052s — different object types (`CREATE UNIQUE INDEX` vs `ADD CONSTRAINT`) and different ledger keys (`'052'` vs `'052_devotionals_composite_unique'`). RULE: every migration goes to `migrations/`; after running the SQL in Supabase, commit the BYTE-EXACT text that was run to `migrations/NNN_*.sql` (repo/DB parity, #212/#242) — the committed file must mirror the LIVE schema (constraint-vs-index matters), so a fresh `migrations/`-folder replay reproduces the live DB. When two variants exist, keep the one that matches what actually ran and delete the other.

**Established July 2, 2026 (Session 55). Invariant #252 added - count now 252.**

---

### **253. Model-3 shared-catalog uniques need PARTIAL indexes, not a plain composite — the base row (`church_id IS NULL`) must dedupe separately from per-church overrides**

The #218 composite `UNIQUE(church_id, <key>)` fix is correct for PURE-tenant tables (every row owned by one church). It is WRONG for Model-3 shared-catalog tables (`cohort_programs`, `btli_quizzes`, `usbong_quizzes`, `library_chapters`, …) where `church_id IS NULL` = the canonical shared base and `NOT NULL` = a per-church overlay: a plain composite lets unlimited base rows share a key (Postgres treats NULLs as distinct in a unique index), corrupting the catalog. Correct pattern = TWO partial unique indexes: `UNIQUE(<key>) WHERE church_id IS NULL` (one canonical base per key) + `UNIQUE(church_id, <key>) WHERE church_id IS NOT NULL` (one override per church per key). Judge per table first — some are already scoped by a tenant-owned FK (e.g. `library_chapters(resource_id, …)` rides `resource_id`) and aren't leaks at all. This is the remaining, still-parked slice of the #218 audit.

**Established July 2, 2026 (Session 55). Invariant #253 added - count now 253.**

---

### **254. `auth_member_id()` resolves in BOTH session systems — the leader JWT carries `sub: m.id`, so per-member RLS works on leader-facing (MD/MLT) tables**

`auth-login` (and `token-login`) mint the JWT with `sub: m.id` for leader logins AND member logins alike (confirmed by reading the EF source, #246). Since `auth_member_id()` reads the JWT `sub`, it resolves to the current person's member id in the leader session too — not only in MMT. So a leader-facing table can safely gate PER-MEMBER: e.g. `lcg_leader_checkins` lets an LC Leader (L2, leader session in MLT) SELECT/UPDATE only their OWN row via `leader_member_id = auth_member_id()`, while L3+ (`auth_level() >= 3`) read/insert all-in-church. `lc_meeting_guides`/`lc_meeting_responses` already relied on this. Don't assume `auth_member_id()` is member-session-only.

**Established July 2, 2026 (Session 55). Invariant #254 added - count now 254.**

---

### **255. Leftover `_backup_*`/snapshot tables must be RLS-locked or dropped — never left API-reachable**

Supabase Security Advisor flags any RLS-disabled table in the `public` schema as "publicly accessible" — anyone with the project's anon key + URL can read/edit/delete it. S55 got that alert for `_backup_devo_attendance_cleanup_20260620` (a cleanup snapshot holding real member data, RLS off). FIX (`055`): `ALTER TABLE … ENABLE ROW LEVEL SECURITY;` with NO policies → zero rows to anon/authenticated, still readable via the SQL editor / service role, and the advisor clears. Better long-term: DROP the snapshot once its cleanup is confirmed. RULE: backup/diagnostic snapshots never live reachable in `public` — lock (RLS-on-no-policy) or drop them. (Sibling of the SECURITY DEFINER view audit, #206–#208.)

**Established July 2, 2026 (Session 55). Invariant #255 added - count now 255.**

---

### **256. Keep the literal space in the template when interpolating an OPTIONAL attribute after a tag name (`<div ${var}`) — and RENDER generated HTML, because `node --check` can't see it**

S55's clickable ack-chip shipped `return \`<div${click}style="…">…\`` where `click` was `''` for the awaiting state → the browser received `<divstyle="…">`, an unknown WELDED tag that corrupted the DOM and broke the entire LCG-Pulse heartbeat grid (buttons escaped their cards, rows went full-width). `node --check` passed and the ANSWERED path (non-empty `click`) rendered fine, so it slipped past #105. RULE: put the separator space in the TEMPLATE (`<div ${click}…`), never inside the optional variable, so an empty value can't fuse the tag shut. Broader rule: `node --check` validates the JavaScript, NOT the HTML string it builds — always VISUALLY RENDER generated markup before declaring done (the HTML sibling of PPTX render-before-ship #82 and #105).

**Established July 2, 2026 (Session 55). Invariant #256 added - count now 256.**

---

### **257. One member-facing message = one editable source: the Message Greetings template → composed on send → stored → shown, never a parallel hardcode**

The LCG check-in message is driven by the pastor-editable **LC Check-in** template (`system_settings.meta.lcg_checkin_greeting`, MD Settings → Message Greetings). S55 first stored a SEPARATE hardcoded body on the reply screen → it didn't match the Pulse modal the pastor saw. FIX: store the composed template output (`fullText`, placeholders filled) into `lcg_leader_checkins.message` (`056`) at send-time, and render THAT on the MLT reply screen (falling back to a clear meeting-context default). Now Settings template → modal preview → sent → reply screen are identical AND pastor-editable from one tab; editing the template moves them all. RULE: never hardcode a parallel copy of a message that has a Message-Greetings template — capture the composed text at the moment of send for historical fidelity.

**Established July 2, 2026 (Session 55). Invariant #257 added - count now 257.**

---

### **258. The shepherd's check-in loop is SELF-REPORT, not surveillance — the app surfaces, it never nags or renders a verdict**

The LCG check-in loop (`054`/`056`; Pulse send #93, MLT reply #95, ack chip #98/#99, grid fix #100): a coach/pastor (L3+) sends an IN-APP check-in from the LCG Pulse to a silent LCG's leader (persist-on-send, dedup against an existing `awaiting` row); the leader SELF-REPORTS one of 7 reasons + an optional free-text note on a gentle MLT banner→screen (`status → answered`); the pastor reads the reason chip back on the Pulse card and taps it for the note. The leader chooses what to disclose — nothing is auto-flagged, pushed, or scored (extends AI-as-conversation-starter-not-verdict #6, and shepherd-not-spy). The first reason ("nag-meet, nakalimutan i-log") deliberately rescues the faithful-but-forgetful BEFORE any "correction." RLS: L3+ create/read-all-in-church; leader reads/answers own (via #254).

**Established July 2, 2026 (Session 55). Invariant #258 added - count now 258.**

---

### **259. L0 is a real pre-pipeline level — foundations live at L0, formal formation (BTLI) begins at L1**

The MULTIPLY leadership pipeline now opens with **L0 "New Believer · Follow Jesus"** (two internal stages, Guest → New Believer, conversion as the gate): New Believers Orientation, the Usbong devotional, the salvation + readiness assessments, and the Baptism / Completed-NBO milestones all belong at L0; BTLI (formal formation) starts at L1. Books: **Basic Christianity** (Stott) for seekers, **Real-Life Discipleship** (Putman) for new believers; **The Purpose Driven Life is retired.** L1 compensations: an "Entering Formation" pipeline orientation, a Spiritual Disciplines Inventory, formation milestones (Completed BTLI 101, 90-day devotional streak, discipling my EOLO one). The standalone `leadership_pipeline.html` diagram (static cards + click-modals + filter tabs) lives in the repo and is wired into MD Settings → Pastor Tools (📊 Leadership Pipeline, visible to all churches).

**Established July 2, 2026 (Session 55). Invariant #259 added - count now 259.**

---

### **260. Leadership Pathway v1 — per-level rungs a member climbs, church-isolated, member-read + LCL-marked**

The pipeline is now traversable: `057` adds **`pathway_rungs`** (catalog, Model 3 — `church_id` NULL = MULTIPLY base + per-church overlay; **partial-unique** `base(level,rung_key) WHERE church_id IS NULL` + `overlay(church_id,level,rung_key) WHERE NOT NULL` — the #253 fix, since a plain composite lets NULLs duplicate) and **`pathway_progress`** (per-member marks; `UNIQUE(church_id,member_id,level,rung_key)`). Rungs carry `category` (book·training·lesson·ministry·coaching·assessment·character·competency·discipline) + `completion_source` (`manual`/`auto`) + `auto_source_key` — v1 is manual-marked but the schema is **auto-ready** (v2 self-checks BTLI/assessments/devo-streak from the same activity spine). RLS: member reads own; **LCL marks own disciples** via `discipler_of(member_id)=auth_member_id()` (uses `auth_member_id()` in leader sessions #254); L3+ coach reads church-wide; L5 pastor writes any — **members never self-mark in v1**. Surfaces: **MMT Journey** `renderPathway` (read-only ladder + clickable L0–L5 metro to preview any level); **MLT** `renderMltPathway`/`_mltPwToggle` (LCL taps to mark). Frontend stamps `church_id` on insert (#211). PRs #101/#104/#105/#106; 37 base rungs seeded L0–L5.

**Established July 4, 2026 (Session 57). Invariant #260 added - count now 260.**

---

### **261. SVI is a CARE lens, never an advancement gate — vitality × progression, pastoral priority follows vitality**

The pathway measures **progression** ("am I moving up?" — competence/milestones, the visible ladder, Eph 4 maturing); the **SVI** measures **vitality** ("am I alive/abiding now?" — the weekly pulse, John 15). They are **orthogonal axes and must never be conflated.** **NEVER gate pathway advancement on the SVI** — the moment a care instrument becomes a promotion hurdle it invites gaming, pride, legalism (the Luke 6:40 trap). SVI feeds the **care loop** (dip → soft surfacing → the S55 check-in) and is **advisory context** for a pastor's promotion discernment (character-before-competence; FATLESS affirmed by a human), never a computed gate. The pastoral tool is the **Flock Map** quadrant (vitality × progression); colour follows **vitality** because a soul's aliveness matters more than its rung — the dangerous quadrant is "advancing but dry." AI stays conversation-starter, not verdict (#6). Auto rungs (devo-streak, service, EOLO) and SVI dimensions read the **same activity spine** — siblings, not duplicates.

**Established July 4, 2026 (Session 57). Invariant #261 added - count now 261.**

---

### **262. Per-church pipeline = shared LEVEL frame (the 3M "right Model") + per-church RUNG contents (the "right Method")**

A church may run MULTIPLY's template **or build its own pipeline** — but the split is deliberate. The **LEVEL FRAME (L0–L5, Mac Lake) is universal, shared, un-forkable** — the 3M's *right Model*, the common language keeping SVI (per-level weights), promotions, cross-church reports, and `leadership_pipeline.html` coherent. The **RUNG CONTENTS (books/lessons/competencies per level) are fully per-church** — the *right Method*, overlay-driven. Overlay algebra needs **zero new schema** (uses `pathway_rungs.published`): **keep** (no overlay → inherit base), **override** (same `rung_key`, overlay wins — cf. `ministry_archetypes` #244), **hide** (same `rung_key`, `published=false`), **add** (new `rung_key`), **reorder** (`sort_order`). Pastor-gated (`auth_level()>=5`, own-church overlay only). The tie to member progress is **free**: `pathway_progress` keys on `(level, rung_key)`, agnostic to base/overlay. RULE: churches own their **contents**, never the **frame** — changing the level count/meaning would shatter SVI, reports, the diagram. (Authoring surface parked.)

**Established July 4, 2026 (Session 57). Invariant #262 added - count now 262.**

---

### **263. BTLI slide decks follow `BTLI_SLIDE_SPEC.md` — questions on their own slides, time on every slide, the whole guide in the notes**

The standing standard for every BTLI lesson deck (repo root `BTLI_SLIDE_SPEC.md`, generic — not just L1): **(1)** every participant-guide question gets its **OWN dark-navy slide** (one per question), placed right after the content that sets it up, headed `<emoji> MOVEMENT · TANONG` with a gold **`Participant Guide Question`** tag; **(2)** a gold **timer badge on EVERY slide** top-right (`slide-min` + cumulative), per-slide minutes split from the **facilitator guide's movement pacing**, summing to movement totals + the lesson core time; **(3)** **generous, self-facilitating notes on EVERY slide** (~200–700 chars: exact question + pastoral notes + stories + cautions + tips, so the lecturer teaches from Presenter View without the guide); **(4)** **"Participant Guide" — never "Booklet"** (sweep slide text + notes). Tokens navy `0F1C34`/gold `D4A84A`/cream `FEFCF8`; generic branding (#26). Build via `python-pptx` (question slides from scratch, reorder sldIdLst, renumber, badges, notes), QA render→pdftoppm. Worked example: L2 "Bible Meditation" = 23 slides, 55-min core (PUKAW 8·TUKLAS 15·TALAKAY 12·GAWIN 12·DALHIN 8).

**Established July 4, 2026 (Session 57). Invariant #263 added - count now 263.**

---

### **264. Ship well-supported emoji (footprints not the newer ladder) — and pure `.md` docs upload direct to `main`, no CC/PR**

Two hygiene rules. **(a) Emoji rendering:** newer glyphs render as **tofu boxes** on many devices — the ladder (U+1FA9C, 2020) showed as a box in Chrome/Windows, so the pathway's identity icon is the older, universally-supported **footprints** (matching the MMT Journey tab), applied consistently across **MMT** ("My pathway" title) and **MLT** (Pathway section header); prefer long-standing emoji on any shipped surface and render-verify (#105/#245/#256 extend to emoji). **(b) Doc-only upload lane:** a pure documentation file (`.md`, no code) may be **uploaded straight to `main` via the GitHub web UI** (Add file → Upload files → Commit directly to main) — no CC branch/PR; keep CC + PR for code, migrations, or any deployed file. `BTLI_SLIDE_SPEC.md` landed this way (verified on `main`).

**Established July 4, 2026 (Session 57). Invariant #264 added - count now 264.**

---

### **265. pathway_rungs is ONE catalog for both the rich diagram and the trackable spine — `trackable` splits them, `meta` carries chip detail**

Full-Unify (migration `060`, Path A). `pathway_rungs` is the single source for BOTH the rich reference diagram (211 hand-authored chips migrated from the static `leadership_pipeline.html`) AND the member-progress spine (the 37 curated rungs from `057`). A `trackable boolean` (default true) separates them: the data-driven poster renders **all published** base+overlay rungs; the MMT/MLT progress ladder filters `trackable=true`. `meta jsonb` (migration `059`) holds structured chip detail — `{type,title,body,footer,author,source_type,duration,key_takeaways,scripture_refs,six_sources,builds,ai_researched_at}` — rendered in the chip modal, and is where the ✨ AI-research paste-back lands. Base seed keeps `church_id NULL`; the 11 spine rungs with a matching write-up got `meta` attached, the other 167 static chips seeded as `trackable=false` reference rungs (204 base total).

**Established July 6, 2026 (Session 58). Invariant #265 added - count now 265.**

---

### **266. pathway_rungs overlay writes send NO church_id — the base-safe stamp trigger fills it from the JWT**

The L5 pipeline editor's overlay INSERTs omit `church_id` entirely. Migration `061` attaches `trg_set_church_id` (`set_church_id_from_jwt()`, from `014`) to `pathway_rungs` — it is **base-safe** because it stamps ONLY when `NEW.church_id IS NULL`, setting it to `auth_church_id()` which is NULL for owner/migration inserts (no JWT) → base rows stay NULL, JWT-borne client overlays get stamped. RLS then enforces `church_id = auth_church_id() AND auth_level() >= 5`. The client never handles `church_id` and `multiply_shared.js` is untouched. `pathway_rungs` post-dates `014`'s bulk-attach, which is why it lacked the trigger until now.

**Established July 6, 2026 (Session 58). Invariant #266 added - count now 266.**

---

### **267. The overlay partial-unique CANNOT be PostgREST-upserted — customize/tombstone use manual insert-or-update**

`pathway_rungs_overlay_uk` is a PARTIAL unique index `(church_id, level, rung_key) WHERE church_id IS NOT NULL`. PostgREST `onConflict` cannot target a partial index (it emits `ON CONFLICT (cols)` with no `WHERE`, so PG rejects it) — so `upsert({onConflict:'church_id,level,rung_key'})` FAILS. Overlay writes that must be idempotent-per-key (customizeBase, tombstoneBase) are therefore **manual insert-or-update**: edit mode loads the church's own raw overlays into `OVERLAY_BY_KEY` (incl. `published:false`), then UPDATE by id if an overlay exists for that `level|rung_key` else INSERT. This also makes customize↔hide toggle a single overlay row. (Caught by CC's back-check of the S58 Step-3 spec — a real miss in the first draft.)

**Established July 6, 2026 (Session 58). Invariant #267 added - count now 267.**

---

### **268. `noopener` on `window.open` strips sessionStorage → the leader session is lost → redirect loop**

`window.open(url,'_blank','noopener')` creates a fresh top-level browsing context with no opener, and per spec sessionStorage is copied to a new context ONLY when it has an opener. The leader session lives in `sessionStorage` (`multiply_leader_session`), so a `noopener` tab starts session-less → `gateOrRedirect` fires → bounce to `leader_login` → the button re-opens another session-less tab → loop. Session-gated standalone pages launched from MD must use `window.open(url,'_blank')` WITHOUT `noopener` (the working `lcg_pulse_report.html` launch, line 798). Fixed the Leadership Pipeline launcher this way (`multiply_dashboard.html:959`, direct-to-main). Surfaced only when Pastor Timothy first opened the pipeline from MD.

**Established July 6, 2026 (Session 58). Invariant #268 added - count now 268.**

---

### **269. `churches` is SELECT-only under RLS — per-church config goes through an EF or a dedicated per-church table, never `churches.update`**

`churches` has a single RLS policy (`churches_tenant_select: id = auth_church_id()`) — NO INSERT/UPDATE/DELETE. A client `db.from('churches').update(...)` is rejected (default deny). Per-church configuration must route through a service-role EF (`church-settings-flag`, which merges one settings key server-side after a `pipeline_level>=5` check) OR a **dedicated per-church table** that reuses the proven RLS + church-stamp-trigger pattern (e.g. `pathway_section_order`, `063`) so the client writes directly with `church_id` auto-stamped. The dedicated-table route is preferred when it avoids an EF deploy.

**Established July 6, 2026 (Session 58). Invariant #269 added - count now 269.**

---

### **270. Per-church pipeline order = `pathway_section_order.order_map`, keyed by rung_key so it survives customization; full base+overlay interleave without severing base**

Migration `063`: `pathway_section_order` (one row/church, `order_map jsonb = {"level|category":[rung_key,...]}`, RLS L5-own-church + stamp trigger). The render orders each `(level,category)` section by the map — using `rung_key` (the stable identity shared by a base rung and its overlay, so a customized base keeps its slot); rungs absent from the map fall back to `sort_order` and append after the ordered ones. Reorder (↑/↓) is an insert-or-update of `order_map` (client sends no `church_id`). This gives full interleave of base + overlay chips WITHOUT auto-customizing base rungs — so a reordered base chip still receives future MULTIPLY content updates.

**Established July 6, 2026 (Session 58). Invariant #270 added - count now 270.**

---

### **271. LCG Pulse buckets are an exhaustive, exclusive partition — and a solo LCG is never 'weak'**

The Pulse report (`lcg_pulse_report.html`, PR #107) partitions every LCG into exactly one of: **Champions** (met every week) · **🌱 Building Rhythm** (met this week but not every week) · **Needs a Heartbeat** (missed this week). Proven exhaustive + mutually exclusive (an LCG that meets this week yet not every week used to fall through the Champions/Heartbeat gap and get no card — e.g. Rosana Cordero). A solo LCG (`flockSize <= 1`) is NEVER flagged weak/amber (1 present = full turnout; the weak rule is `met && attendance<=1 && flockSize>1`). All four sections sort alphabetically by LCL name.

**Established July 6, 2026 (Session 58). Invariant #271 added - count now 271.**

---

### **272. A migration run-but-not-committed is invisible to CC's repo greps — commit every migration immediately; trust the ledger + schema.json over a grep**

Reinforces #242 with a concrete failure mode. An applied-but-uncommitted migration (`059`/`061` sat in the live DB but not in `migrations/`) is invisible to CC when it greps the repo — CC's S58 Step-3 back-check flagged a 'missing church-stamp trigger' that was in fact already live (`061`). Commit each migration to `migrations/` the moment it runs. On any tenancy/trigger/RLS review, the authoritative sources are the live `schema_migrations` ledger and `schema.json`, NOT a repo grep of `migrations/` (which can lag).

**Established July 6, 2026 (Session 58). Invariant #272 added - count now 272.**

---

### **273. Step 4 shipped — the AI-research chip modal (BYO-AI `meta` enrichment) is LIVE**

`leadership_pipeline.html` (S59) turns any empty pipeline chip into a BYO-AI research flow, L5-edit-mode only: `buildResearchPrompt(chip)` composes a JSON-only prompt with the full frame baked in (top-tier disciplemaking expert, Mac Lake L0–L5, Grenny's Six Sources, Luke 6:40, Gal 5:22-23); the pastor copies it → any AI → pastes the reply → `parseResearchJSON()` fail-soft parses (strips fences, never crashes) → editable preview → `researchToMeta()` stamps `ai_source` + `ai_researched_at` → `saveResearch()` enriches `pathway_rungs.meta`. Empty chips show a ✨ marker; bilingual empty-state. This is the headline feature — it was already on `main` but undocumented (found live during S60); the "is Step 4 done?" confusion traces to that doc gap.

**Established Session 59 (reconciled from live code July 7, 2026). Invariant #273 added - count now 273.**

---

### **274. The session lives in `sessionStorage` (8h TTL), is handed to embedded tools VERBATIM, and cannot be refreshed — only re-logged-in**

`auth-login` mints an 8-hour session (`SESSION_HOURS = 8`); JWT + session `expiresAt` are both now+8h. `getValidSession()` / member equivalent read `sessionStorage` (NOT localStorage) and return null past `expiresAt`. There is **no refresh/renew path** — an expired session can only be re-authenticated via login. The shell (`index.html`) is the embed **parent**: it answers a tool's `MULTIPLY_EMBED_READY` postMessage with `MULTIPLY_SESSION` carrying its current `sessionStorage` session **verbatim** (same `expiresAt`). Consequences: (a) a brand-new top-level tab (or `<a target="_blank">`) starts with EMPTY `sessionStorage` → any auth-gated page opened that way loops to login; (b) re-handshaking on wake cannot rescue an expired session (the shell's copy is equally expired); (c) idle < 8h resumes cleanly, idle > 8h correctly logs out.

**Established July 7, 2026 (Session 60). Invariant #274 added - count now 274.**

---

### **275. Show a standalone report INSIDE a tool via `_openLessonViewerModal(url,label,hideNewTab)` + an `?embed=1` Samsung-safe report mode — hide "↗ New tab" for authenticated reports**

`window.open(url,'_blank')` pops an Android custom-tab (browser chrome). To render a report inside MLT/MMT, call the existing generic overlay `_openLessonViewerModal('report.html?embed=1', label, /*hideNewTab*/ true)` — a `position:fixed` container with a flex-pinned (Samsung-safe) header, a ‹ close, and a sandboxed same-origin iframe. The report's `?embed=1` mode must (a) neutralize its own `position:fixed` elements (gate blackout → `position:absolute`) or Samsung Internet blanks the iframe, and (b) hide its own toolbar/back button. **Pass `hideNewTab=true` for auth-gated reports** — a New-tab link opens a fresh top-level tab with empty `sessionStorage` (see #274) → login loop; keep it only for public lesson viewers. Auth works in-overlay because a same-origin iframe shares the parent's `sessionStorage`. Pilot: LC Attendance Compliance (`lc_attendance_report.html`, PRs #119/#120); rolls out to the other 3 reports as a one-line swap + tiny embed pass each.

**Established July 7, 2026 (Session 60). Invariant #275 added - count now 275.**

---

### **276. The service worker's `networkFirst` MUST race the fetch against a short timeout — a bare `await fetch` hangs for minutes on a post-idle stale socket (the "white screen on wake" bug)**

`multiply-sw.js` routes all documents + `.js` (incl. `multiply_shared.js`) through `networkFirst`. A bare `await fetch(req)` with cache-fallback only inside the `catch` means that on wake — radio asleep, socket stale — the fetch hangs the full OS/TCP timeout (2-4 min) before the catch serves cache, leaving the tool white the whole time. Fix (PR #121): race the fetch against `SW_NET_TIMEOUT_MS = 3500`, serve the precached copy the moment it stalls, keep the real fetch running to revalidate in the background (stale-while-revalidate), and be **cache-miss safe** (on a timeout with no cache, do NOT abandon — await the real fetch). Fresh-deploy-wins stays intact. On-device confirmed: 10-min idle now resumes in seconds. `cacheFirst` left alone (serves cache first, never hangs). SW changes are the riskiest kind — PR + phone smoke-test, and the new SW only takes over after a full close+reopen (×2).

**Established July 7, 2026 (Session 60). Invariant #276 added - count now 276.**

---

### **277. MMT poll discipline — fetch once then render-from-cache, and visibility-gate every interval**

`renderHome` was re-fetching announcements on EVERY render, and the 2-min poll ran even backgrounded. Fixed (PR #118): fetch once on first Home render (`_annsLoadedOnce` guard) then `renderPinnedAnnouncements()` (cache render, no DB) thereafter; the interval is visibility-gated (`document.visibilityState === 'visible'`) with a refetch on return. General rule for all MMT/MLT polls: never fetch on every render, and no DB polling while the PWA is backgrounded (saves battery/data on Manila mobile). Mirrors the MLT `_pollWhenVisible` pattern.

**Established July 7, 2026 (Session 60). Invariant #277 added - count now 277.**

---

### **278. `raw.githubusercontent.com` can serve a STALE cached copy for minutes after a push — a session-open doc read may lag reality**

At the S60 open, a `raw.githubusercontent` fetch of the docs returned a pre-S58 copy (count 264) even though S58 (count 272) was already on `main` — the raw CDN lagged the push, producing a false "docs frozen at S57" belief that persisted much of the session. When a session-open count/tail looks behind expectation, don't trust the first raw fetch — re-fetch after a beat, or cross-check via the codeload tarball (`codeload.github.com/.../tar.gz/refs/heads/main`) or the GitHub API. Applies the #97 "verify against live data" rule to the doc-read step itself.

**Established July 7, 2026 (Session 60). Invariant #278 added - count now 278.**

---

### **279. In-app report embed — full rollout (MLT + MD), two marker conventions**

Every report now opens in-app via `_openLessonViewerModal('X.html?embed=1', label, /*hideNewTab*/true)` (S61 #123 MLT: LC Member/Member Attendance/Quiz Scores; S63 #125 all 5 MD launchers + lcg_pulse). Each report carries an embed pass: newer metrics use `#embedFix` (a head `<script>` stamping `html.embed` + a `<style id="embedFix">` neutralizing its `position:fixed` → `absolute`); the pilot `lc_attendance` uses the OLDER method (`classList.add('embed')` + `html.embed` CSS, no `#embedFix` id) — both are embed-ready, so an `embedFix` grep of 0 is not "unpatched." `member_attendance`'s post-scroll `.detail-overlay` also gets `window.scrollTo(0,0)` on open in embed so the absolute overlay lands in view. The `.crm` care-detail modal is capped at `88vh` with an internally-scrolling body + pinned header so the ✕ is reachable on phone (S62 #124).

**Established July 7, 2026 (Sessions 61–63). Invariant #279 added - count now 279.**

---

### **280. SVI count_rows is fully table-driven + self-prefetching; adding a metric = one seed row, no EF code**

Metrics live in the GLOBAL `svi_metrics` catalog (no `church_id`). The count_rows handler issues its OWN per-metric bulk query from `compute_config {table, member_col, date_col, lookback_days, filter}`, DATE-CAPPED at weekStart (`.gte(lower)` AND `.lt(dateCol, weekStart+1)`) — so forward-dated rows (e.g. the pre-populated preaching schedule) are correctly excluded until they occur. Weight comes from `svi_weight_profiles.weights` JSONB keyed by `metric_key`; `weight <= 0 → skip`, so a newly-seeded metric defaults OFF for every church (opt-in) and disturbs no one until weighted. count_rows returns a NUMBER (never null) → 0 rows scores 0 unless `null_if_zero`.

**Established July 7, 2026 (Session 64). Invariant #280 added - count now 280.**

---

### **281. `null_if_zero` and the sufficiency `metricsTotal--` are a matched pair; two distinct softenings**

`compute_config.null_if_zero:true` → count_rows returns null when count===0 → the metric is EXCLUDED (not zeroed) for non-participants. But the loop pre-increments `metricsTotal` before compute, so a null n/a MUST `metricsTotal--` (and record `note:"n/a"`) — else the extra null denominators push regular members below the `metricsWithData >= ceil(metricsTotal/2)` sufficiency threshold and wrongly flip them to "insufficient." TWO softenings, never conflated: `null` = INAPPLICABLE (opt-in non-participant → excluded from the denominator) vs `floor` (#010, applicable-but-event-didn't-happen → floored to 4). Universal metrics (Prayer Meeting, Celebration) OMIT null_if_zero (0 = legit low signal); opt-in metrics (BTLI, batch, quiz, pathway, meeting-prep, guide-prep, preaching) SET it.

**Established July 7, 2026 (Session 64). Invariant #281 added - count now 281.**

---

### **282. compute-svi-weekly was NOT church-scoped — a latent cross-church weight collision (fixed S64)**

Members + weight profiles were loaded with NO church filter, and profiles were keyed by `applies_to_level` ONLY → different churches' profiles collided (last-loaded wins, non-deterministic). Benign only while every church's profile is a Rosehill copy; the instant a church's weights diverge, tuning may silently not apply. Fix: `church_id` added to both selects; `profilesByChurchLevel` keyed `${church_id}|${level}` + `defaultByChurch` per-church; per-member resolution by `member.church_id` with a no-profile guard (a church without a profile → honest "insufficient", not a crash or a collided score); snapshot stamped `church_id` (#211). This is the prerequisite for per-church weight tuning to take effect at all.

**Established July 7, 2026 (Session 64). Invariant #282 added - count now 282.**

---

### **283. SVI weights are PER-LEVEL — editing "default" does not touch a member at a specific level**

A metric appears in the care-detail modal AND counts toward a member's score only if it has weight>0 for that member's OWN `pipeline_level`. Symptom (S65): new metrics weighted at "default" moved lower-level dormants but NOT the L5 pastor; the tell was `Σweight = 129` (unchanged, the pre-Wave-5a total) in his modal. Fix: weight each metric at every level where it should count (student metrics L1–L2; leader metrics L4–L5). This is a feature — the pipeline is designed to measure different things at different levels.

**Established July 7, 2026 (Session 65). Invariant #283 added - count now 283.**

---

### **284. Care-detail metric explanations are data-driven via `compute_config.unit`**

The care-detail modal's `rawMeaning` count_rows branch reads `cfg.unit` for descriptive text ("6 Prayer Meetings attended"), falling back to the generic "N records in the period" when absent (`065` seeded a `unit` on all 10 Wave-5a metrics). n/a metrics (`note==='n/a'`) render "not applicable to this member — not counted" (vs "no data recorded"). Future metrics self-describe by carrying a `unit` — no modal edit needed. BOTH `multiply_dashboard.html` and `lc_leader_tool.html` have parallel `openCareDetail` explanation logic (rawMeaning/tierStr/explainMetric) — keep them in lockstep (S65 #128 edited both).

**Established July 7, 2026 (Session 65). Invariant #284 added - count now 284.**

---

### **285. compute-svi-weekly is DASHBOARD-deployed (source `index.ts` at repo ROOT) — merging the PR ≠ live**

The SVI compute EF's source lives at repo root as `index.ts` (NOT under `supabase/functions/`). Merging an EF PR updates the repo version-of-record but does NOT deploy it — the Pastor must paste the merged `index.ts` into the Supabase dashboard EF editor and redeploy (Verify-JWT OFF, #224). A CLI `supabase functions deploy compute-svi-weekly` won't find the root source. Reinforces #248: an EF change is a separate human-gated deploy that must land with/before the frontend expects it.

**Established July 7, 2026 (Session 64). Invariant #285 added - count now 285.**

---

### **286. GitHub web-editor commits arrive CRLF → breaks pure-LF; and `schema_migrations` columns**

A migration Gerry commits via the GitHub web editor lands with CRLF, violating the repo's pure-LF rule (`.gitattributes` #151) → git shows a perpetual phantom "modified" (both `064` and `065` did this, fixed by LF-normalization PRs #127 and #129 — pure CRLF→LF, SQL byte-identical). Prevention: route migration commits through CC (LF-clean) or git CLI, never the web editor. Related (reinforces #223 — read columns from schema.json, not memory): `schema_migrations` columns are `version, filename, applied_at, note` (NOT `name, description`); stamp via `insert into public.schema_migrations (version, filename, applied_at, note) values (...) on conflict (version) do nothing`.

**Established July 7, 2026 (Sessions 64–65). Invariant #286 added - count now 286.**

---

### **287. Manual split by audience: pastor-manual = SVI computation/methods; leader-manual = shepherding playbook**

The SVI documentation lives in two homes by audience. `md_manual.html` (MD, Pastor) Chapter 2 carries the full computation/methods — the 10 count-first signals, the score-rules→weighted-blend→n/a→Insufficient→trend build, per-church/per-level weights, and care-detail units. `mlt_manual.html` (MLT, Leader) Chapter 5 carries the shepherding playbook — four states, trend-reading, detail-drilldown care moves, low-pressure Taglish check-ins, celebrate-not-compare, and the Luke 6:40/Gal 5:22-23 anchor. Keep future SVI doc edits in the right home: methods → pastor, how-to-shepherd → leader.

**Established July 8, 2026 (Session 66). Invariant #287 added - count now 287.**

---

### **288. Embed-mode sweep: MD/Settings pages open in-app via `_openLessonViewerModal(url?embed=1, label, true)`, never `window.open(_blank)`**

Every MD/Settings launcher (viewers AND editors) opens inside the shell's iframe modal, matching the reports. Each embedded page adds the embed-class script (`?embed=1` → `document.documentElement.classList.add('embed')`) plus `html.embed` CSS flipping full-screen `position:fixed` overlays (gate blackout, modals, toasts) → `absolute` (Samsung Internet blanks fixed elements inside iframes). The page's own gate PASSES via the shared same-tab sessionStorage (a same-origin iframe shares the top document's sessionStorage — no gate-defer needed). Editors (Tier-2) additionally hide their own back-chrome under `html.embed`, and make their back handler embed-aware via a `_exitTool()` helper: in embed, exit = `window.parent._closeLessonViewer()`, NEVER `window.close()`→`location.href='multiply_dashboard.html'` (which navigates the IFRAME to the dashboard = dashboard-inside-modal).

**Established July 8, 2026 (Session 66). Invariant #288 added - count now 288.**

---

### **289. `lcg_leader_checkins` is dual-kind (checkin | celebration); loaders MUST route by `kind`**

Migration 066 added `kind text NOT NULL DEFAULT 'checkin'`. Check-ins are two-way (`status` awaiting→answered; reason/note/reply). Celebrations are one-way pastor kudos: `kind='celebration'`, `status='sent'`, `message` = the Settings-worded greeting, `responded_at` = the leader's "Amen" (the publish gate; no reply lifecycle). Any loader over this table MUST route celebrations to their own map so they never render as check-in chips/banners — Pulse `loadCheckins` splits `_checkinByLeader` vs `_celebrationByLeader`; MLT `_loadMyCheckin` filters `status='awaiting'` so `status='sent'` celebrations are excluded.

**Established July 8, 2026 (Session 66). Invariant #289 added - count now 289.**

---

### **290. Verify CHECK-constraint DDL, not just schema.json column defaults, before inserting a new column value**

schema.json shows a column's type/nullable/default but NOT its CHECK constraint. Inserting `status:'sent'` would have failed EVERY celebration insert against `lcg_checkins_status_chk CHECK (status IN ('awaiting','answered','resolved'))` (created in 054) — a bug invisible to an anchor patcher and to schema.json (caught by CC). Before writing a new enum-ish value, read the constraint DDL from the creating migration and extend the CHECK as a SUPERSET (drop-and-recreate keeping ALL existing allowed values, so no existing row is rejected). Migration 066 extended it to `('awaiting','answered','resolved','sent')`.

**Established July 8, 2026 (Session 66). Invariant #290 added - count now 290.**

---

### **291. LC celebrations feed = a computed multi-source group-badge assembler; auto-wins are pull/compute badges, never materialized rows**

`loadCelebrationFeed` assembles two tiers: `celebrationWins` (individual, capped) + `celebrationGroupBadges` (pinned, LCG-wide, `{icon,label_en,label_tl}`). New auto-surfaced wins are COMPUTED at render from their source tables — never fan-out inserts. Pastor celebration = a group badge read from `lcg_leader_checkins`, surfaced ONLY once the leader Amens it (`responded_at IS NOT NULL`), via an additive member-read RLS policy gated on `auth_discipler_id()` (migration 067) — the SECURITY-DEFINER "my LC leader" helper (047), preferred over subqueries for member-reads-about-their-leader. Perfect-attendance badges mirror the existing Sunday one: `_dates.mostRecentWeekday(d)` (0=Sun, 3=Wed) + the EXACT `event_type` string (Sunday='Sunday Service', Wednesday='Prayer Meeting'), firing only if the whole sharing LCG (≥2) was present.

**Established July 8, 2026 (Session 66). Invariant #291 added - count now 291.**

---

### **292. `lcg_leader_checkins` is now TRI-kind (checkin | celebration | encouragement); Building-Rhythm gets a one-way encouragement**

Migration 068 extended the CHECK to `kind IN ('checkin','celebration','encouragement')`. Encouragement is a one-way pastoral nudge for the LCG Pulse “🌱 Building Rhythm” tier (a leader keeping cadence but not yet thriving): `kind='encouragement'`, `status='sent'`, `message` = the editable `lcg_encouragement_greeting` (5th tab in MD Settings → Message Greetings). Distinct from both the “Needs a Heartbeat” two-way check-in and the celebration kudos flow. Extends the route-by-kind rule (#289) — `_encouragementByLeader` is its own bucket; the CHECK-DDL-superset discipline (#290) applied again.

**Established July 10, 2026 (Session 67). Invariant #292 added - count now 292.**

---

### **293. In-app embed extends to standalone manuals, not just reports**

The MLT User’s Manual (and the SVI manual pair) now open inside the shell’s iframe modal via `_openLessonViewerModal('..._manual.html?embed=1', label, true)` — the reports pattern (#288), replacing `window.open(..., '_blank', 'noopener')`. The manual carries the embed-class script + a `<style id="embedFix">` that flips its off-canvas sidebar `position:fixed`→`absolute` under `html.embed` on Samsung Internet. Any standalone HTML surface opened from a tool should use this embed pattern, never a new tab.

**Established July 10, 2026 (Session 67). Invariant #293 added - count now 293.**

---

### **294. Fetch-first: CC cuts every branch off the FRESHEST `origin/main` (stale-base guard)**

A PR (#147) was cut from a local `main` that lagged `origin` by one merge (#146) — the branch silently dropped the just-merged change; the byte-for-byte back-check caught it (branch missing a line that was on `main`), fixed by rebasing `--force-with-lease` onto `origin/main`. Standing rule: every CC task opens with `git fetch origin` + `git checkout -b <branch> origin/main`. The back-check (branch-vs-current-`main` diff = EXACTLY the intended files) is what surfaces a stale base; run it before every merge.

**Established July 10, 2026 (Session 67). Invariant #294 added - count now 294.**

---

### **295. Meeting-guide church Library = opt-in share + Share-to-my-LCG CLONE with provenance**

Migration 069 added `shared_to_library boolean` (opt-in at publish) + `source_guide_id uuid REFERENCES lc_meeting_guides(id) ON DELETE SET NULL`. Leaders browse `published AND shared_to_library` guides church-wide (RLS-scoped). “Share to my LCG” does NOT reference-in-place — it CLONES the guide into a new row the borrower owns (their `lcl_id`, date defaults to today + editable, confirm-replace on the `UNIQUE(church,lcl,date)` collision, `status='published'`), stamping `source_guide_id` for honor. Borrowing is copy-with-provenance, never shared ownership. (S67 follow-up: the Library also lists your OWN shared guides, tagged “· you”; opening your own offers Edit, not clone-to-self, via a per-guide `_mine` flag.)

**Established July 10, 2026 (Session 67). Invariant #295 added - count now 295.**

---

### **296. `auth_is_leader()` — SECURITY-DEFINER leader-read RLS helper (prefer over inline EXISTS)**

Migration 069’s `auth_is_leader()` (`RETURNS boolean … SECURITY DEFINER SET search_path=public`, mirroring `auth_discipler_id()` from 047) returns `members.is_facilitator` for the JWT caller, bypassing members-RLS to avoid policy recursion. It gates the 3rd branch of `lcmg_select` (any church leader reads the shared library). Prefer a SECURITY-DEFINER boolean helper over an inline `EXISTS(SELECT … FROM members …)` for “is the caller a leader/role” checks inside another table’s RLS — the subquery runs under the caller’s members-RLS and can silently return false.

**Established July 10, 2026 (Session 67). Invariant #296 added - count now 296.**

---

### **297. Bilingual meeting guides via `*_md_tl` + a graceful-degrade 4-section parser**

The Meeting-Prep AI prompt now requests EN + TL in four fences (`===FACILITATOR_EN===`/`PARTICIPANT_EN`/`FACILITATOR_TL`/`PARTICIPANT_TL`/`===END===`). `mpParse` splits four sections AND stays backward-compatible with the old two-section output (`===FACILITATOR===`/`===PARTICIPANT===`); with EN-only it fills EN and hides the Tagalog editor. Columns `facilitator_md_tl`/`participant_md_tl` (069) feed the modal EN/TL toggle; the `#mpTlBlock` editor reveals only when TL content exists. Caveat: bilingual doubles AI output and can truncate on free tools — the parser must degrade to EN-only cleanly, never error.

**Established July 10, 2026 (Session 67). Invariant #297 added - count now 297.**

---

### **298. Deliver CC edits as readable `str_replace` anchor blocks, not base64 — the transport-drift lesson**

An 18 KB base64 patcher drifted in chat transit: it decoded cleanly and `ast`-parsed cleanly, but its sha256 no longer matched — content changed somewhere in transport, correctly caught by CC’s `sha256sum -c` gate (nothing run or committed). Preferred delivery for edits to an existing file: readable old→new `str_replace` anchor blocks, extractable to a single copyable block via `<<<FIND>>>/<<<REPLACE>>>/<<<END>>>` markers (fence-safe; `ast`-extract the pairs from the proven patcher so they’re byte-accurate). `str_replace`’s match-exactly-once IS the drift guard; Claude still proves every edit on a throwaway `/tmp` copy (node --check + jsdom) and keeps that proven output as the byte-for-byte back-check reference. Reserve base64 only when content genuinely can’t be expressed as clean anchors.

**Established July 10, 2026 (Session 67). Invariant #298 added - count now 298.**

---

### **299. MMT guide bodies pick the language SOURCE column + re-render; the CSS `.tl-text`/`.en-text` toggle can’t touch rendered markdown**

The MMT Filipino toggle flips a `lang-tl` class on `document.body` (50+ static spans switch via `.en-text`/`.tl-text` CSS). But a meeting guide is rendered-markdown HTML in one node — CSS can’t swap its content. So a guide body must READ the right source column at render time: `_mtgGuideBodyHtml(g)` returns `mmtMd(participant_md_tl)` when `document.body.classList.contains('lang-tl')` AND it’s non-empty, else `mmtMd(participant_md)` (graceful EN fallback); `setLang()` re-renders the open guide sheet so it flips live. Any dynamic JS-built or markdown-rendered surface (guides, sermon detail, pipeline) needs an explicit language re-render on toggle — only static `.en-text`/`.tl-text` spans self-switch. Completes the bilingual meeting-guide loop (author EN+TL #297 → member reads in their language).

**Established July 10, 2026 (Session 67). Invariant #299 added - count now 299.**

---

### **300. SVI `rate_rows` compute_type — the rate engine (present ÷ opportunities), feeds the existing `rate_to_score`**

Wave 5a metrics were count-first (raw count over a window). Wave 5b-1 adds a `rate_rows` compute_type to `compute-svi-weekly`: a dedicated denominator prefetch + a `computeRateRows` handler returning a 0..1 rate, scored by the ALREADY-existing `rate_to_score` rule (the scoring half pre-existed; only the compute half — numerator ÷ denominator — was missing). Zero regression on the 6 count metrics (untouched). Migration 070 converted 4 attendance-cadence metrics in place (`prayer_meeting_att`, `gather_sunday_school`, `growth_btli_att`, `growth_batch_att`); the other 6 stay `count_rows` — they have no natural denominator (you can't count "gratitude opportunities held"). Result on live data: dormant lessened, thriving increased — faithful attendance the raw count undervalued is now measured fairly.

**Established July 10, 2026 (Session 68). Invariant #300 added - count now 300.**

---

### **301. Two SVI denominator modes: `rostered` (an absent is an absent) vs `events_held`; both n/a paths route through `null_if_zero`**

`rostered` (Sunday School / BTLI / Special Batch — opt-in tracks): denom = the member's OWN logged sessions (present+absent) for the event_type in-window → present/(present+absent). A logged **absence lowers the rate** (Pastor Gerry's explicit rule — "an absent is an absent"). Enrollment is detected FREE from attendance: **0 logged rows (neither present nor absent) = not enrolled = null (n/a)**, preserving the #281 opt-in fairness. `events_held` (Prayer Meeting — church-wide, no roster): denom = distinct church-held dates (≥1 present anywhere in that church) → present/held; **held=0 = null (n/a)**; **present=0 while held>0 = rate 0 (counted)** — a real church-wide-expectation care-flag. Both n/a cases route through the existing `null_if_zero` + `metricsTotal--` sufficiency guard, so non-participants never flip regulars to "insufficient". Mode is chosen per-metric via `compute_config.denominator_mode`.

**Established July 10, 2026 (Session 68). Invariant #301 added - count now 301.**

---

### **302. `svi_metrics.compute_type` is CHECK-gated — widen the constraint BEFORE adding a new compute_type (#290 in practice)**

`svi_metrics_compute_type_check` allow-listed only `sql_query/jsonb_extract/count_rows/boolean_check/date_recency/manual_override` — a raw UPDATE to `compute_type='rate_rows'` would have been rejected at the constraint. Migration 070 does `DROP CONSTRAINT IF EXISTS` + re-`ADD` the CHECK with `rate_rows` included FIRST, before the UPDATEs. A fresh instance of #290: always verify the originating CHECK DDL (not just schema.json column defaults) before inserting a new enum-style value — this applies to `compute_type`, not just `kind` columns.

**Established July 10, 2026 (Session 68). Invariant #302 added - count now 302.**

---

### **303. `svi_metric_overrides` — per-church metric-window overrides (mirrors the `svi_weight_profiles` tenancy pattern; a REGULAR composite unique, unlike the partial-index #267 case)**

Wave 5b-2a added `public.svi_metric_overrides` (`church_id`, `metric_key`, `compute_config_override jsonb`, `is_active`, `UNIQUE(church_id, metric_key)`) so a church can tune any count/rate metric's `lookback_days` WITHOUT touching the GLOBAL `svi_metrics` catalog (#032 — `svi_metrics` has no `church_id`). RLS = the same 4-policy `auth_church_id()` shape as `svi_weight_profiles`, plus a `set_church_id_from_jwt` BEFORE INSERT trigger so the client sends no `church_id` (#266). Because the unique is a REGULAR composite (not a partial index like `pathway_rungs` #267), PostgREST `onConflict` COULD target it — but the client still does **manual insert-or-update-by-id** (load existing overrides → UPDATE by id / INSERT / DELETE by id) for robustness and to sidestep any autostamp+onConflict interaction.

**Established July 11, 2026 (Session 69). Invariant #303 added - count now 303.**

---

### **304. SVI per-church windows: widest-fetch + per-member-bound — and ONLY `count_rows`/`rate_rows` are window-able**

The EF resolves each member's effective window as `override.lookback_days ?? metric.compute_config.lookback_days`. To keep the bulk prefetch single-pass (#170), it fetches the WIDEST window across all churches (`widestLookback`) ONCE, then bounds each member's rows by their OWN church's window (`effLookback`) inside the `count_rows` and `rate_rows` prefetch loops. IMPORTANT: only `count_rows` and `rate_rows` honor per-church windows — the `sql_query` metrics compute their windows internally and are NOT wired to overrides. The MD SVI Windows UI therefore exposes ONLY the count/rate metrics — expose only what the engine actually honors.

**Established July 11, 2026 (Session 69). Invariant #304 added - count now 304.**

---

### **305. A lite/backfill projection must SELECT every column a downstream `.get()` reads — the `allLite`/`church_id` silent-null bug, caught by a parity spot-check on REAL data**

The EF's `allLite` backfill query selected `id,pipeline_level,discipler_id` but NOT `church_id`, so `liteById.get(id)?.church_id` was always `undefined`. That silently broke the `events_held` prayer denominator (every held-date keyed to `""` → dropped → held=0 → prayer n/a for ALL members) since Wave 5b-1, and neutered per-church windows. The one-line fix (add `church_id` to the select) revived prayer as a live weight-10 dimension. LESSON: a lite/backfill projection must include EVERY column any downstream `.get()` reads — a missing column fails SILENTLY as `undefined`, not an error. Caught only because the 5b-2a dry-run was spot-checked against Gerry's REAL attendance data (548 present rows / 22 held dates → prayer showing n/a was the tell), not synthetic — parity spot-check on real data, not merely "it ran clean".

**Established July 11, 2026 (Session 69). Invariant #305 added - count now 305.**

---

### **306. MD SVI Windows UI — pastor tunes per-metric windows without SQL; input=default DELETES the override**

Wave 5b-2b added a pastor-only "🗓️ SVI Windows" MD Settings section (mirrors the SVI Weights editor). One days-input per window-able metric (`count_rows`/`rate_rows` with a `lookback_days`), pre-filled with `override ?? global`. Save logic: input ≠ global default → insert/update the override; input = global default → DELETE the override (revert to global, never store a redundant row). Client uses the JWT'd `db` → RLS + autostamp scope everything to the pastor's own church. Reuses `_sviInvokeCompute()` + `loadCareRadar()`; Save & Recompute applies immediately.

**Established July 11, 2026 (Session 69). Invariant #306 added - count now 306.**

---

### **307. Reward "more of X" WITHOUT lowering anyone: ADD an n/a-below-threshold bonus metric at weight 0 — don't grade the existing boolean (Option B) + the generic `count_fields` compute_type**

To reward multi-ministry service, grading the existing `service_ministry_role` boolean into a count (Option A) would have DROPPED role-only members (who have `ministry_role` but no named ministry) from 10→0 — a regression. Option B instead KEEPS the boolean untouched and ADDS a separate `service_multi_ministry` bonus metric: n/a (null) for 0–1 ministries, 7 for two, 10 for three — so only multi-servers rise, nobody falls. PATTERN: to reward "more of X" without penalizing "some X", add an additive bonus metric that returns null below the threshold (sufficiency-guarded #281), seeded at weight 0 (zero effect until the pastor weights it — no surprise shift). Enabled by a new GENERIC `count_fields` compute_type: counts non-empty configured member columns (`fields`), returns null below `min_count`. CHECK-widened first (#290/#302).

**Established July 11, 2026 (Session 69). Invariant #307 added - count now 307.**

---

### **308. Emitting FIND/REPLACE anchors from a file SLICE: never re-wrap a newline-terminated slice — the phantom trailing-blank-line trap**

When generating FIND/REPLACE anchor blocks by SLICING a region out of a proven file, the slice often already ends in a newline (or two). Wrapping it with an extra newline on each side then adds a phantom trailing blank line inside the FIND portion → it matches ZERO times against the real file. This bit Option B's EF EDIT 2 (FIND carried two trailing blanks; the file had one between functions). CC correctly stopped, reported loudly (#298), and re-anchored on the next stable line — the merged result was byte-identical to intent. The verify-by-reapply guard checks the OUTCOME (re-applied result == proven file) but NOT the emission artifact, because it re-applies the in-memory strings, not the wrapped prompt text. FIX: emit slices verbatim — never add wrapping newlines around a newline-terminated slice; or anchor on a stable non-blank line.

**Established July 11, 2026 (Session 69). Invariant #308 added - count now 308.**

---

### **309. Sandboxed iframes must carry `allow-modals` — a blocked `confirm()` returns falsy and the guard bails SILENTLY**

`_openLessonViewerModal` embedded every admin tool with `sandbox="allow-scripts allow-same-origin allow-forms allow-popups allow-popups-to-escape-sandbox"` — no `allow-modals`. In such a sandbox the browser **silently ignores** `confirm()`/`alert()`/`prompt()`; `confirm()` returns falsy. Every confirm-gated destructive action therefore opened with `const ok = confirm(...); if(!ok) return;` and **bailed instantly with zero feedback** — the button looked dead. This was not an Attendance-Admin bug: six MD tools were affected (attendance, preaching ×6 confirms, lesson-quiz-editor ×5, leadership-pipeline ×2, devotional, transfer). `alert()` was muzzled too, so even the ERROR path was silent. Fixed in all three embed hosts (MD #161, MLT+MMT #162). RULE: any sandboxed iframe whose target may call a modal needs `allow-modals`; the absence of the token is invisible until a destructive action quietly does nothing.

**Established July 13, 2026 (Session 70). Invariant #309 added - count now 309.**

---

### **310. Service worker: clone the Response BEFORE the async gap — `caches.open()` is async and the body is gone by the time it resolves**

`networkFirst` did `caches.open(CACHE_VERSION).then(c => c.put(req, fresh.clone()))`. `caches.open()` is **async**: by the time it resolves, `fresh` has already been handed to `respondWith()` and the browser has begun reading its body, so the deferred `clone()` throws *"Response body is already used"*. Worse, it throws **while evaluating the argument**, so the trailing `.catch()` never sees it → an UNHANDLED rejection **and a cache write that never happens**. Line 77 routes every HTML doc and every JS file through `networkFirst`, so the cache had been frozen since `CACHE_VERSION = 'multiply-shell-v1-2026-06-15'` — which very plausibly explains months of hard-refresh pain. FIX: `const copy = fresh.clone();` **synchronously**, then hand `copy` to the async chain. `cacheFirst` was NOT affected — it clones before `fresh` is ever returned. Bump `CACHE_VERSION` in the same PR so the frozen cache is evicted on activate.

**Established July 13, 2026 (Session 70). Invariant #310 added - count now 310.**

---

### **311. `typeof` does NOT protect a temporal-dead-zone binding — it throws for a `let`/`const` declared later in the same scope**

`initMltAddMemberToggle()` was called at top level ~60 lines ABOVE `const LeaderScope = ...`, and guarded itself with `typeof LeaderScope !== 'undefined' && ...`. That guard is a **false friend**: `typeof` only saves you from an *undeclared* variable. For a `let`/`const` in its TDZ it **throws a ReferenceError** rather than returning `'undefined'`. The async function therefore rejected with *"Cannot access 'LeaderScope' before initialization"*, and the Pastor's MLT add-member permission toggle silently never initialized. FIX: move the CALL below the declaration. RULE: `typeof` is not a TDZ guard; ordering is. If a defensive `typeof` sits in front of a `const` from the same module, that is a bug in waiting.

**Established July 13, 2026 (Session 70). Invariant #311 added - count now 311.**

---

### **312. `\UXXXXXXXX` is not JavaScript — the capital-U escape is a Python-ism that becomes junk TEXT**

While generating an emoji through a Python heredoc, `\\U0001F54A` was written into a JS source string. **JavaScript has no `\U` escape** (only `\uXXXX` and surrogate pairs like `\uD83D\uDD4A`, plus `\u{...}`). The backslash is simply dropped and the user sees the literal text `U0001F54A`. My proven copy therefore carried a real bug that would have rendered *"Nothing new yet. U0001F54A"* to the member; the literal `🕊` that CC shipped from the prompt was **correct**. RULE: emit emoji as literal UTF-8 characters, or as `\uXXXX`/surrogate pairs — never `\UXXXXXXXX`. Add `grep -c '\\U0001'` → 0 to the self-verify of any file carrying emoji.

**Established July 13, 2026 (Session 70). Invariant #312 added - count now 312.**

---

### **313. Diagnostic SQL run in the Supabase SQL Editor MUST carry an explicit tenant filter — the Editor runs as owner and bypasses RLS**

A gate-impact query (`WHERE is_facilitator AND pipeline_level < 3`) was handed over with **no `church_id` filter**. The SQL Editor runs as owner, so RLS is off (#186) and the result spanned **every tenant**: 12 of the 60 rows returned were **Agape** members, not Rosehill. The Pastor spotted one name (Tofy) and reasonably suspected a tenancy leak; the wall was in fact intact — migration 028 had moved him correctly. The bug was the query. A cross-tenant result read as single-tenant is **worse than no result**: it manufactures false alarms and can equally mask real ones. RULE: every diagnostic SELECT in the Editor joins `churches` and filters `c.slug = '<tenant>'`, or is explicitly labelled as cross-tenant. This is a direct corollary of #186 and it bites the author, not the app.

**Established July 13, 2026 (Session 70). Invariant #313 added - count now 313.**

---

### **314. The MD level gate lives in THREE files and must move as one**

MD had **no level gate at all**: `gateOrRedirect()` only checks that a valid session exists, and `leader_login` offered a free Desktop/Mobile chooser. In 14,396 lines `leaderLevel` appeared 14 times and the only runtime UI gate was the "+ Add Member" button. So an L2 LCL could reach Settings, Attendance Admin, Preaching Admin, Lesson/Quiz Editor, SVI weight profiles and Bulk Send. Restricting MD to Coach (L3+) required **three** coordinated gates: `index.html` (shell registry `TOOLS.md.minLevel`), `leader_login.html` (hide the Desktop option), and `multiply_dashboard.html` (`MD_MIN_LEVEL` entry backstop for bookmarks / typed URLs / installed PWA). Miss any one and the restriction leaks. RULE: `MD_MIN_LEVEL` is duplicated in three files by deliberate tradeoff (centralizing it in `multiply_shared.js` would force a `?v=` bump across every tool); each copy carries a comment pointing at the other two, and they move together. **This is a UX/role gate, NOT a security boundary — RLS remains the only real boundary.**

**Established July 13, 2026 (Session 70). Invariant #314 added - count now 314.**

---

### **315. Session-derived identity must resolve LIVE, never snapshot at parse time — the frozen shim was the ROOT CAUSE of the duplicate-member epidemic**

MLT's `currentLeader` was built by an anonymous IIFE that snapshotted `window.LEADER` at **parse time**. Inside the shell iframe the session arrives later via postMessage (#169), so every field froze as `undefined`. The damage was silent and wide: (a) Add Member showed a **blank Discipler box** despite the hint "Auto-set to you"; (b) `saveNewMember` wrote **`discipler_id: null`** → an **ORPHAN member**, invisible in its own LCL's list → the LCL assumed the save failed and **added the person again → DUPLICATES**; (c) the L2 level clamp never fired (`myLvl` read as 0); (d) `openChangeLevel` rejected real LCLs. A prior band-aid (`currentLeader.pipeline_level = lvl;`) had patched one symptom without seeing the disease. FIX (#166): rebuild the shim with `Object.defineProperty` getters that resolve from the live session on each read, caching only once a real session appears; a setter preserves the legacy assignment. **One change healed all 35 call sites.** Plus belt-and-braces: `saveNewMember` now REFUSES to save when no discipler resolves. RULE: never snapshot session-derived identity into a `const` at module scope. Resolve it live, or you will ship an orphan.

**Established July 13, 2026 (Session 70). Invariant #315 added - count now 315.**

---

### **316. Public celebration is for EVENTS, never for STATES — and the flag is FAIL-CLOSED**

When the Pastor asked for rung completions to reach the LC's celebrations, the temptation was to broadcast them all. The rungs make that catastrophic: `category='character'` holds the nine fruit of the Spirit **alongside** "No moral failure 5 yrs", "No active church discipline", "Financial integrity audit", "Assurance of salvation", "Family affirmation". Announcing *"Joy is growing in Ana"* makes the room ask **why not Ben** — the **silence about everyone else becomes a verdict**. Announcing *"no moral failure"* tells the room that moral failure is being **measured**. The Pastor drew the line himself and drew it better than the proposal: **books, training, lessons, ministry onboarding, baptism, EGR** — all things that HAPPENED. *"Ana finished Mere Christianity"* affirms Ana and says nothing about Ben: he simply has not read it yet. Migration 076 encodes this as `meta.celebrate_publicly`, set on exactly 56 base + 3 Rosehill overlay rungs. **Default = absent = PRIVATE.** Fail-open would mean a sensitive rung added a year from now gets broadcast silently and nobody notices. Private notification to the disciple still fires for **every** rung — they still hear that they are seen; it is simply not spoken aloud.

**Established July 13, 2026 (Session 70). Invariant #316 added - count now 316.**

---

### **317. Do not type-check by substring or by `category` — assert on an explicit allowlist**

Twice in one session a string was mistaken for a type. (a) The celebration message keyed on `category`, but `category='character'` is a **mixed bag** — it holds "Joy" (formation) next to "Completed BTLI 101" (achievement), so category-keyed copy would have been wrong for the majority. FIX: key on the **title** against an explicit nine-fruit table. (b) Migration 076's safety guard used `title_en ILIKE '%discipline%'` to catch "No active church discipline" — and **false-alarmed on the BOOK "Disciplines of a Christian Coach (Webb)"**, which is correctly celebratable. FIX: assert on **category membership**, which is what was actually decided. RULE: a human-readable title is not a type. When a decision has been made about a set of rows, encode the SET (an allowlist, or a column), and assert against the set — never against letters that happen to look similar.

**Established July 13, 2026 (Session 70). Invariant #317 added - count now 317.**

---

### **318. The bytes proven must be the bytes shipped — a hand-edited prompt invalidates its own back-check**

Three times this session the byte-for-byte back-check failed, and **every time the fault was mine, not CC's**: after proving an edit on a `/tmp` copy I reworded a comment (twice) or reflowed a line (once) while writing the CC prompt. The branch then matched the PROMPT but not my PROVEN COPY — so my own reference was stale and the back-check reported a false difference. Worse, in one case the proof copy contained a **real bug** (#312) that the prompt did not, meaning the artifact I "proved" was the broken one. This is the same family as the stale-base trap in #162. RULE: generate the prompt **from** the proven bytes, or re-prove after any hand edit. If the prompt is touched by hand, the proof is void and must be re-run before it can serve as a back-check reference.

**Established July 13, 2026 (Session 70). Invariant #318 added - count now 318.**

---

### **319. Do not self-verify with grep-match COUNTS — measure the things that cannot be miscounted**

**Eight times** in one session a CC self-verify count came back different from the spec's expectation, and **eight times CC was right and the spec was wrong**. The pattern is always the same: I count the places I am ADDING a token and forget (a) that my own **comments** contain the token, (b) that a `console.warn`/error path references the function, and (c) that a **pre-existing unrelated line** also matches the grep (`cat === 'btli'`, a nine-hundred-line-away match). CC surfacing these instead of silently "correcting" toward my wrong number is exactly right — a silent fix toward a bad expectation is how real drift hides. RULE: self-verify on quantities that **cannot** be miscounted — **byte delta**, **file count**, `git diff --numstat`, **syntax check**, byte-for-byte `cmp` against the proven copy. Where a grep count is genuinely useful, state it as "≥ N" or enumerate the expected lines rather than asserting an exact total.

**Established July 13, 2026 (Session 70). Invariant #319 added - count now 319.**

---

### **320. A duplicate `display` in an inline style silently defeats the earlier one — and `el.style.display = ''` DELETES the property, it does not restore it**

MLT's heads-up banner flashed "0 heads-ups from your LC" on every boot. It read like a race condition; it was not. The element carried **two** `display` declarations in one `style` attribute — `style="display:none; …padding:11px 14px; display:flex; …"`. Last declaration wins, so the CSSOM resolved `display:flex` **at parse time**: the banner was VISIBLE from first paint until `renderHeadsUpBanner()` ran (behind a `setTimeout(…, 800)` **and** a DB round-trip) and hid it. The `display:none` the author believed in had been overridden the whole time. **A duplicate property in an inline style is invisible in review — the eye reads the first declaration and stops.**

The same bug has a **second half**. The show-branch did `banner.style.display = ''`, intending "restore it." But `el.style` is a declaration block: the two declarations collapse into ONE entry whose value is `flex`, and assigning `''` **removes the property entirely**. With no stylesheet rule for `#headsUpBanner`, the div fell back to `display:block` — icon, text and chevron stacking vertically instead of sitting in a row. It only ever "looked fine" because nobody had a pending notice while looking.

**RULE:** one `display` per inline style, ever. Never write `style.display = ''` meaning "put it back" — **set the intended value explicitly** (`'flex'`, `'block'`). `''` is only correct when a stylesheet rule is *known* to supply the fallback (e.g. `.qa-btn { display:flex }`), and even then, say so in a comment. **Corollary:** when a collapsed/hidden state is wanted, prefer **not emitting the markup at all** over hiding it with `display:none` — a node that isn't there cannot be un-hidden by a stray declaration.

**Established July 14, 2026 (Session 71). Invariant #320 added - count now 320.**

---

### **321. `json.dumps` without `ensure_ascii=False` turns emoji into lone surrogates — a Python string literal will NOT recombine them, and the FIND matches zero**

Generating a CC patch script mechanically from a proven diff, the emitted `PAIRS` were serialized with `json.dumps(...)`. Every hunk then matched **zero** times against a file they had been derived from minutes earlier. The cause: `json.dumps` defaults to `ensure_ascii=True`, which encodes 📋 as the surrogate pair `\ud83d\udccb`. **JSON parsers recombine that into one character. Python source does not** — `"\ud83d\udccb"` is a two-element string of lone surrogates, and it is not equal to `"📋"`. The FIND string was quietly a different string from the file.

Same family as **#312** (`\UXXXXXXXX` is not valid JS): *an escape form that is valid in one language and junk in another.* The failure mode is the dangerous one — no exception, no warning, just a silent non-match that looks like a stale anchor.

**RULE:** any time Python emits string literals that will be re-parsed as Python (patch scripts, anchor blocks, generated code), pass **`ensure_ascii=False`** and write the file as UTF-8. The emoji, box-drawing chars (`─ ═ ▸ ▾ ·`) and arrows in this codebase are everywhere; assume every generated literal contains one.

**Established July 14, 2026 (Session 71). Invariant #321 added - count now 321.**

---

### **322. The CLIENT must never be the authority on WHO the caller is — `auth-login` trusts `body.stamp`, so every shell login is invisible to `leader_sessions`**

`auth-login` decides whether a login is a leader login with `const isLeader = body.stamp === "leader"` — **a flag supplied by the browser.** Only `leader_login.html` (the LEGACY page) sends it. The unified shell `index.html` redirects **everyone, leaders included**, to `member_login.html`, which does not. So `stampLogin()` takes the `else` branch, updates `members.member_last_login`, and **inserts no `leader_sessions` row at all**.

Result: `leader_sessions` does not measure "how often a leader opens MLT." It measures **"how often a leader used the old login page."** As leaders migrated to the shell and the PWA, their rows stopped appearing — and the resulting graph looked exactly like a collapse in engagement. `leader_last_login` is stale for the same reason (the Pastor's read `2026-07-07` while his `member_last_login` read `2026-07-13`).

The server already loads `pipeline_level` in `MEMBER_COLS`. **It has the answer and asks the client anyway.** This is the same class of error as a client-side permission gate — the difference is that a permission gate fails *loudly* when abused, while an identity flag fails *silently* and corrupts a year of telemetry.

**RULE:** the server derives identity, level and role from **its own DB read**, never from the request body. A client-supplied hint may select a *destination*; it may never establish a *fact*.

**Established July 14, 2026 (Session 71). Invariant #322 added - count now 322.**

---

### **323. `ended_at IS NULL` does not mean "active" — it means "never explicitly closed," and one logout rewrites the whole history**

Every one of the Pastor's 20 `leader_sessions` rows carried the **identical** `ended_at` — `2026-07-12 13:27:16.893` — including sessions from June 14 that had expired weeks earlier. Both writers (`multiply_shared.js`, `multiply_dashboard.html`) are **correct**: they filter `.eq('leader_id', id).is('ended_at', null)`. The bug is that **nothing ever reaps an expired session.** `ended_at` is written *only* on an explicit logout, and people don't log out — they close the app. So the NULLs accumulate, and the first real Logout matches **every session the leader ever had** and stamps them all in one write.

Three consequences: (a) `ended_at` / `ended_reason` are **junk** — session duration is unmeasurable; (b) every logout write-amplifies across the member's entire history; (c) **the landmine** — any future code reading `ended_at IS NULL` as "currently active" would see a leader with 40 past logins as **40 concurrent sessions**. Nothing reads it that way today. Something will.

**RULE:** a lifecycle column needs a writer for **every** way the lifecycle can end, not just the polite one. If a session can expire, something must stamp `ended_at = expires_at, ended_reason = 'expired'`. Until then, treat `ended_at IS NULL` as "unknown," never as "open," and never build a filter on it.

**Established July 14, 2026 (Session 71). Invariant #323 added - count now 323.**

---

### **324. Validate the instrument before you interpret it — a telemetry column with no PROVEN end-to-end write path is not evidence**

From `leader_sessions` I built a confident, vivid story: weekly logins had collapsed **93%** (706 → 48), **18 of 49 leaders** had last opened MLT in a single five-day window, and that window sat on **June 15** — the exact date the service-worker cache froze (#310). I produced charts. I told the Pastor **not to hold his LC meeting**, and drafted an apology to send to sixty leaders for a bug that had locked them out.

**All of it was an artifact of #322.** The instrument was broken. The correct query — `member_last_login`, the column the shell actually writes — showed **46 of 49 leaders active in the last 7 days and 49 of 49 in the last 30.** Engagement had never fallen at all. The "cliff" was leaders **changing front doors.**

I even wrote the words *"validate the instrument before you act on it"* — and then did not do it myself, until a single row that didn't fit (the Pastor's own) forced the check.

**RULE:** before any conclusion is drawn from a telemetry column, **prove the write path end-to-end**: perform the action, then confirm the row appears. A column that *exists* is not a column that is *written*. And a chart is not evidence — it is a rendering of whatever the column happened to contain. **The more compelling the narrative, the more urgently the instrument needs auditing** — a broken metric that tells a boring story gets checked; one that tells a thrilling story gets believed.

**Established July 14, 2026 (Session 71). Invariant #324 added - count now 324.**

---

### **325. A rate is a lie until its denominator is audited — count only the people who COULD have participated**

Announcements ride on MMT/MLT, and member engagement read **35% active in 7 days / 60% in 30** — comfortably "below 50%," and the Pastor was preparing to address it with his LC leaders.

Then the denominator: of **161 members, 38 have no PIN.** They have never been given a credential. **They cannot log in.** They were not ignoring the church — the door was never opened for them.

Recompute against the 123 who actually hold a key: **122 of 123 have used it. One single person received a PIN and never opened the app.** Adoption is not 35%. It is **99%**. The bottleneck was never motivation — it was **onboarding**, and the 38 un-onboarded members had been silently diluting every percentage the platform had ever produced.

**RULE:** before reporting any rate about people, subtract everyone who was structurally unable to participate — no PIN, no discipler, not yet enrolled, test/external (`is_test_member`, `is_external_user`). Report the excluded count **alongside** the rate, never folded into it. A denominator that includes the unable does not measure obedience; **it measures your own onboarding, and blames it on them.**

**Established July 14, 2026 (Session 71). Invariant #325 added - count now 325.**

---

### **326. A DISPLAY typeface is not a TEXT typeface — MMT sets its reading body in Fraunces, and a member thought his vision was failing**

A member reported that in the MMT devotional "some capital letters appear wavy," and believed he was having an **episode affecting his eyesight.** He was not. MMT sets body text in **Fraunces** (58 declarations) — an "old style" soft-serif in the Windsor/Souvenir/Cooper lineage, shipping a variable axis literally named **WONK** that introduces deliberately wonky, swashed letterforms. Its stems swell and taper, its serifs curve rather than sit flat, and its stroke contrast is high. At body size, on a phone, thin strokes drift toward the rendering threshold and **shimmer**; soft swelling stems on capitals read as **undulating**. MMT also carries **31 `text-transform:uppercase` rules** — a row of high-contrast, soft-serifed, wonky *capitals* is the worst case, and capitals are exactly what he named.

**A display face was doing a text face's job.** Legibility for aging eyes turns on **low stroke contrast**, **large x-height**, **open counters** and **unambiguous letterforms**. Fraunces fails the first and, on the WONK axis, the last.

**RULE:** display faces set headings; text faces set paragraphs. For MMT's reading surfaces use a **screen-reading serif** (Literata, Source Serif 4 — keeps the Scripture feel), keep Fraunces for `h1`–`h3`, never `text-transform:uppercase` on anything a person actually reads, and offer an **Easy Read** mode (Atkinson Hyperlegible, Braille Institute, built for low vision). **AND — the pastoral half:** perceiving straight lines as wavy (*metamorphopsia*) is a real ophthalmic symptom. When a member reports it, fix the font **and** ask him to check whether door frames, tile grout or printed text look wavy too, one eye at a time. A typography fix must never quietly mask a retina.

**Established July 14, 2026 (Session 71). Invariant #326 added - count now 326.**

---

### **327. The handoff's own fix-list is a hypothesis, not a spec — re-derive the fix from the file before executing the plan**

Session 71 handed Session 72 a four-point fix for the MMT font (#326): (1) Literata for body, (2) demote Fraunces, (3) "add the A−/A+ slider," (4) "kill uppercase in the reading flow." Auditing the actual file before writing a line: **the slider already existed** (`FONT_STEPS=[0.9,1.0,1.1,1.25,1.4]`, `adjustFont()`, `multiply_mmt_fontscale`, applied as `zoom`) — a dead bullet; and **there was no uppercase in the reading flow** — all 31 `text-transform:uppercase` rules were chrome (tabs, pills, eyebrows), so that bullet was a no-op too. The diagnosis was also loose: `body{font-family:'DM Sans'}` — MMT does not set *body* text in Fraunces; it sets the *reading surfaces* in it, which was the part that mattered.

**RULE:** a HANDOFF TODO is a prior instance's hypothesis written before the fix was attempted. Treat it exactly like a pending/parked note (#97): verify each claim against the current file before acting. Two of four bullets here were already-done or non-existent. Re-derive; don't execute on faith.

**Established July 14, 2026 (Session 72). Invariant #327 added - count now 327.**

---

### **328. A stylesheet sweep is not a typography audit — the worst offenders were inline in JS template strings, and a CSS custom property crosses that boundary**

The Fraunces fix (#326) looked like a handful of CSS selectors. A `grep` of the stylesheet would have caught them and **missed twelve more** `font-family:'Fraunces','Georgia',serif` declarations living inside JS template literals — the sermon body, three quiz question stems, the quiz reflection textarea, lesson prose, the Library transcript, encouragement blocks — every one a surface a person *reads* or *types into*, none visible to a CSS grep. A residual-audit pass then found three more (an EOLO subtitle set light-on-dark at 12.5px, two typed-into inputs). Final count: 25 reading surfaces, not the 4 first assumed.

The elegant half: rather than swap 25 literals, introduce a CSS custom property — `--font-read` (Literata) with `--font-display` (Fraunces) and `--font-easy` (Atkinson) — and repoint every surface to `var(--font-read)`. Then `body.easy-read{ --font-read:var(--font-easy); }` flips **both** the stylesheet rules *and* the inline `style=` literals in one class, because **a CSS variable crosses the inline-style boundary a class selector cannot reach.** One token beats two sweeps.

**RULE:** to change how a rendered surface looks, sweep the *rendered surface* (CSS + inline `style=` in JS templates), not just the stylesheet. And prefer a CSS custom property over N literal edits — it is the one mechanism that reaches inline styles without touching them.

**Established July 14, 2026 (Session 72). Invariant #328 added - count now 328.**

---

### **329. A new-file heredoc is where transport drift hides — base64 the proven bytes, never hand-retype; a 2-byte drift passes every grep and only the SHA catches it**

`GIVING_JOURNEY.md` was authored and proven (SHA `40f83bfe…`, 16,476 bytes). Handed to CC as a heredoc, CC's copy hashed to `b7493d74…` — **16,478 bytes.** Same 180 lines, same 85 non-ASCII characters, same emoji and em-dashes; two stray invisible bytes (whitespace) had crept into the hand-typed heredoc. CC's diagnosis reasoned "the same characters transported byte-exact into `md_manual.html`, so this file is verbatim too" — and **talked past its own byte count**, which was the actual tell. The fix was not to hunt the 2 bytes but to make the shipped file equal the proven file: base64-encode the proven copy, have CC `base64 -d` it (zero retyping), re-verify → exact `40f83bfe…`.

**RULE:** when a whole new file (or any large block that cannot be a `str_replace` anchor against existing content) must reach CC, deliver it as **base64 of the proven bytes** and have CC decode it — never as a heredoc to be re-typed. This is the `m.md` splice discipline extended to whole-file creation. And when a SHA gate disagrees, the byte *count* is decisive over the byte *characters*: same chars + different count = invisible-whitespace drift, still a real defect. The bytes you prove must be the bytes you ship (#318); a 2-byte drift passes every grep-count check and only the SHA catches it (#319).

**Established July 14, 2026 (Session 72). Invariant #329 added - count now 329.**

---

### **330. GIVING IS A HEART ISSUE — the discipleship of giving is a path of TRUST, and the platform teaches it but never measures it**

The pastor asked to help disciples grow in generosity, expressed in giving. The design that emerged (see `GIVING_JOURNEY.md`) rests on the conviction that money is never a neutral resource but a **rival god** (Mt 6:24) and a **diagnostic of the heart** (Mt 6:21) — so giving is faith, trust, gratitude, accountability, and the recognition of God's ownership, not merely generosity. Hence the **Giving Journey / *Landas ng Pagtitiwala*** (Path of Trust): six rungs (First Fruits → Rhythm → Proportional → The Tithe → Sacrificial → A Generous Life), anchored in 2 Cor 8–9 and **never Malachi's storehouse threat**, framed in formation language ("Trust is being formed in you," never "Giving: complete"), mapped across the pipeline (L1 give-at-all → L2 know-your-portion/model-it → L3 form-other-givers/giving-costs → L4 generosity-as-a-way-of-life; #331).

**RULE:** any giving feature disciples the heart; it does not run a collection drive. It **teaches** the journey (visible to all, in the manual, on the pipeline) and **never measures** a person's actual giving as a metric, rank, or flag. The moment giving becomes a number the system tracks about a person, it has become the tax it was built to prevent.

**Established July 14, 2026 (Session 72). Invariant #330 added - count now 330.**

---

### **331. The path is the discipler's; the YES is the disciple's — obedience can be required, faith cannot be installed**

The pastoral knot: how to avoid *abdication* ("the disciple decides his own path in his own time" — the parent who says "go to school whenever you want") without tipping into *coercion* (manufacturing a "yes" through pressure, a dashboard, comparison, guilt — the tax God rejects, 2 Cor 9:7). The resolution: the parent commands the outward step and **woos** the inward heart, and knows the difference. **Obedience can be required. Faith cannot be installed.** The discipler owns the *summons* — the path is his to set, the invitation his to issue, loud and persistent and by name. The disciple owns only the *yielding* — not "will you grow" (not his to refuse) but "will you open your hand" (his alone, or it is not a gift).

**RULE (the volunteer-only yes):** the discipler may invite as hard as he likes; the **system may not press at all.** For the Giving Journey specifically: the giving rungs appear on a member's pipeline — his own MMT view *and* his LCL's MLT view — **only after the member's own action** opens a covenant (naming one leader to walk it with). RLS enforces member-insert-only on the covenant; the LCL can never flip the switch, and once opened, marks the rungs like any other rung *because he was invited*. The invitation is a shepherd's voice, never a notification.

**Established July 14, 2026 (Session 72). Invariant #331 added - count now 331.**

---

### **332. Absence is not a verdict — and the finance wall is permanent**

Two guardrails the Giving Journey made explicit, extending #316 ("public celebration is for events not states; the silence about everyone else becomes a verdict"):

**(a) Absence is not a verdict.** The giving rungs do not sit visible-but-unchecked on every member's pipeline — a row of grey giving rungs would itself accuse ("this one hasn't started giving"). They are **absent** until the member opts in (#331). No dashboard, no leaderboard, no ranking of who gives what; no AI flag, no "0% for three weeks" alert, ever. The **0% member is invisible to the machine** — a lost job, a sick spouse, debt — and his leader learns it the ancient way, by asking, and answers it the Acts 4 way: give to him, do not measure him.

**(b) The finance wall.** The discipleship platform **never reads the church finance office's actual giving records** — not for privacy, but because *self-disclosure and audited record are different acts*: one is confession (it disciples), the other is audit (it polices). The private calculator lives only on the member's device; if he ever shares a number, he shares it, and it is never checked against a ledger behind his back.

**RULE:** guard both walls in every future giving feature. A build that adds a giving dashboard, a low-giving flag, or a finance-ledger cross-check has broken the doctrine, not merely a setting.

**Established July 14, 2026 (Session 72). Invariant #332 added - count now 332.**

---

### **333. Doctrine belongs in two homes, two voices — the repo teaches the builder, the manual teaches the pastor**

The Giving Journey's rationale was committed twice: `GIVING_JOURNEY.md` (canonical doctrine for builders — includes the RLS/guardrail/plumbing framing) and a new **"The Giving Journey"** chapter under a **"The heart of MULTIPLY"** nav group in `md_manual.html` (pastoral voice only — the four convictions, the six rungs, a pastor's examination of conscience; no build talk), reachable in-app via MD → Manual. A markdown file governs how the system is built; an in-app page shapes how a pastor uses it, and a pastor who misunderstands the *why* can invert a feature into its opposite. Same doctrine, different audience, different voice.

**RULE:** when a feature's design carries pastoral rationale a *user* must understand (not just a builder), commit it in both homes — the repo doc for build-time truth, and the in-app manual (pastoral voice, plumbing stripped) for the person who wields it. `md_manual.html` is a scroll-spy single-page manual; a new chapter is one nav `<a>` + one `<section id>`, and the scroll-spy picks it up automatically.

**Established July 14, 2026 (Session 72). Invariant #333 added - count now 333.**

---

### **334. The covenant-gate — a consent table makes a doctrine-sensitive feature visible only to those who opted in; absence renders as nothing**

The Giving Journey is gated by `giving_covenant` (member-insert-only RLS, no finance columns — consent + companionship, never amount/percentage/income, #330). Its six rungs (`meta.track='giving'`) are filtered OUT of the normal pathway metro AND its done-count, and appear only inside a dedicated section that renders ONLY when an open covenant exists — on the member's view (MMT) and the companion's (MLT). Non-participants never see the rungs; the leader is never shown who *hasn't* opened one and can never ask why. In pixels: `host.innerHTML=''` on an empty query, never a "not started" row.

**RULE:** for a consent-gated, doctrine-sensitive feature, gate visibility on a member-insert-only table; render empty as nothing, never as an absence-state; never surface a roster of who hasn't opted in — even to the pastor. Scope the RLS to the two parties only.

**Established July 16, 2026 (Session 73). Invariant #334 added - count now 334.**

---

### **335. Formation renders as formation, never a scoreboard**

Giving-rung completion (LCL-affirmed in `pathway_progress`) shows the member a soft formation line — "Your companion sees this becoming true in you" — with no checkmark, no count, no progress bar. `celebrate_publicly=false` + `trackable=false` keep it off every feed and metric. And because `renderPathway` computes `nDone` by filtering the *already-giving-filtered* `rungs` list, a giving completion never leaks into the pipeline progress bar even though it lives in the same `pathway_progress` table.

**RULE:** for formation/character/giving rungs, completion is a private acknowledgment in formation language, never a triumphant state; exclude the track from BOTH the list and the done-count. Public celebration is for events, not states (#316).

**Established July 16, 2026 (Session 73). Invariant #335 added - count now 335.**

---

### **336. `category='formation'` is not free — widen the CHECK**

`pathway_rungs.category` carries a CHECK (`pathway_rungs_category_check`) that did NOT include `'formation'`; seeding the giving rungs required a drop-if-exists + re-add of that constraint with the value appended (safe — adding an allowed value never invalidates existing rows). The jumpstart had named `category='formation'` as if already valid; the database rejected it.

**RULE:** before seeding a row with a new enum-ish value, read the CHECK from the migration / `schema.json`; if the value is new, widen the constraint in the same migration. Never trust a summary that names a column value without confirming it's allowed (extends #290).

**Established July 16, 2026 (Session 73). Invariant #336 added - count now 336.**

---

### **337. Mirror the proven `pathway_progress` writer — triggers and defaults are invisible but load-bearing**

Marking a rung done already had a proven prod pattern (`_mltPwToggle`): `insert({ member_id, level, rung_key, marked_by })` — NO `church_id` (stamped by trigger `trg_set_church_id`), NO `completed_at` (column default `now()`); delete keyed by `member_id + level + rung_key`; and **row-existence = done** (`renderPathway` builds its `done` set from presence, not from `completed_at`). A first draft that set `church_id`/`completed_at` explicitly and deleted without `level` would have fought the trigger/default and mismatched the done-check — caught by reading the existing writer before shipping.

**RULE:** before writing a new writer for an existing table, read how that table is already written in prod and mirror it exactly. Column defaults and triggers do not appear in the client code but are load-bearing (extends #246 to writes).

**Established July 16, 2026 (Session 73). Invariant #337 added - count now 337.**

---

### **338. The BASE/WANT gate is what makes a wrong-context push impossible**

This session CC was, at different moments, on a stale Session-44 clone, then bound to the *wrong repo* (`eastbridge-op`, a different app), then a stale session after a device switch. Each time the BASE-sha gate (the repo file must equal the parent we patched) + the WANT-sha gate (result must equal the proven copy) + CC's read-first discipline halted the swap before any clobber — three times, zero damage. Verifying the true upstream (codeload + `git ls-remote`, never a cached clone) settled ground truth each time.

**RULE:** every CC file-swap gates on BOTH `sha(repo file)==BASE` and `sha(uploaded)==WANT`, and CC confirms `pwd`/`origin` before anything outward-facing. A new device or new session can silently point CC at a stale clone or the wrong repo; the gate, not vigilance, is the safety.

**Established July 16, 2026 (Session 73). Invariant #338 added - count now 338.**

---

### **339. The uploaded file lands at a separate path with a possible suffix — target the real path, prove it by WANT**

CC's uploads arrive at `/root/.claude/uploads/…/<hash>-<name>.html` (sometimes `_N`-suffixed from a repeat download), NOT at repo root and NOT at a predictable `/mnt/user-data/uploads` glob. A swap that globs a fixed location reports "no upload found" even when the correct bytes are present.

**RULE:** in a CC upload-swap prompt, set a `UP` variable to the real upload path CC reports and let the WANT-sha prove identity — the filename suffix and mount location are irrelevant once the bytes hash to WANT.

**Established July 16, 2026 (Session 73). Invariant #339 added - count now 339.**

---

### **340. codeload tarballs go stale like raw — SHA-check after every merge**

At session open the tarball read count #326 while `main` was #333 (the #183 doc-splice hadn't re-cached); mid-session, branch tarballs sometimes lagged a merge by a minute. The "this can't be a cache" reasoning was wrong once — a coherent-but-behind snapshot is exactly what a time-ordered CDN cache produces.

**RULE:** after a merge, re-pull and confirm the file's sha (or pin to the commit via the GitHub API when not rate-limited) before trusting a codeload read; internal coherence does not prove freshness. #278 applies to codeload, not just `raw.githubusercontent`.

**Established July 16, 2026 (Session 73). Invariant #340 added - count now 340.**

---

### **341. The Giving Journey begins at L1, not L0**

"Visible from the beginning" in `GIVING_JOURNEY.md` means from the *start of the pathway* — which begins at L1 — not L0. The rungs seed at L1–L4; the MMT door is L1-gated (`pipeline_level < 1 → host.innerHTML=''`). An L0 member seeing a door to a path whose first rung didn't yet exist for them was the tell.

**RULE:** for the Giving Journey, "from the beginning" = from L1; the door and rungs are gated `pipeline_level >= 1`. `GIVING_JOURNEY.md` wording reads "visible from L1 onward" to remove the L0 ambiguity.

**Established July 16, 2026 (Session 73). Invariant #341 added - count now 341.**

---

### **342. GitHub Pages runs Jekyll by default — its metadata plugin makes a live GitHub-API call that can 503 and fail the deploy; `.nojekyll` is the cure for a static site**

MULTIPLY is a pure static PWA (no `_config.yml`, no `_layouts`, no `Gemfile`), yet GitHub Pages ran it through **Jekyll** anyway — because there was no `.nojekyll` file. Jekyll's `jekyll-github-metadata` plugin calls `GET https://api.github.com/repos/gejable1/multiply` during every build. During an API 503 storm that call failed, the **"pages build and deployment"** Action went **red**, and Pages kept serving the last *successful* (old) commit — so a correctly-merged fix (`main` had the new file) never reached the browser. The tell: `main`'s file sha was new, but the published `github-pages` deployment sha was an older commit whose file was old.

**RULE:** for a static Pages site, commit an empty **`.nojekyll`** at the publish root — it skips Jekyll entirely (no API call), so deploys are fast and can't 503-fail. If a Pages deploy goes red, read the Actions **build** log: a `GET api.github.com … 503` is transient GitHub infra, not your code — re-running the job works once the storm clears, but `.nojekyll` prevents the whole class.

**Established July 17, 2026 (Session 74). Invariant #342 added - count now 342.**

---

### **343. "Old file still showing" — check the DEPLOYED Pages commit, not just `main`; and hard-reload never clears the service-worker cache**

`main` can carry a merge (new file bytes) while GitHub **Pages still serves an older commit** — deploy lag, or a failed deploy. Chasing browser cache first wastes an hour. Diagnose in order: (1) `git ls-remote … refs/heads/main` for the real HEAD; (2) `api.github.com/repos/.../deployments?environment=github-pages` for the actually-**published** sha; (3) codeload that published sha and check the file bytes. Only once Pages is confirmed current do you look at the client. And on the client: DevTools **"Empty Cache and Hard Reload" clears the HTTP cache but NOT the service-worker Cache Storage** — and a file opened inside a modal **iframe** is SW-intercepted, so it keeps serving the cached copy. The fix (once Pages is current) is **"Clear site data"** (which wipes Cache Storage) or a CACHE_VERSION bump.

**RULE:** before blaming the browser, prove what Pages actually published (deployments API + codeload the deployed sha). To force a client past a stale SW copy: "Clear site data," not hard-reload.

**Established July 17, 2026 (Session 74). Invariant #343 added - count now 343.**

---

### **344. Bump `multiply-sw.js` CACHE_VERSION to force clients to purge stale caches**

The service worker's `activate` handler deletes every cache whose name ≠ `CACHE_VERSION`. Bumping the date-stamped version (`multiply-shell-v2-2026-07-12` → `…-2026-07-17`) makes every client auto-refresh on next load with **no manual "Clear site data."** Bump it whenever a cached HTML file changes and you want guaranteed-fresh delivery to LCLs — `facilitator_debrief_guide.html` isn't precached but is still SW-cached on-demand via `networkFirst`, whose short-timeout race can serve a stale copy. **Caveat:** the *old* SW is still in control on the first post-merge load; it hands off to the new SW, which purges on *its* activate — so the very first client still needs one manual clear, and everyone after is automatic.

**RULE:** a change to any SW-cached HTML that must reach LCLs promptly ships **with** a CACHE_VERSION bump; expect one manual "Clear site data" on the first load after merge, automatic thereafter.

**Established July 17, 2026 (Session 74). Invariant #344 added - count now 344.**

---

### **345. `diagnostic_results` stores only SECTION aggregates — individual scale answers were never persisted**

The salvation diagnostic saves `section_fruit_*` (nine fruit), `section_assurance`, `section_disciplines`, `section_gospel`, etc. — but **never the per-question scale answers** (the B1 confidence rating, per-habit scores). So debrief ask-box brackets like `[their B1 score]` and `[lowest habit]` are structurally **un-fillable by anyone** (AI or client) → reword them away, or repoint to a stored **free-text** `open_answers` field (the B section now references the B2 answer, which IS stored). Fruit **highest/lowest IS computable** from the nine `section_fruit_*` columns. The free-text `open_answers` (A1, A3, A5, B2, B5, C1, C2, D1, F1, H1–H5) are what drive the AI tailoring.

**RULE:** before promising to "fill in" a diagnostic value, confirm it's actually stored — `diagnostic_results` has section aggregates + `open_answers` free-text only, not raw per-question scale scores.

**Established July 17, 2026 (Session 74). Invariant #345 added - count now 345.**

---

### **346. Client-side placeholder fill runs at load, before any tailoring/snapshot, and skips rich-text elements**

`_fillPlaceholder(bracket, value)` substitutes bracket text in `.ask-box` elements guarded by `children.length===0` — so it only touches leaf text nodes and never flattens child markup. It fires in the member fetch `.then()` for `[Name]` and the diagnostic fetch `.then()` for fruit names — **before** the tailored snapshot is taken — so both the standard AND tailored views show real values, and the revert snapshot captures the already-filled baseline. Tagged AI ask-boxes still show their bracket *cues* in standard and are AI-filled (or omitted → left as the cue) in tailored. This is the pattern for any "known fact" fill (name, computed scores) versus AI conversation-tailoring.

**RULE:** fill known facts client-side at load (leaf-only, before snapshot); reserve AI tailoring for free-text-derived conversation prompts. Never string-replace into an element with children.

**Established July 17, 2026 (Session 74). Invariant #346 added - count now 346.**

---

### **347. BASE→patcher→WANT is the default surgical-edit delivery — proven end-to-end through CC this session**

For surgical edits, Claude writes a Python patcher in `/tmp`, runs it against a codeload `origin/main` copy, asserts **each edit matches exactly once**, `node --check`s the result, and computes a **BASE** sha (current file) + **WANT** sha (patched). CC runs the *same* patcher inside one fenced block: fetch + branch off `origin/main` → `git checkout origin/main -- <file>` → **BASE gate** (halt on mismatch) → run patcher → **WANT gate** (halt on mismatch) → CRLF check → `node --check` → commit → `git push -u` → `gh pr create`. Never stop at commit. Claude then back-checks the PR head **byte-for-byte** via codeload against WANT before greenlighting the merge. First full runs = PRs #195 and #196 — clean end-to-end. The BASE/WANT gate is the safety, not vigilance (#338); the patcher is the deliverable.

**RULE:** surgical edits go BASE→patcher→WANT through CC as one block; whole-file **upload** (UP-var proven by WANT sha, #339) is reserved for near-total rewrites. Back-check every PR head vs WANT via codeload before merge (#318/#340).

**Established July 17, 2026 (Session 74). Invariant #347 added - count now 347.**

---

### **348. The Giving Journey L1-gate is a lockstep invariant -- MMT and MLT must BOTH gate at `pipeline_level >= 1`**

The formation track begins at L1 (#341). MMT `renderGivingJourney` gates the door; the MLT companion card (`_refreshGivingCompanions`) must MIRROR it -- resolve each covenant member's level (`members.select('id,pipeline_level').in('id', memberIds)`) and filter to `>= 1`, failing OPEN on a hard level-fetch error so a transient glitch never blanks a legit view. A disciple who opened while ungated, or was later moved to L0, is DORMANT on the leader side (hidden, not deleted) and reappears at L1. The gate is client-side only (RLS is member-insert, no level check), so the two views silently diverged until this -- an L0 member showed all 6 rungs on the leader's card while invisible on her own.

**RULE:** the giving door/rungs gate at `pipeline_level >= 1` in BOTH MMT and MLT; a dormant L0 covenant persists (never auto-closed) and reappears at L1.

**Established July 19, 2026 (Session 75). Invariant #348 added - count now 348.**

---

### **349. The L0 door-gate hides only the INVITATION -- an already-open covenant's close control is reachable at any level (theirs to close, #331)**

#331 = the covenant is the disciple's to open AND to close; the leader never can. The L1 door-gate (#341/#348) must therefore hide only the OPEN-invitation for L0, never strand a covenant already opened. MMT `renderGivingJourney` blanks the section only when `!cov && pipeline_level < 1`; if an open covenant exists it always renders (the 'open' view carries the close control), whatever the level. Symptom that forced this: a member who opted in while ungated dropped to L0, the whole section blanked, and she could never reach her own off-switch -- the covenant orphaned (invisible to her, visible to the leader; closed via one human-gated SQL). Deliberate asymmetry: the leader companions ACTIVE journeys (dormant-L0 hidden on MLT, #348), but the member always controls their OWN covenant (close reachable at any level).

**RULE:** gate the invitation door by level, never the close control -- an already-open covenant is always reachable by its owner (#331) regardless of `pipeline_level`.

**Established July 19, 2026 (Session 75). Invariant #349 added - count now 349.**

---

### **350. MLT giving affirmation is cumulative per-member -- an LCL affirms only rungs at/below each disciple's own level; MMT stays full aspiration**

In the MLT giving companion card a rung is affirmable only when `rung.level <= disciple.pipeline_level` (cumulative -- every rung up to and including their level). Higher rungs stay VISIBLE but render LOCKED (dimmed, dashed, "Opens at Level N", no onclick), with a defense-in-depth guard in `_gjAffirm` that refuses an above-level affirmation even if a locked row fires. Per-member: two disciples under one LCL gate independently by their own level (state carries `level` per companion; resolved from the same `lvlById` as #348). The member's own MMT view is UNCHANGED -- the full 6-rung path stays visible as aspiration (doctrine: visible from L1 onward, not unlocked rung-by-rung, GIVING_JOURNEY.md). Only the leader's *affirm* action is level-bounded.

**RULE:** MLT affirmation is cumulative-gated (`rung.level <= member.level`); above-level rungs show locked, never checkable; the member's aspiration view stays full.

**Established July 19, 2026 (Session 75). Invariant #350 added - count now 350.**

---

### **351. A catch-all "Others" reason requires its free-text before submitting -- and every reason-label map must learn the new code**

When a fixed-reason picker gains a catch-all ("Iba pa"/Others) sitting above a Detail free-text box, the catch-all must NOT submit on an empty box -- an empty "other" tells the pastor nothing. `_submitOther()` focuses the box and prompts when empty, submitting `reason_code='other'` only once there's text. Because the reasons fire `_submitCheckin(code)` immediately, the catch-all needs its OWN handler. And any new `reason_code` must be taught to EVERY map that renders it (`CHECKIN_LABELS` in `lcg_pulse_report.html`) or it silently falls back to a generic "Replied" pill.

**RULE:** a catch-all reason requires its detail box before submitting; add the new code to every reason-label map, not just the button.

**Established July 19, 2026 (Session 75). Invariant #351 added - count now 351.**

---

### **352. codeload / raw / `git show` are EOL-blind -- verify line endings via a clone + `git cat-file blob`**

GitHub's archive export (codeload tarball, `raw.githubusercontent`) applies `.gitattributes text eol=lf` normalization, so it shows LF even when the committed blob is CRLF -- a byte-for-byte codeload back-check CANNOT reveal a CRLF blob or verify an eol-only fix (this compounds #340: codeload is unreliable for BOTH staleness AND eol). `git show HEAD:<file>` ALSO applies the smudge filter and lies the same way; only `git cat-file blob <oid>` returns the raw stored bytes. To find/fix eol drift: `git clone` + `git ls-files --eol | grep i/crlf` to locate offenders, renormalize from the raw blob (`git cat-file blob HEAD:<f>` | replace CRLF->LF), prove content-identical via `git diff --cached --ignore-space-at-eol` (empty), and back-check the PR via clone + `git cat-file` (NOT codeload). One offender found + fixed this session: `lessons/btli101_xrw5fg/btli1_l3_participant.html` (561 CRLF lines, #3 restored).

**RULE:** eol-sensitive verification uses `git cat-file blob` (raw) via a clone; codeload and `git show` both normalize and will lie about CRLF.

**Established July 19, 2026 (Session 75). Invariant #352 added - count now 352.**

---

### **353. `pipeline_lessons` is the shared lesson catalog -- leader-readable (global OR own church), BTLI is `track='BTLI'`, dedup by overlay precedence**

The lessons catalog lives in `pipeline_lessons` (level, track, lesson_number, title_en/tl, aim, scripture_refs, outline_md, handout_md, leader_notes_md, published, church_id, ...). RLS `pipeline_lessons_tenant_select` (authenticated) = `church_id IS NULL OR church_id = auth_church_id()` -- a leader reads the GLOBAL catalog (church_id null) PLUS their own church's overlays (no new policy needed; `multiply_shared.js`/MD already query it directly). BTLI lessons carry `track='BTLI'` (capitalized; Pre-Pipeline is `'Usbong'`). A global base row and a church overlay can BOTH match a `level|lesson_number`, so dedup with overlay precedence (a church row beats its base twin) -- the same rule as `renderMltPathway` / the celebrate feed. As of S75 only `aim` + `scripture_refs` are populated for BTLI (11 published); `outline_md`/`leader_notes_md` are empty -- the LCG-weekly guide text lives only in the lesson HTML, not the catalog.

**RULE:** query the lesson catalog from `pipeline_lessons` (RLS-safe), filter `track='BTLI'` + `published`, and dedup catalog-vs-overlay by overlay precedence keyed on `level|lesson_number`.

**Established July 19, 2026 (Session 75). Invariant #353 added - count now 353.**

---

### **354. Meeting Prep source is generalized -- devotional | btli | custom, one source-agnostic prompt skeleton; non-Scripture material MUST be Scripture-anchored**

`lc_meeting_guides` gained `source_kind` ('devotional'|'btli'|'custom', default 'devotional', NOT NULL, CHECK) + `source_title` + `source_text` (migration 078); `devotional_id` is nullable. The BYO-AI two-guide prompt (RULES + timed 1-hour flow + EN/TL fences) is SOURCE-AGNOSTIC -- only the SOURCE block varies (`mpBuildPrompt` for a devotional's structured fields, `mpBuildPromptCustom` for free material). Because an article/story is NOT itself Scripture, the custom prompt MUST anchor the session in a NAMED Bible passage (the material illuminates the Word, never replaces it) -- a non-negotiable pastoral guardrail. BTLI is a convenience pre-fill of the custom path (seeds title+aim+scripture from the catalog #353, stamped `source_kind='btli'`); paste and `.txt`/`.md` upload (client-side FileReader, nothing sent to a server) feed the same custom path. Any "all guides for a leader" title lookup must treat any non-devotional `source_kind` (use `source_title`), not just 'custom'.

**RULE:** Meeting Prep sources share one prompt skeleton with a swappable SOURCE block; non-Scripture material must be Scripture-anchored; stamp `source_kind` and surface `source_title` for every non-devotional guide.

**Established July 19, 2026 (Session 75). Invariant #354 added - count now 354.**

---

### **355. Member delete in LCL hands is empty-only and server-guarded -- catalog-driven, telemetry-blind, and it lives in the database not the client**

`mlt_delete_empty_member(p_member_id uuid)` (migration 079, SECURITY DEFINER, `set search_path=public`) is the ONLY delete path an LCL gets. It does its OWN authorization via `auth_member_id()` (caller must be the target's `discipler_id`, or a platform admin, same church) and refuses anyone with ANY non-telemetry footprint. The guard is CATALOG-DRIVEN: it loops every live FK into `public.members` (via `pg_constraint`) and blocks if the member is referenced by any formation/record row -- so new tables auto-covered, the guard never silently rots, and it errs toward refusing. It IGNORES pure telemetry (fixed denylist: `view_log`, `leader_sessions`, `profile_tokens`, `notifications`, `announcement_acks`, `announcement_retraction_dismissals`, `prayer_list_opens`, `attendance_self_attest_log`) -- critical because merely OPENING the member detail writes a `view_log` row, so counting it would make delete impossible. It pre-clears the NO-ACTION/RESTRICT telemetry rows before deleting (else the DELETE FK-fails). Returns jsonb the client renders as a friendly message (`{ok:true,name}` or `{ok:false,reason:'has_history'|'not_your_member'|'cannot_delete_self'|...,blockers:[...]}`). `members` has 67 inbound FKs, 22 CASCADE -- a raw delete would silently erase pathway progress, assessments, giving covenants, so 49 LCLs never get a raw `members.delete()` (MD/pastor still does). UI: a danger button at the bottom of the member detail (own-LCL/Pastor, mirrors Reset PIN). Typos are fixed by the disciple self-renaming in MMT (`editField('name')` writes `members.name`), not by delete.

**RULE:** Destructive member ops in LCL hands are empty-only and server-guarded; the guard is catalog-driven over live FKs, treats telemetry as disposable (denylist) but every formation row as a hard block. Never hand many low-trust users a raw `members.delete()`.

**Established July 20, 2026 (Session 76). Invariant #355 added - count now 355.**

---

### **356. A feature documented in an invariant can be silently GONE from the code -- the doc is intent, not proof of presence; whole-file uploads drop code without a trace**

The MLT weekly attendance gate (`runWeeklyAttendanceGate`, Inv #100) was described as live in the invariants, yet had been ABSENT from `lc_leader_tool.html` for ~2 months -- silently dropped in a May-28-2026 "Add files via upload" whole-file commit (`d463aaa`) and never re-added. `git log -S` pinpointed the removal; the last-good copy was `10971c8`. This is #97 (handoff notes are hypotheses) applied to invariants themselves: an invariant records intent/design, NOT current code state. Before assuming a documented feature is live, GREP the deployed file for the actual function -- especially for anything predating the surgical-edit era. This is also WHY surgical BASE->WANT edits (#347) exist: whole-file uploads are exactly how code vanishes unnoticed. When restored, the gate was made attendance-ONLY -- the old "merged wall" also surfaced unread announcements, but the announcement inbox now owns that (accumulates as unread + badge), so the coupling was stripped.

**RULE:** An invariant documents a feature; it does not prove the feature is in the code. Grep the deployed file before trusting presence. Whole-file uploads silently drop code -- verify, don't assume.

**Established July 20, 2026 (Session 76). Invariant #356 added - count now 356.**

---

### **357. A new UI enum option must ship with its DB CHECK widen in the SAME change -- else the option renders but the DB rejects its value at submit (silent-until-submit)**

The S75 "Iba pa" check-in shipped the FRONTEND (button + `_submitCheckin('other')`) but never widened `lcg_checkins_reason_chk` (migration 054 allowed only 7 reason codes, not `'other'`) -- so every "Iba pa" submission failed with `violates check constraint`, on every device, for everyone. The user sees a working option that mysteriously "won't send" -- it looks like a bug (and NOT a cache/install issue; the opposite -- the user is on the NEW build). This is #290/#336 recurring: the frontend enum and the DB CHECK are ONE change, not two. Migration 080 widened the constraint (DROP + re-ADD with `'other'`). Diagnostic tell: a submit-time (not load-time) failure naming a `_chk`/`_check` constraint means the value the UI sends isn't in the constraint -- verify the CHECK DDL from the ORIGINATING migration (#290), not schema.json.

**RULE:** Ship a new UI enum option and its DB CHECK widen together. A rendered option whose value the DB rejects is a silent-until-submit failure; when a submit fails on a `_chk` constraint, the fix is the constraint, not the frontend.

**Established July 20, 2026 (Session 76). Invariant #357 added - count now 357.**

---

### **358. Do NOT transmit large payloads as base64 text through a CC prompt -- homoglyph/encoding corruption; deliver large blocks and whole files via sha-verified upload**

A ~20 KB base64 blob embedded in a CC patcher arrived CORRUPTED: 16 characters were Cyrillic homoglyphs of Latin base64 letters (U+0420 for `P`, U+0417 for `Z`/`3`, U+0434 for `g`/`d`) -- a clipboard/font/transmission artifact. base64 is ASCII-only, so `base64.b64decode` raised before any file write; CC correctly HALTED and refused to guess-substitute (the reversal is genuinely ambiguous -- U+0417 look-alikes BOTH `Z` and `3`). The clean path: deliver the finished WHOLE FILE via upload (UP-var proven by WANT sha #339), located BY its WANT sha (loop the uploads dir, match the sha -- impossible to grab the wrong file), with a BASE+WANT gate (#338). No base64 in the prompt = no corruption surface. Reserve base64-in-prompt for small ASCII-safe payloads.

**RULE:** Large payloads (blocks, whole files) go to CC via sha-verified file upload, located by the WANT sha, never as base64 text in the prompt. A corrupt payload must HALT, never be guess-repaired.

**Established July 20, 2026 (Session 76). Invariant #358 added - count now 358.**

---

### **359. `multiply-sw.js` is network-first for HTML/JS -- a CACHE_VERSION bump refreshes the OFFLINE shell and forces a clean purge; it is NOT how online users get fresh code**

The sole active service worker (`multiply-sw.js`, registered only by `index.html`, scope `./`; the per-tool `service-worker.js`/`service-worker-member.js` are retired kill-switch stubs) is NETWORK-FIRST for navigations + HTML + JS, cache-first only for immutable static assets. So an ONLINE user already gets the fresh deploy on next app open -- the cache is only an offline fallback. Bumping `CACHE_VERSION` (`v2-2026-07-17` -> `v3-2026-07-20`) forces the browser to install the new SW, whose `activate` deletes every non-current cache and `install` re-precaches the current SHELL_ASSETS -- refreshing the OFFLINE fallback and purging leftovers, with `skipWaiting()`+`clients.claim()` for prompt activation. Good hygiene after a deploy, but NOT why an online user does or doesn't see new code (if stubbornly stale, a full close+reopen is the sure fix). Corollary: if online users see stale HTML, suspect a networkFirst bug (e.g. a missed `Response.clone()` #310), not the cache version.

**RULE:** HTML/JS is network-first -- online users get fresh code on next open; a `CACHE_VERSION` bump refreshes the offline shell + forces a clean purge, it is not the online-freshness lever. Don't diagnose an online-staleness report by bumping the cache.

**Established July 20, 2026 (Session 76). Invariant #359 added - count now 359.**

---

### **360. Non-ASCII CC payloads ship as sha-verified UPLOADS, never inline in the prompt -- `\u` escapes flatten in transit**

The Giving Mirror patcher's modal HTML (em-dashes, the peso sign, the mirror emoji as `\u{1FA9E}`) was proven pure-ASCII AT SOURCE but delivered IN-PROMPT; CC's WANT gate HALTED on a 20-byte divergence (9554 vs 9534). Root cause: a display/paste layer between the message and the shell flattened the literal `\u2014`/`\u{1FA9E}` escape sequences into their glyphs, so the bytes diverged even though the code looked identical. Reshipped as a sha-verified UPLOAD (binary-faithful) -- landed on WANT exactly, first try. This extends #358 (which was base64-specific) to ANY escape-bearing or glyph-bearing payload. Counter-proof same session: the embed-viewer patcher used DOUBLE-backslash JS escapes (`\\u2039`) -- genuinely pure-ASCII -- and shipped IN-PROMPT cleanly.

**RULE:** If a CC payload contains non-ASCII glyphs OR single-backslash `\u`/`\U` escape sequences a paste layer can flatten, deliver it as a sha-verified UPLOAD located by its sha -- never inline. Only genuinely pure-ASCII payloads (incl. `\\u` double-backslash JS escapes) may go in-prompt.

**Established July 21, 2026 (Session 77). Invariant #360 added - count now 360.**

---

### **361. Uploaded files nest under a session subdir -- locate BY SHA with a recursive walk, not a flat glob**

The first Giving Mirror upload block used a flat glob (`/root/.claude/uploads/*.py`) and found nothing -- the environment nests uploads under a per-session subdirectory. CC independently hashed the file, confirmed it matched the expected sha, and only then proceeded; the durable fix is to WALK the tree. Every upload-locate since uses `os.walk('/root/.claude/uploads')` matching the target sha.

**RULE:** Locate an uploaded file by hashing candidates under a RECURSIVE `os.walk('/root/.claude/uploads')` for the target sha -- never a single-level glob. Verify the sha before use; HALT if not found. (Refines #339.)

**Established July 21, 2026 (Session 77). Invariant #361 added - count now 361.**

---

### **362. MMT has the embedded viewer too -- reuse it (?embed=1) for standalone in-app pages instead of window.open**

Ported the minimal `_openLessonViewerModal`/`_closeLessonViewer` (full-screen sandboxed iframe overlay + a back chevron) from MLT/MD into `member_tool.html` (S77 #217). A member-facing standalone page -- e.g. `family_huddle_card.html` -- now opens IN-APP via the viewer instead of `window.open(...,'_blank')`, which spawns a jarring new browser tab (worst in the installed PWA). The page opts in with `?embed=1` (a `body.embed` class it can style against). It is a STATIC-resource opener: no session/JWT needed, so `noopener`-style sessionStorage loss is irrelevant.

**RULE:** To open a standalone page inside MMT, use `_openLessonViewerModal(url?embed=1, label, hideNewTab=true)`, not `window.open`. All three tools (MD/MLT/MMT) now share this embed pattern.

**Established July 21, 2026 (Session 77). Invariant #362 added - count now 362.**

---

### **363. The Giving Mirror is on-device ONLY -- income in, percentage out, localStorage keyed by memberId; it writes NOTHING to the server**

The private giving calculator + one-page budget (S77 #213, on the MMT Giving Journey card, L1+, reachable before any covenant) takes income + giving, shows the real percentage against the 10% tithe milestone -- the ONLY fixed marker, because First Fruits/Proportional/Sacrificial are heart-moves the doctrine forbids enthroning as amounts -- and reveals margin. It persists ONLY to `localStorage` keyed by memberId, with a Clear button. ZERO server footprint: no Supabase write, no `giving_covenant` column, no rung tick, no `?v=` bump. It reports to no one and compares to no one (GIVING_JOURNEY.md Guardrail #5, Sources #2/#6).

**RULE:** The Giving Mirror never touches the network. Never wire it to Supabase, the covenant, or a rung -- a future "just sync the number" instinct is the finance-wall breach the doctrine exists to prevent. Keep it on-device.

**Established July 21, 2026 (Session 77). Invariant #363 added - count now 363.**

---

### **364. Batch attendance pickers + member-count labels filter status==='active' -- cohort_members carries withdrawn/graduated rows for the roster History**

`cohort_members` keeps withdrawn (`status='withdrew'`) and graduated (`'graduated'`) rows so the batch-roster modal can render its History section. The three attendance pickers (Gen. Purpose / BTLI / Usbong) and their dropdown member counts were reading the FULL `_members` list unfiltered, so withdrawn members reappeared in the attendance checklist and inflated the count (S77 #214, six sites). Fixed by adding the `status==='active'` filter the roster view and member-count already use elsewhere. Withdrawal is precisely how an LCL removes someone from attendance without logging absences, so the filter must hold.

**RULE:** Any attendance roster or batch member-count derived from `cohort_members._members` must `.filter(cm => cm.status === 'active')`. Withdrawn/graduated live in History, never in attendance.

**Established July 21, 2026 (Session 77). Invariant #364 added - count now 364.**

---

### **365. app_sessions is the single session logbook -- every login (member+leader), is_leader server-derived; leader_sessions is DROPPED**

The S78 telemetry rebuild replaced the leader-only `leader_sessions` with one `app_sessions` table (migration 081) that records EVERY login -- member and leader. Both Edge Functions (`auth-login`, `token-login`) insert a row on login; `logoutLeader` (`multiply_shared.js`) and the MD pin-reset close `ended_at` (keyed on `member_id`); `reap_expired_sessions()` closes expired-open rows. `is_leader` is stamped server-side from `pipeline_level >= 2`, never from a client field. Tenant RLS mirrors the old table; the EF writes via service role with an explicit `church_id`. Migration 082 dropped `leader_sessions` after re-backfilling late rows. schema.json: `leader_sessions` gone, `app_sessions` in, still 74 tables.

**RULE:** Session/login telemetry lives in `app_sessions` ONLY. `leader_sessions` no longer exists -- never reference it. A session writer stamps `member_id` + `is_leader` (from level) + explicit `church_id`.

**Established July 22, 2026 (Session 78). Invariant #365 added - count now 365.**

---

### **366. Leader-ness is server-derived (pipeline_level >= 2), never client-declared -- the body.stamp fiction is dead (#322 closed)**

`auth-login` used to trust `body.stamp === "leader"` -- a label the browser sent about itself, spoofable and fragile (it was the root of the phantom S71 "engagement collapse"). S78 removed it: the EF derives `isLeader = pipeline_level >= LEADER_MIN_LEVEL (2)` from the member row it already fetches (matching the `leader_login` picker + MLT's `leaderLevel>=2`). The legacy `stamp` field is now simply ignored, so old login pages keep working. This is the long-deferred #322 fix.

**RULE:** The server decides leader-ness from `pipeline_level`, never from client input. A frontend must never be trusted to declare a member's role or level -- the DB is the authority.

**Established July 22, 2026 (Session 78). Invariant #366 added - count now 366.**

---

### **367. reap_expired_sessions() reaps opportunistically on each login; ALL telemetry writes are best-effort -- login never depends on them**

`reap_expired_sessions()` (SECURITY DEFINER SQL fn, migration 081) sets `ended_at=now(), ended_reason='expired'` on any row past `expires_at` still open. Each login best-effort `rpc`s it -- no cron needed, self-cleaning, reusable by a future pg_cron. Every telemetry step (last-login update, `app_sessions` insert, reap) is wrapped in try/catch in BOTH EFs, so a telemetry failure NEVER blocks the login or token exchange. Expiry-reaping is the scalable close mechanism -- more reliable than depending on a logout event to fire (which historically never reaped, S71 #323).

**RULE:** Telemetry is best-effort and MUST never sit on the critical path of auth. Reap by expiry; don't rely solely on a logout-close firing.

**Established July 22, 2026 (Session 78). Invariant #367 added - count now 367.**

---

### **368. Lossless table replacement: a drop-migration RE-BACKFILLS inside the guard, immediately before DROP -- the live cutover is not atomic with the merge**

When retiring a table superseded by a new one across a STAGGERED deploy, the drop migration must re-run the null-safe backfill (dedup on the natural key, e.g. `member_id` + `created_at`) INSIDE the `to_regclass IS NOT NULL` guard, immediately before `DROP TABLE`. Migration 082 did this: any `leader_sessions` rows written by the OLD live EF between 081's backfill and the drop are carried into `app_sessions` first, so no history is lost even though the EF redeploy is a separate human step. Guarded => rerunnable no-op once gone; self-verifies `to_regclass IS NULL`.

**RULE:** A drop-migration for a replaced table re-backfills at drop time, never assuming the first backfill caught everything. The merge does not deploy the EF, so the cutover window can still write the old table.

**Established July 22, 2026 (Session 78). Invariant #368 added - count now 368.**

---

### **369. .js is network-first, so a ?v= bump ALONE delivers new shared.js code -- no CACHE_VERSION bump for a JS logic change (corollary #359)**

`multiply-sw.js` serves navigations + HTML + JS network-first (#359), so an online user fetches fresh `multiply_shared.js?v=N` on next open; bumping the `?v=` query busts the HTTP-layer cache too. Therefore a shared.js LOGIC change shipped via the `?v` lockstep (S78 #223: `?v=11->12` across 21 consumers) needs NO `CACHE_VERSION` bump. Reserve `CACHE_VERSION` bumps for refreshing the OFFLINE shell / precache list -- e.g. S78 #219 adding `family_huddle_card.html` to `SHELL_ASSETS` (v3->v4), which genuinely changes what is precached.

**RULE:** shared.js logic change => `?v` lockstep bump, no `CACHE_VERSION`. A `SHELL_ASSETS`/precache change => `CACHE_VERSION` bump. Two different levers; don't conflate them.

**Established July 22, 2026 (Session 78). Invariant #369 added - count now 369.**

---

### **370. A multi-file lockstep patcher self-gates on ONE combined sha over the whole change set (sorted name\0bytes\0), not N per-file shas**

For a 22-file change (shared.js logic + a 21-consumer `?v` lockstep, S78 #223) the patcher computes a single `combined_sha()` -- sha256 over each file's `name\0content\0` in sorted order -- and self-asserts `BASE_EXPECT` before writing and `WANT_EXPECT` after, plus per-anchor uniqueness (`count==1`) asserts. One gate covers the whole set; any drift on any file halts before commit. Pure-ASCII patcher, proven against a fresh codeload copy, `node --check` on the touched JS (#105).

**RULE:** Gate a multi-file surgical change with one combined-sha BASE+WANT over the sorted change set + per-anchor uniqueness. Cleaner and stricter than tracking N individual shas.

**Established July 22, 2026 (Session 78). Invariant #370 added - count now 370.**

---

### **371. An EF PR merge records SOURCE ONLY -- verify the LIVE function by watching app_sessions count tick on a login**

Merging an `auth-login`/`token-login` PR only records source in the repo; the LIVE function updates ONLY on a Supabase dashboard redeploy (Verify-JWT OFF). If the old code stays live after `leader_sessions` is dropped, its insert silently fails (best-effort) and telemetry goes inert while login still works -- an easy "merged but not deployed" trap. The definitive smoke test: `select count(*) from app_sessions` before, log in once, count after -- +1 == the new EF is live. S78 verified 3221 -> 3222.

**RULE:** After merging an EF change, redeploy it in the Supabase dashboard, THEN prove it live via the `app_sessions` count tick. Never assume a merge deployed an EF.

**Established July 22, 2026 (Session 78). Invariant #371 added - count now 371.**

---

### **372. Allow-all RLS stubs predating the S46 sweep leak cross-church (or to anon) -- audit pg_policies for qual/with_check = 'true'**

The S46 tenancy sweep tightened tables to `_tenant_*` policies on `church_id = auth_church_id()`, but EARLY-ERA tables kept their original permissive stubs and were MISSED: `svi_snapshots` had `svi_snapshots_read USING(true)` (every authenticated SVI report saw ALL churches -- the "301"), and `interventions` + `ministry_intake` each had ONLY `"Enable all for anon" (ALL, roles={anon}, USING/WITH CHECK true)` -- unauthenticated read+write of every church's rows. RLS was ENABLED on all three; the stub simply defeated it. The tell is the policy NAME (`_read`/`_write` / `Enable all for anon`, not `_tenant_*`). The definitive audit:
```sql
select p.tablename, p.policyname, p.cmd, p.roles::text, p.qual, p.with_check
from pg_policies p join information_schema.columns c
  on c.table_schema='public' and c.table_name=p.tablename and c.column_name='church_id'
where p.schemaname='public' and (p.qual='true' or p.with_check='true')
  and 'service_role' <> all(p.roles)
order by p.tablename, p.cmd;
```
Fix (085/086) = drop the stub, add the 4 church-scoped policies (SELECT / INSERT-with-check / UPDATE / DELETE `TO authenticated USING/WITH CHECK (church_id = public.auth_church_id())`). Service-role (the EF) bypasses RLS so compute is untouched. The whole surface tested clean (empty audit) only AFTER the fix.

**RULE:** RLS-enabled is not RLS-enforced. Periodically audit `pg_policies` for `qual='true' OR with_check='true'` on every `church_id` table (excluding service_role lanes); any hit is a live leak. Fix with the S46 `_tenant_*` pattern.

**Established July 22, 2026 (Session 79). Invariant #372 added - count now 372.**

---

### **373. The SVI compute is church-BLIND and historically excluded test members but NOT guests -- exclude is_external_user in BOTH member loads**

`compute-svi-weekly` scores every active member across ALL tenant churches on one schedule (each snapshot stamped `church_id`); the church scoping happens at READ time via RLS on `svi_snapshots` (#372/085). Both EF member loads filtered only `.or("is_test_member.is.null,is_test_member.eq.false")` -- so GUESTS (`is_external_user=true`) were scored and snapshotted, inflating the church count (Rosehill read 215 = 211 members + 4 guests). Reports elsewhere already exclude BOTH (Standing Rule #16); the SVI EF was the exception. Fix (S79g): add `.eq("is_external_user", false)` to BOTH loads (the scored-members query AND the allLite map).

**RULE:** Anything that scores or counts "members" excludes test AND guests. When a count looks high, check whether guests (`is_external_user`) slipped in -- and remember the SVI compute is platform-wide, scoped only by the read-side RLS.

**Established July 22, 2026 (Session 79). Invariant #373 added - count now 373.**

---

### **374. writeSnapshots UPSERTs on (member_id, week_start) and never deletes orphans -- dropping a member from the compute leaves their old snapshot**

`writeSnapshots` does `.upsert(batch, { onConflict: "member_id,week_start" })`. It only touches members that ARE in the current results; it never deletes rows for members no longer computed. So fixing the EF to exclude guests (#373) stops FUTURE guest snapshots but leaves the EXISTING ones -- the report count wouldn't drop until they age out. A one-time purge is required to drop it immediately: `DELETE FROM svi_snapshots s USING members m WHERE s.member_id=m.id AND (m.is_external_user OR m.is_test_member)` (migration 087, idempotent). The EF fix + the purge are BOTH needed: purge alone reverts on the next weekly compute if the EF isn't also redeployed.

**RULE:** An upsert-only writer never removes rows for entities it stops emitting. To make an exclusion visible NOW, pair the compute fix with a one-time DELETE of the orphaned rows -- and ship both (redeploy + purge) or the next run reverts it.

**Established July 22, 2026 (Session 79). Invariant #374 added - count now 374.**

---

### **375. pathway_progress.marked_by is uuid -- system/auto inserts use marked_by=NULL + note='auto:<key>', and stamp church_id explicitly**

`pathway_progress.marked_by` is a `uuid` (the LCL who affirmed a rung), NOT text -- so an auto-completion row can't stamp a `'auto'` sentinel there. The auto engine (084) writes `marked_by = NULL` and tags provenance in the `note` text column (`'auto:'||auto_source_key`), which cleanly distinguishes system rows from LCL marks (multiplication counts either). It also provides `church_id` EXPLICITLY from the source row (not the base rung, which is `church_id IS NULL`), so the `set_church_id_from_jwt` trigger -- which is NULL-guarded (`if new.church_id is null`) -- no-ops and never calls `auth_church_id()` in the JWT-less SECURITY DEFINER context.

**RULE:** For system-written rows on a church table, provide `church_id` explicitly (the NULL-guarded JWT trigger then no-ops) and carry provenance in a text/note column, never by overloading a typed FK/uuid column.

**Established July 22, 2026 (Session 79). Invariant #375 added - count now 375.**

---

### **376. Auto-completion stamps the REAL milestone date, never now() -- else a backfill floods every recency window**

`auto_complete_pathway_rungs()` derives completion dates from the source of truth: an assessment's earliest `date_taken`, a course's last passing `submitted_at`, the exact day a devotional streak reached N. It must NOT use `now()`: the one-time backfill inserts YEARS of historical completions at once, and stamping them "today" would flood the Multiplication metric's 90-day window and falsely spike every leader's recent movement. Real dates keep recency honest -- an assessment taken 6 months ago backfills dated 6 months ago and correctly does NOT count as recent multiplication.

**RULE:** When backfilling derived events, stamp each with the date it actually happened, never the backfill time -- any downstream "last N days" metric depends on it.

**Established July 22, 2026 (Session 79). Invariant #376 added - count now 376.**

---

### **377. The pathway auto-completion engine (084): 9 objective rungs tick themselves; character/fruit stay manual; runs at the top of the full weekly compute only**

`pathway_progress` was manual-only (LCL toggles), so a flock crushing BTLI + assessments read as almost no movement (multiplication 1/12). Migration 084 adds a SECURITY DEFINER `auto_complete_pathway_rungs()` that derives the 9 rungs tagged `completion_source='auto'` into `pathway_progress`, idempotent via `ON CONFLICT (church_id,member_id,level,rung_key)`: 5 assessments (a row in `gifts_diagnostic` / `diagnostic_results` / `member_profiles` by `profile_type`, where `conflict_style`->rung `conflict`); 2 all-lessons courses (passed EVERY active lesson, course matched by `lower(replace(course_code,' ',''))` = the `auto_source_key` token, BTLI + Usbong in separate quiz tables); 2 devotional streaks (N consecutive >=10-word days via gaps-and-islands). Base rungs only (v1). The 4 character/fruit rungs stay `manual` (human-witnessed -- formation, never auto-certified). The EF hook calls `supabase.rpc("auto_complete_pathway_rungs")` at the TOP of `runComputation` gated `!dry_run && !member_id` (the real full weekly run) so Multiplication always reads fresh completions; best-effort (logs, never blocks compute). Backfill took Gerry's multiplication 1/12 -> 11/12.

**RULE:** Derive objective, system-verifiable rungs (assessments, finished courses, streaks) from their source automatically; leave character/formation rungs to the shepherd. Hook the derivation ahead of any metric that reads the derived table.

**Established July 22, 2026 (Session 79). Invariant #377 added - count now 377.**

---

### **378. The Multiplication metric (Wave 5c, disciples_advancing) is a care-lens, special-cased like service_lc_led -- and only as honest as the marking beneath it**

`multiplication_disciples_advancing` (compute_type `disciples_advancing`, category `multiplication`, weight 0 until the pastor opts in per level L2+) is NOT a computeMetric dispatch case -- it's special-cased in `computeMemberSnapshot` (the `service_lc_led` precedent): for a leader, the fraction of THEIR disciples (grouped by `discipler_id`, guests excluded) who completed >=1 pathway rung in the 90d window. No disciples => `null` (n/a, `metricsTotal--`, never a penalty); disciples but none advancing => rate 0 => a gentle low score (a flag to notice, not punish). Stores `detail:{advanced,total}` so care-detail renders "N of M disciples advanced a rung" (a `rawMeaning` case in MD + MLT, lockstep). CRITICAL: it reads `pathway_progress`, so it only reflects what's MARKED -- which is exactly why the auto-completion engine (#377/084) is its prerequisite (it moved a real flock from a false 1/12 to a true 11/12).

**RULE:** A multiplication/advancement metric measures logged movement, not actual movement -- pair it with automatic rung derivation, and frame it as a care-lens (n/a for no-disciples, gentle flag for none-moving), never a KPI.

**Established July 22, 2026 (Session 79). Invariant #378 added - count now 378.**

---

### **379. Prove data-writing SQL (functions, DELETEs, policy DDL) on an ephemeral Postgres 16 before shipping**

For migrations that WRITE or DELETE data or add RLS policies (084 function, 085/086 policy DDL, 087 purge), spin up a throwaway PG16 in the sandbox and prove behavior + idempotency before the human runs it live. `initdb`/`pg_ctl` refuse to run as root -> run them as the `postgres` system user (uid 101) under a postgres-owned dir (`chown postgres:postgres /tmp/pgt`; `su postgres -c '...'`; socket `-k /tmp/pgt -c listen_addresses=""`). Recreate the minimal schema + boundary data (partial-course must NOT complete, 6-day streak must NOT hit devo-7, mixed-case course code must match, retake uses earliest date, allow-all stub -> scoped), run the migration, assert every boundary + a rerun == idempotent. 084 passed 10/10 asserts; 085/086/087 each proved the before/after policy or row state. Extends the S76 PG-proving habit (#355) to the whole data-writing surface.

**RULE:** Never hand a human a data-writing or policy migration you haven't executed against a real Postgres first. Ephemeral PG16 as the `postgres` user is cheap; assert boundaries + idempotency.

**Established July 22, 2026 (Session 79). Invariant #379 added - count now 379.**

---

### **380. The two quiz subsystems are now WIRED: quiz visibility flows through the single lesson access-grant resolver**

The BTLI + Usbong quiz journeys (keyed `course_code+lesson_number`) were a SEPARATE subsystem from the lesson library and NEVER read `pipeline_lesson_grants` -- both MMT renderers fetched every `is_active` quiz and drew a card for each, gating only LOCKED/OPEN state, never SEE. So the "Who can see this?" access setting never touched quiz cards (recurring "the quiz keeps coming back" symptom). PR-J wired them together: reuse the ONE grant resolver `MultiplyShared.lessons.fetchVisibleLessons({memberId,isPastor,isLeader})` (already called at MMT ~11756/11824), build a Set of accessible `lesson.id`, filter `quizzes` to those; fail-CLOSED on resolver error (empty set -> no cards). Unlock-sync preserved: `cohort_lesson_unlocks` (Model X, #84) untouched -- granted+unlocked still opens.

**RULE:** Quiz visibility == lesson access-grant. When two subsystems key off the same concept (a lesson), resolve visibility through ONE resolver, don't reimplement it. Fail closed.

**Established July 25, 2026 (Session 80). Invariant #380 added - count now 380.**

---

### **381. An active quiz MUST have a lesson_id -- the CHECK that makes grant-based visibility safe (090)**

Once quiz visibility keys on the quiz's `lesson_id` (#380), a NULL `lesson_id` on an active quiz would fail OPEN (no lesson to gate against). Migration 090 adds `CHECK (is_active=false OR lesson_id IS NOT NULL)` on BOTH `btli_quizzes` + `usbong_quizzes` (flat DROP-then-ADD; PG has no `ADD CONSTRAINT IF NOT EXISTS`). This closes #127's latent BTLI fail-open hole: a draft may be null, but the moment it goes active it must point at a lesson. PG16-proven 5/5 (block active-null, allow inactive draft, allow active-with-lesson, block flip-to-active-while-null, idempotent).

**RULE:** When visibility derives from a FK, constrain that FK non-null on the active state so the gate can never be bypassed by a null.

**Established July 25, 2026 (Session 80). Invariant #381 added - count now 381.**

---

### **382. The empty quiz panel must hide the SECTION, not just the list -- a blanked inner list leaves a ghost header**

Each MMT quiz renderer writes its section header into `wrap` (the section div carrying `margin-top:1.5rem`), then the empty branch blanked only the inner list (`btli/usbongQuizzesList`), leaving the dark header floating (a ghost). Once grant-visibility (#380) can legitimately yield zero quizzes, this shows constantly. Fix (PR-L): in the empty branch set `wrap.style.display='none'` AND `wrap.innerHTML=''` (display:none so the section's own top-margin doesn't leave a phantom gap); add a `wrap.style.display=''` re-show reset immediately before each header write so a re-render un-hides. Both curricula lockstep (#127).

**RULE:** To hide a section, hide the SECTION element (display:none), not just its contents -- and pair every hide with a re-show reset at the render entry point.

**Established July 25, 2026 (Session 80). Invariant #382 added - count now 382.**

---

### **383. Two views of the pathway: the poster shows ALL rungs; the member/leader tools show only trackable. Reference rungs are conversation, not checkbox.**

The Leadership Pipeline poster (`leadership_pipeline.html`, MD) shows EVERY published rung (ignores `trackable`). "My pathway" in MMT/MLT shows only `trackable!==false` rungs -- because those are completable steps. A `trackable=false` rung (the 167 reference rungs from #265) is lifelong/formational: a shepherd's conversation agenda, not a checkbox. PR-F was the bug this exposed: both progress bars (`renderPathway` MMT, `renderMltPathway` MLT) counted `published!==false` only, ignoring `trackable`, so of 210 published base rungs only ~37 trackable -> every bar divided ~5x too many (an L2 disciple showed 7/39, should be 7/7) since July 6. Fix: both filter `published!==false && trackable!==false && !(meta&&meta.track==='giving')` (giving already excluded #334). PR-K then surfaced the removed reference rungs as a COLLAPSED "Coaching notes" `<details>` panel per level (MLT + MMT), display-only, no onclick, with `description_en` as talking points.

**RULE:** Progress denominators count trackable rungs only. Reference rungs are pastoral conversation, surfaced (collapsed) but never counted. New poster rungs default trackable=true -> they shift live bars; know that when editing.

**Established July 25, 2026 (Session 80). Invariant #383 added - count now 383.**

---

### **384. Embed-mode `position:absolute` on .modal-overlay parks modals off-screen when scrolled**

The pipeline poster opens embedded in MD (`?embed=1`). Base `.modal-overlay` is `position:fixed;inset:0` (viewport-centered, works standalone), but the embed override (added to stop Samsung Internet iframe blanking) flips it to `position:absolute` -- which anchors the overlay to the TOP of the long scrolling poster document. Scroll down, click +Add/Customize, and `openRungForm` runs correctly and adds `.open`, but the form renders far above the scroll while `body overflow:hidden` freezes the page. Symptom: "buttons do nothing," console CLEAN, buttons render fine -- because the modal opened off-screen. Hits BOTH modals (edit form + read-only detail, same class). Fix (PR-M): `_pwPinOverlay(id)`/`_pwUnpinOverlay(id)` -- in embed mode, on open set `top=scrollY, height=100vh`; on close clear. No-op standalone (guarded on `<html class="embed">`), so the standalone page is byte-behavior unchanged and the Samsung fix stays intact.

**RULE:** "Dead buttons + clean console + embedded iframe" = a visibility failure, not a broken handler. Check whether a `position:absolute` overlay opened off-screen before touching the handler.

**Established July 25, 2026 (Session 80). Invariant #384 added - count now 384.**

---

### **385. auth_is_leader() reads EXACTLY is_facilitator -- so is_facilitator gates the meeting-guide library (069)**

`auth_is_leader()` (migration 069 line 15) is `SELECT COALESCE((SELECT is_facilitator FROM members WHERE id=auth_member_id()), false)`. It gates the `lcmg_select` church-library read branch. So a discipler with a flock but `is_facilitator=false` is not only badge-less/"unassigned" in MD (the discipler picker, announcement audience, roster-candidate set all key on `is_facilitator OR facilitator_role`) -- they are SERVER-SIDE locked out of the shared meeting-guide library. This is an access gate, not cosmetics.

**RULE:** is_facilitator is the single source of leader-ness that `auth_is_leader()` reads. Any change to who is/isn't a facilitator changes library access. Treat it as a security-relevant field.

**Established July 25, 2026 (Session 80). Invariant #385 added - count now 385.**

---

### **386. is_facilitator is DERIVED from pipeline_level (>=2), enforced by a trigger; L5 role=Pastor, L2-4=LC Leader (091)**

Doctrine (Pastor): advancing L1->L2 now requires disciples, so L2+ and "is a facilitator/leader" are the same thing -- couple them for good, in BOTH directions (fully derived). Migration 091: a `BEFORE INSERT OR UPDATE` trigger `members_derive_facilitator()` sets `is_facilitator := (pipeline_level>=2)`; when flagging on and role is empty, a level-aware default `facilitator_role` (`L5+`->'Pastor', `L2-4`->'LC Leader'); an existing non-empty role is NEVER overwritten. Enforced at the DB so every write path obeys it and it can't drift. Composes with the 050 privilege-guard (only L5 can change pipeline_level, so the coupling only fires on a pastor's edit -- no conflict). Backfill aligned all rows; PG16-proven 10/10. The diagnostic (below, #387) revealed 9 tenant PASTORS unflagged -> silently locked out of their own library (#385), all fixed. MD frontend (PR-N) hid the now-derived checkbox + stopped the save sending is_facilitator/facilitator_role; CAUGHT a regression -- `_canEditLc=_canManage && isFac` depended on the dead checkbox, so `isFac` was repointed to derive from the level field `#fl>=2` (mirrors the trigger) or the pastor would lose LC-Group-Name editing.

**RULE:** When two fields must stay coupled, enforce with a DB trigger (every write path), not per-form JS. When you hide a derived input, repoint anything that READ it to the same derivation.

**Established July 25, 2026 (Session 80). Invariant #386 added - count now 386.**

---

### **387. A cross-tenant backfill you can't behaviorally test -> prove it with a read-only diagnostic SELECT first**

You cannot log in as another church's member, so you cannot behaviorally test a data change on a tenant. The safe pattern (used for the is_facilitator derivation across all churches): run a READ-ONLY diagnostic SELECT that lists BOTH directions of the change -- "WILL FLAG ON" (L2+ gaining the flag) and "WILL UN-FLAG" (the sensitive reverse set) -- with church name and a fixture column, in the SQL editor (which runs as owner and sees all tenants). Review both lists with the Pastor BEFORE any write. The un-flag/removal side is the one to eyeball: empty or only fixtures = safe; a real person = a conversation, not a silent strip. Then the migration's self-verify SELECT proves the data criterion, and the already-proven code path (#385) gives the behavioral outcome by construction -- no login needed. (Here: WILL-FLAG-ON = 9 pastors + 2 real L2 + 1 fixture; WILL-UN-FLAG = empty. Clean.)

**RULE:** For a cross-tenant data change you can't test as the affected user, diagnostic-SELECT both directions first, review, then rely on structural proof (self-verify + a verified code path), not behavioral testing.

**Established July 25, 2026 (Session 80). Invariant #387 added - count now 387.**

---

### **388. MD is now on pathway_rungs: the member modal, the members-table Progress column, and the distribution tiles all read ONE church-wide cache**

The MD member-modal PIPELINE tab, the members-table Progress column, and the Pipeline-Distribution tiles all ran the LEGACY `checks` system (a hardcoded `PC[]` per-level list + an `m.checks` JSON blob keyed by literal checklist text) -- a SEPARATE ledger from `pathway_progress`. So the pastor's dashboard never saw LCL marks (the "0/24" blindness); MLT/MMT wrote pathway_progress, MD read checks. PR-O migrated all three onto `pathway_rungs`+`pathway_progress` via ONE church-wide cache (`_PW_RUNGS[level]={rung_key:resolved_row}` overlay-precedence; `_PW_PROG[member_id]=Set('level|rung_key')`) loaded once in `loadMembers` before `renderAll()` (so the synchronous table/tiles have data). Modal = full L0->L5, every trackable rung tappable (pastor marks any -- pathway_progress RLS 057 already allows `auth_level()>=5` to write any member), reference rungs in a collapsed panel. `_mdPwToggle` writes, updates the cache, re-renders all three so nothing drifts. Legacy `PC`/`rPCL`/`tCheck` now dead (left in place); `checks` column untouched.

**RULE:** When several surfaces show the same computed value, feed them from ONE cache/source, not parallel reimplementations -- and load the cache before the first synchronous render that needs it.

**Established July 25, 2026 (Session 80). Invariant #388 added - count now 388.**

---

### **389. Astral emoji as \\ud83d\\udcda surrogate pairs crash a Python UTF-8 write -- emit via String.fromCodePoint or full \\U escapes**

A pure-ASCII patcher that emits emoji by writing `\ud83d\udcda` (surrogate-pair escapes) in a Python string literal produces LONE SURROGATES -- Python does NOT auto-combine them, and `io.open(...,encoding='utf-8').write(s)` raises `UnicodeEncodeError: surrogates not allowed`. Two clean fixes: (a) emit the emoji in the OUTPUT JS via `String.fromCodePoint(0x1F4DA)` (keeps the patcher AND the output pure-ASCII; JS decodes at runtime); (b) if a literal is needed, use a single full codepoint escape `\U0001F4DA`. BMP escapes (`\u00b7`, `\u2500`) are fine either way -- only astral (>U+FFFF) pairs bite.

**RULE:** Never write astral emoji as `\udXXX\udXXX` pairs in a Python patcher. Emit them via `String.fromCodePoint()` in the output JS (best: keeps everything ASCII) or a full `\U` escape.

**Established July 25, 2026 (Session 80). Invariant #389 added - count now 389.**

---

### **390. Emit unicode as literal \\uXXXX text in the OUTPUT JS so the file stays pure-ASCII (JS decodes at runtime)**

To keep a generated .html/.js file pure-ASCII (transit-safe, #360/#361), emit non-ASCII as literal backslash-u TEXT in the output: a JS string `'\u00b7'` renders as the middot at runtime but the file bytes are pure ASCII. In a Python patcher this means the source must contain a DOUBLED backslash (`'\\u00b7'`) so Python writes the 6 characters `\u00b7`, not the decoded `\u00b7` char. This is the exact seam that caused PR-O's mismatches (#391): a patcher where Python DECODES the escape (real char in output) vs one that emits literal `\u` text (ASCII output) are DIFFERENT patchers with different output shas.

**RULE:** For pure-ASCII output, emit `\uXXXX` as literal text (doubled backslash in the Python source). Verify the OUTPUT file's added-non-ASCII delta is 0 against BASE, not just that the patcher parses.

**Established July 25, 2026 (Session 80). Invariant #390 added - count now 390.**

---

### **391. Hand-editing a patcher anchor at paste-time makes it a DIFFERENT patcher -- two clean-execution WANT mismatches = switch to upload, don't nudge**

PR-O mismatched WANT twice with ZERO anchor HALTs and a confirmed-identical BASE. Root cause: the canonical patcher's `CACHE_ANCHOR` was `"// -- PIPELINE CHECKLIST --\nfunction rPCL(m){\n"`, but when pasting the block inline I hand-simplified it to `"function rPCL(m){\n"` to avoid the box-drawing chars. Since the inserted block is placed BEFORE the anchor, dropping that comment line from the anchor shifted where the block landed relative to it -> different output bytes, same logic. Two clean-execution mismatches (Python is deterministic + BASE identical) is the signal the INLINE PAYLOAD differs from the canonical one in transit -- switch to a sha-verified UPLOAD located by a recursive sha walk (#339/#361), which CC verifies BEFORE running so corruption halts at the sha gate. CC held the line correctly (HALT, revert, don't nudge #338).

**RULE:** Any hand-edit to a proven patcher -- even a "cosmetic" anchor simplification -- invalidates its WANT. Two clean-execution WANT mismatches on a large inline payload = deliver as an upload located by sha, never keep re-pasting.

**Established July 25, 2026 (Session 80). Invariant #391 added - count now 391.**

---

### **392. A variable rename in a patcher must be grepped across the WHOLE enclosing function; a render-edit harness must EXECUTE the template, not just the helpers**

PR-O swapped `renderTable`'s compute line from `lc=PC[l]...` to `_pp=_pwProgress(...)` but a SECOND consumer 16 lines down (the Progress cell, `${done}/${lc.length}`) still read the old `lc` -> `ReferenceError: lc is not defined` on every row -> `renderTable`->`renderAll` threw -> EMPTY members table + all counts 0, with "Synced" GREEN because `sync('ok')` runs before `renderAll`. It sailed through the WANT gate + `node --check` + marker checks because it was a RUNTIME error, not a syntax error, and the harness tested the pure functions (`_pwProgress` etc.) 9/9 in ISOLATION -- it never rendered the `renderTable` template string, so the orphaned `lc` in the HTML was invisible. Caught in production; PR-P hotfix `${lc.length}`->`${_pp.total}` (one cell). The other `lc` refs were safe (dead `rPCL` self-defines its own `lc`; an unrelated notification `lc`).

**RULE:** When a patcher RENAMES a variable in a compute line, grep the ENTIRE enclosing function body for the OLD name before proving -- a second consumer downstream is invisible to the WANT/node/marker gates. For any edit to a render function, the harness must EXECUTE the template against a fake row and catch throws, not just unit-test the helper functions. Byte-exactness + valid syntax != it renders.

**Established July 25, 2026 (Session 80). Invariant #392 added - count now 392.**

---

### **393. An INSERT policy's WITH CHECK is applied to the PROPOSED row even when ON CONFLICT resolves to an UPDATE -- a rule that must tell "create" from "edit" belongs in a trigger that tests id-existence, not in the policy**

Hardening `members` INSERT (092), the level rule went into `members_insert_own_church` first: a non-pastor may create a member strictly below their own level. It rejected an L3 coach SAVING the L5 pastor's profile. MD saves members with `.upsert(l2r(m),{onConflict:'id'})`, and PostgreSQL evaluates the INSERT policy's WITH CHECK against the row PROPOSED for insertion even when the conflict path turns it into an UPDATE. Verified empirically on PG16: an L3 upserting an L2 row passed, the same L3 upserting the L5 row raised `new row violates row-level security policy`. Moving the rule into the BEFORE INSERT OR UPDATE trigger fixed it -- the trigger can ask `if new.id is not null and exists (select 1 from members m where m.id = new.id) then return new` and let the UPDATE branch govern a real edit; it also raises a readable message instead of the opaque RLS error.

**RULE:** Value rules with no false-positive risk (a column that must be false) can live in the policy. Any rule that depends on whether the write is a CREATE or an EDIT must live in a BEFORE trigger that tests whether the id already exists -- an INSERT policy cannot distinguish them, and every upsert call site will trip it. Prove the upsert path explicitly on PG16; a plain-INSERT test will not surface this.

**Established July 26, 2026 (Session 81). Invariant #393 added - count now 393.**

---

### **394. A column that grants a PLATFORM-wide capability must not be writable by any church-scoped role -- including the pastor**

Migration 050's guard returned early for `auth_level() >= 5`, so `is_platform_admin` was writable by any of the 12 tenant pastors. That flag is the ONLY gate on the `catalog-publish` Edge Function, which writes the BASE (`church_id IS NULL`) curriculum lane shared by every church -- so a per-church role held a platform-wide key, and a tenant pastor could have rewritten the shared catalog for everyone. Repo-wide grep confirmed no client ever WRITES the column (the only occurrences are `catalog-publish` READING it); migration 036 seeded it by direct SQL. 092 now blocks it in both walls: the INSERT policy requires `coalesce(is_platform_admin,false)=false`, and the trigger raises on any change while `auth_church_id()` is non-null, pastors included. Settable only with no JWT -- service-role or the SQL editor.

**RULE:** Before trusting a level check on a privilege column, ask what SCOPE the capability has. If the capability crosses tenants, no tenant-scoped JWT may set it at any level; gate it to the no-JWT path and grant it by human-run SQL. Audit the write paths by grep first -- if no client writes it, the lockdown costs nothing.

**Established July 26, 2026 (Session 81). Invariant #394 added - count now 394.**

---

### **395. A form that writes an OVERLAY row must carry every column of the base row it overrides -- not only the fields it displays**

`leadership_pipeline.html`'s `customizeBase()` built its overlay payload from the four fields the edit form shows: `{title_en, description_en, trackable, published, meta}`. The strings `completion_source`, `auto_source_key`, `title_tl` and `description_tl` appear ZERO times in that file. So the DB defaults applied -- `completion_source` became `'manual'`, `auto_source_key` became NULL -- and a pastor who merely RETITLED a rung silently disconnected it from the auto-completion engine. Two Rosehill rungs were damaged this way (L2 `conflict`, L2 `disc`); migration 093 restored them from their base rows and PR #253 made `customizeBase` carry the auto-wiring. The Tagalog columns had been silently lost too and were repaired, unknowingly, by migration 075's backfill in S70 -- exactly 5 Rosehill overlay rows, which is why nobody noticed the cause.

**RULE:** An overlay write is a COPY plus an edit, not an edit alone. Enumerate the base row's columns and carry every one the form does not explicitly change; a column the UI cannot see is exactly the column that will be lost. When adding a column to a catalog table, grep every overlay-write path before shipping.

**Established July 26, 2026 (Session 81). Invariant #395 added - count now 395.**

---

### **396. One bug can MASK another -- before fixing a defect, ask what is currently hiding its symptom**

Auto-completion v1 (084) joined base rungs only (`r.church_id IS NULL`) and never consulted a church's overlay. That was the known gap. But it was also the reason nobody noticed #395: because the engine ticked from the BASE definition, the two un-wired Rosehill rungs kept getting their checkmarks and members saw nothing wrong. Shipping the v2 resolver alone -- which honours the overlay -- would have turned the hidden defect into a visible REGRESSION: 131 existing completions would have kept a tick that new members could no longer earn. The correct order was editor fix -> data repair (093) -> resolver (094). Reading the editor before writing the cleanup also stopped a proposal to DELETE those 131 rows, which are legitimate completions -- those members really did take the assessments.

**RULE:** When a defect has been live for weeks and nobody reported it, find out WHY it was invisible before fixing it. The masking mechanism is usually a second defect, and removing the mask first turns a silent bug into a user-visible regression. Sequence: fix the source, repair the data, then unmask.

**Established July 26, 2026 (Session 81). Invariant #396 added - count now 396.**

---

### **397. A weight that is a BY-PRODUCT of how many items were written is not a decision -- declare it explicitly and guard the total**

The salvation assurance diagnostic summed raw section points, and its section maxima were simply the question counts times five: nine fruit of the Spirit made section C worth 45, six gospel questions made section A worth 10. So the GOSPEL carried 5.9% of a salvation diagnostic while spiritual habits and church integration carried 35.3%. Nobody chose that. It mattered because of how the instrument is administered: every respondent has already completed 10-16 weeks of one-on-one Usbong plus a weekly huddle, so the habit and community sections are high for nearly everyone -- they contributed points without contributing information and diluted the two sections that genuinely distinguish. Modelled effect of declared weights (A18/B12/C22/D18/E12/F9/G9, set with the Pastor): a genuine new believer moves Zone 2 -> Zone 1; a disciplined long-time member trusting his own goodness moves Zone 1 -> Zone 2, into the Assurance Formation track. Three other profiles unchanged.

**RULE:** If a score's balance falls out of item counts, it is an accident wearing the costume of a judgement. Declare the weights as data, normalise each section to its own percentage so adding questions cannot shift the balance, and add a guard that fails loudly when the weights stop totalling 100%. Then have the domain expert -- not the engineer -- approve the numbers.

**Established July 26, 2026 (Session 81). Invariant #397 added - count now 397.**

---

### **398. After changing a CALCULATION, inspect what the human READS -- add a render gate, not just a maths gate**

The reweighting (#397) passed BASE/WANT, `node --check`, a non-ASCII delta of 0, and a behavioural gate that executed the real scorer against five profiles and three edge cases: 6/6. It was still wrong on screen. The Overall Score card still printed the RAW fraction beside the newly weighted percentage, so it read `136/170` next to `71%` -- and 136/170 is 79%. Two counting systems side by side with no way to tell which was true. The Pastor caught it on his phone, not any gate. Fixed in PR #256: the card leads with the weighted percentage and labels the raw figure as raw points, plus a line explaining that only the 1-5 rating questions score at all (a respondent answering the first Section A items sees 0% because A1-A4 are open text and checkboxes).

**RULE:** Changing how a number is computed changes every label, denominator and fraction printed near it. After a scoring change, BUILD the rendered output for a real profile and assert on the text a human will read -- that the units are labelled, that no stale denominator survives, that a blank input reads sensibly. Byte-exact + syntactically valid + mathematically correct still is not "it reads correctly".

**Established July 26, 2026 (Session 81). Invariant #398 added - count now 398.**

---

### **399. At session open, cross-check `migrations/` in the repo against `schema_migrations` in the database**

Migration 093 was written, proven on PG16, run by the Pastor in Supabase with an 8/8 self-verify -- and then never committed. It sat applied-but-unrecorded for three turns while three other PRs went by, and CC compounded it by reporting "pairs with the already-merged migration 093" because the delivery block had been NAMED `CC_093_editor_fix.sh` (it carried the editor fix, not the migration). The database's ledger said 093; the repo's `migrations/` ended at 092. Anyone rebuilding from the repo would have got a different database from production. This is exactly the drift the S46 ledger (#212) exists to surface, and nothing was looking at it.

**RULE:** Add to the session-open ritual: list `migrations/` on `origin/main` and compare it against `SELECT version FROM schema_migrations ORDER BY version`. A version in the ledger with no file is an applied-but-uncommitted migration; a file with no ledger row is an unrun one. Also: name a delivery block after WHAT IT CARRIES, never after the migration it happens to accompany.

**Established July 26, 2026 (Session 81). Invariant #399 added - count now 399.**

---

### **400. A write path with no reader is a silent no-op -- when shipping an editor control, verify at least one consumer READS what it saves**

The pipeline poster has working reorder arrows: `actMove` -> `moveRung` -> `saveSectionOrder` writes `pathway_section_order.order_map`. But `member_tool.html`, `lc_leader_tool.html` and `multiply_dashboard.html` contain ZERO references to `pathway_section_order` -- all three sort by `sort_order` alone, and `moveRung` never touches `sort_order`. So reordering a rung changes the poster and NOTHING else; the disciple's Journey keeps the original order forever. One real instance exists (Rosehill, `0|book`, saved 2026-07-25). The original design was not careless -- `sort_order` lives on the row and base rungs are shared by all 12 churches, so writing it directly would reorder every church at once; `order_map` correctly solved tenancy and was simply wired to one consumer. A second limit surfaced with it: `order_map` is keyed `level|category` and the member's Journey is a FLAT list, so a per-category order cannot even express the intended sequence.

**RULE:** Shipping an editor control is not done when the write succeeds. Grep every consumer for the table or column it writes and confirm at least one READS it; if none do, the feature is a no-op that will accumulate silent divergence between what the author sees and what the user sees. Check the SHAPE too -- a grouped-by-category order cannot drive a flat list.

**Established July 26, 2026 (Session 81). Invariant #400 added - count now 400.**

---

### **401. `lpad` truncates -- a diagnostic that normalizes values for readability can destroy the evidence it was written to find**

The S82 pre-flight ledger check (#399) ran `string_agg(lpad(version,3,'0'))` so the text-sorted `version` column would sort numerically. The list came back clean: `001..077,083..094`. It was not clean. PostgreSQL's `lpad(string, length, fill)` does not only pad -- **if the string is already longer than `length` it TRUNCATES on the right.** Five rows stamped in S52-S56 stored the full migration NAME as the version (`052_devotionals_composite_unique`), and `lpad(...,3,'0')` rendered every one of them as a tidy three-digit number. The normalizer written to expose drift was the thing hiding it. A first repair (095) was then written against the normalized view and its Part A silently matched nothing, because the rows were not the shape the diagnostic had shown.

**RULE:** A drift diagnostic reads RAW first. Normalize only after the raw values are on the screen -- and when a check returns an unexpected count, suspect the lens before the data. For version-like text columns, dump `version`, `length(version)` and `encode(convert_to(version,'UTF8'),'hex')` together: hex renders invisible characters and unexpected lengths as numbers you cannot misread. This is #396 (ask what is MASKING it) turned back on our own tooling.

**Established July 27, 2026 (Session 82). Invariant #401 added - count now 401.**

---

### **402. A migration is finished when the LEDGER ROW exists, not when the DDL runs -- the stamp belongs in the migration body**

The same pre-flight found five migrations -- 078, 079, 080, 081, 082 -- present as files, applied in production (verified against `schema.json`: the `source_*` columns, `mlt_delete_empty_member`, `'other'` in `lcg_checkins_reason_chk`, `app_sessions` present, `leader_sessions` absent), and **absent from `schema_migrations` entirely.** Not a commit lag like #399 -- grep found ZERO mentions of `schema_migrations` in all five bodies. The stamp was never written. Every migration before and after them stamps correctly, so this was a stretch of sessions where the habit lapsed unnoticed for weeks.

**RULE:** Every migration body ends with its own `INSERT INTO public.schema_migrations ... ON CONFLICT (version) DO UPDATE`. A migration that runs without stamping is invisible to the #399 reconcile and will read as "never applied" forever. When backfilling a missed stamp, verify the effect is live in `schema.json` FIRST, and do not touch `applied_at` on conflict -- those rows ran weeks ago and the honest timestamp is unknown, not now.

**Established July 27, 2026 (Session 82). Invariant #402 added - count now 402.**

---

### **403. A self-verifying migration asserts only ITS OWN effects -- never a global total**

Both S82 ledger-repair migrations were first written with `CASE WHEN (SELECT count(*) FROM schema_migrations) = 94 ... THEN 'PASS'`. Correct on the day. Permanently wrong afterwards: every subsequent migration changes that total, so re-running 095 after 097 ships reports FAIL while nothing is broken. A migration that cries wolf on rerun destroys the value of the rerun-until-true habit (#210) -- the next person learns to ignore the verify block.

**RULE:** The self-verify block asserts the postconditions THIS migration is responsible for -- these rows now exist, this shape is now gone, this migration stamped itself -- and nothing else. Any assertion whose truth depends on work done by a later migration is a landmine. Corollary: if the committed file differs from what was executed ONLY in its verify block, say so in the header comment; the DML must still be byte-identical.

**Established July 27, 2026 (Session 82). Invariant #403 added - count now 403.**

---

### **404. RELOCATE, never swap -- a swap moves two items, and the second one is invisible to the person who clicked**

The poster's reorder arrows move a rung within its category group. When `order_map` was re-keyed flat per level (#400), the original swap logic was kept: exchange the two rung_keys' positions in the flat list. On the poster it looked perfect. An execution harness against a realistic L0 printed the flat list a MEMBER would see: moving `baptism` up one slot inside Ministry also flung `join-lc` from first to LAST, because a swap exchanges two flat positions and the two same-category neighbours can be far apart in the flat order. The pastor sees one rung move one notch; two rungs move on every member's phone. Changed to splice: lift the rung out, drop it beside its neighbour -- identical on the poster, and only the rung that was touched moves.

**RULE:** When an editor moves an item within a SUBSET of a larger ordered list, relocate it (`splice` out, `splice` in) rather than swapping with its neighbour. A swap is only safe when the visible list and the list of record are the same list. Corollary for review: whenever a control edits a projection of a bigger structure, render the BIGGER structure in the harness and assert on that -- the projection will look right either way.

**Established July 27, 2026 (Session 82). Invariant #404 added - count now 404.**

---

### **405. ONE resolver -- a ranking or precedence rule duplicated across surfaces will diverge, and that is what #400 already was**

Closing #400 put a flat-order resolver in `multiply_shared.js` and taught MMT/MLT/MD to call it -- but the first PR left `leadership_pipeline.html` carrying its own `_sectionComparator`, a second copy of the same rule. Two copies of a ranking rule is precisely the condition that produced #400 in the first place: the poster ordered one way, the tools another, for weeks. The duplicate was removed in the same arc and the poster now calls the shared resolver, passing its own already-loaded `SECTION_ORDER` so it does not re-query. Same shape as #380 (quiz visibility wired to ONE access-grant resolver) and #254 (`v_effective_auto_rungs`).

**RULE:** Precedence, ranking and visibility rules live in exactly one function. If a surface needs the rule with different inputs, pass the inputs -- never re-implement. When closing a divergence bug, grep for the rule you are centralising and confirm the count of implementations goes to one; leaving the original in place fixes the symptom and preserves the cause.

**Established July 27, 2026 (Session 82). Invariant #405 added - count now 405.**

---

### **406. A permission gate FAILS CLOSED -- reveal the control after the check passes, never hide it after the check fails**

The poster's Edit toggle was revealed by `if (isEditor){ ... display = '' }`, a synchronous level check. Restricting it to the platform admin during the template-review freeze required an async lookup of `is_platform_admin`. Written the obvious way -- show it, then hide it if the check fails -- a slow, failed or throwing query leaves the button live. Written the other way round, the button starts hidden in markup and is revealed ONLY after `is_platform_admin === true` comes back; every failure path (error, throw, no row, no session, no client) leaves the pipeline read-only. Strict equality matters too: `'true'` and `1` are truthy and must not unlock.

**RULE:** The default state of a gated control is DENIED, expressed in the markup, not in a branch that has to run. An async permission check may only ever ADD capability. Test the failure paths explicitly -- error, throw, null row, missing session, missing client, and truthy-but-not-true. And say in the comment whether the gate is UX or security: this one is UX, and RLS remains the real boundary.

**Established July 27, 2026 (Session 82). Invariant #406 added - count now 406.**

---

### **407. The throwaway diagnostic is where source-reading discipline slips -- three times in one session**

S82 produced three assertions from memory instead of from the source, all in checks that felt too small to verify. (1) The distribution of `sort_order` was explained from the poster's `nextSort()` formula -- correct for rungs added through the form, wrong for the hand-seeded spine, and the Pastor's data showed an explicitly authored 1-6 sequence with no ties at all. (2) "Gentleness appears nowhere in the pipeline" was asserted from a template dump that had been truncated mid-L3; gentleness is at L4. (3) A verification query used `members.full_name`, a column that does not exist -- `schema.json` says `name` -- breaking #223 in a one-off SELECT. None of the three was a hard problem; all three were skipped checks.

**RULE:** #223 has no size exemption. A column name, a function's edge-case behaviour, or a claim about "every level" gets read from `schema.json`, from the docs, or from the full dataset -- especially in a throwaway diagnostic, because that is exactly where the check feels disproportionate to the effort. When a dataset arrives in pieces, state the boundary of what has been seen before generalising across it, and compute distributions in code rather than eyeballing them.

**Established July 27, 2026 (Session 82). Invariant #407 added - count now 407.**

---

### **408. A constraint check that reads `unique_constraints` and stops has not checked**

`PATHWAY_FORK_DESIGN.md` section 7 claimed `pathway_rungs` had no unique constraint on `(church_id, level, rung_key)`, and that a double publish could duplicate a church's whole pipeline. It was wrong, and a migration was nearly written to close a gap that did not exist. The table carries no unique *constraints*, but two partial unique *indexes* -- `pathway_rungs_overlay_uk` and `pathway_rungs_base_uk` -- already covered both lanes completely. Worse, the proposed fix would have been actively harmful: a plain table `UNIQUE` treats NULLs as distinct, so it would have left the template lane unprotected while duplicating a rule that already existed, which is #405.

**RULE:** uniqueness in Postgres lives in `indexes` as often as in `unique_constraints`, and partial unique indexes never appear as constraints at all. Any claim that a uniqueness guarantee is missing must be checked against BOTH arrays of the table's `schema.json` entry, and confirmed live before a migration is written to add one.

**Established July 28, 2026 (Session 83). Invariant #408 added - count now 408.**

---

### **409. A check whose passing state is an empty result cannot be distinguished from a check that never ran**

The first 098 pre-flight put the duplicate-rung check in its own statement returning zero rows on success. The Pastor ran it and reported "success, no rows" -- which was indistinguishable from the block not having executed, and cost two round trips to resolve. The same shape recurred in a PG16 fixture whose error was redirected to `/dev/null`, silently dropping a test church and nearly being read as a diagnostic bug.

**RULE:** a diagnostic asserts counts, never absence. Every check emits a labelled row in every outcome -- `duplicate_count_expect_0 | 0` rather than an empty result set -- and multi-check pre-flights return ONE result set, because an editor that shows only the last statement turns a silent skip into a false all-clear.

**Established July 28, 2026 (Session 83). Invariant #409 added - count now 409.**

---

### **410. Reconcile a ledger by set difference, never by counting**

The S82 handoff recorded the ledger and `migrations/` agreeing at 97/97. Both numbers were wrong and agreed anyway: `001`-`097` reads as 97 slots, but `006` never existed on either side, so the true figure is 96/96. A set diff -- zero ledger rows without a file, zero files without a ledger row -- settled in one query what a matching pair of totals had hidden for a whole session. Counting also requires knowing WHAT to count: `migrations/` holds 113 `.sql` files, 17 of them `_rollback` / `_verify` / `_diagnostic` companions.

**RULE:** #399's reconcile is a `comm`-style set diff in both directions, printed. Two matching totals are not agreement; they are two numbers that happen to be equal.

**Established July 28, 2026 (Session 83). Invariant #410 added - count now 410.**

---

### **411. In a set-difference gate, the parentheses are load-bearing**

Migration 101's gate compared the auto-rung view before and after as `A EXCEPT ALL B UNION ALL B EXCEPT ALL A`. `EXCEPT` and `UNION` share precedence and associate left, so it parsed as `((A EXCEPT B) UNION B) EXCEPT A` -- which reconstructs A and subtracts it, returning 0 however much the sets differ. The gate passed on data where one tuple was genuinely missing. Isolated on a 3-row vs 2-row case: 0 unparenthesised, 1 parenthesised.

**RULE:** both arms of a symmetric difference are parenthesised explicitly, and the gate is proved by feeding it data it MUST reject before it is trusted on data it should accept.

**Established July 28, 2026 (Session 83). Invariant #411 added - count now 411.**

---

### **412. Never assert on `pg_views.definition` text without first reading how Postgres normalised it**

Migration 101's self-verify tested `definition LIKE '%IS NULL OR%'` to prove the old template arm was gone. Postgres stores the normalised form `((x.church_id IS NULL) OR (x.church_id = c.id))`, so that pattern matched NEITHER the old view nor the new one and the check was hardcoded to pass. `%LATERAL%` discriminates correctly: 1 for the old shape, 0 for the new.

**RULE:** catalog text is rewritten by the server. Any `LIKE` against `pg_views.definition`, `pg_get_functiondef` or a CHECK expression is first run against BOTH the shape it should match and the shape it should not, and only used once it has been seen to discriminate.

**Established July 28, 2026 (Session 83). Invariant #412 added - count now 412.**

---

### **413. A data migration's gate belongs inside its transaction**

Migration 099 forked 2,447 rows across twelve live churches. Its gate captured before-state to a TEMP table, performed the writes, recomputed from the new state and RAISEd on any difference -- all inside one `BEGIN`/`COMMIT`. Proved by breaking it on purpose: withholding one rung produced 12 differing pairs, raised, and rolled back 2,435 inserted rows, 12 versions and a cleared order map. A gate that reports afterwards can only name what has already been lost.

**RULE:** a migration that writes rows carries its own before/after comparison in-transaction and RAISEs, so a wrong result commits nothing. A follow-up verification query is a receipt, not a gate -- and the gate is proved by deliberately failing it before it is trusted.

**Established July 28, 2026 (Session 83). Invariant #413 added - count now 413.**

---

### **414. CC delivery blocks state the goal, never the tool**

Three blocks this session ended with a hard-coded `gh pr create` in an environment with no `gh`. Each exited 127 after the push -- harmless, because it landed after the commit and was not a gate, and CC correctly completed the PR through the GitHub MCP tool each time. But a delivery block should not contain a line guaranteed to fail.

**RULE:** the block pushes; the instruction says "then open the PR by whatever mechanism you have." Any step whose availability depends on the executing environment is expressed as an objective, not a command.

**Established July 28, 2026 (Session 83). Invariant #414 added - count now 414.**

---

### **415. A harness must lift from the file under test, by a path proved in the same run**

The Phase 3 follow-up was verified by a harness whose `patched` slice was lifted from `/tmp/p3run/member_tool.html` -- the PREVIOUS pass's output -- while the file actually being patched sat in a different directory. It reported 5/5 against code that no longer existed. What exposed it was removing `isLive` from the stub, which should have been a no-op and failed 4/5 instead; a `Proxy` on the stub proved something really was reading `.isLive`, and `patched.includes('isLive')` proved the lifted text disagreed with the file on disk.

**RULE:** a harness lifts from the file it is verifying, by a relative path resolved in the same working directory as the patch, and asserts that the lifted text contains the change it expects. A stub omits any capability the patched code must not depend on, so a surviving dependency throws rather than passing quietly.

**Established July 28, 2026 (Session 83). Invariant #415 added - count now 415.**

---

### **416. Enumerating a vocabulary by regex over one call site under-reports it**

Migration 102's validator was built on an `auto_source_key` vocabulary extracted by regex from `auto_complete_pathway_rungs()`. Two separate lesson arms -- one over `btli_quizzes`, one over `usbong_quizzes` -- share a single `LIKE 'lesson:%:all'` literal, so the pattern appeared once and was read as one arm. The validator therefore reported 13 legitimate Usbong rungs across all twelve churches as unrecognised, with total confidence, and a migration was drafted to set them all to manual -- which would have disabled auto-completion that had been working correctly. Only the Pastor's curriculum knowledge ("there is no Usbong 1") prompted the second look that surfaced `usbong_quizzes` and `usbong_quiz_attempts`.

**RULE:** a vocabulary is enumerated from the CONSUMERS of each pattern, not from the pattern literals. Before a validator is trusted to report something as invalid, it is run against every known-good value in production and required to return zero findings; a non-zero count is treated as a defect in the validator until the data is proved guilty.

**Established July 28, 2026 (Session 83). Invariant #416 added - count now 416.**

---

### **417. Do not add an API to a lockstep-versioned shared module to deliver a one-line predicate**

Phase 3 added `pathwayOrder.isLive(r)` to `multiply_shared.js`, which 22 consumers pin as `?v=14`, without bumping it (#138). A client holding the old module while running the new HTML would have hit `isLive is not a function` and the pathway would not have rendered; the service worker `CACHE_VERSION` bump covers the installed PWA but not a plain tab or a slow-to-activate worker. CC caught it before merge. The fix was not the 22-file `?v=` bump but removing the dependency: `!r.retired_at` inline, which one of the three files was already doing.

**RULE:** touching a lockstep-versioned shared module obligates the full `?v=` bump across every consumer. Before accepting that cost, ask whether the shared home is earning it -- a single field test is not a rule that can drift, and duplicating it in three files is cheaper and safer than versioning the whole platform to deliver it.

**Established July 28, 2026 (Session 83). Invariant #417 added - count now 417.**

---

### **418. A rename survey scans every text and JSON column, not the ones you can name**

The `Usbong 1` -> `Usbong` rename was scoped from curriculum knowledge as four surfaces: `usbong_quizzes.course_code`, the rung keys, the progress rows and the published docs. The real answer was **fifteen columns across ten tables**. Grepping the frontend found the attendance coupling; reading the eligibility helper found `cohort_programs.usbong_course_code`, compared with strict equality and named nothing like `course_code`; and a scan of every text and jsonb column in the database found `pathway_rungs.title_tl`, `pathway_progress.note`, `cohorts.name`, `pipeline_lessons.aim`, `usbong_quizzes.intro_text` and `outro_pass_text`. Four of the fifteen were invisible to any amount of code-reading. Had the four-item scope shipped, 233 attendance rows would have stopped matching their patterns and every member would have silently lost the attendance path to Usbong eligibility -- no error, no log line.

**RULE:** before renaming any identifier that lives in data, enumerate the surfaces by scanning **every** `text`/`varchar`/`json`/`jsonb` column of every base table for the old value, and read the actual VALUES before classifying any of them. Reasoning about which columns "would" hold it is how four of fifteen get missed.

**Established July 28, 2026 (Session 84). Invariant #418 added - count now 418.**

---

### **419. A patcher asserts post-conditions on its OUTPUT, not merely that its edit matched once**

While adding a tombstone guard to `publish_pathway_version`, a patcher replaced a `WHERE` block that ended in the retire arm's `NOT EXISTS (... pathway_version_items ...)` predicate and did not put the predicate back. The edit matched **exactly once**, applied cleanly, produced valid SQL, and passed every static check. The resulting function retired every live rung in the church on any publish -- across twelve churches, one transaction. The migration's own self-verify still read `PASS`. It was caught only by executing publish against a fixture and reading `retired = 4` where `0` was predicted.

**RULE:** "matched exactly once" proves the edit was unambiguous, never that the result is correct. A patcher ends by asserting the SHAPE of what it produced -- the clauses that must still be present, and their counts -- and any patch to executable logic is then RUN, with a value predicted in advance and compared.

**Established July 28, 2026 (Session 84). Invariant #419 added - count now 419.**

---

### **420. A gate that recomputes a predicate does not verify the code that uses it**

Migration 104's self-verify computes `would_retire` by writing the retire arm's predicate out a second time in plain SQL. When the function's own retire arm lost its predicate (#419), the self-verify still reported `PASS`, because it was measuring its own copy of the rule against the data -- never the function. The two agreed about the world and disagreed about the code, which is exactly the blind spot the gate existed to cover.

**RULE:** a verification that re-derives a rule tests the DATA, not the CODE. Where a gate must restate a rule independently (which is right -- a check that calls the thing it checks proves nothing, #415), pair it with at least one gate that INVOKES the real code path and compares against a predicted value. Independent restatement and live invocation catch different failures and neither substitutes for the other.

**Established July 28, 2026 (Session 84). Invariant #420 added - count now 420.**

---

### **421. Rename keys and live labels; never rewrite delivered messages or audit logs**

The Usbong scan surfaced eighteen columns holding the old name. Fifteen were renamed and three deliberately were not: `notifications.body` and `notifications.payload` (messages already delivered and read -- rewriting them makes the record disagree with what the member actually received) and `attendance_self_attest_log.meta` (an append-only audit log; `member_tool.html` only ever INSERTs to it and nothing matches on it, so a stale string breaks nothing while an edited audit trail defeats the purpose of having one). The line is not "historical vs current": `attendance.event_name` is historical and WAS renamed, because eligibility matching reads it -- it is a functional key. `pathway_progress.note` looked like a leader's prose and was nearly left alone until its values were read: all four were the machine-written provenance `auto:lesson:usbong1:all`.

**RULE:** rename a string where it is USED -- keys, matching patterns, live labels. Leave it where it is REMEMBERED -- delivered messages, audit logs, anyone's record of a past moment. Decide by reading the values, not the column name, and have the migration PIN the leave-behinds at their exact counts so what was left is provable rather than merely claimed.

**Established July 28, 2026 (Session 84). Invariant #421 added - count now 421.**

---

### **422. An exact-count pre-gate needs a three-state form to stay rerun-safe**

Migration 103 gated on the surveyed row counts of fifteen surfaces, which is the right strength -- a drift means the survey is stale and the migration must not run. But it also made the migration one-shot: a second run found zeroes everywhere and aborted, violating rerun-until-true (#242 and the standing rerun discipline). Loosening the gate to tolerate zero would have destroyed it, since a HALF-applied state also shows zeroes on some surfaces.

**RULE:** an exact-count pre-gate over N surfaces resolves three ways, not two. All N at the surveyed count = pending, proceed. All N at zero = already applied; say so, let the statements no-op, and let the post-gates re-verify. Anything MIXED = abort loudly and name the offenders, because mixed is the state a half-applied run or a genuine drift produces and it is the only one that must never be papered over.

**Established July 28, 2026 (Session 84). Invariant #422 added - count now 422.**

---

### **423. One order of record per mode, or the interface lies twice**

Slice C put the pathway editor into draft mode while the wall kept rendering published rows. The wall's reorder arrows write `order_map`; publish CLEARS `order_map` because `sort_order` is the order of record. So while a draft was open, every arrow press looked correct -- `pathwayOrder.sort` reads the map first -- and would be silently discarded at publish. The same shape appeared twice more the same day: a flat-view toggle label written in two places drifted out of step with the class it described, and a draft rung count written once at open never moved again while the document changed underneath it.

**RULE:** when a surface has two modes, each mode has exactly ONE store that owns a given fact, and every affordance in that mode writes to that store or is removed. Derived display -- labels, counts, positions -- is re-derived from state on every render, never written at the sites that change state. A control that writes to the store the current mode does not own must be disabled, not left hopeful.

**Established July 31, 2026 (Session 85). Invariant #423 added - count now 423.**

---

### **424. The document owns structure and text; the live row owns `meta`**

`publish_pathway_version()` upserts title, description, category, `completion_source`, `auto_source_key` and `trackable` from the version document, and deliberately never reads or writes `meta` -- which carries system flags like the giving-track marker. Relocating the AI research feature into the draft editor unchanged would have written its summary to `description_en` on the live row, where the next publish reverts it. The feature would have appeared to work and quietly lost every summary.

**RULE:** where two writers touch one row, name the owner of each field and split the write accordingly. `meta` is the one field publish does not own, which is precisely why a direct write to it is safe and a direct write to anything else is not. Prove the split with a harness that asserts neither field crosses.

**Established July 31, 2026 (Session 85). Invariant #424 added - count now 424.**

---

### **425. A post-condition asserts a DELTA from BASE, never a magic count**

Eight times in one session a patcher post-condition failed on a number I had guessed rather than measured: `BASE_KEYS` was 6 not 4, `flat-cell` 8 not 3, `AUTO_OPTS` 7 not 5, `db.from('pathway_rungs')` 12 not 4. Each failure cost a round trip and none indicated a defect in the patch. One assertion counted the substring `foot`, which matched inside unrelated words. The worst carried the comment "see note" -- a guess wearing an explanation.

**RULE:** a post-condition either counts a token distinctive enough to mean one thing, or -- far better -- captures the count at BASE and asserts the DELTA: `eq(src.count(X), BASE_X + 1, 'exactly one new call site')`. The delta form states the invariant the edit is actually claiming, survives unrelated growth in the file, and cannot rot.

**Established July 31, 2026 (Session 85). Invariant #425 added - count now 425.**

---

### **426. A commit may describe what it defers; it must not name the slice that will close it**

Slice D1 shipped a disclosed gap and its commit message said "D2 closes it." D2 was rescoped mid-session for a good reason -- closing the gap would have taken the research path down with it -- and the gap closed in D3. The code was right at every step; the permanent record was wrong, and the conversation that justified the rescope does not survive into the repo. CC flagged it from the repo alone, which is exactly who gets misled.

**RULE:** a commit may state what it defers and why. It may not name the future slice, PR or session that will close it, because the deferral outlives the plan and a commit cannot be corrected once merged. Describe the debt, not the repayment date.

**Established July 31, 2026 (Session 85). Invariant #426 added - count now 426.**

---

### **427. A gate measures the change it gates, not everything around it**

Migration 105's effect gate ran `auto_complete_pathway_rungs()` and demanded 0. It failed in production -- correctly, on data that was fine. The engine runs seven arms; six predate 105 and had a genuine backlog waiting, so one legitimate completion was written that had nothing to do with the new arm. The migration rolled back cleanly and nothing was harmed, but the gate had asserted a claim that was never 105's to make.

**RULE:** a gate isolates its own effect. Count the thing the change produces -- here, rows whose `note` carries the new arm's prefix -- before and after, and assert on that difference. Report the surrounding activity rather than suppressing it or forbidding it. "My change did nothing" and "nothing happened" are different claims, and only the first belongs to the change.

**Established July 31, 2026 (Session 85). Invariant #427 added - count now 427.**

---

### **428. A proving environment cleaner than production proves less than it appears to**

Migration 105 ran green on a scratch PostgreSQL built from a minimal schema, then failed its own gate on the live database. The scratch DB had no backlog, so the flawed assumption held there. The gate was correct; the proving ground was too tidy to refute it.

**RULE:** a scratch database proves syntax, structure and logic. It does not prove assumptions about ACCUMULATED STATE -- backlogs, partially-applied history, rows nobody has looked at in months. Where a check depends on what production has been doing while nobody watched, seed the scratch environment with that condition deliberately, or accept that the gate inside the transaction is the real proof and design it to fail safely.

**Established July 31, 2026 (Session 85). Invariant #428 added - count now 428.**

---

### **429. A defect uniform across everything you measured indicts the measurement first**

Reviewing PR #283 I audited a 21-slide deck and reported 19 slides misordered. Every original slide was shifted by exactly the number of inserted slides -- a pattern too uniform to be authoring error. PowerPoint stores running order in `presentation.xml`'s `<p:sldIdLst>`, not in slide part filenames; a slide inserted third is still `slide17.xml` on disk. The deck was entirely correct and I had nearly sent it back.

**RULE:** when a check condemns nearly everything it looked at, and the failures share one shape, suspect the instrument before the subject. Re-derive the measurement from the format's own source of truth and re-run before reporting. A reviewer's false alarm costs trust in every real finding that follows.

**Established July 31, 2026 (Session 85). Invariant #429 added - count now 429.**

---

### **430. A harness proves the logic you wrote; only the schema proves the contract you assumed**

Slice F is a thin client over two server RPCs. Its harness passed 8/8 on the summary and gate logic while proving nothing about whether `p_version_id` was the real parameter name or whether `version`/`upserted`/`retired` were real return columns. A named-parameter mismatch would have thrown at runtime with every gate green.

**RULE:** where code calls something it does not own -- an RPC, a table, a view, a library -- the harness is necessary and not sufficient. Read the declaration and check the call against it: parameter names, return columns, single-row vs set, and whether the client unwraps correctly. The harness covers what you wrote; the schema covers what you assumed.

**Established July 31, 2026 (Session 85). Invariant #430 added - count now 430.**

---

### **431. A lesson deck's running order is `sldIdLst`, and every build asserts printed number == deck position**

Facilitators run BTLI classes from the slides alone, so each slide carries a printed "N / total". When questions are inserted into an existing deck those two can drift, and the facilitator discovers it in front of the class. The audit that checks this must read `ppt/presentation.xml`'s `<p:sldIdLst>` resolved through `ppt/_rels/presentation.xml.rels` -- never the slide part filenames (#429). Run canonically across all eleven decks, it passed eight and found three (L5, L6, L11) carrying no running number at all, so their order cannot be verified by any means.

**RULE:** every deck build ends by walking slides in `sldIdLst` order and asserting each printed running number equals its position, via `tools/check_slide_order.py`. A deck with no running numbers FAILS as unverifiable rather than passing silently. This applies to decks already in the repo and to L12-L20 as they are written.

**Established July 31, 2026 (Session 85). Invariant #431 added - count now 431.**

---

*"A student who is fully trained will be like their teacher." — Luke 6:40*
