import React from 'react';

/**
 * @startingPoint section="Core" subtitle="Glassmorphic surface primitive used by every card in the app" viewport="700x200"
 */
export interface GlassCardProps {
  /** Fill/border intensity. */
  variant?: 'default' | 'raised' | 'pressed';
  /** Corner radius token. */
  radius?: 'sm' | 'md' | 'lg' | 'xl';
  /** CSS padding value. */
  padding?: string;
  /** Optional CSS background (color/gradient) rendered as a blurred glow behind the content — used for the aurora effect. */
  glow?: string;
  style?: React.CSSProperties;
  children?: React.ReactNode;
}
