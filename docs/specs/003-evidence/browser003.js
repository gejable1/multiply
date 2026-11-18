// Spec 003 browser test (+ Spec 002 helpers) - the REAL member_tool.html in Chromium against a fake
// Supabase holding ONE test member (is_test_member) and practice devotionals.
// Nothing leaves this machine. Clock: Tue 2026-11-03 09:00 Manila (scenario 6: Sun Nov 8).
// Usage: node browser003.js <repo dir> <dir with OLD member_tool.html + multiply-sw.js> <out dir>
'use strict';
const path = require('path');
const fs = require('fs');
const http = require('http');
const { chromium } = require('playwright');

const REPO = process.argv[2], OLD = process.argv[3], OUT = process.argv[4];
const SUPA_UMD = path.join(__dirname, 'node_modules/@supabase/supabase-js/dist/umd/supabase.js');
const ME = 'TEST-MEMBER-1';
const ymd = d => d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');

function freshDb() {
  const db = { members: [{ id: ME, name: 'Test Member (practice)', is_test_member: true, is_external_user: false, pipeline_level: 1,
      discipler_id: null, lc_group: null, church_id: 'c-test', status: 'active', share_with_lc: false }],
    devotionals: [], devotional_reflections: [], attendance: [] };
  // Practice devotionals Oct 19 - Nov 7 (no Sundays)
  for (let d = new Date('2026-10-19T00:00:00'); d <= new Date('2026-11-07T00:00:00'); d.setDate(d.getDate() + 1)) {
    if (d.getDay() === 0) continue;
    const s = ymd(d);
    db.devotionals.push({ id: 'dv-' + s, church_id: 'c-test', entry_date: s, title: 'Practice devotional ' + s, scripture_ref: 'Psalm 23:1',
      scripture_text: 'The Lord is my shepherd; I shall not want.', story: 'A short practice story.', explanation: 'A short practice explanation.',
      response: 'A short practice response.', prayer: 'A short practice prayer.', reflection_questions: ['What is God saying to you today?'], author: 'Practice' });
  }
  // Existing streak: Oct 26-31 + Nov 2 (Sunday Nov 1 skipped) = 7 days before today
  ['2026-10-26','2026-10-27','2026-10-28','2026-10-29','2026-10-30','2026-10-31','2026-11-02'].forEach((s, i) =>
    db.attendance.push({ id: 'at' + i, member_id: ME, event_type: 'devotional', event_date: s, present: true }));
  return db;
}

