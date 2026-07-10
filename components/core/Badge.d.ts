/**
 * @startingPoint section="Core" subtitle="Daily / favorite / saved tags on journal rows" viewport="700x100"
 */
export interface BadgeProps {
  kind?: 'daily' | 'favorite' | 'success';
  children?: React.ReactNode;
  style?: React.CSSProperties;
}
