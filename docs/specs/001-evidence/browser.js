// Spec 001 browser test - the REAL preaching_admin.html in Chromium, with a fake
// Supabase (PRACTICE data only, nothing leaves this machine). Scenario 1 data.
// Usage: node browser.js <repo dir> <out dir>
'use strict';
const path = require('path');
const fs = require('fs');
const http = require('http');
const { chromium } = require('playwright');

const REPO = process.argv[2], OUT = process.argv[3];
const SUPA_UMD = path.join(__dirname, 'node_modules/@supabase/supabase-js/dist/umd/supabase.js');

// ---- practice data ----
const NAMES = { M: 'Practice Mainstay (M)' };
['R2','R3','R4','R5','R6','R7','R8','R9','R10','R11','R12'].forEach(r => NAMES[r] = 'Practice ' + r);
const members = Object.entries(NAMES).map(([id, name]) => ({ id, name, pipeline_level: 3, lc_group: null, is_test_member: false, is_external_user: false }));
const preachers = Object.keys(NAMES).map((id, i) => ({ id: 'p' + i, member_id: id, is_active: true, is_mainstay_preacher: id === 'M',
  recurrence_pattern: null, sequence: i + 1, on_leave_until: null, notes: null }));
const ymd = d => d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
let wp = []; let nid = 1;
const add = (date, who, svc) => wp.push({ id: 'w' + (nid++), preach_date: date, service_type: svc || (new Date(date + 'T00:00:00').getDay() === 0 ? 'sunday' : 'wednesday'),
  preacher_member_id: who, original_preacher_member_id: who, created_at: '2026-01-01T00:00:00Z' });
// History Wednesdays ending ... R6 (Oct 14), R7 (Oct 21), M (Oct 28), 57 Wednesdays back, R12 never in history.
(() => { const pool = ['R2','R3','R4','R5','R6','R7','R8','R9','R10','R11']; const seq = [];
  let pi = pool.indexOf('R7') + 1; for (let k = 0; k < 57; k++) { if (k % 3 === 0) seq.push('M'); else { pi = (pi - 1 + pool.length) % pool.length; seq.push(pool[pi]); } }
  const d = new Date('2026-10-28T00:00:00'); for (const who of seq) { add(ymd(d), who); d.setDate(d.getDate() - 7); } })();
// Sundays Sep-Oct (mainstay except last Sundays R5, R6) and Nov 1 already assigned
['2026-09-06','2026-09-13','2026-09-20','2026-10-04','2026-10-11','2026-10-18','2026-11-01'].forEach(d => add(d, 'M'));
add('2026-09-27', 'R5'); add('2026-10-25', 'R6');

// ---- tiny PostgREST emulator ----
function query(table, params) {
  let rows = table === 'members' ? members : table === 'preachers' ? preachers : table === 'wednesday_preaching' ? wp : [];
  for (const [k, v] of params) {
    if (['select', 'order', 'limit', 'offset'].includes(k)) continue;
    const m = v.match(/^(eq|lt|lte|gte|gt|neq)\.(.*)$/); if (!m) continue;
    const [, op, val] = m; const f = { eq: x => String(x) === val, neq: x => String(x) !== val, lt: x => x < val, lte: x => x <= val, gt: x => x > val, gte: x => x >= val }[op];
    rows = rows.filter(r => f(r[k]));
  }
  const ord = params.get('order'); if (ord) { const [c, dir] = ord.split('.'); rows = rows.slice().sort((a, b) => (a[c] < b[c] ? -1 : a[c] > b[c] ? 1 : 0) * (dir === 'desc' ? -1 : 1)); }
  const lim = params.get('limit'); if (lim) rows = rows.slice(0, +lim);
  const sel = params.get('select'); if (sel && sel !== '*') { const keep = sel.split(',').map(s => s.trim()); rows = rows.map(r => Object.fromEntries(keep.map(c => [c, r[c]]))); }
  return rows;
}

