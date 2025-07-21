#include "trainer.h"
#include "ui.h"
#include <algorithm>
#include <iomanip>
#include <iostream>
#include <random>

namespace blackjack {

TrainingSession::TrainingSession(const std::string &difficulty)
    : difficulty_(difficulty), strategy_(std::make_unique<StrategyChart>()),
      correct_count_(0), total_count_(0) {}

bool TrainingSession::setup_session() {
  return true; // Default implementation - no additional setup needed
}

std::vector<int>
TrainingSession::generate_hand_cards(const std::string &hand_type,
                                     int player_total) const {
  static std::random_device rd;
  static std::mt19937 gen(rd());

  if (hand_type == "pair") {
    return {player_total, player_total};
  } else if (hand_type == "soft") {
    int other_card = player_total - 11;
    return {11, other_card};
  } else { // hard
    if (player_total <= 11) {
      return {player_total};
    }
    // Generate two valid cards (2-10) that sum to player_total
    std::uniform_int_distribution<> dis(2, std::min(10, player_total - 2));
    int first_card = dis(gen);
    int second_card = player_total - first_card;

    // If second card would be > 10, we need more cards
    if (second_card > 10) {
      // For totals > 20, generate 3+ cards
      std::vector<int> cards = {first_card};
      int remaining = player_total - first_card;

      while (remaining > 10) {
        // Take a card between 2 and min(10, remaining-2) to ensure we can
        // finish
        int max_card = std::min(10, remaining - 2);
        if (max_card < 2) {
          break;
        }
        std::uniform_int_distribution<> card_dis(2, max_card);
        int card = card_dis(gen);
        cards.push_back(card);
        remaining -= card;
      }

      if (remaining >= 2) {
        cards.push_back(remaining);
      }
      return cards;
    } else if (second_card < 2) {
      // If second card would be < 2, just use single card
      return {player_total};
    } else {
      return {first_card, second_card};
    }
  }
}

bool TrainingSession::check_answer(char user_action,
                                   char correct_action) const {
  // Handle split variations
  if (user_action == 'P') {
    user_action = 'Y';
  }
  return user_action == correct_action;
}

std::pair<bool, bool> TrainingSession::show_feedback(
    const std::tuple<std::string, std::vector<int>, int, int> &scenario,
    char user_action, char correct_action) const {

  auto [hand_type, player_cards, player_total, dealer_card] = scenario;
  bool correct = check_answer(user_action, correct_action);
  std::string explanation =
      strategy_->get_explanation(hand_type, player_total, dealer_card);
  bool quit_requested =
      display_feedback(correct, user_action, correct_action, explanation);

  return {correct, quit_requested};
}

void TrainingSession::run(Statistics &stats) {
  display_session_header(get_mode_name());

  if (!setup_session()) {
    return; // User cancelled setup
  }

  int question_count = 0;
  while (question_count < get_max_questions()) {
    auto scenario = generate_scenario();
    auto [hand_type, player_cards, player_total, dealer_card] = scenario;

    display_hand(player_cards, dealer_card, hand_type, player_total);

    char user_action = get_user_action();
    if (user_action == '\0') { // User quit
      break;
    }

    char correct_action =
        strategy_->get_correct_action(hand_type, player_total, dealer_card);
    auto [correct, quit_requested] =
        show_feedback(scenario, user_action, correct_action);

    // Record statistics
    std::string dealer_strength = stats.get_dealer_strength(dealer_card);
    stats.record_attempt(hand_type, dealer_strength, correct);

    question_count++;

    if (correct) {
      correct_count_++;
    }
    total_count_++;

    if (quit_requested) {
      break;
    }
  }

  // Show session summary
  if (total_count_ > 0) {
    double accuracy =
        (static_cast<double>(correct_count_) / total_count_) * 100.0;
    std::cout << std::fixed << std::setprecision(1);
    std::cout << "\nSession complete! Final score: " << correct_count_ << "/"
              << total_count_ << " (" << accuracy << "%)" << std::endl;
  }
}

// RandomTrainingSession implementation
RandomTrainingSession::RandomTrainingSession(const std::string &difficulty)
    : TrainingSession(difficulty) {}

std::string RandomTrainingSession::get_mode_name() const { return "random"; }

int RandomTrainingSession::get_max_questions() const { return 50; }

std::tuple<std::string, std::vector<int>, int, int>
RandomTrainingSession::generate_scenario() {
  static std::random_device rd;
  static std::mt19937 gen(rd());

  std::uniform_int_distribution<> dealer_dis(2, 11);
  int dealer_card = dealer_dis(gen);

  std::vector<std::string> hand_types = {"hard", "soft", "pair"};
  std::uniform_int_distribution<> type_dis(0, 2);
  std::string hand_type = hand_types[type_dis(gen)];

  std::vector<int> player_cards;
  int player_total;

  if (hand_type == "pair") {
    std::vector<int> pair_values = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11};
    std::uniform_int_distribution<> pair_dis(0, pair_values.size() - 1);
    int pair_value = pair_values[pair_dis(gen)];
    player_cards = {pair_value, pair_value};
    player_total = pair_value;
  } else if (hand_type == "soft") {
    std::uniform_int_distribution<> other_dis(2, 9);
    int other_card = other_dis(gen);
    player_cards = {11, other_card};
    player_total = 11 + other_card;
  } else { // hard
    std::uniform_int_distribution<> total_dis(5, 20);
    player_total = total_dis(gen);
    player_cards = generate_hand_cards(hand_type, player_total);
  }

