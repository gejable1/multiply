// supabase/functions/meeting-prep-ai/index.ts
//
// MULTIPLY - S106 pilot: run the MLT Meeting Prep prompt on the Claude API so a
// leader gets the four guides (EN/TL facilitator + participant) without copy-paste.
// The API key lives ONLY here (secret ANTHROPIC_API_KEY); the browser never sees it.
//
// Contract:
//   POST { action: "status" }
//     -> { data: { allowed, remaining_today, daily_cap }, error }
//   POST { action: "generate", prompt: string }
//     -> { data: { text, truncated, remaining_today, model }, error }
//
// Gate (all must pass):
//   * caller's HS256 church JWT verified here (same scheme as church-settings-flag)
//   * member belongs to the JWT's church and is pipeline_level >= 2 (Meeting Prep is MLT)
//   * PILOT: pastor (level >= 5) OR member id listed in churches.settings.ai_pilot_members
//   * daily cap per member (AI_DAILY_CAP, default 5) and monthly cap per church
//     (AI_MONTHLY_CAP, default 300), counted from public.ai_usage_log
//   * prompt must be the Meeting Prep prompt (contains the ===FACILITATOR_EN=== fence)
//     and <= 60,000 characters - this function is not a general-purpose chatbot.
// No member data is sent to the AI: the prompt is built only from the devotional or
// the material the leader pasted.
//
// Deploy:  Supabase Dashboard -> Edge Functions -> Deploy a new function
//          name "meeting-prep-ai", paste this file, and turn OFF "Verify JWT"
//          (we verify the church JWT ourselves, like church-settings-flag).
// Secrets: ANTHROPIC_API_KEY (new), JWT_SECRET (reuse); optional AI_MODEL,
//          AI_DAILY_CAP, AI_MONTHLY_CAP. SUPABASE_URL + SERVICE_ROLE are auto-injected.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { verify } from "https://deno.land/x/djwt@v3.0.2/mod.ts";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, content-type, apikey, x-client-info",
};
const FEATURE = "meeting_prep";
const MIN_LEVEL = 2;
const PASTOR_LEVEL = 5;
const MAX_PROMPT_CHARS = 60000;
const FENCE = "===FACILITATOR_EN===";

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { ...CORS, "Content-Type": "application/json" } });
}
const fail = (error: string, status: number) => json({ data: null, error }, status);
const intEnv = (k: string, d: number) => {
  const n = parseInt(Deno.env.get(k) || "", 10);
  return Number.isFinite(n) && n > 0 ? n : d;
};

