import React from 'react';

export const TYPES = {
  alt: { label: 'Alternate Uses', icon: 'ph-git-branch', gradient: 'var(--type-alt-gradient)', tint: 'var(--type-alt-1)' },
  coin: { label: 'Coin a Word', icon: 'ph-text-aa', gradient: 'var(--type-coin-gradient)', tint: 'var(--type-coin-1)' },
  twist: { label: 'Twisted Uses', icon: 'ph-link', gradient: 'var(--type-twist-gradient)', tint: 'var(--type-twist-1)' },
  reality: { label: 'Reality Shift', icon: 'ph-sparkle', gradient: 'var(--type-reality-gradient)', tint: 'var(--type-reality-1)' },
  fusion: { label: 'Fusion', icon: 'ph-intersect', gradient: 'var(--type-fusion-gradient)', tint: 'var(--type-fusion-1)' },
  backstory: { label: 'Backstory', icon: 'ph-magnifying-glass', gradient: 'var(--type-backstory-gradient)', tint: 'var(--type-backstory-1)' },
  perspective: { label: 'Perspective Flip', icon: 'ph-eye', gradient: 'var(--type-perspective-gradient)', tint: 'var(--type-perspective-1)' },
  redefine: { label: 'Redefine', icon: 'ph-quotes', gradient: 'var(--type-redefine-gradient)', tint: 'var(--type-redefine-1)' },
};

export function TypeChip({ type = 'alt', size = 'md', emoji, style }) {
  const t = TYPES[type] || TYPES.alt;
  const sizes = { sm: { h: 26, icon: 12, font: '700 11px var(--font-ui)', pad: '0 10px' }, md: { h: 34, icon: 15, font: '700 13px var(--font-ui)', pad: '0 14px' } };
  const s = sizes[size];
  return React.createElement(
    'span',
    { style: { display: 'inline-flex', alignItems: 'center', gap: 6, height: s.h, padding: s.pad, borderRadius: 'var(--radius-pill)', background: t.gradient, color: 'var(--text-on-gradient)', font: s.font, letterSpacing: '0.02em', ...style } },
    React.createElement('i', { className: `ph ${t.icon}`, style: { fontSize: s.icon } }),
    t.label,
    emoji && React.createElement('span', { style: { fontSize: s.icon, marginLeft: 2, opacity: 0.9 } }, emoji)
  );
}

export function TypeIcon({ type = 'alt', size = 44 }) {
  const t = TYPES[type] || TYPES.alt;
  return React.createElement(
    'div',
    { style: { width: size, height: size, borderRadius: size * 0.32, background: t.gradient, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 } },
    React.createElement('i', { className: `ph ${t.icon}`, style: { fontSize: size * 0.5, color: 'var(--text-on-gradient)' } })
  );
}
