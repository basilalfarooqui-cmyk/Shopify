#!/usr/bin/env bash
# build-pdp.sh — generates the six main-store product pages.
#
#   bash tools/build-pdp.sh
#
# Why a generator: the brief asks for one professional structure across all six
# categories with a *different mood* per category. So the page skeleton lives
# here once (and maps cleanly onto a single Shopify product template later),
# while every category supplies its own theme class, photography, copy,
# options, specs, features, reviews and FAQ below.
#
# Re-running overwrites main-store/products/*.html.
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/main-store/products"
mkdir -p "$OUT"

# ===========================================================================
# The page template. All CAT_* / P_* variables are substituted at emit time.
# ===========================================================================
emit () {
cat > "$OUT/$SLUG.html" <<PAGE
<!doctype html>
<html lang="en" class="no-js">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<title>${P_TITLE} — Kosha</title>
<meta name="description" content="${P_META}">
<meta name="theme-color" content="${THEME_COLOR}">

<link rel="stylesheet" href="../../assets/fonts/fonts.css">
<link rel="stylesheet" href="../assets/css/base.css">
<link rel="stylesheet" href="../assets/css/site.css">
<link rel="stylesheet" href="../assets/css/product.css">
<link rel="stylesheet" href="../assets/css/themes.css">
</head>

<!-- Category mood is applied with a single class on <body>. Structure below
     is identical across all six categories; themes.css does the rest. -->
<body class="${THEME}">
<a class="skip-link" href="#main">Skip to content</a>

<!-- ══ ANNOUNCEMENT ═══════════════════════════════════════════════════ -->
<div class="announce">
  <div class="announce__track">
    <div class="announce__group">
      <span class="announce__item">Free shipping over ₹999</span>
      <span class="announce__item">Cash on delivery available</span>
      <span class="announce__item">7-day easy returns</span>
      <span class="announce__item">Dispatched in 24 hours</span>
    </div>
    <div class="announce__group" aria-hidden="true">
      <span class="announce__item">Free shipping over ₹999</span>
      <span class="announce__item">Cash on delivery available</span>
      <span class="announce__item">7-day easy returns</span>
      <span class="announce__item">Dispatched in 24 hours</span>
    </div>
  </div>
</div>

<!-- ══ HEADER  → sections/header.liquid ═══════════════════════════════ -->
<header class="header" data-header>
  <div class="wrap header__inner">
    <div class="header__left">
      <button class="burger" data-drawer-open="nav-drawer" data-burger
              aria-expanded="false" aria-controls="nav-drawer" aria-label="Open menu">
        <span class="burger__box"><span class="burger__line"></span><span class="burger__line"></span><span class="burger__line"></span></span>
      </button>
      <nav class="nav" aria-label="Primary">
        <div class="nav__item" data-mega-item>
          <a class="nav__link has-menu" href="../index.html#categories" data-mega-trigger aria-expanded="false">
            Shop <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M6 9l6 6 6-6"/></svg>
          </a>
          <div class="mega">
            <div class="wrap mega__inner">
              <div class="mega__cols">
                <div class="mega__group">
                  <p class="eyebrow is-plain">Categories</p>
                  <ul class="mega__list">
                    <li><a href="jewellery.html">Jewellery &amp; Accessories</a></li>
                    <li><a href="beauty.html">Beauty &amp; Personal Care</a></li>
                    <li><a href="kitchen.html">Home &amp; Kitchen</a></li>
                    <li><a href="furniture.html">Home &amp; Furniture</a></li>
                    <li><a href="electronics.html">Electronics &amp; Accessories</a></li>
                    <li><a href="general.html">General Merchandise</a></li>
                  </ul>
                </div>
                <div class="mega__group">
                  <p class="eyebrow is-plain">Edits</p>
                  <ul class="mega__list">
                    <li><a href="../index.html#bestsellers">Best sellers</a></li>
                    <li><a href="../index.html#new">New this week</a></li>
                    <li><a href="../index.html#categories">Under ₹999</a></li>
                    <li><a href="../index.html#categories">Gifting</a></li>
                  </ul>
                </div>
                <div class="mega__group">
                  <p class="eyebrow is-plain">Help</p>
                  <ul class="mega__list">
                    <li><a href="../contact.html">Contact us</a></li>
                    <li><a href="../contact.html#faq">Shipping &amp; returns</a></li>
                    <li><a href="../contact.html#faq">Track an order</a></li>
                  </ul>
                </div>
              </div>
              <div class="mega__feature">
                <a class="mega__card" href="jewellery.html">
                  <div class="media ar-4-5 media--zoom"><img src="../assets/img/jewel-04.jpg" alt="Gold pendant necklace" loading="lazy"></div>
                  <h4>The Jewellery Edit</h4><p>Everyday gold, 22 pieces</p>
                </a>
                <a class="mega__card" href="electronics.html">
                  <div class="media ar-4-5 media--zoom"><img src="../assets/img/tech-01.jpg" alt="Over-ear headphones" loading="lazy"></div>
                  <h4>Sound &amp; Charge</h4><p>Audio and power essentials</p>
                </a>
              </div>
            </div>
          </div>
        </div>
        <a class="nav__link" href="../index.html#bestsellers">Best sellers</a>
        <a class="nav__link" href="../index.html#story">About</a>
        <a class="nav__link" href="../contact.html">Contact</a>
      </nav>
    </div>

    <a class="header__logo" href="../index.html">Kosha</a>

    <div class="header__right">
      <a class="header__act hide-mobile" href="#" aria-label="Search">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><path d="M20 20l-3.5-3.5"/></svg></a>
      <a class="header__act hide-mobile" href="../contact.html" aria-label="Account">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0116 0"/></svg></a>
      <button class="header__act" data-drawer-open="cart-drawer" aria-label="Open bag">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M6 8h12l-1 12H7L6 8z"/><path d="M9 8V6a3 3 0 016 0v2"/></svg>
        <span class="cart-count" data-cart-count>0</span>
      </button>
    </div>
  </div>
</header>

<!-- ══ DRAWERS ═══════════════════════════════════════════════════════ -->
<div class="scrim" data-scrim></div>

<aside class="drawer drawer--left" id="nav-drawer" aria-hidden="true" aria-label="Menu">
  <div class="drawer__head">
    <span class="drawer__title">Menu</span>
    <button class="icon-btn" data-drawer-close aria-label="Close menu">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"><path d="M18 6L6 18M6 6l12 12"/></svg></button>
  </div>
  <div class="drawer__body">
    <ul class="mnav">
      <li class="mnav__item">
        <button class="mnav__link" data-mnav-toggle aria-expanded="false">Shop
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg></button>
        <div class="mnav__sub"><div>
          <a href="jewellery.html">Jewellery &amp; Accessories</a>
          <a href="beauty.html">Beauty &amp; Personal Care</a>
          <a href="kitchen.html">Home &amp; Kitchen</a>
          <a href="furniture.html">Home &amp; Furniture</a>
          <a href="electronics.html">Electronics &amp; Accessories</a>
          <a href="general.html">General Merchandise</a>
        </div></div>
      </li>
      <li class="mnav__item"><a class="mnav__link" href="../index.html#bestsellers">Best sellers</a></li>
      <li class="mnav__item"><a class="mnav__link" href="../index.html#story">About</a></li>
      <li class="mnav__item"><a class="mnav__link" href="../contact.html">Contact</a></li>
    </ul>
  </div>
</aside>

<aside class="drawer drawer--right" id="cart-drawer" aria-hidden="true" aria-label="Shopping bag">
  <div class="drawer__head">
    <span class="drawer__title">Your bag</span>
    <button class="icon-btn" data-drawer-close aria-label="Close bag">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"><path d="M18 6L6 18M6 6l12 12"/></svg></button>
  </div>
  <div class="drawer__body" data-cart-body></div>
  <div class="drawer__foot" data-cart-foot hidden>
    <div class="cart-total"><span class="t-meta">Subtotal</span><strong data-cart-total>₹0</strong></div>
    <p class="t-meta" style="margin-bottom:var(--s-4)">Shipping and taxes calculated at checkout.</p>
    <button class="btn btn--block btn--lg">Checkout</button>
  </div>
</aside>

<main id="main">
  <div class="wrap">
    <nav class="crumbs" aria-label="Breadcrumb">
      <a href="../index.html">Home</a><em>/</em>
      <a href="../index.html#categories">${CAT_NAME}</a><em>/</em>
      <span aria-current="page">${P_TITLE}</span>
    </nav>

    <!-- ══ PRODUCT  → sections/main-product.liquid ═══════════════════
         data-* on .pdp is the product payload the cart reads. On Shopify:
           data-id    = {{ product.selected_or_first_available_variant.id }}
           data-title = {{ product.title }}
           data-price = {{ variant.price | divided_by: 100 }}
           data-img   = {{ product.featured_image | image_url }}
    -->
    <article class="pdp" data-pdp
             data-id="${P_ID}"
             data-title="${P_TITLE}"
             data-price="${P_PRICE_RAW}"
             data-img="../assets/img/${IMG1}.jpg">

      <!-- gallery → product.images
           Phone: a swipeable carousel with arrows, a counter and a thumbnail
           strip, so it is obvious more photographs exist and they are
           reachable without guessing that the image swipes.
           Desktop: the same thumbnails become a vertical rail and the slides
           stack into one scrollable column. -->
      <div class="gallery">
        <div class="gallery__frame">
          <div class="gallery__stage" data-gallery-stage>
            <div class="gallery__slide"><img src="../assets/img/${IMG1}.jpg" alt="${P_TITLE}, main view" fetchpriority="high"></div>
            <div class="gallery__slide"><img src="../assets/img/${IMG2}.jpg" alt="${P_TITLE}, detail" loading="lazy"></div>
            <div class="gallery__slide"><img src="../assets/img/${IMG3}.jpg" alt="${P_TITLE}, in use" loading="lazy"></div>
            <div class="gallery__slide"><img src="../assets/img/${IMG4}.jpg" alt="${P_TITLE}, alternate angle" loading="lazy"></div>
          </div>

          <button class="gallery__nav gallery__nav--prev" data-gallery-prev aria-label="Previous image">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M15 6l-6 6 6 6"/></svg>
          </button>
          <button class="gallery__nav gallery__nav--next" data-gallery-next aria-label="Next image">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M9 6l6 6-6 6"/></svg>
          </button>

          <span class="gallery__counter" data-gallery-counter aria-hidden="true">1 / 4</span>
        </div>

        <div class="gallery__thumbs" role="tablist" aria-label="Product images">
          <button class="gallery__thumb is-on" data-gallery-thumb role="tab" aria-selected="true"><img src="../assets/img/${IMG1}.jpg" alt="" loading="eager"></button>
          <button class="gallery__thumb" data-gallery-thumb role="tab" aria-selected="false"><img src="../assets/img/${IMG2}.jpg" alt="" loading="lazy"></button>
          <button class="gallery__thumb" data-gallery-thumb role="tab" aria-selected="false"><img src="../assets/img/${IMG3}.jpg" alt="" loading="lazy"></button>
          <button class="gallery__thumb" data-gallery-thumb role="tab" aria-selected="false"><img src="../assets/img/${IMG4}.jpg" alt="" loading="lazy"></button>
        </div>
      </div>

      <!-- buy column -->
      <div class="pdp__buy-col">
        <div class="pdp__head">
          <p class="pdp__vendor">${CAT_NAME}</p>
          <h1 class="pdp__title">${P_TITLE}</h1>

          <div class="pdp__ratingline">
            <span class="stars">
              <span class="stars__row"><span class="stars__bg">★★★★★</span><span class="stars__fg" style="width:${P_STARW}">★★★★★</span></span>
              <span>${P_RATING}</span>
            </span>
            <a href="#reviews">${P_REVCOUNT} reviews</a>
          </div>

          <div class="pdp__price">
            <span class="now">${P_PRICE}</span>
            <span class="was">${P_WAS}</span>
            <span class="tag tag--sale">${P_OFF}</span>
          </div>
          <p class="pdp__taxnote">Inclusive of all taxes. ${P_TAXNOTE}</p>
        </div>

        <!-- top-of-page benefit list -->
        <ul class="pdp__usp">
${P_USPS}
        </ul>

        <!-- options → product.options_with_values -->
${P_OPTIONS}

        <!-- add to cart → form action="/cart/add" -->
        <div class="pdp__buy" data-buy-anchor>
          <div class="pdp__buy-row">
            <div class="qty" data-qty>
              <button type="button" data-step="-1" aria-label="Decrease quantity">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M5 12h14"/></svg></button>
              <span class="qty__val">1</span>
              <button type="button" data-step="1" aria-label="Increase quantity">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg></button>
            </div>
            <button class="btn btn--accent pdp__atc" data-atc>Add to bag — ${P_PRICE}</button>
          </div>
          <button class="btn btn--ghost btn--block">Buy it now</button>
          <p class="pdp__note">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M4 5l8-3 8 3v6c0 5-3.4 9-8 11-4.6-2-8-6-8-11z"/></svg>
            ${P_STOCKNOTE}
          </p>
        </div>

        <!-- delivery + offers -->
        <div class="pdp__panel">
          <div class="pdp__panel-row">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M2 7h11v10H2z"/><path d="M13 10h4l3 3v4h-7z"/><circle cx="6" cy="18" r="1.8"/><circle cx="17" cy="18" r="1.8"/></svg>
            <span><b>Delivered ${P_ETA}</b> to most pin codes. Free over ₹999.</span>
          </div>
          <div class="pdp__panel-row">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="6" width="20" height="12" rx="2"/><path d="M2 10h20"/></svg>
            <span><b>Cash on delivery</b> available. UPI, cards and net banking too.</span>
          </div>
          <div class="pdp__panel-row">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12a9 9 0 1 0 3-6.7"/><path d="M3 4v5h5"/></svg>
            <span><b>7-day returns.</b> ${P_RETURNS}</span>
          </div>
        </div>

        <!-- description / specs / care -->
        <div class="acc" data-acc>
          <div class="acc__item is-open">
            <button class="acc__btn" aria-expanded="true">Description
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg></button>
            <div class="acc__panel"><div>
${P_DESC}
            </div></div>
          </div>

          <div class="acc__item">
            <button class="acc__btn" aria-expanded="false">${P_SPECLABEL}
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg></button>
            <div class="acc__panel"><div>
              <table class="specs">
${P_SPECS}
              </table>
              <div style="height:var(--s-5)"></div>
            </div></div>
          </div>

          <div class="acc__item">
            <button class="acc__btn" aria-expanded="false">${P_CARELABEL}
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg></button>
            <div class="acc__panel"><div>
              <ul>
${P_CARE}
              </ul>
            </div></div>
          </div>

          <div class="acc__item">
            <button class="acc__btn" aria-expanded="false">Shipping &amp; returns
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg></button>
            <div class="acc__panel"><div>
              <p>Orders placed before 2pm IST are dispatched the same working day, otherwise the
                next. Delivery runs ${P_ETA} depending on your pin code, and you will get a
                tracking link by SMS and email the moment it leaves us.</p>
              <p style="margin-top:var(--s-3)">Not right? Start a return within 7 days of delivery
                and we will arrange a free pickup. Refunds land back on the original payment
                method within 3–5 working days of the item reaching us.</p>
            </div></div>
          </div>
        </div>
      </div>
    </article>
  </div>

  <!-- ══ TRUST BAR ══════════════════════════════════════════════════ -->
  <section class="trustbar">
    <div class="wrap">
      <div class="trustbar__grid">
        <div class="trustbar__item">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M2 7h11v10H2z"/><path d="M13 10h4l3 3v4h-7z"/><circle cx="6" cy="18" r="1.8"/><circle cx="17" cy="18" r="1.8"/></svg>
          <h4>Free shipping over ₹999</h4><p>Flat ₹59 below that</p>
        </div>
        <div class="trustbar__item">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M4 5l8-3 8 3v6c0 5-3.4 9-8 11-4.6-2-8-6-8-11z"/><path d="M9 12l2 2 4-4"/></svg>
          <h4>${P_TRUST2}</h4><p>${P_TRUST2SUB}</p>
        </div>
        <div class="trustbar__item">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="6" width="20" height="12" rx="2"/><path d="M2 10h20"/></svg>
          <h4>Cash on delivery</h4><p>Available across India</p>
        </div>
        <div class="trustbar__item">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M4 18v-6a8 8 0 0116 0v6"/><path d="M20 19a2 2 0 01-2 2h-2"/><rect x="2" y="13" width="4" height="6" rx="1.4"/><rect x="18" y="13" width="4" height="6" rx="1.4"/></svg>
          <h4>Real people</h4><p>WhatsApp support, 10–7</p>
        </div>
      </div>
    </div>
  </section>

  <!-- ══ FEATURE 1 ══════════════════════════════════════════════════ -->
  <section class="section">
    <div class="wrap">
      <div class="feature">
        <div class="feature__media reveal">
          <div class="media ${AR_F1}"><img src="../assets/img/${IMG_F1}.jpg" alt="${P_F1ALT}" loading="lazy"></div>
        </div>
        <div class="feature__copy reveal">
          <p class="eyebrow">${P_F1EYE}</p>
          <h2 class="display t-h2">${P_F1TITLE}</h2>
          <p class="t-lead">${P_F1BODY}</p>
        </div>
      </div>
    </div>
  </section>

  <!-- ══ BENEFITS TRIO ══════════════════════════════════════════════ -->
  <section class="section-b">
    <div class="wrap">
      <div class="section-head">
        <div class="section-head__title">
          <p class="eyebrow">${P_BENEYE}</p>
          <h2 class="display t-h2">${P_BENTITLE}</h2>
        </div>
      </div>
      <div class="bens" data-reveal-group>
${P_BENS}
      </div>
    </div>
  </section>

  <!-- ══ FEATURE 2 (image on the right) ═════════════════════════════ -->
  <section class="section" style="background:var(--paper-2)">
    <div class="wrap">
      <div class="feature feature--flip">
        <div class="feature__media reveal">
          <div class="media ${AR_F2}"><img src="../assets/img/${IMG_F2}.jpg" alt="${P_F2ALT}" loading="lazy"></div>
        </div>
        <div class="feature__copy reveal">
          <p class="eyebrow">${P_F2EYE}</p>
          <h2 class="display t-h2">${P_F2TITLE}</h2>
          <p class="t-lead">${P_F2BODY}</p>
          <a class="btn btn--ghost" href="#reviews" style="justify-self:start">Read the reviews</a>
        </div>
      </div>
    </div>
  </section>

  <!-- ══ REVIEWS  → a reviews app renders into this block ═══════════ -->
  <section class="section" id="reviews">
    <div class="wrap">
      <div class="section-head">
        <div class="section-head__title">
          <p class="eyebrow">Customer reviews</p>
          <h2 class="display t-h2">${P_REVHEAD}</h2>
        </div>
        <button class="btn btn--ghost btn--sm">Write a review</button>
      </div>

      <div class="rv">
        <div class="rv__summary">
          <div>
            <p class="rv__score">${P_RATING}</p>
            <span class="stars"><span class="stars__row"><span class="stars__bg">★★★★★</span><span class="stars__fg" style="width:${P_STARW}">★★★★★</span></span></span>
            <p class="t-meta" style="margin-top:6px">Based on ${P_REVCOUNT} verified reviews</p>
          </div>
          <div class="rv__bars">
${P_REVBARS}
          </div>
        </div>

        <div class="rv__list">
${P_REVIEWS}
        </div>
      </div>
    </div>
  </section>

  <!-- ══ FAQ ════════════════════════════════════════════════════════ -->
  <section class="section-b">
    <div class="wrap wrap-narrow">
      <div class="section-head">
        <div class="section-head__title">
          <p class="eyebrow">Before you buy</p>
          <h2 class="display t-h2">Questions we get asked</h2>
        </div>
      </div>
      <div class="acc" data-acc style="margin-top:0">
${P_FAQ}
      </div>
    </div>
  </section>

  <!-- ══ RELATED  → sections/related-products.liquid ════════════════ -->
  <section class="section-b">
    <div class="wrap">
      <div class="section-head">
        <div class="section-head__title">
          <p class="eyebrow">More from this edit</p>
          <h2 class="display t-h2">${P_RELHEAD}</h2>
        </div>
        <a class="link t-meta" href="../index.html#categories">All categories &rarr;</a>
      </div>
      <div class="rail" data-reveal-group data-reveal-step="55">
${P_RELATED}
      </div>
    </div>
  </section>
</main>

<!-- ══ STICKY MOBILE BUY BAR ════════════════════════════════════════ -->
<div class="buybar" data-buybar>
  <div class="buybar__info">
    <span class="buybar__title">${P_TITLE}</span>
    <span class="buybar__price">${P_PRICE} · <span data-buybar-variant></span></span>
  </div>
  <button class="btn btn--accent" data-atc>Add to bag</button>
</div>

<!-- ══ FOOTER ═══════════════════════════════════════════════════════ -->
<footer class="footer">
  <div class="wrap">
    <div class="footer__top">
      <div class="footer__brand">
        <span class="footer__word">Kosha</span>
        <p class="t-meta" style="color:rgba(251,249,246,.62)">Everyday things, chosen well.
          Packed by hand in Bengaluru and shipped across India.</p>
        <form class="footer__signup" data-demo-form="You're on the list — thanks!">
          <label class="sr-only" for="fnl">Email address</label>
          <input id="fnl" type="email" placeholder="Email address" required>
          <button type="submit">Join</button>
        </form>
      </div>
      <div class="footer__col">
        <h4>Shop</h4>
        <ul>
          <li><a href="jewellery.html">Jewellery &amp; Accessories</a></li>
          <li><a href="beauty.html">Beauty &amp; Personal Care</a></li>
          <li><a href="kitchen.html">Home &amp; Kitchen</a></li>
          <li><a href="furniture.html">Home &amp; Furniture</a></li>
          <li><a href="electronics.html">Electronics</a></li>
          <li><a href="general.html">General Merchandise</a></li>
        </ul>
      </div>
      <div class="footer__col">
        <h4>Help</h4>
        <ul>
          <li><a href="../contact.html">Contact us</a></li>
          <li><a href="../contact.html#faq">Shipping &amp; delivery</a></li>
          <li><a href="../contact.html#faq">Returns &amp; exchanges</a></li>
          <li><a href="../contact.html#faq">Track your order</a></li>
          <li><a href="../contact.html#faq">FAQ</a></li>
        </ul>
      </div>
      <div class="footer__col">
        <h4>Company</h4>
        <ul>
          <li><a href="../index.html#story">Our story</a></li>
          <li><a href="../index.html#bestsellers">Best sellers</a></li>
          <li><a href="../contact.html">Careers</a></li>
          <li><a href="../contact.html">Wholesale</a></li>
        </ul>
      </div>
    </div>
    <div class="footer__bottom">
      <span>© <span data-year>2026</span> Kosha Retail. All rights reserved.</span>
      <span class="footer__legal">
        <a href="../contact.html">Privacy</a>
        <a href="../contact.html">Terms</a>
        <a href="../contact.html">Refund policy</a>
      </span>
    </div>
  </div>
</footer>

<script src="../assets/js/site.js"></script>
<script src="../assets/js/product.js"></script>
</body>
</html>
PAGE
echo "  built products/$SLUG.html  ($THEME)"
}

