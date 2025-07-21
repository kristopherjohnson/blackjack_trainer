#pragma once

#include <map>
#include <string>
#include <utility>
#include <vector>

namespace blackjack {

/**
 * Complete blackjack basic strategy chart implementation.
 *
 * This class encapsulates the optimal basic strategy for blackjack based on
 * standard casino rules: 4-8 decks, dealer stands on soft 17, double after
 * split allowed, surrender not allowed.
 *
 * The strategy chart covers three main categories:
 * - Hard totals (5-21): Hands without aces or where ace counts as 1
 * - Soft totals (13-21): Hands with ace counting as 11 (A,2 through A,9)
 * - Pairs (2,2 through A,A): Identical card pairs for split decisions
 *
 * Action codes:
 * - H: Hit (take another card)
 * - S: Stand (keep current total)
 * - D: Double down (double bet, take exactly one more card)
 * - Y: Split (for pairs - split into two separate hands)
 *
 * The class also provides:
 * - Explanatory mnemonics for learning key patterns
 * - Dealer strength groupings (weak/medium/strong)
 * - Absolute rule identification for never/always scenarios
 *
 * All strategy decisions are based on mathematically optimal play that
 * minimizes the house edge over the long term.
 */
class StrategyChart {
public:
  StrategyChart();

  /**
   * Get the correct action for a given scenario.
   * @param hand_type Type of hand: "hard", "soft", or "pair"
   * @param player_total Player's hand total or pair value
   * @param dealer_card Dealer's up card (2-11, where 11 = Ace)
   * @return Action character: 'H', 'S', 'D', or 'Y'
   */
  char get_correct_action(const std::string &hand_type, int player_total,
                          int dealer_card) const;

  /**
   * Get an explanation/mnemonic for a given scenario.
   * @param hand_type Type of hand: "hard", "soft", or "pair"
   * @param player_total Player's hand total or pair value
   * @param dealer_card Dealer's up card (2-11, where 11 = Ace)
   * @return Explanatory string
   */
  std::string get_explanation(const std::string &hand_type, int player_total,
                              int dealer_card) const;

  /**
   * Check if a scenario represents an absolute rule (always/never).
   * @param hand_type Type of hand: "hard", "soft", or "pair"
   * @param player_total Player's hand total or pair value
   * @param dealer_card Dealer's up card (2-11, where 11 = Ace)
   * @return True if this is an absolute rule
   */
  bool is_absolute_rule(const std::string &hand_type, int player_total,
                        int dealer_card) const;

  /**
   * Get dealer strength groups.
   * @return Map of strength name to vector of dealer cards
   */
  const std::map<std::string, std::vector<int>> &get_dealer_groups() const;

private:
  void build_hard_totals();
  void build_soft_totals();
  void build_pairs();
  void build_mnemonics();

  std::map<std::pair<int, int>, char> hard_totals_;
  std::map<std::pair<int, int>, char> soft_totals_;
  std::map<std::pair<int, int>, char> pairs_;
  std::map<std::string, std::string> mnemonics_;
  std::map<std::string, std::vector<int>> dealer_groups_;
};

} // namespace blackjack