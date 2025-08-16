export type Action = 'H' | 'S' | 'D' | 'Y';
export type HandType = 'hard' | 'soft' | 'pair';
export type DealerGroup = 'weak' | 'medium' | 'strong';

export interface Scenario {
  handType: HandType;
  playerTotal: number;
  dealerCard: number;
  cards?: string[];
}

export interface SessionStats {
  correct: number;
  total: number;
  accuracy: number;
  categoryStats: Record<string, { correct: number; total: number }>;
}

export interface TrainingMode {
  id: string;
  name: string;
  description: string;
  icon: string;
}

export interface FeedbackData {
  isCorrect: boolean;
  userAction: Action;
  correctAction: Action;
  explanation: string;
  scenario: Scenario;
}