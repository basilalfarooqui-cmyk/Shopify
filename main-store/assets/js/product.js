/* ===========================================================================
   KOSHA — product.js
   Product-detail behaviour: gallery (mobile carousel / desktop thumb strip),
   variant selection, quantity stepper, add-to-cart, accordions, and the
   sticky mobile buy bar.

   Loads after site.js and reuses its cart (window.KOSHA_cart).
   =========================================================================== */
(function () {
  'use strict';

  var $  = function (s, c) { return (c || document).querySelector(s); };
  var $$ = function (s, c) { return Array.prototype.slice.call((c || document).querySelectorAll(s)); };

  var root = $('[data-pdp]');
  if (!root) return;

  var Cart  = window.KOSHA_cart;
  var money = window.KOSHA_money;

  /* =========================================================================
     GALLERY
     One markup, two behaviours. On a phone the stage is a snap carousel and
     the dots track it; on desktop the stage is a stacked column and the
     thumbs scroll it into view.
     ========================================================================= */
  var stage   = $('[data-gallery-stage]', root);
  var dots    = $$('[data-gallery-dot]', root);
  var thumbs  = $$('[data-gallery-thumb]', root);
  var prevBtn = $('[data-gallery-prev]', root);
  var nextBtn = $('[data-gallery-next]', root);
  var counter = $('[data-gallery-counter]', root);
  var current = 0;

  function markActive(i) {
    current = i;
    dots.forEach(function (d, n) { d.classList.toggle('is-on', n === i); });
    thumbs.forEach(function (t, n) {
      t.classList.toggle('is-on', n === i);
      t.setAttribute('aria-selected', String(n === i));
    });

    var count = thumbs.length;
    if (counter) counter.textContent = (i + 1) + ' / ' + count;

    /* Arrows stop at the ends rather than wrapping — wrapping on a product
       gallery makes it hard to tell you have seen everything. */
    if (prevBtn) prevBtn.disabled = (i <= 0);
    if (nextBtn) nextBtn.disabled = (i >= count - 1);

    /* keep the active thumbnail in view in the horizontal strip */
    var t = thumbs[i];
    if (t && t.parentElement && t.parentElement.scrollWidth > t.parentElement.clientWidth) {
      var p = t.parentElement;
      var tl = t.offsetLeft, tr = tl + t.offsetWidth;
      if (tl < p.scrollLeft) p.scrollTo({ left: tl - 8, behavior: 'smooth' });
      else if (tr > p.scrollLeft + p.clientWidth) p.scrollTo({ left: tr - p.clientWidth + 8, behavior: 'smooth' });
    }
  }

  /* Move the carousel by n slides (phone), or scroll to that slide (desktop). */
  function goTo(i) {
    if (!stage) return;
    var slides = $$('.gallery__slide', stage);
    i = Math.max(0, Math.min(i, slides.length - 1));
    if (window.innerWidth >= 960) {
      slides[i].scrollIntoView({ behavior: 'smooth', block: 'start' });
    } else {
      stage.scrollTo({ left: stage.clientWidth * i, behavior: 'smooth' });
    }
    markActive(i);
  }

  if (prevBtn) prevBtn.addEventListener('click', function () { goTo(current - 1); });
  if (nextBtn) nextBtn.addEventListener('click', function () { goTo(current + 1); });

  if (stage) {
    var slides = $$('.gallery__slide', stage);

    /* mobile: which slide is centred */
    var raf;
    stage.addEventListener('scroll', function () {
      cancelAnimationFrame(raf);
      raf = requestAnimationFrame(function () {
        var i = Math.round(stage.scrollLeft / stage.clientWidth);
        markActive(Math.max(0, Math.min(i, slides.length - 1)));
      });
    }, { passive: true });

    /* desktop: which slide is in view */
    if ('IntersectionObserver' in window) {
      var vo = new IntersectionObserver(function (entries) {
        if (window.innerWidth < 960) return;
        entries.forEach(function (en) {
          if (en.isIntersecting && en.intersectionRatio > 0.55) {
            markActive(slides.indexOf(en.target));
          }
        });
      }, { threshold: [0.55] });
      slides.forEach(function (s) { vo.observe(s); });
    }

    thumbs.forEach(function (t, i) {
      t.addEventListener('click', function () { goTo(i); });
    });

    dots.forEach(function (d, i) {
      d.addEventListener('click', function () { goTo(i); });
    });

    markActive(0);
  }

  /* =========================================================================
     VARIANT OPTIONS
     Each [data-opt] group behaves like a radio group. The chosen values are
     joined into the variant string that goes onto the cart line — the same
     shape Shopify uses for variant titles ("Gold / 18 inch").
     ========================================================================= */
  function selectedVariant() {
    return $$('[data-opt]', root).map(function (group) {
      var on = $('[aria-checked="true"]', group);
      return on ? on.getAttribute('data-value') : '';
    }).filter(Boolean).join(' / ');
  }

  $$('[data-opt]', root).forEach(function (group) {
    var label = $('[data-opt-value]', group);
    var items = $$('[role="radio"]', group);

    function choose(el) {
      if (el.hasAttribute('data-soldout')) return;
      items.forEach(function (i) {
        var on = i === el;
        i.setAttribute('aria-checked', String(on));
        i.setAttribute('tabindex', on ? '0' : '-1');
      });
      if (label) label.textContent = el.getAttribute('data-value');
      updateBar();
    }

    items.forEach(function (el, i) {
      el.addEventListener('click', function () { choose(el); });
      el.addEventListener('keydown', function (e) {
        var next = null;
        if (e.key === 'ArrowRight' || e.key === 'ArrowDown') next = items[(i + 1) % items.length];
        if (e.key === 'ArrowLeft'  || e.key === 'ArrowUp')   next = items[(i - 1 + items.length) % items.length];
        if (e.key === ' ' || e.key === 'Enter') { e.preventDefault(); choose(el); }
        if (next) { e.preventDefault(); choose(next); next.focus(); }
      });
    });
  });

  /* =========================================================================
     QUANTITY
     ========================================================================= */
  var qtyWrap = $('[data-qty]', root);
  var qty = 1;
  function renderQty() {
    if (!qtyWrap) return;
    $('.qty__val', qtyWrap).textContent = qty;
    var minus = $('[data-step="-1"]', qtyWrap);
    if (minus) minus.disabled = qty <= 1;
  }
  if (qtyWrap) {
    $$('button', qtyWrap).forEach(function (b) {
      b.addEventListener('click', function () {
        qty = Math.max(1, Math.min(99, qty + Number(b.getAttribute('data-step'))));
        renderQty();
      });
    });
    renderQty();
  }

  /* =========================================================================
     ADD TO CART
     ========================================================================= */
  function currentLine() {
    return {
      id:      root.getAttribute('data-id'),
      title:   root.getAttribute('data-title'),
      price:   Number(root.getAttribute('data-price')),
      img:     root.getAttribute('data-img'),
      url:     window.location.pathname.split('/').pop(),
      variant: selectedVariant(),
      qty: qty
    };
  }

  $$('[data-atc]').forEach(function (btn) {
    btn.addEventListener('click', function () {
      Cart.add(currentLine());
      window.KOSHA_toast('Added to bag');

      /* brief confirmation state on the button itself */
      var original = btn.innerHTML;
      btn.innerHTML = 'Added ✓';
      btn.classList.add('is-disabled');
      setTimeout(function () {
        btn.innerHTML = original;
        btn.classList.remove('is-disabled');
      }, 1400);
    });
  });

  /* =========================================================================
     ACCORDIONS
     ========================================================================= */
  $$('[data-acc] .acc__btn').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var item = btn.closest('.acc__item');
      var open = item.classList.toggle('is-open');
      btn.setAttribute('aria-expanded', String(open));
    });
  });

  /* =========================================================================
     STICKY MOBILE BUY BAR
     Shows once the main buy button leaves the viewport, hides again at the
     very bottom so it never covers the footer links.
     ========================================================================= */
  var bar = $('[data-buybar]');
  var anchor = $('[data-buy-anchor]', root);
  if (bar && anchor && 'IntersectionObserver' in window) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (en) {
        bar.classList.toggle('is-on', !en.isIntersecting && en.boundingClientRect.top < 0);
      });
    }, { threshold: 0 });
    io.observe(anchor);
  }

  function updateBar() {
    if (!bar) return;
    var v = $('[data-buybar-variant]', bar);
    if (v) v.textContent = selectedVariant();
  }
  updateBar();

})();
