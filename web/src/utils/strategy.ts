import type { Action, HandType } from '@/types/strategy';

export class StrategyChart {
  private hardTotals: Map<string, Action>;
  private softTotals: Map<string, Action>;
  private pairs: Map<string, Action>;
  private mnemonics: Record<string, string>;
  public dealerGroups: Record<string, number[]>;

  constructor() {
    this.hardTotals = this.buildHardTotals();
    this.softTotals = this.buildSoftTotals();
    this.pairs = this.buildPairs();
    this.mnemonics = this.buildMnemonics();
    this.dealerGroups = {
      weak: [4, 5, 6],
      medium: [2, 3, 7, 8],
      strong: [9, 10, 11]
    };
  }

  private buildHardTotals(): Map<string, Action> {
    const chart = new Map<string, Action>();

    // Hard 5-8: Always hit
    for (let total = 5; total <= 8; total++) {
      for (let dealer = 2; dealer <= 11; dealer++) {
        chart.set(`${total},${dealer}`, 'H');
      }
    }

    // Hard 9: Double vs 3-6, otherwise hit
    for (let dealer = 2; dealer <= 11; dealer++) {
      if (dealer >= 3 && dealer <= 6) {
        chart.set(`9,${dealer}`, 'D');
      } else {
        chart.set(`9,${dealer}`, 'H');
      }
    }

    // Hard 10: Double vs 2-9, otherwise hit
    for (let dealer = 2; dealer <= 11; dealer++) {
      if (dealer >= 2 && dealer <= 9) {
        chart.set(`10,${dealer}`, 'D');
      } else {
        chart.set(`10,${dealer}`, 'H');
      }
    }

    // Hard 11: Double vs 2-10, hit vs Ace
    for (let dealer = 2; dealer <= 11; dealer++) {
      if (dealer <= 10) {
        chart.set(`11,${dealer}`, 'D');
      } else {
        chart.set(`11,${dealer}`, 'H');
      }
    }

    // Hard 12: Stand vs 4-6, otherwise hit
    for (let dealer = 2; dealer <= 11; dealer++) {
      if (dealer >= 4 && dealer <= 6) {
        chart.set(`12,${dealer}`, 'S');
      } else {
        chart.set(`12,${dealer}`, 'H');
      }
    }

    // Hard 13-16: Stand vs 2-6, otherwise hit
    for (let total = 13; total <= 16; total++) {
      for (let dealer = 2; dealer <= 11; dealer++) {
        if (dealer >= 2 && dealer <= 6) {
          chart.set(`${total},${dealer}`, 'S');
        } else {
          chart.set(`${total},${dealer}`, 'H');
        }
      }
    }

    // Hard 17+: Always stand
    for (let total = 17; total <= 21; total++) {
      for (let dealer = 2; dealer <= 11; dealer++) {
        chart.set(`${total},${dealer}`, 'S');
      }
    }

    return chart;
  }

  private buildSoftTotals(): Map<string, Action> {
    const chart = new Map<string, Action>();

    // Soft 13-14 (A,2-A,3): Double vs 5-6, otherwise hit
    for (const total of [13, 14]) {
      for (let dealer = 2; dealer <= 11; dealer++) {
        if (dealer >= 5 && dealer <= 6) {
          chart.set(`${total},${dealer}`, 'D');
        } else {
          chart.set(`${total},${dealer}`, 'H');
        }
      }
    }

    // Soft 15-16 (A,4-A,5): Double vs 4-6, otherwise hit
    for (const total of [15, 16]) {
      for (let dealer = 2; dealer <= 11; dealer++) {
        if (dealer >= 4 && dealer <= 6) {
          chart.set(`${total},${dealer}`, 'D');
        } else {
          chart.set(`${total},${dealer}`, 'H');
        }
      }
    }

    // Soft 17 (A,6): Double vs 3-6, otherwise hit
    for (let dealer = 2; dealer <= 11; dealer++) {
      if (dealer >= 3 && dealer <= 6) {
        chart.set(`17,${dealer}`, 'D');
      } else {
        chart.set(`17,${dealer}`, 'H');
      }
    }

    // Soft 18 (A,7): Stand vs 2,7,8; Double vs 3-6; Hit vs 9,10,A
    for (let dealer = 2; dealer <= 11; dealer++) {
      if ([2, 7, 8].includes(dealer)) {
        chart.set(`18,${dealer}`, 'S');
      } else if (dealer >= 3 && dealer <= 6) {
        chart.set(`18,${dealer}`, 'D');
      } else {
        chart.set(`18,${dealer}`, 'H');
      }
    }

    // Soft 19-21: Always stand
    for (const total of [19, 20, 21]) {
      for (let dealer = 2; dealer <= 11; dealer++) {
        chart.set(`${total},${dealer}`, 'S');
      }
    }

    return chart;
  }

