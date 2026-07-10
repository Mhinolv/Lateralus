/**
 * @startingPoint section="Core" subtitle="Circular tap target for close, favorite, dice, search" viewport="700x120"
 */
export interface IconButtonProps {
  /** Phosphor icon class, e.g. "ph-x". */
  icon: string;
  /** Toggled-on state (e.g. favorited star turns gold + filled). */
  active?: boolean;
  variant?: 'default' | 'plain';
  size?: number;
  onClick?: () => void;
  style?: React.CSSProperties;
}
