/**
 * @startingPoint section="Navigation" subtitle="3-tab bottom bar: Today / Journal / Insights" viewport="700x110"
 */
export interface TabBarProps {
  active?: 'today' | 'journal' | 'insights';
  onChange?: (key: string) => void;
  style?: React.CSSProperties;
}
