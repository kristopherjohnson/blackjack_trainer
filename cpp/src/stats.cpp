#include "stats.h"
#include <iomanip>
#include <iostream>

namespace blackjack {

Statistics::Statistics() : total_attempts_(0), correct_answers_(0) {
  // Initialize category tracking
  by_category_["hard"] = CategoryData{};
  by_category_["soft"] = CategoryData{};
  by_category_["pair"] = CategoryData{};

  // Initialize dealer strength tracking
  by_dealer_strength_["weak"] = CategoryData{};
  by_dealer_strength_["medium"] = CategoryData{};
  by_dealer_strength_["strong"] = CategoryData{};
}

void Statistics::record_attempt(const std::string &hand_type,
                                const std::string &dealer_strength,
                                bool correct) {
  total_attempts_++;
  if (correct) {
    correct_answers_++;
  }

  // Record by hand type
  if (by_category_.find(hand_type) != by_category_.end()) {
    by_category_[hand_type].total++;
    if (correct) {
      by_category_[hand_type].correct++;
    }
  }

  // Record by dealer strength
  if (by_dealer_strength_.find(dealer_strength) != by_dealer_strength_.end()) {
    by_dealer_strength_[dealer_strength].total++;
    if (correct) {
      by_dealer_strength_[dealer_strength].correct++;
    }
  }
}

double Statistics::get_category_accuracy(const std::string &category) const {
  auto it = by_category_.find(category);
  if (it == by_category_.end() || it->second.total == 0) {
    return 0.0;
  }
  return (static_cast<double>(it->second.correct) / it->second.total) * 100.0;
}

double
Statistics::get_dealer_strength_accuracy(const std::string &strength) const {
  auto it = by_dealer_strength_.find(strength);
  if (it == by_dealer_strength_.end() || it->second.total == 0) {
    return 0.0;
  }
  return (static_cast<double>(it->second.correct) / it->second.total) * 100.0;
}

double Statistics::get_session_accuracy() const {
  if (total_attempts_ == 0) {
    return 0.0;
  }
  return (static_cast<double>(correct_answers_) / total_attempts_) * 100.0;
}

void Statistics::display_progress() const {
  std::cout << "\n" << std::string(50, '=') << std::endl;
  std::cout << "SESSION STATISTICS" << std::endl;
  std::cout << std::string(50, '=') << std::endl;

  if (total_attempts_ == 0) {
    std::cout << "No practice attempts yet this session." << std::endl;
    std::cout << "\nPress Enter to continue...";
    std::cin.ignore();
    std::cin.get();
    return;
  }

  std::cout << std::fixed << std::setprecision(1);
  std::cout << "Overall: " << correct_answers_ << "/" << total_attempts_ << " ("
            << get_session_accuracy() << "%)" << std::endl;

  std::cout << "\nBy Hand Type:" << std::endl;
  for (const auto &hand_type : {"hard", "soft", "pair"}) {
    auto it = by_category_.find(hand_type);
    if (it != by_category_.end() && it->second.total > 0) {
      double accuracy =
          (static_cast<double>(it->second.correct) / it->second.total) * 100.0;
      std::cout << "  " << hand_type << ": " << it->second.correct << "/"
                << it->second.total << " (" << accuracy << "%)" << std::endl;
    }
  }

  std::cout << "\nBy Dealer Strength:" << std::endl;
  for (const auto &strength : {"weak", "medium", "strong"}) {
    auto it = by_dealer_strength_.find(strength);
    if (it != by_dealer_strength_.end() && it->second.total > 0) {
      double accuracy =
          (static_cast<double>(it->second.correct) / it->second.total) * 100.0;
      std::cout << "  " << strength << ": " << it->second.correct << "/"
                << it->second.total << " (" << accuracy << "%)" << std::endl;
    }
  }

  std::cout << "\nPress Enter to continue...";
  std::cin.ignore();
  std::cin.get();
}

void Statistics::reset_session() {
  total_attempts_ = 0;
  correct_answers_ = 0;

  for (auto &category : by_category_) {
    category.second = CategoryData{};
  }

  for (auto &strength : by_dealer_strength_) {
    strength.second = CategoryData{};
  }
}

std::string Statistics::get_dealer_strength(int dealer_card) const {
  if (dealer_card == 4 || dealer_card == 5 || dealer_card == 6) {
    return "weak";
  } else if (dealer_card == 2 || dealer_card == 3 || dealer_card == 7 ||
             dealer_card == 8) {
    return "medium";
  } else {
    // 9, 10, 11 (Ace)
    return "strong";
  }
}

} // namespace blackjack