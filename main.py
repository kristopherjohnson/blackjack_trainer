#!/usr/bin/env python3

from trainer import (RandomTrainingSession, DealerGroupTrainingSession,
                     HandTypeTrainingSession, AbsoluteTrainingSession)
from ui import display_menu
from stats import Statistics


def main():
    print("Blackjack Basic Strategy Trainer")
    print("=" * 40)

    stats = Statistics()

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
