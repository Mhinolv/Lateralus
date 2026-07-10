import React from 'react';

export function EmptyState({ icon = 'ph-notebook', title, body, style }) {
  return React.createElement(
    'div',
    { style: { display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', gap: 8, padding: '48px 32px', ...style } },
    React.createElement('div', {
      style: { width: 64, height: 64, borderRadius: '50%', background: 'var(--glass-fill-raised)', border: '1px solid var(--glass-border)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 8 },
    }, React.createElement('i', { className: `ph ${icon}`, style: { fontSize: 28, color: 'var(--text-secondary)' } })),
    React.createElement('div', { style: { font: 'var(--text-title)', color: 'var(--text-primary)' } }, title),
    body && React.createElement('div', { style: { font: 'var(--text-body)', color: 'var(--text-tertiary)', maxWidth: 260 } }, body)
  );
}
