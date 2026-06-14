# UNIFY_SHELL_PLAN.md — MMT as the unified shell (MMT + MLT + MD in one app)

**Status:** PLAN ONLY — no code changes (Inv #56: read-only validation; deployed files read, nothing edited).
**Goal under validation:** merge **MMT + MLT + MD** into **one app**. MMT is the primary login / shell.
MLT and MD open as **full-screen overlays (iframes)** on top of MMT, launched from **role-gated buttons in
the existing bottom toolbar** (where Home / Journey live). Each overlay has a **floating Home button** that
closes it and resurfaces MMT. **One login, one PWA.**

**Role → button mapping (confirmed feasible):**
- **Member** → MMT only (everyone has a member session).
- **LCL (leader)** → MMT + **MLT** button.
- **Pastor / superuser (L5)** → MMT + **MLT** + **MD** buttons.

**Verdict: feasible, low-to-moderate risk.** No framebusting anywhere in the codebase, same-origin
storage is shared, the PIN is already unified, and the two session shapes map cleanly. The two real
work items are (1) a **session bridge** so one MMT login also satisfies the leader gate, and (2) a
**unified history/back-button + service-worker/manifest consolidation**. Details below.

---

## 1. Current architecture (as read from deployed files)

### 1.1 Two independent sessions (`multiply_shared.js`)

Both live in **`sessionStorage`** (not localStorage), independent keys, scoped per tab.

| | Leader session | Member session |
|---|---|---|
| Key | `multiply_leader_session` | `multiply_member_session` |
| Minted by | `leader_login.html` → `loginSuccess()` (`:551`) | `member_login.html` → `loginSuccess()` (`:537`) |
| Read/gate | `getValidSession()` (`:61`) → `gateOrRedirect()` (`:77`) sets `window.LEADER` | `getValidMemberSession()` (`:118`) → `gateMemberOrRedirect()` (`:134`) sets `window.MEMBER` |
| Logout | `logoutLeader()` (`:89`) — stamps `leader_sessions.ended_at`, clears key | `logoutMember()` (`:148`) — clears key |
| Validity rule | has `leaderId` + `expiresAt` not past + **`leaderLevel >= 2`** | has `memberId` + `expiresAt` not past |

**Exact stored shapes:**

```js
// multiply_leader_session  (leader_login.html:553)
{ leaderId, leaderName, leaderLevel, leaderRole, leaderLcGroup, expiresAt, sessionStart }

// multiply_member_session  (member_login.html:539)
{ memberId, memberName, memberLevel, memberRole, memberLcGroup, memberDisciplerName, expiresAt, sessionStart }
```

Both sessions last `SESSION_HOURS = 8`. The leader gate hard-requires `leaderLevel >= 2`
(`getValidSession` `:71`) — non-leaders can never hold a valid leader session.

**Consumers:** `multiply_leader_session` → MD, MLT, the 4 reports. `multiply_member_session` → MMT.
The module header (`:24–28`) explicitly warns: **do not remove the member or leader gate functions** —
every entry page calls its gate synchronously at top-of-`<body>` or the spinner hangs forever. The bridge
below is **purely additive** and removes none of the four functions (honors Inv #84's spirit).

### 1.2 PIN is already unified

Both login pages verify against the **same DB column `members.member_pin_hash`**:
- `member_login.html:355` selects `member_pin_hash`; `leader_login.html:371` selects `member_pin_hash`.
- Leader list is filtered to `pipeline_level >= 2` (`leader_login.html:372`); member list loads everyone.

So a leader's single PIN already authenticates both surfaces — **the only thing missing is minting the
second session object.** This is what makes the bridge a small, safe change.

### 1.3 MMT toolbar (where buttons slot in)

`member_tool.html` bottom tab bar `#tabbar` (`:2126`), 5 buttons, each `onclick="goTo('<page>')"`:

```
🏡 Home (home) · 🪜 Journey (pipeline) · 🌱 Discover (assess) · 🌍 EOLO (eolo) · 👤 Profile (profile)
```

`goTo(pageName)` (`:5561`) toggles `.screen-page.active` and the active `.tab`. **Role-gated MLT / MD
buttons slot in here** as extra `.tab` buttons — but instead of calling `goTo`, they call an overlay
opener (`openShellOverlay('mlt'|'md')`). With 5 existing + up to 2 new = 6–7 buttons, the bar needs
`overflow-x:auto` (horizontal scroll) or icon-only compaction on narrow phones.

### 1.4 Role resolution (drives which buttons render)

- **member** — always (the MMT session itself).
- **leader (LCL)** — `pipeline_level >= 2` (matches both `leader_login.html:372` and the `getValidSession`
  floor). The member's own `members` row is authoritative (Inv #162: never the session shim).
- **pastor / superuser** — `multiply_dashboard.html:_isSuperuser()` (`:2926`) = `LeaderScope.isPastor()`
  (level ≥ 5) **OR** Level-5-with-no-`discipler_id`. MMT has no `LeaderScope`; the MMT prayer block
  already mirrors this as **`pipeline_level >= 5`** (HANDOFF S35) — reuse that predicate in the shell.

**Important:** MD's own gate (`multiply_dashboard.html:451`) only requires a *valid leader session*
(level ≥ 2) — it does **not** itself enforce pastor-only. Therefore the **MD-button visibility (Pastor/L5
only) must be enforced in the shell**, not relied upon from inside MD.

### 1.5 PWA / service-worker / manifest (today = two separate PWAs)

| | MLT | MMT |
|---|---|---|
| Manifest | `manifest.json` — `start_url`/`scope` = `…/lc_leader_tool.html` | `manifest_member.json` — `start_url`/`scope` = `…/member_tool.html` |
| Service worker | `service-worker.js`, registered `scope:'/multiply/lc_leader_tool.html'` (`lc_leader_tool.html:6131`) | `service-worker-member.js`, registered `scope:'/multiply/member_tool.html'` (`member_tool.html:5948`) |
| Strategy | network-first HTML + `multiply_shared.js`; cache-first assets | identical strategy |

`index.html` redirects `/multiply/` → `lc_leader_tool.html` (the legacy default landing). MD registers
**no** service worker (desktop tool). Two manifests = two installable PWAs from one domain → this is exactly
the **Samsung One-UI dual-install conflict (Inv #15)**. **Consolidation removes that footgun.**

### 1.6 Existing history/back handling

Only **MLT** intercepts history (`lc_leader_tool.html:1255–1323`): a `screenStack`, `pushState` per
screen, a `popstate` handler that walks back through screens and `confirm()`s before exiting at root, a
`beforeunload` guard on unsaved attendance, and a boot `replaceState`. **MMT and MD have no history
interception.** This MLT logic is the one piece that will **conflict** with a shell-owned back-button when
MLT is iframed (see §4 and §5-A2).

---

## 2. iframe feasibility — blockers scan + verdict

**Method:** grepped all HTML for `window.top` / `window.parent` / `self !== top` / `top.location` /
`parent.location` / `frameElement` / framebust patterns → **zero matches.** No app tries to break out of
or detect a frame.

| Concern | Finding | Verdict |
|---|---|---|
| Framebusting / `window.top` checks | None anywhere | ✅ Safe to embed |
| Same-origin storage sharing | All three are same-origin (`gejable1.github.io/multiply/…`). A same-origin iframe **shares the parent tab's `sessionStorage` and `localStorage`** | ✅ Bridge in MMT's `sessionStorage` is visible to iframed MD/MLT gates |
| Standalone/PWA-only assumptions | MMT lesson viewer notes "installed PWA shell — fullscreen" (`:5304`) but it's cosmetic, not a frame-buster | ✅ No blocker |
| `location.replace` on logout/gate-fail | Inside an iframe, `location.replace` replaces **the iframe document**, not the shell | ⚠️ Acceptable but must be handled — see §3.4 and §5-A2 |
| MLT `popstate`/`beforeunload`/`pushState` | Runs inside the iframe; its `pushState` lands on the **shared tab session history**, colliding with the shell's back model | ⚠️ **Primary blocker** — mitigation in §4 / §5-A2 |
| Inv #57 URL-leak (obscure slugs) | Iframes keep the inner URL out of the address bar; in standalone PWA there's no address bar at all | ✅ **Helped** — consolidation improves #57 posture |
| Service-worker scope | MMT SW scope (`/multiply/member_tool.html`) does **not** cover an iframe loading `lc_leader_tool.html`; that doc would be controlled by MLT's own SW (if still registered) | ⚠️ Resolve via single `/multiply/`-scoped SW — see §3.5 |

**Net:** no hard blockers. The only real engineering is the **MLT internal history handler** and the
**SW/manifest consolidation** — both addressed below.

---

## 3. The design

### 3.1 Session bridge (the core of A1)

**Problem:** an iframed MLT/MD calls `gateOrRedirect()`, which needs a valid `multiply_leader_session`.
After an MMT-only login that session does not exist.

**Solution:** add **one additive helper** to `multiply_shared.js`, e.g.:

```js
// Additive — does NOT replace any of the 4 gate functions (module header :24–28).
function bridgeLeaderSessionFromMember(memberRow, memberSession) {
  // Only leaders (level >= 2) get a leader session — mirrors getValidSession :71
  const level = (memberRow && memberRow.pipeline_level) || memberSession.memberLevel || 0;
  if (level < 2) return false;
  // Never clobber a richer, still-valid leader session that already exists.
  if (getValidSession()) return true;
  const sess = {
    leaderId:     memberSession.memberId,
    leaderName:   memberSession.memberName,
    leaderLevel:  level,
    leaderRole:   memberRow.facilitator_role || memberSession.memberRole,
    leaderLcGroup: memberRow.lc_group || memberSession.memberLcGroup || null,
    expiresAt:    memberSession.expiresAt,     // keep both sessions on ONE clock
    sessionStart: memberSession.sessionStart,
  };
  sessionStorage.setItem('multiply_leader_session', JSON.stringify(sess));
  return true;
}
```

- **Called from MMT boot** (after `gateMemberOrRedirect` succeeds and the member's own row is loaded — MMT
  already loads it for Inv #162). Mints the leader session **only for leaders**, from the **member's own DB
  row** (authoritative, never the shim).
- **Shared expiry clock:** copy `expiresAt`/`sessionStart` from the member session so the two don't drift
  and one doesn't silently outlive the other.
- **No-clobber:** if a valid leader session already exists (e.g., the leader logged into MLT directly
  earlier in the tab), leave it.
- **Logout:** the shell's logout calls **both** `logoutMember()` and (if present) `logoutLeader()` so the
  bridged session is also torn down and `leader_sessions.ended_at` is stamped.

This is the **minimal** change that lets the iframed MD/MLT gates pass with one login. The four original
gate functions remain untouched.

### 3.2 Shell + role toolbar

- Compute role flags at MMT boot from the member's own row: `isLeader = level >= 2`, `isPastor = level >= 5`
  (mirror `_isSuperuser`'s no-`discipler_id` clause if desired for the rare top-of-tree L5).
- Conditionally render extra `#tabbar` buttons: **🧑‍🏫 Leader (MLT)** when `isLeader`; **⚙️ Pastor (MD)**
  when `isPastor`. Make `#tabbar` horizontally scrollable for 6–7 buttons.
- Buttons call `openShellOverlay('mlt')` / `openShellOverlay('md')`, **not** `goTo`.

### 3.3 Full-screen iframe overlays + floating Home

- One reusable overlay container: `position:fixed; inset:0; z-index:10000` (above MMT modals which top out
  at `z-index:9999`), holding a lazily-created `<iframe>`.
- `openShellOverlay(which)` sets `iframe.src = which==='md' ? 'multiply_dashboard.html?embed=1'
  : 'lc_leader_tool.html?embed=1'` (lazy: only first open loads it; later opens just unhide).
- **Floating Home button** (FAB, `z-index:10001`) drawn by the shell over the iframe → `closeShellOverlay()`
  hides the overlay and resurfaces MMT at its last tab. The button is the shell's, not the iframe's, so it
  cannot be broken by inner-app CSS.

### 3.4 `?embed=1` contract (decouples the inner apps from the shell)

A query flag tells MD/MLT they're embedded, so they can **defer cross-cutting behaviors to the shell**:
- **Suppress their own history interception** (MLT `pushState`/`popstate`/`beforeunload` block,
  `lc_leader_tool.html:1255–1323`) — the shell owns back (see §4).
- **Redirect-on-logout/gate-fail:** when embedded, instead of `location.replace('leader_login.html')`
  (which would strand a login page inside the frame), post a message to the shell
  (`parent.postMessage({type:'shell-logout'}, location.origin)`) so the shell closes the overlay and runs
  the unified logout. (A1 can ship the bridge without this; A2 wires it.)
- Optionally hide the inner app's own logout/back chrome since the shell provides Home.

This keeps A1 shippable on its own and concentrates iframe-specific logic behind one readable flag.

### 3.5 PWA consolidation (one shell PWA)

- **One manifest** (keep `manifest_member.json`'s identity, or a new `manifest.json`): `start_url` =
  `member_tool.html`, `scope` = `/multiply/` (covers the iframed inner docs). Update `index.html` to point
  the legacy `/multiply/` landing at `member_tool.html` (was `lc_leader_tool.html`).
- **One service worker** scoped to **`/multiply/`** so it controls the shell *and* the iframed
  `lc_leader_tool.html` / `multiply_dashboard.html` documents. Reuse the existing network-first-HTML +
  network-first-`multiply_shared.js` + cache-first-assets strategy (already identical in both SWs). Add the
  inner HTML files to the shell-asset precache list. **Bump `CACHE_VERSION`.**
- **Retire/neutralize** `service-worker.js` + `service-worker-member.js` + the second manifest as separate
  installables. (Keep a kill-switch SW per the existing comment if a stale registration must be cleared in
  the wild.)
- **Inv #15 win:** one PWA per domain eliminates the Samsung dual-install conflict.
- **Inv #57 win:** standalone PWA has no address bar; iframed slugs never surface.

---

## 4. Unified back-button model

**Target behavior:** Back closes the top overlay/modal → returns to MMT; at the MMT root, Back does **not**
exit the PWA.

**Shell-owned single source of truth (replaces ad-hoc per-app handlers):**
1. On boot, `history.replaceState({shell:'root'}, '')` — a sentinel root entry.
2. Opening an overlay (or a shell modal) → `history.pushState({shell:'overlay', which}, '')`.
3. `popstate`:
   - If an overlay is open → `closeShellOverlay()` and **stop** (back "consumed" by closing).
   - Else (at MMT root) → re-`pushState` the sentinel so the PWA is **not** exited (the standalone
     "don't close on back" requirement — this **subsumes** that separate task).

**MLT-inside-iframe conflict (the one real complication):** MLT today pushes a history entry per inner
screen and runs its own `popstate`. Inside the frame those entries land on the **shared tab history**,
so a single Back press would be ambiguous (inner screen vs. shell overlay). **Mitigation (chosen):** when
`?embed=1`, **MLT disables its `screenStack`/`popstate`/`beforeunload`/`pushState` block entirely** and
exposes its in-app navigation through its existing on-screen back buttons only; the **shell's** Back closes
the whole overlay. This is the simplest correct model and avoids nested-history fragility. (A later,
optional refinement could let the shell delegate Back into the iframe until its screen stack empties, then
close the overlay — more faithful but more fragile; not recommended for first cut.) MLT's **unsaved-
attendance `beforeunload` guard** should be preserved in a shell-aware form (e.g., the overlay-close path
checks an `attendanceDirty` flag the iframe exposes) so the existing data-loss protection isn't lost.

---

## 5. Sequenced sub-build plan

### A1 — Auth / session bridge  *(small, isolated, shippable alone)*
**Build:**
1. Add `bridgeLeaderSessionFromMember()` to `multiply_shared.js` (additive; export it).
2. Call it from MMT boot once the member's own row is loaded; mint leader session for `level >= 2`.
3. Make the shell logout call both `logoutMember()` + `logoutLeader()`.
4. **Bump `?v=` lockstep** across **all** `multiply_shared.js` consumers (Inv #138) → `?v=5`.

**Verify:** `node --check` (Inv #105) + a truth-table harness for the bridge (level <2 → no session;
level ≥2 → correct shape; existing valid leader session → no clobber; expiry copied).

**Risks:** (a) `?v=` lockstep miss → stale-cache split-brain (Inv #138/#4); (b) expiry skew if not copied
from the member session; (c) clobbering a directly-minted leader session (guarded by the no-clobber check);
(d) the bridged session uses the member's own row — must read the live row, never the shim (Inv #162).

### A2 — Shell: role toolbar + iframe overlays + floating Home + back-button + PWA consolidation
**Build:**
1. Role flags at boot (`isLeader`, `isPastor`); conditionally render MLT/MD tab buttons; make `#tabbar`
   horizontally scrollable.
2. Overlay container + lazy iframe + `openShellOverlay`/`closeShellOverlay`; floating Home FAB.
3. `?embed=1` contract: in MD/MLT, suppress own history handlers + route logout/gate-fail via `postMessage`.
4. Shell-owned back-button model (§4); preserve MLT's unsaved-attendance guard in a shell-aware form.
5. PWA consolidation (§3.5): one `/multiply/`-scoped SW, one manifest, `index.html` → `member_tool.html`,
   bump `CACHE_VERSION`; retire the duplicate SW/manifest.

**Verify:** browser smoke (Inv #80/#31) on phone PWA — member sees MMT only; LCL sees +MLT overlay with
working Home + Back; Pastor sees +MD; back at root doesn't exit; attendance dirty-guard still warns; one
install only (Inv #15); no slug leak (Inv #57).

**Risks:** (a) **iframe history conflict** (the central one — mitigated by `?embed=1` suppression);
(b) SW scope/cache correctness across the broadened scope; (c) toolbar overflow on small phones;
(d) double service workers during transition (old registrations must be cleared — kill-switch SW ready);
(e) z-index layering (overlay `10000` over MMT's `9999` modals); (f) iframe `location.replace` on an
unhandled gate-fail stranding a login page in the frame (handled by the `postMessage` logout route).

### Later (optional) — deeper merge
- Delegate Back **into** the iframe screen-stack before closing the overlay (faithful nested history).
- Collapse MD/MLT from iframes into in-page modules sharing one DOM/session (removes iframe entirely;
  large, only if iframe seams prove annoying).
- Retire `leader_login.html`'s destination chooser (the shell replaces "which tool?" with role buttons);
  keep `leader_login.html` as a fallback direct entry.
- Centralize role/kind helpers into `multiply_shared.js` — folds naturally into kind-mirroring **Phase B**
  (HANDOFF) and another `?v=` bump.

---

## 6. Invariants touched
- **#4 / #138** — `?v=` bump-together on any `multiply_shared.js` change (A1).
- **#56** — this doc is read-only validation; deployed files were read, none edited.
- **#84 (spirit)** — bridge is additive; the four gate functions are never removed.
- **#162** — bridge reads the member's own live row, not the session shim.
- **#15** — consolidation removes the Samsung dual-PWA install conflict.
- **#57** — iframes/standalone hide inner slugs (improves URL-leak posture).
- **#105 / #31 / #80** — `node --check` + truth-tables + phone smoke before ship.

## 7. PoC note
A trivial iframe-overlay PoC was considered but **skipped** — the task is read-only validation and a
"PR with just the plan doc; implement nothing yet." A safe PoC would still touch `member_tool.html` and a
`?v=` bump, which is out of scope for this pass. Ship A1 first when the Pastor gives the go.
