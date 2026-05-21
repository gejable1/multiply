/* ════════════════════════════════════════════════════════════════════════════
 * multiply_slides_nav.js · v1
 * ════════════════════════════════════════════════════════════════════════════
 *
 * PURPOSE
 *   Shared slide-deck navigation module for all MULTIPLY lesson slides.
 *   Encapsulates the navigation chrome (controls, dots, notes overlay,
 *   fullscreen, keyboard handlers) so individual lesson slides.html files
 *   don't have to maintain navigation code themselves.
 *
 * USAGE
 *   Drop into the root of the repo (sibling to multiply_lesson_slider.js).
 *   Each slides.html includes it ONCE with config via data-* attributes:
 *
 *   <script src="../multiply_slides_nav.js?v=1"
 *           data-notes-label="L6"></script>
 *
 *   Optional data-* attributes:
 *     data-notes-label   — short label shown in notes panel (e.g. "L6", "BTLI 1 · L6")
 *     data-notes-var     — name of the global NOTES array (default: "NOTES")
 *     data-hover-reveal  — "true" (default) or "false" to keep controls always visible
 *
 * REQUIREMENTS OF THE HOST PAGE
 *   - Each slide is a `<div class="slide">` (the first should also have class "active").
 *   - A global `const NOTES = [...]` array, one entry per slide.
 *     (Or override the name via data-notes-var.)
 *
 * WHAT IT INJECTS
 *   - CSS for .controls, .ctrl-btn, .ctrl-info, .dot-row, .dot, .notes-panel
 *   - HTML for the control bar + notes overlay (appended to <body>)
 *   - JS event handlers (prev/next, dot click, keyboard, fullscreen, hover-reveal)
 *
 * WHAT IT EXPOSES (window globals)
 *   - window.slidesNav.showSlide(n)   — jump to slide n (0-indexed)
 *   - window.slidesNav.nextSlide()
 *   - window.slidesNav.prevSlide()
 *   - window.slidesNav.toggleNotes()
 *   - window.slidesNav.toggleFullscreen()
 *   - window.slidesNav.current        — current slide index
 *   - window.slidesNav.total          — total slide count
 *
 * KEYBOARD
 *   →, Space, PageDown     → next
 *   ←, PageUp              → prev
 *   Home                   → first slide
 *   End                    → last slide
 *   N                      → toggle notes overlay
 *   F                      → toggle fullscreen
 *
 * TOUCH
 *   Swipe left/right       → next/prev
 *
 * VERSIONING
 *   v1 (May 21, 2026) — Initial extraction from L1 nav pattern.
 *                       Established as Invariant #74.
 * ══════════════════════════════════════════════════════════════════════════ */

