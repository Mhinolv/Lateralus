/**
 * @startingPoint section="Forms" subtitle="Voice-note recorder: idle / recording (pulsing) / permission-denied" viewport="700x160"
 */
export interface MicButtonProps {
  state?: 'idle' | 'recording' | 'denied';
  onClick?: () => void;
  style?: React.CSSProperties;
}
