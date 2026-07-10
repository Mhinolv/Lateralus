/**
 * @startingPoint section="Core" subtitle="Primary/secondary/ghost/danger actions" viewport="700x160"
 */
export interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger';
  size?: 'md' | 'sm';
  /** Phosphor icon class, e.g. "ph-microphone". */
  icon?: string;
  disabled?: boolean;
  onClick?: () => void;
  style?: React.CSSProperties;
  children?: React.ReactNode;
}
