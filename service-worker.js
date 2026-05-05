// ─────────────────────────────────────────────────────────────────
// MULTIPLY Leader's Tool — Service Worker
// ─────────────────────────────────────────────────────────────────
// Conservative caching strategy:
//   - Network-first for HTML (so deploys are seen quickly)
//   - Cache-first for icons/manifest (rarely change)
//   - Pass-through for Supabase API (must always be fresh)
//
// CACHE_VERSION: bump this string whenever you deploy. Old caches with
// different versions are deleted on activate, forcing a fresh fetch.
//
// KILL SWITCH: if this PWA ever misbehaves in the wild, deploy a new
// service-worker.js whose only contents are:
//     self.addEventListener('install', () => self.skipWaiting());
//     self.addEventListener('activate', e => {
//       e.waitUntil(caches.keys().then(ks => Promise.all(ks.map(k=>caches.delete(k)))));
//       self.registration.unregister();
//     });
// That will unregister the SW and clear everything on next page load.
// ─────────────────────────────────────────────────────────────────

const CACHE_VERSION = 'mlt-v1-2026-05-05';
const SHELL_ASSETS = [
  './lc_leader_tool.html',
  './multiply_shared.js',
  './manifest.json',
  './icon_192.png',
  './icon_512.png',
  './maskable_icon.png',
];

// ─── Install: pre-cache the shell ───────────────────────────────────
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_VERSION).then(cache => {
      // Use addAll with try/catch fallback — if any file fails (404 etc),
      // don't fail the whole install; cache what we can.
      return Promise.all(
        SHELL_ASSETS.map(url =>
          cache.add(url).catch(err => {
            console.warn('[sw] precache failed for', url, err.message);
          })
        )
      );
    }).then(() => self.skipWaiting()) // activate immediately on first install
  );
});

// ─── Activate: clean up old caches ──────────────────────────────────
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

// ─── Fetch: routing ────────────────────────────────────────────────
self.addEventListener('fetch', event => {
  const req = event.request;
  const url = new URL(req.url);

  // Only handle GET requests — never cache POST/PUT/DELETE etc.
  if (req.method !== 'GET') return;

  // Never intercept Supabase API calls. Auth, member data, attendance
  // writes — all must hit the network. If offline, let it fail naturally.
  if (url.host.includes('supabase')) return;

  // Never intercept cross-origin third-party scripts (jsPDF, Google Fonts, etc.)
  // Browser cache handles them fine; SW intercepting can cause CORS surprises.
  if (url.origin !== self.location.origin) return;

  // ── HTML: network-first (so new deploys are seen quickly) ──
  if (req.destination === 'document' || url.pathname.endsWith('.html') || url.pathname.endsWith('/')) {
    event.respondWith(networkFirst(req));
    return;
  }

  // ── Everything else (JS/CSS/PNG/JSON): cache-first ──
  event.respondWith(cacheFirst(req));
});

// ─── Strategies ────────────────────────────────────────────────────

// Network-first: try network; on failure, fall back to cache.
// Updates the cache on every successful network fetch (stale-while-revalidate
// flavor — current visit gets fresh, cache catches up for next offline).
async function networkFirst(req) {
  try {
    const fresh = await fetch(req);
    // Only cache successful responses (avoid caching 404 / 500 pages)
    if (fresh && fresh.ok) {
      const cache = await caches.open(CACHE_VERSION);
      cache.put(req, fresh.clone()).catch(() => {});
    }
    return fresh;
  } catch (e) {
    const cached = await caches.match(req);
    if (cached) return cached;
    // No network and no cache → return a tiny offline page rather than
    // letting the browser show its default offline error
    return new Response(
      '<!doctype html><html><body style="font-family:sans-serif;padding:2em;text-align:center;background:#0f0f13;color:#e6e6e6"><h2>Offline</h2><p>MLT can\'t reach the server right now.<br>Please check your connection and try again.</p></body></html>',
      { headers: { 'Content-Type': 'text/html' }, status: 503 }
    );
  }
}

// Cache-first: serve from cache when present; otherwise fetch + cache.
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
    // Truly unreachable — return a 503 so callers see the failure
    return new Response('Resource unavailable offline', { status: 503 });
  }
}

// ─── Message handler: lets the page request a force-update ─────────
// Page can call: navigator.serviceWorker.controller.postMessage({type:'SKIP_WAITING'})
self.addEventListener('message', event => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});
