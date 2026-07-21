// MULTIPLY - auth-login Edge Function (Path 1 - HS256 / legacy JWT_SECRET)
//
// Consolidated login surface. Three actions, all anon-callable (pre-auth) -
// the EF *is* the auth boundary, so the login pages never read/write `members`
// from the client and the PIN hash never leaves the server. This is what lets
// `members` RLS lock the table from anon while login still works.
//
//   action:"search"  {q, min_level?}  -> name-search directory for the login
//                                        picker. Returns id/name/role/has_pin
//                                        ONLY - never member_pin_hash. Optional
//                                        min_level filters BEFORE the limit (the
//                                        leader picker passes 2).
//   action:"login"   {member_id,pin}  -> bcrypt-verify the PIN (service role,
//   (default)                            bypasses RLS) + mint an 8h church JWT
//                                        + last-login stamp + app_sessions row.
//   action:"set_pin" {member_id,pin}  -> FIRST-login PIN claim: only when the
//                                        member has no hash yet. bcrypt-hash,
//                                        store, stamp, then mint (auto-login).
//   action:"change_pin" {member_id,    -> member-initiated change: a hash already
//                     current_pin,         exists; bcrypt-verify current_pin, then
//                     new_pin}             overwrite. No session minted.
//
// Telemetry (S78 #322/#323): leader-ness is derived SERVER-SIDE from the
// member's pipeline_level (>= LEADER_MIN_LEVEL), never from a client-supplied
// `stamp` - the browser can no longer declare itself a leader. Every login
// (member or leader) is recorded in the unified `app_sessions` logbook, and
// each login opportunistically reaps expired-open sessions. A legacy `stamp`
// field in the body is simply ignored, so old login pages keep working.
import { createClient } from "npm:@supabase/supabase-js@2";
import bcrypt from "npm:bcryptjs@2.4.3";
import { create } from "https://deno.land/x/djwt@v3.0.2/mod.ts";

const SUPABASE_URL  = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE  = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const JWT_SECRET    = Deno.env.get("JWT_SECRET")!;
const SESSION_HOURS = 8;
const LEADER_MIN_LEVEL = 2;   // pipeline_level >= 2 == LCL+ == leader (Inv #33)

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const json = (b: unknown, s = 200) =>
  new Response(JSON.stringify(b), { status: s, headers: { ...cors, "Content-Type": "application/json" } });

let _key: CryptoKey | null = null;
async function hmacKey() {
  if (_key) return _key;
  _key = await crypto.subtle.importKey(
    "raw", new TextEncoder().encode(JWT_SECRET),
    { name: "HMAC", hash: "SHA-256" }, false, ["sign", "verify"],
  );
  return _key;
}

