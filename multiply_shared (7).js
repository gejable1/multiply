// ═══════════════════════════════════════════════════════════════
// MULTIPLY · Shared Module
// ─────────────────────────────────────────────────────────────────
// Loaded by:
//   • multiply_dashboard.html (Pastor desktop)
//   • lc_leader_tool.html     (LC leader mobile)
//   • lc_attendance_report.html
//   • member_tool.html        (MMT — member mobile)
//
// Provides single source of truth for:
//   • Supabase client (singleton)
//   • Leader-session gating (gateOrRedirect, logoutLeader)
//   • Member-session gating (gateMemberOrRedirect, logoutMember)
//   • LeaderScope factory (scoping + tiers for leader-side tools)
//   • Audit logging
//
// Two distinct session keys live in sessionStorage:
//   multiply_leader_session — used by MD/MLT/reports
//   multiply_member_session — used by MMT
// They are independent. Same device can have either, both, or neither.
//
// IMPORTANT: All four entry pages call their respective gate function
// at the top of <body>. If a gate function is MISSING from this module,
// the calling page throws TypeError synchronously and the loading spinner
// hangs forever. Do not remove member or leader gate functions without
// updating every consumer.
// ═══════════════════════════════════════════════════════════════

(function (global) {
  'use strict';

  // ───── Configuration ─────
  const SB_URL = 'https://tirzeikbflolaclgtket.supabase.co';
  const SB_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpcnplaWtiZmxvbGFjbGd0a2V0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcxMTYwOTksImV4cCI6MjA5MjY5MjA5OX0.ejHouXj7NOB3yUmcdOuUFfk-HHPbfyCmQACb4xNk2V8';

  const SESSION_KEY = 'multiply_leader_session';
  const MEMBER_SESSION_KEY = 'multiply_member_session';   // for MMT (member tool)
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


  // ═════════════════════════════════════════════════════════════
  // MEMBER-SESSION FUNCTIONS (for MMT — member_tool.html)
  // ───────────────────────────────────────────────────────────
  // The member tool uses a SEPARATE session (multiply_member_session)
  // from the leader tools, because a single device may be used by
  // both a leader and an ordinary member at different times. These
  // mirror the leader functions above but read/write the member key.
  //
  // The session shape is set by member_login.html's loginSuccess():
  //   { memberId, memberName, memberLevel, memberRole, memberLcGroup,
  //     memberDisciplerName, expiresAt, sessionStart }
  // ═════════════════════════════════════════════════════════════

  function getValidMemberSession() {
    let sess = null;
    try {
      const raw = sessionStorage.getItem(MEMBER_SESSION_KEY);
      if (raw) sess = JSON.parse(raw);
    } catch (e) {
      sess = null;
    }
    if (!sess || !sess.memberId || !sess.expiresAt) return null;
    if (Date.parse(sess.expiresAt) <= Date.now()) return null;
    return sess;
  }

  // Hard gate for MMT. If member session is invalid, clear storage and
  // redirect to login. Returns true if session was valid (caller may
  // proceed); on success, sets window.MEMBER for the page to read.
  function gateMemberOrRedirect(loginUrl) {
    const sess = getValidMemberSession();
    if (sess) {
      global.MEMBER = sess;
      return true;
    }
    try { sessionStorage.removeItem(MEMBER_SESSION_KEY); } catch (e) {}
    global.location.replace(loginUrl || 'member_login.html');
    return false;
  }

  // Logout for members — clear storage and redirect to login.
  // No DB session table for members in Phase 1 (could be added later
  // if we want last-login auditing parallel to leader_sessions).
  function logoutMember(loginUrl) {
    try { sessionStorage.removeItem(MEMBER_SESSION_KEY); } catch (e) {}
    global.location.replace(loginUrl || 'member_login.html');
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
      // ─── HIDDEN-MEMBER FILTERS (Pastor's call, May 2026) ───
      // By default, exclude:
      //   • is_test_member      — Pastor's QA accounts (May 2026)
      //   • is_external_user    — real people trying the app but not yet
      //                            church members (May 2026)
      // …so neither shows up in pipeline counts, member lists shown to
      // leaders, EOLO/celebration feeds, or anywhere statistics matter.
      // Admin contexts (Pastor's full member list, edit-modal lookup,
      // login search) pass {includeTest:true} (legacy name kept for
      // compatibility) which now also re-includes external users, since
      // both categories are "people Pastor manages but doesn't count".
      const includeHidden = !!(opts && (opts.includeTest || opts.includeAll));
      const filtered = includeHidden
        ? list
        : list.filter(m => !m.is_test_member && !m.is_external_user);
      // We need to filter the input to getDirect/getTree/getMinistry too,
      // since they read from getMembers() directly. Do that by temporarily
      // wrapping getMembers — but simpler: post-filter their results.
      const stripHidden = arr => includeHidden
        ? arr
        : arr.filter(m => !m.is_test_member && !m.is_external_user);
      if (current === 'all' && isPastor()) return filtered;
      if (current === 'disciples') return stripHidden(getDirect());
      if (current === 'tree') return stripHidden(getTree());
      if (current === 'ministry') return stripHidden(getMinistry());
      return stripHidden(getDirect()); // safe fallback
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

  // ═════════════════════════════════════════════════════════════
  // LESSON ACCESS PREDICATE (Phase 3 — May 2026)
  // ───────────────────────────────────────────────────────────
  // Determines which pipeline_lessons (and which attachments WITHIN
  // each lesson) a given user can see.
  //
  // Audience model (lesson-level — pipeline_lessons.audience):
  //   'pastor_only' → only Pastor (level >= PASTOR_LEVEL)
  //   'cohort_only' → only people via pipeline_lesson_grants OR cohort membership
  //   'lc_leaders'  → leader (level >= 2) + Pastor
  //   'all_members' → everyone
  //
  // Attachment-level (per row in attachments JSONB):
  //   role_required ∈ {'all', 'apprentice+', 'teacher+', 'pastor_only'}
  //
  //   'all'         — anyone with lesson access
  //   'apprentice+' — apprentices, co-teachers, teachers (in granted cohort), Pastor
  //   'teacher+'    — co-teachers, teachers (in granted cohort), Pastor; OR
  //                   apprentices in a granted cohort IF the cohort has an unlock
  //                   for this lesson (cohort_lesson_unlocks row)
  //   'pastor_only' — only Pastor
  //
  // The viewer (MLT/MMT) calls fetchVisibleLessons() which returns a
  // ready-to-render array. No further filtering needed downstream.
  //
  // API:
  //   await MultiplyShared.lessons.fetchVisibleLessons({
  //     memberId: '…',
  //     isPastor: boolean,
  //     isLeader: boolean        // level >= 2
  //   })
  //   → returns [{ lesson, role, attachments, lockedAttachmentCount }, …]
  //
  // Where:
  //   lesson — full pipeline_lessons row
  //   role   — the user's effective role for THIS lesson:
  //              'pastor' | 'teacher' | 'co-teacher' | 'apprentice'
  //              | 'observer' | 'leader' | 'member'
  //   attachments — filtered + sorted list of {label, url, role_required}
  //                  that the user CAN see
  //   lockedAttachmentCount — how many were hidden (for UI hint)
  // ═════════════════════════════════════════════════════════════

  // Role rank — higher means more privileged.
  // The role_required gate compares the user's rank to the attachment's
  // minimum-required rank. 'all' = 0, 'apprentice+' = 1, 'teacher+' = 2,
  // 'pastor_only' = 3. We compute the user's role-for-this-lesson and
  // compare ranks.
  const ROLE_RANK = {
    'all':         0,
    'apprentice+': 1,
    'teacher+':    2,
    'pastor_only': 3
  };

  // Map the user's batch-role string (from cohort_members.role) to an
  // attachment-rank number.
  // Pastor always = 3. Leader-not-in-cohort = 0 (sees only 'all' attachments).
  function _userRoleRankForLesson(opts) {
    if (opts.isPastor) return 3;
    if (opts.batchRole === 'teacher')    return 2;
    if (opts.batchRole === 'co-teacher') return 2;
    if (opts.batchRole === 'apprentice') {
      // Apprentice with cohort unlock for this lesson → promoted to teacher rank
      return opts.cohortUnlockedForThisLesson ? 2 : 1;
    }
    if (opts.batchRole === 'observer') return 0;
    // Not in any cohort that grants this lesson
    return 0;
  }

  async function fetchVisibleLessons(opts) {
    opts = opts || {};
    const memberId = opts.memberId;
    const isPastor = !!opts.isPastor;
    const isLeader = !!opts.isLeader;
    const db = getDB();
    if (!db) return [];
    if (!memberId && !isPastor) return [];

    // Parallel fetch. Use only published lessons unless Pastor (who can
    // preview drafts via MD; but in MLT context we still show only published
    // since MLT viewers shouldn't see Pastor's drafts).
    const [lRes, gRes, cmRes, unRes] = await Promise.all([
      db.from('pipeline_lessons').select('*').eq('published', true),
      db.from('pipeline_lesson_grants').select('*'),
      memberId
        ? db.from('cohort_members').select('cohort_id, role, status').eq('member_id', memberId).eq('status', 'active')
        : Promise.resolve({ data: [] }),
      // Unlocks for any cohort the user is in. We over-fetch slightly
      // (could narrow to relevant cohorts) but the table is small.
      db.from('cohort_lesson_unlocks').select('*')
    ]);
    if (lRes.error) throw lRes.error;
    if (gRes.error) throw gRes.error;
    if (cmRes.error) throw cmRes.error;
    if (unRes.error) throw unRes.error;

    const lessons = lRes.data || [];
    const grants = gRes.data || [];
    const myCohortRoles = (cmRes.data || []);
    const allUnlocks = unRes.data || [];

    // Index cohort program ids for program-level grants
    const myCohortIds = new Set(myCohortRoles.map(cm => cm.cohort_id));

    // Build a lookup: cohort_id → role
    const cohortRoleMap = {};
    myCohortRoles.forEach(cm => { cohortRoleMap[cm.cohort_id] = cm.role; });

    // Pre-fetch program ids for my cohorts (needed for program-level grant match)
    // We can derive this from the cohorts table — but to avoid another query,
    // we'll filter grants of type cohort_id first, then check program_id grants
    // against cohorts we already know we're in.
    // For program-level grants, we need to know which programs our cohorts belong to.
    // Best: fetch the cohorts the user is in.
    let myCohortPrograms = new Set();
    if (myCohortIds.size > 0) {
      const cRes = await db.from('cohorts')
        .select('id, program_id')
        .in('id', Array.from(myCohortIds));
      if (cRes.error) throw cRes.error;
      (cRes.data || []).forEach(c => myCohortPrograms.add(c.program_id));
    }

    // Compute per-lesson: do I have lesson-level access? if so, my role for it.
    const result = [];
    for (const l of lessons) {
      // 1. Lesson-level audience check
      let lessonAccessible = false;
      let accessReason = null;
      if (isPastor) {
        lessonAccessible = true;
        accessReason = 'pastor';
      } else if (l.audience === 'all_members') {
        lessonAccessible = true;
        accessReason = 'all_members';
      } else if (l.audience === 'lc_leaders') {
        if (isLeader) {
          lessonAccessible = true;
          accessReason = 'lc_leaders';
        }
      } else if (l.audience === 'cohort_only') {
        // Check if any grant matches
        const lessonGrants = grants.filter(g => g.lesson_id === l.id);
        for (const g of lessonGrants) {
          if (g.cohort_id && myCohortIds.has(g.cohort_id)) {
            lessonAccessible = true;
            accessReason = 'cohort_grant';
            break;
          }
          if (g.program_id && myCohortPrograms.has(g.program_id)) {
            lessonAccessible = true;
            accessReason = 'program_grant';
            break;
          }
          if (g.member_id && g.member_id === memberId) {
            lessonAccessible = true;
            accessReason = 'member_grant';
            break;
          }
        }
      }
      // 'pastor_only' audience falls through — nobody non-Pastor sees it.

      if (!lessonAccessible) continue;

      // 2. Determine the user's role for THIS lesson
      // Pick the most-privileged role across all granting cohorts.
      let bestRole = null;
      let cohortUnlockedForThisLesson = false;
      if (isPastor) {
        bestRole = 'pastor';
      } else if (accessReason === 'cohort_grant' || accessReason === 'program_grant') {
        // Walk the user's cohorts that have access to this lesson; pick the highest role.
        const grantingCohorts = [];
        const lessonGrants = grants.filter(g => g.lesson_id === l.id);
        myCohortRoles.forEach(cm => {
          const hasCohortGrant = lessonGrants.some(g => g.cohort_id === cm.cohort_id);
          const cohortInProgramGrant = lessonGrants.some(g =>
            g.program_id && myCohortPrograms.has(g.program_id)
          );
          // A program-level grant covers all my cohorts in that program — but
          // for simplicity, if ANY program-level grant matched my membership,
          // count every active cohort role I have toward role-promotion.
          if (hasCohortGrant || cohortInProgramGrant) {
            grantingCohorts.push(cm);
          }
        });
        // Role priority: teacher > co-teacher > apprentice > observer
        const rolePriority = { teacher: 4, 'co-teacher': 3, apprentice: 2, observer: 1 };
        grantingCohorts.sort((a,b) => (rolePriority[b.role]||0) - (rolePriority[a.role]||0));
        bestRole = grantingCohorts[0]?.role || 'member';
        // Check if any of the granting cohorts have unlocked this lesson
        cohortUnlockedForThisLesson = grantingCohorts.some(cm => {
          const u = allUnlocks.find(x => x.cohort_id === cm.cohort_id && x.lesson_id === l.id);
          if (!u) return false;
          if (u.unlocked_at) return true;
          if (u.scheduled_for && new Date(u.scheduled_for) <= new Date()) return true;
          return false;
        });
      } else if (accessReason === 'member_grant') {
        // Individual grant — treat as 'member' rank (sees only 'all' attachments
        // unless we want to make grants role-promote too. For now: treat as basic.)
        bestRole = 'member';
      } else if (accessReason === 'lc_leaders') {
        bestRole = 'leader';
      } else if (accessReason === 'all_members') {
        bestRole = 'member';
      }

      // 3. Filter attachments by role rank
      const userRank = _userRoleRankForLesson({
        isPastor,
        batchRole: ['teacher','co-teacher','apprentice','observer'].includes(bestRole) ? bestRole : null,
        cohortUnlockedForThisLesson
      });
      const rawAttachments = Array.isArray(l.attachments) ? l.attachments : [];
      const visibleAttachments = [];
      let lockedCount = 0;
      rawAttachments.forEach(a => {
        const requiredRank = ROLE_RANK[a.role_required || 'all'];
        if (requiredRank == null) {
          // unknown role_required — be conservative, treat as pastor-only
          if (isPastor) visibleAttachments.push(a);
          else lockedCount++;
          return;
        }
        if (userRank >= requiredRank) visibleAttachments.push(a);
        else lockedCount++;
      });

      result.push({
        lesson: l,
        role: bestRole,
        attachments: visibleAttachments,
        lockedAttachmentCount: lockedCount,
        cohortUnlockedForThisLesson  // for UI hints
      });
    }

    // Sort: by level, then track, then lesson_number
    result.sort((a, b) => {
      const al = a.lesson, bl = b.lesson;
      const lv = (al.level || 99) - (bl.level || 99);
      if (lv !== 0) return lv;
      const tr = (al.track || '').localeCompare(bl.track || '');
      if (tr !== 0) return tr;
      return (al.lesson_number || 99) - (bl.lesson_number || 99);
    });

    return result;
  }


  // ═════════════════════════════════════════════════════════════
  // WEDNESDAY PREACHING HELPERS (May 2026)
  // ───────────────────────────────────────────────────────────
  // Used by MLT and MMT to show the reminder banner for upcoming
  // preaching assignments + pending swap requests targeted at this
  // member. Pulls from three tables:
  //   • wednesday_preaching       — assignments
  //   • preaching_swap_requests   — pending swaps to respond to
  //   • preachers                 — to know if member is in roster
  //
  // Banner logic:
  //   • If you have an assignment within 7 days, banner shows.
  //   • Color escalates: 7d=gold, 3d=orange, 0d (today)=red
  //   • Day-of dismissal persists in localStorage so the day-of
  //     reminder doesn't reappear on every page load
  //
  // Dismissal storage key:
  //   multiply_preaching_dismissed_<member_id>_<preach_date>_<stage>
  //   where stage ∈ {'7d','3d','0d'}
  //
  // Public API:
  //   await MultiplyShared.preaching.getUpcomingForMember(memberId, daysAhead?)
  //     → returns nearest upcoming assignment within daysAhead (default 7)
  //       or null if none
  //
  //   await MultiplyShared.preaching.getPendingSwapsForMember(memberId)
  //     → returns array of pending swap requests where this member is TARGET
  //
  //   MultiplyShared.preaching.computeReminderStage(preachDateStr)
  //     → returns '7d' | '3d' | '0d' | null (null if outside window or past)
  //
  //   MultiplyShared.preaching.isDismissed(memberId, preachDate, stage)
  //   MultiplyShared.preaching.dismiss(memberId, preachDate, stage)
  //
  //   await MultiplyShared.preaching.renderReminderBanner(containerId, memberId, opts?)
  //     → drop-in renderer. Injects banner HTML into containerId.
  //     opts.onSwapClick(assignment) → custom handler (default: open admin)
  //     opts.bilingual = true → emit en-text/tl-text spans (for MMT)
  // ═════════════════════════════════════════════════════════════

  // ─── Timezone-safe local-date helper (see preaching_admin for rationale) ─
  function _ymdLocal(d){
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return y + '-' + m + '-' + day;
  }

  async function _preaching_getUpcomingForMember(memberId, daysAhead) {
    daysAhead = daysAhead || 7;
    const db = getDB();
    if (!db || !memberId) return null;
    const today = new Date(); today.setHours(0,0,0,0);
    const end = new Date(today); end.setDate(end.getDate() + daysAhead);
    // Use LOCAL-date helper. toISOString() shifts to UTC which off-by-ones
    // every Wednesday in Manila (UTC+8). Critical: preach_date column is
    // a Postgres DATE — no timezone — so we must send LOCAL Y-M-D.
    const todayStr = _ymdLocal(today);
    const endStr = _ymdLocal(end);
    const { data, error } = await db.from('wednesday_preaching')
      .select('*')
      .eq('preacher_member_id', memberId)
      .gte('preach_date', todayStr)
      .lte('preach_date', endStr)
      .order('preach_date')
      .limit(1);
    if (error) { console.warn('preaching.getUpcoming:', error); return null; }
    return (data && data[0]) || null;
  }

  async function _preaching_getPendingSwapsForMember(memberId) {
    const db = getDB();
    if (!db || !memberId) return [];
    const { data, error } = await db.from('preaching_swap_requests')
      .select('*')
      .eq('target_member_id', memberId)
      .eq('status', 'pending')
      .order('created_at', { ascending: false });
    if (error) { console.warn('preaching.getPendingSwaps:', error); return []; }
    return data || [];
  }

  function _preaching_computeReminderStage(preachDateStr) {
    if (!preachDateStr) return null;
    const today = new Date(); today.setHours(0,0,0,0);
    const d = new Date(preachDateStr + 'T00:00:00');
    const diff = Math.round((d - today) / 86400000);
    if (diff < 0) return null;      // past — no banner
    if (diff === 0) return '0d';    // today
    if (diff <= 3) return '3d';
    if (diff <= 7) return '7d';
    return null;                     // > 7 days — no banner yet
  }

  function _preaching_dismissKey(memberId, preachDate, stage) {
    return 'multiply_preaching_dismissed_' + memberId + '_' + preachDate + '_' + stage;
  }

  function _preaching_isDismissed(memberId, preachDate, stage) {
    try { return localStorage.getItem(_preaching_dismissKey(memberId, preachDate, stage)) === '1'; }
    catch (e) { return false; }
  }

  function _preaching_dismiss(memberId, preachDate, stage) {
    try { localStorage.setItem(_preaching_dismissKey(memberId, preachDate, stage), '1'); }
    catch (e) { /* localStorage unavailable */ }
  }

  // Drop-in HTML renderer for both MLT and MMT.
  // The banner is injected into containerId (which should be an empty div
  // located at the top of the home screen).
  async function _preaching_renderReminderBanner(containerId, memberId, opts) {
    opts = opts || {};
    const container = document.getElementById(containerId);
    if (!container || !memberId) return;
    const bilingual = !!opts.bilingual;

    // Fetch in parallel
    const [assignment, swaps] = await Promise.all([
      _preaching_getUpcomingForMember(memberId, 7),
      _preaching_getPendingSwapsForMember(memberId)
    ]);

    const parts = [];

    // ── Pending swap requests targeting this member ──
    if (swaps && swaps.length > 0) {
      // Fetch the requester's name + assignment dates
      const db = getDB();
      const reqIds = swaps.map(s => s.requester_member_id);
      const assignIds = swaps.flatMap(s => [s.requester_assignment_id, s.target_assignment_id]);
      const [memRes, asnRes] = await Promise.all([
        db.from('members').select('id, name').in('id', reqIds),
        db.from('wednesday_preaching').select('id, preach_date').in('id', assignIds)
      ]);
      const memMap = new Map((memRes.data || []).map(m => [m.id, m]));
      const asnMap = new Map((asnRes.data || []).map(a => [a.id, a]));
      for (const s of swaps) {
        const requester = memMap.get(s.requester_member_id) || { name:'Someone' };
        const reqA = asnMap.get(s.requester_assignment_id);
        const tgtA = asnMap.get(s.target_assignment_id);
        if (!reqA || !tgtA) continue;
        const reqDate = new Date(reqA.preach_date + 'T00:00:00').toLocaleDateString('en-US', { weekday:'short', month:'short', day:'numeric' });
        const tgtDate = new Date(tgtA.preach_date + 'T00:00:00').toLocaleDateString('en-US', { weekday:'short', month:'short', day:'numeric' });
        parts.push(_preaching_swapTargetBannerHTML(s, requester.name, reqDate, tgtDate, bilingual));
      }
    }

    // ── Upcoming assignment reminder ──
    if (assignment) {
      const stage = _preaching_computeReminderStage(assignment.preach_date);
      if (stage && !_preaching_isDismissed(memberId, assignment.preach_date, stage)) {
        parts.push(_preaching_assignmentBannerHTML(assignment, stage, bilingual));
      }
    }

    container.innerHTML = parts.join('');

    // Wire up the dismiss + swap-request buttons
    container.querySelectorAll('[data-preaching-action]').forEach(btn => {
      btn.addEventListener('click', async (e) => {
        e.stopPropagation();
        const action = btn.dataset.preachingAction;
        const assignmentId = btn.dataset.assignmentId;
        const preachDate = btn.dataset.preachDate;
        const stage = btn.dataset.stage;
        const swapId = btn.dataset.swapId;
        if (action === 'dismiss') {
          _preaching_dismiss(memberId, preachDate, stage);
          // Re-render
          _preaching_renderReminderBanner(containerId, memberId, opts);
        } else if (action === 'request-swap') {
          if (typeof opts.onRequestSwap === 'function') {
            opts.onRequestSwap(assignmentId, preachDate);
          } else {
            alert('Swap request: contact Pastor or open preaching_admin.html to manage swaps.');
          }
        } else if (action === 'view-calendar') {
          window.open('preaching_calendar.html', '_blank');
        } else if (action === 'respond-swap') {
          if (typeof opts.onRespondSwap === 'function') {
            opts.onRespondSwap(swapId);
          } else {
            // Default: prompt accept/decline and call DB directly
            await _preaching_handleSwapResponse(swapId, memberId, containerId, opts);
          }
        }
      });
    });
  }

  function _preaching_assignmentBannerHTML(assignment, stage, bilingual) {
    const date = new Date(assignment.preach_date + 'T00:00:00');
    const dateLabel = date.toLocaleDateString('en-US', { weekday:'long', month:'long', day:'numeric' });
    // Service type drives messaging — Sunday vs Wednesday phrasing differs.
    // Defaults to 'wednesday' for legacy rows that pre-date the column.
    const svc = (assignment.service_type || 'wednesday');
    const isSunday = svc === 'sunday';
    const dayWord = isSunday ? 'Sunday' : 'Wednesday';
    const dayWordTL = isSunday ? 'Linggo' : 'Miyerkules';
    // Service-specific time-of-service phrasing
    const tonightOrMorning = isSunday ? 'morning' : 'tonight';
    const tonightOrMorningTL = isSunday ? 'umaga' : 'gabi';

    // Mid-tone saturated backgrounds — must read well against BOTH dark MLT
    // (#0f0f13) AND cream MMT (#f5f0e6) since this function is shared. Earlier
    // attempts at near-pastel were too close to MMT's cream. These colors
    // strike a balance: clearly visible on dark, clearly visible on cream.
    const colors = {
      '7d': { bg:'linear-gradient(135deg,#f5d78e,#e8b84b)', border:'#8a6116', icon:'📅', textColor:'#1a1612' },
      '3d': { bg:'linear-gradient(135deg,#fdba74,#fb923c)', border:'#a14a0a', icon:'⚠️', textColor:'#1a1612' },
      '0d': { bg:'linear-gradient(135deg,#fca5a5,#f87171)', border:'#7f1d1d', icon:'🎤', textColor:'#1a1612' }
    };
    const c = colors[stage];

    const msgs = {
      '7d': bilingual ? {
        en: 'You\'re preaching this coming ' + dayWord + ', ' + dateLabel + '. Time to start preparing!',
        tl: 'Ikaw ang mangangaral sa darating na ' + dayWordTL + ', ' + dateLabel + '. Tara, magsimula nang magprepare!'
      } : { en: 'You\'re preaching this coming ' + dayWord + ', ' + dateLabel + '. Time to start preparing!', tl: null },
      '3d': bilingual ? {
        en: '3 days until you preach (' + dateLabel + '). What message is God placing on your heart?',
        tl: '3 araw na lang bago ka mangaral (' + dateLabel + '). Anong mensahe ang inilalagay ng Diyos sa puso mo?'
      } : { en: '3 days until you preach (' + dateLabel + '). What message is God placing on your heart?', tl: null },
      '0d': bilingual ? {
        en: 'You preach this ' + tonightOrMorning + '. Praying for you, kapatid.',
        tl: 'Ikaw ang mangangaral ngayong ' + tonightOrMorningTL + '. Ipinagdarasal ka namin, kapatid.'
      } : { en: 'You preach this ' + tonightOrMorning + '. Praying for you, kapatid.', tl: null }
    };
    const m = msgs[stage];
    const titles = {
      '7d': 'Upcoming · This ' + dayWord,
      '3d': 'Reminder · 3 Days',
      '0d': isSunday ? 'This Morning' : 'Tonight'
    };

    return (
      '<div style="background:' + c.bg + ';border:1.5px solid ' + c.border + ';border-radius:10px;padding:11px 14px;margin-bottom:.75rem;display:flex;align-items:flex-start;gap:10px;box-shadow:0 1px 3px rgba(0,0,0,.12)">' +
        '<div style="width:36px;height:36px;border-radius:50%;background:rgba(0,0,0,.78);display:flex;align-items:center;justify-content:center;font-size:18px;flex-shrink:0;line-height:1;box-shadow:0 1px 2px rgba(0,0,0,.18)">' + c.icon + '</div>' +
        '<div style="flex:1;min-width:0;line-height:1.4">' +
          '<div style="font-weight:700;font-size:13.5px;margin-bottom:2px;color:#1a1612">' + escapeHTML(titles[stage]) + '</div>' +
          '<div style="font-size:12.5px;color:#1a1612">' +
            (bilingual && m.tl
              ? '<span class="en-text">' + escapeHTML(m.en) + '</span><span class="tl-text">' + escapeHTML(m.tl) + '</span>'
              : escapeHTML(m.en)) +
          '</div>' +
          '<div style="display:flex;gap:6px;margin-top:7px;flex-wrap:wrap">' +
            '<button type="button" data-preaching-action="request-swap" data-assignment-id="' + assignment.id + '" data-preach-date="' + assignment.preach_date + '" style="background:rgba(255,255,255,.92);border:1px solid rgba(0,0,0,.25);font-family:inherit;font-size:11.5px;padding:5px 11px;border-radius:6px;cursor:pointer;font-weight:600;color:#1a1612">🔄 Request Swap</button>' +
            '<button type="button" data-preaching-action="view-calendar" style="background:rgba(255,255,255,.65);border:1px solid rgba(0,0,0,.25);font-family:inherit;font-size:11.5px;padding:5px 11px;border-radius:6px;cursor:pointer;color:#1a1612;font-weight:500">📅 View Calendar</button>' +
          '</div>' +
        '</div>' +
        '<button type="button" data-preaching-action="dismiss" data-preach-date="' + assignment.preach_date + '" data-stage="' + stage + '" title="Dismiss" style="background:transparent;border:none;font-size:16px;cursor:pointer;color:rgba(0,0,0,.65);padding:0 4px;line-height:1;flex-shrink:0">✕</button>' +
      '</div>'
    );
  }

  function _preaching_swapTargetBannerHTML(swap, requesterName, requesterDate, targetDate, bilingual) {
    const msg = bilingual
      ? '<span class="en-text">' + escapeHTML(requesterName) + ' is asking to swap their <strong>' + escapeHTML(requesterDate) + '</strong> preaching with your <strong>' + escapeHTML(targetDate) + '</strong>.</span>' +
        '<span class="tl-text">' + escapeHTML(requesterName) + ' ay humihiling makipag-swap ng kanyang <strong>' + escapeHTML(requesterDate) + '</strong> sa iyong <strong>' + escapeHTML(targetDate) + '</strong>.</span>'
      : escapeHTML(requesterName) + ' is asking to swap their <strong>' + escapeHTML(requesterDate) + '</strong> preaching with your <strong>' + escapeHTML(targetDate) + '</strong>.';
    const reason = swap.reason ? '<div style="font-style:italic;font-size:11.5px;color:#5a4e3f;margin-top:4px">"' + escapeHTML(swap.reason) + '"</div>' : '';

    return (
      '<div style="background:linear-gradient(135deg,#f5d78e,#e8b84b);border:1.5px solid #8a6116;border-radius:10px;padding:11px 14px;margin-bottom:.75rem;display:flex;align-items:flex-start;gap:10px;box-shadow:0 1px 3px rgba(0,0,0,.12)">' +
        '<div style="width:36px;height:36px;border-radius:50%;background:rgba(0,0,0,.78);display:flex;align-items:center;justify-content:center;font-size:18px;flex-shrink:0;line-height:1;box-shadow:0 1px 2px rgba(0,0,0,.18)">🔄</div>' +
        '<div style="flex:1;min-width:0">' +
          '<div style="font-weight:700;font-size:13.5px;margin-bottom:3px;color:#1a1612">Swap Request</div>' +
          '<div style="font-size:12.5px;color:#1a1612;line-height:1.45">' + msg + '</div>' +
          reason +
          '<div style="display:flex;gap:6px;margin-top:8px">' +
            '<button type="button" data-preaching-action="respond-swap" data-swap-id="' + swap.id + '" data-decision="accept" style="background:#2a5c40;color:white;border:none;font-family:inherit;font-size:12px;padding:6px 14px;border-radius:6px;cursor:pointer;font-weight:600">✓ Accept</button>' +
            '<button type="button" data-preaching-action="respond-swap" data-swap-id="' + swap.id + '" data-decision="decline" style="background:white;color:#a8332a;border:1px solid #a8332a;font-family:inherit;font-size:12px;padding:6px 14px;border-radius:6px;cursor:pointer;font-weight:600">✕ Decline</button>' +
          '</div>' +
        '</div>' +
      '</div>'
    );
  }

  // Default swap-response handler — accept or decline, then re-render banner.
  // Pages can override via opts.onRespondSwap.
  async function _preaching_handleSwapResponse(swapId, memberId, containerId, opts) {
    const db = getDB();
    if (!db) return;
    // Find the button clicked to know decision
    const btn = document.querySelector('[data-preaching-action="respond-swap"][data-swap-id="' + swapId + '"]');
    const decision = btn ? btn.dataset.decision : null;
    if (!decision) return;
    if (!confirm(decision === 'accept' ? 'Accept this swap?' : 'Decline this swap?')) return;

    // Fetch the swap row
    const { data: sData, error: sErr } = await db.from('preaching_swap_requests').select('*').eq('id', swapId).single();
    if (sErr || !sData) { alert('Could not load swap request: ' + (sErr?.message || 'not found')); return; }
    if (sData.status !== 'pending') { alert('This swap is no longer pending.'); return; }

    if (decision === 'accept') {
      // Flip preacher_member_id on both assignments
      const { data: assignments, error: aErr } = await db.from('wednesday_preaching')
        .select('*').in('id', [sData.requester_assignment_id, sData.target_assignment_id]);
      if (aErr || !assignments || assignments.length !== 2) {
        alert('Could not load assignments.'); return;
      }
      const reqA = assignments.find(a => a.id === sData.requester_assignment_id);
      const tgtA = assignments.find(a => a.id === sData.target_assignment_id);
      await Promise.all([
        db.from('wednesday_preaching').update({ preacher_member_id: tgtA.preacher_member_id, updated_at: new Date().toISOString() }).eq('id', reqA.id),
        db.from('wednesday_preaching').update({ preacher_member_id: reqA.preacher_member_id, updated_at: new Date().toISOString() }).eq('id', tgtA.id),
        db.from('preaching_swap_requests').update({ status: 'accepted', responded_at: new Date().toISOString() }).eq('id', swapId)
      ]);
    } else {
      await db.from('preaching_swap_requests')
        .update({ status: 'declined', responded_at: new Date().toISOString() })
        .eq('id', swapId);
    }
    // Re-render banner so the swap card disappears
    _preaching_renderReminderBanner(containerId, memberId, opts);
  }


  // ═════════════════════════════════════════════════════════════
  // ASSESSMENT CAVEAT BANNERS (May 2026)
  // ─────────────────────────────────────────────────────────────
  // Bridges a measurement-quality gap: four diagnostic instruments
  // (Enneagram, DISC, Love Language, Conflict Style) were empirically
  // audited and found NOT to differentiate well — top-vs-second spreads
  // are within noise for the majority of members. The instruments are
  // being redesigned, but until then, results already on file should
  // carry a soft caveat so members and Pastor don't over-trust noise.
  //
  // Config (in system_settings.meta.instrument_redesign_dates):
  //   {
  //     "enneagram":      "2026-08-15",
  //     "disc":           "2026-09-01",
  //     "love_language":  "2026-09-15",
  //     "conflict_style": "2026-10-01"
  //   }
  //
  // Auto-clear semantic: any result with date_taken >= cutoff is
  // assumed to be from the redesigned instrument and gets no caveat.
  // Older results get the caveat. Pastor sets one date per instrument
  // when its redesign deploys; no schema migration, no per-result
  // flagging needed.
  //
  // Pastoral framing (Invariant #16): caveat is a conversation starter,
  // NOT a triage alert. Visual treatment is a soft pastel banner inline
  // with the assessment — never a popup, never a notification.
  // ═════════════════════════════════════════════════════════════

  // Returns true if a caveat banner should be displayed for this
  // assessment result. `profileType` is the canonical DB profile_type
  // ('enneagram', 'disc', 'love_language', 'conflict_style', etc.).
  // `dateTaken` is a YYYY-MM-DD string or null. `settings` is the full
  // system_settings row (we read .meta.instrument_redesign_dates).
  //
  // Returns false if:
  //   • Pastor has not set a redesign date for this instrument
  //   • dateTaken is missing (we can't confidently say it's old)
  //   • dateTaken >= cutoff (already from the redesigned instrument)
  function shouldShowAssessmentCaveat(profileType, dateTaken, settings) {
    if (!profileType || !settings) return false;
    const meta = settings.meta || {};
    const dates = meta.instrument_redesign_dates || {};
    const cutoff = dates[profileType];
    if (!cutoff) return false;
    if (!dateTaken) return false;
    // String compare on YYYY-MM-DD is lexicographically correct
    return dateTaken < cutoff;
  }

  // Returns the canonical pretty label for an instrument. Used by
  // banner copy so the surrounding sentence reads naturally.
  function assessmentLabelFor(profileType) {
    const LABELS = {
      love_language:  'Love Language',
      disc:           'DISC',
      enneagram:      'Enneagram',
      conflict_style: 'Conflict Style',
      strengths:      'Strengths',
      gifts:          'Spiritual Gifts'
    };
    return LABELS[profileType] || profileType;
  }

  // Renders the HTML for a caveat banner. `audience` is either
  // 'pastor' (amber, more direct) or 'member' (slate-blue, gentler).
  // Returns empty string if shouldShowAssessmentCaveat returns false,
  // so callers can drop it inline without an if-guard.
  //
  //   const banner = renderAssessmentCaveatBanner('enneagram',
  //     row.date_taken, sysSettings, 'pastor');
  //   html += banner;  // empty string if no caveat needed
  function renderAssessmentCaveatBanner(profileType, dateTaken, settings, audience) {
    if (!shouldShowAssessmentCaveat(profileType, dateTaken, settings)) return '';
    const label = assessmentLabelFor(profileType);
    const isPastor = audience === 'pastor';

    const bg     = isPastor ? '#fdf6e8' : '#eef2f7';
    const border = isPastor ? '#b8882a' : '#5b6f8a';
    const ink    = isPastor ? '#5c3f0a' : '#2c3a4f';
    const icon   = isPastor ? '⚠️'      : '💬';

    const msg = isPastor
      ? 'This ' + escapeHTML(label) + ' result was produced by an earlier version of the assessment which our analysis showed has weak differentiation. Treat as conversation-starter for discipleship, not as a verdict. The instrument is being redesigned; re-administering will refresh this result.'
      : 'Your ' + escapeHTML(label) + ' result is best understood through reflection and conversation with a discipler — not as a final label. We are refining this assessment, and you\'ll be invited to retake it when the improved version is ready.';

    return (
      '<div style="background:' + bg + ';border-left:3px solid ' + border + ';border-radius:8px;' +
        'padding:.65rem .85rem;margin:.5rem 0;display:flex;gap:10px;align-items:flex-start;font-size:11.5px;line-height:1.55;color:' + ink + '">' +
        '<div style="font-size:14px;flex-shrink:0;line-height:1.2">' + icon + '</div>' +
        '<div style="flex:1">' + msg + '</div>' +
      '</div>'
    );
  }


  // ───── Public surface ─────
  global.MultiplyShared = {
    SB_URL, SB_KEY, SESSION_KEY, MEMBER_SESSION_KEY, LEVEL_NAMES, PASTOR_LEVEL,
    getDB,
    // Leader-session API (for MD, MLT, lc_attendance_report, etc.)
    getValidSession,
    gateOrRedirect,
    logoutLeader,
    // Member-session API (for MMT — member_tool.html)
    getValidMemberSession,
    gateMemberOrRedirect,
    logoutMember,
    // Scoping + audit
    makeLeaderScope,
    logView,
    tierLockCard,
    escapeHTML,
    // Assessment caveat banners (May 2026 — instrument redesign bridge)
    shouldShowAssessmentCaveat,
    renderAssessmentCaveatBanner,
    assessmentLabelFor,
    // Lesson access predicate (Phase 3)
    lessons: {
      fetchVisibleLessons
    },
    // Wednesday Preaching (May 2026)
    preaching: {
      getUpcomingForMember: _preaching_getUpcomingForMember,
      getPendingSwapsForMember: _preaching_getPendingSwapsForMember,
      computeReminderStage: _preaching_computeReminderStage,
      isDismissed: _preaching_isDismissed,
      dismiss: _preaching_dismiss,
      renderReminderBanner: _preaching_renderReminderBanner
    }
  };
})(typeof window !== 'undefined' ? window : globalThis);
