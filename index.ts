// =====================================================================
// MULTIPLY · compute-svi-weekly Edge Function (supabase-js version)
// =====================================================================
//
// Computes weekly Spiritual Vitality Index snapshots for all active members.
//
// USAGE
// -----
// GET  https://<project>.supabase.co/functions/v1/compute-svi-weekly
// POST https://<project>.supabase.co/functions/v1/compute-svi-weekly
//
// Query params (all optional):
//   ?week_start=YYYY-MM-DD     Override target Monday (default: most recent Monday)
//   ?dry_run=true              Compute but do NOT write to svi_snapshots
//   ?member_id=<uuid>          Compute for ONE member only (debugging)
//   ?limit=N                   Cap rows processed (debugging; default: all)
//
// SECRETS REQUIRED
// ----------------
//   SUPABASE_URL              — auto-injected by Supabase
//   SUPABASE_SERVICE_ROLE_KEY — auto-injected by Supabase
//
// (No SUPABASE_DB_URL needed — supabase-js handles connections.)
// =====================================================================

import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
};

// =====================================================================
// ENTRY POINT
// =====================================================================
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !serviceKey) {
    return jsonResponse({
      error: "Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY",
      hint: "These are normally auto-injected. Check function deployment.",
    }, 500);
  }

  const url = new URL(req.url);
  const params = {
    week_start: url.searchParams.get("week_start"),
    dry_run: url.searchParams.get("dry_run") === "true",
    member_id: url.searchParams.get("member_id"),
    limit: url.searchParams.get("limit") ? parseInt(url.searchParams.get("limit")!) : null,
  };

  const supabase = createClient(supabaseUrl, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  try {
    const result = await runComputation(supabase, params);
    return jsonResponse(result);
  } catch (e) {
    console.error("compute-svi-weekly error:", e);
    return jsonResponse({
      error: String((e as any)?.message || e),
      stack: String((e as any)?.stack || ""),
    }, 500);
  }
});