  return std::make_tuple(hand_type, player_cards, player_total, dealer_card);
}

// DealerGroupTrainingSession implementation
DealerGroupTrainingSession::DealerGroupTrainingSession(
    const std::string &difficulty)
    : TrainingSession(difficulty), dealer_group_(0) {}

std::string DealerGroupTrainingSession::get_mode_name() const {
  return "dealer_groups";
}

int DealerGroupTrainingSession::get_max_questions() const { return 50; }

bool DealerGroupTrainingSession::setup_session() {
  dealer_group_ = display_dealer_groups();
  return dealer_group_ != 0;
}

std::tuple<std::string, std::vector<int>, int, int>
DealerGroupTrainingSession::generate_scenario() {
  static std::random_device rd;
  static std::mt19937 gen(rd());

  // Select dealer card based on chosen group
  int dealer_card;
  if (dealer_group_ == 1) { // Weak
    std::vector<int> weak_cards = {4, 5, 6};
    std::uniform_int_distribution<> dis(0, weak_cards.size() - 1);
    dealer_card = weak_cards[dis(gen)];
  } else if (dealer_group_ == 2) { // Medium
    std::vector<int> medium_cards = {2, 3, 7, 8};
    std::uniform_int_distribution<> dis(0, medium_cards.size() - 1);
    dealer_card = medium_cards[dis(gen)];
  } else { // Strong
    std::vector<int> strong_cards = {9, 10, 11};
    std::uniform_int_distribution<> dis(0, strong_cards.size() - 1);
    dealer_card = strong_cards[dis(gen)];
  }

  std::vector<std::string> hand_types = {"hard", "soft", "pair"};
  std::uniform_int_distribution<> type_dis(0, 2);
  std::string hand_type = hand_types[type_dis(gen)];

  std::vector<int> player_cards;
  int player_total;

  if (hand_type == "pair") {
    std::vector<int> pair_values = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11};
    std::uniform_int_distribution<> pair_dis(0, pair_values.size() - 1);
    int pair_value = pair_values[pair_dis(gen)];
    player_cards = {pair_value, pair_value};
    player_total = pair_value;
  } else if (hand_type == "soft") {
    std::uniform_int_distribution<> other_dis(2, 9);
    int other_card = other_dis(gen);
    player_cards = {11, other_card};
    player_total = 11 + other_card;
  } else { // hard
    std::uniform_int_distribution<> total_dis(5, 20);
    player_total = total_dis(gen);
    player_cards = generate_hand_cards(hand_type, player_total);
  }

  return std::make_tuple(hand_type, player_cards, player_total, dealer_card);
}

