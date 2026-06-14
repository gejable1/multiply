// supabase/functions/schema-dump/index.ts
//
// MULTIPLY — full database schema dump as JSON.
// Captures, for the requested schema(s): tables/views, columns (type, nullable,
// default, identity, comment), primary keys, foreign keys (incl. on_update /
// on_delete), unique + check constraints, indexes (with definitions), RLS
// policies, enum types, functions (incl. SECURITY DEFINER flag), and triggers.
//
// Every catalog query below was validated against a live PostgreSQL 16 instance.
//
// ── Deploy ──────────────────────────────────────────────────────────────────
//   supabase functions deploy schema-dump --no-verify-jwt
//   supabase secrets set SCHEMA_DUMP_SECRET="<a-long-random-string>"
//
// ── Call ────────────────────────────────────────────────────────────────────
//   curl -H "x-schema-secret: <secret>" \
//        "https://<project-ref>.functions.supabase.co/schema-dump?schemas=public&download=1" \
//        -o schema.json
//
//   Query params:
//     schemas   comma-separated list (default: "public"). e.g. schemas=public,auth
//     download  "1" to send a Content-Disposition attachment (schema.json)
//     pretty    "0" to minify (default: pretty-printed)
//
// SUPABASE_DB_URL is injected automatically into Edge Functions — no key needed.
// ─────────────────────────────────────────────────────────────────────────────

import postgres from "https://deno.land/x/postgresjs@v3.4.5/mod.js";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-schema-secret, content-type",
};

// ── The validated catalog queries. $1 = text[] of schema names. ──────────────
const Q = {
  meta: `select current_database() as database, version() as version`,

  tables: `
    select c.relname as name,
           case c.relkind when 'r' then 'table' when 'v' then 'view'
                when 'm' then 'materialized_view' when 'p' then 'partitioned_table'
                else c.relkind::text end as kind,
           obj_description(c.oid) as comment,
           c.relrowsecurity as rls_enabled,
           c.reltuples::bigint as est_rows
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = any($1::text[]) and c.relkind in ('r','v','m','p')
    order by n.nspname, c.relname`,

  columns: `
    select t.relname as table_name, a.attname as column_name, a.attnum as ordinal,
           format_type(a.atttypid, a.atttypmod) as data_type,
           a.attnotnull as not_null,
           pg_get_expr(d.adbin, d.adrelid) as default_expr,
           (a.attidentity <> '') as is_identity,
           col_description(t.oid, a.attnum) as comment
    from pg_attribute a
    join pg_class t on t.oid = a.attrelid
    join pg_namespace n on n.oid = t.relnamespace
    left join pg_attrdef d on d.adrelid = t.oid and d.adnum = a.attnum
    where n.nspname = any($1::text[]) and t.relkind in ('r','v','m','p')
      and a.attnum > 0 and not a.attisdropped
    order by t.relname, a.attnum`,

  constraints: `
    select rel.relname as table_name, con.conname as name, con.contype as type,
           pg_get_constraintdef(con.oid) as definition,
           (select array_agg(att.attname order by k.ord)::text[]
              from unnest(con.conkey) with ordinality as k(attnum, ord)
              join pg_attribute att on att.attrelid = con.conrelid and att.attnum = k.attnum) as columns,
           fr.relname as foreign_table, fn.nspname as foreign_schema,
           (select array_agg(att.attname order by k.ord)::text[]
              from unnest(con.confkey) with ordinality as k(attnum, ord)
              join pg_attribute att on att.attrelid = con.confrelid and att.attnum = k.attnum) as foreign_columns,
           case con.confupdtype when 'a' then 'NO ACTION' when 'r' then 'RESTRICT'
                when 'c' then 'CASCADE' when 'n' then 'SET NULL' when 'd' then 'SET DEFAULT' end as on_update,
           case con.confdeltype when 'a' then 'NO ACTION' when 'r' then 'RESTRICT'
                when 'c' then 'CASCADE' when 'n' then 'SET NULL' when 'd' then 'SET DEFAULT' end as on_delete
    from pg_constraint con
    join pg_class rel on rel.oid = con.conrelid
    join pg_namespace nsp on nsp.oid = rel.relnamespace
    left join pg_class fr on fr.oid = con.confrelid
    left join pg_namespace fn on fn.oid = fr.relnamespace
    where nsp.nspname = any($1::text[])
    order by rel.relname, con.contype, con.conname`,

  indexes: `
    select t.relname as table_name, i.relname as index_name,
           ix.indisunique as is_unique, ix.indisprimary as is_primary,
           pg_get_indexdef(ix.indexrelid) as definition,
           (select array_agg(a.attname order by k.ord)::text[]
              from unnest(ix.indkey) with ordinality as k(attnum, ord)
              left join pg_attribute a on a.attrelid = t.oid and a.attnum = k.attnum
              where k.attnum <> 0) as columns
    from pg_index ix
    join pg_class i on i.oid = ix.indexrelid
    join pg_class t on t.oid = ix.indrelid
    join pg_namespace n on n.oid = t.relnamespace
    where n.nspname = any($1::text[])
    order by t.relname, i.relname`,

  policies: `
    select tablename as table_name, policyname as name, permissive,
           roles::text[] as roles, cmd, qual, with_check
    from pg_policies where schemaname = any($1::text[])
    order by tablename, policyname`,

  enums: `
    select n.nspname as schema, t.typname as name,
           array_agg(e.enumlabel order by e.enumsortorder)::text[] as values
    from pg_type t
    join pg_enum e on e.enumtypid = t.oid
    join pg_namespace n on n.oid = t.typnamespace
    where n.nspname = any($1::text[])
    group by n.nspname, t.typname order by t.typname`,

  functions: `
    select n.nspname as schema, p.proname as name,
           pg_get_function_identity_arguments(p.oid) as arguments,
           pg_get_function_result(p.oid) as returns,
           l.lanname as language, p.prosecdef as security_definer,
           case p.prokind when 'f' then 'function' when 'p' then 'procedure'
                when 'a' then 'aggregate' when 'w' then 'window' end as kind,
           case when p.prokind in ('f','p') then pg_get_functiondef(p.oid) else null end as definition
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    join pg_language l on l.oid = p.prolang
    where n.nspname = any($1::text[])
    order by p.proname`,

  triggers: `
    select t.relname as table_name, tg.tgname as name,
           pg_get_triggerdef(tg.oid) as definition
    from pg_trigger tg
    join pg_class t on t.oid = tg.tgrelid
    join pg_namespace n on n.oid = t.relnamespace
    where n.nspname = any($1::text[]) and not tg.tgisinternal
    order by t.relname, tg.tgname`,
};

