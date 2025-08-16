import type { HandType, Scenario, TrainingMode } from '@/types/strategy';
import { StrategyChart } from './strategy';

export abstract class TrainingSession {
  protected strategy: StrategyChart;
  public correctCount: number = 0;
  public totalCount: number = 0;
  
  constructor(public difficulty: string = 'normal') {
    this.strategy = new StrategyChart();
  }

  abstract get modeName(): string;
  abstract get maxQuestions(): number;
  abstract generateScenario(): Scenario;

  protected generateHandCards(handType: HandType, playerTotal: number): string[] {
    if (handType === 'pair') {
      const cardValue = playerTotal === 11 ? 'A' : playerTotal.toString();
      return [cardValue, cardValue];
    }
    
    if (handType === 'soft') {
      const otherCard = playerTotal - 11;
      const otherCardStr = otherCard === 1 ? 'A' : otherCard.toString();
      return ['A', otherCardStr];
    }
    
    // Hard totals - always generate at least 2 cards
    // For low totals, create two small cards
    
    // Generate two valid cards that sum to playerTotal
    const minFirst = 2;
    const maxFirst = Math.min(10, playerTotal - 2);
    
    // Ensure we can generate valid cards
    if (maxFirst < minFirst) {
      // For very low totals (5-6), use smallest possible cards
      if (playerTotal === 5) return ['2', '3'];
      if (playerTotal === 6) return ['2', '4'];
      if (playerTotal === 7) return ['3', '4'];
      if (playerTotal === 8) return ['3', '5'];
      // For other cases, generate multi-card hands
      const cards = ['2'];
      let remaining = playerTotal - 2;
      while (remaining >= 2) {
        const nextCard = Math.min(remaining, 10);
        cards.push(nextCard.toString());
        remaining -= nextCard;
      }
      return cards;
    }
    
    const firstCard = Math.floor(Math.random() * (maxFirst - minFirst + 1)) + minFirst;
    const secondCard = playerTotal - firstCard;
    
    if (secondCard > 10 || secondCard < 2) {
      // Generate multi-card hand
      const cards = [firstCard.toString()];
      let remaining = playerTotal - firstCard;
      
      while (remaining > 10) {
        const maxCard = Math.min(10, remaining - 2);
        if (maxCard < 2) break;
        const card = Math.floor(Math.random() * (maxCard - 2 + 1)) + 2;
        cards.push(card.toString());
        remaining -= card;
      }
      
      if (remaining >= 2) {
        cards.push(remaining.toString());
      }
      return cards;
    }
    
    return [firstCard.toString(), secondCard.toString()];
  }

  getCorrectAction(scenario: Scenario) {
    return this.strategy.getCorrectAction(scenario.handType, scenario.playerTotal, scenario.dealerCard);
  }

  getExplanation(scenario: Scenario) {
    return this.strategy.getExplanation(scenario.handType, scenario.playerTotal, scenario.dealerCard);
  }

  checkAnswer(userAction: string, correctAction: string): boolean {
    // Handle split variations
    const normalizedUser = userAction === 'P' ? 'Y' : userAction;
    return normalizedUser === correctAction;
  }
}

export class RandomTrainingSession extends TrainingSession {
  get modeName(): string {
    return 'Quick Practice';
  }

  get maxQuestions(): number {
    return 50;
  }

  generateScenario(): Scenario {
    const dealerCard = Math.floor(Math.random() * 10) + 2; // 2-11
    const adjustedDealer = dealerCard === 11 ? 11 : dealerCard;
    const handType = ['hard', 'soft', 'pair'][Math.floor(Math.random() * 3)] as HandType;

    let playerTotal: number;
    let cards: string[];

    if (handType === 'pair') {
      const pairValues = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
      playerTotal = pairValues[Math.floor(Math.random() * pairValues.length)];
      cards = this.generateHandCards(handType, playerTotal);
    } else if (handType === 'soft') {
      const otherCard = Math.floor(Math.random() * 8) + 2; // 2-9
      playerTotal = 11 + otherCard;
      cards = ['A', otherCard.toString()];
    } else {
      playerTotal = Math.floor(Math.random() * 16) + 5; // 5-20
      cards = this.generateHandCards(handType, playerTotal);
    }

    return {
      handType,
      playerTotal,
      dealerCard: adjustedDealer,
      cards
    };
  }
}

export class DealerGroupTrainingSession extends TrainingSession {
  private dealerGroup: string = '';

  get modeName(): string {
    return `Dealer ${this.dealerGroup} Cards`;
  }

  get maxQuestions(): number {
    return 50;
  }

  setDealerGroup(group: string): void {
    this.dealerGroup = group;
  }