// Manila (UTC+8) day / month starts, as UTC ISO strings, for the caps.
function manilaStarts() {
  const nowM = new Date(Date.now() + 8 * 3600 * 1000);
  const y = nowM.getUTCFullYear(), m = nowM.getUTCMonth(), d = nowM.getUTCDate();
  const day = new Date(Date.UTC(y, m, d) - 8 * 3600 * 1000).toISOString();
  const month = new Date(Date.UTC(y, m, 1) - 8 * 3600 * 1000).toISOString();
  return { day, month };
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return fail("method_not_allowed", 405);

  // -- 1. Verify the church JWT --
  const bm = (req.headers.get("Authorization") || "").match(/^Bearer\s+(.+)$/i);
  if (!bm) return fail("missing_bearer", 401);
  const SECRET = Deno.env.get("JWT_SECRET");
  const API_KEY = Deno.env.get("ANTHROPIC_API_KEY");
  if (!SECRET || !API_KEY) return fail("server_misconfigured", 500);
  let payload: Record<string, unknown>;
  try {
    const key = await crypto.subtle.importKey("raw", new TextEncoder().encode(SECRET),
      { name: "HMAC", hash: "SHA-256" }, false, ["verify"]);
    payload = await verify(bm[1], key) as Record<string, unknown>;
  } catch { return fail("invalid_token", 401); }
  const sub = payload?.sub, churchClaim = payload?.church_id;
  if (!sub || typeof sub !== "string") return fail("invalid_token", 401);
  if (!churchClaim || typeof churchClaim !== "string") return fail("no_church_claim", 401);

  let body: { action?: unknown; prompt?: unknown };
  try { body = await req.json(); } catch { return fail("bad_json", 400); }
  const action = body.action === "generate" ? "generate" : body.action === "status" ? "status" : "";
  if (!action) return fail("bad_action", 400);

  const db = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false } });

  // -- 2. Who is calling, and are they in the pilot? --
  const { data: me, error: meErr } = await db.from("members")
    .select("id, pipeline_level, church_id").eq("id", sub).maybeSingle();
  if (meErr) return fail(meErr.message, 500);
  if (!me) return fail("member_not_found", 403);
  if (me.church_id !== churchClaim) return fail("church_mismatch", 403);
  const level = me.pipeline_level ?? 0;
  const { data: ch } = await db.from("churches").select("settings").eq("id", churchClaim).maybeSingle();
  const st = (ch?.settings && typeof ch.settings === "object") ? ch.settings as Record<string, unknown> : {};
  const pilot = Array.isArray(st.ai_pilot_members) ? (st.ai_pilot_members as unknown[]).map(String) : [];
  const inPilot = level >= MIN_LEVEL && (level >= PASTOR_LEVEL || pilot.includes(sub));

  // -- 3. Caps --
  const DAILY = intEnv("AI_DAILY_CAP", 5), MONTHLY = intEnv("AI_MONTHLY_CAP", 300);
  const { day, month } = manilaStarts();
  const { count: usedToday } = await db.from("ai_usage_log").select("id", { count: "exact", head: true })
    .eq("member_id", sub).eq("feature", FEATURE).eq("ok", true).gte("created_at", day);
  const remaining = Math.max(0, DAILY - (usedToday ?? 0));

  if (action === "status") {
    return json({ data: { allowed: inPilot, remaining_today: inPilot ? remaining : 0, daily_cap: DAILY }, error: null });
  }

  // -- 4. Generate --
  if (!inPilot) return fail("not_in_pilot", 403);
  if (remaining <= 0) return fail("daily_limit", 429);
  const { count: usedMonth } = await db.from("ai_usage_log").select("id", { count: "exact", head: true })
    .eq("church_id", churchClaim).eq("ok", true).gte("created_at", month);
  if ((usedMonth ?? 0) >= MONTHLY) return fail("monthly_limit", 429);

  const prompt = typeof body.prompt === "string" ? body.prompt : "";
  if (prompt.length < 200 || prompt.length > MAX_PROMPT_CHARS || !prompt.includes(FENCE)) {
    return fail("bad_prompt", 400);
  }

  const model = Deno.env.get("AI_MODEL") || "claude-haiku-5-5";
  const log = (row: Record<string, unknown>) =>
    db.from("ai_usage_log").insert({ church_id: churchClaim, member_id: sub, feature: FEATURE, model, ...row });

  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), 140000);
  try {
    const r = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      signal: ctrl.signal,
      headers: { "content-type": "application/json", "x-api-key": API_KEY, "anthropic-version": "2023-06-01" },
      body: JSON.stringify({ model, max_tokens: 16000, messages: [{ role: "user", content: prompt }] }),
    });
    const j = await r.json().catch(() => null);
    if (!r.ok || !j) {
      const msg = (j && j.error && j.error.message) ? String(j.error.message).slice(0, 300) : "HTTP " + r.status;
      await log({ ok: false, error: msg });
      return fail(r.status === 429 || r.status === 529 ? "ai_busy" : "ai_error", 502);
    }
    const text = Array.isArray(j.content)
      ? j.content.filter((c: { type?: string }) => c && c.type === "text").map((c: { text?: string }) => c.text || "").join("")
      : "";
    const truncated = j.stop_reason === "max_tokens";
    await log({ ok: !!text, input_tokens: j.usage?.input_tokens ?? null, output_tokens: j.usage?.output_tokens ?? null,
                error: text ? (truncated ? "truncated" : null) : "empty_reply" });
    if (!text) return fail("empty_reply", 502);
    return json({ data: { text, truncated, remaining_today: Math.max(0, remaining - 1), model }, error: null });
  } catch (e) {
    const aborted = (e as Error)?.name === "AbortError";
    await log({ ok: false, error: aborted ? "timeout" : String((e as Error)?.message || e).slice(0, 300) });
    return fail(aborted ? "timeout" : "ai_error", 504);
  } finally {
    clearTimeout(timer);
  }
});