// =====================================================================
// MAIN COMPUTATION
// =====================================================================
async function runComputation(supabase: any, params: any) {
  const startTime = Date.now();

  const weekStart = params.week_start || mostRecentMonday();
  if (!/^\d{4}-\d{2}-\d{2}$/.test(weekStart)) {
    throw new Error(`Invalid week_start format: ${weekStart}. Expected YYYY-MM-DD.`);
  }

  // Load metrics catalog
  const { data: metrics, error: mErr } = await supabase
    .from("svi_metrics")
    .select("metric_key,display_name,category,compute_type,compute_config,score_rules,min_pipeline_level,max_pipeline_level")
    .eq("is_active", true)
    .order("sort_order");
  if (mErr) throw new Error(`Loading svi_metrics: ${mErr.message}`);
  if (!metrics || metrics.length === 0) {
    return { error: "No active metrics in svi_metrics. Did the migration run?" };
  }

  // Load svi_start_date from system_settings (for adaptive lookback)
  let systemStartDate: string | null = null;
  try {
    const { data: ssRows } = await supabase
      .from("system_settings")
      .select("meta")
      .eq("id", 1)
      .limit(1);
    if (ssRows && ssRows.length > 0 && ssRows[0].meta) {
      systemStartDate = ssRows[0].meta.svi_start_date || null;
    }
  } catch (_e) {
    // Non-fatal — falls back to no adaptive cap
    systemStartDate = null;
  }

  // Load weight profiles
  const { data: profiles, error: pErr } = await supabase
    .from("svi_weight_profiles")
    .select("profile_key,applies_to_level,weights,zone_thresholds,trend_thresholds,church_id")
    .eq("is_active", true);
  if (pErr) throw new Error(`Loading svi_weight_profiles: ${pErr.message}`);

  const profilesByChurchLevel = new Map<string, any>();
  const defaultByChurch = new Map<string, any>();
  for (const p of profiles || []) {
    profilesByChurchLevel.set(`${p.church_id}|${p.applies_to_level}`, p);
    if (p.applies_to_level === null) defaultByChurch.set(String(p.church_id), p);
  }
  if (defaultByChurch.size === 0) {
    throw new Error("No default svi_weight_profile (applies_to_level IS NULL) found for any church.");
  }

  // Load active members
  let memberQuery = supabase
    .from("members")
    .select("id,name,lc_group,pipeline_level,discipler_id,ministry_role,ministry,ministry2,ministry3,eolo,enrolled_date,is_test_member,church_id")
    .or("is_test_member.is.null,is_test_member.eq.false");

  if (params.member_id) {
    memberQuery = memberQuery.eq("id", params.member_id);
  }
  if (params.limit) {
    memberQuery = memberQuery.limit(params.limit);
  }
  memberQuery = memberQuery.order("name");

  const { data: members, error: memErr } = await memberQuery;
  if (memErr) throw new Error(`Loading members: ${memErr.message}`);
  if (!members) return { error: "No members returned" };

  // ── PRECOMPUTE: which LC groups actually MET (≥1 member present at an LC
  //    Meeting), per LC key, over the last 8 weeks. An UNFILTERED active-member
  //    lite map is loaded so groups stay complete even on single-member dry
  //    runs (the filtered `members` above may hold just one person).
  const { data: allLite } = await supabase
    .from("members")
    .select("id,pipeline_level,discipler_id")
    .or("is_test_member.is.null,is_test_member.eq.false");
  const liteById = new Map<string, any>((allLite || []).map((m: any) => [m.id, m]));

  // ── BULK PREFETCH: every per-member data source fetched ONCE for ALL members,
  //    each over its widest needed window ending at weekStart, FULLY PAGINATED
  //    (no 1000-row truncation). The per-member loop then reads these maps with
  //    ZERO queries. Scores are byte-identical — same windows/filters/aggregation;
  //    only data acquisition moved from per-call queries to here.
  const allLiteById = liteById; // (alias for clarity in the prefetch below)
  const dayStr = (base: string, minusDays: number) => {
    const d = new Date(base + "T00:00:00Z"); d.setUTCDate(d.getUTCDate() - minusDays);
    return d.toISOString().slice(0, 10);
  };
  // widest configured lookback (weeks) per source, falling back to known defaults
  const maxWeeks = (pred: (m: any) => boolean, def: number) => {
    let w = def;
    for (const m of metrics) { if (pred(m)) { const lw = Number(m.compute_config?.lookback_weeks) || def; if (lw > w) w = lw; } }
    return w;
  };
  const attDays    = maxWeeks((m) => m.compute_config?.table === "attendance" || m.compute_config?.computed === "lc_attendance_rate", 8) * 7;
  const devoDays   = maxWeeks((m) => m.compute_config?.table === "devotional_reflections", 4) * 7;
  const intervDays = maxWeeks((m) => m.compute_config?.table === "interventions", 26) * 7;
  const attLower    = dayStr(weekStart, attDays - 1);
  const devoLower   = dayStr(weekStart, devoDays - 1);
  const intervLower = dayStr(weekStart, intervDays - 1);

  // Attendance (Sunday Service + LC Meeting), present AND absent — widest window.
  const attRows = await fetchAllPaged((f, t) => supabase.from("attendance")
    .select("member_id,event_type,event_date,present")
    .in("event_type", ["Sunday Service", "LC Meeting"])
    .gte("event_date", attLower).lte("event_date", weekStart).range(f, t));
  const attendanceByMember = new Map<string, any[]>();
  for (const r of attRows) { (attendanceByMember.get(r.member_id) || attendanceByMember.set(r.member_id, []).get(r.member_id))!.push(r); }

  // Devotional reflections — widest window.
  const devoRows = await fetchAllPaged((f, t) => supabase.from("devotional_reflections")
    .select("member_id,entry_date,reflection")
    .gte("entry_date", devoLower).lte("entry_date", weekStart).range(f, t));
  const devotionalByMember = new Map<string, any[]>();
  for (const r of devoRows) { (devotionalByMember.get(r.member_id) || devotionalByMember.set(r.member_id, []).get(r.member_id))!.push(r); }

  // Interventions — widest window; status is filtered in-memory by the handler.
  const intervRows = await fetchAllPaged((f, t) => supabase.from("interventions")
    .select("member_id,status,start_date")
    .gte("start_date", intervLower).lte("start_date", weekStart).range(f, t));
  const interventionsByMember = new Map<string, any[]>();
  for (const r of intervRows) { (interventionsByMember.get(r.member_id) || interventionsByMember.set(r.member_id, []).get(r.member_id))!.push(r); }

  // Diagnostics — latest date_taken per member (no window; date_recency uses latest ever).
  const diagRows = await fetchAllPaged((f, t) => supabase.from("diagnostic_results")
    .select("member_id,date_taken").range(f, t));
  const diagnosticLatestByMember = new Map<string, string | null>();
  for (const r of diagRows) { if (!r.date_taken) continue; const prev = diagnosticLatestByMember.get(r.member_id); if (!prev || r.date_taken > prev) diagnosticLatestByMember.set(r.member_id, r.date_taken); }

  // count_rows metrics (the Wave-4 prayer ×4) — one bulk per metric, grouped by
  // member, applying each metric's exact window/filter (same as computeCountRows).
  const countByMetric = new Map<string, Map<string, number>>();
  for (const m of metrics) {
    if (m.compute_type !== "count_rows") continue;
    const cfg = m.compute_config || {};
    const table = cfg.table; if (!table) continue;
    const memberCol = cfg.member_col || "member_id";
    const dateCol = cfg.date_col || null;
    const lookbackDays = Number(cfg.lookback_days || (cfg.lookback_weeks ? cfg.lookback_weeks * 7 : 30));
    const cols = [memberCol].concat(dateCol ? [dateCol] : []).join(",");
    const rows = await fetchAllPaged((f, t) => {
      let q = supabase.from(table).select(cols);
      const filter = cfg.filter || {};
      for (const [c, v] of Object.entries(filter)) q = Array.isArray(v) ? q.in(c, v) : q.eq(c, v);
      if (dateCol) {
        const ws = new Date(weekStart + "T00:00:00Z");
        const lower = new Date(ws); lower.setUTCDate(lower.getUTCDate() - lookbackDays + 1);
        const upper = new Date(ws); upper.setUTCDate(upper.getUTCDate() + 1); // include weekStart day
        q = q.gte(dateCol, lower.toISOString()).lt(dateCol, upper.toISOString());
      }
      return q.range(f, t);
    });
    const cm = new Map<string, number>();
    for (const r of rows) { const id = (r as any)[memberCol]; if (!id) continue; cm.set(id, (cm.get(id) || 0) + 1); }
    countByMetric.set(m.metric_key, cm);
  }

  // Prior snapshots @ weekStart−28d (trend baseline).
  const priorStr = dayStr(weekStart, 28);
  const priorRowsAll = await fetchAllPaged((f, t) => supabase.from("svi_snapshots")
    .select("member_id,total_score").eq("week_start", priorStr).range(f, t));
  const priorScoreByMember = new Map<string, number | null>();
  for (const r of priorRowsAll) { priorScoreByMember.set(r.member_id, r.total_score); }

  // ── meetingsHeld: which LC groups actually MET (≥1 member present at an LC
  //    Meeting) over the last 8 weeks — DERIVED from the attendance bulk above
  //    (same window/result as the old separate lcAtt query). allLite resolves
  //    each member's lcKey so groups stay complete even on single-member runs.
  const lcLowerStr = dayStr(weekStart, 56 - 1); // exact 8-week window (weekStart−55)
  const meetingsHeld = new Map<string, Set<string>>(); // lcKey -> Set(event_date)
  for (const r of attRows) {
    if (r.event_type !== "LC Meeting" || r.present !== true) continue;
    if (r.event_date < lcLowerStr) continue; // hold to the exact 8-week window
    const att = allLiteById.get(r.member_id); if (!att) continue;
    const key = lcKeyOf(att); if (!key) continue;
    if (!meetingsHeld.has(key)) meetingsHeld.set(key, new Set());
    meetingsHeld.get(key)!.add(r.event_date);
  }

  const prefetch = {
    attendanceByMember, devotionalByMember, interventionsByMember,
    diagnosticLatestByMember, countByMetric, priorScoreByMember,
  };

  // Compute per member
  const results: any[] = [];
  const errors: any[] = [];

  for (const member of members) {
    try {
      const snapshot = computeMemberSnapshot(
        member, metrics, profilesByChurchLevel, defaultByChurch, weekStart, systemStartDate, meetingsHeld, prefetch
      );
      results.push(snapshot);
    } catch (e) {
      errors.push({
        member_id: member.id,
        member_name: member.name,
        error: String((e as any)?.message || e),
      });
    }
  }

  // Persist
  let written = 0;
  if (!params.dry_run && results.length > 0) {
    written = await writeSnapshots(supabase, results, weekStart);
  }

  return {
    week_start: weekStart,
    svi_start_date: systemStartDate,
    dry_run: params.dry_run,
    members_processed: members.length,
    snapshots_computed: results.length,
    snapshots_written: written,
    errors: errors,
    error_count: errors.length,
    elapsed_ms: Date.now() - startTime,
    sample_results: results.slice(0, 5).map((r: any) => ({
      member_name: r.member_name,
      lc_group: r.lc_group,
      pipeline_level: r.pipeline_level,
      total_score: r.total_score,
      zone: r.zone,
      trend: r.trend,
      profile_used: r.profile_used,
      metric_scores: r.metric_scores,
    })),
  };
}