# Small helpers so the category blocks below stay readable.
usp ()  { printf '          <li><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6L9 17l-5-5"/></svg><span>%s</span></li>\n' "$1"; }
spec () { printf '                <tr><th>%s</th><td>%s</td></tr>\n' "$1" "$2"; }
care () { printf '                <li>%s</li>\n' "$1"; }
bar ()  { printf '            <div class="rv__bar"><span>%s★</span><span class="rv__track"><span class="rv__fill" style="width:%s"></span></span><span>%s</span></div>\n' "$1" "$2" "$3"; }

ben () { # n / title / body
  printf '        <div class="ben reveal"><span class="ben__n">%s</span><h4>%s</h4><p>%s</p></div>\n' "$1" "$2" "$3"
}

review () { # avatar / name / place / date / heading / body
  cat <<RV
          <article class="rv__item">
            <div class="rv__top">
              <span class="rv__who">
                <img src="../assets/img/$1.jpg" alt="" loading="lazy">
                <span><b>$2</b><br><span class="rv__date">$3</span></span>
              </span>
              <span class="rv__verified">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6L9 17l-5-5"/></svg>
                Verified purchase</span>
            </div>
            <span class="stars"><span class="stars__row"><span class="stars__bg">★★★★★</span><span class="stars__fg" style="width:$4">★★★★★</span></span></span>
            <div class="rv__body"><h4>$5</h4><p>$6</p></div>
          </article>
RV
}