  private buildPairs(): Map<string, Action> {
    const chart = new Map<string, Action>();

    // A,A: Always split
    for (let dealer = 2; dealer <= 11; dealer++) {
      chart.set(`11,${dealer}`, 'Y');
    }

    // 2,2 and 3,3: Split vs 2-7, otherwise hit
    for (const pairVal of [2, 3]) {
      for (let dealer = 2; dealer <= 11; dealer++) {
        if (dealer >= 2 && dealer <= 7) {
          chart.set(`${pairVal},${dealer}`, 'Y');
        } else {
          chart.set(`${pairVal},${dealer}`, 'H');
        }
      }
    }

    // 4,4: Split vs 5-6, otherwise hit
    for (let dealer = 2; dealer <= 11; dealer++) {
      if (dealer >= 5 && dealer <= 6) {
        chart.set(`4,${dealer}`, 'Y');
      } else {
        chart.set(`4,${dealer}`, 'H');
      }
    }

    // 5,5: Never split, treat as hard 10
    for (let dealer = 2; dealer <= 11; dealer++) {
      if (dealer >= 2 && dealer <= 9) {
        chart.set(`5,${dealer}`, 'D');
      } else {
        chart.set(`5,${dealer}`, 'H');
      }
    }

    // 6,6: Split vs 2-6, otherwise hit
    for (let dealer = 2; dealer <= 11; dealer++) {
      if (dealer >= 2 && dealer <= 6) {
        chart.set(`6,${dealer}`, 'Y');
      } else {
        chart.set(`6,${dealer}`, 'H');
      }
    }

    // 7,7: Split vs 2-7, otherwise hit
    for (let dealer = 2; dealer <= 11; dealer++) {
      if (dealer >= 2 && dealer <= 7) {
        chart.set(`7,${dealer}`, 'Y');
      } else {
        chart.set(`7,${dealer}`, 'H');
      }
    }

    // 8,8: Always split
    for (let dealer = 2; dealer <= 11; dealer++) {
      chart.set(`8,${dealer}`, 'Y');
    }

    // 9,9: Split vs 2-9 except 7, stand vs 7,10,A
    for (let dealer = 2; dealer <= 11; dealer++) {
      if ([7, 10, 11].includes(dealer)) {
        chart.set(`9,${dealer}`, 'S');
      } else {
        chart.set(`9,${dealer}`, 'Y');
      }
    }

    // 10,10: Never split, always stand
    for (let dealer = 2; dealer <= 11; dealer++) {
      chart.set(`10,${dealer}`, 'S');
    }

    return chart;
  }

  private buildMnemonics(): Record<string, string> {
    return {
      dealer_weak: "Dealer bust cards (4,5,6) = player gets greedy",
      always_split: "Aces and eights, don't hesitate",
      never_split: "Tens and fives, keep them alive",
      teens_vs_strong: "Teens stay vs weak, flee from strong",
      soft_17: "A,7 is the tricky soft hand",
      hard_12: "12 is the exception - only stand vs 4,5,6",
      doubles: "Double when dealer is weak and you can improve"
    };
  }

  getCorrectAction(handType: HandType, playerTotal: number, dealerCard: number): Action {
    const key = `${playerTotal},${dealerCard}`;
    
    if (handType === 'pair') {
      return this.pairs.get(key) ?? 'H';
    }
    if (handType === 'soft') {
      return this.softTotals.get(key) ?? 'H';
    }
    // hard
    return this.hardTotals.get(key) ?? 'H';
  }

  getExplanation(handType: HandType, playerTotal: number, dealerCard: number): string {
    const explanations: Record<string, string> = {
      'pair,11': this.mnemonics.always_split,
      'pair,8': this.mnemonics.always_split,
      'pair,10': this.mnemonics.never_split,
      'pair,5': this.mnemonics.never_split,
      'soft,18': this.mnemonics.soft_17,
      'hard,12': this.mnemonics.hard_12
    };

    const key = `${handType},${playerTotal}`;
    if (key in explanations) {
      return explanations[key];
    }

    if (this.dealerGroups.weak.includes(dealerCard)) {
      return this.mnemonics.dealer_weak;
    }
    if (playerTotal >= 13 && playerTotal <= 16 && this.dealerGroups.strong.includes(dealerCard)) {
      return this.mnemonics.teens_vs_strong;
    }
    return "Follow basic strategy patterns";
  }

  isAbsoluteRule(handType: HandType, playerTotal: number): boolean {
    const absolutes = [
      'pair,11',  // Always split A,A
      'pair,8',   // Always split 8,8
      'pair,10',  // Never split 10,10
      'pair,5'    // Never split 5,5
    ];

    // Add hard 17+ always stand
    if (handType === 'hard' && playerTotal >= 17) {
      return true;
    }

    // Add soft 19+ always stand
    if (handType === 'soft' && playerTotal >= 19) {
      return true;
    }

    return absolutes.includes(`${handType},${playerTotal}`);
  }
}