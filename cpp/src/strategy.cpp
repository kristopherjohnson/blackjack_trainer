#include "strategy.h"
#include <algorithm>

namespace blackjack {

StrategyChart::StrategyChart() {
  build_hard_totals();
  build_soft_totals();
  build_pairs();
  build_mnemonics();

  dealer_groups_["weak"] = {4, 5, 6};
  dealer_groups_["medium"] = {2, 3, 7, 8};
  dealer_groups_["strong"] = {9, 10, 11};
}

void StrategyChart::build_hard_totals() {
  // Hard 5-8: Always hit
  for (int total = 5; total <= 8; ++total) {
    for (int dealer = 2; dealer <= 11; ++dealer) {
      hard_totals_[{total, dealer}] = 'H';
    }
  }

  // Hard 9: Double vs 3-6, otherwise hit
  for (int dealer = 2; dealer <= 11; ++dealer) {
    if (dealer >= 3 && dealer <= 6) {
      hard_totals_[{9, dealer}] = 'D';
    } else {
      hard_totals_[{9, dealer}] = 'H';
    }
  }

  // Hard 10: Double vs 2-9, otherwise hit
  for (int dealer = 2; dealer <= 11; ++dealer) {
    if (dealer >= 2 && dealer <= 9) {
      hard_totals_[{10, dealer}] = 'D';
    } else {
      hard_totals_[{10, dealer}] = 'H';
    }
  }

  // Hard 11: Double vs 2-10, hit vs Ace
  for (int dealer = 2; dealer <= 11; ++dealer) {
    if (dealer <= 10) {
      hard_totals_[{11, dealer}] = 'D';
    } else {
      hard_totals_[{11, dealer}] = 'H';
    }
  }

  // Hard 12: Stand vs 4-6, otherwise hit
  for (int dealer = 2; dealer <= 11; ++dealer) {
    if (dealer >= 4 && dealer <= 6) {
      hard_totals_[{12, dealer}] = 'S';
    } else {
      hard_totals_[{12, dealer}] = 'H';
    }
  }

  // Hard 13-16: Stand vs 2-6, otherwise hit
  for (int total = 13; total <= 16; ++total) {
    for (int dealer = 2; dealer <= 11; ++dealer) {
      if (dealer >= 2 && dealer <= 6) {
        hard_totals_[{total, dealer}] = 'S';
      } else {
        hard_totals_[{total, dealer}] = 'H';
      }
    }
  }

  // Hard 17+: Always stand
  for (int total = 17; total <= 21; ++total) {
    for (int dealer = 2; dealer <= 11; ++dealer) {
      hard_totals_[{total, dealer}] = 'S';
    }
  }
}

void StrategyChart::build_soft_totals() {
  // Soft 13-14 (A,2-A,3): Double vs 5-6, otherwise hit
  for (int total : {13, 14}) {
    for (int dealer = 2; dealer <= 11; ++dealer) {
      if (dealer >= 5 && dealer <= 6) {
        soft_totals_[{total, dealer}] = 'D';
      } else {
        soft_totals_[{total, dealer}] = 'H';
      }
    }
  }

  // Soft 15-16 (A,4-A,5): Double vs 4-6, otherwise hit
  for (int total : {15, 16}) {
    for (int dealer = 2; dealer <= 11; ++dealer) {
      if (dealer >= 4 && dealer <= 6) {
        soft_totals_[{total, dealer}] = 'D';
      } else {
        soft_totals_[{total, dealer}] = 'H';
      }
    }
  }

  // Soft 17 (A,6): Double vs 3-6, otherwise hit
  for (int dealer = 2; dealer <= 11; ++dealer) {
    if (dealer >= 3 && dealer <= 6) {
      soft_totals_[{17, dealer}] = 'D';
    } else {
      soft_totals_[{17, dealer}] = 'H';
    }
  }

  // Soft 18 (A,7): Stand vs 2,7,8; Double vs 3-6; Hit vs 9,10,A
  for (int dealer = 2; dealer <= 11; ++dealer) {
    if (dealer == 2 || dealer == 7 || dealer == 8) {
      soft_totals_[{18, dealer}] = 'S';
    } else if (dealer >= 3 && dealer <= 6) {
      soft_totals_[{18, dealer}] = 'D';
    } else {
      soft_totals_[{18, dealer}] = 'H';
    }
  }

  // Soft 19-21: Always stand
  for (int total : {19, 20, 21}) {
    for (int dealer = 2; dealer <= 11; ++dealer) {
      soft_totals_[{total, dealer}] = 'S';
    }
  }
}

void StrategyChart::build_pairs() {
  // A,A: Always split
  for (int dealer = 2; dealer <= 11; ++dealer) {
    pairs_[{11, dealer}] = 'Y';
  }

  // 2,2 and 3,3: Split vs 2-7, otherwise hit
  for (int pair_val : {2, 3}) {
    for (int dealer = 2; dealer <= 11; ++dealer) {
      if (dealer >= 2 && dealer <= 7) {
        pairs_[{pair_val, dealer}] = 'Y';
      } else {
        pairs_[{pair_val, dealer}] = 'H';
      }
    }
  }

  // 4,4: Split vs 5-6, otherwise hit
  for (int dealer = 2; dealer <= 11; ++dealer) {
    if (dealer >= 5 && dealer <= 6) {
      pairs_[{4, dealer}] = 'Y';
    } else {
      pairs_[{4, dealer}] = 'H';
    }
  }

  // 5,5: Never split, treat as hard 10
  for (int dealer = 2; dealer <= 11; ++dealer) {
    if (dealer >= 2 && dealer <= 9) {
      pairs_[{5, dealer}] = 'D';
    } else {
      pairs_[{5, dealer}] = 'H';
    }
  }

  // 6,6: Split vs 2-6, otherwise hit
  for (int dealer = 2; dealer <= 11; ++dealer) {
    if (dealer >= 2 && dealer <= 6) {
      pairs_[{6, dealer}] = 'Y';
    } else {
      pairs_[{6, dealer}] = 'H';
    }
  }

  // 7,7: Split vs 2-7, otherwise hit
  for (int dealer = 2; dealer <= 11; ++dealer) {
    if (dealer >= 2 && dealer <= 7) {
      pairs_[{7, dealer}] = 'Y';
    } else {
      pairs_[{7, dealer}] = 'H';
    }
  }

  // 8,8: Always split
  for (int dealer = 2; dealer <= 11; ++dealer) {
    pairs_[{8, dealer}] = 'Y';
  }

  // 9,9: Split vs 2-9 except 7, stand vs 7,10,A
  for (int dealer = 2; dealer <= 11; ++dealer) {
    if (dealer == 7 || dealer == 10 || dealer == 11) {
      pairs_[{9, dealer}] = 'S';
    } else {
      pairs_[{9, dealer}] = 'Y';
    }
  }

  // 10,10: Never split, always stand
  for (int dealer = 2; dealer <= 11; ++dealer) {
    pairs_[{10, dealer}] = 'S';
  }
}

void StrategyChart::build_mnemonics() {
  mnemonics_["dealer_weak"] = "Dealer bust cards (4,5,6) = player gets greedy";
  mnemonics_["always_split"] = "Aces and eights, don't hesitate";
  mnemonics_["never_split"] = "Tens and fives, keep them alive";
  mnemonics_["teens_vs_strong"] = "Teens stay vs weak, flee from strong";
  mnemonics_["soft_17"] = "A,7 is the tricky soft hand";
  mnemonics_["hard_12"] = "12 is the exception - only stand vs 4,5,6";
  mnemonics_["doubles"] = "Double when dealer is weak and you can improve";
}

char StrategyChart::get_correct_action(const std::string &hand_type,
                                       int player_total,
                                       int dealer_card) const {
  std::pair<int, int> key = {player_total, dealer_card};

  if (hand_type == "pair") {
    auto it = pairs_.find(key);
    return (it != pairs_.end()) ? it->second : 'H';
  } else if (hand_type == "soft") {
    auto it = soft_totals_.find(key);
    return (it != soft_totals_.end()) ? it->second : 'H';
  } else { // hard
    auto it = hard_totals_.find(key);
    return (it != hard_totals_.end()) ? it->second : 'H';
  }
}

std::string StrategyChart::get_explanation(const std::string &hand_type,
                                           int player_total,
                                           int dealer_card) const {
  // Specific explanations for key scenarios
  if (hand_type == "pair" && player_total == 11) {
    return mnemonics_.at("always_split");
  }
  if (hand_type == "pair" && player_total == 8) {
    return mnemonics_.at("always_split");
  }
  if (hand_type == "pair" && player_total == 10) {
    return mnemonics_.at("never_split");
  }
  if (hand_type == "pair" && player_total == 5) {
    return mnemonics_.at("never_split");
  }
  if (hand_type == "soft" && player_total == 18) {
    return mnemonics_.at("soft_17");
  }
  if (hand_type == "hard" && player_total == 12) {
    return mnemonics_.at("hard_12");
  }

  // Dealer strength based explanations
  auto weak_cards = dealer_groups_.at("weak");
  auto strong_cards = dealer_groups_.at("strong");

  if (std::find(weak_cards.begin(), weak_cards.end(), dealer_card) !=
      weak_cards.end()) {
    return mnemonics_.at("dealer_weak");
  }

  if (player_total >= 13 && player_total <= 16 &&
      std::find(strong_cards.begin(), strong_cards.end(), dealer_card) !=
          strong_cards.end()) {
    return mnemonics_.at("teens_vs_strong");
  }

  return "Follow basic strategy patterns";
}

bool StrategyChart::is_absolute_rule(const std::string &hand_type,
                                     int player_total,
                                     int /* dealer_card */) const {
  // Pair absolutes
  if (hand_type == "pair") {
    if (player_total == 11 || player_total == 8 || player_total == 10 ||
        player_total == 5) {
      return true;
    }
  }

  // Hard 17+ always stand
  if (hand_type == "hard" && player_total >= 17) {
    return true;
  }

  // Soft 19+ always stand
  if (hand_type == "soft" && player_total >= 19) {
    return true;
  }

  return false;
}

const std::map<std::string, std::vector<int>> &
StrategyChart::get_dealer_groups() const {
  return dealer_groups_;
}

} // namespace blackjack