# Lateralus Design System

This folder contains prototype components derived from the native SwiftUI application. Production behavior and accessibility remain defined by the Swift source under `Lateralus/`.

## Index

- `styles.css` — shared prototype styles.
- `core/` — cards, buttons, badges, streak pill, and empty state.
- `challenge/` — challenge identity and secondary-prompt panels.
- `forms/` — text fields and voice-note recording control.
- `data/` — stat and discipline-balance charts.
- `navigation/` — three-tab navigation.

## Product context

Lateralus is a dark-mode, three-tab iOS app: Today, Journal, and Insights. It contains twelve daily/practice games plus the prompt-free Diary entry type. Entries can combine text, PencilKit drawings, and recorded voice-note attachments. Voice notes are not transcribed. There is no AI coach, account, analytics, or networking.

## Content fundamentals

- Use a warm, concise, encouraging voice without presenting an automated coach persona.
- Frame empty states around the next useful action.
- Privacy copy should be literal: entries and attachments remain in the app container.
- Use numerals for counts, streaks, chart values, and recording durations.
- Do not use emoji in UI chrome. Native production UI uses SF Symbols.

## Visual foundations

- Full-bleed near-black indigo/navy “night sky” background.
- Restrained glass cards with translucent fills, hairline borders, large radii, and soft shadows.
- Editorial serif display type for prompts/headlines; sans-serif for body text, data, and controls.
- One app accent plus a distinct tint for each of the twelve games. Diary has its own neutral identity.
- Minimal functional animation: press feedback, recording pulse, save transitions, and numeric changes.
- No photography or illustration system; background glow and game color supply the visual identity.

## Iconography

The native app uses SF Symbols. Web prototypes may use Phosphor Icons as an approximation, but should preserve the production call-site semantics. Prompt emoji is optional stored content, not a substitute for interface icons.