// ---- tiny PostgREST emulator ----
function applyFilters(rows, params) {
  for (const [k, v] of params) {
    if (['select', 'order', 'limit', 'offset', 'on_conflict', 'columns'].includes(k)) continue;
    let m = v.match(/^(eq|neq|lt|lte|gt|gte|in|is)\.(.*)$/); if (!m) continue;
    const [, op, val] = m;
    const f = { eq: x => String(x) === val, neq: x => String(x) !== val, lt: x => x < val, lte: x => x <= val, gt: x => x > val, gte: x => x >= val,
      in: x => val.replace(/^\(|\)$/g, '').split(',').map(s => s.replace(/^"|"$/g, '')).includes(String(x)), is: x => (val === 'null' ? x == null : String(x) === val) }[op];
    rows = rows.filter(r => f(r[k]));
  }
  return rows;
}
function handle(db, req) {
  const u = new URL(req.url()); const method = req.method();
  if (u.pathname.startsWith('/rest/v1/rpc/') || u.pathname.startsWith('/functions/') || u.pathname.startsWith('/storage/') || u.pathname.startsWith('/auth/'))
    return { status: 200, body: '[]' };
  const m = u.pathname.match(/\/rest\/v1\/([^/?]+)/); if (!m) return { status: 200, body: '[]' };
  const t = m[1]; db[t] = db[t] || []; const p = u.searchParams; const accept = req.headers()['accept'] || '';
  const single = accept.includes('vnd.pgrst.object');
  const reply = rows => single ? (rows.length === 1 ? { status: 200, body: JSON.stringify(rows[0]) } : { status: 406, body: JSON.stringify({ code: 'PGRST116', message: 'JSON object requested, multiple (or no) rows returned', details: `${rows.length} rows` }) })
                                : { status: method === 'POST' ? 201 : 200, body: JSON.stringify(rows) };
  if (method === 'GET' || method === 'HEAD') {
    let rows = applyFilters(db[t], p);
    const ord = p.get('order'); if (ord) { const [c, dir] = ord.split(',')[0].split('.'); rows = rows.slice().sort((a, b) => (a[c] < b[c] ? -1 : a[c] > b[c] ? 1 : 0) * (dir === 'desc' ? -1 : 1)); }
    const lim = p.get('limit'); if (lim) rows = rows.slice(0, +lim);
    return reply(rows.map(r => ({ ...r })));
  }
  const body = JSON.parse(req.postData() || 'null'); const arr = Array.isArray(body) ? body : [body];
  if (method === 'POST') {
    const conflict = p.get('on_conflict'); const out = [];
    for (const r of arr) {
      let ex = conflict ? db[t].find(x => conflict.split(',').every(c => x[c] === r[c])) : null;
      if (ex) { Object.assign(ex, r); out.push({ ...ex }); }
      else { const row = { id: t + '-' + (db[t].length + 1) + '-' + Math.random().toString(36).slice(2, 7), ...r }; db[t].push(row); out.push({ ...row }); }
    }
    return reply(out);
  }
  if (method === 'PATCH') { const rows = applyFilters(db[t], p); rows.forEach(r => Object.assign(r, body)); return reply(rows.map(r => ({ ...r }))); }
  if (method === 'DELETE') { const rows = applyFilters(db[t], p); db[t] = db[t].filter(r => !rows.includes(r)); return reply([]); }
  return { status: 200, body: '[]' };
}

const words = n => Array.from({ length: n }, (_, i) => ['God', 'is', 'faithful', 'and', 'His', 'mercy', 'is', 'new', 'every', 'morning', 'for', 'me', 'today', 'and', 'always'][i % 15]).join(' ');

// ===== Spec 003 additions =====
// Usage: node browser003.js <repo dir> <dir with OLD (main) member_tool.html + multiply-sw.js> <out dir>
const OLDDIR = OLD;
const FRIENDLY_EN = 'Not saved yet — your words are still here. Check your signal and tap Save again.';
const FRIENDLY_TL = 'Hindi pa na-save — nandito pa ang isinulat mo. Tingnan ang signal at i-tap muli ang Save.';

// fault injection on top of handle(): dupOnce (Postgres 23505 on the upsert), offline, delayMs
function handle3(db, req) {
  const u = new URL(req.url());
  if (db.__dupOnce && req.method() === 'POST' && /\/rest\/v1\/devotional_reflections/.test(u.pathname) && u.searchParams.get('on_conflict')) {
    db.__dupOnce = false; db.__dupHits = (db.__dupHits || 0) + 1;
    return { status: 409, body: JSON.stringify({ code: '23505', message: 'duplicate key value violates unique constraint "devotional_reflections_member_id_entry_date_key"', details: null, hint: null }) };
  }
  if (req.method() === 'PATCH' && /devotional_reflections/.test(u.pathname)) db.__patches = (db.__patches || 0) + 1;
  return handle(db, req);
}

