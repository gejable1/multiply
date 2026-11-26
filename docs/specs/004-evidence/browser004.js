// Spec 004 browser test (bilingual devotionals) - the REAL MMT, MLT, public page and admin in Chromium against a fake
// Supabase holding ONE test member (is_test_member) and practice devotionals.
// Nothing leaves this machine. Clock: Tue 2026-11-03 09:00 Manila (scenario 6: Sun Nov 8).
// Usage: node browser004.js <repo dir> <main's lc_leader_tool.html> <out dir>
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

// ===== Spec 004: bilingual devotionals =====
// Usage: node browser004.js <repo dir> <main's lc_leader_tool.html (for the byte-identical check)> <out dir>
const OLD_MLT = OLD;
const TL_COLS = ['title_tl','scripture_text_tl','story_tl','explanation_tl','response_tl','prayer_tl','reflection_questions_tl','weekly_summary_tl','tl_status'];
const TODAY = '2026-11-03';
const longTl = n => Array.from({ length: n }, (_, i) => ['Ang', 'Panginoon', 'ay', 'aking', 'pastol', 'hindi', 'ako', 'magkukulang', 'kailanman', 'kapatid'][i % 10]).join(' ');

function devoDb(tlMode, opts = {}) {
  const db = freshDb();
  db.devotionals.forEach(d => { d.weekly_summary = d.entry_date === '2026-11-07' ? 'English weekly summary.' : null; });
  const d = db.devotionals.find(x => x.entry_date === TODAY);
  d.title = 'Shepherd of My Days'; d.story = 'ENGLISH STORY: a shepherd counted his sheep.'; d.explanation = 'ENGLISH EXPLANATION of Psalm 23.';
  d.response = 'ENGLISH RESPONSE: trust Him today.'; d.prayer = 'ENGLISH PRAYER: Lord, lead me.';
  d.weekly_summary = 'ENGLISH WEEKLY SUMMARY.';
  if (opts.pre129) return Object.assign(db, { __pre129: true });
  TL_COLS.forEach(c => db.devotionals.forEach(r => { r[c] = null; }));
  if (tlMode === 'draft' || tlMode === 'full') Object.assign(d, {
    title_tl: 'Pastol ng Aking mga Araw', scripture_text_tl: 'Ang Panginoon ang aking pastol; hindi ako magkukulang.',
    story_tl: opts.longStory ? longTl(3200) : 'TAGALOG NA KUWENTO: binilang ng pastol ang kanyang mga tupa.',
    explanation_tl: 'TAGALOG NA PALIWANAG ng Awit 23.', response_tl: 'TAGALOG NA TUGON: magtiwala sa Kanya ngayon.',
    prayer_tl: 'TAGALOG NA PANALANGIN: Panginoon, akayin Mo ako.', reflection_questions_tl: ['Ano ang sinasabi ng Diyos sa iyo ngayon?'],
    weekly_summary_tl: 'TAGALOG NA LINGGUHANG BUOD.', tl_status: tlMode === 'draft' ? 'draft' : 'reviewed' });
  if (tlMode === 'partial') Object.assign(d, { title_tl: 'Pastol ng Aking mga Araw', story_tl: 'TAGALOG NA KUWENTO lamang.', tl_status: 'reviewed' });
  return db;
}