// =====================================================================
// PER-MEMBER SNAPSHOT
// =====================================================================
function computeMemberSnapshot(
  member: any, metrics: any[],
  profilesByChurchLevel: Map<string, any>, defaultByChurch: Map<string, any>,
  weekStart: string, systemStartDate: string | null,
  meetingsHeld: Map<string, Set<string>>, prefetch: any
) {
  const level = member.pipeline_level ?? 0;
  const _ck = String(member.church_id);
  const profile = profilesByChurchLevel.get(`${_ck}|${level}`) || defaultByChurch.get(_ck);
  if (!profile) {
    return { member_id: member.id, member_name: member.name, church_id: member.church_id,
      lc_group: member.lc_group, pipeline_level: level, week_start: weekStart,
      profile_used: null, metric_scores: {}, category_scores: {}, total_score: null,
      zone: "insufficient", trend: "new", trend_delta: null,
      metrics_with_data: 0, metrics_total: 0 };
  }
  const weights: Record<string, number> = profile.weights || {};
  const zoneThresholds = profile.zone_thresholds || { thriving: 70, warming: 40 };
  const trendThresholds = profile.trend_thresholds || { up: 5, down: -5 };

  const metricScores: Record<string, any> = {};
  const categoryScores: Record<string, { total: number; weight: number }> = {};
  let weightedSum = 0;
  let totalWeight = 0;
  let metricsWithData = 0;
  let metricsTotal = 0;

  for (const metric of metrics) {
    if (level < metric.min_pipeline_level || level > metric.max_pipeline_level) continue;
    const weight = weights[metric.metric_key] || 0;
    if (weight <= 0) continue;

    metricsTotal++;

    // SERVICE_LC_LED (L2+ only): scored from whether THIS leader's LC actually
    // met, evidenced by member LC-attendance (meetingsHeld keyed by leader id).
    // L0/L1 don't lead an LC → null (not counted).
    if (metric.metric_key === "service_lc_led") {
      if (level < 2) {
        metricScores[metric.metric_key] = { raw: null, score: null, weight, category: metric.category };
      } else {
        const raw = meetingsHeld.get(member.id)?.size || 0;
        const score = applyScoreRules(raw, metric.score_rules);
        metricScores[metric.metric_key] = { raw, score, weight, category: metric.category };
        metricsWithData++; weightedSum += score * weight; totalWeight += weight;
        if (!categoryScores[metric.category]) categoryScores[metric.category] = { total: 0, weight: 0 };
        categoryScores[metric.category].total += score * weight;
        categoryScores[metric.category].weight += weight;
      }
      continue;
    }

    let raw: any = null;
    try {
      raw = computeMetric(member, metric, weekStart, systemStartDate, prefetch);
    } catch (e) {
      console.error(`Metric ${metric.metric_key} failed for ${member.name}:`, e);
      raw = null;
    }

    if (raw === null && metric.compute_config?.null_if_zero) {
      metricsTotal--;
      metricScores[metric.metric_key] = { raw: null, score: null, weight, category: metric.category, note: "n/a" };
      continue;
    }
    let score = (raw === null || raw === undefined) ? null : applyScoreRules(raw, metric.score_rules);
    let note: string | null = null;

    // Soften LC-fellowship metrics to a FLOOR when the member's LC did NOT meet
    // (vs a full penalty when it met but they were absent). The impact is still
    // felt — surfacing that LC fellowship is missing — but it isn't a hard zero.
    if (metric.metric_key === "gather_lc" || metric.metric_key === "fellowship_lc_rate") {
      const lcKey = lcKeyOf(member);
      const lcMet = !!(lcKey && meetingsHeld.get(lcKey)?.size);
      if (!lcMet && score !== null) {
        score = (metric.compute_config?.no_meeting_floor_score ?? 4);
        note = "no_meeting_held";
      }
    }

    metricScores[metric.metric_key] = {
      raw, score, weight, category: metric.category, ...(note ? { note } : {}),
    };

    if (score !== null) {
      metricsWithData++;
      weightedSum += score * weight;
      totalWeight += weight;
      if (!categoryScores[metric.category]) {
        categoryScores[metric.category] = { total: 0, weight: 0 };
      }
      categoryScores[metric.category].total += score * weight;
      categoryScores[metric.category].weight += weight;
    }
  }

  let total: number | null = null;
  let zone = "insufficient";

  if (totalWeight > 0 && metricsWithData >= Math.ceil(metricsTotal / 2)) {
    total = (weightedSum / totalWeight) * 10;
    if (total >= zoneThresholds.thriving) zone = "thriving";
    else if (total >= zoneThresholds.warming) zone = "warming";
    else zone = "dormant";
  }

  // (New-member detection rule removed 2026-05-06: data import had set
  //  enrolled_date to recent dates for established members, so the rule
  //  was incorrectly marking everyone as insufficient. Letting metrics
  //  speak for themselves is more honest anyway.)

  // Trend: compare to the snapshot 4 weeks ago (prefetched).
  const priorScore = prefetch.priorScoreByMember.get(member.id);
  let trend = "new";
  let trendDelta: number | null = null;
  if (priorScore !== undefined && priorScore !== null && total !== null) {
    trendDelta = total - Number(priorScore);
    if (trendDelta >= trendThresholds.up) trend = "up";
    else if (trendDelta <= trendThresholds.down) trend = "down";
    else trend = "steady";
  }

  const categoryScoresOut: Record<string, number> = {};
  for (const [cat, { total: t, weight: w }] of Object.entries(categoryScores)) {
    categoryScoresOut[cat] = w > 0 ? Number(((t / w) * 10).toFixed(2)) : 0;
  }

  return {
    member_id: member.id,
    member_name: member.name,
    church_id: member.church_id,
    lc_group: member.lc_group,
    pipeline_level: level,
    week_start: weekStart,
    profile_used: profile.profile_key,
    metric_scores: metricScores,
    category_scores: categoryScoresOut,
    total_score: total !== null ? Number(total.toFixed(2)) : null,
    zone,
    trend,
    trend_delta: trendDelta !== null ? Number(trendDelta.toFixed(2)) : null,
    metrics_with_data: metricsWithData,
    metrics_total: metricsTotal,
  };
}