// deno-lint-ignore no-explicit-any
function assemble(schemas: string[], meta: any, r: Record<string, any[]>) {
  const out: any = {
    generated_at: new Date().toISOString(),
    database: meta.database,
    postgres_version: meta.version,
    schemas,
    table_count: 0,
    tables: {} as Record<string, any>,
    enums: [] as any[],
    functions: [] as any[],
  };
  const tbl = (name: string) =>
    (out.tables[name] ??= {
      kind: null, comment: null, rls_enabled: false, est_rows: null,
      columns: [], primary_key: [], foreign_keys: [], unique_constraints: [],
      check_constraints: [], indexes: [], policies: [], triggers: [],
    });

  for (const t of r.tables) {
    Object.assign(tbl(t.name), {
      kind: t.kind, comment: t.comment, rls_enabled: t.rls_enabled,
      est_rows: Number(t.est_rows) < 0 ? null : Number(t.est_rows),
    });
  }
  for (const c of r.columns) {
    tbl(c.table_name).columns.push({
      name: c.column_name, ordinal: c.ordinal, data_type: c.data_type,
      nullable: !c.not_null, default: c.default_expr,
      is_identity: c.is_identity, comment: c.comment,
    });
  }
  for (const k of r.constraints) {
    const t = tbl(k.table_name);
    if (k.type === "p") t.primary_key = k.columns || [];
    else if (k.type === "f") {
      t.foreign_keys.push({
        name: k.name, columns: k.columns, foreign_schema: k.foreign_schema,
        foreign_table: k.foreign_table, foreign_columns: k.foreign_columns,
        on_update: k.on_update, on_delete: k.on_delete, definition: k.definition,
      });
    } else if (k.type === "u") {
      t.unique_constraints.push({ name: k.name, columns: k.columns });
    } else if (k.type === "c") {
      t.check_constraints.push({ name: k.name, definition: k.definition });
    }
  }
  for (const ix of r.indexes) {
    tbl(ix.table_name).indexes.push({
      name: ix.index_name, is_unique: ix.is_unique, is_primary: ix.is_primary,
      columns: ix.columns, definition: ix.definition,
    });
  }
  for (const p of r.policies) {
    tbl(p.table_name).policies.push({
      name: p.name, permissive: p.permissive, roles: p.roles,
      command: p.cmd, using: p.qual, with_check: p.with_check,
    });
  }
  for (const tg of r.triggers) {
    tbl(tg.table_name).triggers.push({ name: tg.name, definition: tg.definition });
  }
  out.enums = r.enums.map((e) => ({ schema: e.schema, name: e.name, values: e.values }));
  out.functions = r.functions.map((f) => ({
    schema: f.schema, name: f.name, arguments: f.arguments, returns: f.returns,
    language: f.language, security_definer: f.security_definer, kind: f.kind,
    definition: f.definition,
  }));
  out.table_count = Object.keys(out.tables).length;
  return out;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });

  // ── Auth gate: shared secret. Deploy with --no-verify-jwt; protect here. ──
  const secret = Deno.env.get("SCHEMA_DUMP_SECRET");
  if (!secret) {
    return json({ error: "SCHEMA_DUMP_SECRET is not set on the function." }, 500);
  }
  if (req.headers.get("x-schema-secret") !== secret) {
    return json({ error: "Unauthorized." }, 401);
  }

  const url = new URL(req.url);
  const schemas = (url.searchParams.get("schemas") || "public")
    .split(",").map((s) => s.trim()).filter(Boolean);
  const pretty = url.searchParams.get("pretty") !== "0";
  const download = url.searchParams.get("download") === "1";

  const dbUrl = Deno.env.get("SUPABASE_DB_URL");
  if (!dbUrl) return json({ error: "SUPABASE_DB_URL unavailable." }, 500);

  const sql = postgres(dbUrl, { prepare: false, idle_timeout: 5, max: 1 });
  try {
    const meta = (await sql.unsafe(Q.meta))[0];
    const r: Record<string, any[]> = {};
    for (const [key, query] of Object.entries(Q)) {
      if (key === "meta") continue;
      r[key] = await sql.unsafe(query, [schemas]);
    }
    const dump = assemble(schemas, meta, r);
    const body = pretty ? JSON.stringify(dump, null, 2) : JSON.stringify(dump);
    const headers: Record<string, string> = {
      ...CORS,
      "content-type": "application/json; charset=utf-8",
    };
    if (download) headers["content-disposition"] = 'attachment; filename="schema.json"';
    return new Response(body, { headers });
  } catch (e) {
    return json({ error: String(e?.message ?? e) }, 500);
  } finally {
    await sql.end({ timeout: 5 });
  }
});

function json(obj: unknown, status = 200) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { ...CORS, "content-type": "application/json; charset=utf-8" },
  });
}
