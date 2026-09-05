/* ===========================================================================
   ORBIT — ring.js
   Small, dependency-free behaviour for the smart-ring site.
   =========================================================================== */
(function () {
  'use strict';

  var $  = function (s, c) { return (c || document).querySelector(s); };
  var $$ = function (s, c) { return Array.prototype.slice.call((c || document).querySelectorAll(s)); };

  document.documentElement.classList.remove('no-js');

  /* --- header shadow once scrolled ------------------------------------- */
  var header = $('.header');
  if (header) {
    var onScrollHeader = function () {
      header.classList.toggle('is-stuck', window.scrollY > 8);
    };
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
    burger.addEventListener('click', function () {
      setMenu(!menu.classList.contains('is-open'));
    });
    /* follow a link, close the menu */
    $$('a', menu).forEach(function (a) {
      a.addEventListener('click', function () { setMenu(false); });
    });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') setMenu(false);
    });
    /* a resize into desktop layout should not leave the body locked */
    window.addEventListener('resize', function () {
      if (window.innerWidth >= 900) setMenu(false);
    });
  }

  /* --- FAQ accordion ---------------------------------------------------- */
  $$('.faq__btn').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var item = btn.closest('.faq__item');
      var open = !item.classList.contains('is-open');
      item.classList.toggle('is-open', open);
      btn.setAttribute('aria-expanded', String(open));
    });
  });

  /* --- counters --------------------------------------------------------- */
  /* Numbers count up once, when they first come into view. */
  var counters = $$('[data-count]');

  function finalValue(el) {
    var target = parseFloat(el.getAttribute('data-count'));
    var suffix = el.getAttribute('data-suffix') || '';
    var dec    = (el.getAttribute('data-dec') | 0);
    return target.toFixed(dec) + suffix;
  }

  var runCounter = function (el) {
    if (el.dataset.started) return;
    el.dataset.started = '1';

    var target = parseFloat(el.getAttribute('data-count'));
    var suffix = el.getAttribute('data-suffix') || '';
    var dec    = (el.getAttribute('data-dec') | 0);
    var dur    = 1100;
    var t0     = null;

    /* requestAnimationFrame stops being served whenever the page is not
       painting — a background tab, an embedded frame, a throttled browser.
       Left alone that freezes the number partway, showing "2" where it
       should read "7", which is worse than never animating. This timer
       writes the true value regardless of whether the frames arrived. */
    var settle = setTimeout(function () {
      el.textContent = finalValue(el);
      el.dataset.done = '1';
    }, dur + 260);

    var tick = function (t) {
      if (t0 === null) t0 = t;
      var p = Math.min((t - t0) / dur, 1);
      var eased = 1 - Math.pow(1 - p, 3);
      el.textContent = (target * eased).toFixed(dec) + suffix;
      if (p < 1) {
        requestAnimationFrame(tick);
      } else {
        clearTimeout(settle);
        el.textContent = finalValue(el);
        el.dataset.done = '1';
      }
    };
    requestAnimationFrame(tick);
  };

  /* --- reveal on scroll -------------------------------------------------
     IntersectionObserver first, then a geometry backstop on scroll, then a
     hard failsafe. A missed callback must never leave a section invisible. */
  var reduce  = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var reveals = $$('.reveal');

  function showAll() {
    reveals.forEach(function (el) { el.classList.add('is-in'); });
    /* Anything that never finished counting gets its real value written now. */
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
      $$('.reveal', g).forEach(function (el, i) {
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
        if (el.dataset.done) return;
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
    setTimeout(showAll, 4000);      /* nothing stays hidden, whatever happens */
  }

  /* --- gallery (product page only) -------------------------------------
     Phone: a swipe carousel with arrows, a counter and a thumbnail strip.
     Desktop: the thumbnails become a rail and the slides stack. */
  var gal = $('[data-gallery]');
  if (gal) {
    var stage   = $('[data-gallery-stage]', gal);
    var thumbs  = $$('[data-gallery-thumb]', gal);
    var prevBtn = $('[data-gallery-prev]', gal);
    var nextBtn = $('[data-gallery-next]', gal);
    var counter = $('[data-gallery-counter]', gal);
    var slides  = $$('.gallery__slide', gal);
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
      if (window.innerWidth >= 960) slides[i].scrollIntoView({ behavior: 'smooth', block: 'start' });
      else stage.scrollTo({ left: stage.clientWidth * i, behavior: 'smooth' });
      mark(i);
    }

    if (prevBtn) prevBtn.addEventListener('click', function () { goTo(current - 1); });
    if (nextBtn) nextBtn.addEventListener('click', function () { goTo(current + 1); });
    thumbs.forEach(function (t, i) { t.addEventListener('click', function () { goTo(i); }); });

    /* keep the indicator honest when the carousel is swiped */
    var st;
    stage.addEventListener('scroll', function () {
      clearTimeout(st);
      st = setTimeout(function () {
        if (window.innerWidth >= 960) return;
        mark(Math.round(stage.scrollLeft / stage.clientWidth));
      }, 90);
    }, { passive: true });

    mark(0);
  }

  /* --- variant selection + price ---------------------------------------- */
  $$('[data-optgroup]').forEach(function (group) {
    var opts = $$('button', group);
    opts.forEach(function (b) {
      b.addEventListener('click', function () {
        opts.forEach(function (o) {
          o.classList.remove('is-on');
          o.setAttribute('aria-checked', 'false');
        });
        b.classList.add('is-on');
        b.setAttribute('aria-checked', 'true');
        var label = group.parentElement && $('[data-optvalue]', group.parentElement);
        if (label) label.textContent = b.getAttribute('data-label') || b.textContent.trim();
      });
    });
  });

  /* --- quantity --------------------------------------------------------- */
  $$('[data-qty]').forEach(function (q) {
    var out  = $('[data-qty-val]', q);
    var minus = $('[data-qty-minus]', q);
    var plus  = $('[data-qty-plus]', q);
    var n = 1;
    var render = function () {
      out.textContent = n;
      if (minus) minus.disabled = (n <= 1);
    };
    if (minus) minus.addEventListener('click', function () { if (n > 1) { n--; render(); } });
    if (plus)  plus.addEventListener('click',  function () { if (n < 10) { n++; render(); } });
    render();
  });

  /* --- add to cart (static demo) ---------------------------------------- */
  var atc = $('[data-atc]');
  var toast = $('[data-toast]');
  if (atc && toast) {
    var hideT;
    atc.addEventListener('click', function () {
      toast.classList.add('is-on');
      clearTimeout(hideT);
      hideT = setTimeout(function () { toast.classList.remove('is-on'); }, 2600);
    });
  }

  /* --- year ------------------------------------------------------------- */
  $$('[data-year]').forEach(function (el) { el.textContent = new Date().getFullYear(); });
})();
