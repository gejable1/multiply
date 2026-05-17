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
//   • Lessons / BTLI eligibility / Cohorts / Preaching helpers
//   • Transfers (LCG transfer propose/approve flow, May 2026)
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
  //              | 'participant' | 'observer' | 'leader' | 'member'
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
  //
  // Canonical batch roles (cohort_members.role) — five values:
  //   'teacher'     — rank 2 (sees teacher+ attachments)
  //   'co-teacher'  — rank 2
  //   'apprentice'  — rank 1 (apprentice+), promoted to rank 2 if cohort has
  //                   a lesson-unlock row for this lesson
  //   'participant' — rank 0 (the disciple being trained; sees only 'all'
  //                   attachments — no facilitator material). Default role
  //                   on new enrollments. Added May 17, 2026.
  //   'observer'    — rank 0 (watching to learn the format)
  function _userRoleRankForLesson(opts) {
    if (opts.isPastor) return 3;
    if (opts.batchRole === 'teacher')    return 2;
    if (opts.batchRole === 'co-teacher') return 2;
    if (opts.batchRole === 'apprentice') {
      // Apprentice with cohort unlock for this lesson → promoted to teacher rank
      return opts.cohortUnlockedForThisLesson ? 2 : 1;
    }
    if (opts.batchRole === 'participant') return 0;
    if (opts.batchRole === 'observer')    return 0;
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
        // Role priority: teacher > co-teacher > apprentice > participant > observer
        // (participant added May 17, 2026 — the disciple being trained; ranks
        // above observer because they're the higher-investment learner)
        const rolePriority = { teacher: 5, 'co-teacher': 4, apprentice: 3, participant: 2, observer: 1 };
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
        batchRole: ['teacher','co-teacher','apprentice','participant','observer'].includes(bestRole) ? bestRole : null,
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


  // ═══════════════════════════════════════════════════════════════════
  // BTLI ELIGIBILITY (Priority C · May 16, 2026)
  // ─────────────────────────────────────────────────────────────────
  // Decides whether a given member can take a given BTLI quiz, and how
  // they got there. Single source of truth used by both:
  //   • member_tool.html → renderBtliQuizzes (cards on Journey page)
  //   • btli_quiz_player.html → loadQuiz (gate before showing intro)
  //
  // The gate is HYBRID per Pastor Gerry's May 16 decision:
  //
  //   eligible = enrolled OR attendance_pattern_matches
  //   drop_in  = eligible AND NOT enrolled
  //
  // "Enrolled" means the member has an active cohort_members row in an
  // active cohort whose program.btli_course_code matches the quiz's
  // course_code. (Schema added by btli_cohort_link_migration.sql.)
  //
  // "Attendance pattern matches" preserves the v1 behavior so nobody who
  // currently uses BTLI quizzes breaks the day this ships. Drop-in mode
  // is the UI signal that drives the back-fill conversation.
  //
  // Returns ONE object per (member, quiz) pair:
  //   {
  //     eligible: bool,
  //     reason: 'pastor' | 'enrolled' | 'attendance' | 'no_gate' | 'blocked',
  //     enrolled: bool,
  //     dropIn: bool,           // eligible by attendance only
  //     cohortIds: string[],    // active cohorts that enrolled them
  //     programNames: string[]  // human-readable for UI hints
  //   }
  //
  // Designed for two call patterns:
  //   (A) Single-quiz check (player) — use btliEligibilityFor(...)
  //   (B) Many quizzes for one member (MMT card list) — use
  //       btliEligibilityForMany(...) to amortize 4 queries into 1 batch.
  // ═══════════════════════════════════════════════════════════════════

  // Internal: fetch a member's active BTLI program enrollments.
  // Returns array of { program_id, program_name, btli_course_code, cohort_id, cohort_name, role }
  //
  // IMPORTANT: does NOT use PostgREST !inner(...) embedding — embed
  // resolution failed with HTTP 400 in some Supabase configurations
  // (May 17, 2026). Three small queries + client-side stitching is
  // both faster and more robust.
  async function _btliFetchEnrollments(memberId) {
    if (!memberId) return [];
    const db = getDB();
    if (!db) return [];

    // 1) Member's active cohort_members rows
    const cmRes = await db
      .from('cohort_members')
      .select('cohort_id, role, status')
      .eq('member_id', memberId)
      .eq('status', 'active');
    if (cmRes.error) {
      console.warn('_btliFetchEnrollments: cohort_members fetch failed (failing open):', cmRes.error);
      return [];
    }
    const enrolls = cmRes.data || [];
    if (enrolls.length === 0) return [];

    // 2) Their active cohorts
    const cohortIds = Array.from(new Set(enrolls.map(e => e.cohort_id).filter(Boolean)));
    const cohRes = await db
      .from('cohorts')
      .select('id, name, status, program_id')
      .in('id', cohortIds)
      .eq('status', 'active');
    if (cohRes.error) {
      console.warn('_btliFetchEnrollments: cohorts fetch failed (failing open):', cohRes.error);
      return [];
    }
    const cohortById = {};
    (cohRes.data || []).forEach(c => { cohortById[c.id] = c; });

    // 3) Their active BTLI programs (must have btli_course_code set)
    const programIds = Array.from(new Set(Object.values(cohortById).map(c => c.program_id).filter(Boolean)));
    if (programIds.length === 0) return [];
    const pRes = await db
      .from('cohort_programs')
      .select('id, name, btli_course_code, is_active')
      .in('id', programIds)
      .eq('is_active', true)
      .not('btli_course_code', 'is', null);
    if (pRes.error) {
      console.warn('_btliFetchEnrollments: programs fetch failed (failing open):', pRes.error);
      return [];
    }
    const programById = {};
    (pRes.data || []).forEach(p => { programById[p.id] = p; });

    // 4) Stitch: only keep enrollments whose cohort is active AND program is active BTLI
    return enrolls.flatMap(e => {
      const c = cohortById[e.cohort_id];
      if (!c) return [];
      const p = programById[c.program_id];
      if (!p || !p.btli_course_code) return [];
      return [{
        cohort_id: c.id,
        cohort_name: c.name || '',
        role: e.role,
        program_id: p.id,
        program_name: p.name || '',
        btli_course_code: p.btli_course_code
      }];
    });
  }

  // Internal: fetch all present=true attendance event_names for a member.
  // Lowercased Set for substring matching against quiz patterns.
  async function _btliFetchAttendedNames(memberId) {
    if (!memberId) return new Set();
    const db = getDB();
    if (!db) return new Set();
    const { data, error } = await db
      .from('attendance')
      .select('event_name')
      .eq('member_id', memberId)
      .eq('present', true);
    if (error) {
      console.warn('_btliFetchAttendedNames failed (failing open):', error);
      return new Set();  // empty set = no attendance match; enrollment still works
    }
    return new Set((data || []).map(r => (r.event_name || '').toLowerCase()).filter(Boolean));
  }

  // Public: eligibility for a single quiz.
  // `quiz` must include: course_code, attendance_event_name_pattern.
  // `opts` may include: isPastor (skips all checks).
  async function btliEligibilityFor(memberId, quiz, opts) {
    opts = opts || {};
    const isPastor = !!opts.isPastor;
    if (isPastor) {
      return { eligible: true, reason: 'pastor', enrolled: false, dropIn: false, cohortIds: [], programNames: [] };
    }
    if (!memberId || !quiz || !quiz.course_code) {
      return { eligible: false, reason: 'blocked', enrolled: false, dropIn: false, cohortIds: [], programNames: [] };
    }
    const [enrollments, attendedNames] = await Promise.all([
      _btliFetchEnrollments(memberId),
      _btliFetchAttendedNames(memberId)
    ]);
    return _btliComputeOne(quiz, enrollments, attendedNames);
  }

  // Public: eligibility for many quizzes at once (single batch fetch).
  // Returns Map<quizId, eligibilityObject>. Quizzes must have an `id` plus the
  // same fields as the single-quiz variant.
  async function btliEligibilityForMany(memberId, quizzes, opts) {
    opts = opts || {};
    const isPastor = !!opts.isPastor;
    const out = new Map();
    if (!Array.isArray(quizzes) || quizzes.length === 0) return out;
    if (isPastor) {
      quizzes.forEach(q => out.set(q.id, {
        eligible: true, reason: 'pastor', enrolled: false, dropIn: false, cohortIds: [], programNames: []
      }));
      return out;
    }
    if (!memberId) {
      quizzes.forEach(q => out.set(q.id, {
        eligible: false, reason: 'blocked', enrolled: false, dropIn: false, cohortIds: [], programNames: []
      }));
      return out;
    }
    const [enrollments, attendedNames] = await Promise.all([
      _btliFetchEnrollments(memberId),
      _btliFetchAttendedNames(memberId)
    ]);
    quizzes.forEach(q => {
      out.set(q.id, _btliComputeOne(q, enrollments, attendedNames));
    });
    return out;
  }

  // Pure: given pre-fetched enrollments + attendance, decide for one quiz.
  function _btliComputeOne(quiz, enrollments, attendedNames) {
    const courseCode = quiz.course_code || '';
    // Enrollment match: any enrollment whose program teaches this course_code
    const matchingEnrollments = enrollments.filter(e => e.btli_course_code === courseCode);
    const enrolled = matchingEnrollments.length > 0;

    // Attendance match
    const pattern = (quiz.attendance_event_name_pattern || '').toLowerCase();
    let attendanceMatch = false;
    if (pattern) {
      for (const n of attendedNames) {
        if (n.includes(pattern)) { attendanceMatch = true; break; }
      }
    }
    const noGate = !pattern && !enrolled;  // quiz has no gate AND member is not enrolled

    if (enrolled) {
      return {
        eligible: true,
        reason: 'enrolled',
        enrolled: true,
        dropIn: false,
        cohortIds: matchingEnrollments.map(e => e.cohort_id),
        programNames: Array.from(new Set(matchingEnrollments.map(e => e.program_name).filter(Boolean)))
      };
    }
    if (attendanceMatch) {
      return {
        eligible: true,
        reason: 'attendance',
        enrolled: false,
        dropIn: true,
        cohortIds: [],
        programNames: []
      };
    }
    if (!pattern) {
      // Quiz has no attendance gate at all — historically "always unlocked".
      // We honor that to preserve the v1 escape hatch, but flag as drop-in
      // so Pastor still sees who's taking ungated quizzes without enrollment.
      return {
        eligible: true,
        reason: 'no_gate',
        enrolled: false,
        dropIn: true,
        cohortIds: [],
        programNames: []
      };
    }
    return {
      eligible: false,
      reason: 'blocked',
      enrolled: false,
      dropIn: false,
      cohortIds: [],
      programNames: []
    };
  }

  // ═══════════════════════════════════════════════════════════════════
  // COHORT PERMISSIONS + MLT HELPERS (Priority C2 · May 16, 2026)
  // ─────────────────────────────────────────────────────────────────
  // Ownership-based authorization for MLT enrollment self-service.
  //
  // Ownership rules (Pastor Gerry, May 16, 2026):
  //   • Pastor-owned cohort  → any LCL can enroll their LeaderScope-
  //                            visible members of matching pipeline_level.
  //   • LCL-owned cohort     → only the owner LCL can enroll, and only
  //                            their own scoped members of matching level.
  //
  // Level match (hard rule, no override):
  //   member.pipeline_level === program.pipeline_level
  //   Exception: program.pipeline_level IS NULL → any level OK.
  //
  // Status transitions in MLT:
  //   • Withdraw: LCL may withdraw enrollees from cohorts they have
  //     edit rights on.
  //   • Graduate: Pastor-owned programs → Pastor only.
  //                LCL-owned cohorts → owner LCL may graduate.
  //
  // These rules are enforced HERE in shared code so MLT and any future
  // surface (e.g. a Pastor dashboard for the same flow) agree.
  // ═══════════════════════════════════════════════════════════════════

  // canEnroll(actor, cohort, program, candidate) — can `actor` enroll
  // `candidate` into `cohort` (which belongs to `program`)?
  //
  // actor:     { memberId: uuid, isPastor: bool }   (from session payload)
  // cohort:    { owner_id, status, ... }            (cohorts row)
  // program:   { pipeline_level, is_active, ... }   (cohort_programs row)
  // candidate: { id, pipeline_level }               (members row)
  //
  // Returns { ok: bool, reason: string }
  function _cohortsCanEnroll(actor, cohort, program, candidate) {
    if (!actor || !cohort || !program || !candidate) {
      return { ok: false, reason: 'Missing inputs' };
    }
    if (program.is_active === false) {
      return { ok: false, reason: 'Program is inactive' };
    }
    if (cohort.status !== 'active' && cohort.status !== 'forming') {
      return { ok: false, reason: 'Cohort is ' + cohort.status };
    }
    // Hard level match (program-level === member-level), nullable program-level escapes
    if (program.pipeline_level != null) {
      const memLvl = candidate.pipeline_level;
      if (memLvl == null) {
        return { ok: false, reason: 'Member has no pipeline level yet' };
      }
      if (parseInt(memLvl, 10) !== parseInt(program.pipeline_level, 10)) {
        return { ok: false, reason: 'Level mismatch (member L' + memLvl + ' vs program L' + program.pipeline_level + ')' };
      }
    }
    // Ownership check
    if (actor.isPastor) return { ok: true, reason: 'pastor' };
    const isOwner = cohort.owner_id && actor.memberId && cohort.owner_id === actor.memberId;
    if (isOwner) return { ok: true, reason: 'owner' };
    // Non-owner LCLs can enroll only into Pastor-owned cohorts. We can't
    // know "is the owner the Pastor?" from just IDs without a roundtrip,
    // so the caller passes `cohort._ownerIsPastor` when known. If absent
    // we default to denying (safe).
    if (cohort._ownerIsPastor === true) return { ok: true, reason: 'pastor_owned' };
    return { ok: false, reason: 'Not your cohort' };
  }

  // canEditCohort(actor, cohort) — can `actor` edit this cohort's
  // metadata (name, dates, status — but not enroll/withdraw, which uses
  // canEnroll)? Mirrors ownership.
  function _cohortsCanEdit(actor, cohort) {
    if (!actor || !cohort) return { ok: false, reason: 'Missing inputs' };
    if (actor.isPastor) return { ok: true, reason: 'pastor' };
    if (cohort.owner_id && cohort.owner_id === actor.memberId) {
      return { ok: true, reason: 'owner' };
    }
    return { ok: false, reason: 'Not your cohort' };
  }

  // canGraduate(actor, cohort) — graduation is a celebratory act with
  // pastoral weight. Pastor-owned cohorts: Pastor only. LCL-owned
  // cohorts: owner LCL may graduate (it's their training group).
  function _cohortsCanGraduate(actor, cohort) {
    if (!actor || !cohort) return { ok: false, reason: 'Missing inputs' };
    if (actor.isPastor) return { ok: true, reason: 'pastor' };
    // Owner of own cohort can graduate; cannot graduate Pastor-owned ones.
    if (cohort._ownerIsPastor === true) {
      return { ok: false, reason: 'Pastor-owned program — Pastor graduates' };
    }
    if (cohort.owner_id && cohort.owner_id === actor.memberId) {
      return { ok: true, reason: 'owner' };
    }
    return { ok: false, reason: 'Not your cohort' };
  }

  // Fetch all cohorts visible to an LCL in MLT:
  //   • Cohorts the LCL owns (any status except archived)
  //   • Active/forming Pastor-owned cohorts (so LCL can enroll their members)
  //
  // Returns each row with:
  //   • cohort fields
  //   • _ownerIsPastor: bool (resolved by checking owner.pipeline_level)
  //   • cohort_programs: embedded program row
  //   • _members: array of cohort_members rows (each with `members` resolved)
  //
  // Caller-supplied: actor = { memberId, isPastor }.
  //
  // IMPORTANT: this function does NOT use PostgREST `!inner(...)` embed
  // syntax. We tried that originally and hit HTTP 400 from PostgREST
  // (embed resolution failed silently, leaving roster screens empty).
  // Instead we fetch each table separately and stitch client-side. Three
  // queries total — small data, fast, robust. (May 17, 2026 fix.)
  async function _cohortsListVisibleToLeader(actor) {
    if (!actor || !actor.memberId) return [];
    const db = getDB();
    if (!db) return [];

    // ─── Step 1: Fetch cohorts (no embed) ───
    const cohRes = await db
      .from('cohorts')
      .select('id, name, start_date, end_date, status, notes, program_id, owner_id, created_at')
      .in('status', ['active', 'forming']);
    if (cohRes.error) {
      console.error('_cohortsListVisibleToLeader: cohorts query failed', cohRes.error);
      throw new Error('Could not load batches: ' + (cohRes.error.message || cohRes.error));
    }
    let cohorts = cohRes.data || [];
    if (cohorts.length === 0) return [];

    // ─── Step 2: Fetch programs for these cohorts (separate query) ───
    const programIds = Array.from(new Set(cohorts.map(c => c.program_id).filter(Boolean)));
    const programById = {};
    if (programIds.length > 0) {
      const pRes = await db
        .from('cohort_programs')
        .select('id, name, category, pipeline_level, btli_course_code, is_active')
        .in('id', programIds);
      if (pRes.error) {
        console.error('_cohortsListVisibleToLeader: programs query failed', pRes.error);
        throw new Error('Could not load programs: ' + (pRes.error.message || pRes.error));
      }
      (pRes.data || []).forEach(p => { programById[p.id] = p; });
    }
    cohorts.forEach(c => { c.cohort_programs = programById[c.program_id] || null; });

    // ─── Step 3: Resolve Pastor-owned flag ───
    const ownerIds = Array.from(new Set(cohorts.map(c => c.owner_id).filter(Boolean)));
    let pastorOwnerSet = new Set();
    if (ownerIds.length > 0) {
      const oRes = await db
        .from('members')
        .select('id, pipeline_level')
        .in('id', ownerIds);
      if (!oRes.error) {
        (oRes.data || []).forEach(m => {
          if ((m.pipeline_level || 0) >= PASTOR_LEVEL) pastorOwnerSet.add(m.id);
        });
      } else {
        console.warn('_cohortsListVisibleToLeader: pastor-owner lookup failed (treating as non-pastor)', oRes.error);
      }
    }
    cohorts.forEach(c => { c._ownerIsPastor = pastorOwnerSet.has(c.owner_id); });

    // ─── Step 4: Trim by visibility rule ───
    if (!actor.isPastor) {
      cohorts = cohorts.filter(c =>
        c._ownerIsPastor === true || c.owner_id === actor.memberId
      );
    }
    if (cohorts.length === 0) {
      // Nothing visible to this LCL — still return empty array (not an error).
      return [];
    }

    // ─── Step 5: Fetch cohort_members for visible cohorts (no embed) ───
    const cohortIds = cohorts.map(c => c.id);
    const cmRes = await db
      .from('cohort_members')
      .select('id, cohort_id, member_id, role, status, joined_at, exited_at')
      .in('cohort_id', cohortIds);
    if (cmRes.error) {
      console.error('_cohortsListVisibleToLeader: cohort_members query failed', cmRes.error);
      throw new Error('Could not load rosters: ' + (cmRes.error.message || cmRes.error));
    }
    const enrollments = cmRes.data || [];

    // ─── Step 6: Resolve member details (separate query) ───
    const memberIds = Array.from(new Set(enrollments.map(cm => cm.member_id).filter(Boolean)));
    const memberById = {};
    if (memberIds.length > 0) {
      const mRes = await db
        .from('members')
        .select('id, name, pipeline_level, lc_group, is_test_member, is_external_user')
        .in('id', memberIds);
      if (mRes.error) {
        console.warn('_cohortsListVisibleToLeader: member detail lookup failed (rendering with IDs only)', mRes.error);
        // Don't throw — render the enrollments anyway, with placeholder names.
      } else {
        (mRes.data || []).forEach(m => { memberById[m.id] = m; });
      }
    }
    enrollments.forEach(cm => {
      cm.members = memberById[cm.member_id] || {
        id: cm.member_id, name: '(unknown member)', pipeline_level: null, lc_group: null
      };
    });

    // ─── Step 7: Bucket enrollments under their cohorts ───
    const byCohort = {};
    enrollments.forEach(cm => {
      if (!byCohort[cm.cohort_id]) byCohort[cm.cohort_id] = [];
      byCohort[cm.cohort_id].push(cm);
    });
    cohorts.forEach(c => { c._members = byCohort[c.id] || []; });

    return cohorts;
  }

  // For the "Add member" picker inside a cohort:
  // returns the LCL's scoped members who are eligible to be enrolled
  // (correct pipeline level, not already in another active cohort of
  // the same program).
  //
  // actor:      { memberId, isPastor }
  // cohort:     full cohort row (with _ownerIsPastor and cohort_programs)
  // scoped:     array of member rows the LCL has LeaderScope on
  //             (from LeaderScope.getTree() in MLT)
  // sameProgramEnrolledIds: Set<uuid> of member_ids already enrolled
  //             in ANY active cohort of the same program (caller computes
  //             from listVisibleToLeader's output)
  function _cohortsEligibleCandidates(actor, cohort, program, scoped, sameProgramEnrolledIds) {
    if (!Array.isArray(scoped)) return [];
    const targetLevel = (program && program.pipeline_level != null)
      ? parseInt(program.pipeline_level, 10)
      : null;
    return scoped.filter(m => {
      if (!m || !m.id) return false;
      // Already enrolled in same program? Skip.
      if (sameProgramEnrolledIds.has(m.id)) return false;
      // Level match
      if (targetLevel != null) {
        if (m.pipeline_level == null) return false;
        if (parseInt(m.pipeline_level, 10) !== targetLevel) return false;
      }
      return true;
    });
  }

  // For C3b (BTLI attendance roster derivation, May 17, 2026):
  // returns all active cohorts whose program teaches the given BTLI
  // course_code, scoped to what `actor` can see (Pastor-owned or own).
  // Each cohort has its active members resolved with display data.
  //
  // Caller is MLT attendance flow — once the LCL picks a BTLI lesson,
  // we derive course_code from it and call this to populate the batch
  // picker. The picker shows the resulting cohorts; on selection, the
  // chosen cohort's active members become the attendance roster.
  //
  // Returns array of cohorts, each with _members (active only) and
  // _ownerIsPastor populated. Empty array if nothing matches.
  async function _cohortsListActiveByCourseCode(actor, courseCode) {
    if (!actor || !actor.memberId || !courseCode) return [];
    // We reuse listVisibleToLeader and filter to matching course_code.
    // It returns more than we need (all visible cohorts), but the table
    // is small and this avoids drift between the two helpers' logic.
    const all = await _cohortsListVisibleToLeader(actor);
    return (all || [])
      .filter(c => c.cohort_programs &&
                   c.cohort_programs.btli_course_code === courseCode &&
                   c.status === 'active')
      .map(c => {
        // Narrow _members to active enrollments only
        c._members = (c._members || []).filter(cm => cm.status === 'active');
        return c;
      });
  }

  // ═══════════════════════════════════════════════════════════════════════
  // TRANSFERS — LCG transfer flow with audit history (May 18, 2026)
  // ═══════════════════════════════════════════════════════════════════════
  //
  // Mental model:
  //   • Destination is identified by LCL (a member with pipeline_level >= 2),
  //     not by the sparse lc_group text field. Per Invariant #45.
  //   • Per Invariant #46 (Rosehill pastoral practice): discipler = LCL.
  //     A member's facilitator_id and discipler_id always point to the same
  //     person. On approve, BOTH pointers move atomically to the destination.
  //   • members.pending_facilitator_id is the in-flight uuid pointer to the
  //     destination LCL. We also keep members.pending_lc_group + transfer_date
  //     populated for backwards compatibility with the existing yellow card
  //     in MLT and Pastor's kanban.
  //   • transfers table is APPEND-ONLY history. Every action writes a row.
  //   • Approve: members.facilitator_id := pending_facilitator_id;
  //              members.discipler_id   := pending_facilitator_id;
  //              resolve names + lc_group from destination LCL. Clear pending_*.
  //   • Reject/cancel: clear pending_* without touching facilitator_id or
  //     discipler_id.
  //
  // Usage pattern:
  //   await MultiplyShared.transfers.propose({
  //     memberId, toFacilitatorId, effectiveDate, reason, proposedBy
  //   });
  //   await MultiplyShared.transfers.approve({memberId, decidedBy, decisionNote});
  //   await MultiplyShared.transfers.reject({memberId, decidedBy, decisionNote});
  //   await MultiplyShared.transfers.cancel({memberId, cancelledBy});
  //   await MultiplyShared.transfers.modify({memberId, toFacilitatorId, effectiveDate, modifiedBy});
  //   await MultiplyShared.transfers.listEligibleDestinationLCLs();
  //   await MultiplyShared.transfers.historyFor(memberId);
  //   await MultiplyShared.transfers.incomingFor(facilitatorId);
  //   await MultiplyShared.transfers.outgoingFor(facilitatorId);
  //   await MultiplyShared.transfers.openProposalsCount();
  //
  // All functions throw on error per Invariant #38 — never swallow.

  // Internal helper: fetch a member row (id, name, lc_group, facilitator_id)
  // Used to resolve names/groups at the moment of write.
  async function _xferGetMember(db, memberId) {
    const { data, error } = await db.from('members')
      .select('id,name,lc_group,facilitator_id,facilitator_name,pending_lc_group,pending_facilitator_id,pending_transfer_by,transfer_date,pipeline_level')
      .eq('id', memberId).maybeSingle();
    if (error) throw error;
    if (!data) throw new Error('Member not found: ' + memberId);
    return data;
  }

  // List of eligible destination LCLs (pipeline_level >= 2, excluding test).
  // Returns: [{id, name, pipeline_level, lc_group, level_name}, ...]
  async function _xferListEligibleDestinationLCLs() {
    const db = getDB();
    const { data, error } = await db.from('members')
      .select('id,name,pipeline_level,lc_group,is_test_member')
      .gte('pipeline_level', 2)
      .order('name');
    if (error) throw error;
    return (data || [])
      .filter(m => !m.is_test_member)
      .map(m => ({
        id: m.id,
        name: m.name,
        pipeline_level: m.pipeline_level,
        lc_group: m.lc_group || null,
        level_name: LEVEL_NAMES[m.pipeline_level] || 'Leader'
      }));
  }

  // Propose a transfer. Writes to members.pending_* AND inserts transfers row.
  // Args:
  //   memberId          — disciple being transferred
  //   toFacilitatorId   — destination LCL (member.id with pipeline_level >= 2)
  //   effectiveDate     — 'YYYY-MM-DD' string or null (defaults to today on UI)
  //   reason            — optional text
  //   proposedBy        — member.id of the proposer (LCL or Pastor)
  //
  // Throws if member already has a pending transfer (caller should cancel first).
  // Throws if destination LCL is not pipeline_level >= 2.
  async function _xferPropose(args) {
    const { memberId, toFacilitatorId, effectiveDate, reason, proposedBy } = args || {};
    if (!memberId) throw new Error('memberId required');
    if (!toFacilitatorId) throw new Error('toFacilitatorId required');
    if (!proposedBy) throw new Error('proposedBy required');

    const db = getDB();

    // Resolve current member + destination LCL state.
    const member = await _xferGetMember(db, memberId);
    if (member.pending_facilitator_id || member.pending_lc_group) {
      throw new Error('Member already has a pending transfer. Cancel it first.');
    }

    const { data: destRow, error: destErr } = await db.from('members')
      .select('id,name,lc_group,pipeline_level')
      .eq('id', toFacilitatorId).maybeSingle();
    if (destErr) throw destErr;
    if (!destRow) throw new Error('Destination LCL not found');
    if ((destRow.pipeline_level || 0) < 2) {
      throw new Error('Destination LCL must be pipeline_level >= 2');
    }

    // Resolve destination lc_group text (LCL's own lc_group, else their name)
    const toLcGroup = destRow.lc_group || destRow.name;

    // 1) Update members.pending_* in-flight state
    const updates = {
      pending_facilitator_id: toFacilitatorId,
      pending_lc_group: toLcGroup,
      pending_transfer_by: proposedBy,
      transfer_date: effectiveDate || null,
      updated_at: new Date().toISOString()
    };
    const { error: mErr } = await db.from('members').update(updates).eq('id', memberId);
    if (mErr) throw mErr;

    // 2) Insert transfers row (status=proposed)
    const { data: row, error: tErr } = await db.from('transfers').insert({
      member_id: memberId,
      from_facilitator_id: member.facilitator_id || null,
      to_facilitator_id: toFacilitatorId,
      from_lc_group: member.lc_group || null,
      to_lc_group: toLcGroup,
      effective_date: effectiveDate || null,
      reason: reason || null,
      status: 'proposed',
      proposed_by: proposedBy
    }).select().single();
    if (tErr) throw tErr;
    return row;
  }

  // Approve the current pending transfer for a member. Writes the transition
  // to members (facilitator_id, facilitator_name, lc_group) and stamps the
  // most recent 'proposed' transfers row as 'approved'.
  async function _xferApprove(args) {
    const { memberId, decidedBy, decisionNote } = args || {};
    if (!memberId) throw new Error('memberId required');
    if (!decidedBy) throw new Error('decidedBy required');

    const db = getDB();
    const member = await _xferGetMember(db, memberId);
    if (!member.pending_facilitator_id) {
      throw new Error('No pending transfer to approve');
    }

    // Resolve destination LCL display name
    const { data: destRow, error: destErr } = await db.from('members')
      .select('id,name,lc_group').eq('id', member.pending_facilitator_id).maybeSingle();
    if (destErr) throw destErr;
    if (!destRow) throw new Error('Destination LCL no longer exists');

    const nowIso = new Date().toISOString();
    const todayYmd = _xferYmd(new Date());

    // 1) Promote pending → live on members.
    //    Per Invariant #46 (Rosehill pastoral practice): discipler = LCL.
    //    The transfer moves BOTH pointers atomically. If a future practice
    //    ever decouples them, change here and document in the invariant.
    const memUpdates = {
      facilitator_id:   destRow.id,
      facilitator_name: destRow.name,
      discipler_id:     destRow.id,
      discipler_name:   destRow.name,
      discipler:        destRow.name,  // legacy text field — keep in sync
      lc_group:         destRow.lc_group || destRow.name,
      pending_facilitator_id: null,
      pending_lc_group:       null,
      pending_transfer_by:    null,
      pending_discipler:      null,
      transfer_date:    todayYmd,
      updated_at:       nowIso
    };
    const { error: mErr } = await db.from('members').update(memUpdates).eq('id', memberId);
    if (mErr) throw mErr;

    // 2) Stamp most-recent proposed row as approved
    const stamped = await _xferStampLatestProposed(db, memberId, {
      status: 'approved',
      decided_by: decidedBy,
      decided_at: nowIso,
      decision_note: decisionNote || null
    });
    return stamped;
  }

  // Reject the current pending transfer for a member. Clears pending_* without
  // touching facilitator_id. Stamps the proposed row as 'rejected'.
  async function _xferReject(args) {
    const { memberId, decidedBy, decisionNote } = args || {};
    if (!memberId) throw new Error('memberId required');
    if (!decidedBy) throw new Error('decidedBy required');

    const db = getDB();
    const member = await _xferGetMember(db, memberId);
    if (!member.pending_facilitator_id && !member.pending_lc_group) {
      throw new Error('No pending transfer to reject');
    }

    const nowIso = new Date().toISOString();

    const { error: mErr } = await db.from('members').update({
      pending_facilitator_id: null,
      pending_lc_group: null,
      pending_transfer_by: null,
      transfer_date: null,
      updated_at: nowIso
    }).eq('id', memberId);
    if (mErr) throw mErr;

    const stamped = await _xferStampLatestProposed(db, memberId, {
      status: 'rejected',
      decided_by: decidedBy,
      decided_at: nowIso,
      decision_note: decisionNote || null
    });
    return stamped;
  }

  // Cancel one's own proposed transfer (LCL who initiated, or Pastor).
  // Schema-wise identical to reject except status='cancelled' and decided_by
  // is the canceller.
  async function _xferCancel(args) {
    const { memberId, cancelledBy } = args || {};
    if (!memberId) throw new Error('memberId required');
    if (!cancelledBy) throw new Error('cancelledBy required');

    const db = getDB();
    const member = await _xferGetMember(db, memberId);
    if (!member.pending_facilitator_id && !member.pending_lc_group) {
      throw new Error('No pending transfer to cancel');
    }

    const nowIso = new Date().toISOString();

    const { error: mErr } = await db.from('members').update({
      pending_facilitator_id: null,
      pending_lc_group: null,
      pending_transfer_by: null,
      transfer_date: null,
      updated_at: nowIso
    }).eq('id', memberId);
    if (mErr) throw mErr;

    const stamped = await _xferStampLatestProposed(db, memberId, {
      status: 'cancelled',
      decided_by: cancelledBy,
      decided_at: nowIso,
      decision_note: null
    });
    return stamped;
  }

  // Modify an in-flight proposal: change destination LCL or effective date.
  // Stamps the existing proposed row as 'modified' (chained via parent_id)
  // and inserts a new 'proposed' row with the new values. Updates members.pending_*.
  async function _xferModify(args) {
    const { memberId, toFacilitatorId, effectiveDate, modifiedBy } = args || {};
    if (!memberId) throw new Error('memberId required');
    if (!modifiedBy) throw new Error('modifiedBy required');

    const db = getDB();
    const member = await _xferGetMember(db, memberId);
    if (!member.pending_facilitator_id) {
      throw new Error('No pending transfer to modify');
    }

    // If destination unchanged, only effective_date needs updating.
    const newToFacId = toFacilitatorId || member.pending_facilitator_id;
    let toLcGroup = member.pending_lc_group;
    if (toFacilitatorId && toFacilitatorId !== member.pending_facilitator_id) {
      const { data: destRow, error: destErr } = await db.from('members')
        .select('id,name,lc_group,pipeline_level').eq('id', toFacilitatorId).maybeSingle();
      if (destErr) throw destErr;
      if (!destRow) throw new Error('Destination LCL not found');
      if ((destRow.pipeline_level || 0) < 2) {
        throw new Error('Destination LCL must be pipeline_level >= 2');
      }
      toLcGroup = destRow.lc_group || destRow.name;
    }

    const nowIso = new Date().toISOString();

    // Get the existing proposed row to chain via parent_id
    const { data: existing, error: exErr } = await db.from('transfers')
      .select('id,from_facilitator_id,from_lc_group,reason,proposed_by')
      .eq('member_id', memberId)
      .eq('status', 'proposed')
      .order('created_at', { ascending: false })
      .limit(1).maybeSingle();
    if (exErr) throw exErr;
    if (!existing) {
      // No proposed row found — treat as fresh propose
      return await _xferPropose({
        memberId, toFacilitatorId: newToFacId,
        effectiveDate, reason: null, proposedBy: modifiedBy
      });
    }

    // 1) Stamp existing as 'modified'
    const { error: stampErr } = await db.from('transfers').update({
      status: 'modified',
      decided_by: modifiedBy,
      decided_at: nowIso
    }).eq('id', existing.id);
    if (stampErr) throw stampErr;

    // 2) Insert new 'proposed' row chained to it
    const { data: newRow, error: insErr } = await db.from('transfers').insert({
      member_id: memberId,
      from_facilitator_id: existing.from_facilitator_id,
      to_facilitator_id: newToFacId,
      from_lc_group: existing.from_lc_group,
      to_lc_group: toLcGroup,
      effective_date: effectiveDate || member.transfer_date || null,
      reason: existing.reason,
      status: 'proposed',
      proposed_by: existing.proposed_by,
      parent_id: existing.id
    }).select().single();
    if (insErr) throw insErr;

    // 3) Update members.pending_*
    const { error: mErr } = await db.from('members').update({
      pending_facilitator_id: newToFacId,
      pending_lc_group: toLcGroup,
      transfer_date: effectiveDate || member.transfer_date || null,
      updated_at: nowIso
    }).eq('id', memberId);
    if (mErr) throw mErr;

    return newRow;
  }

  // Full chronological history for a member (all transfers rows).
  async function _xferHistoryFor(memberId) {
    if (!memberId) return [];
    const db = getDB();
    const { data, error } = await db.from('transfers')
      .select('*')
      .eq('member_id', memberId)
      .order('created_at', { ascending: false });
    if (error) throw error;
    return data || [];
  }

  // Members with a pending transfer INTO the given LCL.
  // Used by the destination LCL's "Incoming Members" home card.
  async function _xferIncomingFor(facilitatorId) {
    if (!facilitatorId) return [];
    const db = getDB();
    const { data, error } = await db.from('members')
      .select('id,name,lc_group,facilitator_id,facilitator_name,pending_lc_group,pending_facilitator_id,pending_transfer_by,transfer_date,pipeline_level')
      .eq('pending_facilitator_id', facilitatorId)
      .order('name');
    if (error) throw error;
    return data || [];
  }

  // Members with a pending transfer OUT of the given LCL (whose facilitator_id
  // is the LCL but who have a pending_facilitator_id set to someone else).
  // Used by source LCL to find their own outgoing proposals.
  async function _xferOutgoingFor(facilitatorId) {
    if (!facilitatorId) return [];
    const db = getDB();
    const { data, error } = await db.from('members')
      .select('id,name,lc_group,facilitator_id,facilitator_name,pending_lc_group,pending_facilitator_id,pending_transfer_by,transfer_date,pipeline_level')
      .eq('facilitator_id', facilitatorId)
      .not('pending_facilitator_id', 'is', null)
      .order('name');
    if (error) throw error;
    return data || [];
  }

  // Count of open proposals (for Pastor's badge / nav count).
  async function _xferOpenProposalsCount() {
    const db = getDB();
    const { count, error } = await db.from('transfers')
      .select('id', { count: 'exact', head: true })
      .eq('status', 'proposed');
    if (error) throw error;
    return count || 0;
  }

  // ── Internal helpers for transfers ──

  // Stamp the most recent 'proposed' row for a member with new status.
  // If multiple proposed rows exist (shouldn't happen, but defensive),
  // stamps the newest one only.
  async function _xferStampLatestProposed(db, memberId, patch) {
    const { data: existing, error: exErr } = await db.from('transfers')
      .select('id')
      .eq('member_id', memberId)
      .eq('status', 'proposed')
      .order('created_at', { ascending: false })
      .limit(1).maybeSingle();
    if (exErr) throw exErr;
    if (!existing) {
      // Edge case: pending_lc_group was set without a transfers row (legacy
      // data from before this migration). Insert a synthetic row so the
      // audit trail has something.
      const { data: synth, error: synthErr } = await db.from('transfers').insert({
        member_id: memberId,
        to_facilitator_id: patch.decided_by, // best effort — caller-decided
        to_lc_group: '(legacy)',
        status: patch.status,
        proposed_by: null,
        proposed_at: new Date().toISOString(),
        decided_by: patch.decided_by,
        decided_at: patch.decided_at,
        decision_note: (patch.decision_note || '') + ' [legacy — no proposed row]'
      }).select().single();
      if (synthErr) throw synthErr;
      return synth;
    }

    const { data: stamped, error: upErr } = await db.from('transfers')
      .update(patch).eq('id', existing.id).select().single();
    if (upErr) throw upErr;
    return stamped;
  }

  // Manila-safe YYYY-MM-DD (Invariant #12 trap avoidance)
  function _xferYmd(d) {
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${y}-${m}-${day}`;
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
    // BTLI Quiz eligibility (Priority C · May 16, 2026 — hybrid gate)
    btli: {
      eligibilityFor: btliEligibilityFor,
      eligibilityForMany: btliEligibilityForMany
    },
    // Cohort permissions + MLT helpers (Priority C2 · May 16, 2026)
    cohorts: {
      canEnroll:           _cohortsCanEnroll,
      canEdit:             _cohortsCanEdit,
      canGraduate:         _cohortsCanGraduate,
      listVisibleToLeader: _cohortsListVisibleToLeader,
      listActiveByCourseCode: _cohortsListActiveByCourseCode,
      eligibleCandidates:  _cohortsEligibleCandidates
    },
    // Wednesday Preaching (May 2026)
    preaching: {
      getUpcomingForMember: _preaching_getUpcomingForMember,
      getPendingSwapsForMember: _preaching_getPendingSwapsForMember,
      computeReminderStage: _preaching_computeReminderStage,
      isDismissed: _preaching_isDismissed,
      dismiss: _preaching_dismiss,
      renderReminderBanner: _preaching_renderReminderBanner
    },
    // LCG Transfers — propose/approve flow with audit history (May 18, 2026)
    transfers: {
      listEligibleDestinationLCLs: _xferListEligibleDestinationLCLs,
      propose:               _xferPropose,
      approve:               _xferApprove,
      reject:                _xferReject,
      cancel:                _xferCancel,
      modify:                _xferModify,
      historyFor:            _xferHistoryFor,
      incomingFor:           _xferIncomingFor,
      outgoingFor:           _xferOutgoingFor,
      openProposalsCount:    _xferOpenProposalsCount
    }
  };
})(typeof window !== 'undefined' ? window : globalThis);