faq () { # question / answer
  cat <<FQ
        <div class="acc__item">
          <button class="acc__btn" aria-expanded="false">$1
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg></button>
          <div class="acc__panel"><div><p>$2</p></div></div>
        </div>
FQ
}

card () { # img / althover / title / meta / price / was / off / id / variant / rawprice / badge
  local badge=""
  [ -n "${11:-}" ] && badge="<span class=\"card__badges\"><span class=\"tag tag--solid\">${11}</span></span>"
  local wasoff=""
  [ -n "${6:-}" ] && wasoff="<span class=\"price__was num\">$6</span><span class=\"price__off\">$7</span>"
  cat <<CD
        <article class="card reveal">
          <a href="#" class="card__media">
            <div class="media ar-4-5 media--zoom"><img src="../assets/img/$1.jpg" alt="$3" loading="lazy"></div>
            <div class="card__alt"><img src="../assets/img/$2.jpg" alt="" loading="lazy"></div>
            $badge
          </a>
          <div class="card__quick">
            <button class="btn btn--light btn--sm btn--block" data-quick-add
              data-id="$8" data-title="$3" data-variant="$9"
              data-price="${10}" data-img="../assets/img/$1.jpg" data-url="#">Quick add</button>
          </div>
          <div class="card__body">
            <a href="#"><h3 class="card__title">$3</h3></a>
            <p class="card__meta">$4</p>
            <p class="price"><span class="price__now num">$5</span>$wasoff</p>
          </div>
        </article>
CD
}

# ===========================================================================
# 01 — JEWELLERY & ACCESSORIES  (elegant, refined, luxury)
# ===========================================================================
build_jewellery () {
SLUG=jewellery; THEME=t-jewellery; THEME_COLOR="#8a6a34"; CAT_NAME="Jewellery &amp; Accessories"
IMG1=jewel-04; IMG2=jewel-01; IMG3=jewel-hero; IMG4=jewel-08
IMG_F1=jewel-lifestyle; AR_F1=ar-4-3; IMG_F2=jewel-03; AR_F2=ar-4-5
P_ID="ko-jw-01"
P_TITLE="Meridian Crescent Pendant"
P_META="A slim crescent pendant in 18k gold vermeil over recycled sterling silver. Three chain lengths, tarnish-resistant, ready to wear every day."
P_PRICE="₹1,290"; P_PRICE_RAW=1290; P_WAS="₹1,890"; P_OFF="32% off"
P_RATING="4.9"; P_STARW="98%"; P_REVCOUNT="312"
P_TAXNOTE="Free gift box with every order."
P_STOCKNOTE="Only 12 left in gold — dispatched within 24 hours"
P_ETA="in 2–4 days"
P_RETURNS="Unworn, in its box, with the tag on."
P_TRUST2="1-year plating warranty"; P_TRUST2SUB="Re-plated free if it fades"
P_USPS="$(usp '18k gold vermeil over recycled 925 sterling — not brass, not plated steel'
usp 'Tarnish-resistant and safe for sensitive skin: nickel and lead free'
usp 'Adjustable 16–18 inch chain with a 2 inch extender'
usp 'Arrives in a lined gift box with a polishing cloth')"
P_OPTIONS='        <div class="opt" data-opt>
          <div class="opt__head"><span class="opt__name">Finish</span><span class="opt__value" data-opt-value>18k Gold</span></div>
          <div class="opt__row" role="radiogroup" aria-label="Finish">
            <button class="swatch" role="radio" aria-checked="true"  tabindex="0"  data-value="18k Gold"    style="background:linear-gradient(140deg,#e6c98a,#b9903f)" aria-label="18k Gold"></button>
            <button class="swatch" role="radio" aria-checked="false" tabindex="-1" data-value="Silver"      style="background:linear-gradient(140deg,#eceff1,#b9c0c5)" aria-label="Silver"></button>
            <button class="swatch" role="radio" aria-checked="false" tabindex="-1" data-value="Rose Gold"   style="background:linear-gradient(140deg,#f0cdc0,#cf9a84)" aria-label="Rose Gold"></button>
          </div>
        </div>

        <div class="opt" data-opt>
          <div class="opt__head"><span class="opt__name">Chain length</span><span class="opt__value" data-opt-value>18 inch</span></div>
          <div class="opt__row" role="radiogroup" aria-label="Chain length">
            <button class="pill" role="radio" aria-checked="false" tabindex="-1" data-value="16 inch">16&Prime;</button>
            <button class="pill" role="radio" aria-checked="true"  tabindex="0"  data-value="18 inch">18&Prime;</button>
            <button class="pill" role="radio" aria-checked="false" tabindex="-1" data-value="20 inch">20&Prime;</button>
            <button class="pill" role="radio" aria-checked="false" tabindex="-1" data-value="22 inch" data-soldout>22&Prime;</button>
          </div>
        </div>'
