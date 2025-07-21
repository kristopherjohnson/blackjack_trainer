// Package ui provides terminal user interface utilities for the blackjack trainer.
//
// This package handles all terminal input/output operations including:
// - Menu display and user choice collection
// - Hand and scenario display
// - User action input with validation
// - Feedback display with explanations
// - Session headers and progress indicators
package ui

import (
	"blackjack_trainer/internal/strategy"
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

// DisplayMenu displays the main menu and gets user choice.
func DisplayMenu() (int, bool) {
	fmt.Println("\nBlackjack Basic Strategy Trainer")
	fmt.Println("1. Quick Practice (random)")
	fmt.Println("2. Learn by Dealer Strength")
	fmt.Println("3. Focus on Hand Types")
	fmt.Println("4. Absolutes Drill")
	fmt.Println("5. View Statistics")
	fmt.Println("6. Quit")
	fmt.Print("\nChoice (1-6): ")

	reader := bufio.NewReader(os.Stdin)
	input, err := reader.ReadString('\n')
	if err != nil {
		return 0, false
	}

	choice, err := strconv.Atoi(strings.TrimSpace(input))
	if err != nil || choice < 1 || choice > 6 {
		return 0, false
	}

	return choice, true
}

// DisplaySessionHeader displays session header with mode name.
func DisplaySessionHeader(modeName string) {
	fmt.Println("\n" + strings.Repeat("=", 40))
	fmt.Printf("Training Mode: %s\n", modeName)
	fmt.Println(strings.Repeat("=", 40))
	fmt.Println("(Press 'q' + Enter to quit at any time)")
}

// DisplayHand displays the current hand and dealer card.
func DisplayHand(playerCards []int, dealerCard int, handType string, playerTotal int) {
	fmt.Printf("\nDealer shows: %s\n", strategy.CardToString(dealerCard))

	fmt.Print("Your hand: ")
	for i, card := range playerCards {
		if i > 0 {
			fmt.Print(", ")
		}
		fmt.Print(strategy.CardToString(card))
	}

	handDesc := strings.Title(handType)
	fmt.Printf(" (%s %d)\n", handDesc, playerTotal)
}

// GetUserAction gets user's action choice.
func GetUserAction() (rune, bool) {
	fmt.Println("\nWhat's your move?")
	fmt.Print("(H)it, (S)tand, (D)ouble, s(P)lit: ")

	reader := bufio.NewReader(os.Stdin)
	input, err := reader.ReadString('\n')
	if err != nil {
		return 0, true
	}

	input = strings.TrimSpace(input)
	if len(input) == 0 {
		return 0, true
	}

	action := rune(strings.ToUpper(input)[0])

	// Check for quit
	if action == 'Q' {
		return 0, true
	}

	return action, false
}

// DisplayFeedback displays feedback after user's answer.
// Returns true if user wants to quit.
func DisplayFeedback(correct bool, userAction, correctAction rune, explanation string) bool {
	if correct {
		fmt.Println("\n✓ Correct!")
	} else {
		fmt.Println("\n❌ Incorrect!")
		fmt.Printf("\nCorrect answer: %s\n", strategy.ActionToString(correctAction))
		fmt.Printf("Your answer: %s\n", strategy.ActionToString(userAction))
		fmt.Printf("\nPattern: %s\n", explanation)
	}

	fmt.Print("\nPress Enter to continue (or 'q' + Enter to quit): ")

	reader := bufio.NewReader(os.Stdin)
	input, err := reader.ReadString('\n')
	if err != nil {
		return false
	}

	input = strings.TrimSpace(input)
	return len(input) > 0 && strings.ToUpper(input)[0] == 'Q'
}

// DisplayDealerGroups displays dealer groups menu and gets user choice.
func DisplayDealerGroups() (int, bool) {
	fmt.Println("\nChoose dealer strength group to practice:")
	fmt.Println("1. Weak cards (4, 5, 6) - 'Bust cards'")
	fmt.Println("2. Medium cards (2, 3, 7, 8)")
	fmt.Println("3. Strong cards (9, 10, A)")
	fmt.Println("0. Cancel")
	fmt.Print("\nChoice (0-3): ")

	reader := bufio.NewReader(os.Stdin)
	input, err := reader.ReadString('\n')
	if err != nil {
		return 0, false
	}

	choice, err := strconv.Atoi(strings.TrimSpace(input))
	if err != nil {
		return 0, false
	}

	if choice == 0 {
		return 0, false
	}

	if choice < 1 || choice > 3 {
		return 0, false
	}

	return choice, true
}

// DisplayHandTypes displays hand types menu and gets user choice.
func DisplayHandTypes() (int, bool) {
	fmt.Println("\nChoose hand type to practice:")
	fmt.Println("1. Hard totals (no ace or ace = 1)")
	fmt.Println("2. Soft totals (ace = 11)")
	fmt.Println("3. Pairs")
	fmt.Println("0. Cancel")
	fmt.Print("\nChoice (0-3): ")

	reader := bufio.NewReader(os.Stdin)
	input, err := reader.ReadString('\n')
	if err != nil {
		return 0, false
	}

	choice, err := strconv.Atoi(strings.TrimSpace(input))
	if err != nil {
		return 0, false
	}

	if choice == 0 {
		return 0, false
	}

	if choice < 1 || choice > 3 {
		return 0, false
	}

	return choice, true
}
