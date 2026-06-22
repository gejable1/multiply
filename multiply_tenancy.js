/* multiply_tenancy.js — v2
 *
 * Standalone tenancy bootstrap for MULTIPLY cold-capable pages
 * (the 7 assessment instruments + member_self_edit.html).
 *
 * WHY separate (not in multiply_shared.js): these pages deliberately do not load
 * the big shared.js (Inv #11 — avoids a ?v= lockstep across all shared.js
 * consumers). This mirrors multiply_close.js: own ?v=, classic <script>, self-contained.
 *
 * Load order on the page (AFTER the supabase UMD script, BEFORE the page script):
 *   <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
 *   <script src="multiply_tenancy.js?v=2"></script>
 *
 * window.MultiplyTenancy:
 *   await tokenLogin(token) -> POST {token} to the token-login EF, store the
 *                             church-scoped JWT in sessionStorage.multiply_jwt,
 *                             return { token, church_id, member_id, expires_at }.
 *   await bootstrap()      -> resolve the member id from the page URL, handling
 *                            both the cold (?token=) and in-app (?id=) paths.
 *                            COLD (token present + no valid session): tokenLogin,
 *                            then return currentMemberId(); on failure replace the
 *                            page body with a bilingual "link expired" notice and
 *                            THROW so the page halts. IN-APP (no token): return
 *                            ?id= unchanged (getDB() attaches the existing JWT).
 *   getDB()                -> Supabase client with the church JWT attached as
 *                            Bearer when present+valid, else anon. SYNCHRONOUS.
 *   readJwt(), currentMemberId(), churchId(), hasValidSession()
 *
 * The multiply_jwt sessionStorage key is the SAME one multiply_shared.js getDB
 * reads — interop by design.
 */
(function (global) {
  'use strict';

  var SB_URL  = 'https://tirzeikbflolaclgtket.supabase.co';
  var SB_ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpcnplaWtiZmxvbGFjbGd0a2V0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcxMTYwOTksImV4cCI6MjA5MjY5MjA5OX0.ejHouXj7NOB3yUmcdOuUFfk-HHPbfyCmQACb4xNk2V8';
  var EF_URL  = SB_URL.replace('.supabase.co', '.functions.supabase.co') + '/token-login';
  var JWT_KEY = 'multiply_jwt';

  function _readStored() {
    try {
      var raw = sessionStorage.getItem(JWT_KEY);
      if (!raw) return null;
      var obj = JSON.parse(raw);
      if (!obj || !obj.token || !obj.expires_at) return null;
      if (Date.parse(obj.expires_at) <= Date.now()) return null;
      return obj;
    } catch (e) { return null; }
  }

  function _decodeClaims(jwt) {
    try {
      var p = jwt.split('.')[1].replace(/-/g, '+').replace(/_/g, '/');
      while (p.length % 4) p += '=';
      return JSON.parse(atob(p));
    } catch (e) { return null; }
  }

  function readJwt() { var s = _readStored(); return s ? s.token : null; }
  function hasValidSession() { return !!_readStored(); }

  function currentMemberId() {
    var s = _readStored(); if (!s) return null;
    if (s.member_id) return s.member_id;
    var c = _decodeClaims(s.token); return c ? (c.sub || null) : null;
  }

  function churchId() {
    var s = _readStored(); if (!s) return null;
    if (s.church_id) return s.church_id;
    var c = _decodeClaims(s.token); return c ? (c.church_id || null) : null;
  }

  async function tokenLogin(token) {
    if (!token) throw new Error('token required');
    var res = await fetch(EF_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token: token })
    });
    if (!res.ok) {
      var msg = 'token_login_failed';
      try { msg = (await res.json()).error || msg; } catch (e) {}
      throw new Error(msg);
    }
    var data = await res.json();
    sessionStorage.setItem(JWT_KEY, JSON.stringify(data));
    _db = null;
    return data;
  }

  async function bootstrap() {
    var params = new URLSearchParams(location.search);
    var token = params.get('token');
    if (token) {
      if (!hasValidSession()) {
        try {
          await tokenLogin(token);
        } catch (e) {
          document.body.innerHTML =
            '<div style="max-width:520px;margin:80px auto;padding:24px;font-family:system-ui,-apple-system,sans-serif;text-align:center;color:#b00">' +
            '<h2>Link expired or invalid</h2>' +
            '<p>Please ask your leader for a fresh link.</p>' +
            '<p style="color:#777;margin-top:.5rem">Paso na o di-wasto ang link — pakihingi sa iyong lider ang bagong link.</p>' +
            '</div>';
          throw new Error('token_login_failed');
        }
      }
      return currentMemberId();
    }
    return params.get('id');
  }

  var _db = null;
  function getDB() {
    if (_db) return _db;
    if (typeof global.supabase === 'undefined' || !global.supabase.createClient) {
      console.error('[MultiplyTenancy] Supabase SDK not loaded. Include @supabase/supabase-js BEFORE multiply_tenancy.js.');
      return null;
    }
    var opts = { auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false } };
    var jwt = readJwt();
    if (jwt) opts.global = { headers: { Authorization: 'Bearer ' + jwt } };
    _db = global.supabase.createClient(SB_URL, SB_ANON, opts);
    return _db;
  }

  global.MultiplyTenancy = {
    tokenLogin: tokenLogin,
    bootstrap: bootstrap,
    getDB: getDB,
    readJwt: readJwt,
    currentMemberId: currentMemberId,
    churchId: churchId,
    hasValidSession: hasValidSession
  };
})(window);
