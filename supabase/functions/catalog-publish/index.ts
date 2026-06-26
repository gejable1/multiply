// supabase/functions/catalog-publish/index.ts
//
// MULTIPLY — platform publish lane for SHARED-CONTENT BASE rows (church_id = NULL).
// Service-role (bypasses RLS, explicitly stamps church_id NULL — Inv #211).
// Gate: caller's HS256 JWT is verified here, then members.is_platform_admin must be TRUE
// (decoupled from any tenant church_id — S49 migration 036).
//
// Contract:  POST { table, op:'insert'|'update'|'upsert'|'delete', id?, payload?, onConflict? }  ->  { data, error }
// Locks: (1) table ∈ 7-table allowlist  (2) op allowlist  (3) insert/upsert force church_id=NULL
//        (4) update/delete scoped .is('church_id', null) — BASE rows only, never an overlay.
//
// Deploy:  supabase functions deploy catalog-publish --no-verify-jwt
// Secrets: JWT_SECRET (reuse), SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY (auto-injected).

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { verify } from "https://deno.land/x/djwt@v3.0.2/mod.ts";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, content-type, apikey",
};

const WRITABLE = new Set([
  "btli_quizzes", "cohort_programs", "library_chapters", "library_quizzes",
  "library_resources", "pipeline_lessons", "usbong_quizzes",
]);
const OPS = new Set(["insert", "update", "upsert", "delete"]);

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
  if (!sub || typeof sub !== "string") return fail("invalid_token", 401);

  const SB_URL = Deno.env.get("SUPABASE_URL")!;
  const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const db = createClient(SB_URL, SERVICE_KEY, { auth: { persistSession: false } });

  const { data: me, error: meErr } = await db
    .from("members").select("id, is_platform_admin").eq("id", sub).maybeSingle();
  if (meErr || !me || me.is_platform_admin !== true) return fail("not_platform_admin", 403);

  let body: { table?: string; op?: string; id?: string; payload?: Record<string, unknown>; onConflict?: string };
  try { body = await req.json(); } catch { return fail("bad_json", 400); }
  const { table, op, id } = body;
  const inPayload = body.payload;
  if (!table || !WRITABLE.has(table)) return fail("table_not_allowed", 400);
  if (!op || !OPS.has(op)) return fail("op_not_allowed", 400);

  const needsPayload = (op === "insert" || op === "update" || op === "upsert");
  if (needsPayload && (!inPayload || typeof inPayload !== "object" || Array.isArray(inPayload)))
    return fail("payload_required", 400);

  try {
    if (op === "insert") {
      const row = { ...inPayload, church_id: null };
      const { data, error } = await db.from(table).insert(row).select().single();
      if (error) return fail(error.message, 400);
      return json({ data, error: null });
    }
    if (op === "upsert") {
      const row = { ...inPayload, church_id: null };
      const onConflict = typeof body.onConflict === "string" ? body.onConflict : undefined;
      const { data, error } = await db.from(table)
        .upsert(row, onConflict ? { onConflict } : undefined).select().single();
      if (error) return fail(error.message, 400);
      return json({ data, error: null });
    }
    if (op === "update") {
      if (!id || typeof id !== "string") return fail("id_required", 400);
      const patch = { ...inPayload };
      delete (patch as Record<string, unknown>).church_id;
      const { data, error } = await db.from(table).update(patch)
        .is("church_id", null).eq("id", id).select().single();
      if (error) return fail(error.message, 400);
      return json({ data, error: null });
    }
    if (!id || typeof id !== "string") return fail("id_required", 400);
    const { data, error } = await db.from(table).delete()
      .is("church_id", null).eq("id", id).select();
    if (error) return fail(error.message, 400);
    if (!data || data.length === 0) return fail("not_found_or_not_base", 404);
    return json({ data, error: null });
  } catch (e) {
    return fail(String(e), 500);
  }
});
