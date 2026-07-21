// supabase/functions/token-login/index.ts
//
// MULTIPLY — mint a short-lived church-scoped JWT from a profile_tokens token.
// Cold-link entry (no PIN/login): assessment + member_self_edit pages POST {token}.
// Mirrors auth-login's claim shape + signing so getDB()'s Bearer header works identically,
// so church_id flows to auth_church_id() and the set_church_id_from_jwt trigger.
//
// Deploy:  supabase functions deploy token-login --no-verify-jwt
// Secret reused: JWT_SECRET  (the SAME Legacy JWT Secret auth-login already uses — do NOT create a new one)

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { create, getNumericDate } from "https://deno.land/x/djwt@v3.0.2/mod.ts";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, content-type",
};

const JWT_TTL_SECONDS = 2 * 60 * 60; // +2h (decision #3)
const LEADER_MIN_LEVEL = 2;          // pipeline_level >= 2 == leader (#322)

function fail(status = 401) {
  return new Response(JSON.stringify({ error: "invalid_token" }), {
    status,
    headers: { ...CORS, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return fail(405);
  const ua = req.headers.get("user-agent") || "";

  let token: string | null = null;
  try { token = (await req.json())?.token ?? null; } catch { return fail(400); }
  if (!token || typeof token !== "string") return fail(400);

  const SB_URL = Deno.env.get("SUPABASE_URL")!;
  const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const SECRET = Deno.env.get("JWT_SECRET");
  if (!SECRET) return fail(500);

  // Service role bypasses RLS — intentional: this endpoint IS the server-trusted gate.
  const db = createClient(SB_URL, SERVICE_KEY, { auth: { persistSession: false } });

  // 1) Validate the token.
  const { data: tok, error: tErr } = await db
    .from("profile_tokens")
    .select("id, member_id, expires_at, used_count")
    .eq("token", token)
    .maybeSingle();
  if (tErr || !tok) return fail();
  if (new Date(tok.expires_at).getTime() <= Date.now()) return fail();

  // 2) Resolve the member's church + identity.
  const { data: m, error: mErr } = await db
    .from("members")
    .select("id, name, church_id, pipeline_level, is_test_member, is_external_user")
    .eq("id", tok.member_id)
    .maybeSingle();
  if (mErr || !m || !m.church_id) return fail();

  // 3) Mint the church-scoped JWT (same claim shape as auth-login).
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(SECRET),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign", "verify"],
  );
  const exp = getNumericDate(JWT_TTL_SECONDS);
  const jwt = await create(
    { alg: "HS256", typ: "JWT" },
    {
      sub: m.id,
      role: "authenticated",
      aud: "authenticated",
      church_id: m.church_id,
      leader_level: m.pipeline_level ?? 0,
      name: m.name,
      is_test: !!m.is_test_member,
      is_guest: !!m.is_external_user,
      iat: getNumericDate(0),
      exp,
    },
    key,
  );

  // 4) Best-effort usage bump (non-fatal).
  try {
    await db.from("profile_tokens")
      .update({ used_count: (tok.used_count ?? 0) + 1, used_at: new Date().toISOString() })
      .eq("id", tok.id);
  } catch { /* non-fatal */ }

  // 5) Telemetry (S78 #323): record this cold-link login in the unified
  //    app_sessions logbook + reap expired-open rows. Best-effort - never
  //    blocks the token exchange. expires_at mirrors the JWT's own 2h TTL.
  try {
    await db.from("app_sessions").insert({
      member_id: m.id,
      is_leader: (m.pipeline_level ?? 0) >= LEADER_MIN_LEVEL,
      church_id: m.church_id,
      expires_at: new Date(exp * 1000).toISOString(),
      user_agent_hint: ua.slice(0, 180),
    });
  } catch { /* non-fatal */ }
  try { await db.rpc("reap_expired_sessions"); } catch { /* non-fatal */ }

  return new Response(JSON.stringify({
    token: jwt,
    church_id: m.church_id,
    member_id: m.id,
    expires_at: new Date(exp * 1000).toISOString(),
  }), { headers: { ...CORS, "Content-Type": "application/json" } });
});
