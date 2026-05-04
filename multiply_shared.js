// ═══════════════════════════════════════════════════════════════
// MULTIPLY · Shared Module
// ─────────────────────────────────────────────────────────────────
// Loaded by both multiply_dashboard.html (desktop) and
// lc_leader_tool.html (mobile). Provides the single source of truth
// for: Supabase client, leader-session gating, scoping rules,
// sensitivity tiers, and audit logging.
//
// Pages should:
//   1. Load this script BEFORE any of their own logic runs.
//   2. Call MultiplyShared.gateOrRedirect(LOGIN_URL) at the very top
//      of <body> to guarantee an authenticated leader session before
//      anything renders.
//   3. Read the active leader from window.LEADER, scope arrays via
//      LeaderScope.apply(members), and gate sensitive UI via
//      LeaderScope.canSee(tier, member).
//
// This module is intentionally framework-free and dependency-light —
// it expects only the Supabase JS SDK to already be loaded.
// ═══════════════════════════════════════════════════════════════

(function (global) {
  'use strict';

  // ───── Configuration ─────
  const SB_URL = 'https://tirzeikbflolaclgtket.supabase.co';
  const SB_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpcnplaWtiZmxvbGFjbGd0a2V0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcxMTYwOTksImV4cCI6MjA5MjY5MjA5OX0.ejHouXj7NOB3yUmcdOuUFfk-HHPbfyCmQACb4xNk2V8';

  const SESSION_KEY = 'multiply_leader_session';
  const LEVEL_NAMES = ['Pre-Pipeline', 'Team Member', 'Leader', 'Coach', 'Director', 'Executive Leader'];
  const PASTOR_LEVEL = 5;

  // ───── Supabase client (singleton) ─────
  let _db = null;
  function getDB() {
    if (_db) return _db;
    if (typeof global.supabase === 'undefined' || !global.supabase.createClient) {
      console.error('Supabase SDK not loaded. Include @supabase/supabase-js BEFORE multiply_shared.js.');
      return null;
    }
    _db = global.supabase.createClient(SB_URL, SB_KEY, {
      auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false }
    });
    return _db;
  }

  // ───── Leader-session gate ─────
  // Reads the session from sessionStorage. Returns the session object
  // if valid, null otherwise. Does NOT redirect — the page should
  // call gateOrRedirect() if it wants the redirect behavior.
  function getValidSession() {
    let sess = null;
    try {
      const raw = sessionStorage.getItem(SESSION_KEY);
      if (raw) sess = JSON.parse(raw);
    } catch (e) {
      sess = null;
    }
    if (!sess || !sess.leaderId || !sess.expiresAt) return null;
    if (Date.parse(sess.expiresAt) <= Date.now()) return null;
    if ((sess.leaderLevel || 0) < 2) return null;
    return sess;
  }

  // Hard gate. If session is invalid, clear storage and redirect.
  // Returns true if session was valid (caller may proceed).
  function gateOrRedirect(loginUrl) {
    const sess = getValidSession();
    if (sess) {
      global.LEADER = sess; // expose globally for legacy code that reads `LEADER`
      return true;
    }
    try { sessionStorage.removeItem(SESSION_KEY); } catch (e) {}
    global.location.replace(loginUrl || 'leader_login.html');
    return false;
  }

  // Logout — mark active session ended in DB, clear storage, redirect.
  async function logoutLeader(loginUrl) {
    const L = global.LEADER || getValidSession() || {};
    try {
      const db = getDB();
      if (db && L.leaderId) {
        await db.from('leader_sessions').update({
          ended_at: new Date().toISOString(),
          ended_reason: 'logout'
        }).eq('leader_id', L.leaderId).is('ended_at', null);
      }
    } catch (e) { /* non-fatal */ }
    try { sessionStorage.removeItem(SESSION_KEY); } catch (e) {}
    global.location.replace(loginUrl || 'leader_login.html');
  }

  // ───── LeaderScope ─────
  // Three views:
  //   'disciples' — m.discipler_id === LEADER.leaderId
  //   'tree'      — direct + every descendant in the discipler graph
  //   'ministry'  — same primary ministry as the leader
  //   'all'       — pastor only
  //
  // Plus sensitivity tiers:
  //   'public'    — anyone in scope sees this
  //   'pastoral'  — anyone in this leader's tree
  //   'sensitive' — direct discipler + pastor only
  //   'pastor'    — pastor only
  //
  // IMPORTANT: This is UI scoping only. RLS is the proper fix —
  // see RLS_PHASE_2.md. Phase 1 protects against accidental exposure
  // by honest leaders; it does not stop a determined DevTools user.
  function makeLeaderScope(getMembers) {
    let current = 'disciples';

    function L() { return global.LEADER || {}; }
    function isPastor() { return (L().leaderLevel || 0) >= PASTOR_LEVEL; }

    function getDirect() {
      return (getMembers() || []).filter(m => m.discipler_id === L().leaderId);
    }

    function getTree() {
      const members = getMembers() || [];
      const byDiscipler = new Map();
      members.forEach(m => {
        if (!m.discipler_id) return;
        if (!byDiscipler.has(m.discipler_id)) byDiscipler.set(m.discipler_id, []);
        byDiscipler.get(m.discipler_id).push(m);
      });
      const visited = new Set();
      const result = [];
      const queue = [L().leaderId];
      while (queue.length) {
        const node = queue.shift();
        const children = byDiscipler.get(node) || [];
        children.forEach(child => {
          if (visited.has(child.id)) return; // cycle guard
          visited.add(child.id);
          result.push(child);
          queue.push(child.id);
        });
      }
      return result;
    }

    function getMinistry() {
      const members = getMembers() || [];
      const me = members.find(m => m.id === L().leaderId);
      if (!me) return [];
      const myMins = [me.ministry, me.ministry2, me.ministry3].filter(Boolean);
      if (!myMins.length) return [];
      return members.filter(m => {
        if (m.id === L().leaderId) return false;
        return [m.ministry, m.ministry2, m.ministry3].filter(Boolean).some(min => myMins.includes(min));
      });
    }

    function apply(memberList, opts) {
      const list = memberList || getMembers() || [];
      // ─── TEST-MEMBER FILTER (Pastor's call, May 2026) ───
      // By default, exclude members flagged is_test_member so they don't
      // count in any statistical surface. Admin contexts (Pastor's full
      // member list, edit modal lookup) pass {includeTest:true} to bypass.
      const includeTest = !!(opts && opts.includeTest);
      const filtered = includeTest ? list : list.filter(m => !m.is_test_member);
      // We need to filter the input to getDirect/getTree/getMinistry too,
      // since they read from getMembers() directly. Do that by temporarily
      // wrapping getMembers — but simpler: post-filter their results.
      const stripTest = arr => includeTest ? arr : arr.filter(m => !m.is_test_member);
      if (current === 'all' && isPastor()) return filtered;
      if (current === 'disciples') return stripTest(getDirect());
      if (current === 'tree') return stripTest(getTree());
      if (current === 'ministry') return stripTest(getMinistry());
      return stripTest(getDirect()); // safe fallback
    }

    function setView(v) {
      if (!isPastor() && v === 'all') v = 'tree';
      current = v;
    }

    function getCurrent() { return current; }

    function canSee(tier, member) {
      if (isPastor()) return true;
      // Self-clause: a leader can always see their OWN profile, diagnostics,
      // and assessments. Otherwise leaders couldn't self-administer their own
      // DISC, Enneagram, Strengths, etc. Only blocks looking at OTHER leaders.
      if (member && member.id === L().leaderId) return true;
      if (!member) return tier === 'public';
      if (tier === 'public') return true;
      if (tier === 'pastoral') {
        return member.discipler_id === L().leaderId
          || getTree().some(x => x.id === member.id);
      }
      if (tier === 'sensitive') {
        return member.discipler_id === L().leaderId;
      }
      if (tier === 'pastor') return false; // handled by isPastor() above
      return false;
    }

    return { setView, getCurrent, isPastor, getDirect, getTree, getMinistry, apply, canSee };
  }

  // ───── Audit log helper ─────
  // Fire-and-forget; never throws. Pages should call after rendering
  // sensitive content so the pastor can audit who viewed what.
  function logView(viewedMemberId, context) {
    try {
      const db = getDB();
      const L = global.LEADER || {};
      if (!db || !L.leaderId || !viewedMemberId) return;
      db.from('view_log').insert({
        viewer_id: L.leaderId,
        viewed_member_id: viewedMemberId,
        context: context || 'profile_open'
      }).then(() => {}, () => {}); // swallow errors silently
    } catch (e) { /* ignore */ }
  }

  // ───── Sensitivity-tier card markup ─────
  // Drop-in HTML for "this section is hidden" placeholders, used by
  // both pages so the look is consistent.
  function tierLockCard(opts) {
    opts = opts || {};
    const title = opts.title || 'Section Hidden';
    const reason = opts.reason || 'You do not have access to view this section.';
    return (
      '<div style="background:#f5efe3;border:1.5px dashed #e2d8cc;border-radius:8px;' +
        'padding:1.25rem 1rem;text-align:center;">' +
        '<div style="font-size:24px;margin-bottom:.4rem;">🔒</div>' +
        '<div style="font-size:13px;font-weight:600;color:#1a1612;margin-bottom:.3rem;">' +
          escapeHTML(title) +
        '</div>' +
        '<div style="font-size:11.5px;color:#6b5f4f;line-height:1.55;max-width:340px;margin:0 auto;">' +
          escapeHTML(reason) +
        '</div>' +
      '</div>'
    );
  }

  function escapeHTML(s) {
    return String(s == null ? '' : s).replace(/[&<>"']/g, c => (
      {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]
    ));
  }

  // ───── Public surface ─────
  global.MultiplyShared = {
    SB_URL, SB_KEY, SESSION_KEY, LEVEL_NAMES, PASTOR_LEVEL,
    getDB,
    getValidSession,
    gateOrRedirect,
    logoutLeader,
    makeLeaderScope,
    logView,
    tierLockCard,
    escapeHTML
  };
})(typeof window !== 'undefined' ? window : globalThis);
