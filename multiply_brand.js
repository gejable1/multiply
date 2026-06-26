/* multiply_brand.js?v=1 — MULTIPLY shared church-name brand painter.
 *
 * Standalone UMD sibling of multiply_close.js / multiply_tenancy.js (NOT folded
 * into multiply_shared.js, so no ?v= lockstep). Include on any page whose chrome
 * shows the church's name.
 *
 * Reads the church-scoped JWT from sessionStorage.multiply_jwt (the one canonical
 * key — same as shared.js getDB + tenancy.js, Inv #204), fetches the own-church
 * row ONCE (churches own-row RLS, migration 035 -> exactly this tenant's row), then
 *   - auto-paints any [data-church-tmpl] / [data-church-name] element on load, and
 *   - resolves MultiplyBrand.churchName() -> Promise<string|null> for JS/PDF use.
 *
 * Anti-leak: the page's STATIC fallback carries NO church name (just "MULTIPLY ...");
 * the module overwrites it only once a real name resolves. No JWT / no row / any
 * failure -> fallback stays -> generic MULTIPLY, never a wrong tenant.
 *
 * Template tokens: {church} -> full name, {CHURCH} -> UPPER, {slug} -> slug, {SLUG} -> UPPER.
 */
(function (global) {
  'use strict';
  var SB_URL  = 'https://tirzeikbflolaclgtket.supabase.co';
  var SB_ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpcnplaWtiZmxvbGFjbGd0a2V0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcxMTYwOTksImV4cCI6MjA5MjY5MjA5OX0.ejHouXj7NOB3yUmcdOuUFfk-HHPbfyCmQACb4xNk2V8';
  var JWT_KEY = 'multiply_jwt';

  function _jwt() {
    try {
      var raw = sessionStorage.getItem(JWT_KEY);
      if (!raw) return null;
      var j = JSON.parse(raw);
      if (!j || !j.token) return null;
      if (j.expires_at && Date.parse(j.expires_at) <= Date.now()) return null;
      return j.token;
    } catch (e) { return null; }
  }

  function _client(token) {
    var opts = {
      auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false },
      global: { headers: { Authorization: 'Bearer ' + token } }
    };
    if (global.supabase && global.supabase.createClient) {
      return Promise.resolve(global.supabase.createClient(SB_URL, SB_ANON, opts));
    }
    return import('https://esm.sh/@supabase/supabase-js@2')
      .then(function (m) { return m.createClient(SB_URL, SB_ANON, opts); });
  }

  var _rowPromise = null;
  function _row() {
    if (_rowPromise) return _rowPromise;
    _rowPromise = (function () {
      var token = _jwt();
      if (!token) return Promise.resolve(null);
      return _client(token).then(function (db) {
        return db.from('churches').select('name, slug').limit(1).maybeSingle();
      }).then(function (res) {
        if (!res || res.error || !res.data) return null;
        var nm = (res.data.name || '').trim();
        if (!nm) return null;
        return { name: nm, slug: (res.data.slug || '').trim() || nm };
      }).catch(function () { return null; });
    })();
    return _rowPromise;
  }

  function churchName() { return _row().then(function (r) { return r ? r.name : null; }); }
  function church()     { return _row(); }

  function _applyTo(el, c) {
    var tmpl = el.getAttribute('data-church-tmpl');
    if (tmpl != null) {
      el.textContent = tmpl
        .replace(/\{church\}/g, c.name)
        .replace(/\{CHURCH\}/g, c.name.toUpperCase())
        .replace(/\{slug\}/g, c.slug)
        .replace(/\{SLUG\}/g, c.slug.toUpperCase());
    } else {
      el.textContent = c.name;
    }
  }

  function paint() {
    _row().then(function (c) {
      if (!c) return;
      var els = document.querySelectorAll('[data-church-tmpl],[data-church-name]');
      for (var i = 0; i < els.length; i++) _applyTo(els[i], c);
    });
  }

  function _onReady(fn) {
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', fn);
    else fn();
  }
  _onReady(paint);

  global.MultiplyBrand = { churchName: churchName, church: church, paint: paint };
})(typeof window !== 'undefined' ? window : this);