(function () {
  'use strict';

  // ── Read config from this <script> tag ────────────────────────────────
  const thisScript = document.currentScript || (function () {
    const all = document.getElementsByTagName('script');
    return all[all.length - 1];
  })();

  const NOTES_LABEL = (thisScript.dataset.notesLabel || 'Lesson');
  const NOTES_VAR_NAME = (thisScript.dataset.notesVar || 'NOTES');
  const HOVER_REVEAL = (thisScript.dataset.hoverReveal !== 'false');

  // ── Inject CSS ───────────────────────────────────────────────────────
  const css = `
/* multiply_slides_nav.js v1 — injected CSS */
.slides-nav-controls{
  position:fixed;bottom:24px;left:50%;transform:translateX(-50%);
  display:flex;gap:10px;align-items:center;
  background:rgba(10,20,36,.7);backdrop-filter:blur(10px);
  padding:10px 16px;border-radius:999px;
  ${HOVER_REVEAL ? 'opacity:0;' : 'opacity:1;'}
  transition:opacity .3s;z-index:100;
  border:1px solid rgba(212,168,56,.18);
  font-family:'DM Sans',sans-serif;
}
${HOVER_REVEAL ? 'body:hover .slides-nav-controls{opacity:1;}' : ''}
.slides-nav-controls .nav-btn{
  background:none;border:none;color:#f5edd8;cursor:pointer;
  width:36px;height:36px;border-radius:50%;
  display:flex;align-items:center;justify-content:center;
  font-size:14px;transition:background .15s;
  padding:0;
}
.slides-nav-controls .nav-btn:hover{background:rgba(212,168,56,.15);}
.slides-nav-controls .nav-info{
  font-size:12px;color:rgba(245,237,216,.55);
  padding:0 12px;font-weight:500;
  font-variant-numeric:tabular-nums;
}
.slides-nav-controls .nav-dots{
  display:flex;gap:5px;align-items:center;padding:0 8px;
}
.slides-nav-controls .nav-dot{
  width:7px;height:7px;border-radius:50%;
  background:rgba(245,237,216,.2);cursor:pointer;
  transition:all .2s;
}
.slides-nav-controls .nav-dot.active{
  background:#d4a838;width:24px;border-radius:4px;
}

.slides-nav-notes{
  position:fixed;left:24px;bottom:24px;
  max-width:32vw;min-width:280px;
  background:rgba(10,20,36,.92);
  backdrop-filter:blur(12px);
  border:1px solid rgba(212,168,56,.3);
  border-radius:10px;padding:14px 16px;
  font-size:12.5px;line-height:1.6;
  display:none;z-index:90;
  font-family:'DM Sans',sans-serif;
}
.slides-nav-notes.show{display:block;}
.slides-nav-notes .nav-notes-label{
  font-size:9.5px;letter-spacing:.18em;text-transform:uppercase;
  color:#f0c64a;font-weight:700;margin-bottom:6px;
  display:flex;justify-content:space-between;
}
.slides-nav-notes .nav-notes-content{
  color:rgba(255,255,255,.85);white-space:pre-wrap;
}

@media (orientation:portrait){
  .slides-nav-controls{bottom:16px;padding:8px 12px;gap:6px;}
  .slides-nav-controls .nav-btn{width:32px;height:32px;}
  .slides-nav-notes{max-width:90vw;left:5vw;bottom:74px;}
}
`;
  const styleEl = document.createElement('style');
  styleEl.setAttribute('data-injected-by', 'multiply_slides_nav');
  styleEl.textContent = css;
  document.head.appendChild(styleEl);

  // ── Inject HTML markup ──────────────────────────────────────────────
  function injectMarkup() {
    // Notes panel
    const notesEl = document.createElement('div');
    notesEl.className = 'slides-nav-notes';
    notesEl.id = 'slidesNavNotes';
    notesEl.innerHTML = `
      <div class="nav-notes-label">
        <span>🎯 Facilitator Notes</span>
        <span>${escapeHtml(NOTES_LABEL)}</span>
      </div>
      <div class="nav-notes-content" id="slidesNavNotesContent"></div>
    `;
    document.body.appendChild(notesEl);

    // Controls
    const controlsEl = document.createElement('div');
    controlsEl.className = 'slides-nav-controls';
    controlsEl.innerHTML = `
      <button class="nav-btn" id="slidesNavPrev" title="Previous (←)">◂</button>
      <span class="nav-info">
        <span id="slidesNavCur">1</span> / <span id="slidesNavTotal">1</span>
      </span>
      <button class="nav-btn" id="slidesNavNext" title="Next (→)">▸</button>
      <div class="nav-dots" id="slidesNavDots"></div>
      <button class="nav-btn" id="slidesNavNotesBtn" title="Toggle notes (N)">📝</button>
      <button class="nav-btn" id="slidesNavFs" title="Fullscreen (F)">⛶</button>
    `;
    document.body.appendChild(controlsEl);
  }

  // ── Core state + handlers ────────────────────────────────────────────
  function init() {
    const slides = document.querySelectorAll('.slide');
    const total = slides.length;
    if (total === 0) {
      console.warn('[multiply_slides_nav] No .slide elements found — aborting init.');
      return;
    }

    const NOTES = (window[NOTES_VAR_NAME] || []);

    let current = 0;
    // Ensure first slide is active if none is marked
    if (!document.querySelector('.slide.active')) {
      slides[0].classList.add('active');
    } else {
      // Use the index of the already-active slide
      slides.forEach((s, i) => { if (s.classList.contains('active')) current = i; });
    }

    // Build dot row
    const dotsContainer = document.getElementById('slidesNavDots');
    const dotEls = [];
    for (let i = 0; i < total; i++) {
      const d = document.createElement('div');
      d.className = 'nav-dot' + (i === current ? ' active' : '');
      d.title = 'Go to slide ' + (i + 1);
      d.onclick = () => showSlide(i);
      dotsContainer.appendChild(d);
      dotEls.push(d);
    }

    // Set total count
    document.getElementById('slidesNavTotal').textContent = total;
    document.getElementById('slidesNavCur').textContent = current + 1;

    // Initial notes
    const notesContentEl = document.getElementById('slidesNavNotesContent');
    notesContentEl.textContent = NOTES[current] || '';

    function showSlide(n) {
      slides.forEach(s => s.classList.remove('active'));
      dotEls.forEach(d => d.classList.remove('active'));
      current = ((n % total) + total) % total;
      slides[current].classList.add('active');
      dotEls[current].classList.add('active');
      document.getElementById('slidesNavCur').textContent = current + 1;
      notesContentEl.textContent = NOTES[current] || '';
      window.slidesNav.current = current;
    }
    function nextSlide() { showSlide(current + 1); }
    function prevSlide() { showSlide(current - 1); }
    function toggleNotes() {
      document.getElementById('slidesNavNotes').classList.toggle('show');
    }
    function toggleFullscreen() {
      if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen().catch(err => {
          console.warn('[multiply_slides_nav] Fullscreen request failed:', err);
        });
      } else {
        document.exitFullscreen();
      }
    }

    // Wire up buttons
    document.getElementById('slidesNavPrev').onclick = prevSlide;
    document.getElementById('slidesNavNext').onclick = nextSlide;
    document.getElementById('slidesNavNotesBtn').onclick = toggleNotes;
    document.getElementById('slidesNavFs').onclick = toggleFullscreen;

    // Keyboard
    document.addEventListener('keydown', (e) => {
      // Ignore if user is typing in an input/textarea
      const tag = (e.target.tagName || '').toLowerCase();
      if (tag === 'input' || tag === 'textarea') return;

      if (e.key === 'ArrowRight' || e.key === ' ' || e.key === 'PageDown') {
        e.preventDefault(); nextSlide();
      } else if (e.key === 'ArrowLeft' || e.key === 'PageUp') {
        e.preventDefault(); prevSlide();
      } else if (e.key === 'Home') {
        e.preventDefault(); showSlide(0);
      } else if (e.key === 'End') {
        e.preventDefault(); showSlide(total - 1);
      } else if (e.key === 'n' || e.key === 'N') {
        toggleNotes();
      } else if (e.key === 'f' || e.key === 'F') {
        toggleFullscreen();
      }
    });

    // Touch swipe
    let touchStartX = null;
    let touchStartY = null;
    document.addEventListener('touchstart', (e) => {
      touchStartX = e.touches[0].clientX;
      touchStartY = e.touches[0].clientY;
    }, { passive: true });
    document.addEventListener('touchend', (e) => {
      if (touchStartX === null) return;
      const dx = e.changedTouches[0].clientX - touchStartX;
      const dy = e.changedTouches[0].clientY - touchStartY;
      // Require horizontal dominance to avoid hijacking scrolling
      if (Math.abs(dx) > 50 && Math.abs(dx) > Math.abs(dy)) {
        if (dx < 0) nextSlide(); else prevSlide();
      }
      touchStartX = null;
      touchStartY = null;
    }, { passive: true });

    // Expose globals
    window.slidesNav = {
      showSlide: showSlide,
      nextSlide: nextSlide,
      prevSlide: prevSlide,
      toggleNotes: toggleNotes,
      toggleFullscreen: toggleFullscreen,
      get current() { return current; },
      total: total
    };
  }

  function escapeHtml(s) {
    return String(s)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }

  // ── Boot ────────────────────────────────────────────────────────────
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
      injectMarkup();
      init();
    });
  } else {
    injectMarkup();
    init();
  }
})();
