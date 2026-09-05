/* ===========================================================================
   audit.js — responsive breakage audit, run inside the page.

   Screenshots hide the things that actually break a phone layout, so this
   measures them instead. Paste/inject into a page and call:

       __audit()

   Checks, in order of how often they bite:
     1. horizontal overflow  — the page scrolls sideways (worst offender)
     2. escaping elements    — anything sticking out past the viewport
     3. tap targets          — interactive things under 44x44 CSS px
     4. text clipping        — content cut off by a fixed height
     5. sticky/fixed cover   — bars eating more than a third of the screen
     6. images               — broken or still-unloaded sources
     7. tiny text            — anything under 12px

   Returns a plain object so it can be read straight out of the console.
   =========================================================================== */
window.__audit = function () {
  var vw = document.documentElement.clientWidth;
  var vh = document.documentElement.clientHeight;
  var out = {
    url: location.pathname,
    viewport: vw + 'x' + vh,
    pass: true,
    overflow: null,
    escaping: [],
    smallTaps: [],
    clipped: [],
    stickyCover: [],
    badImages: [],
    tinyText: []
  };

  /* An element that pokes past the viewport is harmless if an ancestor clips
     it — a zooming hero image inside overflow:hidden, say. Only report things
     that are genuinely visible outside the fold. */
  var isClippedByAncestor = function (el) {
    var p = el.parentElement;
    while (p && p !== document.body) {
      var cs = getComputedStyle(p);
      if (/hidden|clip|auto|scroll/.test(cs.overflowX) || /hidden|clip|auto|scroll/.test(cs.overflow)) {
        var pr = p.getBoundingClientRect();
        if (pr.right <= vw + 1 && pr.left >= -1) return true;
      }
      p = p.parentElement;
    }
    return false;
  };

  /* Visually-hidden helpers are 1px on purpose. */
  var isVisuallyHidden = function (el) {
    if (el.classList.contains('sr-only')) return true;
    var r = el.getBoundingClientRect();
    return (r.width <= 1 || r.height <= 1);
  };

  var label = function (el) {
    var s = el.tagName.toLowerCase();
    if (el.id) s += '#' + el.id;
    if (el.className && typeof el.className === 'string') {
      s += '.' + el.className.trim().split(/\s+/).slice(0, 3).join('.');
    }
    var t = (el.textContent || '').trim().replace(/\s+/g, ' ').slice(0, 40);
    if (t) s += '  "' + t + '"';
    return s;
  };

  /* --- 1. does the document scroll sideways? ---------------------------- */
  var docW = document.documentElement.scrollWidth;
  if (docW > vw + 1) {
    out.pass = false;
    out.overflow = { scrollWidth: docW, viewport: vw, by: docW - vw };
  }

  /* --- 2 & 3 & 7. walk everything once ---------------------------------- */
  var all = document.querySelectorAll('body *');
  var seen = 0;

  for (var i = 0; i < all.length; i++) {
    var el = all[i];
    var cs = getComputedStyle(el);
    if (cs.display === 'none' || cs.visibility === 'hidden' || cs.opacity === '0') continue;

    var r = el.getBoundingClientRect();
    if (r.width === 0 && r.height === 0) continue;
    seen++;

    /* elements poking out past the right edge (or off the left) */
    if (r.right > vw + 1 || r.left < -1) {
      /* ignore deliberate edge-to-edge scrollers and decorative overflow */
      var scroller = el.closest('[data-gallery-stage], .rail, .announce, .drawer, .scrim');
      var isOffscreenByDesign = cs.position === 'fixed' &&
                                (el.classList.contains('drawer') || el.classList.contains('scrim'));
      if (!scroller && !isOffscreenByDesign && !isClippedByAncestor(el)) {
        out.escaping.push({
          el: label(el),
          left: Math.round(r.left),
          right: Math.round(r.right),
          overBy: Math.round(r.right - vw)
        });
      }
    }

    /* tap targets — interactive and too small for a thumb */
    var interactive = el.matches('a, button, [role="radio"], [role="tab"], input, select, textarea, [onclick]');
    if (interactive) {
      var tooSmall = (r.width < 44 || r.height < 44);
      /* inline links inside a paragraph are fine at text height */
      var inlineLink = el.tagName === 'A' && cs.display.indexOf('inline') === 0 &&
                       el.closest('p, li, .crumbs, .footer, .rv__body, .acc__panel');
      if (tooSmall && !inlineLink) {
        out.smallTaps.push({
          el: label(el),
          size: Math.round(r.width) + 'x' + Math.round(r.height)
        });
      }
    }

    /* text clipped by a fixed height */
    if (el.scrollHeight > el.clientHeight + 2 &&
        cs.overflowY === "hidden" &&
        el.clientHeight > 0 &&
        !isVisuallyHidden(el) &&
        (el.textContent || '').trim().length > 0 &&
        !el.closest('.acc__panel, .mnav__sub, .gallery, [data-gallery-stage]')) {
      out.clipped.push({
        el: label(el),
        visible: el.clientHeight,
        needs: el.scrollHeight
      });
    }

    /* text too small to read on a phone */
    var fs = parseFloat(cs.fontSize);
    if (fs && fs < 12 && (el.textContent || '').trim().length > 12 && el.children.length === 0) {
      out.tinyText.push({ el: label(el), size: fs + 'px' });
    }
  }

  /* --- 5. sticky / fixed chrome eating the screen ----------------------- */
  var fixedTotal = 0;
  document.querySelectorAll('body *').forEach(function (el) {
    var cs = getComputedStyle(el);
    if (cs.position !== 'fixed' && cs.position !== 'sticky') return;
    if (cs.display === 'none' || cs.visibility === 'hidden') return;
    var r = el.getBoundingClientRect();
    if (r.height === 0 || r.height > vh) return;
    /* Parked offscreen. `<= 0` matters: an off-canvas panel translated by
       exactly its own height lands with bottom === 0, and a strict `< 0`
       counted it as though it were covering the screen. */
    if (r.bottom <= 0 || r.top >= vh) return;
    /* Closed off-canvas panels are not chrome. */
    if (el.classList.contains('drawer') || el.classList.contains('scrim')) return;
    if (el.hasAttribute('data-menu') && !el.classList.contains('is-open')) return;
    /* Only full-width bars actually eat usable screen. A narrow sticky column
       — a thumbnail rail or a buy panel beside the content — does not, and
       counting its height here produced a false failure. */
    if (r.width < vw * 0.6) return;
    fixedTotal += r.height;
    out.stickyCover.push({ el: label(el), height: Math.round(r.height) });
  });
  out.fixedChromeHeight = Math.round(fixedTotal);
  out.fixedChromePct = Math.round((fixedTotal / vh) * 100);

  /* --- 6. images ------------------------------------------------------- */
  document.querySelectorAll('img').forEach(function (img) {
    if (!img.getAttribute('src')) {
      out.badImages.push({ el: label(img), why: 'no src' });
    } else if (img.complete && img.naturalWidth === 0) {
      out.badImages.push({ el: label(img), why: 'failed to load', src: img.getAttribute('src') });
    }
  });

  /* --- verdict --------------------------------------------------------- */
  out.elementsChecked = seen;
  if (out.escaping.length || out.clipped.length || out.badImages.length) out.pass = false;
  if (out.fixedChromePct > 34) out.pass = false;

  /* trim noisy lists so the result stays readable */
  ['escaping', 'smallTaps', 'clipped', 'tinyText', 'badImages'].forEach(function (k) {
    if (out[k].length > 8) {
      var n = out[k].length;
      out[k] = out[k].slice(0, 8);
      out[k].push('... and ' + (n - 8) + ' more');
    }
  });

  return out;
};
