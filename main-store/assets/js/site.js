/* ===========================================================================
   KOSHA — site.js
   Site-wide behaviour: header scroll state, mega menu, mobile drawer,
   cart drawer + localStorage cart, scroll reveal, toast, year stamp.

   Written as plain ES2019 with no build step and no dependencies, so it
   drops straight into a Shopify theme's assets/ folder later on.
   =========================================================================== */
(function () {
  'use strict';

  document.documentElement.classList.remove('no-js');

  var $  = function (s, c) { return (c || document).querySelector(s); };
  var $$ = function (s, c) { return Array.prototype.slice.call((c || document).querySelectorAll(s)); };

  /* =========================================================================
     CART
     A tiny localStorage cart so the store is genuinely clickable offline.
     On Shopify this whole object is replaced by calls to /cart/add.js etc.
     Line item shape: { id, title, variant, price, qty, img, url }
     ========================================================================= */
  var Cart = {
    KEY: 'kosha.cart.v1',
    items: [],

    load: function () {
      try { this.items = JSON.parse(localStorage.getItem(this.KEY)) || []; }
      catch (e) { this.items = []; }
      if (!Array.isArray(this.items)) this.items = [];
      return this.items;
    },
    save: function () {
      try { localStorage.setItem(this.KEY, JSON.stringify(this.items)); } catch (e) {}
      this.render();
    },
    key: function (it) { return it.id + '::' + (it.variant || ''); },

    add: function (item) {
      var k = this.key(item);
      var found = null;
      for (var i = 0; i < this.items.length; i++) {
        if (this.key(this.items[i]) === k) { found = this.items[i]; break; }
      }
      if (found) found.qty += (item.qty || 1);
      else this.items.push({
        id: item.id, title: item.title, variant: item.variant || '',
        price: Number(item.price) || 0, qty: item.qty || 1,
        img: item.img || '', url: item.url || '#'
      });
      this.save();
    },
    setQty: function (idx, q) {
      if (!this.items[idx]) return;
      if (q <= 0) this.items.splice(idx, 1);
      else this.items[idx].qty = Math.min(q, 99);
      this.save();
    },
    remove: function (idx) { this.items.splice(idx, 1); this.save(); },

    count: function () {
      return this.items.reduce(function (n, i) { return n + i.qty; }, 0);
    },
    total: function () {
      return this.items.reduce(function (n, i) { return n + i.price * i.qty; }, 0);
    },

    render: function () {
      var n = this.count();

      $$('[data-cart-count]').forEach(function (el) {
        el.textContent = n;
        el.classList.toggle('is-on', n > 0);
      });

      var body = $('[data-cart-body]');
      var foot = $('[data-cart-foot]');
      if (!body) return;

      if (!this.items.length) {
        body.innerHTML =
          '<div class="cart-empty">' +
            '<p class="t-h4">Your bag is empty</p>' +
            '<p class="t-meta">Nothing here yet — start with the new arrivals.</p>' +
            '<a class="btn btn--ghost" href="' + (window.KOSHA_ROOT || '') + 'index.html#categories">Browse categories</a>' +
          '</div>';
        if (foot) foot.hidden = true;
        return;
      }

      if (foot) foot.hidden = false;
      body.innerHTML = this.items.map(function (it, i) {
        return '' +
        '<div class="cart-line">' +
          '<a href="' + it.url + '" class="media ar-1-1" style="border-radius:3px">' +
            (it.img ? '<img src="' + it.img + '" alt="" loading="lazy">' : '') +
          '</a>' +
          '<div class="cart-line__body">' +
            '<a href="' + it.url + '" class="cart-line__title">' + it.title + '</a>' +
            (it.variant ? '<span class="cart-line__meta">' + it.variant + '</span>' : '') +
            '<div class="cart-line__foot">' +
              '<div class="qty qty--sm" data-cart-qty="' + i + '">' +
                '<button type="button" data-step="-1" aria-label="Decrease quantity">' + ICON.minus + '</button>' +
                '<span class="qty__val">' + it.qty + '</span>' +
                '<button type="button" data-step="1" aria-label="Increase quantity">' + ICON.plus + '</button>' +
              '</div>' +
              '<span class="num">' + money(it.price * it.qty) + '</span>' +
            '</div>' +
            '<button type="button" class="cart-line__rm" data-cart-remove="' + i + '">Remove</button>' +
          '</div>' +
        '</div>';
      }).join('');

      var tot = $('[data-cart-total]');
      if (tot) tot.textContent = money(this.total());
    }
  };

  var ICON = {
    minus: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M5 12h14"/></svg>',
    plus:  '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>',
    check: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6L9 17l-5-5"/></svg>'
  };

  /* Indian rupee formatting, no decimals — matches how prices read locally. */
  function money(n) {
    return '₹' + Math.round(n).toLocaleString('en-IN');
  }
  window.KOSHA_money = money;

  /* =========================================================================
     HEADER — solidify on scroll
     ========================================================================= */
  var header = $('[data-header]');
  if (header) {
    var stuck = false;
    var onScroll = function () {
      var s = window.scrollY > 12;
      if (s !== stuck) { stuck = s; header.classList.toggle('is-stuck', s); }
    };
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });
  }

  /* =========================================================================
     MEGA MENU — hover on pointer devices, click for keyboard/touch
     ========================================================================= */
  var megaTimer;
  $$('[data-mega-item]').forEach(function (item) {
    var trigger = $('[data-mega-trigger]', item);
    if (!trigger) return;

    var open  = function () {
      clearTimeout(megaTimer);
      $$('[data-mega-item]').forEach(function (o) { if (o !== item) o.classList.remove('is-open'); });
      item.classList.add('is-open');
      trigger.setAttribute('aria-expanded', 'true');
    };
    var close = function () {
      item.classList.remove('is-open');
      trigger.setAttribute('aria-expanded', 'false');
    };

    if (window.matchMedia('(hover: hover)').matches) {
      item.addEventListener('mouseenter', open);
      item.addEventListener('mouseleave', function () { megaTimer = setTimeout(close, 90); });
    }
    trigger.addEventListener('click', function (e) {
      e.preventDefault();
      item.classList.contains('is-open') ? close() : open();
    });
    item.addEventListener('focusout', function (e) {
      if (!item.contains(e.relatedTarget)) close();
    });
  });

  /* =========================================================================
     DRAWERS (mobile nav + cart) and the shared scrim
     ========================================================================= */
  var scrim = $('[data-scrim]');
  var openDrawer = null;

  function drawerOpen(el) {
    if (!el) return;
    if (openDrawer && openDrawer !== el) openDrawer.classList.remove('is-open');
    el.classList.add('is-open');
    el.setAttribute('aria-hidden', 'false');
    if (scrim) scrim.classList.add('is-on');
    document.body.classList.add('is-locked');
    openDrawer = el;
    var focusable = el.querySelector('button, a, input');
    if (focusable) setTimeout(function () { focusable.focus(); }, 260);
  }
  function drawerClose() {
    if (openDrawer) {
      openDrawer.classList.remove('is-open');
      openDrawer.setAttribute('aria-hidden', 'true');
    }
    openDrawer = null;
    if (scrim) scrim.classList.remove('is-on');
    document.body.classList.remove('is-locked');
    $$('[data-burger]').forEach(function (b) { b.setAttribute('aria-expanded', 'false'); });
  }
  window.KOSHA_drawerClose = drawerClose;

  $$('[data-drawer-open]').forEach(function (btn) {
    btn.addEventListener('click', function (e) {
      e.preventDefault();
      var target = $('#' + btn.getAttribute('data-drawer-open'));
      var isOpen = target && target.classList.contains('is-open');
      if (isOpen) { drawerClose(); return; }
      drawerOpen(target);
      if (btn.hasAttribute('data-burger')) btn.setAttribute('aria-expanded', 'true');
    });
  });
  $$('[data-drawer-close]').forEach(function (b) { b.addEventListener('click', drawerClose); });
  if (scrim) scrim.addEventListener('click', drawerClose);
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') {
      drawerClose();
      $$('[data-mega-item]').forEach(function (o) { o.classList.remove('is-open'); });
    }
  });

  /* --- mobile nav accordions --- */
  $$('[data-mnav-toggle]').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var item = btn.closest('.mnav__item');
      var isOpen = item.classList.contains('is-open');
      $$('.mnav__item').forEach(function (i) { i.classList.remove('is-open'); });
      if (!isOpen) item.classList.add('is-open');
      btn.setAttribute('aria-expanded', String(!isOpen));
    });
  });

  /* =========================================================================
     CART EVENTS (delegated — the drawer's contents are re-rendered)
     ========================================================================= */
  document.addEventListener('click', function (e) {
    var rm = e.target.closest('[data-cart-remove]');
    if (rm) { Cart.remove(Number(rm.getAttribute('data-cart-remove'))); return; }

    var step = e.target.closest('[data-cart-qty] button');
    if (step) {
      var wrap = step.closest('[data-cart-qty]');
      var idx  = Number(wrap.getAttribute('data-cart-qty'));
      Cart.setQty(idx, Cart.items[idx].qty + Number(step.getAttribute('data-step')));
      return;
    }

    /* quick-add straight from a product card */
    var quick = e.target.closest('[data-quick-add]');
    if (quick) {
      e.preventDefault();
      Cart.add({
        id:      quick.getAttribute('data-id'),
        title:   quick.getAttribute('data-title'),
        variant: quick.getAttribute('data-variant') || '',
        price:   quick.getAttribute('data-price'),
        img:     quick.getAttribute('data-img'),
        url:     quick.getAttribute('data-url') || '#',
        qty: 1
      });
      toast('Added to bag');
      drawerOpen($('#cart-drawer'));
    }
  });

  /* =========================================================================
     TOAST
     ========================================================================= */
  var toastEl, toastTimer;
  function toast(msg) {
    if (!toastEl) {
      toastEl = document.createElement('div');
      toastEl.className = 'toast';
      toastEl.setAttribute('role', 'status');
      document.body.appendChild(toastEl);
    }
    toastEl.innerHTML = ICON.check + '<span>' + msg + '</span>';
    requestAnimationFrame(function () { toastEl.classList.add('is-on'); });
    clearTimeout(toastTimer);
    toastTimer = setTimeout(function () { toastEl.classList.remove('is-on'); }, 2600);
  }
  window.KOSHA_toast = toast;
  window.KOSHA_cart  = Cart;

  /* =========================================================================
     SCROLL REVEAL
     Elements marked .reveal fade up once as they enter view. Children of a
     [data-reveal-group] are staggered automatically.
     ========================================================================= */
  var reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var reveals = $$('.reveal');

  function revealAll() {
    reveals.forEach(function (el) { el.classList.add('is-in'); });
  }

  if (!reveals.length) {
    /* nothing to do */
  } else if (reduce) {
    revealAll();
  } else {
    /* stagger children of a group so a row arrives in sequence */
    $$('[data-reveal-group]').forEach(function (group) {
      var step = Number(group.getAttribute('data-reveal-step')) || 70;
      $$('.reveal', group).forEach(function (el, i) {
        el.style.setProperty('--reveal-delay', (i * step) + 'ms');
      });
    });

    /* Primary: IntersectionObserver. */
    var io = null;
    if ('IntersectionObserver' in window) {
      io = new IntersectionObserver(function (entries) {
        entries.forEach(function (en) {
          if (en.isIntersecting) { en.target.classList.add('is-in'); io.unobserve(en.target); }
        });
      }, { rootMargin: '0px 0px -8% 0px', threshold: 0.05 });
      reveals.forEach(function (el) { io.observe(el); });
    }

    /* Backstop: a plain geometry check on scroll and resize.
       IntersectionObserver is throttled or suppressed in some contexts
       (background tabs, embedded frames, a few older mobile browsers), and a
       missed callback would leave a whole section permanently invisible.
       This costs almost nothing and removes that failure mode. */
    var ticking = false;
    function sweep() {
      ticking = false;
      var h = window.innerHeight || document.documentElement.clientHeight;
      var remaining = false;
      reveals.forEach(function (el) {
        if (el.classList.contains('is-in')) return;
        var r = el.getBoundingClientRect();
        if (r.top < h * 0.94 && r.bottom > 0) {
          el.classList.add('is-in');
          if (io) io.unobserve(el);
        } else {
          remaining = true;
        }
      });
      if (!remaining) {
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
    sweep();                       /* catch whatever is already on screen */
    setTimeout(sweep, 400);        /* again once images have laid out */

    /* Last resort: never leave content invisible. If anything is still
       hidden after 4s — whatever the reason — just show it. */
    setTimeout(revealAll, 4000);
  }

  /* =========================================================================
     MISC
     ========================================================================= */
  $$('[data-year]').forEach(function (el) { el.textContent = new Date().getFullYear(); });

  /* newsletter + contact forms are static demos — acknowledge, don't submit */
  $$('[data-demo-form]').forEach(function (form) {
    form.addEventListener('submit', function (e) {
      e.preventDefault();
      toast(form.getAttribute('data-demo-form') || 'Thanks — we’ll be in touch.');
      form.reset();
    });
  });

  Cart.load();
  Cart.render();
})();