(async () => {
  // ---------- static server with phases + fault flags (for the service worker test) ----------
  const srvState = { phase: 'new', down: false, htmlDelay: 0, marker: '' };
  const srv = http.createServer(async (req, res) => {
    if (srvState.down) { req.socket.destroy(); return; }
    const rel = decodeURIComponent(req.url.split('?')[0]);
    if (rel === '/__swtest.html') { res.writeHead(200, { 'Content-Type': 'text/html' }); return res.end('<!doctype html><title>swtest</title><body>sw test page</body>'); }
    let p = path.join(REPO, rel === '/' ? '/index.html' : rel); if (process.env.DBG) console.log('  srv', srvState.phase, req.url);
    if (srvState.phase === 'old' && (rel === '/member_tool.html' || rel === '/multiply-sw.js')) p = path.join(OLDDIR, path.basename(rel));
    if (srvState.phase === 'oldsw' && rel === '/multiply-sw.js') p = path.join(OLDDIR, 'multiply-sw.js');
    if (!fs.existsSync(p) || fs.statSync(p).isDirectory()) { res.writeHead(404); return res.end(); }
    if (p.endsWith('.html') && srvState.htmlDelay) await new Promise(r => setTimeout(r, srvState.htmlDelay));
    let body = fs.readFileSync(p);
    if (rel === '/member_tool.html' && srvState.marker) body = Buffer.concat([body, Buffer.from('\n<!-- ' + srvState.marker + ' -->\n')]);
    res.writeHead(200, { 'Content-Type': p.endsWith('.js') ? 'text/javascript' : p.endsWith('.webmanifest') ? 'application/manifest+json' : p.endsWith('.png') ? 'image/png' : p.endsWith('.svg') ? 'image/svg+xml' : 'text/html', 'Cache-Control': 'no-store' });
    res.end(body);
  }).listen(0);
  const base = 'http://127.0.0.1:' + srv.address().port;
  const browser = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });

  async function open(db, { width = 390, height = 844, clock = '2026-11-03T09:00:00+08:00' } = {}) {
    const ctx = await browser.newContext({ viewport: { width, height }, timezoneId: 'Asia/Manila', deviceScaleFactor: 2, serviceWorkers: 'block' });
    const pg = await ctx.newPage();
    await pg.clock.install({ time: new Date(clock) }); await pg.clock.resume();
    await pg.route(/^https?:\/\/(?!127\.0\.0\.1)/, async r => {
      const url = r.request().url();
      if (/supabase\.co/.test(url)) {
        if (db.__offline) return r.abort('internetdisconnected');
        if (db.__delayMs) await new Promise(res => setTimeout(res, db.__delayMs));
        const o = handle3(db, r.request()); return r.fulfill({ status: o.status, contentType: 'application/json', body: o.body });
      }
      return r.fulfill({ status: 204, body: '' });
    });
    await pg.route('**/cdn.jsdelivr.net/**supabase-js**', r => r.fulfill({ contentType: 'text/javascript', body: fs.readFileSync(SUPA_UMD) }));
    await pg.route(/fonts\.(googleapis|gstatic)\.com/, r => r.fulfill({ contentType: 'text/css', body: '' }));
    await pg.addInitScript(me => {
      sessionStorage.setItem('multiply_member_session', JSON.stringify({ memberId: me, memberName: 'Test Member (practice)', expiresAt: '2099-01-01T00:00:00Z' }));
      window.__toasts = []; window.__errs = [];
      const ce = console.error.bind(console); console.error = (...a) => { window.__errs.push(a.map(String).join(' ')); ce(...a); };
    }, ME);
    pg.on('pageerror', e => console.log('  PAGE ERROR:', e.message));
    await pg.goto(base + '/member_tool.html');
    await pg.waitForFunction(() => typeof window.loadDevoStreak === 'function' && typeof devoStreak !== 'undefined', null, { timeout: 20000 });
    await pg.waitForTimeout(2500);
    await pg.evaluate(() => { const o = window.showToast; if (!o.__hooked) { window.showToast = function (m) { window.__toasts.push(String(m)); return o.apply(this, arguments); }; window.showToast.__hooked = true; } });
    return pg;
  }
  const dismissReminder = pg => pg.evaluate(() => { const m = document.getElementById('reflectionModal'); const t = m && getComputedStyle(m).display !== 'none' ? m.innerText : ''; if (t) _dismissReflectionReminder(); return t; });
  async function openToday(pg) { await dismissReminder(pg); await pg.evaluate(() => openDevoReader('today')); await pg.waitForSelector('#reflectionInput', { state: 'visible', timeout: 10000 }); }
  const typeWords = async (pg, n) => { await pg.focus('#reflectionInput'); await pg.keyboard.type(words(n)); };
  const TODAY = '2026-11-03';
  const rowsFor = (db, d) => db.attendance.filter(r => r.member_id === ME && r.event_type === 'devotional' && r.event_date === d).length;
  const reflRows = (db, d) => db.devotional_reflections.filter(r => r.member_id === ME && r.entry_date === d);
  const toasts = pg => pg.evaluate(() => window.__toasts.slice());
  const results = []; const rec = (n, title, expected, actual, ok) => { results.push({ n, title, expected, actual, ok }); console.log((ok ? 'PASS ' : 'FAIL ') + n + ' ' + title + ' :: ' + actual); };

  // ---- 1. Normal save ----
  { const db = freshDb(); const pg = await open(db); await openToday(pg); await typeWords(pg, 12); await pg.click('#reflectionSaveBtn'); await pg.waitForTimeout(1500);
    const t = await toasts(pg);
    rec('1', 'Normal: 12 words today, tap Save', '1 reflection row, 1 attendance row, streak toast', `reflections ${reflRows(db, TODAY).length}, attendance ${rowsFor(db, TODAY)}, toasts: ${t.join(' → ')}`,
      reflRows(db, TODAY).length === 1 && rowsFor(db, TODAY) === 1 && t.some(x => x.includes('🔥 Day 8'))); await pg.context().close(); }

  // ---- 2a. currentReflectionRow = null after auto-save wrote the row, edit, Save ----
  { const db = freshDb(); const pg = await open(db); await openToday(pg); await typeWords(pg, 12); await pg.waitForTimeout(2600);   // auto-save wrote row (+ credited, Spec 002)
    await pg.evaluate(() => { currentReflectionRow = null; window.__toasts.length = 0; });
    await pg.focus('#reflectionInput'); await pg.keyboard.press('End'); await pg.keyboard.type(' and I trust Him'); await pg.click('#reflectionSaveBtn'); await pg.waitForTimeout(1500);
    const t = await toasts(pg); const rows = reflRows(db, TODAY);
    rec('2a', 'Stale state: currentReflectionRow=null after auto-save, edit, Save', 'saved, no error toast, 1 reflection row (latest text), day credited once',
      `reflections ${rows.length} (text ends "${(rows[0] || {}).reflection.slice(-16)}"), attendance ${rowsFor(db, TODAY)}, toasts: ${t.join(' → ')}`,
      rows.length === 1 && rows[0].reflection.endsWith('I trust Him') && rowsFor(db, TODAY) === 1 && !t.some(x => /Not saved|Could not/.test(x))); await pg.context().close(); }

  // ---- 2b. upsert rejects once with 23505 -> fallback re-reads and UPDATES by id ----
  { const db = freshDb(); db.devotional_reflections.push({ id: 'refl-existing', member_id: ME, entry_date: TODAY, reflection: 'old words from another copy', updated_at: '2026-11-03T00:10:00Z' });
    const pg = await open(db); await openToday(pg);
    await pg.evaluate(() => { currentReflectionRow = null; window.__toasts.length = 0; });   // simulate the stale state
    db.__dupOnce = true; await pg.focus('#reflectionInput'); await pg.keyboard.press('Control+A'); await typeWords(pg, 12); await pg.click('#reflectionSaveBtn'); await pg.waitForTimeout(1500);
    const t = await toasts(pg); const rows = reflRows(db, TODAY);
    rec('2b', 'Forced 23505 on the upsert (once)', 'fallback UPDATES the existing row by id; no error toast; 1 row; day credited + streak toast',
      `23505 hits ${db.__dupHits || 0}, PATCH updates ${db.__patches || 0}, reflections ${rows.length} (id ${(rows[0] || {}).id}), text updated ${rows[0] && rows[0].reflection.startsWith('God is faithful')}, attendance ${rowsFor(db, TODAY)}, toasts: ${t.join(' → ')}`,
      db.__dupHits === 1 && db.__patches >= 1 && rows.length === 1 && rows[0].id === 'refl-existing' && rows[0].reflection.startsWith('God is faithful') && rowsFor(db, TODAY) === 1 && t.some(x => x.includes('🔥')) && !t.some(x => /Not saved|Could not/.test(x)));
    await pg.context().close(); }

  // ---- 3. Hard failure (offline): friendly EN + TL, text kept, ✕ keeps reader open, back online -> saves + credits ----
  for (const [w, h] of [[390, 844], [360, 740]]) {
    const db = freshDb(); const pg = await open(db, { width: w, height: h }); await openToday(pg); await typeWords(pg, 12);
    db.__offline = true; await pg.evaluate(() => { clearTimeout(_devoAutosaveTimer); window.__toasts.length = 0; });
    await pg.click('#reflectionSaveBtn'); await pg.waitForTimeout(700);
    await pg.screenshot({ path: path.join(OUT, `offline_toast_en_${w}.png`) });
    const geo = await pg.evaluate(() => { const r = document.getElementById('toast').getBoundingClientRect(); return { l: Math.round(r.left), r: Math.round(r.right), vw: innerWidth, h: Math.round(r.height) }; });
    const textAfter = await pg.inputValue('#reflectionInput');
    await pg.evaluate(() => document.body.classList.add('lang-tl')); await pg.click('#reflectionSaveBtn'); await pg.waitForTimeout(700);
    if (w === 390) await pg.screenshot({ path: path.join(OUT, `offline_toast_tl_${w}.png`) });
    await pg.evaluate(() => document.body.classList.remove('lang-tl'));
    await pg.click('.reader-back'); await pg.waitForTimeout(1000);
    const readerOpen = await pg.evaluate(() => document.getElementById('devoReader').classList.contains('show'));
    const t1 = await toasts(pg); const errs = await pg.evaluate(() => window.__errs.filter(e => e.includes('reflection persist failed')).length);
    db.__offline = false; await pg.evaluate(() => { window.__toasts.length = 0; });
    await pg.click('#reflectionSaveBtn'); await pg.waitForTimeout(1500); const t2 = await toasts(pg);
    if (w === 390) rec('3', 'Offline Save: friendly message, text kept; ✕ keeps reader open; online Save works', 'EN + TL friendly toasts, raw error only in console, text intact, then saved + credited',
      `toasts: ${t1.map(x => x.slice(0, 22) + '…').join(' | ')}; text intact ${textAfter.split(/\s+/).length === 12}; console errors ${errs}; reader still open after ✕ ${readerOpen}; back online: ${t2.join(' → ')}, reflections ${reflRows(db, TODAY).length}, attendance ${rowsFor(db, TODAY)}`,
      t1.includes(FRIENDLY_EN) && t1.includes(FRIENDLY_TL) && textAfter.split(/\s+/).length === 12 && errs >= 1 && readerOpen && t2.some(x => x.includes('🔥')) && reflRows(db, TODAY).length === 1 && rowsFor(db, TODAY) === 1);
    results.push({ n: '6-' + w, geo });
    await pg.context().close();
  }

  // ---- 5 (save part). Slow network: 4 s delay on every Supabase call; Save still completes ----
  { const db = freshDb(); const pg = await open(db); await openToday(pg); db.__delayMs = 4000; await typeWords(pg, 12);
    await pg.evaluate(() => { clearTimeout(_devoAutosaveTimer); window.__toasts.length = 0; });
    const t0 = Date.now(); await pg.click('#reflectionSaveBtn'); await pg.waitForFunction(() => window.__toasts.length > 0, null, { timeout: 30000 }); const ms = Date.now() - t0;
    const t = await toasts(pg);
    rec('5a', 'Throttled: every Supabase request delayed 4 s, tap Save', 'Save still completes and credits', `took ${(ms / 1000).toFixed(1)} s, toasts: ${t.join(' → ')}, reflections ${reflRows(db, TODAY).length}, attendance ${rowsFor(db, TODAY)}`,
      t.some(x => x.includes('🔥')) && reflRows(db, TODAY).length === 1 && rowsFor(db, TODAY) === 1); await pg.context().close(); }

  // ---- 6. toast fits at 360 / 390 ----
  { const g = results.filter(r => r.geo); const ok = g.every(r => r.geo.l >= 0 && r.geo.r <= r.geo.vw);
    rec('6', 'Phone 360 / 390 px: friendly toast wraps inside the screen', 'no horizontal overflow', g.map(r => `${r.n.slice(2)}px: toast x ${r.geo.l}–${r.geo.r} of ${r.geo.vw}, height ${r.geo.h}`).join('; '), ok); }

  // ---- 4 + 5 (load part). Real service worker ----
  {
    const ctx = await browser.newContext({ viewport: { width: 390, height: 844 } });
    const pg = await ctx.newPage();
    const fetchText = (u) => pg.evaluate(async (u) => { try { const r = await fetch(u); return { status: r.status, text: await r.text() }; } catch (e) { return { status: 0, text: String(e) }; } }, u);
    const has = (t, s) => t.includes(s);
    const NEWMSG = 'Not saved yet';
    // A. Sep-30-style install: OLD sw (v18) + OLD member_tool precached
    srvState.phase = 'old';
    await pg.goto(base + '/__swtest.html');
    await pg.evaluate(async () => { await navigator.serviceWorker.register('multiply-sw.js', { scope: './' }); await navigator.serviceWorker.ready; });
    await pg.reload(); await pg.waitForFunction(() => !!navigator.serviceWorker.controller);
    const keysA = await pg.evaluate(() => caches.keys());
    // B. New member_tool deployed, SW file unchanged (v18): shell loads ?embed=1 online, then offline plain URL
    srvState.phase = 'oldsw';
    const embedB = await fetchText('member_tool.html?embed=1');
    srvState.down = true; const plainB = await fetchText('member_tool.html'); srvState.down = false;
    rec('4-old', 'OLD v18 worker (bug repro): ?embed=1 fresh online, then offline plain member_tool.html', 'serves the stale install-time copy',
      `caches ${keysA.join(',')}; ?embed=1 online has new message: ${has(embedB.text, NEWMSG)}; offline plain has new message: ${has(plainB.text, NEWMSG)} (stale copy)`,
      keysA.length === 1 && keysA[0].includes('v18') && has(embedB.text, NEWMSG) && !has(plainB.text, NEWMSG));
    // C. New SW deployed -> update + activate
    srvState.phase = 'new';
    await pg.evaluate(async () => { const reg = await navigator.serviceWorker.getRegistration(); await reg.update(); });
    for (let i = 0; i < 100; i++) {   // real poll (an async waitForFunction predicate is always truthy)
      const st = await pg.evaluate(async () => { const r = await navigator.serviceWorker.getRegistration(); return { keys: await caches.keys(), active: r.active && r.active.state, waiting: !!r.waiting, installing: !!r.installing }; });
      if (st.keys.length === 1 && st.keys[0].includes('v19') && st.active === 'activated' && !st.waiting && !st.installing) break;
      await pg.waitForTimeout(300);
    }
    await pg.reload(); await pg.waitForTimeout(500);
    const keysC = await pg.evaluate(() => caches.keys());
    // D. a later deploy (marker BUILD-2): shell loads ?embed=1 online, then offline -> plain URL must be that same fresh copy
    srvState.marker = 'BUILD-2';
    const embedD = await fetchText('member_tool.html?embed=1');
    srvState.down = true;
    const plainD = await fetchText('member_tool.html'); const embedOff = await fetchText('member_tool.html?embed=1');
    let navOk = false, navText = '';
    try { const resp = await pg.goto(base + '/member_tool.html', { waitUntil: 'commit' }); navText = await resp.text(); navOk = resp.fromServiceWorker(); } catch (e) { navText = String(e); }
    srvState.down = false;
    const cacheEntries = await (await ctx.newPage()).evaluate(async (b) => { return []; }, base);
    await pg.goto(base + '/__swtest.html');
    const htmlKeys = await pg.evaluate(async () => { const c = await caches.open((await caches.keys())[0]); return (await c.keys()).map(r => new URL(r.url).pathname + new URL(r.url).search).filter(k => k.includes('member_tool')); });
    rec('4', 'NEW v19 worker: only v19 cache; ?embed=1 loaded online, then offline plain member_tool.html', 'only multiply-shell-v19-…; plain URL serves the same fresh build (new message + BUILD-2)',
      `caches ${keysC.join(',')}; member_tool cache keys: ${htmlKeys.join(', ')}; online ?embed=1 BUILD-2 ${has(embedD.text, 'BUILD-2')}; OFFLINE plain: new message ${has(plainD.text, NEWMSG)}, BUILD-2 ${has(plainD.text, 'BUILD-2')}; offline ?embed=1 BUILD-2 ${has(embedOff.text, 'BUILD-2')}; offline navigation from SW ${navOk} with BUILD-2 ${has(navText, 'BUILD-2')}`,
      keysC.length === 1 && keysC[0] === 'multiply-shell-v19-2026-11-18' && htmlKeys.length === 1 && has(plainD.text, NEWMSG) && has(plainD.text, 'BUILD-2') && has(embedOff.text, 'BUILD-2') && navOk && has(navText, 'BUILD-2'));
    // E. slow network: HTML takes 4 s -> SW serves the cache after its 3.5 s timeout
    srvState.htmlDelay = 4000; srvState.marker = 'BUILD-3';
    const t0 = Date.now(); const slow = await fetchText('member_tool.html'); const ms = Date.now() - t0;
    srvState.htmlDelay = 0;
    await pg.waitForTimeout(1200);
    const after = await fetchText('member_tool.html');
    rec('5b', 'Throttled load: HTML delayed 4 s', 'page served from cache after ~3.5 s; background fetch then refreshes the cache',
      `served in ${(ms / 1000).toFixed(1)} s (cached BUILD-2 ${has(slow.text, 'BUILD-2')}); next load has BUILD-3 ${has(after.text, 'BUILD-3')}`,
      ms < 4000 && has(slow.text, 'BUILD-2') && has(after.text, 'BUILD-3'));
    // F. MLT + dashboard still load through the worker
    srvState.marker = '';
    const mlt = await fetchText('lc_leader_tool.html?embed=1'); const md = await fetchText('multiply_dashboard.html?embed=1'); const shell = await fetchText('./');
    rec('6b', 'Leader tool, dashboard and shell load through the new worker', 'all 200 with their own page', `MLT ${mlt.status} (${/<title>[^<]*/.exec(mlt.text)}), MD ${md.status} (${/<title>[^<]*/.exec(md.text)}), shell ${shell.status}`,
      mlt.status === 200 && md.status === 200 && shell.status === 200 && /lc_leader|Leader/i.test(mlt.text) && /dashboard|MULTIPLY/i.test(md.text));
    await ctx.close();
  }

  fs.writeFileSync(path.join(OUT, 'results.json'), JSON.stringify(results, null, 1));
  const fails = results.filter(r => r.ok === false).length;
  console.log(fails ? `${fails} FAILED` : 'ALL PASS');
  await browser.close(); srv.close(); process.exit(fails ? 1 : 0);
})().catch(e => { console.error(e); process.exit(2); });
