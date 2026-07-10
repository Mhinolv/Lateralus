/**
 * @startingPoint section="Challenge" subtitle="Type identity chip + icon glyph, all 12 disciplines" viewport="700x200"
 */
export interface TypeChipProps {
  /** One of: alt, coin, twist, reality, fusion, backstory, perspective, redefine. */
  type?: string;
  size?: 'sm' | 'md';
  /** Optional emoji from the PromptItem's stored-but-unused emoji field, shown as a small secondary accent. */
  emoji?: string;
  style?: React.CSSProperties;
}

export interface TypeIconProps {
  type?: string;
  size?: number;
}
