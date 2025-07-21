#pragma once

#include <map>
#include <string>

namespace blackjack {

/**
 * Statistics tracking for blackjack strategy training sessions.
 *
 * This class tracks performance metrics during training sessions, including:
 * - Overall accuracy (correct answers / total attempts)
 * - Accuracy by hand type (hard totals, soft totals, pairs)
 * - Accuracy by dealer strength (weak, medium, strong dealer cards)
 *
 * Dealer strength categories:
 * - Weak: 4, 5, 6 (dealer bust cards)
 * - Medium: 2, 3, 7, 8 (moderate dealer cards)
 * - Strong: 9, 10, A (strong dealer cards)
 *
 * The statistics are maintained for the current session and can be displayed
 * to show the user's progress and identify areas for improvement.
 */
class Statistics {
public:
  Statistics();

  /**
   * Record an attempt in the training session.
   * @param hand_type Type of hand: "hard", "soft", or "pair"
   * @param dealer_strength Dealer strength: "weak", "medium", or "strong"
   * @param correct Whether the answer was correct
   */
  void record_attempt(const std::string &hand_type,
                      const std::string &dealer_strength, bool correct);

  /**
   * Get accuracy percentage for a specific category.
   * @param category Hand type category
   * @return Accuracy percentage (0-100)
   */
  double get_category_accuracy(const std::string &category) const;

  /**
   * Get accuracy percentage for a dealer strength category.
   * @param strength Dealer strength category
   * @return Accuracy percentage (0-100)
   */
  double get_dealer_strength_accuracy(const std::string &strength) const;

  /**
   * Get overall session accuracy percentage.
   * @return Accuracy percentage (0-100)
   */
  double get_session_accuracy() const;

  /**
   * Display progress statistics to the console.
   */
  void display_progress() const;

  /**
   * Reset session statistics.
   */
  void reset_session();

  /**
   * Determine dealer strength from dealer card.
   * @param dealer_card Dealer's up card (2-11, where 11 = Ace)
   * @return Dealer strength: "weak", "medium", or "strong"
   */
  std::string get_dealer_strength(int dealer_card) const;

private:
  struct CategoryData {
    int correct = 0;
    int total = 0;
  };

  int total_attempts_;
  int correct_answers_;
  std::map<std::string, CategoryData> by_category_;
  std::map<std::string, CategoryData> by_dealer_strength_;
};

} // namespace blackjack