// =====================================================================
// METRIC COMPUTERS (dispatcher by compute_type)
// =====================================================================
function computeMetric(member: any, metric: any, weekStart: string, systemStartDate: string | null, prefetch: any): any {
  switch (metric.compute_type) {
    case "sql_query":      return computeSqlQuery(member, metric, weekStart, systemStartDate, prefetch);
    case "jsonb_extract":  return computeJsonbExtract(member, metric);
    case "boolean_check":  return computeBooleanCheck(member, metric);
    case "date_recency":   return computeDateRecency(member, metric, weekStart, prefetch);
    case "count_rows":     return computeCountRows(member, metric, prefetch);
    default:
      throw new Error(`Unknown compute_type: ${metric.compute_type}`);
  }
}

// --- sql_query handler ----
// Returns either a raw count OR a rate (0.0 - 1.0+) depending on
// whether the metric's compute_config has rate_based: true.
//
// Adaptive lookback: if systemStartDate is set, the actual lookback
// is capped to days_since_start, so brand-new deployments don't
// suffer from "expected 8 Sundays, found 1" math.
function computeSqlQuery(
  member: any,
  metric: any,
  weekStart: string,
  systemStartDate: string | null,
  prefetch: any
): number {
  const cfg = metric.compute_config;
  const weekStartDate = new Date(weekStart);

  // ----- compute effective lookback (UNCHANGED) -----
  const configuredLookbackDays = (cfg.lookback_weeks || 4) * 7;
  let effectiveLookbackDays = configuredLookbackDays;
  if (systemStartDate) {
    const startDate = new Date(systemStartDate);
    const daysSinceStart = Math.floor(
      (weekStartDate.getTime() - startDate.getTime()) / (86400 * 1000)
    );
    // Use at least 1 day (avoid div-by-zero); cap at configured lookback
    effectiveLookbackDays = Math.max(1, Math.min(configuredLookbackDays, daysSinceStart + 1));
  }
  const cutoff = new Date(weekStartDate);
  cutoff.setUTCDate(cutoff.getUTCDate() - effectiveLookbackDays + 1);
  const cutoffStr = cutoff.toISOString().slice(0, 10);

  const isRateBased = !!cfg.rate_based;
  const intervalDays = Number(cfg.typical_interval_days || 7);

  // Special computed: lc_attendance_rate (already returns a percentage)
  if (cfg.computed === "lc_attendance_rate") {
    const data = (prefetch.attendanceByMember.get(member.id) || [])
      .filter((r: any) => r.event_type === "LC Meeting" && r.event_date >= cutoffStr && r.event_date <= weekStart);
    const total = data.length;
    if (total === 0) return 0;
    const present = data.filter((r: any) => r.present === true).length;
    return Math.round((present / total) * 100);
  }

  const table = cfg.table;
  if (!table) throw new Error(`compute_config.table missing for ${metric.metric_key}`);

  // ATTENDANCE
  if (table === "attendance") {
    const eventTypeFilter = cfg.filter?.event_type;
    const aggregate = cfg.aggregate || "count_rows";

    const data = (prefetch.attendanceByMember.get(member.id) || [])
      .filter((r: any) => r.event_type === eventTypeFilter && r.present === true
        && r.event_date >= cutoffStr && r.event_date <= weekStart);

    let actualCount: number;
    if (aggregate === "count_distinct_dates") {
      actualCount = new Set(data.map((r: any) => r.event_date)).size;
    } else {
      actualCount = data.length;
    }

    if (isRateBased) {
      const expectedCount = Math.max(1, effectiveLookbackDays / intervalDays);
      return Math.min(1.0, actualCount / expectedCount);
    }
    return actualCount;
  }

  // DEVOTIONAL_REFLECTIONS
  if (table === "devotional_reflections") {
    const data = (prefetch.devotionalByMember.get(member.id) || [])
      .filter((r: any) => r.entry_date >= cutoffStr && r.entry_date <= weekStart);

    const actualCount = data.filter(
      (r: any) => r.reflection && r.reflection.trim().length > 0
    ).length;

    if (isRateBased) {
      // Skip Sundays in expected count if configured
      let expectedDays = effectiveLookbackDays;
      if (cfg.skip_sundays) {
        // Approximate: 6 of every 7 days are non-Sunday
        expectedDays = effectiveLookbackDays * (6 / 7);
      }
      const expectedCount = Math.max(1, expectedDays / Math.max(0.5, intervalDays));
      return Math.min(1.0, actualCount / expectedCount);
    }
    return actualCount;
  }

  // INTERVENTIONS
  if (table === "interventions") {
    const statusList = cfg.filter?.status_in || ["in_progress", "completed"];
    const data = (prefetch.interventionsByMember.get(member.id) || [])
      .filter((r: any) => statusList.includes(r.status)
        && r.start_date >= cutoffStr && r.start_date <= weekStart);
    return data.length;
  }

  throw new Error(`No handler implemented for table: ${table}`);
}

