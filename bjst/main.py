#!/usr/bin/env python3

import argparse
from .trainer import (RandomTrainingSession, DealerGroupTrainingSession,
                      HandTypeTrainingSession, AbsoluteTrainingSession)
from .ui import display_menu
from .stats import Statistics


def create_session(session_type, difficulty='normal'):
    """Create a training session based on type."""
    sessions = {
        'random': RandomTrainingSession,
        'dealer': DealerGroupTrainingSession,
        'hand': HandTypeTrainingSession,
        'absolute': AbsoluteTrainingSession
    }

    if session_type not in sessions:
        return None

    return sessions[session_type](difficulty)


def main():
    """Main entry point for the Blackjack Basic Strategy Trainer.

    This function serves as the primary entry point for the training application,
    supporting both command-line and interactive modes of operation.

    Command-line mode:
        When session type is specified via --session argument, runs that specific
        training session directly and exits. Supports session types: random,
        dealer, hand, absolute with optional difficulty levels.

    Interactive mode:
        When no session type is specified, displays the main menu allowing users
        to choose from multiple training options:
        1. Quick Practice (random scenarios)
        2. Learn by Dealer Strength (weak/medium/strong dealer groups)
        3. Focus on Hand Types (hard/soft/pairs)
        4. Absolutes Drill (never/always rules)
        5. View Statistics (session performance)
        6. Quit

    The function initializes statistics tracking that persists across all
    training sessions within the same execution, allowing users to see
    cumulative progress.

    Usage:
        python3 bjst                    # Interactive mode
        python3 bjst -s random          # Direct random practice
        python3 bjst -s absolute -d easy # Absolutes drill, easy difficulty
    """
    parser = argparse.ArgumentParser(
        description='Blackjack Basic Strategy Trainer')
    parser.add_argument('--session', '-s',
                        choices=['random', 'dealer', 'hand', 'absolute'],
                        help='Training session type')
    parser.add_argument('--difficulty', '-d',
                        choices=['easy', 'normal', 'hard'],
                        default='normal',
                        help='Difficulty level (default: normal)')

    args = parser.parse_args()

    print("Blackjack Basic Strategy Trainer")
    print("=" * 40)

    stats = Statistics()

    # If session type specified via command line, run it directly
    if args.session:
        session = create_session(args.session, args.difficulty)
        if session:
            session.run(stats)
        else:
            print(f"Invalid session type: {args.session}")
        return

    # Otherwise show the interactive menu
    while True:
        choice = display_menu()

        if choice == 1:
            session = RandomTrainingSession('normal')
            session.run(stats)
        elif choice == 2:
            session = DealerGroupTrainingSession('normal')
            session.run(stats)
        elif choice == 3:
            session = HandTypeTrainingSession('normal')
            session.run(stats)
        elif choice == 4:
            session = AbsoluteTrainingSession('easy')
            session.run(stats)
        elif choice == 5:
            stats.display_progress()
        elif choice == 6:
            print("Thanks for practicing! Keep those strategies sharp!")
            break
        else:
            print("Invalid choice. Please try again.")


if __name__ == "__main__":
    main()
