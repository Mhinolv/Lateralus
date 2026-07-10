/**
 * @startingPoint section="Challenge" subtitle="Highlighted constraint / twist / merge-with / seen-by panel" viewport="700x140"
 */
export interface ModifierPanelProps {
  kind?: 'constraint' | 'twist' | 'merge-with' | 'seen-by';
  value: string;
  /** Tint color, normally the active challenge type's accent (var(--type-*-1)). */
  tint?: string;
  style?: React.CSSProperties;
}
