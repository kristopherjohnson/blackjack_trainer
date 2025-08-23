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

// HandType represents the different types of blackjack hands.
type HandType int

const (
	// HandTypeHard represents hard totals (no ace or ace counting as 1).
	HandTypeHard HandType = iota
	// HandTypeSoft represents soft totals (ace counting as 11).
	HandTypeSoft
	// HandTypePair represents pairs (two identical cards).
	HandTypePair
)

// String returns the string representation of a HandType.
func (ht HandType) String() string {
	switch ht {
	case HandTypeHard:
		return "hard"
	case HandTypeSoft:
		return "soft"
	case HandTypePair:
		return "pair"
	default:
		return "unknown"
	}
}

// MnemonicKey represents the different types of mnemonic explanations.
type MnemonicKey int

const (
	// MnemonicAlwaysSplit represents the "always split" mnemonic for pairs.
	MnemonicAlwaysSplit MnemonicKey = iota
	// MnemonicNeverSplit represents the "never split" mnemonic for pairs.
	MnemonicNeverSplit
	// MnemonicDealerWeak represents explanations for dealer weak cards.
	MnemonicDealerWeak
	// MnemonicTeensVsStrong represents teens vs strong dealer explanations.
	MnemonicTeensVsStrong
	// MnemonicSoft17 represents the soft 17 (A,7) explanation.
	MnemonicSoft17
	// MnemonicHard12 represents the hard 12 exception explanation.
	MnemonicHard12
	// MnemonicDoubles represents general doubling explanations.
	MnemonicDoubles
)

// String returns the string key for a MnemonicKey.
func (mk MnemonicKey) String() string {
	switch mk {
	case MnemonicAlwaysSplit:
		return "always_split"
	case MnemonicNeverSplit:
		return "never_split"
	case MnemonicDealerWeak:
		return "dealer_weak"
	case MnemonicTeensVsStrong:
		return "teens_vs_strong"
	case MnemonicSoft17:
		return "soft_17"
	case MnemonicHard12:
		return "hard_12"
	case MnemonicDoubles:
		return "doubles"
	default:
		return "unknown"
	}
}

// StrategyChart represents the complete blackjack basic strategy chart.
type StrategyChart struct {
	hardTotals   map[HandKey]rune
	softTotals   map[HandKey]rune
	pairs        map[HandKey]rune
	mnemonics    map[MnemonicKey]string
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
		mnemonics:    make(map[MnemonicKey]string),
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
func (c *StrategyChart) GetCorrectAction(handType HandType, playerTotal, dealerCard int) rune {
	key := HandKey{PlayerTotal: playerTotal, DealerCard: dealerCard}

	switch handType {
	case HandTypePair:
		if action, exists := c.pairs[key]; exists {
			return action
		}
	case HandTypeSoft:
		if action, exists := c.softTotals[key]; exists {
			return action
		}
	case HandTypeHard:
		if action, exists := c.hardTotals[key]; exists {
			return action
		}
	}
	return 'H' // Default to hit
}

// GetExplanation returns an explanation/mnemonic for a given scenario.
func (c *StrategyChart) GetExplanation(handType HandType, playerTotal, dealerCard int) string {
	// Specific explanations for key scenarios
	switch handType {
	case HandTypePair:
		switch playerTotal {
		case 11: // A,A
			return c.mnemonics[MnemonicAlwaysSplit]
		case 8: // 8,8
			return c.mnemonics[MnemonicAlwaysSplit]
		case 10: // 10,10
			return c.mnemonics[MnemonicNeverSplit]
		case 5: // 5,5
			return c.mnemonics[MnemonicNeverSplit]
		}
	case HandTypeSoft:
		if playerTotal == 18 { // A,7
			return c.mnemonics[MnemonicSoft17]
		}
	case HandTypeHard:
		if playerTotal == 12 {
			return c.mnemonics[MnemonicHard12]
		}
	}

	// Dealer strength based explanations
	if weakCards, exists := c.dealerGroups["weak"]; exists {
		for _, card := range weakCards {
			if card == dealerCard {
				return c.mnemonics[MnemonicDealerWeak]
			}
		}
	}

	if strongCards, exists := c.dealerGroups["strong"]; exists {
		if playerTotal >= 13 && playerTotal <= 16 {
			for _, card := range strongCards {
				if card == dealerCard {
					return c.mnemonics[MnemonicTeensVsStrong]
				}
			}
		}
	}

	return "Follow basic strategy patterns"
}

// IsAbsoluteRule checks if a scenario represents an absolute rule (always/never).
func (c *StrategyChart) IsAbsoluteRule(handType HandType, playerTotal, dealerCard int) bool {
	switch handType {
	case HandTypePair:
		// Pair absolutes: A,A (11), 8,8, 10,10, 5,5
		return playerTotal == 11 || playerTotal == 8 || playerTotal == 10 || playerTotal == 5
	case HandTypeHard:
		// Hard 17+ always stand
		return playerTotal >= 17
	case HandTypeSoft:
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
	c.mnemonics[MnemonicDealerWeak] = "Dealer bust cards (4,5,6) = player gets greedy"
	c.mnemonics[MnemonicAlwaysSplit] = "Aces and eights, don't hesitate"
	c.mnemonics[MnemonicNeverSplit] = "Tens and fives, keep them alive"
	c.mnemonics[MnemonicTeensVsStrong] = "Teens stay vs weak, flee from strong"
	c.mnemonics[MnemonicSoft17] = "A,7 is the tricky soft hand"
	c.mnemonics[MnemonicHard12] = "12 is the exception - only stand vs 4,5,6"
	c.mnemonics[MnemonicDoubles] = "Double when dealer is weak and you can improve"
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
