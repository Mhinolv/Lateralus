# Lateralus Design System

Source material: `uploads/DESIGN_HANDOFF.md` (design handoff brief for **Lateralus**, an iOS 26 / SwiftUI + SwiftData app that trains lateral thinking through daily creativity challenges). No Figma file or codebase was attached — this design system was built directly from that brief, extending its documented visual language ("night sky" gradient, glassmorphism, serif display type) into a full token/component/UI-kit system. There is no existing logo; the wordmark is set in plain type (see `guidelines/brand-wordmark.html`).

## Index

- `styles.css` — root stylesheet, imports every token file. Link this one file to consume the system.
- `tokens/` — `colors.css`, `typography.css`, `spacing.css`, `effects.css`.
- `guidelines/` — foundation specimen cards (Colors, Type, Spacing, Effects, Brand) shown in the Design System tab.
- `components/` — reusable React primitives, grouped by concern:
  - `core/` — GlassCard, Button, IconButton, Badge, StreakPill, EmptyState
  - `challenge/` — TypeChip / TypeIcon, ModifierPanel, CoachPanel
  - `forms/` — TextField (search + editor), MicButton
  - `data/` — StatTile, BarChart
  - `navigation/` — TabBar
- `ui_kits/lateralus-app/` — full click-through recreation of the 5 in-scope screens (Today, Challenge modal, Journal, Attempt Detail, Insights), in an iOS device frame.
- `SKILL.md` — portable skill file for Claude Code / Agent Skills.

## Product context

Lateralus is a **3-tab app** (Today / Journal / Insights), dark-mode only, no accounts or network calls — everything (journal, dictation, AI coaching) runs on-device. 8 challenge disciplines (Alternate Uses, Twisted Uses, Reality Shift, Fusion, Backstory, Perspective Flip, Redefine, Coin a Word), each with a distinct 2-color gradient identity spread evenly around the color wheel. Full detail in `uploads/DESIGN_HANDOFF.md`.

**In scope this pass:** Today, Challenge modal, Journal, Attempt Detail, Insights.
**Explicitly out of scope this pass:** Settings and Onboarding screens (both flagged as gaps in the brief — neither exists in the app today).

## Content fundamentals

- **Voice:** warm and encouraging, coach-like — never clinical or corporate. Second person ("you"), short declaratives. Headline example from the brief: *"Think sideways."*
- **Empty states** frame forward rather than stating absence: *"Your saved answers will show up here"* rather than *"No results."*
- **Coach copy** pattern: one sentence of praise, then provocations phrased as questions ("What if it also had to be edible?").
- **Privacy copy** is explicit and reassuring, not legalistic: *"Your journal, dictation, and coaching all run on this device. Nothing is uploaded, ever."*
- No emoji in UI chrome. The content library's per-prompt **emoji field is stored but never shown** in the shipped app; this system offers `TypeChip`'s optional `emoji` prop as a candidate small secondary accent (not a replacement for the icon system) — genuinely optional, not mandatory.
- Numerals over words for counts/stats (streak days, word counts, chart values).

## Visual foundations

- **Background:** full-bleed "night sky" — a 3-stop vertical gradient (`--bg-sky-1/2/3`, near-black indigo/navy) behind every screen. No light mode exists; do not invent one without new direction.
- **Aurora glow:** soft, large, heavily-blurred color blobs (`GlassCard`'s `glow` prop) tinted to the active challenge type, positioned behind hero cards — never as a full-screen wash, always contained/blurred behind a specific card.
- **Cards are glassmorphic:** translucent white fill (6–9% opacity), 1px hairline border (10–20% white), 20px backdrop blur, large radius (24–32px), soft outer shadow. Three fill states: `default`, `raised` (hero/modal — stronger border + deeper shadow), `pressed`.
- **Corner radii:** 10 / 16 / 24 / 32px + full pill, scaling with a component's visual weight (chips → buttons/inputs → cards → hero cards/modals).
- **Type:** serif display (`Source Serif 4`, standing in for the app's native New York) for prompts and headlines — this is the one deliberately editorial, "written by a person" voice in the UI. Sans (`Manrope`, standing in for SF Pro) for all chrome, labels, data, and body copy. Never mix — prompts/headlines are always serif, everything else always sans.
- **Color:** dark neutral base + one app-wide accent (violet, `--accent`) for streak/links/focus, *plus* 8 independent 2-stop gradients — one per challenge discipline — spread evenly around the hue wheel so every discipline reads as visually distinct at a glance (chip, icon tile, journal row, bar-chart bar all share the same gradient per type).
- **Animation:** minimal and functional, not decorative — button press = slight scale-down (0.97), mic recording = pulsing outward ring (`lat-mic-pulse`), coach loading = spinning glyph. Standard easing `cubic-bezier(0.4,0,0.2,1)`, 150–400ms.
- **Borders/shadows:** hairline borders throughout (never a heavy stroke); shadows are soft and large-radius, never sharp or short.
- **Blur/transparency:** used specifically for the glass-card material and the frosted tab bar — not as a general effect elsewhere.
- **Imagery:** none in the app (no photos/illustrations) — the "night sky" gradient + aurora glow *is* the imagery system.

## Iconography

- **System:** the native app uses SF Symbols; this web recreation substitutes **Phosphor Icons** (regular + fill weights) via CDN (`https://unpkg.com/@phosphor-icons/web`) — closest available thin-line match, flagged here per design-system convention. If real SF Symbol exports become available, swap the `ph-*` classes for an SF Symbols web font/SVG set using the same call sites.
- **Challenge-type icons** use Phosphor's **duotone-adjacent single glyphs inside a gradient-filled tile** (`TypeIcon`) — the 2-color gradient itself carries the "duotone" feeling rather than a duotone icon style, keeping a single consistent icon weight (regular) throughout the app.
- **Emoji:** not used in shipped UI; each `PromptItem`'s stored emoji is available as an optional secondary accent via `TypeChip`'s `emoji` prop (see Content fundamentals).
- No custom SVG icons were hand-drawn for this system — everything routes through the Phosphor set.

## Intentional additions

No source component library existed for this brief, so the full component set was authored from scratch, sized to exactly what the 5 in-scope screens need — no speculative primitives (no Toast, Tabs-as-nav-elsewhere, Tooltip, Dialog-frame, etc. beyond what the app actually uses).
