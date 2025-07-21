#include "stats.h"
#include "trainer.h"
#include "ui.h"
#include <CLI/CLI.hpp>
#include <iostream>
#include <memory>
#include <string>

namespace blackjack {

/**
 * Create a training session based on type.
 * @param session_type Type of session to create
 * @param difficulty Difficulty level
 * @return Unique pointer to training session or nullptr if invalid type
 */
std::unique_ptr<TrainingSession>
create_session(const std::string &session_type,
               const std::string &difficulty = "normal") {
  if (session_type == "random") {
    return std::make_unique<RandomTrainingSession>(difficulty);
  } else if (session_type == "dealer") {
    return std::make_unique<DealerGroupTrainingSession>(difficulty);
  } else if (session_type == "hand") {
    return std::make_unique<HandTypeTrainingSession>(difficulty);
  } else if (session_type == "absolute") {
    return std::make_unique<AbsoluteTrainingSession>(difficulty);
  }
  return nullptr;
}

} // namespace blackjack

/**
 * Main entry point for the Blackjack Basic Strategy Trainer.
 *
 * This function serves as the primary entry point for the training application,
 * supporting both command-line and interactive modes of operation.
 *
 * Command-line mode:
 *     When session type is specified via --session argument, runs that specific
 *     training session directly and exits. Supports session types: random,
 *     dealer, hand, absolute with optional difficulty levels.
 *
 * Interactive mode:
 *     When no session type is specified, displays the main menu allowing users
 *     to choose from multiple training options:
 *     1. Quick Practice (random scenarios)
 *     2. Learn by Dealer Strength (weak/medium/strong dealer groups)
 *     3. Focus on Hand Types (hard/soft/pairs)
 *     4. Absolutes Drill (never/always rules)
 *     5. View Statistics (session performance)
 *     6. Quit
 *
 * The function initializes statistics tracking that persists across all
 * training sessions within the same execution, allowing users to see
 * cumulative progress.
 *
 * Usage:
 *     ./blackjack_trainer                    # Interactive mode
 *     ./blackjack_trainer -s random          # Direct random practice
 *     ./blackjack_trainer -s absolute -d easy # Absolutes drill, easy
 * difficulty
 */
int main(int argc, char *argv[]) {
  using namespace blackjack;

  CLI::App app{"Blackjack Basic Strategy Trainer"};

  std::string session_type;
  std::string difficulty = "normal";

  app.add_option("-s,--session", session_type, "Training session type")
      ->check(CLI::IsMember({"random", "dealer", "hand", "absolute"}));

  app.add_option("-d,--difficulty", difficulty, "Difficulty level")
      ->check(CLI::IsMember({"easy", "normal", "hard"}));

  CLI11_PARSE(app, argc, argv);

  std::cout << "Blackjack Basic Strategy Trainer" << std::endl;
  std::cout << std::string(40, '=') << std::endl;

  Statistics stats;

  // If session type specified via command line, run it directly
  if (!session_type.empty()) {
    auto session = create_session(session_type, difficulty);
    if (session) {
      session->run(stats);
    } else {
      std::cout << "Invalid session type: " << session_type << std::endl;
      return 1;
    }
    return 0;
  }

  // Otherwise show the interactive menu
  while (true) {
    int choice = display_menu();

    if (choice == 1) {
      auto session = std::make_unique<RandomTrainingSession>("normal");
      session->run(stats);
    } else if (choice == 2) {
      auto session = std::make_unique<DealerGroupTrainingSession>("normal");
      session->run(stats);
    } else if (choice == 3) {
      auto session = std::make_unique<HandTypeTrainingSession>("normal");
      session->run(stats);
    } else if (choice == 4) {
      auto session = std::make_unique<AbsoluteTrainingSession>("easy");
      session->run(stats);
    } else if (choice == 5) {
      stats.display_progress();
    } else if (choice == 6) {
      std::cout << "Thanks for practicing! Keep those strategies sharp!"
                << std::endl;
      break;
    } else {
      std::cout << "Invalid choice. Please try again." << std::endl;
    }
  }

  return 0;
}