  generateScenario(): Scenario {
    let dealerCard: number;
    
    switch (this.dealerGroup.toLowerCase()) {
      case 'weak':
        dealerCard = [4, 5, 6][Math.floor(Math.random() * 3)];
        break;
      case 'medium':
        dealerCard = [2, 3, 7, 8][Math.floor(Math.random() * 4)];
        break;
      case 'strong':
        dealerCard = [9, 10, 11][Math.floor(Math.random() * 3)];
        break;
      default:
        dealerCard = Math.floor(Math.random() * 10) + 2;
    }

    const handType = ['hard', 'soft', 'pair'][Math.floor(Math.random() * 3)] as HandType;
    let playerTotal: number;
    let cards: string[];

    if (handType === 'pair') {
      const pairValues = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
      playerTotal = pairValues[Math.floor(Math.random() * pairValues.length)];
      cards = this.generateHandCards(handType, playerTotal);
    } else if (handType === 'soft') {
      const otherCard = Math.floor(Math.random() * 8) + 2;
      playerTotal = 11 + otherCard;
      cards = ['A', otherCard.toString()];
    } else {
      playerTotal = Math.floor(Math.random() * 16) + 5;
      cards = this.generateHandCards(handType, playerTotal);
    }

    return {
      handType,
      playerTotal,
      dealerCard,
      cards
    };
  }
}

export class HandTypeTrainingSession extends TrainingSession {
  private handTypeChoice: HandType = 'hard';

  get modeName(): string {
    return `${this.handTypeChoice.charAt(0).toUpperCase() + this.handTypeChoice.slice(1)} Hands Only`;
  }

  get maxQuestions(): number {
    return 50;
  }

  setHandType(handType: HandType): void {
    this.handTypeChoice = handType;
  }

  generateScenario(): Scenario {
    const dealerCard = Math.floor(Math.random() * 10) + 2;
    const adjustedDealer = dealerCard === 11 ? 11 : dealerCard;
    
    let playerTotal: number;
    let cards: string[];

    if (this.handTypeChoice === 'hard') {
      playerTotal = Math.floor(Math.random() * 16) + 5; // 5-20
      cards = this.generateHandCards('hard', playerTotal);
    } else if (this.handTypeChoice === 'soft') {
      const otherCard = Math.floor(Math.random() * 8) + 2; // 2-9
      playerTotal = 11 + otherCard;
      cards = ['A', otherCard.toString()];
    } else { // pairs
      const pairValues = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
      playerTotal = pairValues[Math.floor(Math.random() * pairValues.length)];
      cards = this.generateHandCards('pair', playerTotal);
    }

    return {
      handType: this.handTypeChoice,
      playerTotal,
      dealerCard: adjustedDealer,
      cards
    };
  }
}

export class AbsoluteTrainingSession extends TrainingSession {
  get modeName(): string {
    return 'Absolutes Drill';
  }

  get maxQuestions(): number {
    return 20;
  }

  generateScenario(): Scenario {
    const absolutes = [
      { handType: 'pair' as HandType, playerTotal: 11, cards: ['A', 'A'] },
      { handType: 'pair' as HandType, playerTotal: 8, cards: ['8', '8'] },
      { handType: 'pair' as HandType, playerTotal: 10, cards: ['10', '10'] },
      { handType: 'pair' as HandType, playerTotal: 5, cards: ['5', '5'] },
      { handType: 'hard' as HandType, playerTotal: 17, cards: null },
      { handType: 'hard' as HandType, playerTotal: 18, cards: null },
      { handType: 'hard' as HandType, playerTotal: 19, cards: null },
      { handType: 'hard' as HandType, playerTotal: 20, cards: null },
      { handType: 'soft' as HandType, playerTotal: 19, cards: ['A', '8'] },
      { handType: 'soft' as HandType, playerTotal: 20, cards: ['A', '9'] },
    ];

    const scenario = absolutes[Math.floor(Math.random() * absolutes.length)];
    const dealerCard = Math.floor(Math.random() * 10) + 2;
    const adjustedDealer = dealerCard === 11 ? 11 : dealerCard;

    let cards = scenario.cards;
    if (cards === null) {
      cards = this.generateHandCards(scenario.handType, scenario.playerTotal);
    }

    return {
      handType: scenario.handType,
      playerTotal: scenario.playerTotal,
      dealerCard: adjustedDealer,
      cards
    };
  }
}

export const TRAINING_MODES: TrainingMode[] = [
  {
    id: 'random',
    name: 'Quick Practice',
    description: 'Random practice with all hand types',
    icon: '🎲'
  },
  {
    id: 'dealer',
    name: 'Dealer Strength',
    description: 'Practice by dealer card groups',
    icon: '👨‍💼'
  },
  {
    id: 'handType',
    name: 'Hand Types',
    description: 'Focus on specific hand categories',
    icon: '🃏'
  },
  {
    id: 'absolute',
    name: 'Absolutes',
    description: 'Practice never/always rules',
    icon: '⚡'
  }
];