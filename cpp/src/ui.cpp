#include "ui.h"
#include <iostream>
#include <limits>
#include <sstream>

namespace blackjack {

int display_menu() {
  std::cout << "\nBlackjack Basic Strategy Trainer" << std::endl;
  std::cout << "1. Quick Practice (random)" << std::endl;
  std::cout << "2. Learn by Dealer Strength" << std::endl;
  std::cout << "3. Focus on Hand Types" << std::endl;
  std::cout << "4. Absolutes Drill" << std::endl;
  std::cout << "5. View Statistics" << std::endl;
  std::cout << "6. Quit" << std::endl;
  std::cout << "\nChoice (1-6): ";

  int choice;
  std::cin >> choice;

  // Clear any remaining input
  std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

  return choice;
}

void display_session_header(const std::string &mode_name) {
  std::cout << "\n" << std::string(40, '=') << std::endl;
  std::cout << "Training Mode: " << mode_name << std::endl;
  std::cout << std::string(40, '=') << std::endl;
  std::cout << "(Press 'q' + Enter to quit at any time)" << std::endl;
}

void display_hand(const std::vector<int> &player_cards, int dealer_card,
                  const std::string &hand_type, int player_total) {
  std::cout << "\nDealer shows: " << card_to_string(dealer_card) << std::endl;

  std::cout << "Your hand: ";
  for (size_t i = 0; i < player_cards.size(); ++i) {
    if (i > 0)
      std::cout << ", ";
    std::cout << card_to_string(player_cards[i]);
  }

  std::string hand_desc = hand_type;
  hand_desc[0] = std::toupper(hand_desc[0]); // Capitalize first letter
  std::cout << " (" << hand_desc << " " << player_total << ")" << std::endl;
}

char get_user_action() {
  std::cout << "\nWhat's your move?" << std::endl;
  std::cout << "(H)it, (S)tand, (D)ouble, s(P)lit: ";

  std::string input;
  std::getline(std::cin, input);

  if (input.empty()) {
    return '\0';
  }

  char action = std::toupper(input[0]);

  // Check for quit
  if (action == 'Q') {
    return '\0';
  }

  return action;
}

bool display_feedback(bool correct, char user_action, char correct_action,
                      const std::string &explanation) {
  if (correct) {
    std::cout << "\n✓ Correct!" << std::endl;
  } else {
    std::cout << "\n❌ Incorrect!" << std::endl;
    std::cout << "\nCorrect answer: " << action_to_string(correct_action)
              << std::endl;
    std::cout << "Your answer: " << action_to_string(user_action) << std::endl;
    std::cout << "\nPattern: " << explanation << std::endl;
  }

  std::cout << "\nPress Enter to continue (or 'q' + Enter to quit): ";
  std::string input;
  std::getline(std::cin, input);

  return !input.empty() && std::toupper(input[0]) == 'Q';
}

int display_dealer_groups() {
  std::cout << "\nChoose dealer strength group to practice:" << std::endl;
  std::cout << "1. Weak cards (4, 5, 6) - 'Bust cards'" << std::endl;
  std::cout << "2. Medium cards (2, 3, 7, 8)" << std::endl;
  std::cout << "3. Strong cards (9, 10, A)" << std::endl;
  std::cout << "0. Cancel" << std::endl;
  std::cout << "\nChoice (0-3): ";

  int choice;
  std::cin >> choice;
  std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

  return choice;
}

int display_hand_types() {
  std::cout << "\nChoose hand type to practice:" << std::endl;
  std::cout << "1. Hard totals (no ace or ace = 1)" << std::endl;
  std::cout << "2. Soft totals (ace = 11)" << std::endl;
  std::cout << "3. Pairs" << std::endl;
  std::cout << "0. Cancel" << std::endl;
  std::cout << "\nChoice (0-3): ";

  int choice;
  std::cin >> choice;
  std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

  return choice;
}

std::string card_to_string(int card) {
  if (card == 11) {
    return "A";
  } else if (card == 10) {
    return "10";
  } else {
    return std::to_string(card);
  }
}

std::string action_to_string(char action) {
  switch (action) {
  case 'H':
    return "HIT";
  case 'S':
    return "STAND";
  case 'D':
    return "DOUBLE";
  case 'Y':
  case 'P':
    return "SPLIT";
  default:
    return "UNKNOWN";
  }
}

} // namespace blackjack