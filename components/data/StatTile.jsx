import React from 'react';

export function StatTile({ icon, value, label, style }) {
  return React.createElement(
    'div',
    { style: { display: 'flex', flexDirection: 'column', gap: 6, padding: 'var(--card-padding)', borderRadius: 'var(--radius-lg)', background: 'var(--glass-fill)', border: '1px solid var(--glass-border)', flex: 1, ...style } },
    React.createElement('i', { className: `ph ${icon}`, style: { fontSize: 20, color: 'var(--accent)' } }),
    React.createElement('div', { style: { font: '600 28px var(--font-display)', color: 'var(--text-primary)' } }, value),
    React.createElement('div', { style: { font: 'var(--text-caption)', color: 'var(--text-tertiary)' } }, label)
  );
}