P_DESC='              <p>A crescent no wider than a thumbnail, hung on a chain fine enough to disappear
                under a collar. It is the piece we reach for when nothing else is quite right —
                which is exactly why we made it the first thing in this edit.</p>
              <p style="margin-top:var(--s-3)">The pendant is cast in recycled sterling silver and
                finished with 2.5 microns of 18k gold — thick enough that it will not rub through
                at the collarbone the way flash-plated jewellery does. The clasp is a proper lobster,
                not a spring ring, so it will not work itself open on a long day.</p>'
P_SPECLABEL="Materials &amp; measurements"
P_SPECS="$(spec 'Metal' 'Recycled 925 sterling silver'
spec 'Plating' '18k gold vermeil, 2.5 micron'
spec 'Pendant' '11 mm × 9 mm'
spec 'Chain' 'Fine cable, 1.1 mm'
spec 'Length' '16–18 in, adjustable'
spec 'Clasp' 'Lobster with extender'
spec 'Weight' '2.4 g'
spec 'Hallmark' 'Stamped 925 on the tag')"
P_CARELABEL="Care"
P_CARE="$(care 'Put it on last — after perfume, sunscreen and hairspray have dried.'
care 'Take it off before swimming, showering or the gym. Chlorine and sweat are what actually kill plating.'
care 'Buff it with the cloth in the box; skip silver dip, which strips gold vermeil.'
care 'Store it flat in the pouch rather than tangled in a dish.')"
P_F1EYE="Made to be worn, not saved"
P_F1TITLE="Thin enough to layer. Solid enough to keep."
P_F1BODY="Most everyday gold is a thin flash over brass, and you can tell within a month. This is
  vermeil over solid silver, which is why we are comfortable re-plating it free for a year. Wear
  it alone, or stack it with a shorter chain and let the crescent sit just below."
P_F1ALT="Crescent pendant worn layered with a second chain"
P_BENEYE="Why this one"; P_BENTITLE="Three things we would not compromise on"
P_BENS="$(ben '01' 'Recycled silver core' 'The base metal is reclaimed 925, not brass. It is the difference between a piece that ages and one that turns your neck green.'
ben '02' 'A plating you can measure' '2.5 microns of 18k gold. Fast-fashion vermeil is often a tenth of that, which is why it wears through at the clasp first.'
ben '03' 'Free re-plating for a year' 'If the finish softens in the first twelve months, send it back. We re-plate it and post it out again at no cost.')"
P_F2EYE="Sizing"; P_F2TITLE="How to choose a length"
P_F2BODY="16 inch sits at the base of the throat and works under a shirt collar. 18 inch — the one
  most people pick — falls just below the collarbone. 20 and 22 inch drop onto the sternum and layer
  well over a knit. If you are between two, take the longer one; the extender takes it back up."
P_F2ALT="Chain length comparison on the neck"
P_REVHEAD="312 people have bought this one"
P_REVBARS="$(bar 5 '89%' 278
bar 4 '8%' 25
bar 3 '2%' 6
bar 2 '1%' 2
bar 1 '0%' 1)"
P_REVIEWS="$(review avatar-01 'Ananya R.' '14 August 2026' '100%' 'Exactly the size I hoped' 'I have bought three &ldquo;dainty&rdquo; pendants online and two of them arrived comically large. This one is genuinely small — it sits right below the collarbone on the 18 inch and I have not taken it off in six weeks, showers excepted.'
review avatar-03 'Fatima S.' '2 August 2026' '100%' 'Still gold after two months' 'The clasp is where my other chains went first, and this one still looks new. It is heavier in the hand than the photos suggest, in a good way.'
review avatar-05 'Priya N.' '21 July 2026' '80%' 'Lovely, box was slightly dented' 'No complaints about the pendant itself. The outer carton took a knock in transit, though the gift box inside was fine. Support offered to resend it, which I did not need.')"
P_FAQ="$(faq 'Will it turn my skin green?' 'No. That happens when the base metal is brass or copper. This is plated over recycled 925 sterling silver, and it is nickel and lead free, so it is safe for most sensitive skin.'
faq 'Can I wear it in the shower?' 'You can, but do not make a habit of it. Soap builds a film on the plating and hard water speeds up wear. Taking it off adds thirty seconds and roughly doubles how long the finish lasts.'
faq 'What if the gold wears off?' 'Send it back within twelve months and we re-plate it free, including return postage. After that we still do it for a small fee.'
faq 'Does it come gift wrapped?' 'Every order arrives in a lined box with a polishing cloth. Add a note at checkout and we will write it on the card by hand.')"
P_RELHEAD="More from the jewellery edit"
P_RELATED="$(card jewel-01 jewel-06 'Amethyst Bloom Ring' 'Sterling silver · 5 sizes' '₹2,150' '₹2,990' '28% off' ko-jw-02 'Silver / 14' 2150 'Best seller'
card jewel-03 jewel-08 'Sentinel Chronograph' 'Sapphire glass · 40 mm' '₹4,890' '' '' ko-jw-03 'Navy' 4890 ''
card jewel-06 jewel-07 'Lapis Drop Earrings' 'Lapis lazuli · Gold vermeil' '₹1,750' '₹2,400' '27% off' ko-jw-04 'Gold' 1750 ''
card jewel-hero jewel-02 'Freshwater Pearl Strand' '6 mm pearls · 16 inch' '₹3,290' '' '' ko-jw-05 'Classic' 3290 '')"
emit
}

# ===========================================================================
# 02 — BEAUTY & PERSONAL CARE  (soft, clean, warm)
# ===========================================================================
build_beauty () {
SLUG=beauty; THEME=t-beauty; THEME_COLOR="#b46b58"; CAT_NAME="Beauty &amp; Personal Care"
IMG1=beauty-08; IMG2=beauty-04; IMG3=beauty-01; IMG4=beauty-hero
IMG_F1=beauty-lifestyle; AR_F1=ar-4-3; IMG_F2=beauty-05; AR_F2=ar-4-5
P_ID="ko-bt-01"
P_TITLE="Quiet Hours Night Serum"
P_META="A niacinamide and squalane night serum for dull, uneven skin. Fragrance-free, non-comedogenic, 30ml. Dermatologist tested."
P_PRICE="₹890"; P_PRICE_RAW=890; P_WAS="₹1,250"; P_OFF="29% off"
P_RATING="4.7"; P_STARW="94%"; P_REVCOUNT="1,046"
P_TAXNOTE="30ml — about three months at nightly use."
P_STOCKNOTE="In stock — dispatched within 24 hours"
P_ETA="in 2–4 days"
P_RETURNS="Opened bottles included, if it does not agree with you."
P_TRUST2="Dermatologist tested"; P_TRUST2SUB="Patch tested on 52 people"
P_USPS="$(usp '5% niacinamide with squalane — brightening without the tight, stripped feeling'
usp 'Fragrance-free and non-comedogenic; safe alongside retinol on alternate nights'
usp 'Lightweight enough to layer under a moisturiser or a sleeping mask'
usp 'Never tested on animals, and the bottle is refill-ready glass')"
P_OPTIONS='        <div class="opt" data-opt>
          <div class="opt__head"><span class="opt__name">Size</span><span class="opt__value" data-opt-value>30 ml</span></div>
          <div class="opt__row" role="radiogroup" aria-label="Size">
            <button class="pill" role="radio" aria-checked="false" tabindex="-1" data-value="15 ml">15 ml</button>
            <button class="pill" role="radio" aria-checked="true"  tabindex="0"  data-value="30 ml">30 ml</button>
            <button class="pill" role="radio" aria-checked="false" tabindex="-1" data-value="50 ml">50 ml</button>
          </div>
        </div>

        <div class="opt" data-opt>
          <div class="opt__head"><span class="opt__name">Buy as</span><span class="opt__value" data-opt-value>One-time</span></div>
          <div class="opt__row" role="radiogroup" aria-label="Purchase type">
            <button class="pill" role="radio" aria-checked="true"  tabindex="0"  data-value="One-time">One-time</button>
            <button class="pill" role="radio" aria-checked="false" tabindex="-1" data-value="Refill every 3 months">Refill every 3 months</button>
          </div>
        </div>'
P_DESC='              <p>A thin, almost watery serum for the nights when your skin looks tired rather
                than troubled. Niacinamide at 5% — high enough to work on uneven tone, low enough
                not to sting — carried in squalane so it sinks in instead of sitting on top.</p>
              <p style="margin-top:var(--s-3)">There is no fragrance, no essential oil and no
                alcohol in it, which is dull to write about and much kinder to a compromised barrier.
                Two or three drops after cleansing is the whole routine.</p>'
P_SPECLABEL="Ingredients"
P_SPECS="$(spec 'Key actives' 'Niacinamide 5%, squalane 3%'
spec 'Supporting' 'Panthenol, glycerin, allantoin'
spec 'Texture' 'Light fluid, matte finish'
spec 'pH' '5.5–6.0'
spec 'Fragrance' 'None'
spec 'Suits' 'All skin types, incl. sensitive'
spec 'Volume' '30 ml'
spec 'Shelf life' '12 months once opened')"
P_CARELABEL="How to use"
P_CARE="$(care 'At night, on clean, slightly damp skin — three drops is plenty for the whole face.'
care 'Press it in rather than rubbing, then follow with a moisturiser.'
care 'Using retinol? Alternate nights for the first fortnight, then judge.'
care 'Store it out of direct sun. The glass is tinted for a reason.')"
P_F1EYE="Made for tired skin"
P_F1TITLE="A short routine you will actually keep to."
P_F1BODY="Most people do not abandon skincare because it fails — they abandon it because it takes
  eleven minutes. This is one bottle, three drops, once a night. Give it four weeks before you
  judge it; niacinamide works on tone slowly, and anything that promises faster is telling you a story."