// --- jsonb_extract handler (EOLO) — in-memory already ---
function computeJsonbExtract(member: any, metric: any): number {
  if (metric.metric_key === "mission_eolo_active") {
    const eolo = member.eolo;
    if (!Array.isArray(eolo)) return 0;
    return eolo.length;
  }
  throw new Error(`No jsonb_extract handler for ${metric.metric_key}`);
}

// --- boolean_check handler (ministry role) — in-memory already ---
function computeBooleanCheck(member: any, metric: any): boolean {
  const cfg = metric.compute_config;
  if (cfg.check === "ministry_role_or_secondary_present") {
    return !!(
      (member.ministry_role && String(member.ministry_role).trim()) ||
      (member.ministry && String(member.ministry).trim()) ||
      (member.ministry2 && String(member.ministry2).trim()) ||
      (member.ministry3 && String(member.ministry3).trim())
    );
  }
  throw new Error(`No boolean_check handler for: ${cfg.check}`);
}

// --- date_recency handler (diagnostic recency) — reads prefetch ---
function computeDateRecency(member: any, metric: any, weekStart: string, prefetch: any): number {
  const cfg = metric.compute_config;
  if (cfg.table === "diagnostic_results") {
    const latestStr = prefetch.diagnosticLatestByMember.get(member.id) || null;
    if (!latestStr) return 99999;
    const latest = new Date(latestStr);
    const ws = new Date(weekStart);
    return Math.max(0, Math.floor((ws.getTime() - latest.getTime()) / (86400 * 1000)));
  }
  throw new Error(`No date_recency handler for table: ${cfg.table}`);
}

