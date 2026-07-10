import React from 'react';

const LABELS = { constraint: 'The constraint', twist: 'The twist', 'merge-with': 'Merge with', 'seen-by': 'Seen by' };

export function ModifierPanel({ kind = 'twist', value, tint = 'var(--accent)', style }) {
  return React.createElement(
    'div',
    {
      style: {
        display: 'flex', flexDirection: 'column', gap: 4, padding: '12px 14px',
        borderRadius: 'var(--radius-md)', background: `color-mix(in srgb, ${tint} 16%, transparent)`,
        border: `1px solid color-mix(in srgb, ${tint} 40%, transparent)`,
        marginTop: 14,
        ...style,
      },
    },
    React.createElement('div', { style: { font: 'var(--text-label)', letterSpacing: 'var(--tracking-label)', textTransform: 'uppercase', color: tint } }, LABELS[kind] || kind),
    React.createElement('div', { style: { font: 'var(--text-body-lg)', color: 'var(--text-primary)' } }, value)
  );
}
