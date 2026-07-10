import React from 'react';
import { TYPES } from '../challenge/TypeChip.jsx';

export function BarChart({ data, style }) {
  const max = Math.max(...data.map((d) => d.count), 1);
  return React.createElement(
    'div',
    { style: { display: 'flex', flexDirection: 'column', gap: 12, ...style } },
    data.map((d, i) => {
      const t = TYPES[d.type];
      return React.createElement(
        'div',
        { key: i, style: { display: 'flex', alignItems: 'center', gap: 10 } },
        React.createElement('div', { style: { width: 110, font: 'var(--text-caption)', color: 'var(--text-secondary)', flexShrink: 0 } }, t.label),
        React.createElement('div', { style: { flex: 1, height: 10, borderRadius: 'var(--radius-pill)', background: 'var(--glass-fill)', overflow: 'hidden' } },
          React.createElement('div', { style: { width: `${(d.count / max) * 100}%`, height: '100%', background: t.gradient, borderRadius: 'var(--radius-pill)' } })
        ),
        React.createElement('div', { style: { width: 24, textAlign: 'right', font: 'var(--text-mono-sm)', color: 'var(--text-tertiary)' } }, d.count)
      );
    })
  );
}