P_F1ALT="Serum bottle beside a folded towel"
P_BENEYE="What is in it"; P_BENTITLE="Three ingredients doing the work"
P_BENS="$(ben '01' 'Niacinamide, 5%' 'Evens out tone and calms redness over weeks, not days. Above about 5% it starts to sting more than it helps, so we stopped there.'
ben '02' 'Squalane, plant-derived' 'The carrier oil, and the reason this absorbs instead of pilling under moisturiser. It is close to what your skin already makes.'
ben '03' 'Nothing to react to' 'No fragrance, no essential oils, no denatured alcohol. Boring on an ingredient list, forgiving on a stressed barrier.')"
P_F2EYE="Honest expectations"; P_F2TITLE="What four weeks actually looks like"
P_F2BODY="Week one: skin feels a little softer, nothing dramatic. Week two: the flat, dull look
  after a bad night lifts faster. Week four: dark marks from old spots are visibly lighter, though
  not gone. If you are looking for an overnight change, this is not the bottle for it."
P_F2ALT="Applying serum to the cheek"
P_REVHEAD="Over a thousand people use this nightly"
P_REVBARS="$(bar 5 '80%' 837
bar 4 '14%' 146
bar 3 '4%' 42
bar 2 '1%' 13
bar 1 '1%' 8)"
P_REVIEWS="$(review avatar-05 'Ishita B.' '28 August 2026' '100%' 'Finally something that does not sting' 'My skin reacts to nearly every serum with fragrance in it. Five weeks in, no reaction, and the marks on my chin from an old breakout have genuinely faded. Not gone — faded, which is what the page said would happen.'
review avatar-06 'Meera K.' '11 August 2026' '80%' 'Good, but the dropper is stiff' 'The serum itself is lovely and sinks in fast. My only gripe is the pipette needs a firm squeeze to draw up properly.'
review avatar-02 'Karan D.' '30 July 2026' '100%' 'Layers well under everything' 'I use it before a moisturiser and it never pills, which was my problem with the last two I tried. Also no smell at all, which I did not know I wanted.')"
P_FAQ="$(faq 'Can I use this with retinol?' 'Yes, but stagger them at first — retinol one night, this the next — for a couple of weeks. Once your skin is used to both, most people apply this first and retinol on top.'
faq 'Will it break me out?' 'It is non-comedogenic and there is no oil in it beyond squalane, which is very unlikely to clog. If you are prone to purging, introduce it every other night for the first week.'
faq 'Is it safe during pregnancy?' 'Niacinamide and squalane are generally considered fine, but we are not your doctor — please check with them before adding anything new.'
faq 'How long will 30ml last?' 'At three drops a night, roughly three months. The 50ml works out cheaper per use if you already know it suits you.')"
P_RELHEAD="More from the beauty edit"
P_RELATED="$(card beauty-01 beauty-03 'Morning Light Vitamin C' '15% L-ascorbic · 20ml' '₹1,190' '₹1,590' '25% off' ko-bt-02 '20ml' 1190 'Best seller'
card beauty-05 beauty-08 'Slow Repair Body Lotion' 'Ceramides · 250ml' '₹640' '' '' ko-bt-03 '250ml' 640 ''
card beauty-06 beauty-hero 'Everyday Edit Palette' '9 shades · Matte + satin' '₹1,450' '₹1,990' '27% off' ko-bt-04 'Warm' 1450 ''
card beauty-07 beauty-04 'Amber Hours Eau de Parfum' 'Amber, cedar, vanilla · 50ml' '₹2,290' '' '' ko-bt-05 '50ml' 2290 '')"
emit
}

# ===========================================================================
# 03 — HOME & KITCHEN  (warm, inviting)
# ===========================================================================
build_kitchen () {
SLUG=kitchen; THEME=t-kitchen; THEME_COLOR="#b3502e"; CAT_NAME="Home &amp; Kitchen"
IMG1=kitchen-hero; IMG2=kitchen-06; IMG3=kitchen-lifestyle; IMG4=kitchen-01
IMG_F1=kitchen-lifestyle; AR_F1=ar-4-3; IMG_F2=kitchen-07; AR_F2=ar-4-5
P_ID="ko-kt-01"
P_TITLE="Hearth Cast-Iron Casserole"
P_META="A 4.2 litre enamelled cast-iron casserole for slow cooking, braising and baking bread. Oven safe to 260°C, induction ready, lifetime guarantee."
P_PRICE="₹3,450"; P_PRICE_RAW=3450; P_WAS="₹4,999"; P_OFF="31% off"
P_RATING="4.8"; P_STARW="96%"; P_REVCOUNT="487"
P_TAXNOTE="4.2 litres — feeds four to six comfortably."
P_STOCKNOTE="Low stock in chilli red — 9 left"
P_ETA="in 3–6 days"
P_RETURNS="Unused, in the original carton."
P_TRUST2="Lifetime guarantee"; P_TRUST2SUB="On the pot, not the enamel"
P_USPS="$(usp 'Sand-cast iron with a three-layer enamel — no seasoning, no rust, no fuss'
usp 'Oven safe to 260°C with the lid on, and works on induction, gas and electric'
usp 'Self-basting lid: the ridges underneath drip moisture back over the food'
usp 'Heavy at 5.1 kg, which is the whole point — it holds heat instead of spiking')"
P_OPTIONS='        <div class="opt" data-opt>
          <div class="opt__head"><span class="opt__name">Colour</span><span class="opt__value" data-opt-value>Chilli Red</span></div>
          <div class="opt__row" role="radiogroup" aria-label="Colour">
            <button class="swatch" role="radio" aria-checked="true"  tabindex="0"  data-value="Chilli Red"  style="background:linear-gradient(140deg,#d0492f,#9c2f1c)" aria-label="Chilli Red"></button>
            <button class="swatch" role="radio" aria-checked="false" tabindex="-1" data-value="Fern Green"  style="background:linear-gradient(140deg,#4a5f4a,#2c3b2f)" aria-label="Fern Green"></button>
            <button class="swatch" role="radio" aria-checked="false" tabindex="-1" data-value="Oat"         style="background:linear-gradient(140deg,#efe7d8,#d3c6ae)" aria-label="Oat"></button>
            <button class="swatch" role="radio" aria-checked="false" tabindex="-1" data-value="Slate"       style="background:linear-gradient(140deg,#5e646a,#3a4046)" aria-label="Slate"></button>
          </div>
        </div>

        <div class="opt" data-opt>
          <div class="opt__head"><span class="opt__name">Capacity</span><span class="opt__value" data-opt-value>4.2 L</span></div>
          <div class="opt__row" role="radiogroup" aria-label="Capacity">
            <button class="pill" role="radio" aria-checked="false" tabindex="-1" data-value="2.4 L">2.4 L</button>
            <button class="pill" role="radio" aria-checked="true"  tabindex="0"  data-value="4.2 L">4.2 L</button>
            <button class="pill" role="radio" aria-checked="false" tabindex="-1" data-value="6.0 L">6.0 L</button>
          </div>
        </div>'
P_DESC='              <p>The pot that ends up on the stove four nights a week. Cast in one piece, coated
                inside and out in enamel, and heavy enough that a low flame keeps a curry at a bare
                simmer for two hours without catching.</p>
              <p style="margin-top:var(--s-3)">It goes straight from the hob into the oven, which is
                what makes it worth the money — brown the meat, add the liquid, put the lid on, and
                walk away. It also bakes an excellent loaf, because the sealed lid traps steam for the
                first half of the bake.</p>'
P_SPECLABEL="Dimensions &amp; materials"
P_SPECS="$(spec 'Body' 'Sand-cast iron'
spec 'Coating' 'Three-layer vitreous enamel'
spec 'Capacity' '4.2 litres'
spec 'Diameter' '26 cm'
spec 'Height with lid' '15.5 cm'
spec 'Weight' '5.1 kg'
spec 'Oven safe' 'To 260°C'
spec 'Hob' 'Induction, gas, electric, halogen')"
P_CARELABEL="Care"
P_CARE="$(care 'Let it cool before it meets water — thermal shock is what cracks enamel, not use.'
care 'Warm soapy water and a soft sponge. No steel wool, no dishwasher tablets.'
care 'For stubborn browning, simmer water with a spoon of bicarbonate for ten minutes.'
care 'Dry it properly and store with the lid slightly ajar so nothing gets musty.')"
P_F1EYE="Built for slow food"
P_F1TITLE="Heat that stays where you put it."
P_F1BODY="Thin pans spike and scorch; five kilos of cast iron simply does not. Once it is up to
  temperature it holds there, which is why a dal or a braise can sit on the lowest flame for two
  hours and come out even. It is the least clever cookware in the kitchen and the one you will use most."
P_F1ALT="Casserole simmering on a hob"
P_BENEYE="Worth knowing"; P_BENTITLE="Three reasons this outlasts the rest"
P_BENS="$(ben '01' 'Enamel on both faces' 'Inside and out. Bare cast iron underneath means rust the first time it sits wet in a cupboard; this does not need seasoning at all.'
ben '02' 'A lid that does something' 'The underside is ridged, so condensation collects and drips back onto the food instead of running down the walls. Braises come out moister for it.'
ben '03' 'Handles you can actually grip' 'Wide enough for oven gloves, cast as part of the body rather than bolted on. Nothing to work loose in five years.')"
P_F2EYE="Choosing a size"; P_F2TITLE="Which capacity you actually need"
P_F2BODY="2.4 litres suits one or two people and a single side. 4.2 is the one most households
  should buy — four to six portions, and it still fits a standard oven shelf. 6 litres is for
  batch cooking and whole birds; be honest about whether you will lift it full."