function admin() {
  return createClient(SUPABASE_URL, SERVICE_ROLE, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

// Build the church-scoped session JWT + the public response for a verified member.
async function mintSession(m: any) {
  const now = Math.floor(Date.now() / 1000);
  const exp = now + SESSION_HOURS * 3600;
  const payload = {
    sub: m.id, role: "authenticated", aud: "authenticated",
    church_id: m.church_id ?? null,
    leader_level: m.pipeline_level ?? 0,
    name: m.name ?? null,
    is_test: !!m.is_test_member, is_guest: !!m.is_external_user,
    iat: now, exp,
  };
  const token = await create({ alg: "HS256", typ: "JWT" }, payload, await hmacKey());
  return {
    token,
    expires_at: new Date(exp * 1000).toISOString(),
    profile: {
      id: m.id, name: m.name, pipeline_level: m.pipeline_level ?? 0,
      church_id: m.church_id ?? null, facilitator_role: m.facilitator_role ?? null,
      is_test_member: !!m.is_test_member, is_external_user: !!m.is_external_user,
    },
  };
}

// Server-derived leader test - the single source of truth for telemetry (#322).
function isLeaderLevel(m: any): boolean {
  return (m?.pipeline_level ?? 0) >= LEADER_MIN_LEVEL;
}

// Best-effort post-auth stamp (S78). Records the member/leader last-login
// column AND a row in the unified app_sessions logbook (#323), then reaps any
// expired-open sessions (#324). All steps non-fatal - login never depends on
// telemetry succeeding.
async function stampLogin(sb: any, memberId: string, isLeader: boolean, ua: string, churchId: string | null) {
  const nowIso = new Date().toISOString();
  const col = isLeader ? "leader_last_login" : "member_last_login";
  try { await sb.from("members").update({ [col]: nowIso }).eq("id", memberId); } catch { /* ignore */ }
  try {
    await sb.from("app_sessions").insert({
      member_id: memberId,
      is_leader: isLeader,
      church_id: churchId ?? null,
      expires_at: new Date(Date.now() + SESSION_HOURS * 3600 * 1000).toISOString(),
      user_agent_hint: (ua || "").slice(0, 180),
    });
  } catch { /* ignore */ }
  try { await sb.rpc("reap_expired_sessions"); } catch { /* ignore */ }
}

const MEMBER_COLS =
  "id,name,pipeline_level,church_id,member_pin_hash,facilitator_role,is_test_member,is_external_user";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST")    return json({ error: "method_not_allowed" }, 405);

  let body: any;
  try { body = await req.json(); } catch { return json({ error: "bad_json" }, 400); }
  const action = (body.action || "login").toString();
  const ua = req.headers.get("user-agent") || "";
  const sb = admin();

  // -- SEARCH ------------------------------------------------------------
  // Anon name-search for the login picker. Safe columns only; the hash is
  // reduced to a boolean (has_pin) so the client knows enter-PIN vs set-PIN.
  // Optional min_level filters BEFORE the limit (leader picker passes 2).
  if (action === "search") {
    const q = (body.q || "").toString().trim();
    if (q.length < 2) return json({ results: [] });
    const minLevel = Number.isFinite(+body.min_level) ? +body.min_level : 0;
    let query = sb
      .from("members")
      .select("id,name,pipeline_level,facilitator_role,lc_group,discipler_name,member_pin_hash,is_test_member,is_external_user")
      .ilike("name", "%" + q + "%");
    if (minLevel > 0) query = query.gte("pipeline_level", minLevel);
    const { data, error } = await query.order("name").limit(8);
    if (error) return json({ error: "search_failed" }, 500);
    const results = (data || []).map((m: any) => ({
      id: m.id, name: m.name, pipeline_level: m.pipeline_level ?? 0,
      facilitator_role: m.facilitator_role ?? null,
      lc_group: m.lc_group ?? null, discipler_name: m.discipler_name ?? null,
      is_test_member: !!m.is_test_member, is_external_user: !!m.is_external_user,
      has_pin: !!m.member_pin_hash,
    }));
    return json({ results });
  }

  // -- SET_PIN (first-login claim) ---------------------------------------
  if (action === "set_pin") {
    const memberId = (body.member_id || "").trim();
    const pin = (body.pin ?? "").toString();
    if (!memberId || pin.length < 4) return json({ error: "missing_credentials" }, 400);

    const { data: m, error } = await sb.from("members").select(MEMBER_COLS).eq("id", memberId).maybeSingle();
    if (error || !m) return json({ error: "invalid_login" }, 401);
    if (m.member_pin_hash) return json({ error: "pin_already_set" }, 409);

    const hash = bcrypt.hashSync(pin, 10);
    const { error: upErr } = await sb.from("members").update({
      member_pin_hash: hash,
      member_pin_set_at: new Date().toISOString(),
    }).eq("id", memberId);
    if (upErr) return json({ error: "set_failed" }, 500);

    await stampLogin(sb, m.id, isLeaderLevel(m), ua, m.church_id);
    return json(await mintSession({ ...m, member_pin_hash: hash }));
  }

  // -- CHANGE_PIN (member-initiated; requires the current PIN) -----------
  // Distinct from set_pin's first-login claim: here a hash already exists and
  // the caller must prove the CURRENT pin (server-side bcrypt) before we
  // overwrite. No session minted - the caller is already logged in.
  if (action === "change_pin") {
    const memberId = (body.member_id || "").trim();
    const cur = (body.current_pin ?? "").toString();
    const nw  = (body.new_pin ?? "").toString();
    if (!memberId || cur.length < 4 || nw.length < 4) return json({ error: "missing_credentials" }, 400);

    const { data: m, error } = await sb.from("members").select(MEMBER_COLS).eq("id", memberId).maybeSingle();
    if (error || !m || !m.member_pin_hash) return json({ error: "invalid_login" }, 401);

    let ok = false;
    try { ok = bcrypt.compareSync(cur, m.member_pin_hash); } catch { ok = false; }
    if (!ok) return json({ error: "invalid_login" }, 401);

    const hash = bcrypt.hashSync(nw, 10);
    const { error: upErr } = await sb.from("members").update({
      member_pin_hash: hash,
      member_pin_set_at: new Date().toISOString(),
    }).eq("id", memberId);
    if (upErr) return json({ error: "set_failed" }, 500);

    return json({ ok: true });
  }

  // -- LOGIN (default) ---------------------------------------------------
  const memberId = (body.member_id || "").trim();
  const pin = (body.pin ?? "").toString();
  if (!memberId || !pin) return json({ error: "missing_credentials" }, 400);

  const { data: m, error } = await sb.from("members").select(MEMBER_COLS).eq("id", memberId).maybeSingle();

  // Uniform failure - never reveal whether the id or the PIN was the problem.
  if (error || !m || !m.member_pin_hash) return json({ error: "invalid_login" }, 401);

  let ok = false;
  try { ok = bcrypt.compareSync(pin, m.member_pin_hash); } catch { ok = false; }
  if (!ok) return json({ error: "invalid_login" }, 401);

  await stampLogin(sb, m.id, isLeaderLevel(m), ua, m.church_id);
  return json(await mintSession(m));
});
