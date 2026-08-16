// ─────────────────────────────────────────────────────────────────────────
// MULTIPLY · Consolidated Service Worker (A3b)
// ───────────────────────────────────────────────────────────────────────────
// ONE service worker for the whole unified shell. Registered ONLY by
// index.html with scope "./" (= /multiply/), so it controls the shell AND the
// iframed tools (member_tool / lc_leader_tool / multiply_dashboard) + the
// login pages — replacing the two narrowly-scoped per-tool SWs (now retired to
// kill-switch stubs in service-worker.js / service-worker-member.js).
//
// STRATEGY (do NOT reintroduce stale-serving — this project relies on ?v=
// cache-busting and rapid Pages deploys):
//   • NETWORK-FIRST for navigations + HTML + JS  → online users always get the
//     fresh deploy; cache is only a fallback when offline.
//   • CACHE-FIRST  for immutable static assets (icons, images, manifest).
//   • Cross-origin (Supabase API, Google Fonts, jsPDF, etc.) is NEVER
//     intercepted — let the browser handle it.
//
// On activate: delete every cache that isn't the current version (incl. the old
// mlt-/mmt- caches), then claim clients immediately.
//
// KILL SWITCH: if this ever misbehaves, replace this file's contents with:
//   self.addEventListener('install', () => self.skipWaiting());
//   self.addEventListener('activate', e => { e.waitUntil(
//     caches.keys().then(ks => Promise.all(ks.map(k => caches.delete(k))))
//       .then(() => self.registration.unregister())); });
// ─────────────────────────────────────────────────────────────────────────

const CACHE_VERSION = 'multiply-shell-v9-2026-08-16';
const SHELL_ASSETS = [
  './',
  'index.html',
  'member_tool.html',
  'lc_leader_tool.html',
  'multiply_dashboard.html',
  'member_login.html',
  'leader_login.html',
  'multiply_shared.js',
  'family_huddle_card.html',
  'shell.webmanifest',
  'favicon.svg',
  'icon_192.png',
  'icon_512.png',
  'maskable_icon.png',
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_VERSION).then(cache =>
      // Best-effort precache — a single 404 must not fail the whole install.
      Promise.all(SHELL_ASSETS.map(url =>
        cache.add(url).catch(err => console.warn('[multiply-sw] precache miss:', url, err && err.message))
      ))
    ).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE_VERSION).map(k => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', event => {
  const req = event.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  // Only handle same-origin; never touch Supabase / fonts / CDN scripts.
  if (url.origin !== self.location.origin) return;

  const isDoc = req.mode === 'navigate'
    || req.destination === 'document'
    || url.pathname.endsWith('.html')
    || url.pathname.endsWith('/');
  const isJS = req.destination === 'script' || url.pathname.endsWith('.js');

  if (isDoc || isJS) { event.respondWith(networkFirst(req)); return; }
  event.respondWith(cacheFirst(req));
});

// Network-first: fresh deploys win; fall back to cache (then a tiny offline
// page for navigations) when the network is unreachable.
const SW_NET_TIMEOUT_MS = 3500;

async function networkFirst(req) {
  // Real network fetch; also refreshes the cache. Kept alive so it can revalidate
  // the cache in the background even when the timeout below wins the race.
  const netPromise = fetch(req).then(fresh => {
    if (fresh && fresh.ok) {
      // Clone NOW, synchronously, while the body is still untouched. caches.open()
      // is async: by the time it resolves, `fresh` has already been handed to
      // respondWith() and the browser has begun reading its body, so a clone()
      // deferred until then throws "Response body is already used" -- and because
      // it throws while evaluating the argument, .catch() never sees it, producing
      // an UNHANDLED rejection and a cache write that silently never happens.
      const copy = fresh.clone();
      caches.open(CACHE_VERSION)
        .then(c => c.put(req, copy))
        .catch(() => {});
    }
    return fresh;
  });
  netPromise.catch(() => {}); // swallow late rejection if the timeout already won

  // On a post-idle stale socket a bare fetch can hang for minutes. Race it against a
  // short timeout and fall back to cache fast instead of waiting out the TCP timeout.
  const timeoutP = new Promise(res => setTimeout(() => res('__NET_TIMEOUT__'), SW_NET_TIMEOUT_MS));

  let res;
  try { res = await Promise.race([netPromise, timeoutP]); }
  catch (e) { res = '__NET_TIMEOUT__'; } // network errored fast -> treat as miss, try cache

  if (res !== '__NET_TIMEOUT__' && res) return res; // network answered in time

  // Stalled/failed -> serve cache if we have it (background fetch keeps it fresh).
  const cached = await caches.match(req);
  if (cached) return cached;

  // No cache (cold, non-precached resource) -> don't abandon; wait for the real fetch.
  try { const late = await netPromise; if (late) return late; } catch (e) {}

  if (req.mode === 'navigate') {
    const shell = (await caches.match('./')) || (await caches.match('index.html'));
    if (shell) return shell;
  }
  return new Response(
    '<!doctype html><meta charset="utf-8"><body style="font-family:system-ui;background:#0e3a2c;color:#f5e8c4;text-align:center;padding:2em"><h2>Offline</h2><p>MULTIPLY can\'t reach the server right now.<br>Check your connection and try again.</p></body>',
    { headers: { 'Content-Type': 'text/html' }, status: 503 }
  );
}

// Cache-first: immutable static assets.
async function cacheFirst(req) {
  const cached = await caches.match(req);
  if (cached) return cached;
  try {
    const fresh = await fetch(req);
    if (fresh && fresh.ok) {
      const cache = await caches.open(CACHE_VERSION);
      cache.put(req, fresh.clone()).catch(() => {});
    }
    return fresh;
  } catch (e) {
    return new Response('Resource unavailable offline', { status: 503 });
  }
}

self.addEventListener('message', event => {
  if (event.data && event.data.type === 'SKIP_WAITING') self.skipWaiting();
});