(async () => {
  const srv = http.createServer((req, res) => {
    const p = path.join(REPO, decodeURIComponent(req.url.split('?')[0]));
    if (!p.startsWith(REPO) || !fs.existsSync(p)) { res.writeHead(404); return res.end(); }
    res.writeHead(200, { 'Content-Type': p.endsWith('.js') ? 'text/javascript' : p.endsWith('.svg') ? 'image/svg+xml' : 'text/html' }); res.end(fs.readFileSync(p));
  }).listen(0);
  const base = 'http://127.0.0.1:' + srv.address().port;
  let browser;
  try { browser = await chromium.launch(); } catch (e) { browser = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' }); }
  const inserted = []; const dialogs = [];
  async function page(width, height) {
    const ctx = await browser.newContext({ viewport: { width, height }, timezoneId: 'Asia/Manila', deviceScaleFactor: 2 });
    const pg = await ctx.newPage();
    await pg.clock.setFixedTime(new Date('2026-11-02T09:00:00+08:00'));
    await pg.route('**/cdn.jsdelivr.net/**supabase-js**', r => r.fulfill({ contentType: 'text/javascript', body: fs.readFileSync(SUPA_UMD) }));
    await pg.route('**/fonts.googleapis.com/**', r => r.fulfill({ contentType: 'text/css', body: '' }));
    await pg.route('**.supabase.co/**', async r => {
      const u = new URL(r.request().url()); const m = u.pathname.match(/\/rest\/v1\/([^/?]+)/);
      if (!m) return r.fulfill({ status: 200, contentType: 'application/json', body: '{}' });
      if (r.request().method() === 'POST' && m[1] === 'wednesday_preaching') {
        const body = JSON.parse(r.request().postData() || '[]'); (Array.isArray(body) ? body : [body]).forEach(x => { const row = { id: 'n' + (nid++), created_at: '2026-11-02T01:00:00Z', ...x }; wp.push(row); inserted.push(row); });
        return r.fulfill({ status: 201, contentType: 'application/json', body: '' });
      }
      return r.fulfill({ status: 200, contentType: 'application/json', body: JSON.stringify(query(m[1], u.searchParams)) });
    });
    await pg.addInitScript(() => sessionStorage.setItem('multiply_leader_session', JSON.stringify({ leaderId: 'M', leaderName: 'Practice Mainstay (M)', leaderLevel: 5, expiresAt: '2099-01-01T00:00:00Z' })));
    pg.on('dialog', d => { dialogs.push(d.message()); d.accept(); });
    pg.on('pageerror', e => console.log('PAGE ERROR:', e.message));
    await pg.goto(base + '/preaching_admin.html');
    await pg.waitForFunction(() => document.getElementById('calMonthTitle') && document.getElementById('calMonthTitle').textContent.includes('November'), null, { timeout: 15000 });
    return pg;
  }

  // Desktop: run Auto-fill
  const d = await page(1280, 900);
  await d.waitForTimeout(500);
  await d.screenshot({ path: path.join(OUT, 'before_desktop.png'), fullPage: true });
  await d.click('button:has-text("Auto-fill")');
  await d.waitForFunction(() => /Filled/.test(document.getElementById('toast').textContent), null, { timeout: 15000 });
  await d.waitForTimeout(400);
  await d.screenshot({ path: path.join(OUT, 'after_desktop.png'), fullPage: true });
  const name = id => NAMES[id] || id;
  const nov = inserted.filter(r => r.preach_date.startsWith('2026-11')).sort((a, b) => a.preach_date < b.preach_date ? -1 : 1);
  console.log('confirm dialog:\n' + dialogs.join('\n---\n'));
  console.log('November inserts:'); nov.forEach(r => console.log(' ', r.preach_date, r.service_type, name(r.preacher_member_id)));
  const calText = await d.evaluate(() => document.getElementById('calGrid').innerText);
  fs.writeFileSync(path.join(OUT, 'calendar_text.txt'), calText);

  // Phone width (390px) - same data, now filled
  const m = await page(390, 844);
  await m.waitForTimeout(500);
  await m.screenshot({ path: path.join(OUT, 'after_390.png'), fullPage: true });

  const want = { '2026-11-04': 'R8', '2026-11-11': 'R9', '2026-11-18': 'M', '2026-11-25': 'R10', '2026-11-29': 'R7' };
  let ok = true; for (const [dt, who] of Object.entries(want)) { const r = nov.find(x => x.preach_date === dt); const got = r ? r.preacher_member_id : '-'; if (got !== who) ok = false; console.log(`${dt}: expected ${who}, got ${got} ${got === who ? 'OK' : 'MISMATCH'}`); }
  console.log(ok ? 'BROWSER PASS' : 'BROWSER FAIL');
  await browser.close(); srv.close(); process.exit(ok ? 0 : 1);
})().catch(e => { console.error(e); process.exit(2); });
