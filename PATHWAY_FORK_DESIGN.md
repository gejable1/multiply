# Pathway Fork Model — Design Shape

**Status:** draft for Pastor Gerry's approval. No code written yet.
**Decided:** retire never delete · notification + opt-in adoption · pastor-edited · all six added recommendations approved · one published pipeline per church · draft is the pastor's desk alone · retired rungs stay visible to members who completed them.

---

## 1. The shift, in one paragraph

Today all twelve churches read **one shared pipeline** (`pathway_rungs` rows with `church_id IS NULL`) and may paste small **overlay patches** over individual rungs. Overlays are the source of the Session 81 defect: an overlay had to carry every base column, and when the form only wrote four of them the rung silently un-wired.

The new model: the shared rows become a **read-only template and repository**. Each church holds an **owned copy** — its real pipeline. No pairing, no precedence, no partial rows. A rung either is in your pipeline or it isn't.

---

## 2. Two things already work in our favour

Worth stating plainly, because they mean this is far less risky than it sounds.

**The RLS is already exactly right.** No policy changes needed on the church lane:

| Action | Existing rule |
|---|---|
| SELECT | `church_id IS NULL` (template) **OR** own church |
| INSERT / UPDATE / DELETE | own church **AND** `auth_level() >= 5` |

A church already *cannot* write to the template, and only a pastor can write its own rows. Requirements 1, 2 and decision 3 are satisfied by the database as it stands.

**Completion history is already decoupled from rung rows.** `pathway_progress` is keyed by `(church_id, member_id, level, rung_key)` — a **text key**, not a foreign key to a rung. And nothing anywhere in the 76-table schema references `pathway_rungs.id`.

This is the single most important fact in the design. It means rung rows can be rebuilt freely and **no member ever loses a completion**. Retire-not-delete becomes cheap rather than delicate.

---

## 3. Core structure: the pipeline is a versioned document

A church's pipeline is authored as a **JSON document**, and publishing renders that document into the live tables the tools already read.

```
pathway_versions                 <-- NEW: the authoring surface
  church_id, version_no, status ('draft' | 'published' | 'archived'),
  doc jsonb, note, created_by, published_at

         |  publish (one transaction)
         v

pathway_rungs (church rows)      <-- unchanged shape, regenerated on publish
pathway_section_order            <-- unchanged, flat order written from the doc
```

**Why a document rather than editing live rows.**

- **Draft/publish falls out for free.** The draft is a row nobody reads. Members keep seeing the published pipeline while you spend three evenings rethinking L0.
- **Snapshots and undo fall out for free.** Every publish leaves its version behind. "Restore last Tuesday" = load that doc as a new draft and publish it.
- **Every existing reader keeps working untouched.** MMT, MLT, MD and the poster read `pathway_rungs` and `pathway_section_order` exactly as they do now — including the flat-order resolver we merged this session. Zero rework of the read side.
- **The sanity check has something to check.** Validation runs against the doc before publish, not against half-saved live rows.

**Publish is a regeneration, not a diff.** For that church: mark absent rungs retired, upsert present ones, write the flat order, archive the previous version, all in one transaction. Safe precisely because nothing references rung `id`.

---

## 4. Your seven requirements

| # | Requirement | How |
|---|---|---|
| 1 | Template for all churches | Existing `church_id IS NULL` rows. Already read-only to tenants. |
| 2 | Can't edit template; save a copy | "Create my pipeline" forks the template into `pathway_versions` as draft v1. |
| 3 | The copy becomes the pipeline | Once a church has a published version, the tools read **only** its own rows. Overlay resolution retires. |
| 4 | Delete the copy, start over | "Start over" archives the current version and opens a fresh draft — from template, or empty. Nothing is destroyed; history intact. |
| 5 | Trackable items: manual tick or autocomplete | `completion_source` and `auto_source_key` **already exist** on the table. This is a form change — expose them — not an architecture change. |
| 6 | Build from scratch, add from repository | Empty draft = levels only. An "Add from library" picker pulls any template rung in. Same picker serves both paths. |
| 7 | Flat view for reordering | The flat order is already the order of record as of this session. The flat view is a draft-mode editing surface writing `doc.order[level]`. |

---

## 5. The six additions you approved

**Draft & publish.** Covered above — it is the backbone, not a feature.

**Warning before removing anything with history.** On retire: *"9 members have completed this. Retiring keeps their record and removes it from the pathway."* Count comes straight from `pathway_progress` by `rung_key`.

**Snapshots & undo.** Version list with date, author and note. Restore any prior version.

**Pre-publish sanity check.** Blocks publish on: a level with no trackable rung; an auto-complete rung with no `auto_source_key`; an `auto_source_key` matching nothing real; a duplicate `rung_key` within a level; an orphaned flat-order entry. Warns (does not block) on: a retired rung with completions; a level with nothing at all.

