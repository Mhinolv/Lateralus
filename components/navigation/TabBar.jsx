import React from 'react';

const TABS = [
  { key: 'today', label: 'Today', icon: 'ph-house' },
  { key: 'journal', label: 'Journal', icon: 'ph-books' },
  { key: 'insights', label: 'Insights', icon: 'ph-chart-bar' },
];

export function TabBar({ active = 'today', onChange, style }) {
  return React.createElement(
    'div',
    {
      style: {
        display: 'flex', height: 'var(--tab-bar-height)', paddingBottom: 20,
        background: 'rgba(11,14,30,0.75)', backdropFilter: 'blur(24px)', WebkitBackdropFilter: 'blur(24px)',
        borderTop: '1px solid var(--line-hairline)',
        ...style,
      },
    },
    TABS.map((t) => React.createElement(
      'button',
      {
        key: t.key,
        onClick: () => onChange && onChange(t.key),
        style: { flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 4, background: 'transparent', border: 'none', cursor: 'pointer', color: active === t.key ? 'var(--text-primary)' : 'var(--text-tertiary)' },
      },
      React.createElement('i', { className: `ph ${active === t.key ? 'ph-fill' : ''} ${t.icon}`.trim(), style: { fontSize: 22 } }),
      React.createElement('span', { style: { font: '600 11px var(--font-ui)' } }, t.label)
    ))
  );
}
