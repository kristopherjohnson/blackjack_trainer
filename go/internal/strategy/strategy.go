// Package strategy provides blackjack basic strategy chart implementation.
//
// This package encapsulates the optimal basic strategy for blackjack based on
// standard casino rules: 4-8 decks, dealer stands on soft 17, double after
// split allowed, surrender not allowed.
//
// The strategy chart covers three main categories:
// - Hard totals (5-21): Hands without aces or where ace counts as 1
// - Soft totals (13-21): Hands with ace counting as 11 (A,2 through A,9)
// - Pairs (2,2 through A,A): Identical card pairs for split decisions
//
// Action codes:
// - H: Hit (take another card)
// - S: Stand (keep current total)
// - D: Double down (double bet, take exactly one more card)
// - Y: Split (for pairs - split into two separate hands)
//
// The package also provides:
// - Explanatory mnemonics for learning key patterns
// - Dealer strength groupings (weak/medium/strong)
// - Absolute rule identification for never/always scenarios
//
// All strategy decisions are based on mathematically optimal play that
// minimizes the house edge over the long term.
package strategy

import (
	"fmt"
)

// StrategyChart represents the complete blackjack basic strategy chart.
type StrategyChart struct {
	hardTotals   map[HandKey]rune
	softTotals   map[HandKey]rune
	pairs        map[HandKey]rune
	mnemonics    map[string]string
	dealerGroups map[string][]int
}

// HandKey represents a (player_total, dealer_card) combination.
type HandKey struct {
	PlayerTotal int
	DealerCard  int
}

// New creates a new strategy chart with all data initialized.
func New() *StrategyChart {
	chart := &StrategyChart{
		hardTotals:   make(map[HandKey]rune),
		softTotals:   make(map[HandKey]rune),
		pairs:        make(map[HandKey]rune),
		mnemonics:    make(map[string]string),
		dealerGroups: make(map[string][]int),
	}

	chart.buildHardTotals()
	chart.buildSoftTotals()
	chart.buildPairs()
	chart.buildMnemonics()
	chart.buildDealerGroups()

	return chart
}

// GetCorrectAction returns the correct action for a given scenario.
func (c *StrategyChart) GetCorrectAction(handType string, playerTotal, dealerCard int) rune {
	key := HandKey{PlayerTotal: playerTotal, DealerCard: dealerCard}

	switch handType {
	case "pair":
		if action, exists := c.pairs[key]; exists {
			return action
		}
	case "soft":
		if action, exists := c.softTotals[key]; exists {
			return action
		}
	case "hard":
		if action, exists := c.hardTotals[key]; exists {
			return action
		}
	}
	return 'H' // Default to hit
}

// GetExplanation returns an explanation/mnemonic for a given scenario.
func (c *StrategyChart) GetExplanation(handType string, playerTotal, dealerCard int) string {
	// Specific explanations for key scenarios
	switch handType {
	case "pair":
		switch playerTotal {
		case 11: // A,A
			return c.mnemonics["always_split"]
		case 8: // 8,8
			return c.mnemonics["always_split"]
		case 10: // 10,10
			return c.mnemonics["never_split"]
		case 5: // 5,5
			return c.mnemonics["never_split"]
		}
	case "soft":
		if playerTotal == 18 { // A,7
			return c.mnemonics["soft_17"]
		}
	case "hard":
		if playerTotal == 12 {
			return c.mnemonics["hard_12"]
		}
	}

	// Dealer strength based explanations
	if weakCards, exists := c.dealerGroups["weak"]; exists {
		for _, card := range weakCards {
			if card == dealerCard {
				return c.mnemonics["dealer_weak"]
			}
		}
	}

	if strongCards, exists := c.dealerGroups["strong"]; exists {
		if playerTotal >= 13 && playerTotal <= 16 {
			for _, card := range strongCards {
				if card == dealerCard {
					return c.mnemonics["teens_vs_strong"]
				}
			}
		}
	}

	return "Follow basic strategy patterns"
}

