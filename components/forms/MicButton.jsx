import React from 'react';

export function MicButton({ state = 'idle', onClick, style }) {
  const recording = state === 'recording';
  return React.createElement(
    React.Fragment,
    null,
    React.createElement('button', {
      onClick,
      style: {
        width: 56, height: 56, borderRadius: '50%', border: 'none', cursor: 'pointer',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        background: recording ? 'var(--danger)' : 'var(--accent)',
        boxShadow: recording ? '0 0 0 8px rgba(255,107,107,0.18)' : 'var(--shadow-button)',
        transition: 'box-shadow var(--duration-standard) var(--ease-standard)',
        animation: recording ? 'lat-mic-pulse 1.4s ease-out infinite' : 'none',
        ...style,
      },
    }, React.createElement('i', { className: `ph ${recording ? 'ph-fill' : ''} ph-microphone`.trim(), style: { fontSize: 22, color: '#fff' } })),
    state === 'denied' && React.createElement('div', { style: { font: 'var(--text-caption)', color: 'var(--danger)', marginTop: 8, maxWidth: 220, textAlign: 'center' } }, 'Microphone access is off — enable it in iOS Settings to record a voice note.')
  );
}
