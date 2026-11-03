// Spec 002 browser test - the REAL member_tool.html in Chromium against a fake
// Supabase holding ONE test member (is_test_member) and practice devotionals.
// Nothing leaves this machine. Clock: Tue 2026-11-03 09:00 Manila (scenario 6: Sun Nov 8).
// Usage: node browser002.js <repo dir> <old member_tool.html> <out dir>
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

(async () => {
  const srv = http.createServer((req, res) => {
    const rel = decodeURIComponent(req.url.split('?')[0]);
    const p = rel === '/__old_member_tool.html' ? OLD : path.join(REPO, rel);
    if (!fs.existsSync(p)) { res.writeHead(404); return res.end(); }
    res.writeHead(200, { 'Content-Type': p.endsWith('.js') ? 'text/javascript' : p.endsWith('.svg') ? 'image/svg+xml' : p.endsWith('.json') ? 'application/json' : 'text/html' }); res.end(fs.readFileSync(p));
  }).listen(0);
  const base = 'http://127.0.0.1:' + srv.address().port;
  // __old_member_tool.html must resolve relative assets from the repo root
  const browser = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });

  async function open(db, { width = 390, height = 844, clock = '2026-11-03T09:00:00+08:00', file = '/member_tool.html' } = {}) {
    const ctx = await browser.newContext({ viewport: { width, height }, timezoneId: 'Asia/Manila', deviceScaleFactor: 2 });
    const pg = await ctx.newPage();
    await pg.clock.install({ time: new Date(clock) });
    await pg.clock.resume();
    await pg.route(/^https?:\/\/(?!127\.0\.0\.1)/, r => {
      const url = r.request().url();
      if (/supabase\.co/.test(url)) { const o = handle(db, r.request()); return r.fulfill({ status: o.status, contentType: 'application/json', body: o.body }); }
      return r.fulfill({ status: 204, body: '' });
    });
    await pg.route('**/cdn.jsdelivr.net/**supabase-js**', r => r.fulfill({ contentType: 'text/javascript', body: fs.readFileSync(SUPA_UMD) }));
    await pg.route(/fonts\.(googleapis|gstatic)\.com/, r => r.fulfill({ contentType: 'text/css', body: '' }));
    await pg.addInitScript(me => {
      sessionStorage.setItem('multiply_member_session', JSON.stringify({ memberId: me, memberName: 'Test Member (practice)', expiresAt: '2099-01-01T00:00:00Z' }));
      window.__toasts = [];
      const hook = () => { if (typeof window.showToast === 'function' && !window.showToast.__hooked) { const o = window.showToast; window.showToast = function (m, e) { window.__toasts.push(String(m)); return o.apply(this, arguments); }; window.showToast.__hooked = true; } };
      document.addEventListener('DOMContentLoaded', hook); setTimeout(hook, 0);
    }, ME);
    pg.on('pageerror', e => console.log('  PAGE ERROR:', e.message));
    await pg.goto(base + file);
    await pg.waitForFunction(() => typeof window.loadDevoStreak === 'function' && typeof devoStreak !== 'undefined' && window.__mmtBooted !== false, null, { timeout: 20000 });
    await pg.waitForTimeout(2500);  // let initMMT finish (home render, reminder gate)
    await pg.evaluate(() => { const o = window.showToast; if (!o.__hooked) { window.showToast = function (m) { window.__toasts.push(String(m)); return o.apply(this, arguments); }; window.showToast.__hooked = true; } });
    return pg;
  }
  const dismissReminder = pg => pg.evaluate(() => { const m = document.getElementById('reflectionModal'); const t = m && getComputedStyle(m).display !== 'none' ? m.innerText : ''; if (t) _dismissReflectionReminder(); return t; });  // real 'Maybe later'
  async function readerType(pg, which, date, n) {
    await dismissReminder(pg);
    await pg.evaluate(([w, d]) => openDevoReader(w, d), [which, date]);
    await pg.waitForSelector('#reflectionInput', { state: 'visible', timeout: 10000 });
    await pg.focus('#reflectionInput'); await pg.keyboard.type(words(n));
  }
  const rowsFor = (db, d) => db.attendance.filter(r => r.member_id === ME && r.event_type === 'devotional' && r.event_date === d).length;
  const streakToasts = pg => pg.evaluate(() => window.__toasts.filter(t => t.includes('🔥')));
  const results = []; const rec = (n, title, expected, actual, ok) => { results.push({ n, title, expected, actual, ok }); console.log((ok ? 'PASS ' : 'FAIL ') + n + ' ' + title + ' :: ' + actual); };

  // 1. 12 words, wait 2s, close tab (no Save/X), reopen
  for (const variant of ['new', 'old']) {
    const db = freshDb(); const file = variant === 'old' ? '/__old_member_tool.html' : '/member_tool.html';
    let pg = await open(db, { file });
    await readerType(pg, 'today', null, 12); await pg.waitForTimeout(2500);
    const t1 = await streakToasts(pg);
    await pg.close();
    pg = await open(db, { file }); const s = await pg.evaluate(() => devoStreak); const rows = rowsFor(db, '2026-11-03');
    const saved = db.devotional_reflections.some(r => r.entry_date === '2026-11-03');
    if (variant === 'new') rec('1', '12 words, auto-save, tab closed, reopen', 'streak 8 (incl. today), 1 row', `streak ${s}, rows today ${rows}, words saved ${saved}, toast "${t1.join(' | ')}"`, s === 8 && rows === 1 && saved && t1.length === 1);
    else rec('1-old', 'same steps on OLD code (bug repro)', 'streak 7, 0 rows (bug)', `streak ${s}, rows today ${rows}, words saved ${saved}`, s === 7 && rows === 0 && saved);
    await pg.close();
  }
  // 2. 8 words only
  { const db = freshDb(); let pg = await open(db);
    await readerType(pg, 'today', null, 8); await pg.waitForTimeout(2500); await pg.close();
    pg = await open(db); const s = await pg.evaluate(() => devoStreak); const rem = await dismissReminder(pg);
    rec('2', '8 words, auto-save, tab closed, reopen', 'no credit (streak 7, 0 rows); "Almost there" reminder', `streak ${s}, rows today ${rowsFor(db, '2026-11-03')}, reminder: ${rem.includes('Almost there') ? '"Almost there" shown' : JSON.stringify(rem.slice(0, 60))}`,
      s === 7 && rowsFor(db, '2026-11-03') === 0 && rem.includes('Almost there')); await pg.close(); }
  // 3. 12 words, wait for auto credit toast, then Save  (+ screenshots with the toast showing)
  for (const [w, h, tag] of [[390, 844, '390'], [1280, 900, 'desktop']]) {
    const db = freshDb(); const pg = await open(db, { width: w, height: h });
    await readerType(pg, 'today', null, 12); await pg.waitForTimeout(2200);
    await pg.screenshot({ path: path.join(OUT, `reader_autosave_toast_${tag}.png`) });
    const box = await pg.evaluate(() => { const r = document.getElementById('reflectionInput').getBoundingClientRect(); const t = document.getElementById('toast'); const tr = t.getBoundingClientRect(); return { ta: [Math.round(r.top), Math.round(r.bottom)], toast: t.classList.contains('show') ? [Math.round(tr.top), Math.round(tr.bottom)] : null, vh: innerHeight }; });
    await pg.click('#reflectionSaveBtn'); await pg.waitForTimeout(1500);
    const t = await streakToasts(pg); const all = await pg.evaluate(() => window.__toasts);
    if (tag === '390') rec('3', '12 words, auto credit toast, then Save', '1 streak toast, then "Reflection saved ✓"; 1 row', `toasts: ${all.join(' | ')}; rows today ${rowsFor(db, '2026-11-03')}`, t.length === 1 && rowsFor(db, '2026-11-03') === 1 && all[all.length - 1].includes('saved'));
    results.push({ n: '7-' + tag, title: `toast vs text box at ${tag}`, geom: box });
    await pg.close();
  }
  // 4. 12 words then X immediately
  { const db = freshDb(); const pg = await open(db);
    await readerType(pg, 'today', null, 12); await pg.click('.reader-back'); await pg.waitForTimeout(3500);
    const t = await streakToasts(pg);
    rec('4', '12 words, ✕ immediately (<1.5s)', '1 credit via ✕ path, no duplicate', `streak toasts ${t.length} (${t.join(' | ')}), rows today ${rowsFor(db, '2026-11-03')}`, t.length === 1 && rowsFor(db, '2026-11-03') === 1); await pg.close(); }
  // 4b. race: auto-save credit in flight while Save lands
  { const db = freshDb(); const pg = await open(db);
    await readerType(pg, 'today', null, 12); await pg.waitForTimeout(1520); await pg.click('#reflectionSaveBtn'); await pg.waitForTimeout(2500);
    const t = await streakToasts(pg);
    rec('4b', 'race: Save tapped right as auto-save fires', '1 row, 1 streak toast', `rows today ${rowsFor(db, '2026-11-03')}, streak toasts ${t.length}`, rowsFor(db, '2026-11-03') === 1 && t.length === 1); await pg.close(); }
  // 5. past day, 50 words, leave
  { const db = freshDb(); let pg = await open(db);
    await readerType(pg, 'date', '2026-10-24', 50); await pg.waitForTimeout(2500); const t = await streakToasts(pg); await pg.close();
    rec('5', 'past day (Oct 24), 50 words, leave', 'no credit for Oct 24 or today; words saved', `rows Oct 24 ${rowsFor(db, '2026-10-24')}, rows today ${rowsFor(db, '2026-11-03')}, streak toasts ${t.length}, words saved ${db.devotional_reflections.some(r => r.entry_date === '2026-10-24')}`,
      rowsFor(db, '2026-10-24') === 0 && rowsFor(db, '2026-11-03') === 0 && t.length === 0 && db.devotional_reflections.some(r => r.entry_date === '2026-10-24')); }
  // 6. Sunday, no devotional today
  { const db = freshDb(); const before = db.attendance.length; const pg = await open(db, { clock: '2026-11-08T09:00:00+08:00' });
    const rem = await dismissReminder(pg); const s0 = await pg.evaluate(() => devoStreak);
    await readerType(pg, 'date', '2026-11-07', 12); await pg.waitForTimeout(2500); const t = await streakToasts(pg); const s1 = await pg.evaluate(() => devoStreak);
    rec('6', 'Sunday Nov 8 (no devotional today), write on Sat entry', 'no reminder, no new rows, streak unchanged', `reminder ${rem ? 'SHOWN' : 'none'}, new rows ${db.attendance.length - before}, streak ${s0}→${s1}, streak toasts ${t.length}`,
      !rem && db.attendance.length === before && s0 === s1 && t.length === 0); await pg.close(); }

  const g = results.filter(r => r.geom);
  const geomOk = g.every(r => r.geom.toast && (r.geom.toast[0] >= r.geom.ta[1] || r.geom.toast[1] <= r.geom.ta[0]));   // toast visible AND not overlapping the text box
  rec('7', 'reader at 390px + desktop; toast vs text box', 'reader works; toast clear of the text box', g.map(r => `${r.title}: textbox y ${r.geom.ta.join('-')}, toast y ${r.geom.toast ? r.geom.toast.join('-') : 'n/a'} (viewport ${r.geom.vh})`).join('; '), geomOk);
  fs.writeFileSync(path.join(OUT, 'results.json'), JSON.stringify(results, null, 1));
  const fails = results.filter(r => r.ok === false).length;
  console.log(fails ? `${fails} FAILED` : 'ALL PASS');
  await browser.close(); srv.close(); process.exit(fails ? 1 : 0);
})().catch(e => { console.error(e); process.exit(2); });
