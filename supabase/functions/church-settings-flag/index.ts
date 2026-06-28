// supabase/functions/church-settings-flag/index.ts
//
// MULTIPLY — pastor-gated toggle for a single church UI feature flag.
// Sets churches.settings.mlt_add_member (boolean) for the CALLER'S OWN church only.
// Service-role (bypasses RLS); merges ONE key so name/branding/other settings stay untouched.
// Gate: caller's HS256 JWT verified here; member must be pipeline_level >= 5 (pastor)
//       AND belong to the church named in the JWT church_id claim.
//
// Contract:  POST { enabled: boolean }  ->  { data: { mlt_add_member: boolean }, error }
// Church is derived from the JWT (never the body) — a pastor can only flip their OWN church.
//
// Deploy:  supabase functions deploy church-settings-flag --no-verify-jwt
// Secrets: JWT_SECRET (reuse), SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY (auto-injected).

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { verify } from "https://deno.land/x/djwt@v3.0.2/mod.ts";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, content-type, apikey",
};

const PASTOR_LEVEL = 5;

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, "Content-Type": "application/json" },
  });
}
const fail = (error: string, status: number) => json({ data: null, error }, status);

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return fail("method_not_allowed", 405);

  const authHeader = req.headers.get("Authorization") || "";
  const bm = authHeader.match(/^Bearer\s+(.+)$/i);
  if (!bm) return fail("missing_bearer", 401);
  const jwt = bm[1];

  const SECRET = Deno.env.get("JWT_SECRET");
  if (!SECRET) return fail("server_misconfigured", 500);

  let payload: Record<string, unknown>;
  try {
    const key = await crypto.subtle.importKey(
      "raw", new TextEncoder().encode(SECRET),
      { name: "HMAC", hash: "SHA-256" }, false, ["verify"],
    );
    payload = await verify(jwt, key) as Record<string, unknown>;
  } catch { return fail("invalid_token", 401); }

  const sub = payload?.sub;
  const churchClaim = payload?.church_id;
  if (!sub || typeof sub !== "string") return fail("invalid_token", 401);
  if (!churchClaim || typeof churchClaim !== "string") return fail("no_church_claim", 401);

  let body: { enabled?: unknown };
  try { body = await req.json(); } catch { return fail("bad_json", 400); }
  if (typeof body.enabled !== "boolean") return fail("enabled_must_be_boolean", 400);
  const enabled = body.enabled;

  const SB_URL = Deno.env.get("SUPABASE_URL")!;
  const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const db = createClient(SB_URL, SERVICE_KEY, { auth: { persistSession: false } });

  // Authz: caller must be a pastor (pipeline_level >= 5) of the church in the JWT claim.
  const { data: me, error: meErr } = await db
    .from("members").select("id, pipeline_level, church_id").eq("id", sub).maybeSingle();
  if (meErr) return fail(meErr.message, 500);
  if (!me) return fail("member_not_found", 403);
  if (me.church_id !== churchClaim) return fail("church_mismatch", 403);
  if ((me.pipeline_level ?? 0) < PASTOR_LEVEL) return fail("not_pastor", 403);

  // Read current settings, merge ONLY the one key, write back — scoped to own church.
  const { data: ch, error: chErr } = await db
    .from("churches").select("settings").eq("id", churchClaim).maybeSingle();
  if (chErr) return fail(chErr.message, 500);
  if (!ch) return fail("church_not_found", 404);

  const existing = (ch.settings && typeof ch.settings === "object" && !Array.isArray(ch.settings))
    ? ch.settings as Record<string, unknown> : {};
  const merged = { ...existing, mlt_add_member: enabled };

  const { error: upErr } = await db
    .from("churches")
    .update({ settings: merged, updated_at: new Date().toISOString() })
    .eq("id", churchClaim);
  if (upErr) return fail(upErr.message, 400);

  return json({ data: { mlt_add_member: enabled }, error: null });
});
