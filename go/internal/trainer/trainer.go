// Package trainer provides training session types for blackjack strategy practice.
//
// This package defines the TrainingSession interface and implements concrete
// training session types that focus on different aspects of blackjack strategy:
// - RandomTrainingSession: Mixed practice with all hand types and dealer cards
// - DealerGroupTrainingSession: Focus on specific dealer strength groups
// - HandTypeTrainingSession: Focus on specific hand types (hard/soft/pairs)
// - AbsoluteTrainingSession: Practice absolute rules (always/never scenarios)
package trainer

import (
	"blackjack_trainer/internal/stats"
	"blackjack_trainer/internal/strategy"
	"blackjack_trainer/internal/ui"
	"fmt"
	"math/rand"
	"time"
)

// TrainingSession interface defines the contract for all training session types.
type TrainingSession interface {
	// GetModeName returns the mode name for display purposes.
	GetModeName() string
	// GetMaxQuestions returns the maximum number of questions for this session type.
	GetMaxQuestions() int
	// GenerateScenario generates a scenario for this training mode.
	// Returns (handType, playerCards, playerTotal, dealerCard).
	GenerateScenario() (strategy.HandType, []int, int, int)
	// SetupSession sets up the session. Returns true if setup successful, false if user cancelled.
	SetupSession() bool
}

// Scenario represents a training scenario.
type Scenario struct {
	HandType    strategy.HandType
	PlayerCards []int
	PlayerTotal int
	DealerCard  int
}

// BaseTrainer provides common functionality for all training sessions.
type BaseTrainer struct {
	rng *rand.Rand
}

// NewBaseTrainer creates a new base trainer with random number generator.
func NewBaseTrainer() *BaseTrainer {
	return &BaseTrainer{
		rng: rand.New(rand.NewSource(time.Now().UnixNano())),
	}
}

// GenerateHandCards generates card representation for a hand.
func (bt *BaseTrainer) GenerateHandCards(handType strategy.HandType, playerTotal int) []int {
	switch handType {
	case strategy.HandTypePair:
		return []int{playerTotal, playerTotal}
	case strategy.HandTypeSoft:
		otherCard := playerTotal - 11
		return []int{11, otherCard}
	case strategy.HandTypeHard:
		if playerTotal <= 11 {
			return []int{playerTotal}
		}
		// Generate two valid cards (2-10) that sum to playerTotal
		firstCard := bt.rng.Intn(min(9, playerTotal-2)) + 2
		secondCard := playerTotal - firstCard

		// If second card would be > 10, we need more cards
		if secondCard > 10 {
			// For totals > 20, generate 3+ cards
			cards := []int{firstCard}
			remaining := playerTotal - firstCard

			for remaining > 10 {
				// Take a card between 2 and min(10, remaining-2) to ensure we can finish
				maxCard := min(10, remaining-2)
				if maxCard < 2 {
					break
				}
				card := bt.rng.Intn(maxCard-1) + 2 // 2 to maxCard
				cards = append(cards, card)
				remaining -= card
			}

			if remaining >= 2 {
				cards = append(cards, remaining)
			}
			return cards
		} else if secondCard < 2 {
			// If second card would be < 2, just use single card
			return []int{playerTotal}
		} else {
			return []int{firstCard, secondCard}
		}
	default:
		return []int{playerTotal}
	}
}

// CheckAnswer checks if user's action matches the correct action.
func CheckAnswer(userAction, correctAction rune) bool {
	normalizedUser := userAction
	if userAction == 'P' {
		normalizedUser = 'Y'
	}
	return normalizedUser == correctAction
}

// RunSession runs the main training session loop.
func RunSession(session TrainingSession, statistics *stats.Statistics) {
	ui.DisplaySessionHeader(session.GetModeName())

	if !session.SetupSession() {
		return // User cancelled setup
	}

	strategyChart := strategy.New()
	var correctCount, totalCount, questionCount int

	for questionCount < session.GetMaxQuestions() {
		handType, playerCards, playerTotal, dealerCard := session.GenerateScenario()

		ui.DisplayHand(playerCards, dealerCard, handType, playerTotal)

		userAction, quit := ui.GetUserAction()
		if quit {
			break
		}

		correctAction := strategyChart.GetCorrectAction(handType, playerTotal, dealerCard)
		correct := CheckAnswer(userAction, correctAction)
		explanation := strategyChart.GetExplanation(handType, playerTotal, dealerCard)

		quitRequested := ui.DisplayFeedback(correct, userAction, correctAction, explanation)

		// Record statistics
		dealerStrength := statistics.GetDealerStrength(dealerCard)
		statistics.RecordAttempt(handType, dealerStrength, correct)

		questionCount++

		if correct {
			correctCount++
		}
		totalCount++

		if quitRequested {
			break
		}
	}

	// Show session summary
	if totalCount > 0 {
		accuracy := (float64(correctCount) / float64(totalCount)) * 100.0
		fmt.Printf("\nSession complete! Final score: %d/%d (%.1f%%)\n",
			correctCount, totalCount, accuracy)
	}
}

