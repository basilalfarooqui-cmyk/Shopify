PROJECT: Multi-phase Shopify dropshipping store build (local-first)

ROLE
You are building a complete e-commerce store project for a solo, non-technical
founder. You are working 100% locally on this machine. No GitHub, no remote
repos, no deployment yet — that comes in a separate later phase the user will
trigger manually. Do not push, publish, or connect to any live Shopify store
in this run.

═══════════════════════════════════════════
0. FIRST ACTIONS (do this before anything else)
═══════════════════════════════════════════
1. Create the root project folder `Shopify/` in the current workspace if it
   doesn't exist, with this structure:

   Shopify/
   ├── PROJECT_BRIEF.md          ← save this entire prompt here, verbatim
   ├── logs/
   │   └── progress.log          ← running log, append-only
   ├── references/               ← user will drop reference screenshots/images here
   ├── main-store/                ← Phase 1 build
   ├── niche-sites/
   │   ├── smart-ring/            ← Phase 2
   │   └── skincare-product/      ← Phase 2
   └── category-variations/       ← Phase 3, one subfolder per category

2. Save this prompt verbatim to `Shopify/PROJECT_BRIEF.md`.
3. Check `Shopify/references/` for any images/screenshots. If present, treat
   them as the primary design reference for style, layout, and component
   patterns — do not design blind or randomly when references exist for a
   given category. If empty for a given part of the build, proceed using the
   design direction below and note in the log that no reference was found.
4. Check what local skills/tools you have available and use whatever is
   relevant to frontend/website design work.
5. Write a first line to `Shopify/logs/progress.log`: timestamp + "Project
   started."

═══════════════════════════════════════════
1. OPERATING RULES — READ CAREFULLY, THESE OVERRIDE DEFAULT BEHAVIOR
═══════════════════════════════════════════
- You have been launched with full permission to read, write, edit, and run
  commands with no confirmation needed. Full permissions are granted for this
  entire project. Do not ask the user for permission to create, edit, or
  delete files, or to run local commands, at any point in this run.
- If you ever find yourself about to ask a question or pause for
  confirmation: stop, re-read `Shopify/PROJECT_BRIEF.md` first. It almost
  certainly already answers you. Full autonomy was explicitly granted — do
  not stop to ask.
- If you hit a genuine blocker on one part (a broken dependency, unclear
  asset, a decision that actually can't be inferred from this brief or the
  references folder) — do NOT stop the whole run. Log it clearly in
  progress.log as `BLOCKED: <what> — <why> — skipped`, move to the next task,
  and come back to it later if time allows.
- At the start of EVERY new category or new site build (not mid-task, but
  when beginning a fresh unit of work), re-read `Shopify/PROJECT_BRIEF.md` in
  full before starting, to keep full context and rules loaded.
- Log every meaningful action to `Shopify/logs/progress.log`: what was
  started, what was completed, what was skipped and why, one line per event,
  with a timestamp. This is the only way the user will know what happened
  overnight, so keep it honest and current — update it as you go, not in a
  batch at the end.
- Work through phases in strict order: Phase 1 fully done and locally
  testable before Phase 2. Phase 2 done before Phase 3. Do not skip ahead.

═══════════════════════════════════════════
2. AUTO-RESUME WATCHDOG (set this up early, as part of setup)
═══════════════════════════════════════════
Claude Code does not natively auto-resume after a usage-limit pause. Build a
small local watchdog for this:

- Create `Shopify/watchdog.sh` (or .py, your choice) that:
  1. Periodically checks the last-modified timestamp of
     `Shopify/logs/progress.log`.
  2. If there's been no update for a stretch of time AND the terminal output
     shows a usage-limit / rate-limit message with a reset time, parse that
     reset time.
  3. Sleep until the reset time (plus a small buffer), then automatically
     run `claude --continue --dangerously-skip-permissions` to resume the
     paused session in place — do NOT start a fresh session, and do not
     replay from scratch.
  4. If progress.log is updating normally, do nothing — stay silent.
  5. Loop this check continuously in the background.
- Document in a short comment at the top of the script how to start it
  (e.g. `nohup ./watchdog.sh &`) so the user can leave it running overnight
  alongside the main session.

═══════════════════════════════════════════
3. BUSINESS CONTEXT (for tone/copy decisions throughout)
═══════════════════════════════════════════
- Model: dropshipping. Products sourced from Meesho, listed on this Shopify
  store. Orders fulfilled manually per order (not automated).
