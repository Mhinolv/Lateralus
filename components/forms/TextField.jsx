import React from 'react';

export function TextField({ variant = 'search', value, onChange, placeholder, wordCount, style }) {
  if (variant === 'search') {
    return React.createElement(
      'div',
      { style: { display: 'flex', alignItems: 'center', gap: 8, height: 44, padding: '0 14px', borderRadius: 'var(--radius-md)', background: 'var(--glass-fill)', border: '1px solid var(--glass-border)', ...style } },
      React.createElement('i', { className: 'ph ph-magnifying-glass', style: { fontSize: 16, color: 'var(--text-tertiary)' } }),
      React.createElement('input', {
        value, onChange, placeholder: placeholder || 'Search your journal',
        style: { flex: 1, background: 'transparent', border: 'none', outline: 'none', font: 'var(--text-body)', color: 'var(--text-primary)' },
      })
    );
  }
  return React.createElement(
    'div',
    { style: { display: 'flex', flexDirection: 'column', borderRadius: 'var(--radius-lg)', background: 'var(--glass-fill)', border: '1px solid var(--glass-border)', padding: 'var(--card-padding)', gap: 10, ...style } },
    React.createElement('textarea', {
      value, onChange, placeholder: placeholder || 'Type your answer…',
      style: { flex: 1, minHeight: 120, background: 'transparent', border: 'none', outline: 'none', resize: 'none', font: 'var(--text-body-lg)', color: 'var(--text-primary)', lineHeight: 1.5 },
    }),
    React.createElement('div', { style: { display: 'flex', justifyContent: 'flex-end', font: 'var(--text-mono-sm)', color: 'var(--text-tertiary)' } }, `${wordCount ?? 0} words`)
  );
}