// RandomTrainingSession provides random practice with all hand types and dealer cards.
type RandomTrainingSession struct {
	*BaseTrainer
}

// NewRandomTrainingSession creates a new random training session.
func NewRandomTrainingSession() *RandomTrainingSession {
	return &RandomTrainingSession{
		BaseTrainer: NewBaseTrainer(),
	}
}

// GetModeName returns the mode name.
func (r *RandomTrainingSession) GetModeName() string {
	return "random"
}

// GetMaxQuestions returns the maximum number of questions.
func (r *RandomTrainingSession) GetMaxQuestions() int {
	return 50
}

// SetupSession sets up the session (no additional setup needed).
func (r *RandomTrainingSession) SetupSession() bool {
	return true
}

// GenerateScenario generates a random scenario.
func (r *RandomTrainingSession) GenerateScenario() (strategy.HandType, []int, int, int) {
	dealerCard := r.rng.Intn(10) + 2 // 2-11
	handTypes := []strategy.HandType{strategy.HandTypeHard, strategy.HandTypeSoft, strategy.HandTypePair}
	handType := handTypes[r.rng.Intn(len(handTypes))]

	var playerCards []int
	var playerTotal int

	switch handType {
	case strategy.HandTypePair:
		pairValues := []int{2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
		pairValue := pairValues[r.rng.Intn(len(pairValues))]
		playerCards = []int{pairValue, pairValue}
		playerTotal = pairValue
	case strategy.HandTypeSoft:
		otherCard := r.rng.Intn(8) + 2 // 2-9
		playerCards = []int{11, otherCard}
		playerTotal = 11 + otherCard
	case strategy.HandTypeHard:
		playerTotal = r.rng.Intn(16) + 5 // 5-20
		playerCards = r.GenerateHandCards(strategy.HandTypeHard, playerTotal)
	}

	return handType, playerCards, playerTotal, dealerCard
}

// DealerGroupTrainingSession focuses on specific dealer strength groups.
type DealerGroupTrainingSession struct {
	*BaseTrainer
	dealerGroup int
}

// NewDealerGroupTrainingSession creates a new dealer group training session.
func NewDealerGroupTrainingSession() *DealerGroupTrainingSession {
	return &DealerGroupTrainingSession{
		BaseTrainer: NewBaseTrainer(),
		dealerGroup: 0,
	}
}

// GetModeName returns the mode name.
func (d *DealerGroupTrainingSession) GetModeName() string {
	return "dealer_groups"
}

// GetMaxQuestions returns the maximum number of questions.
func (d *DealerGroupTrainingSession) GetMaxQuestions() int {
	return 50
}

// SetupSession sets up the session by asking user to choose dealer group.
func (d *DealerGroupTrainingSession) SetupSession() bool {
	choice, ok := ui.DisplayDealerGroups()
	if !ok {
		return false
	}
	d.dealerGroup = choice
	return true
}

// GenerateScenario generates a scenario with specific dealer group.
func (d *DealerGroupTrainingSession) GenerateScenario() (strategy.HandType, []int, int, int) {
	// Select dealer card based on chosen group
	var dealerCard int
	switch d.dealerGroup {
	case 1: // Weak
		weakCards := []int{4, 5, 6}
		dealerCard = weakCards[d.rng.Intn(len(weakCards))]
	case 2: // Medium
		mediumCards := []int{2, 3, 7, 8}
		dealerCard = mediumCards[d.rng.Intn(len(mediumCards))]
	default: // Strong
		strongCards := []int{9, 10, 11}
		dealerCard = strongCards[d.rng.Intn(len(strongCards))]
	}

	handTypes := []strategy.HandType{strategy.HandTypeHard, strategy.HandTypeSoft, strategy.HandTypePair}
	handType := handTypes[d.rng.Intn(len(handTypes))]

	var playerCards []int
	var playerTotal int

	switch handType {
	case strategy.HandTypePair:
		pairValues := []int{2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
		pairValue := pairValues[d.rng.Intn(len(pairValues))]
		playerCards = []int{pairValue, pairValue}
		playerTotal = pairValue
	case strategy.HandTypeSoft:
		otherCard := d.rng.Intn(8) + 2 // 2-9
		playerCards = []int{11, otherCard}
		playerTotal = 11 + otherCard
	case strategy.HandTypeHard:
		playerTotal = d.rng.Intn(16) + 5 // 5-20
		playerCards = d.GenerateHandCards(strategy.HandTypeHard, playerTotal)
	}

	return handType, playerCards, playerTotal, dealerCard
}

// HandTypeTrainingSession focuses on specific hand types.
type HandTypeTrainingSession struct {
	*BaseTrainer
	handTypeChoice int
}

// NewHandTypeTrainingSession creates a new hand type training session.
func NewHandTypeTrainingSession() *HandTypeTrainingSession {
	return &HandTypeTrainingSession{
		BaseTrainer:    NewBaseTrainer(),
		handTypeChoice: 0,
	}
}

// GetModeName returns the mode name.
func (h *HandTypeTrainingSession) GetModeName() string {
	return "hand_types"
}

// GetMaxQuestions returns the maximum number of questions.
func (h *HandTypeTrainingSession) GetMaxQuestions() int {
	return 50
}

// SetupSession sets up the session by asking user to choose hand type.
func (h *HandTypeTrainingSession) SetupSession() bool {
	choice, ok := ui.DisplayHandTypes()
	if !ok {
		return false
	}
	h.handTypeChoice = choice
	return true
}

// GenerateScenario generates a scenario with specific hand type.
func (h *HandTypeTrainingSession) GenerateScenario() (strategy.HandType, []int, int, int) {
	dealerCard := h.rng.Intn(10) + 2 // 2-11

	var handType strategy.HandType
	var playerCards []int
	var playerTotal int

	switch h.handTypeChoice {
	case 1: // Hard totals
		handType = strategy.HandTypeHard
		playerTotal = h.rng.Intn(16) + 5 // 5-20
		playerCards = h.GenerateHandCards(strategy.HandTypeHard, playerTotal)
	case 2: // Soft totals
		handType = strategy.HandTypeSoft
		otherCard := h.rng.Intn(8) + 2 // 2-9
		playerCards = []int{11, otherCard}
		playerTotal = 11 + otherCard
	default: // Pairs
		handType = strategy.HandTypePair
		pairValues := []int{2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
		pairValue := pairValues[h.rng.Intn(len(pairValues))]
		playerCards = []int{pairValue, pairValue}
		playerTotal = pairValue
	}

	return handType, playerCards, playerTotal, dealerCard
}

// AbsoluteTrainingSession focuses on absolute rules (always/never scenarios).
type AbsoluteTrainingSession struct {
	*BaseTrainer
}

// NewAbsoluteTrainingSession creates a new absolute training session.
func NewAbsoluteTrainingSession() *AbsoluteTrainingSession {
	return &AbsoluteTrainingSession{
		BaseTrainer: NewBaseTrainer(),
	}
}

// GetModeName returns the mode name.
func (a *AbsoluteTrainingSession) GetModeName() string {
	return "absolutes"
}

// GetMaxQuestions returns the maximum number of questions.
func (a *AbsoluteTrainingSession) GetMaxQuestions() int {
	return 20
}

// SetupSession sets up the session (no additional setup needed).
func (a *AbsoluteTrainingSession) SetupSession() bool {
	return true
}

// GenerateScenario generates a scenario with absolute rules.
func (a *AbsoluteTrainingSession) GenerateScenario() (strategy.HandType, []int, int, int) {
	absolutes := []struct {
		handType    strategy.HandType
		playerCards []int
		playerTotal int
	}{
		{strategy.HandTypePair, []int{11, 11}, 11}, // A,A
		{strategy.HandTypePair, []int{8, 8}, 8},    // 8,8
		{strategy.HandTypePair, []int{10, 10}, 10}, // 10,10
		{strategy.HandTypePair, []int{5, 5}, 5},    // 5,5
		{strategy.HandTypeHard, []int{}, 17},       // Hard 17
		{strategy.HandTypeHard, []int{}, 18},       // Hard 18
		{strategy.HandTypeHard, []int{}, 19},       // Hard 19
		{strategy.HandTypeHard, []int{}, 20},       // Hard 20
		{strategy.HandTypeSoft, []int{11, 8}, 19},  // Soft 19
		{strategy.HandTypeSoft, []int{11, 9}, 20},  // Soft 20
	}

	absolute := absolutes[a.rng.Intn(len(absolutes))]
	dealerCard := a.rng.Intn(10) + 2 // 2-11

	playerCards := absolute.playerCards
	if len(playerCards) == 0 { // Hard totals
		playerCards = a.GenerateHandCards(absolute.handType, absolute.playerTotal)
	}

	return absolute.handType, playerCards, absolute.playerTotal, dealerCard
}

// Helper function to get minimum of two integers.
func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
