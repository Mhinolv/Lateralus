import React from 'react';

export function IconButton({ icon, active, variant = 'default', size = 44, style, ...rest }) {
  const variants = {
    default: { background: 'var(--glass-fill-raised)', border: '1px solid var(--glass-border)', color: 'var(--text-primary)' },
    plain: { background: 'transparent', border: 'none', color: 'var(--text-secondary)' },
  };
  return React.createElement(
    'button',
    {
      style: {
        width: size, height: size, borderRadius: '50%',
        display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
        cursor: 'pointer',
        color: active ? 'var(--favorite)' : variants[variant].color,
        background: variants[variant].background,
        border: variants[variant].border,
        transition: 'transform var(--duration-fast) var(--ease-standard)',
        ...style,
      },
      ...rest,
    },
    React.createElement('i', { className: `ph ${active ? 'ph-fill' : ''} ${icon}`.trim(), style: { fontSize: size * 0.45 } })
  );
}