// IsAbsoluteRule checks if a scenario represents an absolute rule (always/never).
func (c *StrategyChart) IsAbsoluteRule(handType string, playerTotal, dealerCard int) bool {
	switch handType {
	case "pair":
		// Pair absolutes: A,A (11), 8,8, 10,10, 5,5
		return playerTotal == 11 || playerTotal == 8 || playerTotal == 10 || playerTotal == 5
	case "hard":
		// Hard 17+ always stand
		return playerTotal >= 17
	case "soft":
		// Soft 19+ always stand
		return playerTotal >= 19
	}
	return false
}

// GetDealerGroups returns the dealer strength groups.
func (c *StrategyChart) GetDealerGroups() map[string][]int {
	return c.dealerGroups
}

func (c *StrategyChart) buildHardTotals() {
	// Hard 5-8: Always hit
	for total := 5; total <= 8; total++ {
		for dealer := 2; dealer <= 11; dealer++ {
			c.hardTotals[HandKey{total, dealer}] = 'H'
		}
	}

	// Hard 9: Double vs 3-6, otherwise hit
	for dealer := 2; dealer <= 11; dealer++ {
		action := 'H'
		if dealer >= 3 && dealer <= 6 {
			action = 'D'
		}
		c.hardTotals[HandKey{9, dealer}] = action
	}

	// Hard 10: Double vs 2-9, otherwise hit
	for dealer := 2; dealer <= 11; dealer++ {
		action := 'H'
		if dealer >= 2 && dealer <= 9 {
			action = 'D'
		}
		c.hardTotals[HandKey{10, dealer}] = action
	}

	// Hard 11: Double vs 2-10, hit vs Ace
	for dealer := 2; dealer <= 11; dealer++ {
		action := 'H'
		if dealer <= 10 {
			action = 'D'
		}
		c.hardTotals[HandKey{11, dealer}] = action
	}

	// Hard 12: Stand vs 4-6, otherwise hit
	for dealer := 2; dealer <= 11; dealer++ {
		action := 'H'
		if dealer >= 4 && dealer <= 6 {
			action = 'S'
		}
		c.hardTotals[HandKey{12, dealer}] = action
	}

	// Hard 13-16: Stand vs 2-6, otherwise hit
	for total := 13; total <= 16; total++ {
		for dealer := 2; dealer <= 11; dealer++ {
			action := 'H'
			if dealer >= 2 && dealer <= 6 {
				action = 'S'
			}
			c.hardTotals[HandKey{total, dealer}] = action
		}
	}

	// Hard 17+: Always stand
	for total := 17; total <= 21; total++ {
		for dealer := 2; dealer <= 11; dealer++ {
			c.hardTotals[HandKey{total, dealer}] = 'S'
		}
	}
}

func (c *StrategyChart) buildSoftTotals() {
	// Soft 13-14 (A,2-A,3): Double vs 5-6, otherwise hit
	for _, total := range []int{13, 14} {
		for dealer := 2; dealer <= 11; dealer++ {
			action := 'H'
			if dealer >= 5 && dealer <= 6 {
				action = 'D'
			}
			c.softTotals[HandKey{total, dealer}] = action
		}
	}

	// Soft 15-16 (A,4-A,5): Double vs 4-6, otherwise hit
	for _, total := range []int{15, 16} {
		for dealer := 2; dealer <= 11; dealer++ {
			action := 'H'
			if dealer >= 4 && dealer <= 6 {
				action = 'D'
			}
			c.softTotals[HandKey{total, dealer}] = action
		}
	}

	// Soft 17 (A,6): Double vs 3-6, otherwise hit
	for dealer := 2; dealer <= 11; dealer++ {
		action := 'H'
		if dealer >= 3 && dealer <= 6 {
			action = 'D'
		}
		c.softTotals[HandKey{17, dealer}] = action
	}

	// Soft 18 (A,7): Stand vs 2,7,8; Double vs 3-6; Hit vs 9,10,A
	for dealer := 2; dealer <= 11; dealer++ {
		var action rune
		switch {
		case dealer == 2 || dealer == 7 || dealer == 8:
			action = 'S'
		case dealer >= 3 && dealer <= 6:
			action = 'D'
		default: // 9, 10, A
			action = 'H'
		}
		c.softTotals[HandKey{18, dealer}] = action
	}

	// Soft 19-21: Always stand
	for _, total := range []int{19, 20, 21} {
		for dealer := 2; dealer <= 11; dealer++ {
			c.softTotals[HandKey{total, dealer}] = 'S'
		}
	}
}

