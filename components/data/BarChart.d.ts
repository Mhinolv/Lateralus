/**
 * @startingPoint section="Data" subtitle="Discipline balance — attempt counts across the 12 challenge types" viewport="700x300"
 */
export interface BarChartDatum {
  /** Challenge type key (alt, coin, twist, reality, fusion, backstory, perspective, redefine). */
  type: string;
  count: number;
}

export interface BarChartProps {
  data: BarChartDatum[];
  style?: React.CSSProperties;
}
