/* MULTIPLY — shared Close button for standalone pages (assessments, viewers).
   Self-injects a fixed top-right "✕ Close" that returns to the launching tool WITHOUT closing it (Inv #12):
     • window.close()  — closes the tab when opened via window.open (e.g. MD modal → new tab)
     • else history.back() to a same-host launcher (in-frame nav, e.g. MMT) — state preserved
     • else referrer / history / safe home as last resorts
   Bilingual via the page's existing .tl-text/.en-text classes (mechanism-agnostic: works with data-lang or .lang-tl).
   Config via data-* on the <script> tag: data-home (default 'index.html'), data-auto ('false' to skip auto-mount).
   Usage: <script src="multiply_close.js?v=1"></script>  (auto-mounts), or call MultiplyClose.mount()/MultiplyClose.close().
*/
(function(){
  var _cur = document.currentScript;
  var HOME = (_cur && _cur.getAttribute('data-home')) || 'index.html';
  var AUTO = !(_cur && _cur.getAttribute('data-auto') === 'false');
  function close(){
    try { window.close(); } catch(e) {}
    setTimeout(function(){
      try {
        var ref = document.referrer;
        var sameHost = ref && new URL(ref).host === location.host;
        if (sameHost && history.length > 1) { history.back(); return; }
        if (sameHost) { location.href = ref; return; }
      } catch(e) {}
      if (history.length > 1) { history.back(); return; }
      location.href = HOME;
    }, 200);
  }
  function mount(){
    if (document.getElementById('multiplyCloseBtn')) return; // idempotent
    var b = document.createElement('button');
    b.id = 'multiplyCloseBtn';
    b.setAttribute('aria-label','Close'); b.setAttribute('title','Close');
    b.style.cssText = 'position:fixed;top:.6rem;right:.6rem;z-index:99999;background:rgba(20,16,14,.66);color:#fff;border:none;border-radius:999px;padding:.55rem 1rem;font-size:13px;font-weight:700;cursor:pointer;box-shadow:0 2px 10px rgba(0,0,0,.28);font-family:inherit;line-height:1;-webkit-backdrop-filter:blur(4px);backdrop-filter:blur(4px);';
    b.innerHTML = '<span class="tl-text">✕ Isara</span><span class="en-text">✕ Close</span>';
    b.addEventListener('click', close);
    document.body.appendChild(b);
  }
  window.MultiplyClose = { mount: mount, close: close };
  if (AUTO){
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', mount);
    else mount();
  }
})();