P_F2ALT="Three casserole sizes side by side"
P_REVHEAD="What 487 cooks think"
P_REVBARS="$(bar 5 '85%' 414
bar 4 '11%' 54
bar 3 '3%' 12
bar 2 '1%' 5
bar 1 '0%' 2)"
P_REVIEWS="$(review avatar-02 'Rohit M.' '19 August 2026' '100%' 'Properly heavy, properly packed' 'I was half expecting thin cast with a lot of enamel hiding it. It is genuinely dense — you feel it when you lift the lid. Came in three layers of foam and arrived in Guwahati without a mark.'
review avatar-04 'Sameer T.' '5 August 2026' '100%' 'Bread comes out excellent' 'Bought it for braising, kept it for sourdough. The lid seals well enough that I get a proper oven spring without spraying water everywhere.'
review avatar-03 'Nisha P.' '24 July 2026' '80%' 'Great pot, mind the weight' 'No complaints about the cooking. Just be aware that full of stew this is a two-handed lift, and I would not want the 6 litre.')"
P_FAQ="$(faq 'Does it need seasoning like bare cast iron?' 'No. The enamel means there is nothing to season and nothing to rust. Wash it, dry it, put it away.'
faq 'Can I use metal utensils in it?' 'A metal spoon for stirring is fine. Avoid scraping the base hard with anything sharp, and never cut inside the pot.'
faq 'Will it work on my induction hob?' 'Yes — cast iron is the most induction-friendly material there is. It also works on gas, electric and halogen.'
faq 'What does the lifetime guarantee cover?' 'Casting faults and handle failure, for as long as you own it. Enamel chipping from a knock or from thermal shock is not covered, since that is wear rather than a defect.')"
P_RELHEAD="More from the kitchen edit"
P_RELATED="$(card kitchen-06 kitchen-01 'Base Stoneware Mugs, set of 4' '320 ml · Dishwasher safe' '₹1,190' '₹1,590' '25% off' ko-kt-03 'Chalk' 1190 'Best seller'
card kitchen-05 kitchen-02 'Still Insulated Bottle' '750 ml · 18h cold' '₹749' '' '' ko-kt-02 'Sage' 749 ''
card kitchen-02 kitchen-03 'Whirl Countertop Blender' '1.5 L · 800 W' '₹3,290' '₹4,450' '26% off' ko-kt-04 'Graphite' 3290 ''
card kitchen-03 kitchen-04 'Compact Toaster Oven' '20 L · Convection' '₹5,890' '' '' ko-kt-05 'Black' 5890 '')"
emit
}

# ===========================================================================
# 04 — HOME & FURNITURE  (warm, refined, tactile)
# ===========================================================================
build_furniture () {
SLUG=furniture; THEME=t-furniture; THEME_COLOR="#33473c"; CAT_NAME="Home &amp; Furniture"
IMG1=furniture-hero; IMG2=furniture-07; IMG3=furniture-lifestyle; IMG4=furniture-05
IMG_F1=furniture-lifestyle; AR_F1=ar-3-2; IMG_F2=furniture-04; AR_F2=ar-4-5
P_ID="ko-fn-01"
P_TITLE="Alcott Three-Seat Sofa"
P_META="A three-seat sofa in stain-resistant boucle over a kiln-dried hardwood frame. Ten-year frame guarantee, assembles in under fifteen minutes."
P_PRICE="₹32,900"; P_PRICE_RAW=32900; P_WAS="₹44,500"; P_OFF="26% off"
P_RATING="4.7"; P_STARW="94%"; P_REVCOUNT="164"
P_TAXNOTE="Free doorstep delivery on all furniture."
P_STOCKNOTE="Made to order — dispatched in 10–12 days"
P_ETA="in 10–14 days"
P_RETURNS="Within 7 days of delivery, in its original packing."
P_TRUST2="10-year frame guarantee"; P_TRUST2SUB="Kiln-dried hardwood"
P_USPS="$(usp 'Kiln-dried hardwood frame, corner-blocked and dowelled — not stapled particleboard'
usp 'High-resilience foam over a serpentine spring base; it will not sag into a dip'
usp 'Stain-resistant boucle in four colourways, removable and washable covers'
usp 'Ships flat in two boxes and assembles with one bolt per leg — no tools beyond the key supplied')"
P_OPTIONS='        <div class="opt" data-opt>
          <div class="opt__head"><span class="opt__name">Upholstery</span><span class="opt__value" data-opt-value>Forest</span></div>
          <div class="opt__row" role="radiogroup" aria-label="Upholstery">
            <button class="swatch" role="radio" aria-checked="true"  tabindex="0"  data-value="Forest"   style="background:linear-gradient(140deg,#41564a,#28362e)" aria-label="Forest"></button>
            <button class="swatch" role="radio" aria-checked="false" tabindex="-1" data-value="Oat"      style="background:linear-gradient(140deg,#e8e0d1,#c9bda5)" aria-label="Oat"></button>
            <button class="swatch" role="radio" aria-checked="false" tabindex="-1" data-value="Clay"     style="background:linear-gradient(140deg,#c4785c,#9c563d)" aria-label="Clay"></button>
            <button class="swatch" role="radio" aria-checked="false" tabindex="-1" data-value="Graphite" style="background:linear-gradient(140deg,#5a5c5e,#37393b)" aria-label="Graphite"></button>
          </div>
        </div>

        <div class="opt" data-opt>
          <div class="opt__head"><span class="opt__name">Size</span><span class="opt__value" data-opt-value>Three seat</span></div>
          <div class="opt__row" role="radiogroup" aria-label="Size">
            <button class="pill" role="radio" aria-checked="false" tabindex="-1" data-value="Two seat">Two seat</button>
            <button class="pill" role="radio" aria-checked="true"  tabindex="0"  data-value="Three seat">Three seat</button>
            <button class="pill" role="radio" aria-checked="false" tabindex="-1" data-value="Chaise" data-soldout>Chaise</button>
          </div>
        </div>

        <div class="opt" data-opt>
          <div class="opt__head"><span class="opt__name">Legs</span><span class="opt__value" data-opt-value>Solid oak</span></div>
          <div class="opt__row" role="radiogroup" aria-label="Legs">
            <button class="pill" role="radio" aria-checked="true"  tabindex="0"  data-value="Solid oak">Solid oak</button>
            <button class="pill" role="radio" aria-checked="false" tabindex="-1" data-value="Black steel">Black steel</button>
          </div>
        </div>'
P_DESC='              <p>A sofa with a low back and a deep seat, built for evenings rather than for
                posture. The arms are narrow so it takes less wall than its seating suggests, which
                matters in a flat where the sofa has to sit under a window.</p>
              <p style="margin-top:var(--s-3)">Underneath the boucle is the part worth paying for:
                a kiln-dried hardwood frame with glued and dowelled corner blocks, and a serpentine
                spring deck rather than webbing. That is the difference between a sofa that is still
                flat in year eight and one that is not.</p>'
P_SPECLABEL="Dimensions &amp; construction"
P_SPECS="$(spec 'Overall' '212 W × 92 D × 78 H cm'
spec 'Seat height' '44 cm'
spec 'Seat depth' '58 cm'
spec 'Frame' 'Kiln-dried hardwood, dowelled'
spec 'Suspension' 'Serpentine steel springs'
spec 'Cushions' 'HR foam, 35 kg/m³ core'
spec 'Fabric' 'Stain-resistant boucle, 45k rubs'
spec 'Assembly' 'Four bolt-on legs, key included')"
P_CARELABEL="Care"
P_CARE="$(care 'Vacuum the seats with a brush head every couple of weeks — grit is what wears boucle, not sitting on it.'
care 'Blot spills, do not rub. The finish repels for long enough that most things lift with water.'
care 'Rotate and flip the seat cushions monthly so they settle evenly.'
care 'Covers unzip and machine wash cold; line dry, and put them back on slightly damp for a better fit.')"
P_F1EYE="Under the fabric"
P_F1TITLE="The part of a sofa you never see is the part that fails."
P_F1BODY="Most sofas at this price hide a stapled softwood or particleboard frame, and they go
  within five years — usually at a corner joint. This one is kiln-dried hardwood with glued dowels
  and corner blocks, which is why we are comfortable guaranteeing the frame for a decade."
P_F1ALT="Sofa in a bright living room"
P_BENEYE="Specifics"; P_BENTITLE="Three things worth checking on any sofa"
P_BENS="$(ben '01' 'Frame timber' 'Kiln-dried hardwood holds a screw and does not move with humidity. Green or soft timber shrinks, and that is what makes an old sofa creak.'
ben '02' 'Foam density' '35 kg per cubic metre in the seat core. Cheaper sofas use 18–22, which feels identical in a showroom and quite different after a year.'
ben '03' 'Fabric rub count' '45,000 Martindale rubs — a commercial-grade number. Domestic upholstery is often rated at 15,000 to 20,000.')"
P_F2EYE="Before you order"; P_F2TITLE="Measure the doorway, not the room"
P_F2BODY="It ships flat in two boxes, the largest of which is 218 × 40 × 96 cm, so it will make it
  up most staircases and through a standard 76 cm door. The room needs 212 cm of wall plus a little
  breathing space at each end — we would not put it against a 215 cm wall."
