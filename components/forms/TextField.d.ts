/**
 * @startingPoint section="Forms" subtitle="Search bar + multiline answer editor with live word count" viewport="700x260"
 */
export interface TextFieldProps {
  variant?: 'search' | 'editor';
  value?: string;
  onChange?: (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => void;
  placeholder?: string;
  /** Only used by the editor variant. */
  wordCount?: number;
  style?: React.CSSProperties;
}
