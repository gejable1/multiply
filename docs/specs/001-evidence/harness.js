// Spec 001 harness - runs the REAL autofillNext12() (old = main, new = branch)
// against a fake Supabase client with PRACTICE data only. Today is fixed to
// Mon 2026-11-02. Usage: node harness.js <new preaching_admin.html> <old preaching_admin.html>
'use strict';
const fs = require('fs');
const vm = require('vm');

const FUNCS = ['ymd', 'parseDate', 'fmtDate', 'sundaysInMonth', 'wednesdaysInMonth', 'isLastSundayOfMonth',
  '_recurrenceCycleLength', '_autofillAnchorPointers', 'loadAssignmentsRange', 'autofillNext12'];

function extract(src, name) {
  const re = new RegExp('^(async )?function ' + name + '\\([\\s\\S]*?\\n}\\n', 'm');
  const m = src.match(re);
  return m ? m[0] : '';
}

// ---- fake Supabase query builder (supports the calls autofill makes) ----
function makeDb(rows, log) {
  return {
    from(table) {
      const st = { table, cols: '*', filters: [], order: null, limit: null };
      const b = {
        select(c) { st.cols = c; return b; },
        eq(c, v) { st.filters.push(r => r[c] === v); return b; },
        lt(c, v) { st.filters.push(r => r[c] < v); return b; },
        gte(c, v) { st.filters.push(r => r[c] >= v); return b; },
        lte(c, v) { st.filters.push(r => r[c] <= v); return b; },
        order(c, o) { st.order = [c, !o || o.ascending !== false]; return b; },
        limit(n) { st.limit = n; return b; },
        insert(ins) { log.inserts.push(...ins); return Promise.resolve({ error: null }); },
        then(res, rej) {
          let out = rows.filter(r => st.filters.every(f => f(r)));
          if (st.order) { const [c, asc] = st.order; out.sort((a, b2) => (a[c] < b2[c] ? -1 : a[c] > b2[c] ? 1 : 0) * (asc ? 1 : -1)); }
          if (st.limit != null) out = out.slice(0, st.limit);
          if (st.cols !== '*') {   // project like PostgREST: unselected columns are absent
            const keep = st.cols.split(',').map(s => s.trim());
            out = out.map(r => Object.fromEntries(keep.map(k => [k, r[k]])));
          } else out = out.map(r => ({ ...r }));
          return Promise.resolve({ data: out, error: null }).then(res, rej);
        }
      };
      return b;
    }
  };
}

async function runOnce(src, preachers, rows) {
  const log = { inserts: [], toasts: [], confirms: [] };
  const RealDate = Date;
  const FIX = new RealDate(2026, 10, 2, 9, 0, 0).getTime();   // Mon Nov 2 2026, local
  class FDate extends RealDate { constructor(...a) { if (a.length) super(...a); else super(FIX); } static now() { return FIX; } }
  const ctx = {
    Date: FDate, Map, Set, Math, String, console, Promise,
    db: makeDb(rows, log), _preachers: preachers, _assignments: [],
    toast: (m) => log.toasts.push(m), confirm: (m) => { log.confirms.push(m); return true; },
    loadAssignments: async () => {}, renderCalendar: () => {}
  };
  vm.createContext(ctx);
  vm.runInContext(FUNCS.map(n => extract(src, n)).join('\n') + '\n;this.__run = autofillNext12;', ctx);
  await ctx.__run();
  return log;
}

// ---- practice roster: M (mainstay #1), R2..R12 rotation ----
function roster(opts = {}) {
  const names = opts.names || ['M', 'R2', 'R3', 'R4', 'R5', 'R6', 'R7', 'R8', 'R9', 'R10', 'R11', 'R12'];
  return names.map((n, i) => ({ id: 'p' + i, member_id: n, is_active: true, is_mainstay_preacher: n === 'M',
    recurrence_pattern: null, sequence: i + 1, on_leave_until: (opts.leave || {})[n] || null, member: { name: n } }));
}
let _id = 1;
const row = (date, sched, preached) => ({ id: 'w' + (_id++), preach_date: date, service_type: new Date(date + 'T00:00:00').getDay() === 0 ? 'sunday' : 'wednesday',
  preacher_member_id: preached || sched, original_preacher_member_id: sched });