P_F2ALT="Sofa dimensions shown in a room setting"
P_REVHEAD="164 people have lived with this sofa"
P_REVBARS="$(bar 5 '78%' 128
bar 4 '16%' 26
bar 3 '4%' 7
bar 2 '1%' 2
bar 1 '1%' 1)"
P_REVIEWS="$(review avatar-04 'Vikram J.' '22 August 2026' '100%' 'Assembly genuinely took ten minutes' 'Four legs, four bolts, one key in the box. My last flat-pack sofa took two people and an afternoon. The forest boucle is a shade deeper than on screen, which I prefer.'
review avatar-01 'Divya S.' '9 August 2026' '80%' 'Comfortable, seat is deep' 'Very happy overall. Worth knowing the seat is properly deep — lovely if you sit sideways with your feet up, less ideal if you want to sit upright and work.'
review avatar-06 'Ritu A.' '1 August 2026' '100%' 'Covers came off easily' 'Had a full glass of red wine on it in week three. Covers unzipped, went in the machine cold, came out clean. That alone justified the price for me.')"
P_FAQ="$(faq 'Will it fit through my door?' 'It ships flat in two boxes. The largest is 218 × 40 × 96 cm, which clears a standard 76 cm doorway and most stairwells. Measure the tightest turn rather than the door itself.'
faq 'Do I need tools to assemble it?' 'No. Four legs bolt on by hand using the key in the box. Two people make it easier, mostly for turning the frame over.'
faq 'Is the boucle pet-friendly?' 'The weave is tight and the finish resists staining, but claws can pull loops on any boucle. If you have a cat that scratches furniture, the graphite is the most forgiving.'
faq 'What exactly does the guarantee cover?' 'Ten years on the frame and the spring deck. Foam and fabric carry two years, since those are wear items — we will still help you re-cover after that.')"
P_RELHEAD="More from the furniture edit"
P_RELATED="$(card furniture-03 furniture-04 'Dune Brass Pendant' 'Hand-spun · E27' '₹2,890' '' '' ko-fn-02 'Aged brass' 2890 'New'
card furniture-01 furniture-02 'Vetta Accent Chair' 'Oak frame · Bouclé seat' '₹9,450' '₹12,900' '27% off' ko-fn-03 'Oat' 9450 ''
card furniture-05 furniture-07 'Linden Coffee Table' 'Solid ash · 110 cm' '₹11,200' '' '' ko-fn-04 'Natural' 11200 ''
card furniture-08 furniture-06 'Terracotta Planter, large' 'Unglazed · 28 cm' '₹1,290' '₹1,690' '24% off' ko-fn-05 'Terracotta' 1290 '')"
emit
}

# ===========================================================================
# 05 — ELECTRONICS & ACCESSORIES  (sleek, techy, modern — dark theme)
# ===========================================================================
build_electronics () {
SLUG=electronics; THEME=t-electronics; THEME_COLOR="#0e0f12"; CAT_NAME="Electronics &amp; Accessories"
IMG1=tech-04; IMG2=tech-01; IMG3=tech-hero; IMG4=tech-07
IMG_F1=tech-lifestyle; AR_F1=ar-3-2; IMG_F2=tech-02; AR_F2=ar-4-5
P_ID="ko-el-01"
P_TITLE="Halo ANC Headphones"
P_META="Over-ear wireless headphones with hybrid active noise cancelling, 40 hour battery, multipoint pairing and USB-C fast charge."
P_PRICE="₹2,490"; P_PRICE_RAW=2490; P_WAS="₹3,499"; P_OFF="29% off"
P_RATING="4.6"; P_STARW="92%"; P_REVCOUNT="2,318"
P_TAXNOTE="1-year warranty, serviced in India."
P_STOCKNOTE="In stock — dispatched within 24 hours"
P_ETA="in 2–4 days"
P_RETURNS="With all accessories and the carry case."
P_TRUST2="1-year warranty"; P_TRUST2SUB="Service centres in 40 cities"
P_USPS="$(usp 'Hybrid ANC with four mics — cuts about 28 dB of low-frequency cabin and traffic noise'
usp '40 hours with ANC on, 60 with it off; 10 minutes on USB-C gives roughly 5 hours'
usp 'Multipoint Bluetooth 5.3 — stays connected to a laptop and a phone at the same time'
usp 'Memory-foam earcups at 268 g, and they fold flat into the case supplied')"
P_OPTIONS='        <div class="opt" data-opt>
          <div class="opt__head"><span class="opt__name">Colour</span><span class="opt__value" data-opt-value>Midnight</span></div>
          <div class="opt__row" role="radiogroup" aria-label="Colour">
            <button class="swatch" role="radio" aria-checked="true"  tabindex="0"  data-value="Midnight" style="background:linear-gradient(140deg,#2a2d33,#101216)" aria-label="Midnight"></button>
            <button class="swatch" role="radio" aria-checked="false" tabindex="-1" data-value="Bone"     style="background:linear-gradient(140deg,#f0ece4,#cfc9bd)" aria-label="Bone"></button>
            <button class="swatch" role="radio" aria-checked="false" tabindex="-1" data-value="Cobalt"   style="background:linear-gradient(140deg,#5d8bff,#2c4fbb)" aria-label="Cobalt"></button>
          </div>
        </div>

        <div class="opt" data-opt>
          <div class="opt__head"><span class="opt__name">Bundle</span><span class="opt__value" data-opt-value>Headphones only</span></div>
          <div class="opt__row" role="radiogroup" aria-label="Bundle">
            <button class="pill" role="radio" aria-checked="true"  tabindex="0"  data-value="Headphones only">Headphones only</button>
            <button class="pill" role="radio" aria-checked="false" tabindex="-1" data-value="With flight adapter">+ Flight adapter</button>
            <button class="pill" role="radio" aria-checked="false" tabindex="-1" data-value="With 2-year care">+ 2-year care</button>
          </div>
        </div>'
P_DESC='              <p>Cans built for a commute and a working day rather than a listening room. The
                cancellation is aimed where it matters — engine drone, air conditioning, the low
                rumble of a metro — so voices still come through enough to be useful.</p>
              <p style="margin-top:var(--s-3)">The headline is the battery. Forty hours with ANC
                running means a week of commuting between charges, and the USB-C top-up is quick
                enough that forgetting to plug them in stops being a problem.</p>'
P_SPECLABEL="Specifications"
P_SPECS="$(spec 'Drivers' '40 mm dynamic, PET composite'
spec 'ANC' 'Hybrid, 4 mic, ~28 dB'
spec 'Bluetooth' '5.3, multipoint'
spec 'Codecs' 'SBC, AAC, LDAC'
spec 'Battery' '40 h ANC on / 60 h off'
spec 'Charging' 'USB-C, 10 min = ~5 h'
spec 'Weight' '268 g'
spec 'In the box' 'Case, USB-C cable, 3.5 mm lead')"
P_CARELABEL="Setup &amp; pairing"
P_CARE="$(care 'Hold the power button for three seconds on first use — they come out of the box in pairing mode.'
care 'For multipoint, pair the first device, then hold the button again and pair the second.'
care 'Long-press the left cup to cycle ANC, transparency and off.'
care 'Charge them to full once a month if you store them, rather than leaving them flat.')"
P_F1EYE="Where the ANC works"
P_F1TITLE="Quiet where it counts, not everywhere."
P_F1BODY="Hybrid cancellation is very good at steady low frequencies — an aircraft cabin, a bus
  engine, an air conditioner — and much less effective on sudden, high sounds like a keyboard or a
  voice nearby. Anything claiming to erase all of it at this price is overselling. This kills the
  drone that actually tires you out."
P_F1ALT="Headphones on a desk beside a laptop"
P_BENEYE="Specifications that matter"; P_BENTITLE="Three numbers worth comparing"
P_BENS="$(ben '01' '40 hours, ANC on' 'Most rivals quote their figure with cancellation switched off. This is the honest number with it running — the one you will actually get.'
ben '02' 'Multipoint, properly' 'Held on a laptop call and a phone at once, and it switches when the phone rings instead of dropping the laptop entirely.'
ben '03' '268 grams' 'Light enough for a long flight. The clamp is deliberately gentle, which is a trade — brilliant for comfort, slightly less isolating on a jog.')"
P_F2EYE="Fit and comfort"; P_F2TITLE="Built for the fourth hour, not the first"
P_F2BODY="The earcups are memory foam under a protein leather that does not get sticky, and the
  headband spreads weight across the crown rather than one point. If you wear glasses, the foam is
  soft enough to seal around the arms without pressing them into your temples."
P_F2ALT="Detail of the earcup padding"
P_REVHEAD="2,318 verified reviews"
P_REVBARS="$(bar 5 '74%' 1715
bar 4 '18%' 417
bar 3 '5%' 116
bar 2 '2%' 46
bar 1 '1%' 24)"
P_REVIEWS="$(review avatar-02 'Arjun V.' '26 August 2026' '100%' 'The battery claim holds up' 'I charged them on a Sunday and got to Friday on a two-hour daily commute with ANC on the whole time. That is the first pair I have owned where the number on the box was roughly true.'
review avatar-06 'Sneha L.' '13 August 2026' '80%' 'Great on the metro, average in the office' 'Kills the train rumble completely. Does much less about the person talking two desks away, which the description did say, so no real complaint.'
review avatar-04 'Imran H.' '4 August 2026' '100%' 'Multipoint actually works' 'Laptop and phone at once, switches cleanly when a call comes in. My last pair advertised this and dropped the laptop every time.')"
P_FAQ="$(faq 'Do they work wired if the battery dies?' 'Yes. A 3.5 mm cable is in the box and they will play passively with no power, though ANC and the controls stop working.'
faq 'Can I use them for calls?' 'Yes — the four mics do double duty for voice, with beamforming. They are good in a quiet room and acceptable on a windy street, not exceptional.'
faq 'Is the warranty valid in India?' 'One year, serviced through partner centres in around 40 cities. Keep the invoice; the serial is under the left earcup pad.'
faq 'Do they support LDAC?' 'They do, alongside AAC and SBC. LDAC needs an Android device that supports it and will shorten battery life somewhat.')"
P_RELHEAD="More from the electronics edit"
P_RELATED="$(card tech-03 tech-08 'Drift Wireless Earbuds' '32 h with case · IPX5' '₹1,690' '₹2,299' '27% off' ko-el-02 'Ivory' 1690 'Best seller'
card tech-05 tech-01 'Slate 20W Charger' 'USB-C PD · Foldable pins' '₹749' '' '' ko-el-03 'White' 749 ''
card tech-07 tech-04 'Studio Wired Monitors' '50 mm · 32 ohm' '₹1,990' '₹2,650' '25% off' ko-el-04 'Black' 1990 ''
card tech-06 tech-hero 'Orbit Bluetooth Speaker' '12 h · IP67' '₹2,150' '' '' ko-el-05 'Charcoal' 2150 '')"
emit
}

