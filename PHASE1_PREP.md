# PHASE1_PREP.md — Multi-Tenant Phase 1 Prep (read-only)

**Date:** 2026-06-04 · **Read-only.** No code or schema changed.
Follows `TENANCY_AUDIT.md`. Two deliverables: (1) resolve the 4 UNSURE tables; (2) one authoritative read-only schema query for the Pastor to run live (since `schema.json` lags — it omitted `lc_groups`).

---

## 1. Resolving the 4 UNSURE tables

**Guiding rule that splits them:** *definitions/content catalogs* → **GLOBAL/SHARED**; *pastoral tuning / operational config a church sets for itself* → **PER-CHURCH**. None of the four carries `member_id`, so member data is not the deciding factor — authorship and tuning are.

| Table | Cols (key ones) | Recommended | One-line reason | Pastor call? |
|---|---|---|---|---|
| **`system_settings`** | single-row config: `weights, thresholds, zones, interventions, pipeline, fats, meta` | **PER-CHURCH** | Operational config each church tunes (pipeline/SVI/intervention/FATS); one shared row would force every church to identical settings. | No — clear. *(Note: today it is a single global row → migration = one row per church + a `church_id`.)* |
| **`svi_weight_profiles`** | `profile_key, applies_to_level, weights, zone_thresholds, trend_thresholds, is_active` | **PER-CHURCH** | Pastoral scoring tuning with a built-in in-app editor (Inv #119); weights/zone cutoffs are a church's judgment, not platform code. | Soft — could instead ship a GLOBAL default + per-church override. Recommend PER-CHURCH; confirm the default-vs-override preference. |
| **`svi_metrics`** | metric catalog: `metric_key, compute_type, compute_config, score_rules, min/max_pipeline_level, is_active` | **GLOBAL/SHARED** | These are *metric definitions* (how a metric is computed) — code-adjacent platform engineering, not per-church content. | Soft — only needs a call if a church must run a *different set* of metrics (vs. just re-weighting them, which `svi_weight_profiles` already covers). |
| **`devotionals`** | dated content: `entry_date, title, scripture_*, story, explanation, prayer, reflection_questions, author, weekly_summary` | **GLOBAL/SHARED** (default) | Reusable dated devotional content with no church/member-specific fields; member responses live in the separate PER-CHURCH `devotional_reflections`. | **YES — genuine Pastor call.** Rosehill authors its own via `devotional_admin.html`; a church may want a *private* devotional track. If so → PER-CHURCH (or global-library + per-church entries). |

**Summary:** 2 → PER-CHURCH (`system_settings`, `svi_weight_profiles`), 2 → GLOBAL/SHARED (`svi_metrics`, `devotionals`).
**Decisions that genuinely need the Pastor:** **`devotionals`** (shared library vs. private per-church track) is the real one; **`svi_weight_profiles`** and **`svi_metrics`** are soft "default-vs-override" / "same-set-vs-different-set" confirmations rather than open questions.

> Updated category counts if these recommendations stand: PER-CHURCH **41**, GLOBAL/SHARED **9**, UNSURE **0** (was 39 / 7 / 4). `VERIFY against live DB` per Inv #124 — and re-run §2 before committing to any of this.

---

## 2. Authoritative current-state query (read-only — Pastor runs in Supabase SQL editor)

Returns, for **every base table in schema `public`**: table name, whether a literal `church_id` column already exists, the live RLS-enabled flag (`pg_class.relrowsecurity`) and the force-RLS flag, and an **approximate** row count (`pg_class.reltuples` — fast, no table scan). This is the source of truth that supersedes `schema.json` (which omitted `lc_groups` and showed RLS flags we couldn't reconcile).

```sql
-- READ-ONLY. Authoritative public-schema tenancy snapshot.
-- Run in the Supabase SQL editor. Returns one row per base table.
SELECT
    c.relname                                   AS table_name,
    EXISTS (
        SELECT 1
        FROM information_schema.columns col
        WHERE col.table_schema = 'public'
          AND col.table_name   = c.relname
          AND col.column_name  = 'church_id'     -- literal check; tenant_id/org_id NOT counted
    )                                            AS has_church_id,
    c.relrowsecurity                             AS rls_enabled,   -- pg_class.relrowsecurity
    c.relforcerowsecurity                        AS rls_forced,    -- bonus: FORCE RLS state
    c.reltuples::bigint                          AS approx_row_count  -- estimate; depends on last ANALYZE
FROM pg_catalog.pg_class      c
JOIN pg_catalog.pg_namespace  n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
  AND c.relkind IN ('r', 'p')                    -- ordinary + partitioned tables (excludes views)
ORDER BY c.relname;
```

**Notes for the Pastor / next session:**
- **Read-only & human-gated** — this only `SELECT`s from `pg_catalog` + `information_schema`; it changes nothing. Per Inv #5/#10, *you* run it; Claude does not (no DB creds).
- **`approx_row_count`** uses `reltuples`, the planner's estimate (instant, no scan). It can read `-1` for a table never `ANALYZE`d, or drift from the true count between analyzes. For exact counts on a specific table, run `SELECT count(*) FROM public.<table>;` separately.
- **`has_church_id`** checks only the literal name `church_id`. Expectation today: **all `false`** (the audit found no tenancy column anywhere). Any `true` is a surprise worth noting.
- **Views excluded** (`relkind` limited to `r`/`p`). To include the 9 `v_*` views, add `'v'` to the `IN (...)` list — but RLS/row-count are not meaningful for views.
- **Compare against `TENANCY_AUDIT.md`:** confirm `lc_groups` appears here (it was missing from `schema.json`), and reconcile the 7 tables `schema.json` marked `rls_enabled=true` (`interventions, ministry_intake, svi_metrics, svi_snapshots, svi_weight_profiles, view_log, _backup_members_diag_zone_2026_05_06`) against the live `rls_enabled` column.

---

*Read-only prep. Nothing in the platform was modified. SQL stays human-gated (Inv #5/#10); live results override `schema.json` (Inv #124).*