// Supabase fake on top of handle(): projection, "before 129" column errors, public RPCs
function handle4(db, req) {
  const u = new URL(req.url()); const method = req.method();
  const rpc = (u.pathname.match(/\/rest\/v1\/rpc\/([^/?]+)/) || [])[1];
  const body = (() => { try { return JSON.parse(req.postData() || 'null'); } catch (e) { return null; } })();
  const pub = () => db.devotionals.filter(r => r.entry_date <= TODAY).sort((a, b) => a.entry_date < b.entry_date ? 1 : -1);
  if (rpc === 'public_devotional_dates') return { status: 200, body: JSON.stringify(pub().map(r => ({ entry_date: r.entry_date }))) };
  if (rpc === 'public_devotional') {
    const r = pub().find(x => x.entry_date === (body && body.p_date || TODAY));
    return { status: 200, body: JSON.stringify(r ? [{ entry_date: r.entry_date, title: r.title, scripture_ref: r.scripture_ref, source_note: null, scripture_text: r.scripture_text,
      story: r.story, explanation: r.explanation, response: r.response, prayer: r.prayer, reflection_questions: r.reflection_questions, weekly_summary: r.weekly_summary }] : []) };
  }
  if (rpc === 'public_devotional_tl') {
    db.__tlRpcCalls = (db.__tlRpcCalls || 0) + 1;
    if (db.__pre129) return { status: 404, body: JSON.stringify({ code: 'PGRST202', message: 'Could not find the function public.public_devotional_tl(p_date) in the schema cache' }) };
    const r = pub().find(x => x.entry_date === (body && body.p_date || TODAY) && x.tl_status === 'reviewed');
    return { status: 200, body: JSON.stringify(r ? [Object.fromEntries(['entry_date', ...TL_COLS.slice(0, 8)].map(c => [c, r[c]]))] : []) };
  }
  if (/\/rest\/v1\/devotionals/.test(u.pathname)) {
    const sel = u.searchParams.get('select') || '*';
    const wantsTl = sel.split(',').some(c => TL_COLS.includes(c.trim()));
    const writesTl = body && (Array.isArray(body) ? body : [body]).some(r => r && Object.keys(r).some(k => TL_COLS.includes(k)));
    if (db.__pre129 && wantsTl) { db.__tlSelectErrors = (db.__tlSelectErrors || 0) + 1; return { status: 400, body: JSON.stringify({ code: '42703', message: 'column devotionals.' + sel.split(',').find(c => TL_COLS.includes(c.trim())) + ' does not exist' }) }; }
    if (db.__pre129 && writesTl) return { status: 400, body: JSON.stringify({ code: 'PGRST204', message: "Could not find the 'title_tl' column of 'devotionals' in the schema cache" }) };
    if (method === 'PATCH' && body) db.__devoPatches = (db.__devoPatches || []).concat([body]);
    const o = handle(db, req);
    if ((method === 'GET') && sel !== '*' && o.status === 200) {
      const keep = sel.split(',').map(c => c.trim());
      const proj = r => Object.fromEntries(keep.map(c => [c, r[c]]));
      const v = JSON.parse(o.body); o.body = JSON.stringify(Array.isArray(v) ? v.map(proj) : proj(v));
    }
    return o;
  }
  return handle(db, req);
}