- Primary traffic funnel: social media reels/ads link DIRECTLY to individual
  product pages, not the home page. Product pages are the main conversion
  surface and deserve the most design attention, even though the home page
  must still be built to full quality.

═══════════════════════════════════════════
4. GLOBAL DESIGN DIRECTION (applies to everything you build)
═══════════════════════════════════════════
- Professional, high-end, interactive. Zero tolerance for generic templated
  "slop" or amateur look.
- Not overdone either — no gratuitous 3D, no heavy AI-generated-looking
  visual gimmicks. Restrained, elevated, intentional. Think: better than
  Amazon's bare-utility look, but not maximalist.
- Mobile-first — most traffic will land on product pages from a phone via a
  reel link.
- Use the `references/` folder content wherever available for a given
  section before inventing a look from scratch.

═══════════════════════════════════════════
5. PHASE 1 — MAIN STORE (build and fully test this first)
═══════════════════════════════════════════
Location: `Shopify/main-store/`

Build as a complete, clickable local website (plain HTML/CSS/JS — no
Shopify/Liquid yet, that conversion is a separate later phase not part of
this run):

Pages required:
- Home page — hero section, category navigation, hamburger menu, top nav,
  contact link. One consistent, polished theme site-wide for this page.
  High interactivity, high production value.
- Contact Us page.
- Product pages for each of these 6 categories:
  1. Jewellery & Accessories
  2. Beauty & Personal Care
  3. Home & Kitchen
  4. Home & Furniture
  5. Electronics & Accessories
  6. General Merchandise

Per-category product page theming — each category's product pages should
have their own distinct visual mood, layered on top of the same professional
quality bar (not a site-wide single template). Starting direction (adapt
using references/ if available for that category):
- Jewellery & Accessories → elegant, refined, luxury feel
- Beauty & Personal Care → soft, clean, warm
- Home & Kitchen → warm, inviting
- Home & Furniture → warm, refined, tactile
- Electronics & Accessories → sleek, techy, modern
- General Merchandise → playful, fun, energetic — but still polished, never
  cheap-looking

Include for each product page: image gallery, title, price, variant/quantity
selection UI, add-to-cart button, product description area, trust badges
placeholder, reviews section placeholder — these will later map to real
Shopify product data, so structure them cleanly and clearly labeled/commented
even though they're static/dummy for now.

When this phase is fully built, do a self-review pass: click through every
page path, check mobile responsiveness, check for broken links/placeholders,
log completion status per page/category in progress.log.

═══════════════════════════════════════════
6. PHASE 2 — STANDALONE SINGLE-PRODUCT NICHE SITES
═══════════════════════════════════════════
Location: `Shopify/niche-sites/`

Two fully separate single-product sites, not connected to the main store:

1. `smart-ring/` — Smart ring product. Minimalist, black, premium aesthetic.
   Single product landing/product page focus.
2. `skincare-product/` — Skincare product. Pink, feminine-focused aesthetic,
   attention-grabbing for a mostly-female audience.

Each should be a complete mini single-product website (landing/hero +
product page), built to the same professional quality bar as Phase 1.

═══════════════════════════════════════════
7. PHASE 3 — REFERENCE-BASED CATEGORY VARIATIONS
═══════════════════════════════════════════
Location: `Shopify/category-variations/`

For each of these categories, build 2–3 DISTINCT single-product site designs
(same category, genuinely different layouts/styles — never copy-paste the
same template with colors swapped):

accessories, activities & outdoors, clothing, drink, food, membership,
personal care, pets, shoes, skin care, supplements

Structure: `Shopify/category-variations/<category>/design-1/`,
`design-2/`, etc. Each design = its own small site with a home page and a
few related product pages for that concept.

Use `Shopify/references/` screenshots for these heavily — this phase is
explicitly meant to be reference-driven, not invented from scratch. If no
reference exists for a category, log it and use the global design direction
instead.

This phase has no hard limit — build out every category listed above.

═══════════════════════════════════════════
8. COMPLETION
═══════════════════════════════════════════
When (and only when) all three phases are fully built and self-reviewed,
write a final summary to `Shopify/logs/progress.log` and stop. Do not
continue working past full completion. Do not touch Shopify, GitHub, or any
remote service at any point in this run — local only.

Do not ask any questions at any point. Do not pause for confirmation. If
something is genuinely blocked, log it and skip it, then keep going. Begin
now with section 0.

and also check skills, and whichever neede use them , if want from internet just doneload it yourself and do it, you have full permissions, just make a gooud output product of your hardwork,thankyou, and dont use those sloppy fluff text font, use professionals font not sllop
