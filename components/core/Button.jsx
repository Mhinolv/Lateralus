import React from 'react';

const SIZES = {
  md: { h: 52, pad: '0 24px', font: 'var(--text-button)' },
  sm: { h: 40, pad: '0 18px', font: '700 14px var(--font-ui)' },
};

export function Button({ variant = 'primary', size = 'md', icon, disabled, style, children, ...rest }) {
  const s = SIZES[size] || SIZES.md;
  const base = {
    display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
    height: s.h, padding: s.pad, borderRadius: 'var(--radius-md)', border: 'none',
    font: s.font, cursor: disabled ? 'default' : 'pointer', opacity: disabled ? 0.4 : 1,
    transition: 'transform var(--duration-fast) var(--ease-standard), filter var(--duration-fast)',
  };
  const variants = {
    primary: { background: 'var(--accent)', color: '#ffffff', boxShadow: 'var(--shadow-button)' },
    secondary: { background: 'var(--glass-fill-raised)', color: 'var(--text-primary)', border: '1px solid var(--glass-border-strong)' },
    ghost: { background: 'transparent', color: 'var(--text-secondary)' },
    danger: { background: 'rgba(255,107,107,0.15)', color: 'var(--danger)' },
  };
  return React.createElement(
    'button',
    {
      disabled,
      style: { ...base, ...variants[variant], ...style },
      onMouseDown: (e) => { if (!disabled) e.currentTarget.style.transform = 'scale(0.97)'; },
      onMouseUp: (e) => { e.currentTarget.style.transform = 'scale(1)'; },
      onMouseLeave: (e) => { e.currentTarget.style.transform = 'scale(1)'; },
      ...rest,
    },
    icon && React.createElement('i', { className: `ph ${icon}`, style: { fontSize: 18 } }),
    children
  );
}
