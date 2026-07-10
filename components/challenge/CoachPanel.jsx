import React from 'react';
import { Button } from '../core/Button.jsx';

export function CoachPanel({ state = 'idle', notes, onExpand, style }) {
  return React.createElement(
    'div',
    { style: { display: 'flex', flexDirection: 'column', gap: 12, ...style } },
    React.createElement('div', { style: { display: 'flex', alignItems: 'center', gap: 8 } },
      React.createElement('i', { className: 'ph ph-sparkle', style: { fontSize: 16, color: 'var(--accent)' } }),
      React.createElement('span', { style: { font: 'var(--text-label)', letterSpacing: 'var(--tracking-label)', textTransform: 'uppercase', color: 'var(--text-secondary)' } }, 'Coach')
    ),
    state === 'idle' && React.createElement(Button, { variant: 'secondary', icon: 'ph-sparkle', onClick: onExpand }, 'Expand with on-device AI'),
    state === 'loading' && React.createElement('div', { style: { font: 'var(--text-body)', color: 'var(--text-tertiary)', display: 'flex', alignItems: 'center', gap: 8 } },
      React.createElement('i', { className: 'ph ph-circle-notch', style: { fontSize: 15, animation: 'spin 1s linear infinite' } }), 'Thinking alongside you…'
    ),
    state === 'done' && React.createElement('div', { style: { font: 'var(--text-body)', color: 'var(--text-primary)', lineHeight: 1.55 } }, notes)
  );
}
