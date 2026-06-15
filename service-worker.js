// ─────────────────────────────────────────────────────────────────────────
// MULTIPLY Leader's Tool — Service Worker · RETIRED (A3b kill-switch)
// ───────────────────────────────────────────────────────────────────────────
// This per-tool SW is replaced by the consolidated /multiply/-scoped
// multiply-sw.js (registered only by index.html). lc_leader_tool.html no longer
// registers this file. For any browser that still has it registered, this stub
// removes ITS OWN caches (the old "mlt-*" versions), unregisters itself, and
// stops controlling pages — so a stale pre-embed tool is never served into the
// unified shell's overlay iframe. It deletes ONLY mlt-* caches (CacheStorage is
// origin-shared) so it never touches multiply-sw.js's cache.
// ─────────────────────────────────────────────────────────────────────────
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.filter(k => k.startsWith('mlt-')).map(k => caches.delete(k)));
    try { await self.registration.unregister(); } catch (e) {}
    await self.clients.claim();
  })());
});
