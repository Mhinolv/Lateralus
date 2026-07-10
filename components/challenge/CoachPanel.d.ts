/**
 * @startingPoint section="Challenge" subtitle="On-device AI coach: idle / loading / result" viewport="700x180"
 */
export interface CoachPanelProps {
  state?: 'idle' | 'loading' | 'done';
  /** Coach's response: one sentence of praise + provocations, plain text/markdown. */
  notes?: string;
  onExpand?: () => void;
  style?: React.CSSProperties;
}
