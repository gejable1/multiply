// MULTIPLY · auth-login Edge Function (Path 1 — HS256 / legacy JWT_SECRET)
//
// Consolidated login surface. Three actions, all anon-callable (pre-auth) —
// the EF *is* the auth boundary, so the login pages never read/write `members`
// from the client and the PIN hash never leaves the server. This is what lets
// `members` RLS lock the table from anon while login still works.
//
//   action:"search"  {q}              -> name-search directory for the login
//                                        picker. Returns id/name/role/has_pin
//                                        ONLY — never member_pin_hash.
//   action:"login"   {member_id,pin}  -> bcrypt-verify the PIN (service role,
//   (default)                            bypasses RLS) + mint an 8h church JWT
//                                        + best-effort last-login stamp.
//   action:"set_pin" {member_id,pin}  -> FIRST-login PIN claim: only when the
//                                        member has no hash yet. bcrypt-hash,
//                                        store, then mint a JWT (auto-login).
//
// Backward-compatible: a body with no `action` is treated as "login" and
// returns the identical {token, expires_at, profile} shape as before, so
// deploying this does NOT break the current login pages.
import { createClient } from "npm:@supabase/supabase-js@2";
import bcrypt from "npm:bcryptjs@2.4.3";
import { create } from "https://deno.land/x/djwt@v3.0.2/mod.ts";

const SUPABASE_URL  = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE  = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const JWT_SECRET    = Deno.env.get("JWT_SECRET")!;
const SESSION_HOURS = 8;

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

const MEMBER_COLS =
  "id,name,pipeline_level,church_id,member_pin_hash,facilitator_role,is_test_member,is_external_user";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST")    return json({ error: "method_not_allowed" }, 405);

  let body: any;
  try { body = await req.json(); } catch { return json({ error: "bad_json" }, 400); }
  const action = (body.action || "login").toString();
  const sb = admin();

  // ── SEARCH ────────────────────────────────────────────────────────────
  // Anon name-search for the login picker. Safe columns only; the hash is
  // reduced to a boolean (has_pin) so the client knows enter-PIN vs set-PIN.
  if (action === "search") {
    const q = (body.q || "").toString().trim();
    if (q.length < 2) return json({ results: [] });
    const { data, error } = await sb
      .from("members")
      .select("id,name,pipeline_level,facilitator_role,lc_group,discipler_name,member_pin_hash,is_test_member,is_external_user")
      .ilike("name", "%" + q + "%")
      .order("name")
      .limit(8);
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

  // ── SET_PIN (first-login claim) ───────────────────────────────────────
  // Mirrors the current client behavior: a member with NO hash yet may claim
  // a PIN. If a hash already exists, this path is refused (use login).
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
      member_last_login: new Date().toISOString(),
    }).eq("id", memberId);
    if (upErr) return json({ error: "set_failed" }, 500);

    return json(await mintSession({ ...m, member_pin_hash: hash }));
  }

  // ── LOGIN (default) ───────────────────────────────────────────────────
  const memberId = (body.member_id || "").trim();
  const pin = (body.pin ?? "").toString();
  if (!memberId || !pin) return json({ error: "missing_credentials" }, 400);

  const { data: m, error } = await sb.from("members").select(MEMBER_COLS).eq("id", memberId).maybeSingle();

  // Uniform failure — never reveal whether the id or the PIN was the problem.
  if (error || !m || !m.member_pin_hash) return json({ error: "invalid_login" }, 401);

  let ok = false;
  try { ok = bcrypt.compareSync(pin, m.member_pin_hash); } catch { ok = false; }
  if (!ok) return json({ error: "invalid_login" }, 401);

  // Best-effort last-login stamp (service role; non-fatal).
  try {
    await sb.from("members").update({ member_last_login: new Date().toISOString() }).eq("id", m.id);
  } catch { /* ignore */ }

  return json(await mintSession(m));
});
