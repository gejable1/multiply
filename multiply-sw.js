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

const CACHE_VERSION = 'multiply-shell-v1-2026-06-15';
const SHELL_ASSETS = [
  './',
  'index.html',
  'member_tool.html',
  'lc_leader_tool.html',
  'multiply_dashboard.html',
  'member_login.html',
  'leader_login.html',
  'multiply_shared.js',
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
async function networkFirst(req) {
  try {
    const fresh = await fetch(req);
    if (fresh && fresh.ok) {
      const cache = await caches.open(CACHE_VERSION);
      cache.put(req, fresh.clone()).catch(() => {});
    }
    return fresh;
  } catch (e) {
    const cached = await caches.match(req);
    if (cached) return cached;
    if (req.mode === 'navigate') {
      const shell = (await caches.match('./')) || (await caches.match('index.html'));
      if (shell) return shell;
    }
    return new Response(
      '<!doctype html><meta charset="utf-8"><body style="font-family:system-ui;background:#0e3a2c;color:#f5e8c4;text-align:center;padding:2em"><h2>Offline</h2><p>MULTIPLY can\'t reach the server right now.<br>Check your connection and try again.</p></body>',
      { headers: { 'Content-Type': 'text/html' }, status: 503 }
    );
  }
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
