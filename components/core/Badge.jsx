import React from 'react';

const KINDS = {
  daily: { bg: 'var(--accent-soft)', color: 'var(--accent)', icon: 'ph-sun' },
  favorite: { bg: 'rgba(255,200,87,0.16)', color: 'var(--favorite)', icon: 'ph-star ph-fill' },
  success: { bg: 'rgba(53,212,160,0.16)', color: 'var(--success)', icon: 'ph-check' },
};

export function Badge({ kind = 'daily', children, style }) {
  const k = KINDS[kind] || KINDS.daily;
  return React.createElement(
    'span',
    {
      style: {
        display: 'inline-flex', alignItems: 'center', gap: 4,
        height: 22, padding: '0 8px', borderRadius: 'var(--radius-pill)',
        background: k.bg, color: k.color,
        font: '700 11px/1 var(--font-ui)', letterSpacing: '0.03em', textTransform: 'uppercase',
        ...style,
      },
    },
    React.createElement('i', { className: `ph ${k.icon}`, style: { fontSize: 11 } }),
    children
  );
}
