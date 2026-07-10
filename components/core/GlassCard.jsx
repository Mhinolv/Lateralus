import React from 'react';

const RADIUS = { sm: 'var(--radius-sm)', md: 'var(--radius-md)', lg: 'var(--radius-lg)', xl: 'var(--radius-xl)' };

export function GlassCard({ variant = 'default', radius = 'lg', padding = 'var(--card-padding)', glow, style, children, ...rest }) {
  const fill = variant === 'raised' ? 'var(--glass-fill-raised)' : variant === 'pressed' ? 'var(--glass-fill-pressed)' : 'var(--glass-fill)';
  const border = variant === 'raised' ? 'var(--glass-border-strong)' : 'var(--glass-border)';
  return React.createElement(
    'div',
    {
      style: {
        position: 'relative',
        background: fill,
        border: `1px solid ${border}`,
        borderRadius: RADIUS[radius] || radius,
        backdropFilter: 'blur(var(--blur-glass))',
        WebkitBackdropFilter: 'blur(var(--blur-glass))',
        boxShadow: variant === 'raised' ? 'var(--shadow-card-raised)' : 'var(--shadow-card)',
        padding,
        overflow: 'hidden',
        ...style,
      },
      ...rest,
    },
    glow && React.createElement('div', {
      style: {
        position: 'absolute', inset: '-40% -20% auto -20%', height: '160%',
        background: glow, filter: 'blur(50px)', opacity: 0.35, pointerEvents: 'none',
      },
    }),
    React.createElement('div', { style: { position: 'relative' } }, children)
  );
}
