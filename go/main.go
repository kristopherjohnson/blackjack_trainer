// Blackjack Basic Strategy Trainer
//
// A terminal-based application to help memorize optimal blackjack strategy
// through interactive practice sessions.
//
// Usage:
//
//	blackjack_trainer [flags]
//
// Flags:
//
//	-session string    Session type: random, dealer, hand, absolute
//	-difficulty string Difficulty level: easy, normal, hard (default "normal")
//	-help             Show help message
package main

import (
	"blackjack_trainer/internal/stats"
	"blackjack_trainer/internal/trainer"
	"blackjack_trainer/internal/ui"
	"flag"
	"fmt"
	"os"
)

func main() {
	// Define command line flags
	sessionType := flag.String("session", "", "Session type: random, dealer, hand, absolute")
	difficulty := flag.String("difficulty", "normal", "Difficulty level: easy, normal, hard")
	showHelp := flag.Bool("help", false, "Show help message")

	flag.Parse()

	// Show help if requested
	if *showHelp {
		showUsage()
		return
	}

	statistics := stats.New()

	// If session type specified via command line, run it directly
	if *sessionType != "" {
		session := createSession(*sessionType, *difficulty)
		if session != nil {
			trainer.RunSession(session, statistics)
		} else {
			fmt.Printf("Invalid session type: %s\n", *sessionType)
			fmt.Println("Valid types: random, dealer, hand, absolute")
			os.Exit(1)
		}
		return
	}

	// Otherwise, show interactive menu
	for {
		choice, ok := ui.DisplayMenu()
		if !ok {
			fmt.Println("Invalid choice. Please enter a number 1-6.")
			continue
		}

		switch choice {
		case 1: // Quick Practice (random)
			session := trainer.NewRandomTrainingSession()
			trainer.RunSession(session, statistics)

		case 2: // Learn by Dealer Strength
			session := trainer.NewDealerGroupTrainingSession()
			trainer.RunSession(session, statistics)

		case 3: // Focus on Hand Types
			session := trainer.NewHandTypeTrainingSession()
			trainer.RunSession(session, statistics)

		case 4: // Absolutes Drill
			session := trainer.NewAbsoluteTrainingSession()
			trainer.RunSession(session, statistics)

		case 5: // View Statistics
			statistics.DisplayProgress()

		case 6: // Quit
			fmt.Println("Thanks for practicing! Good luck at the tables!")
			return

		default:
			fmt.Println("Invalid choice. Please enter a number 1-6.")
		}
	}
}

// createSession creates a training session based on the session type and difficulty.
func createSession(sessionType, difficulty string) trainer.TrainingSession {
	// Note: Difficulty levels could be implemented in the future to modify
	// question complexity, but for now we create sessions without difficulty
	_ = difficulty

	switch sessionType {
	case "random":
		return trainer.NewRandomTrainingSession()
	case "dealer":
		return trainer.NewDealerGroupTrainingSession()
	case "hand":
		return trainer.NewHandTypeTrainingSession()
	case "absolute":
		return trainer.NewAbsoluteTrainingSession()
	default:
		return nil
	}
}

// showUsage displays the usage information.
func showUsage() {
	fmt.Println("Blackjack Basic Strategy Trainer")
	fmt.Println()
	fmt.Println("A terminal-based application to help memorize optimal blackjack strategy")
	fmt.Println("through interactive practice sessions.")
	fmt.Println()
	fmt.Println("Usage:")
	fmt.Println("  blackjack_trainer [flags]")
	fmt.Println()
	fmt.Println("Flags:")
	fmt.Println("  -session string    Session type: random, dealer, hand, absolute")
	fmt.Println("  -difficulty string Difficulty level: easy, normal, hard (default \"normal\")")
	fmt.Println("  -help             Show this help message")
	fmt.Println()
	fmt.Println("Session Types:")
	fmt.Println("  random     Mixed practice with all hand types and dealer cards")
	fmt.Println("  dealer     Practice by dealer strength groups (weak/medium/strong)")
	fmt.Println("  hand       Focus on specific hand types (hard/soft/pairs)")
	fmt.Println("  absolute   Practice absolute rules (always/never scenarios)")
	fmt.Println()
	fmt.Println("Examples:")
	fmt.Println("  blackjack_trainer                           # Interactive mode")
	fmt.Println("  blackjack_trainer -session random           # Quick practice")
	fmt.Println("  blackjack_trainer -session dealer           # Dealer groups")
	fmt.Println("  blackjack_trainer -session hand -difficulty hard")
	fmt.Println()
	fmt.Println("If no session type is specified, the program will start in interactive mode")
	fmt.Println("with a menu to choose the practice mode.")
}
