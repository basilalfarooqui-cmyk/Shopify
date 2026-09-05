/* ===========================================================================
   Shared behaviour for the Phase 3 category variations.

   Only behaviour lives here — never appearance. Every design brings its own
   stylesheet and its own markup; this file just makes the common mechanics
   work the same way, because they are the parts that were hardest to get
   right and are worth not re-deriving twenty-eight times:

     - a scroll reveal that CANNOT leave content permanently invisible
     - a gallery that is a swipe carousel on a phone and a stack on desktop
     - counters that always land on their true value
     - menu, accordion, option groups, quantity, add-to-bag toast

   Hooks are all data-attributes, so a design can lay these out however it
   likes and still get the behaviour.
   =========================================================================== */
(function () {
  'use strict';

  var $  = function (s, c) { return (c || document).querySelector(s); };
  var $$ = function (s, c) { return Array.prototype.slice.call((c || document).querySelectorAll(s)); };

  document.documentElement.classList.remove('no-js');

  var reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* --- sticky header state --------------------------------------------- */
  var header = $('[data-header]');
  if (header) {
    var onScrollHeader = function () { header.classList.toggle('is-stuck', window.scrollY > 8); };
    window.addEventListener('scroll', onScrollHeader, { passive: true });
    onScrollHeader();
  }

  /* --- mobile menu ------------------------------------------------------ */
  var burger = $('[data-burger]');
  var menu   = $('[data-menu]');
  if (burger && menu) {
    var setMenu = function (open) {
      burger.classList.toggle('is-open', open);
      menu.classList.toggle('is-open', open);
      burger.setAttribute('aria-expanded', String(open));
      document.body.style.overflow = open ? 'hidden' : '';
    };
    burger.addEventListener('click', function () { setMenu(!menu.classList.contains('is-open')); });
    $$('a', menu).forEach(function (a) { a.addEventListener('click', function () { setMenu(false); }); });
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape') setMenu(false); });
    window.addEventListener('resize', function () { if (window.innerWidth >= 900) setMenu(false); });
  }

  /* --- accordions ------------------------------------------------------- */
  $$('[data-acc-btn]').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var item = btn.closest('[data-acc-item]');
      var open = !item.classList.contains('is-open');
      item.classList.toggle('is-open', open);
      btn.setAttribute('aria-expanded', String(open));
    });
  });

  /* --- counters ---------------------------------------------------------
     rAF is not delivered while a page is not painting (background tab,
     embedded frame, throttled browser). Without a guard the number freezes
     partway and shows something false, so a timer writes the real value
     whether or not the frames ever arrived. */
  var counters = $$('[data-count]');

  /* Large figures are unreadable without separators — "180000 sold" makes a
     reader stop and count digits, which is the opposite of what a proof
     number is for. Grouping is applied above 9,999 only, so a year or a
     quantity like 2026 or 4128 is left alone unless asked for. */
  function groupThousands(s, force) {
    var parts = s.split('.');
    if (force || Math.abs(parseFloat(parts[0])) > 9999) {
      parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    }
    return parts.join('.');
  }

  function format(el, value) {
    var dec    = (el.getAttribute('data-dec') | 0);
    var suffix = el.getAttribute('data-suffix') || '';
    var group  = el.hasAttribute('data-group');
    return groupThousands(value.toFixed(dec), group) + suffix;
  }

  function finalValue(el) {
    return format(el, parseFloat(el.getAttribute('data-count')));
  }

  function runCounter(el) {
    if (el.dataset.started) return;
    el.dataset.started = '1';
    var target = parseFloat(el.getAttribute('data-count'));
    var dur = 1100, t0 = null;

    var settle = setTimeout(function () {
      el.textContent = finalValue(el);
      el.dataset.done = '1';
    }, dur + 260);

    (function tick(t) {
      if (t0 === null) t0 = t;
      var p = Math.min((t - t0) / dur, 1);
      var eased = 1 - Math.pow(1 - p, 3);
      el.textContent = format(el, target * eased);
      if (p < 1) requestAnimationFrame(tick);
      else { clearTimeout(settle); el.textContent = finalValue(el); el.dataset.done = '1'; }
    })(performance.now());
  }

  /* --- reveal on scroll -------------------------------------------------
     Observer first, geometry backstop second, hard failsafe third. A missed
     callback must never leave a whole section invisible. */
  var reveals = $$('[data-reveal]');

  function showAll() {
    reveals.forEach(function (el) { el.classList.add('is-in'); });
    counters.forEach(function (el) {
      if (el.dataset.done) return;
      if (el.dataset.started) { el.textContent = finalValue(el); el.dataset.done = '1'; }
      else runCounter(el);
    });
  }

  if (reduce) {
    showAll();
  } else {
    $$('[data-reveal-group]').forEach(function (g) {
      var step = Number(g.getAttribute('data-reveal-step')) || 70;
      $$('[data-reveal]', g).forEach(function (el, i) {
        el.style.setProperty('--reveal-delay', (i * step) + 'ms');
      });
    });

    var io = null;
    if ('IntersectionObserver' in window) {
      io = new IntersectionObserver(function (entries) {
        entries.forEach(function (en) {
          if (!en.isIntersecting) return;
          en.target.classList.add('is-in');
          if (en.target.hasAttribute('data-count')) runCounter(en.target);
          io.unobserve(en.target);
        });
      }, { rootMargin: '0px 0px -8% 0px', threshold: .05 });
      reveals.forEach(function (el) { io.observe(el); });
      counters.forEach(function (el) { io.observe(el); });
    }

    var ticking = false;
    function sweep() {
      ticking = false;
      var h = window.innerHeight || document.documentElement.clientHeight;
      var left = false;
      reveals.forEach(function (el) {
        if (el.classList.contains('is-in')) return;
        var r = el.getBoundingClientRect();
        if (r.top < h * 0.94 && r.bottom > 0) { el.classList.add('is-in'); if (io) io.unobserve(el); }
        else left = true;
      });
      counters.forEach(function (el) {
        if (el.dataset.started) return;
        var r = el.getBoundingClientRect();
        if (r.top < h * 0.94 && r.bottom > 0) runCounter(el);
      });
      if (!left) {
        window.removeEventListener('scroll', onScrollReveal);
        window.removeEventListener('resize', onScrollReveal);
      }
    }
    function onScrollReveal() {
      if (ticking) return;
      ticking = true;
      requestAnimationFrame(sweep);
    }
    window.addEventListener('scroll', onScrollReveal, { passive: true });
    window.addEventListener('resize', onScrollReveal, { passive: true });
    sweep();
    setTimeout(sweep, 400);
    setTimeout(showAll, 4000);
  }

  /* --- gallery ----------------------------------------------------------
     Phone: swipe carousel + arrows + counter + thumbnail strip.
     Desktop: the slides stack and the thumbnails become a rail.
     A design controls which of those it wants purely through CSS. */
  $$('[data-gallery]').forEach(function (gal) {
    var stage   = $('[data-gallery-stage]', gal);
    if (!stage) return;
    var thumbs  = $$('[data-gallery-thumb]', gal);
    var prevBtn = $('[data-gallery-prev]', gal);
    var nextBtn = $('[data-gallery-next]', gal);
    var counter = $('[data-gallery-counter]', gal);
    var slides  = $$('[data-gallery-slide]', gal);
    var current = 0;

    function mark(i) {
      current = i;
      thumbs.forEach(function (t, n) {
        t.classList.toggle('is-on', n === i);
        t.setAttribute('aria-selected', String(n === i));
      });
      if (counter) counter.textContent = (i + 1) + ' / ' + slides.length;
      if (prevBtn) prevBtn.disabled = (i <= 0);
      if (nextBtn) nextBtn.disabled = (i >= slides.length - 1);

      var t = thumbs[i];
      if (t && t.parentElement && t.parentElement.scrollWidth > t.parentElement.clientWidth) {
        var p = t.parentElement, tl = t.offsetLeft, tr = tl + t.offsetWidth;
        if (tl < p.scrollLeft) p.scrollTo({ left: tl - 8, behavior: 'smooth' });
        else if (tr > p.scrollLeft + p.clientWidth) p.scrollTo({ left: tr - p.clientWidth + 8, behavior: 'smooth' });
      }
    }

    function goTo(i) {
      i = Math.max(0, Math.min(i, slides.length - 1));
      /* If the stage is no longer a horizontal scroller (desktop stacking),
         scroll the slide into view instead of moving the carousel. */
      if (stage.scrollWidth <= stage.clientWidth + 2) slides[i].scrollIntoView({ behavior: 'smooth', block: 'start' });
      else stage.scrollTo({ left: stage.clientWidth * i, behavior: 'smooth' });
      mark(i);
    }

    if (prevBtn) prevBtn.addEventListener('click', function () { goTo(current - 1); });
    if (nextBtn) nextBtn.addEventListener('click', function () { goTo(current + 1); });
    thumbs.forEach(function (t, i) { t.addEventListener('click', function () { goTo(i); }); });

    var st;
    stage.addEventListener('scroll', function () {
      clearTimeout(st);
      st = setTimeout(function () {
        if (stage.scrollWidth <= stage.clientWidth + 2) return;
        mark(Math.round(stage.scrollLeft / stage.clientWidth));
      }, 90);
    }, { passive: true });

    mark(0);
  });

  /* --- option groups ---------------------------------------------------- */
  $$('[data-optgroup]').forEach(function (group) {
    var opts = $$('button', group);
    opts.forEach(function (b) {
      b.addEventListener('click', function () {
        opts.forEach(function (o) { o.classList.remove('is-on'); o.setAttribute('aria-checked', 'false'); });
        b.classList.add('is-on');
        b.setAttribute('aria-checked', 'true');
        var out = group.getAttribute('data-optout');
        var label = out ? $(out) : null;
        if (label) label.textContent = b.getAttribute('data-label') || b.textContent.trim();
      });
    });
  });

  /* --- quantity --------------------------------------------------------- */
  $$('[data-qty]').forEach(function (q) {
    var out = $('[data-qty-val]', q);
    var minus = $('[data-qty-minus]', q);
    var plus  = $('[data-qty-plus]', q);
    var n = 1;
    var render = function () { out.textContent = n; if (minus) minus.disabled = (n <= 1); };
    if (minus) minus.addEventListener('click', function () { if (n > 1) { n--; render(); } });
    if (plus)  plus.addEventListener('click',  function () { if (n < 10) { n++; render(); } });
    render();
  });

  /* --- add to bag (static demo) ----------------------------------------- */
  var toast = $('[data-toast]');
  if (toast) {
    var hideT;
    $$('[data-atc]').forEach(function (btn) {
      btn.addEventListener('click', function () {
        toast.classList.add('is-on');
        clearTimeout(hideT);
        hideT = setTimeout(function () { toast.classList.remove('is-on'); }, 2600);
      });
    });
  }

  /* --- sticky buy bar ---------------------------------------------------
     Appears once the primary call to action has scrolled out of view, and
     hides again when it comes back, so a long page never leaves the button
     out of reach on a phone. Opt in with [data-stickybuy] plus a
     [data-stickybuy-after] element to watch. */
  var sticky = $('[data-stickybuy]');
  var after  = $('[data-stickybuy-after]');
  if (sticky && after) {
    var showSticky = function (on) { sticky.classList.toggle('is-on', on); };

    if ('IntersectionObserver' in window) {
      new IntersectionObserver(function (entries) {
        entries.forEach(function (en) { showSticky(!en.isIntersecting && en.boundingClientRect.top < 0); });
      }, { threshold: 0 }).observe(after);
    }

    /* Geometry fallback, for the same reason the reveal has one: a missed
       observer callback would leave the bar either stuck open or never shown. */
    var stickTick = false;
    var stickSweep = function () {
      stickTick = false;
      var r = after.getBoundingClientRect();
      showSticky(r.bottom < 0);
    };
    window.addEventListener('scroll', function () {
      if (stickTick) return;
      stickTick = true;
      requestAnimationFrame(stickSweep);
    }, { passive: true });
    stickSweep();
  }

  /* --- year ------------------------------------------------------------- */
  $$('[data-year]').forEach(function (el) { el.textContent = new Date().getFullYear(); });
})();