# ===========================================================================
# 06 — GENERAL MERCHANDISE  (playful, fun, energetic — still polished)
# ===========================================================================
build_general () {
SLUG=general; THEME=t-general; THEME_COLOR="#2b4de0"; CAT_NAME="General Merchandise"
IMG1=general-03; IMG2=general-04; IMG3=general-hero; IMG4=general-01
IMG_F1=general-lifestyle; AR_F1=ar-3-2; IMG_F2=general-02; AR_F2=ar-4-5
P_ID="ko-gn-01"
P_TITLE="Ferry Acetate Sunglasses"
P_META="Polarised UV400 sunglasses in hand-polished acetate with spring hinges. Four colourways, hard case and cloth included."
P_PRICE="₹1,150"; P_PRICE_RAW=1150; P_WAS="₹1,690"; P_OFF="32% off"
P_RATING="4.7"; P_STARW="94%"; P_REVCOUNT="628"
P_TAXNOTE="Hard case and cleaning cloth included."
P_STOCKNOTE="In stock — dispatched within 24 hours"
P_ETA="in 2–4 days"
P_RETURNS="Unscratched, with the case and cloth."
P_TRUST2="2-year hinge warranty"; P_TRUST2SUB="Free replacement arms"
P_USPS="$(usp 'Genuine polarised lenses — cuts glare off water, glass and wet tarmac, not just brightness'
usp 'UV400: blocks the full UVA and UVB range, which cheap tinted lenses often do not'
usp 'Hand-polished acetate with steel spring hinges that survive being shoved in a bag'
usp 'Comes with a crush-resistant case and a microfibre cloth, not a flimsy pouch')"
P_OPTIONS='        <div class="opt" data-opt>
          <div class="opt__head"><span class="opt__name">Frame</span><span class="opt__value" data-opt-value>Matte Black</span></div>
          <div class="opt__row" role="radiogroup" aria-label="Frame">
            <button class="swatch" role="radio" aria-checked="true"  tabindex="0"  data-value="Matte Black" style="background:linear-gradient(140deg,#33343a,#131416)" aria-label="Matte Black"></button>
            <button class="swatch" role="radio" aria-checked="false" tabindex="-1" data-value="Tortoise"    style="background:linear-gradient(140deg,#a9723c,#573418)" aria-label="Tortoise"></button>
            <button class="swatch" role="radio" aria-checked="false" tabindex="-1" data-value="Crystal"     style="background:linear-gradient(140deg,#e8eef2,#bcc6cc)" aria-label="Crystal"></button>
            <button class="swatch" role="radio" aria-checked="false" tabindex="-1" data-value="Cobalt"      style="background:linear-gradient(140deg,#4f6ce8,#2436a8)" aria-label="Cobalt"></button>
          </div>
        </div>

        <div class="opt" data-opt>
          <div class="opt__head"><span class="opt__name">Lens</span><span class="opt__value" data-opt-value>Grey polarised</span></div>
          <div class="opt__row" role="radiogroup" aria-label="Lens">
            <button class="pill" role="radio" aria-checked="true"  tabindex="0"  data-value="Grey polarised">Grey</button>
            <button class="pill" role="radio" aria-checked="false" tabindex="-1" data-value="Amber polarised">Amber</button>
            <button class="pill" role="radio" aria-checked="false" tabindex="-1" data-value="Green polarised">Green</button>
            <button class="pill" role="radio" aria-checked="false" tabindex="-1" data-value="Mirror blue" data-soldout>Mirror</button>
          </div>
        </div>'
P_DESC='              <p>A squared-off frame that suits most faces and does not announce a particular
                decade. Acetate rather than injection-moulded plastic, which means it holds a polish,
                takes an adjustment at an optician, and does not go chalky after a summer.</p>
              <p style="margin-top:var(--s-3)">The lenses are properly polarised — hold them against
                a phone screen and rotate, and you will see them go dark. That is the test most
                cheap &ldquo;polarised&rdquo; sunglasses quietly fail.</p>'
P_SPECLABEL="Frame &amp; lens"
P_SPECS="$(spec 'Frame material' 'Hand-polished acetate'
spec 'Hinges' 'Steel spring, 5 barrel'
spec 'Lens' 'Polarised, UV400'
spec 'Lens width' '52 mm'
spec 'Bridge' '20 mm'
spec 'Temple' '145 mm'
spec 'Total width' '142 mm'
spec 'Weight' '28 g')"
P_CARELABEL="Care"
P_CARE="$(care 'Rinse them under a tap before wiping — dust dragged across a lens is what scratches it.'
care 'Use the cloth supplied, not a shirt hem or a paper napkin.'
care 'Take them off with both hands. One-handed removal is what loosens hinges over time.'
care 'Do not leave them on a car dashboard; heat warps acetate and can delaminate the coating.')"
P_F1EYE="Not just tinted"
P_F1TITLE="Polarised, and easy to prove it."
P_F1BODY="A dark lens only dims what you see. A polarised one filters the horizontally reflected
  light that comes off water, glass and wet roads — which is what actually makes you squint while
  driving. If the pair you own does not go dark when rotated against a phone screen, it is tinted, not polarised."
P_F1ALT="Sunglasses on a bright surface"
P_BENEYE="Details"; P_BENTITLE="Three things that decide how long a pair lasts"
P_BENS="$(ben '01' 'Acetate, not injection plastic' 'Cut from sheet and polished. It can be heat-adjusted for a better fit, which moulded plastic frames cannot.'
ben '02' 'Spring hinges' 'Five-barrel steel with a spring, so the arms flex outward instead of levering the frame apart when you push them onto your head.'
ben '03' 'A case that survives a bag' 'Crush-resistant shell with a felt lining. Most scratches happen in transit, not on your face.')"
P_F2EYE="Choosing a lens"; P_F2TITLE="Grey, amber or green"
P_F2BODY="Grey keeps colours neutral and is the safe everyday pick. Amber lifts contrast in flat
  light, which helps when driving on overcast days. Green sits between the two and is easiest on the
  eyes over long stretches outdoors. All three are equally polarised — it is a preference, not a spec."
P_F2ALT="Three lens tints compared"
P_REVHEAD="628 people picked these"
P_REVBARS="$(bar 5 '80%' 502
bar 4 '14%' 88
bar 3 '4%' 25
bar 2 '1%' 8
bar 1 '1%' 5)"
P_REVIEWS="$(review avatar-03 'Tanvi G.' '25 August 2026' '100%' 'Passed the phone-screen test' 'First thing I did was hold them up to my laptop and rotate. They went properly dark, so these are genuinely polarised. Glare off the road on the drive home is noticeably gone.'
review avatar-05 'Aditya R.' '16 August 2026' '80%' 'Great frame, slightly wide for me' 'Build quality is well above the price. I have a narrower face and they sit a touch loose — an optician tightened the arms in two minutes, so easily fixed.'
review avatar-01 'Neha C.' '3 August 2026' '100%' 'The case is the unsung hero' 'Sounds silly to review a case, but it is hard-shell and felt-lined and my glasses have survived a month in a work bag without a mark.')"
P_FAQ="$(faq 'How do I know these are really polarised?' 'Hold them in front of an LCD screen and rotate them ninety degrees. A polarised lens goes near-black at one angle. A merely tinted one does not change at all.'
faq 'Will they fit a smaller face?' 'The frame is 142 mm across, which is a medium. If that is wide for you, any optician can heat and adjust the acetate arms in a couple of minutes, usually free.'
faq 'Can I get prescription lenses fitted?' 'Yes. The frame takes standard 52 mm lenses and most opticians will glaze it. That does mean removing the polarised lenses we supply.'
faq 'What does the hinge warranty cover?' 'Two years on the hinge mechanism and the arms. Send it in and we replace the arm rather than the whole frame. Scratched lenses are wear, so those are not covered.')"
P_RELHEAD="More from general merchandise"
P_RELATED="$(card general-01 general-08 'Wren Everyday Backpack' '22 L · Water-resistant' '₹1,890' '₹2,490' '24% off' ko-gn-02 'Navy' 1890 'Best seller'
card general-02 general-04 'Court Six-Panel Cap' 'Cotton twill · Adjustable' '₹590' '' '' ko-gn-03 'Grey' 590 ''
card general-05 general-06 'Ember Reed Diffuser' 'Cedar + fig · 100 ml' '₹840' '₹1,190' '29% off' ko-gn-04 'Cedar' 840 ''
card general-hero general-07 'Pocket Retro Console' '400 games · USB-C' '₹1,450' '' '' ko-gn-05 'Yellow' 1450 '')"
emit
}

echo "==> building product pages"
build_jewellery
build_beauty
build_kitchen
build_furniture
build_electronics
build_general
echo "==> done"
