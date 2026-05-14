// ─────────────────────────────────────────────────────────────────
// MULTIPLY Member Tool — Service Worker
// ─────────────────────────────────────────────────────────────────
// Mirrors MLT's strategy:
//   - Network-first for HTML (so deploys are seen quickly)
//   - Cache-first for icons/manifest (rarely change)
//   - Pass-through for Supabase API (must always be fresh)
//
// CACHE_VERSION: bump this string whenever you deploy. Old caches with
// different versions are deleted on activate, forcing a fresh fetch.
// ─────────────────────────────────────────────────────────────────

const CACHE_VERSION = 'mmt-v3-2026-05-14-pwa-scope-fix';
const SHELL_ASSETS = [
  './member_tool.html',
  './member_login.html',
  './multiply_shared.js',
  './manifest_member.json',
  './icon_member_192.png',
  './icon_member_512.png',
  './maskable_member.png',
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_VERSION).then(cache => {
      return Promise.all(
        SHELL_ASSETS.map(url =>
          cache.add(url).catch(err => {
            console.warn('[mmt-sw] precache failed for', url, err.message);
          })
        )
      );
    }).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(
        keys
          .filter(k => k !== CACHE_VERSION)
          .map(k => caches.delete(k))
      )
    ).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', event => {
  const req = event.request;
  const url = new URL(req.url);
  if (req.method !== 'GET') return;
  if (url.host.includes('supabase')) return;
  if (url.origin !== self.location.origin) return;

  if (req.destination === 'document' || url.pathname.endsWith('.html') || url.pathname.endsWith('/')) {
    event.respondWith(networkFirst(req));
    return;
  }
  // multiply_shared.js: network-first like HTML, since it carries auth/session
  // logic that MUST match the deployed HTML version. May 14, 2026 lesson: when
  // shared.js was cache-first, the PIN consolidation deploy caused logged-in
  // users to bounce because they were running stale shared.js paired with
  // fresh HTML. Network-first costs ~50ms per page load but eliminates the
  // mismatch class of bugs entirely.
  if (url.pathname.endsWith('/multiply_shared.js') || url.pathname.endsWith('multiply_shared.js')) {
    event.respondWith(networkFirst(req));
    return;
  }
  event.respondWith(cacheFirst(req));
});

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
    return new Response(
      '<!doctype html><html><body style="font-family:sans-serif;padding:2em;text-align:center;background:#0e3a2c;color:#fef9ec"><h2>Offline</h2><p>MMT can\'t reach the server right now.<br>Please check your connection and try again.</p></body></html>',
      { headers: { 'Content-Type': 'text/html' }, status: 503 }
    );
  }
}

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
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});
