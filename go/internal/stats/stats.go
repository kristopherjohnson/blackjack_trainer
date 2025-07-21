// Package stats provides statistics tracking for blackjack strategy training sessions.
//
// This package tracks performance metrics during training sessions, including:
// - Overall accuracy (correct answers / total attempts)
// - Accuracy by hand type (hard totals, soft totals, pairs)
// - Accuracy by dealer strength (weak, medium, strong dealer cards)
//
// Dealer strength categories:
// - Weak: 4, 5, 6 (dealer bust cards)
// - Medium: 2, 3, 7, 8 (moderate dealer cards)
// - Strong: 9, 10, A (strong dealer cards)
//
// The statistics are maintained for the current session and can be displayed
// to show the user's progress and identify areas for improvement.
package stats

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

// CategoryData tracks correct and total attempts for a category.
type CategoryData struct {
	Correct int
	Total   int
}

// Statistics tracks performance metrics for training sessions.
type Statistics struct {
	totalAttempts    int
	correctAnswers   int
	byCategory       map[string]*CategoryData
	byDealerStrength map[string]*CategoryData
}

// New creates a new statistics tracker.
func New() *Statistics {
	stats := &Statistics{
		totalAttempts:    0,
		correctAnswers:   0,
		byCategory:       make(map[string]*CategoryData),
		byDealerStrength: make(map[string]*CategoryData),
	}

	// Initialize category tracking
	stats.byCategory["hard"] = &CategoryData{}
	stats.byCategory["soft"] = &CategoryData{}
	stats.byCategory["pair"] = &CategoryData{}

	// Initialize dealer strength tracking
	stats.byDealerStrength["weak"] = &CategoryData{}
	stats.byDealerStrength["medium"] = &CategoryData{}
	stats.byDealerStrength["strong"] = &CategoryData{}

	return stats
}

// RecordAttempt records an attempt in the training session.
func (s *Statistics) RecordAttempt(handType, dealerStrength string, correct bool) {
	s.totalAttempts++
	if correct {
		s.correctAnswers++
	}

	// Record by hand type
	if category, exists := s.byCategory[handType]; exists {
		category.Total++
		if correct {
			category.Correct++
		}
	}

	// Record by dealer strength
	if strength, exists := s.byDealerStrength[dealerStrength]; exists {
		strength.Total++
		if correct {
			strength.Correct++
		}
	}
}

// GetCategoryAccuracy returns accuracy percentage for a specific category.
func (s *Statistics) GetCategoryAccuracy(category string) float64 {
	if data, exists := s.byCategory[category]; exists && data.Total > 0 {
		return (float64(data.Correct) / float64(data.Total)) * 100.0
	}
	return 0.0
}

// GetDealerStrengthAccuracy returns accuracy percentage for a dealer strength category.
func (s *Statistics) GetDealerStrengthAccuracy(strength string) float64 {
	if data, exists := s.byDealerStrength[strength]; exists && data.Total > 0 {
		return (float64(data.Correct) / float64(data.Total)) * 100.0
	}
	return 0.0
}

// GetSessionAccuracy returns overall session accuracy percentage.
func (s *Statistics) GetSessionAccuracy() float64 {
	if s.totalAttempts == 0 {
		return 0.0
	}
	return (float64(s.correctAnswers) / float64(s.totalAttempts)) * 100.0
}

// DisplayProgress displays progress statistics to the console.
func (s *Statistics) DisplayProgress() {
	fmt.Println("\n" + strings.Repeat("=", 50))
	fmt.Println("SESSION STATISTICS")
	fmt.Println(strings.Repeat("=", 50))

	if s.totalAttempts == 0 {
		fmt.Println("No practice attempts yet this session.")
		fmt.Print("\nPress Enter to continue...")
		bufio.NewReader(os.Stdin).ReadString('\n')
		return
	}

	fmt.Printf("Overall: %d/%d (%.1f%%)\n",
		s.correctAnswers, s.totalAttempts, s.GetSessionAccuracy())

	fmt.Println("\nBy Hand Type:")
	for _, handType := range []string{"hard", "soft", "pair"} {
		if data, exists := s.byCategory[handType]; exists && data.Total > 0 {
			accuracy := (float64(data.Correct) / float64(data.Total)) * 100.0
			capitalized := strings.Title(handType)
			fmt.Printf("  %s: %d/%d (%.1f%%)\n", capitalized, data.Correct, data.Total, accuracy)
		}
	}

	fmt.Println("\nBy Dealer Strength:")
	for _, strength := range []string{"weak", "medium", "strong"} {
		if data, exists := s.byDealerStrength[strength]; exists && data.Total > 0 {
			accuracy := (float64(data.Correct) / float64(data.Total)) * 100.0
			capitalized := strings.Title(strength)
			fmt.Printf("  %s: %d/%d (%.1f%%)\n", capitalized, data.Correct, data.Total, accuracy)
		}
	}

	fmt.Print("\nPress Enter to continue...")
	bufio.NewReader(os.Stdin).ReadString('\n')
}

// ResetSession resets session statistics.
func (s *Statistics) ResetSession() {
	s.totalAttempts = 0
	s.correctAnswers = 0

	for _, category := range s.byCategory {
		category.Correct = 0
		category.Total = 0
	}

	for _, strength := range s.byDealerStrength {
		strength.Correct = 0
		strength.Total = 0
	}
}

// GetDealerStrength determines dealer strength from dealer card.
func (s *Statistics) GetDealerStrength(dealerCard int) string {
	switch dealerCard {
	case 4, 5, 6:
		return "weak"
	case 2, 3, 7, 8:
		return "medium"
	default: // 9, 10, 11 (Ace)
		return "strong"
	}
}