// --- count_rows handler (GENERIC, table-agnostic) — reads prefetch ---
// The bulk prefetch already applied each metric's table/member_col/date_col/
// lookback/filter and grouped a per-member count into prefetch.countByMetric.
// (window/filter semantics identical to the prior per-member count query.)
function computeCountRows(member: any, metric: any, prefetch: any): number | null {
  if (!metric.compute_config?.table) {
    throw new Error(`compute_config.table missing for ${metric.metric_key}`);
  }
  const cm = prefetch.countByMetric.get(metric.metric_key);
  const _c = cm ? (cm.get(member.id) || 0) : 0;
  if (_c === 0 && metric.compute_config?.null_if_zero) return null;
  return _c;
}

// =====================================================================
// SCORE RULES
// =====================================================================
function applyScoreRules(raw: any, rules: any): number {
  if (!rules || !rules.type) return 0;

  switch (rules.type) {
    case "rate_to_score": {
      // raw is expected to be 0.0-1.0 (or 0-100 if input_is_percentage:true)
      let rate = Number(raw);
      if (rules.input_is_percentage) rate = rate / 100;
      const sorted = [...(rules.ranges || [])].sort((a: any, b: any) => b.min_rate - a.min_rate);
      for (const r of sorted) {
        if (rate >= r.min_rate) return r.score;
      }
      return 0;
    }
    case "linear_threshold": {
      const sorted = [...(rules.thresholds || [])].sort((a: any, b: any) => b.value - a.value);
      for (const t of sorted) {
        if (Number(raw) >= t.value) return t.score;
      }
      return 0;
    }
    case "percentage_to_score": {
      const sorted = [...(rules.ranges || [])].sort((a: any, b: any) => b.min - a.min);
      for (const r of sorted) {
        if (Number(raw) >= r.min) return r.score;
      }
      return 0;
    }
    case "days_to_score": {
      const sorted = [...(rules.ranges || [])].sort((a: any, b: any) => a.max_days - b.max_days);
      for (const r of sorted) {
        if (Number(raw) <= r.max_days) return r.score;
      }
      return 0;
    }
    case "boolean_to_score": {
      return raw ? (rules.true_score ?? 10) : (rules.false_score ?? 0);
    }
    default:
      return 0;
  }
}

