GlassCard is the base translucent surface used for every card in Lateralus — daily card, practice cards, prompt/response cards, coach card.

```jsx
<GlassCard variant="raised" radius="xl" glow="var(--type-reality-1)">
  <p>Content</p>
</GlassCard>
```

Variants: `default` (list rows, secondary cards), `raised` (hero/daily card, modals — stronger border + deeper shadow), `pressed` (active/selected state). `glow` renders a soft blurred color wash behind the card content, tinted to the active challenge type — this is the "aurora" motif from the night-sky background bleeding into a card.
