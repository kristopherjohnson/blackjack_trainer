package trainer

import (
	"blackjack_trainer/internal/strategy"
	"testing"
)

// Test hand generation produces valid card combinations
func TestHandGeneration(t *testing.T) {
	baseTrainer := NewBaseTrainer()

	t.Run("PairHandGeneration", func(t *testing.T) {
		for _, pairValue := range []int{2, 3, 4, 5, 6, 7, 8, 9, 10, 11} {
			cards := baseTrainer.GenerateHandCards(strategy.HandTypePair, pairValue)

			if len(cards) != 2 {
				t.Errorf("Pair %d should have 2 cards, got %d", pairValue, len(cards))
			}
			if cards[0] != pairValue {
				t.Errorf("First card should be %d, got %d", pairValue, cards[0])
			}
			if cards[1] != pairValue {
				t.Errorf("Second card should be %d, got %d", pairValue, cards[1])
			}
		}
	})

	t.Run("SoftHandGeneration", func(t *testing.T) {
		for softTotal := 13; softTotal <= 21; softTotal++ { // A,2 through A,10 (13-21)
			cards := baseTrainer.GenerateHandCards(strategy.HandTypeSoft, softTotal)

			if len(cards) != 2 {
				t.Errorf("Soft %d should have 2 cards, got %d", softTotal, len(cards))
			}

			hasAce := false
			for _, card := range cards {
				if card == 11 {
					hasAce = true
					break
				}
			}
			if !hasAce {
				t.Errorf("Soft hand should contain an Ace (11): %v", cards)
			}

			otherCard := softTotal - 11
			hasOtherCard := false
			for _, card := range cards {
				if card == otherCard {
					hasOtherCard = true
					break
				}
			}
			if !hasOtherCard {
				t.Errorf("Soft %d should contain %d: %v", softTotal, otherCard, cards)
			}

			if otherCard < 2 || otherCard > 10 {
				t.Errorf("Other card %d should be 2-10", otherCard)
			}
		}
	})

	t.Run("HardHandValidCards", func(t *testing.T) {
		for total := 5; total <= 21; total++ { // Hard 5-21
			cards := baseTrainer.GenerateHandCards(strategy.HandTypeHard, total)

			// All cards must be valid (2-11)
			for _, card := range cards {
				if card < 2 || card > 11 {
					t.Errorf("Invalid card value %d in hard %d: %v", card, total, cards)
				}
			}

			// Cards must sum to the total
			sum := 0
			for _, card := range cards {
				sum += card
			}
			if sum != total {
				t.Errorf("Cards %v don't sum to %d (sum=%d)", cards, total, sum)
			}
		}
	})

	t.Run("HardHandNoAcesForLowTotals", func(t *testing.T) {
		for total := 5; total <= 10; total++ { // Hard 5-10 (11 can be a single Ace)
			cards := baseTrainer.GenerateHandCards(strategy.HandTypeHard, total)

			// For totals 5-10, we shouldn't need aces (would make it soft)
			for _, card := range cards {
				if card == 11 {
					t.Errorf("Hard %d shouldn't contain Ace: %v", total, cards)
				}
			}
		}
	})

	t.Run("HardHandRealisticCombinations", func(t *testing.T) {
		// Test many iterations to catch edge cases
		for iteration := 0; iteration < 100; iteration++ {
			for total := 12; total <= 21; total++ { // Hard 12-21
				cards := baseTrainer.GenerateHandCards(strategy.HandTypeHard, total)

				// All cards must be 2-10 (no aces in hard totals)
				for _, card := range cards {
					if card < 2 || card > 10 {
						t.Errorf("Hard total shouldn't contain Ace: %v for total %d", cards, total)
					}
				}

				// Should have reasonable number of cards
				if len(cards) > 6 {
					t.Errorf("Too many cards for hard %d: %v", total, cards)
				}
			}
		}
	})

	t.Run("EdgeCaseTotals", func(t *testing.T) {
		// Test hard 20 and 21
		for _, total := range []int{20, 21} {
			cards := baseTrainer.GenerateHandCards(strategy.HandTypeHard, total)

			// Should still be valid
			sum := 0
			for _, card := range cards {
				sum += card
			}
			if sum != total {
				t.Errorf("Cards should sum to %d, got %d", total, sum)
			}

			for _, card := range cards {
				if card < 2 || card > 10 {
					t.Errorf("Invalid card %d in hard %d", card, total)
				}
			}
		}
	})

	t.Run("SingleCardTotals", func(t *testing.T) {
		for total := 2; total <= 11; total++ { // 2-11
			cards := baseTrainer.GenerateHandCards(strategy.HandTypeHard, total)

			if total <= 11 {
				// Should be single card for low totals
				if len(cards) != 1 {
					t.Errorf("Total %d should be single card, got %d cards", total, len(cards))
				}
				if cards[0] != total {
					t.Errorf("Single card should be %d, got %d", total, cards[0])
				}
			}
		}
	})

	t.Run("NoInvalidCardValues", func(t *testing.T) {
		invalidValues := []int{0, 1, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21}

		for iteration := 0; iteration < 200; iteration++ { // Many iterations to catch rare cases
			for _, handType := range []strategy.HandType{strategy.HandTypeHard, strategy.HandTypeSoft, strategy.HandTypePair} {
				var totals []int

				switch handType {
				case strategy.HandTypePair:
					totals = []int{2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
				case strategy.HandTypeSoft:
					for i := 13; i <= 21; i++ {
						totals = append(totals, i)
					}
				case strategy.HandTypeHard:
					for i := 5; i <= 21; i++ {
						totals = append(totals, i)
					}
				}

				for _, total := range totals {
					cards := baseTrainer.GenerateHandCards(handType, total)

					for _, card := range cards {
						for _, invalid := range invalidValues {
							if card == invalid {
								t.Errorf("Invalid card %d in %s %d: %v", card, handType, total, cards)
							}
						}
					}
				}
			}
		}
	})

	t.Run("Hard18SpecificCase", func(t *testing.T) {
		// Test hard 18 many times to ensure no invalid cards
		for iteration := 0; iteration < 50; iteration++ {
			cards := baseTrainer.GenerateHandCards(strategy.HandTypeHard, 18)

			// Should sum to 18
			sum := 0
			for _, card := range cards {
				sum += card
			}
			if sum != 18 {
				t.Errorf("Cards should sum to 18, got %d: %v", sum, cards)
			}

			// All cards should be valid (2-10)
			for _, card := range cards {
				if card < 2 || card > 10 {
					t.Errorf("Invalid card %d in hard 18: %v", card, cards)
				}
			}

			// Should not contain the problematic card 16
			for _, card := range cards {
				if card == 16 {
					t.Errorf("Found invalid card 16 in: %v", cards)
				}
			}
		}
	})
}