// =====================================================================
// PERSIST (upsert)
// =====================================================================
async function writeSnapshots(supabase: any, snapshots: any[], weekStart: string): Promise<number> {
  const rows = snapshots.map((s: any) => ({
    member_id: s.member_id,
    member_name: s.member_name,
    church_id: s.church_id,
    lc_group: s.lc_group,
    pipeline_level: s.pipeline_level,
    week_start: weekStart,
    profile_used: s.profile_used,
    metric_scores: s.metric_scores,
    category_scores: s.category_scores,
    total_score: s.total_score,
    zone: s.zone,
    trend: s.trend,
    trend_delta: s.trend_delta,
    metrics_with_data: s.metrics_with_data,
    metrics_total: s.metrics_total,
  }));

  const batchSize = 50;
  let written = 0;
  for (let i = 0; i < rows.length; i += batchSize) {
    const batch = rows.slice(i, i + batchSize);
    const { error } = await supabase
      .from("svi_snapshots")
      .upsert(batch, { onConflict: "member_id,week_start" });
    if (error) {
      console.error(`Batch upsert failed (rows ${i}-${i + batch.length}):`, error.message);
    } else {
      written += batch.length;
    }
  }
  return written;
}

// =====================================================================
// HELPERS
// =====================================================================
// LC key for a member: an L2+ leader is keyed by their OWN id (they lead an LC);
// everyone else is keyed by their discipler_id (the LC they belong to).
function lcKeyOf(m: any): string | null {
  return ((m?.pipeline_level ?? 0) >= 2 ? m?.id : m?.discipler_id) || null;
}

// Fetch ALL rows for a paginated query — avoids Supabase's default 1000-row cap
// (truncation = missing data = wrong scores). `makeQuery(from,to)` must build a
// FRESH query each call with a .range(from,to) so the range isn't reused.
async function fetchAllPaged(makeQuery: (from: number, to: number) => any): Promise<any[]> {
  const PAGE = 1000;
  let from = 0;
  const out: any[] = [];
  while (true) {
    const { data, error } = await makeQuery(from, from + PAGE - 1);
    if (error) throw error;
    const rows = data || [];
    out.push(...rows);
    if (rows.length < PAGE) break;
    from += PAGE;
  }
  return out;
}

function mostRecentMonday(): string {
  const d = new Date();
  const day = d.getUTCDay();
  const offsetToMon = day === 0 ? 6 : day - 1;
  d.setUTCDate(d.getUTCDate() - offsetToMon);
  return d.toISOString().slice(0, 10);
}

function jsonResponse(body: any, status = 200): Response {
  return new Response(JSON.stringify(body, null, 2), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
