// supabase/functions/church-settings-flag/index.ts
//
// MULTIPLY — pastor-gated toggle for a single church UI feature flag.
// Sets ALLOWLISTED churches.settings keys for the CALLER'S OWN church only (S91).
// Service-role (bypasses RLS); merges ONE key so name/branding/other settings stay untouched.
// Gate: caller's HS256 JWT verified here; member must be pipeline_level >= 5 (pastor)
//       AND belong to the church named in the JWT church_id claim.
//
// Contract:  POST { key?: string, enabled: boolean }            (boolean toggles;
//                key defaults to "mlt_add_member" so the S51 caller is unchanged)
//            POST { key: "mmt_lock_cancel", event, date|null }  (pastor cancels/
//                restores one service date church-wide; null date = restore)
//         -> { data: { [key]: value }, error }
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

  let body: { key?: unknown; enabled?: unknown; event?: unknown; date?: unknown };
  try { body = await req.json(); } catch { return fail("bad_json", 400); }
  // S91: generalized. Boolean toggles by allowlist (missing key defaults to
  // mlt_add_member, keeping the S51 caller byte-unchanged) + the service-
  // cancellation object key. Anything else is refused server-side.
  const BOOL_KEYS = ["mlt_add_member", "mmt_attendance_lock"];
  const CANCEL_KEY = "mmt_lock_cancel";
  const CANCEL_EVENTS = ["Sunday Service", "Prayer Meeting"];
  const key = (typeof body.key === "string" && body.key.length) ? body.key : "mlt_add_member";
  let enabled = false;
  let cancelEvent = "";
  let cancelDate: string | null = null;
  if (BOOL_KEYS.includes(key)) {
    if (typeof body.enabled !== "boolean") return fail("enabled_must_be_boolean", 400);
    enabled = body.enabled;
  } else if (key === CANCEL_KEY) {
    if (typeof body.event !== "string" || !CANCEL_EVENTS.includes(body.event)) return fail("bad_cancel_event", 400);
    if (body.date !== null && (typeof body.date !== "string" || !/^\d{4}-\d{2}-\d{2}$/.test(body.date))) return fail("bad_cancel_date", 400);
    cancelEvent = body.event;
    cancelDate = body.date as string | null;
  } else {
    return fail("key_not_allowed", 400);
  }

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
  let merged: Record<string, unknown>;
  if (key === CANCEL_KEY) {
    const cur = (existing[CANCEL_KEY] && typeof existing[CANCEL_KEY] === "object" && !Array.isArray(existing[CANCEL_KEY]))
      ? { ...(existing[CANCEL_KEY] as Record<string, unknown>) } : {};
    if (cancelDate === null) delete cur[cancelEvent];
    else cur[cancelEvent] = cancelDate;
    merged = { ...existing, [CANCEL_KEY]: cur };
  } else {
    merged = { ...existing, [key]: enabled };
  }

  const { error: upErr } = await db
    .from("churches")
    .update({ settings: merged, updated_at: new Date().toISOString() })
    .eq("id", churchClaim);
  if (upErr) return fail(upErr.message, 400);

  return json({ data: (key === CANCEL_KEY ? { [CANCEL_KEY]: merged[CANCEL_KEY] } : { [key]: enabled }), error: null });
});
