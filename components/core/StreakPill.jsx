import React from 'react';

export function StreakPill({ days = 0, style }) {
  return React.createElement(
    'div',
    {
      style: {
        display: 'inline-flex', alignItems: 'center', gap: 6,
        height: 32, padding: '0 14px 0 10px', borderRadius: 'var(--radius-pill)',
        background: 'var(--glass-fill-raised)', border: '1px solid var(--glass-border)',
        color: 'var(--text-primary)', font: '700 14px var(--font-ui)',
        ...style,
      },
    },
    React.createElement('i', { className: 'ph ph-fire', style: { fontSize: 16, color: '#ffb545' } }),
    `${days} day${days === 1 ? '' : 's'}`
  );
}