// Wednesdays going back from a date, `count` of them
function wedsBack(lastWed, count) { const out = []; const d = new Date(lastWed + 'T00:00:00'); for (let i = 0; i < count; i++) { out.unshift(ymdL(d)); d.setDate(d.getDate() - 7); } return out; }
function ymdL(d) { return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0'); }
// Long, realistic history: "2 rotation then M", rotation walking BACKWARDS from `lastRot`
// through `pool` (pool excludes recently added preachers).
function wedHistory(seqNewestLast, extraBack, pool) {
  const dates = wedsBack('2026-10-28', seqNewestLast.length + extraBack);
  const names = seqNewestLast.slice();
  // fill older slots backward keeping the 2-then-M rhythm
  let pi = pool.indexOf(names.find(n => n !== 'M'));
  const older = [];
  let pos = 0; // walking back from the oldest given entry
  for (let i = 0; i < extraBack; i++) {
    // rhythm back from seq: compute by modular position relative to newest
    const k = (seqNewestLast.length + i); // distance from newest (0-based)
    const isM = (k % 3) === 0;            // newest-M at k=0, then every 3rd back
    if (isM) older.unshift('M'); else { pi = (pi - 1 + pool.length) % pool.length; older.unshift(pool[pi]); }
  }
  return dates.map((d, i) => row(d, (older.concat(names))[i]));
}

const lastSun = (y, m) => { const d = new Date(y, m + 1, 0); while (d.getDay() !== 0) d.setDate(d.getDate() - 1); return ymdL(d); };

function picks(log, rows) {
  const all = rows.filter(r => r.preach_date >= '2026-11-02').map(r => ({ ...r, existing: true }))
    .concat(log.inserts.map(r => ({ ...r, existing: false })));
  const weds = all.filter(r => new Date(r.preach_date + 'T00:00:00').getDay() === 3).sort((a, b) => a.preach_date < b.preach_date ? -1 : 1);
  const sun = all.find(r => r.preach_date === lastSun(2026, 10));
  const fmt = r => (r.original_preacher_member_id ?? r.preacher_member_id) + (r.existing ? '*' : '');
  return { wed: weds.slice(0, 4).map(fmt), wedDates: weds.slice(0, 4).map(r => r.preach_date.slice(5)), sun: sun ? fmt(sun) : '-' };
}

const POOL11 = ['R2', 'R3', 'R4', 'R5', 'R6', 'R7', 'R8', 'R9', 'R10', 'R11']; // before R12 was added

const SCEN = [
  { n: 1, t: 'Reported bug: ...R6, R7, M; R12 added recently; >11 rotation Weds in history',
    pre: roster(), rows: () => [...wedHistory(['R6', 'R7', 'M'], 54, POOL11), row(lastSun(2026, 8), 'R5'), row(lastSun(2026, 9), 'R6')],
    exp: { wed: ['R8', 'R9', 'M', 'R10'], sun: 'R7' } },
  { n: 2, t: 'Swap: last rotation Wed scheduled R5, preached by R9',
    pre: roster(), rows: () => [...wedHistory(['M', 'R4', 'R5', 'M'], 30, POOL11).map(r => r.original_preacher_member_id === 'R5' && r.preach_date === '2026-10-21' ? { ...r, preacher_member_id: 'R9' } : r), row(lastSun(2026, 9), 'R6')],
    exp: { wed: ['R6', 'R7', 'M', 'R8'], sun: 'R7' } },
  { n: 3, t: 'Removed preacher: newest rotation Wed by X (not in roster), before it R4',
    pre: roster(), rows: () => [...wedHistory(['M', 'R4', 'X', 'M'], 30, POOL11), row(lastSun(2026, 9), 'R6')],
    exp: { wed: ['R5', 'R6', 'M', 'R7'], sun: 'R7' } },
  { n: 4, t: 'On leave: R8 next but on leave until Nov 10',
    pre: roster({ leave: { R8: '2026-11-10' } }), rows: () => [...wedHistory(['R6', 'R7', 'M'], 30, POOL11), row(lastSun(2026, 9), 'R6')],
    exp: { wed: ['R9', 'R10', 'M', 'R11'], sun: 'R7' }, rerun: true },
  { n: 5, t: 'Fresh start: no history',
    pre: roster(), rows: () => [], exp: { wed: ['R2', 'R3', 'M', 'R4'], sun: 'R2' } },
  { n: 6, t: 'Last-Sunday rotation: ...R5 (Sep), R6 (Oct); Wed pointer elsewhere (..R11, M)',
    pre: roster(), rows: () => [...wedHistory(['R10', 'R11', 'M'], 30, POOL11), row(lastSun(2026, 8), 'R5'), row(lastSun(2026, 9), 'R6')],
    exp: { wed: ['R12', 'R2', 'M', 'R3'], sun: 'R7' } },
  { n: '7a', t: 'Cycle: history ends M, R3 -> rotation, then M',
    pre: roster(), rows: () => [...wedHistory(['R2', 'M', 'R3'], 30, POOL11), row(lastSun(2026, 9), 'R6')],
    exp: { wed: ['R4', 'M', 'R5', 'R6'], sun: 'R7' } },
  { n: '7b', t: 'Cycle: history ends R3, R4 -> M next',
    pre: roster(), rows: () => [...wedHistory(['M', 'R3', 'R4'], 30, POOL11), row(lastSun(2026, 9), 'R6')],
    exp: { wed: ['M', 'R5', 'R6', 'M'], sun: 'R7' } },
  { n: 8, t: 'Existing in-window slot: Nov 4 = R10 hand-assigned (history ...R6, R7, M)',
    pre: roster(), rows: () => [...wedHistory(['R6', 'R7', 'M'], 30, POOL11), row(lastSun(2026, 9), 'R6'), row('2026-11-04', 'R10')],
    exp: { wed: ['R10*', 'R11', 'M', 'R12'], sun: 'R7' } },
  { n: 9, t: 'Nothing to fill: every preacher on leave through the window',
    pre: roster({ leave: Object.fromEntries(['M', 'R2', 'R3', 'R4', 'R5', 'R6', 'R7', 'R8', 'R9', 'R10', 'R11', 'R12'].map(n => [n, '2027-12-31'])) }),
    rows: () => [...wedHistory(['R6', 'R7', 'M'], 30, POOL11)], exp: { toast: 'Nothing to fill' } },
  { n: 10, t: 'Only mainstay, no rotation (history of M-only Wednesdays)',
    pre: roster({ names: ['M'] }), rows: () => wedsBack('2026-10-28', 10).filter((_, i) => i % 3 === 2).map(d => row(d, 'M')), exp: { sameAsOld: true } },
];

(async () => {
  const NEW = fs.readFileSync(process.argv[2], 'utf8'), OLD = fs.readFileSync(process.argv[3], 'utf8');
  let pass = 0, fail = 0; const md = [];
  md.push('| # | Scenario | Expected (Nov 4, 11, 18, 25 · Nov 29) | New code | Old code | Result |', '|---|---|---|---|---|---|');
  for (const s of SCEN) {
    _id = 1; const rows = s.rows();
    const ln = await runOnce(NEW, JSON.parse(JSON.stringify(s.pre)), rows);
    const lo = await runOnce(OLD, JSON.parse(JSON.stringify(s.pre)), rows);
    const pn = picks(ln, rows), po = picks(lo, rows);
    let ok, expS, newS, oldS;
    if (s.exp.toast) {
      ok = ln.toasts.some(t => t.includes(s.exp.toast)) && ln.inserts.length === 0 && JSON.stringify(ln.toasts) === JSON.stringify(lo.toasts);
      expS = '"Nothing to fill…" toast, 0 inserts'; newS = ln.toasts.join(' / ') + ` (${ln.inserts.length} inserts)`; oldS = lo.toasts.join(' / ') + ` (${lo.inserts.length} inserts)`;
    } else if (s.exp.sameAsOld) {
      ok = JSON.stringify(ln.inserts) === JSON.stringify(lo.inserts) && ln.inserts.length > 0;
      expS = 'identical to old code'; newS = `${pn.wed.join(', ')} · ${pn.sun} (${ln.inserts.length} inserts)`; oldS = `${po.wed.join(', ')} · ${po.sun} (${lo.inserts.length} inserts)`;
    } else {
      ok = JSON.stringify(pn.wed) === JSON.stringify(s.exp.wed) && pn.sun === s.exp.sun;
      expS = `${s.exp.wed.join(', ')} · ${s.exp.sun}`; newS = `${pn.wed.join(', ')} · ${pn.sun}`; oldS = `${po.wed.join(', ')} · ${po.sun}`;
    }
    if (s.rerun) {   // scenario 4: second auto-fill run (history now includes run 1) - R8 returns after leave
      const rows2 = rows.concat(ln.inserts.map((r, i) => ({ id: 'n' + i, ...r })));
      const l2 = await runOnce(NEW, JSON.parse(JSON.stringify(s.pre)), rows2);
      const rotSeq = l2.inserts.filter(r => new Date(r.preach_date + 'T00:00:00').getDay() === 3 && r.original_preacher_member_id !== 'M').map(r => r.original_preacher_member_id);
      const back = rotSeq.includes('R8');
      ok = ok && back;
      newS += `<br>run 2 rotation: ${rotSeq.slice(0, 6).join(', ')}… (R8 ${back ? 'back ✓' : 'MISSING'})`;
    }
    ok ? pass++ : fail++;
    md.push(`| ${s.n} | ${s.t} | ${expS} | ${newS} | ${oldS} | ${ok ? '✅ PASS' : '❌ FAIL'} |`);
    console.log((ok ? 'PASS ' : 'FAIL ') + s.n + '  new=' + newS.replace(/<br>/g, ' | ') + '   old=' + oldS);
  }
  md.push('', `**${pass} passed, ${fail} failed.** \`*\` = slot already assigned before auto-fill.`);
  fs.writeFileSync(process.argv[4] || 'results.md', md.join('\n') + '\n');
  console.log(`${pass} passed, ${fail} failed`);
  process.exit(fail ? 1 : 0);
})();
