import type { SessionStats, HandType } from '@/types/strategy';

export class Statistics {
  private sessionData: SessionStats;

  constructor() {
    this.sessionData = {
      correct: 0,
      total: 0,
      accuracy: 0,
      categoryStats: {}
    };
  }

  recordAttempt(handType: HandType, dealerStrength: string, correct: boolean) {
    // Update overall stats
    this.sessionData.total++;
    if (correct) {
      this.sessionData.correct++;
    }
    this.sessionData.accuracy = (this.sessionData.correct / this.sessionData.total) * 100;

    // Update category stats
    const category = `${handType}-${dealerStrength}`;
    if (!this.sessionData.categoryStats[category]) {
      this.sessionData.categoryStats[category] = { correct: 0, total: 0 };
    }
    
    this.sessionData.categoryStats[category].total++;
    if (correct) {
      this.sessionData.categoryStats[category].correct++;
    }

    // Update hand type stats
    if (!this.sessionData.categoryStats[handType]) {
      this.sessionData.categoryStats[handType] = { correct: 0, total: 0 };
    }
    
    this.sessionData.categoryStats[handType].total++;
    if (correct) {
      this.sessionData.categoryStats[handType].correct++;
    }

    // Update dealer strength stats
    if (!this.sessionData.categoryStats[dealerStrength]) {
      this.sessionData.categoryStats[dealerStrength] = { correct: 0, total: 0 };
    }
    
    this.sessionData.categoryStats[dealerStrength].total++;
    if (correct) {
      this.sessionData.categoryStats[dealerStrength].correct++;
    }
  }

  getDealerStrength(dealerCard: number): string {
    if ([4, 5, 6].includes(dealerCard)) return 'weak';
    if ([2, 3, 7, 8].includes(dealerCard)) return 'medium';
    return 'strong'; // 9, 10, 11 (Ace)
  }

  getSessionStats(): SessionStats {
    return { ...this.sessionData };
  }

  reset() {
    this.sessionData = {
      correct: 0,
      total: 0,
      accuracy: 0,
      categoryStats: {}
    };
  }

  getCategoryAccuracy(category: string): number {
    const stats = this.sessionData.categoryStats[category];
    if (!stats || stats.total === 0) return 0;
    return (stats.correct / stats.total) * 100;
  }
}