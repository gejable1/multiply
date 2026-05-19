// ═══════════════════════════════════════════════════════════════
//  MULTIPLY · LESSON FONT SLIDER · shared module
//  ─────────────────────────────────────────────────────────────
//  Single source of truth for the A− / A+ font-scale toggle that
//  appears on lesson HTMLs (facilitator, intern, participant
//  surfaces). Extracted from the inline pattern that lives in
//  Usbong L1–L10 and BTLI L1–L3.
//
//  HOW TO USE in a lesson HTML:
//
//    1. Include the HTML widget where you want the slider visible
//       (anywhere on the page — header bar, mode-bar, font-bar
//       strip, etc.):
//
//         <div class="font-toggle" role="group" aria-label="Font size">
//           <button class="ft-btn ft-minus" id="ft-down"
//             onclick="changeFontScale(-1)"
//             aria-label="Decrease text size">A−</button>
//           <span class="ft-label" id="ft-label">100%</span>
//           <button class="ft-btn ft-plus" id="ft-up"
//             onclick="changeFontScale(1)"
//             aria-label="Increase text size">A+</button>
//         </div>
//
//    2. Include the styling (either inline in the page <style> or
//       via the shared stylesheet — kept inline by current convention
//       so each lesson can vary the wrapper to match its surface).
//
//    3. Load this script BEFORE </body>, passing a unique FONT_KEY
//       via the data-font-key attribute. Add ?v=N for cache-busting
//       when the slider's behavior changes:
//
//         <script src="multiply_lesson_slider.js?v=1"
//           data-font-key="btli1_l4_facilitator_fontscale"></script>
//
//       FONT_KEY convention: <curriculum>_l<N>_<role>_fontscale
//       Examples:
//         usbong_l1_facilitator_fontscale
//         btli1_l3_intern_fontscale
//         btli1_l4_participant_fontscale
//
//  Five-step scale: 90% / 100% / 110% / 125% / 140%.
//  Default index 1 (= 100%). Persists in localStorage per FONT_KEY.
//  Uses document.body.style.zoom — same approach as the inline
//  pattern. Same UX, just maintained in one place.
//
//  If data-font-key is missing, falls back to a generic key
//  ('multiply_lesson_fontscale_generic'). Slider still works; reader
//  preference just won't be lesson-scoped.
// ═══════════════════════════════════════════════════════════════

(function () {
  'use strict';

  // ─── Read FONT_KEY from this script tag's data-font-key attribute ───
  // We find ourselves via the currentScript reference (synchronous load)
  // or fall back to the last <script> on the page with data-font-key.
  function _resolveFontKey() {
    var self = document.currentScript;
    if (!self) {
      var all = document.querySelectorAll('script[data-font-key]');
      if (all.length) self = all[all.length - 1];
    }
    var key = self && self.getAttribute('data-font-key');
    return key || 'multiply_lesson_fontscale_generic';
  }

  var FONT_KEY = _resolveFontKey();
  var FONT_STEPS = [0.90, 1.00, 1.10, 1.25, 1.40]; // 90% to 140%
  var _fontIdx = 1; // default to 100%

  function applyFontScale() {
    var scale = FONT_STEPS[_fontIdx];
    document.body.style.zoom = scale;
    var lbl = document.getElementById('ft-label');
    if (lbl) lbl.textContent = Math.round(scale * 100) + '%';
    var dn = document.getElementById('ft-down');
    var up = document.getElementById('ft-up');
    if (dn) dn.disabled = (_fontIdx <= 0);
    if (up) up.disabled = (_fontIdx >= FONT_STEPS.length - 1);
  }

  // Expose globally so the inline onclick handlers on the buttons
  // can call them. Matches the inline pattern's surface area exactly.
  window.changeFontScale = function (direction) {
    _fontIdx = Math.max(0, Math.min(FONT_STEPS.length - 1, _fontIdx + direction));
    applyFontScale();
    try { localStorage.setItem(FONT_KEY, String(_fontIdx)); } catch (e) {}
  };

  // ─── Initialize on DOM ready (or immediately if already ready) ───
  function _init() {
    try {
      var saved = parseInt(localStorage.getItem(FONT_KEY), 10);
      if (!isNaN(saved) && saved >= 0 && saved < FONT_STEPS.length) {
        _fontIdx = saved;
      }
    } catch (e) {}
    applyFontScale();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', _init);
  } else {
    _init();
  }
})();