// HandTypeTrainingSession implementation
HandTypeTrainingSession::HandTypeTrainingSession(const std::string &difficulty)
    : TrainingSession(difficulty), hand_type_choice_(0) {}

std::string HandTypeTrainingSession::get_mode_name() const {
  return "hand_types";
}

int HandTypeTrainingSession::get_max_questions() const { return 50; }

bool HandTypeTrainingSession::setup_session() {
  hand_type_choice_ = display_hand_types();
  return hand_type_choice_ != 0;
}

std::tuple<std::string, std::vector<int>, int, int>
HandTypeTrainingSession::generate_scenario() {
  static std::random_device rd;
  static std::mt19937 gen(rd());

  std::uniform_int_distribution<> dealer_dis(2, 11);
  int dealer_card = dealer_dis(gen);

  std::vector<int> player_cards;
  int player_total;
  std::string hand_type;

  if (hand_type_choice_ == 1) { // Hard totals
    std::uniform_int_distribution<> total_dis(5, 20);
    player_total = total_dis(gen);
    player_cards = generate_hand_cards("hard", player_total);
    hand_type = "hard";
  } else if (hand_type_choice_ == 2) { // Soft totals
    std::uniform_int_distribution<> other_dis(2, 9);
    int other_card = other_dis(gen);
    player_cards = {11, other_card};
    player_total = 11 + other_card;
    hand_type = "soft";
  } else { // Pairs
    std::vector<int> pair_values = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11};
    std::uniform_int_distribution<> pair_dis(0, pair_values.size() - 1);
    int pair_value = pair_values[pair_dis(gen)];
    player_cards = {pair_value, pair_value};
    player_total = pair_value;
    hand_type = "pair";
  }

  return std::make_tuple(hand_type, player_cards, player_total, dealer_card);
}

// AbsoluteTrainingSession implementation
AbsoluteTrainingSession::AbsoluteTrainingSession(const std::string &difficulty)
    : TrainingSession(difficulty) {}

std::string AbsoluteTrainingSession::get_mode_name() const {
  return "absolutes";
}

int AbsoluteTrainingSession::get_max_questions() const { return 20; }

std::tuple<std::string, std::vector<int>, int, int>
AbsoluteTrainingSession::generate_scenario() {
  static std::random_device rd;
  static std::mt19937 gen(rd());

  struct AbsoluteScenario {
    std::string hand_type;
    std::vector<int> player_cards;
    int player_total;
  };

  std::vector<AbsoluteScenario> absolutes = {
      {"pair", {11, 11}, 11}, // A,A
      {"pair", {8, 8}, 8},    // 8,8
      {"pair", {10, 10}, 10}, // 10,10
      {"pair", {5, 5}, 5},    // 5,5
      {"hard", {}, 17},       // Hard 17
      {"hard", {}, 18},       // Hard 18
      {"hard", {}, 19},       // Hard 19
      {"hard", {}, 20},       // Hard 20
      {"soft", {11, 8}, 19},  // Soft 19
      {"soft", {11, 9}, 20},  // Soft 20
  };

  std::uniform_int_distribution<> abs_dis(0, absolutes.size() - 1);
  AbsoluteScenario scenario = absolutes[abs_dis(gen)];

  std::uniform_int_distribution<> dealer_dis(2, 11);
  int dealer_card = dealer_dis(gen);

  std::vector<int> player_cards = scenario.player_cards;
  if (player_cards.empty()) { // Hard totals
    player_cards =
        generate_hand_cards(scenario.hand_type, scenario.player_total);
  }

  return std::make_tuple(scenario.hand_type, player_cards,
                         scenario.player_total, dealer_card);
}

} // namespace blackjack