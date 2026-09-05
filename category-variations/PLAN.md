# Phase 3 — category variations, design plan

`references/` was empty when this phase started, so per section 7 of the brief
these follow the global design direction rather than reference screenshots.
That is logged in `logs/progress.log`.

## The rule this plan exists to enforce

The brief is explicit: *never copy-paste the same template with colours
swapped.* So every design is assigned a **layout archetype**, and no category
uses the same archetype twice. Archetypes differ in structure — where the
navigation sits, how the hero is built, how products are listed, how the
product page is composed — not just in palette.

## Archetypes

| # | Archetype | Structure it commits to |
|---|-----------|-------------------------|
| A | **Editorial** | Asymmetric magazine grid, large serif headlines, ragged columns, captions as design elements, rules between sections |
| B | **Cinematic** | Full-bleed imagery, text overlaid on photographs, dark ground, minimal chrome, section transitions by image |
| C | **Catalogue** | Dense utilitarian grid, small type, visible borders, spec-sheet feel, product-forward with little decoration |
| D | **Soft minimal** | Extreme whitespace, small centred type, muted palette, one image at a time, slow rhythm |
| E | **Bold block** | Heavy sans, hard-edged colour blocks, oversized type as texture, high contrast, no rounding |
| F | **Warm retro** | Rounded shapes, 70s palette, arch motifs, playful, generous curves |
| G | **Split screen** | 50/50 panels, one side sticky while the other scrolls, strong vertical division |
| H | **Card stack** | Layered cards with depth and shadow, overlapping panels, floating UI |

## Assignments

| Category | design-1 | design-2 | design-3 |
|---|---|---|---|
| accessories | A Editorial | H Card stack | — |
| activities-outdoors | B Cinematic | C Catalogue | — |
| clothing | A Editorial | E Bold block | G Split screen |
| drink | F Warm retro | B Cinematic | — |
| food | F Warm retro | A Editorial | — |
| membership | G Split screen | D Soft minimal | — |
| personal-care | D Soft minimal | H Card stack | — |
| pets | F Warm retro | H Card stack | — |
| shoes | E Bold block | B Cinematic | G Split screen |
| skin-care | D Soft minimal | A Editorial | — |
| supplements | C Catalogue | E Bold block | — |

28 designs in total.

## What each design contains

- `index.html` — the concept's home page
- `product-1.html`, `product-2.html` — a few related product pages
- `style.css` — that design's own stylesheet, no sharing

Behaviour comes from `_shared/ui.js` (reveal, gallery, menu, accordions,
option groups, quantity, toast). That file is behaviour only and never
appearance, so sharing it does not make two designs look alike.

## Verification

Every design is checked with `tools/audit.js` at 375 / 768 / 1280 before it is
counted as done: no horizontal scroll, nothing escaping the viewport, no
clipped text, no broken images, tap targets at 44px.