(async () => {
  const srv = http.createServer((req, res) => {
    const rel = decodeURIComponent(req.url.split('?')[0]);
    const p = path.join(REPO, rel === '/' ? '/index.html' : rel);
    if (!p.startsWith(REPO) || !fs.existsSync(p) || fs.statSync(p).isDirectory()) { res.writeHead(404); return res.end(); }
    res.writeHead(200, { 'Content-Type': p.endsWith('.js') ? 'text/javascript' : p.endsWith('.svg') ? 'image/svg+xml' : p.endsWith('.png') ? 'image/png' : 'text/html', 'Cache-Control': 'no-store' });
    res.end(fs.readFileSync(p));
  }).listen(0);
  const base = 'http://127.0.0.1:' + srv.address().port;
  const browser = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
  const pageErrors = [];

  async function open(db, file, { width = 390, height = 844, session = 'member', appLang = 'en', storage = {} } = {}) {
    const ctx = await browser.newContext({ viewport: { width, height }, timezoneId: 'Asia/Manila', deviceScaleFactor: 2, serviceWorkers: 'block' });
    const pg = await ctx.newPage();
    await pg.clock.install({ time: new Date(TODAY + 'T09:00:00+08:00') }); await pg.clock.resume();
    await pg.route(/^https?:\/\/(?!127\.0\.0\.1)/, async r => {
      const url = r.request().url();
      if (/supabase\.co/.test(url)) { const o = handle4(db, r.request()); return r.fulfill({ status: o.status, contentType: 'application/json', body: o.body }); }
      return r.fulfill({ status: 204, body: '' });
    });
    await pg.route('**/cdn.jsdelivr.net/**supabase-js**', r => r.fulfill({ contentType: 'text/javascript', body: fs.readFileSync(SUPA_UMD) }));
    await pg.route(/fonts\.(googleapis|gstatic)\.com/, r => r.fulfill({ contentType: 'text/css', body: '' }));
    await pg.addInitScript(([me, session, appLang, storage]) => {
      if (session === 'member') sessionStorage.setItem('multiply_member_session', JSON.stringify({ memberId: me, memberName: 'Test Member (practice)', expiresAt: '2099-01-01T00:00:00Z' }));
      if (session === 'leader') sessionStorage.setItem('multiply_leader_session', JSON.stringify({ leaderId: me, leaderName: 'Practice Pastor', leaderLevel: 5, expiresAt: '2099-01-01T00:00:00Z' }));
      try { localStorage.setItem('multiply_mmt_lang', appLang); for (const k in storage) localStorage.setItem(k, storage[k]); } catch (e) {}
      window.__toasts = []; window.__shared = []; window.__errs = [];
      const ce = console.error.bind(console); console.error = (...a) => { window.__errs.push(a.map(String).join(' ')); ce(...a); };
      Object.defineProperty(navigator, 'share', { configurable: true, value: d => { window.__shared.push(d); return Promise.resolve(); } });
    }, [ME, session, appLang, storage]);
    pg.on('pageerror', e => { pageErrors.push(file + ': ' + e.message); console.log('  PAGE ERROR:', file, e.message); });
    pg.on('dialog', d => d.accept());
    await pg.goto(base + '/' + file);
    return pg;
  }
  async function openMMT(db, o = {}) {
    const pg = await open(db, 'member_tool.html', o);
    await pg.waitForFunction(() => typeof window.openDevoReader === 'function' && typeof todayDevo !== 'undefined' && todayDevo, null, { timeout: 20000 });
    await pg.waitForTimeout(1500);
    await pg.evaluate(() => { const m = document.getElementById('reflectionModal'); if (m && getComputedStyle(m).display !== 'none') _dismissReflectionReminder(); });
    return pg;
  }
  const openReader = async pg => { await pg.evaluate(() => openDevoReader('today')); await pg.waitForSelector('#reflectionInput', { state: 'visible', timeout: 10000 }); await pg.waitForTimeout(300); };
  const readerText = pg => pg.evaluate(() => document.getElementById('readerDevoText').innerText);
  const pillInfo = (pg, sel) => pg.evaluate(sel => { const p = document.querySelector(sel); if (!p) return null; const b = p.querySelector('button'); const r = b.getBoundingClientRect();
    const zoom = parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--fs')) || 1;
    return { pressed: [...p.querySelectorAll('button')].filter(x => x.getAttribute('aria-pressed') === 'true').map(x => x.dataset.lang).join(), h: Math.round(r.height), cssH: Math.round(parseFloat(getComputedStyle(b).minHeight)) }; }, sel);
  const anchorTitle = pg => pg.evaluate(() => { const el = document.getElementById('anchorTitle'); return [...el.children].filter(s => getComputedStyle(s).display !== 'none').map(s => s.textContent).join(''); });

  async function openMLT(db, o = {}) {
    const pg = await open(db, 'lc_leader_tool.html', Object.assign({ session: 'leader', width: 1280, height: 900 }, o));
    await pg.waitForFunction(() => typeof window.mpLoadDevotional === 'function' && typeof db !== 'undefined', null, { timeout: 20000 });
    await pg.waitForTimeout(1200);
    return pg;
  }
  const mltPrompt = async (pg, date) => pg.evaluate(async date => { document.getElementById('mpDate').value = date; await mpLoadDevotional(); return document.getElementById('mpPrompt').value; }, date);

  async function openPub(db, o = {}) {
    const pg = await open(db, 'devotional.html?app=soar', Object.assign({ session: 'none' }, o));
    await pg.waitForSelector('#devoText, .state', { timeout: 15000 }); await pg.waitForTimeout(600);
    return pg;
  }
  async function openAdmin(db, o = {}) {
    const pg = await open(db, 'devotional_admin.html', Object.assign({ session: 'leader', width: 1280, height: 900 }, o));
    await pg.waitForSelector('#appShell', { state: 'visible', timeout: 20000 }); await pg.waitForTimeout(500);
    return pg;
  }
  const noSideScroll = pg => pg.evaluate(() => { const se = document.scrollingElement; const rb = document.getElementById('readerBody');
    return { page: se.scrollWidth <= innerWidth, reader: rb ? rb.scrollWidth <= rb.clientWidth + 1 : true, sw: se.scrollWidth, vw: innerWidth }; });

  // Byte-identical check: main's mpBuildPrompt vs this branch's, in Node
  const fnSrc = (src, name) => { const i = src.indexOf('function ' + name + '('); const j = src.indexOf('\n}\n', i); return src.slice(i, j + 2); };
  const NEW_MLT = fs.readFileSync(path.join(REPO, 'lc_leader_tool.html'), 'utf8'); const OLD_SRC = fs.readFileSync(OLD_MLT, 'utf8');
  const oldBuild = new Function(fnSrc(OLD_SRC, 'mpBuildPrompt') + '; return mpBuildPrompt;')();
  const newBuild = new Function(fnSrc(NEW_MLT, '_mpTagalogBlock') + fnSrc(NEW_MLT, 'mpBuildPrompt') + '; return mpBuildPrompt;')();

  const results = []; const rec = (n, title, actual, ok) => { results.push({ n, title, actual, ok }); console.log((ok ? 'PASS ' : 'FAIL ') + n + ' ' + title + ' :: ' + actual); };
  const shot = (pg, name) => pg.screenshot({ path: path.join(OUT, name + '.png') });

  // ---------- 1. No Tagalog ----------
  { const db = devoDb('none');
    const m = await openMMT(db); await openReader(m); const pill = await pillInfo(m, '#readerBody .devo-lang-pill'); const t = await readerText(m);
    await m.context().close();
    const l = await openMLT(db); const pr = await mltPrompt(l, TODAY); await l.context().close();
    const oldPr = oldBuild(db.devotionals.find(x => x.entry_date === TODAY));
    const p = await openPub(db); const ppill = await p.$('.lang-pill'); await p.context().close();
    rec('1', 'No Tagalog: MMT, MLT and public page as today', `MMT pill ${!!pill}, English story ${t.includes('ENGLISH STORY')}; MLT prompt byte-identical to main ${pr === oldPr} (${pr.length} chars), TL block ${pr.includes('TAGALOG VERSION')}; public pill ${!!ppill}`,
      !pill && t.includes('ENGLISH STORY') && pr === oldPr && !pr.includes('TAGALOG VERSION') && !ppill); }

  // ---------- 2. Draft only ----------
  { const db = devoDb('draft');
    const a = await openAdmin(db); const badge = await a.evaluate(() => [...document.querySelectorAll('.cal-cell .tl-badge')].map(b => b.textContent + ':' + b.className).join()); await a.context().close();
    const m = await openMMT(db, { appLang: 'tl' }); await openReader(m); const pill = await pillInfo(m, '#readerBody .devo-lang-pill'); const t = await readerText(m); await m.context().close();
    const l = await openMLT(db); const pr = await mltPrompt(l, TODAY); await l.context().close();
    const p = await openPub(db); const ppill = await p.$('.lang-pill'); const ptxt = await p.evaluate(() => document.getElementById('devoText').innerText); await p.context().close();
    rec('2', 'Draft only: admin badge; members/leaders/public see English', `admin badge "${badge}"; MMT (app in TL) pill ${!!pill}, English ${t.includes('ENGLISH STORY')}; MLT TL block ${pr.includes('TAGALOG VERSION')}; public pill ${!!ppill}, English ${ptxt.includes('ENGLISH STORY')}`,
      badge === 'TL draft:tl-badge draft' && !pill && t.includes('ENGLISH STORY') && !t.includes('TAGALOG') && !pr.includes('TAGALOG') && !ppill && ptxt.includes('ENGLISH STORY')); }

  // ---------- 3. Reviewed, complete (+ screenshots, + 10) ----------
  { const db = devoDb('full');
    const m = await openMMT(db, { appLang: 'tl' });
    const homeTitleTl = await anchorTitle(m);
    await openReader(m);
    const pill0 = await pillInfo(m, '#readerBody .devo-lang-pill'); const t0 = await readerText(m);
    await m.focus('#reflectionInput'); await m.keyboard.type(words(12)); await m.evaluate(() => clearTimeout(_devoAutosaveTimer));
    await shot(m, 'mmt_tl_390');
    await m.click('#readerBody .devo-lang-pill button[data-lang="en"]'); await m.waitForTimeout(200);
    const pill1 = await pillInfo(m, '#readerBody .devo-lang-pill'); const t1 = await readerText(m); const refl1 = await m.inputValue('#reflectionInput');
    const stored = await m.evaluate(() => localStorage.getItem('mmt_devo_lang')); const appLang = await m.evaluate(() => document.body.classList.contains('lang-tl'));
    const homeTitleEn = await anchorTitle(m);
    await shot(m, 'mmt_en_390');
    await m.click('#readerBody .devo-lang-pill button[data-lang="tl"]'); await m.waitForTimeout(200);
    const t2 = await readerText(m); const refl2 = await m.inputValue('#reflectionInput');
    const secs = ['TAGALOG NA KUWENTO', 'hindi ako magkukulang', 'TAGALOG NA PALIWANAG', 'TAGALOG NA TUGON', 'TAGALOG NA PANALANGIN', 'TAGALOG NA LINGGUHANG BUOD', 'Pastol ng Aking mga Araw'];
    const secsEn = ['ENGLISH STORY', 'I shall not want', 'ENGLISH EXPLANATION', 'ENGLISH RESPONSE', 'ENGLISH PRAYER', 'ENGLISH WEEKLY SUMMARY', 'Shepherd of My Days'];
    rec('3', 'Reviewed complete: MMT pill, opens TL with app in TL; toggle EN and back; reflection kept', `opened in ${pill0 && pill0.pressed} (all 7 TL sections ${secs.every(s => t0.includes(s))}); after EN tap: pressed ${pill1.pressed}, all 7 EN sections ${secsEn.every(s => t1.includes(s))}, no Tagalog left ${!secs.some(s => t1.includes(s))}; back to TL ${secs.every(s => t2.includes(s))}; reflection kept ${refl1 === words(12) && refl2 === words(12)}; mmt_devo_lang=${stored}; app language still TL ${appLang}; home title TL "${homeTitleTl}" → EN "${homeTitleEn}"; pill height ${pill0.h}px`,
      pill0 && pill0.pressed === 'tl' && secs.every(s => t0.includes(s)) && pill1.pressed === 'en' && secsEn.every(s => t1.includes(s)) && !secs.some(s => t1.includes(s)) && secs.every(s => t2.includes(s))
      && refl1 === words(12) && refl2 === words(12) && stored === 'en' && appLang && homeTitleTl === 'Pastol ng Aking mga Araw' && homeTitleEn === 'Shepherd of My Days' && pill0.h >= 40);
    // save still works + credits (Spec 002/003 path untouched)
    await m.evaluate(() => { window.__toasts = []; const o = window.showToast; window.showToast = function (x) { window.__toasts.push(String(x)); return o.apply(this, arguments); }; });
    await m.click('#reflectionSaveBtn'); await m.waitForTimeout(1500);
    const tt = await m.evaluate(() => window.__toasts.slice());
    const att = db.attendance.filter(r => r.member_id === ME && r.event_type === 'devotional' && r.event_date === TODAY).length;
    rec('3b', 'Reviewed TL: Save reflection still saves + credits', `toasts ${tt.join(' → ')}; reflection rows ${db.devotional_reflections.filter(r => r.entry_date === TODAY).length}; attendance ${att}`, tt.some(x => x.includes('🔥')) && att === 1);
    await m.context().close();
    // default EN when the app is English and no stored choice
    const m2 = await openMMT(devoDb('full'), { appLang: 'en' }); await openReader(m2); const pd = await pillInfo(m2, '#readerBody .devo-lang-pill');
    const keepChoice = await (async () => { const m3 = await openMMT(devoDb('full'), { appLang: 'en', storage: { mmt_devo_lang: 'tl' } }); await openReader(m3); const x = await pillInfo(m3, '#readerBody .devo-lang-pill'); await m3.context().close(); return x.pressed; })();
    rec('3c', 'Default follows app language; a stored choice wins', `app EN, no choice → ${pd.pressed}; app EN, stored TL → ${keepChoice}`, pd.pressed === 'en' && keepChoice === 'tl');
    await m2.context().close();
    // screenshots 360 / desktop
    for (const [w, h, n] of [[360, 740, '360'], [1280, 900, 'desktop']]) for (const lang of ['tl', 'en']) {
      const s = await openMMT(devoDb('full'), { width: w, height: h, appLang: lang }); await openReader(s); await shot(s, `mmt_${lang}_${n}`); await s.context().close(); }
  }

  // ---------- 4. Reviewed, partial ----------
  { const db = devoDb('partial'); const m = await openMMT(db, { appLang: 'tl' }); await openReader(m); const t = await readerText(m); const pill = await pillInfo(m, '#readerBody .devo-lang-pill');
    rec('4', 'Reviewed partial (title_tl + story_tl): those in TL, the rest English', `pill ${pill && pill.pressed}; TL title ${t.includes('Pastol ng Aking mga Araw')}, TL story ${t.includes('TAGALOG NA KUWENTO lamang')}, English passage/explanation/response/prayer/summary ${['I shall not want', 'ENGLISH EXPLANATION', 'ENGLISH RESPONSE', 'ENGLISH PRAYER', 'ENGLISH WEEKLY SUMMARY'].every(s => t.includes(s))}, English story gone ${!t.includes('ENGLISH STORY')}`,
      pill && pill.pressed === 'tl' && t.includes('Pastol ng Aking mga Araw') && t.includes('TAGALOG NA KUWENTO lamang') && ['I shall not want', 'ENGLISH EXPLANATION', 'ENGLISH RESPONSE', 'ENGLISH PRAYER', 'ENGLISH WEEKLY SUMMARY'].every(s => t.includes(s)) && !t.includes('ENGLISH STORY'));
    await m.context().close(); }

  // ---------- 5. MLT ----------
  { const db = devoDb('full'); const l = await openMLT(db); const pr = await mltPrompt(l, TODAY); const prOther = await mltPrompt(l, '2026-11-04'); await l.context().close();
    const d = db.devotionals.find(x => x.entry_date === TODAY); const oldPr = oldBuild(d);
    const i = pr.indexOf('\n\nDEVOTIONAL (TAGALOG VERSION'); const j = pr.indexOf('\n\nTHE FACILITATOR');
    const stripped = i > 0 ? pr.slice(0, i) + pr.slice(j) : pr;
    const block = i > 0 ? pr.slice(i, j) : '';
    const dp = devoDb('partial').devotionals.find(x => x.entry_date === TODAY); const prPartial = newBuild(dp);
    fs.writeFileSync(path.join(OUT, 'mlt_prompt_reviewed.txt'), pr);
    rec('5', 'MLT: reviewed date adds the Tagalog block right after DEVOTIONAL; English untouched', `block present ${i > 0}, placed after English "Reflection questions" ${pr.lastIndexOf('Reflection questions:', i) > pr.indexOf('\nDEVOTIONAL\n')}; prompt minus block === main's prompt ${stripped === oldPr}; block has TL title/story/prayer/questions ${['Pastol ng Aking mga Araw', 'TAGALOG NA KUWENTO', 'TAGALOG NA PANALANGIN', 'Ano ang sinasabi'].every(s => block.includes(s))}; non-Tagalog date (Nov 4) byte-identical ${prOther === oldBuild(db.devotionals.find(x => x.entry_date === '2026-11-04'))}; partial falls back (TL story + English prayer in block) ${prPartial.includes('Story: TAGALOG NA KUWENTO lamang') && prPartial.split('Prayer: ENGLISH PRAYER').length === 3}`,
      i > 0 && stripped === oldPr && ['Pastol ng Aking mga Araw', 'TAGALOG NA KUWENTO', 'TAGALOG NA PANALANGIN', 'Ano ang sinasabi'].every(s => block.includes(s)) && prOther === oldBuild(db.devotionals.find(x => x.entry_date === '2026-11-04'))
      && prPartial.includes('Story: TAGALOG NA KUWENTO lamang') && prPartial.split('Prayer: ENGLISH PRAYER').length === 3); }

  // ---------- 6. Public page ----------
  { const db = devoDb('full'); const p = await openPub(db);
    const pill0 = await pillInfo(p, '.lang-pill'); const t0 = await p.evaluate(() => document.getElementById('devoText').innerText);
    await p.fill('#refl', 'my private note'); await p.click('.lang-pill button[data-lang="tl"]'); await p.waitForTimeout(150);
    const t1 = await p.evaluate(() => document.getElementById('devoText').innerText); const note = await p.inputValue('#refl');
    await p.click('#shareBtn'); await p.waitForTimeout(100); const sh1 = await p.evaluate(() => window.__shared.slice(-1)[0]);
    await shot(p, 'public_tl_390');
    const stored = await p.evaluate(() => localStorage.getItem('pub_devo_lang'));
    await p.click('.lang-pill button[data-lang="en"]'); await p.waitForTimeout(150); await p.click('#shareBtn'); await p.waitForTimeout(100); const sh2 = await p.evaluate(() => window.__shared.slice(-1)[0]);
    await p.context().close();
    const pre = devoDb('none', { pre129: true }); const q = await openPub(pre); const qpill = await q.$('.lang-pill'); const qt = await q.evaluate(() => (document.getElementById('devoText') || {}).innerText || ''); await q.context().close();
    const errsBefore = pageErrors.filter(e => e.startsWith('devotional.html')).length;
    rec('6', 'Public: EN default, pill works, share follows language; RPC missing → English only, no error', `default ${pill0 && pill0.pressed} (English ${t0.includes('ENGLISH STORY')}), pill ${pill0 && pill0.h}px; after TL tap Tagalog ${t1.includes('TAGALOG NA KUWENTO')}, note kept ${note === 'my private note'}, pub_devo_lang=${stored}; share TL "${sh1 && sh1.text}" → EN "${sh2 && sh2.text}"; RPC 404: TL RPC called ${pre.__tlRpcCalls}x, pill ${!!qpill}, English ${qt.includes('ENGLISH STORY')}, uncaught errors ${errsBefore}`,
      pill0 && pill0.pressed === 'en' && t0.includes('ENGLISH STORY') && pill0.h >= 40 && t1.includes('TAGALOG NA KUWENTO') && note === 'my private note' && stored === 'tl'
      && sh1 && sh1.text.startsWith('Pastol ng Aking mga Araw') && sh2 && sh2.text.startsWith('Shepherd of My Days') && pre.__tlRpcCalls >= 1 && !qpill && qt.includes('ENGLISH STORY') && errsBefore === 0);
    for (const [w, h, n] of [[360, 740, '360'], [1280, 900, 'desktop']]) { const s = await openPub(devoDb('full'), { width: w, height: h, storage: { pub_devo_lang: 'tl' } }); await shot(s, 'public_tl_' + n); await s.context().close(); } }

  // ---------- 7. Admin edit + bulk re-import keeps Tagalog ----------
  { const db = devoDb('none'); const a = await openAdmin(db);
    await a.evaluate(d => openEdit(d), TODAY); await a.waitForTimeout(200);
    const shown = await a.evaluate(() => ({ sec: getComputedStyle(document.getElementById('tlSection')).display !== 'none', note: getComputedStyle(document.getElementById('tlNote')).display !== 'none' }));
    await a.evaluate(() => { document.getElementById('tlSection').open = true; });
    await a.fill('#fTitleTl', 'Pastol ng Aking mga Araw'); await a.fill('#fStoryTl', 'TAGALOG NA KUWENTO mula sa admin.');
    await a.fill('#fQuestionsTl', 'Unang tanong?\n\n  Ikalawang tanong?  '); await a.selectOption('#fTlStatus', 'reviewed');
    for (const [w, h, n] of [[1280, 900, 'desktop'], [390, 844, '390'], [360, 740, '360']]) { await a.setViewportSize({ width: w, height: h }); await a.evaluate(() => document.getElementById('tlSection').scrollIntoView()); await shot(a, 'admin_editor_' + n); }
    await a.setViewportSize({ width: 1280, height: 900 });
    await a.evaluate(() => saveEntry()); await a.waitForTimeout(800);
    const row = db.devotionals.find(x => x.entry_date === TODAY);
    const saved = row.title_tl === 'Pastol ng Aking mga Araw' && row.story_tl === 'TAGALOG NA KUWENTO mula sa admin.' && JSON.stringify(row.reflection_questions_tl) === '["Unang tanong?","Ikalawang tanong?"]' && row.tl_status === 'reviewed' && row.title === 'Shepherd of My Days';
    await a.reload(); await a.waitForSelector('#appShell', { state: 'visible' }); await a.waitForTimeout(400);
    const badge = await a.evaluate(() => [...document.querySelectorAll('.cal-cell .tl-badge')].map(b => b.textContent).join());
    db.devotionals.find(x => x.entry_date === '2026-11-04').tl_status = 'draft'; await a.evaluate(() => loadMonth()); await a.waitForTimeout(300);
    await shot(a, 'admin_calendar_badges_desktop'); await a.setViewportSize({ width: 390, height: 844 }); await a.waitForTimeout(200); await shot(a, 'admin_calendar_badges_390');
    const overlap = await a.evaluate(() => [...document.querySelectorAll('.cal-cell .tl-badge')].map(b => { const c = b.closest('.cal-cell').getBoundingClientRect(), r = b.getBoundingClientRect(), n = b.closest('.cal-cell').querySelector('.day-num').getBoundingClientRect();
      return { inCell: r.left >= c.left - 1 && r.right <= c.right + 1, hitsNum: !(r.left >= n.right || r.right <= n.left || r.top >= n.bottom || r.bottom <= n.top) }; }));
    console.log('  badge layout @390', JSON.stringify(overlap));
    await a.setViewportSize({ width: 1280, height: 900 });
    db.devotionals.find(x => x.entry_date === '2026-11-04').tl_status = null;
    await a.evaluate(d => openEdit(d), TODAY);
    const back = await a.evaluate(() => ({ t: fTitleTl.value, q: fQuestionsTl.value, s: fTlStatus.value, open: tlSection.open }));
    // English bulk re-import with "replace" on the same date
    await a.evaluate(() => { cancelEdit(); setMode('bulk'); });
    await a.fill('#bulkText', 'Tuesday, November 3, 2026\nTitle: Shepherd of My Days (re-imported)\n\nIllustrative Story:\nA REIMPORTED English story.\n\nPassage: Psalm 23:1 (ESV)\nThe Lord is my shepherd; I shall not want.\n\nExpository Explanation:\nREIMPORTED explanation.\n\nResponse:\nREIMPORTED response.\n\nPrayer:\nREIMPORTED prayer.\n');
    await a.evaluate(() => parseBulk()); await a.waitForTimeout(300);
    db.__devoPatches = [];
    await a.evaluate(() => bulkSave(true)); await a.waitForTimeout(1200);
    const r2 = db.devotionals.find(x => x.entry_date === TODAY);
    const patchKeys = [...new Set(db.__devoPatches.flatMap(o => Object.keys(o)))];
    await a.context().close();
    rec('7', 'Admin: edit Tagalog, save, reload persists; English "replace" re-import keeps Tagalog', `section shown ${shown.sec} (note hidden ${!shown.note}); saved fields+status ${saved}; after reload badge "${badge}", editor shows title "${back.t}", questions ${JSON.stringify(back.q)}, status ${back.s}; re-import updated English (title "${r2.title}", story re-imported ${r2.story === 'A REIMPORTED English story.'}); bulk PATCH keys touch _tl/tl_status: ${patchKeys.some(k => TL_COLS.includes(k))}; Tagalog after re-import: title_tl "${r2.title_tl}", story_tl kept ${r2.story_tl === 'TAGALOG NA KUWENTO mula sa admin.'}, status ${r2.tl_status}`,
      shown.sec && !shown.note && saved && badge === 'TL ✓' && back.t === 'Pastol ng Aking mga Araw' && back.q === 'Unang tanong?\nIkalawang tanong?' && back.s === 'reviewed'
      && r2.title === 'Shepherd of My Days (re-imported)' && r2.story === 'A REIMPORTED English story.' && db.__devoPatches.length >= 1 && !patchKeys.some(k => TL_COLS.includes(k))
      && r2.title_tl === 'Pastol ng Aking mga Araw' && r2.story_tl === 'TAGALOG NA KUWENTO mula sa admin.' && r2.tl_status === 'reviewed'); }

  // ---------- 8. Before migration 129 ----------
  { const db = devoDb('none', { pre129: true });
    const m = await openMMT(db, { appLang: 'tl' }); await openReader(m); const mt = await readerText(m); const mp = await pillInfo(m, '#readerBody .devo-lang-pill'); await m.context().close();
    const l = await openMLT(db); const pr = await mltPrompt(l, TODAY); const prSame = pr === oldBuild(db.devotionals.find(x => x.entry_date === TODAY)); const ltitle = await l.evaluate(() => document.getElementById('mpDevoTitle').textContent); await l.context().close();
    const p = await openPub(db); const pt = await p.evaluate(() => (document.getElementById('devoText') || {}).innerText || ''); await p.context().close();
    const a = await openAdmin(db); await a.evaluate(d => openEdit(d), TODAY);
    const adm = await a.evaluate(() => ({ sec: getComputedStyle(document.getElementById('tlSection')).display !== 'none', note: getComputedStyle(document.getElementById('tlNote')).display !== 'none' ? document.getElementById('tlNote').textContent : '' }));
    await a.fill('#fResponse', 'Edited English response before 129.'); await a.evaluate(() => saveEntry()); await a.waitForTimeout(700);
    const resp = db.devotionals.find(x => x.entry_date === TODAY).response;
    await shot(a, 'admin_pre129'); await a.context().close();
    rec('8', 'Before 129: every screen English; admin shows the note and still saves English', `MMT English ${mt.includes('ENGLISH STORY')}, pill ${!!mp}; MLT loaded "${ltitle}", ${db.__tlSelectErrors} _tl select error(s) caught → prompt byte-identical ${prSame}; public English ${pt.includes('ENGLISH STORY')}; admin section hidden ${!adm.sec}, note "${adm.note}"; English save ok ${resp === 'Edited English response before 129.'}; uncaught page errors ${pageErrors.length}`,
      mt.includes('ENGLISH STORY') && !mp && db.__tlSelectErrors >= 1 && prSame && pt.includes('ENGLISH STORY') && !adm.sec && adm.note === 'Run migration 129 to add Tagalog.' && resp === 'Edited English response before 129.' && pageErrors.length === 0); }

  // ---------- 9. Very long Tagalog story ----------
  { const out = [];
    for (const [w, h] of [[360, 740], [390, 844]]) {
      const db = devoDb('full', { longStory: true }); const wordsN = db.devotionals.find(x => x.entry_date === TODAY).story_tl.split(' ').length;
      const m = await openMMT(db, { width: w, height: h, appLang: 'tl' }); await openReader(m); const ns = await noSideScroll(m); const pill = await pillInfo(m, '#readerBody .devo-lang-pill');
      if (w === 360) await shot(m, 'mmt_tl_long_360'); await m.context().close();
      const p = await openPub(db, { width: w, height: h, storage: { pub_devo_lang: 'tl' } }); const pns = await noSideScroll(p); const pp = await pillInfo(p, '.lang-pill'); await p.context().close();
      out.push({ w, wordsN, ok: ns.page && ns.reader && pns.page && pill.h >= 40 && pp.h >= 40, s: `${w}px: ${wordsN} words, MMT page/reader no side-scroll ${ns.page}/${ns.reader}, pill ${pill.h}px; public no side-scroll ${pns.page}, pill ${pp.h}px` });
    }
    rec('9', 'Long Tagalog story (3,000+ words) at 360/390', out.map(o => o.s).join('; '), out.every(o => o.ok && o.wordsN >= 3000)); }

  rec('10', 'Screenshots + page errors', `${fs.readdirSync(OUT).filter(f => f.endsWith('.png')).length} PNGs; uncaught page errors: ${pageErrors.length ? pageErrors.join(' | ') : 'none'}`, pageErrors.length === 0);
  fs.writeFileSync(path.join(OUT, 'results.json'), JSON.stringify(results, null, 1));
  const fails = results.filter(r => !r.ok).length;
  console.log(fails ? `${fails} FAILED` : 'ALL PASS');
  await browser.close(); srv.close(); process.exit(fails ? 1 : 0);
})().catch(e => { console.error(e); process.exit(2); });