**Lean starter template.** A second template flavour — a handful of rungs per level. Chosen at fork time. A 25-person church plant will abandon a thirty-item L0.

**Print & share.** Publish produces a printable sheet and a read-only link. The wall is the point.

---

## 6. Template updates — notification with opt-in

Your decision, and the right one given Rosehill's own pipeline isn't finished yet.

Each version records which template generation it forked from. When the template gains rungs, a church sees a quiet badge: **"3 new items available in the template."** Opening it lists them with a per-item **Add** — no bulk apply, no auto-adoption, no nagging. Declining is permanent until you ask again.

Template edits to rungs a church already owns are **never** pushed. Once it's yours, it's yours.

---

## 7. One schema gap to close

`pathway_rungs` has **no unique constraint** on `(church_id, level, rung_key)`. Under the current overlay model that was survivable. Under forking, a publish that runs twice could duplicate a church's whole pipeline. This gets added before any fork code ships.

---

## 8. Migration: quiet first, keys after

Twelve churches are live right now. Nothing may break mid-flight.

1. **Add the tables and the constraint.** Nothing reads them yet.
2. **Fork every church invisibly.** Compute each church's *effective* pipeline exactly as its members see it today — base rows plus its overlays — and write that as published v1. Every church keeps precisely what it has. Nobody notices.
3. **Switch the readers** to own-rows-only. Verifiable: the rendered pathway must be identical before and after, per level, per church.
4. **Ship the editor** — draft mode, flat view, library picker, retire warnings, sanity check.
5. **Ship the extras** — versions/undo, template notifications, lean starter, print/share.

Steps 1–3 are invisible plumbing. The pastor sees nothing change until step 4, when the keys are handed over.

---

## 9. Answered

1. **One published pipeline per church.** No congregation-level splits. If that changes later it is a new arc, not a retrofit.
2. **Draft is the pastor's desk.** LCLs and members see only what is published.
3. **A retired rung stays visible to the member who completed it.** It is part of their story.

### 9a. The consequence of (3), and one decision it forces

Answer 3 is the only one that reaches into code we already shipped. Two rules follow:

- **Retirement is a marker, not a deletion.** A new `retired_at` column on `pathway_rungs`. `published` keeps its current meaning (draft visibility); `retired_at` means "no longer part of the pathway, but real."
- **The pathway query grows a second arm.** Today: published rungs at this level. After: published rungs, **plus** retired rungs this member has a completion for.

**The decision this forces: what happens to the count?**

If a retired-but-completed rung counted in both numerator and denominator, two members at the same level would be measured against different pipelines. If it counted in the numerator only, you would see `7/6`.

**Recommended rule:** the denominator is **today's published trackable rungs**. A retired completion shows as a completed item marked *retired*, sitting outside the count.

So progress answers "where are you against the pipeline as it stands," while the pathway still shows everything they have actually done. Say the word if you would rather it counted.

---

## 10. Build sequence

Five phases. Phases 1-3 are invisible plumbing; the pastor sees nothing change until phase 4.

### Phase 1 - foundations (invisible)
- Migration: `pathway_versions` table + RLS (own church, pastor write).
- Migration: unique constraint on `pathway_rungs (church_id, level, rung_key)`; `retired_at` column.
- Migration: `template_generation` counter so a fork can record what it forked from.
- Nothing reads any of it. Zero user-visible change.

### Phase 2 - quiet fork (invisible)
- Migration proven on PG16 against a copy of production shape: for each of the 12 churches, compute the **effective** pipeline exactly as its members see it today (base rows + that church's overlays, existing precedence), write it as published `v1`, and materialise the church's own rung rows.
- Read-only both-directions diagnostic first (#387): for every church and level, the effective rung list before and after must be **identical**. That diff is the gate.

### Phase 3 - switch the readers (invisible if phase 2 was right)
- MMT / MLT / MD / poster read own-church rows only; overlay precedence retires.
- The flat-order resolver shipped this session is unchanged.
- Retired-rung arm added to the member pathway query, with the counting rule above.
- Verification: rendered pathway identical per church, per level, before and after.

### Phase 4 - the editor (the keys change hands)
- Draft mode over `pathway_versions.doc`.
- Flat view: one collapsed column, drag or arrow reorder across categories.
- Library picker: add any template rung; also the "start empty" path.
- Rung form exposes `completion_source` / `auto_source_key` - manual tick vs auto-complete (requirement 5).
- Retire with the completion-count warning.
- Pre-publish sanity check.
- Publish: one transaction, regeneration not diff.

### Phase 5 - the comforts
- Version list, restore, publish notes.
- Template-update notification with per-item opt-in.
- Lean starter template.
- Print sheet + read-only share link.

**Gate between every phase:** the rendered pathway for Rosehill and one tenant church must be identical to the phase before, unless the phase is meant to change it.