func (c *StrategyChart) buildPairs() {
	// A,A: Always split
	for dealer := 2; dealer <= 11; dealer++ {
		c.pairs[HandKey{11, dealer}] = 'Y'
	}

	// 2,2 and 3,3: Split vs 2-7, otherwise hit
	for _, pairVal := range []int{2, 3} {
		for dealer := 2; dealer <= 11; dealer++ {
			action := 'H'
			if dealer >= 2 && dealer <= 7 {
				action = 'Y'
			}
			c.pairs[HandKey{pairVal, dealer}] = action
		}
	}

	// 4,4: Split vs 5-6, otherwise hit
	for dealer := 2; dealer <= 11; dealer++ {
		action := 'H'
		if dealer >= 5 && dealer <= 6 {
			action = 'Y'
		}
		c.pairs[HandKey{4, dealer}] = action
	}

	// 5,5: Never split, treat as hard 10
	for dealer := 2; dealer <= 11; dealer++ {
		action := 'H'
		if dealer >= 2 && dealer <= 9 {
			action = 'D'
		}
		c.pairs[HandKey{5, dealer}] = action
	}

	// 6,6: Split vs 2-6, otherwise hit
	for dealer := 2; dealer <= 11; dealer++ {
		action := 'H'
		if dealer >= 2 && dealer <= 6 {
			action = 'Y'
		}
		c.pairs[HandKey{6, dealer}] = action
	}

	// 7,7: Split vs 2-7, otherwise hit
	for dealer := 2; dealer <= 11; dealer++ {
		action := 'H'
		if dealer >= 2 && dealer <= 7 {
			action = 'Y'
		}
		c.pairs[HandKey{7, dealer}] = action
	}

	// 8,8: Always split
	for dealer := 2; dealer <= 11; dealer++ {
		c.pairs[HandKey{8, dealer}] = 'Y'
	}

	// 9,9: Split vs 2-9 except 7, stand vs 7,10,A
	for dealer := 2; dealer <= 11; dealer++ {
		action := 'Y'
		if dealer == 7 || dealer == 10 || dealer == 11 {
			action = 'S'
		}
		c.pairs[HandKey{9, dealer}] = action
	}

	// 10,10: Never split, always stand
	for dealer := 2; dealer <= 11; dealer++ {
		c.pairs[HandKey{10, dealer}] = 'S'
	}
}

func (c *StrategyChart) buildMnemonics() {
	c.mnemonics["dealer_weak"] = "Dealer bust cards (4,5,6) = player gets greedy"
	c.mnemonics["always_split"] = "Aces and eights, don't hesitate"
	c.mnemonics["never_split"] = "Tens and fives, keep them alive"
	c.mnemonics["teens_vs_strong"] = "Teens stay vs weak, flee from strong"
	c.mnemonics["soft_17"] = "A,7 is the tricky soft hand"
	c.mnemonics["hard_12"] = "12 is the exception - only stand vs 4,5,6"
	c.mnemonics["doubles"] = "Double when dealer is weak and you can improve"
}

func (c *StrategyChart) buildDealerGroups() {
	c.dealerGroups["weak"] = []int{4, 5, 6}
	c.dealerGroups["medium"] = []int{2, 3, 7, 8}
	c.dealerGroups["strong"] = []int{9, 10, 11}
}

// ActionToString converts action rune to full word for display.
func ActionToString(action rune) string {
	switch action {
	case 'H':
		return "HIT"
	case 'S':
		return "STAND"
	case 'D':
		return "DOUBLE"
	case 'Y', 'P':
		return "SPLIT"
	default:
		return "UNKNOWN"
	}
}

// CardToString converts card value to display string.
func CardToString(card int) string {
	switch card {
	case 11:
		return "A"
	case 10:
		return "10"
	default:
		return fmt.Sprintf("%d", card)
	}
}
