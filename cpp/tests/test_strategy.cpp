#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include "strategy.h"
#include <doctest/doctest.h>

using namespace blackjack;

TEST_SUITE("StrategyChart") {
  TEST_CASE("Hard totals low values (5-8)") {
    StrategyChart chart;

    for (int total = 5; total <= 8; ++total) {
      for (int dealer = 2; dealer <= 11; ++dealer) {
        char action = chart.get_correct_action("hard", total, dealer);
        CHECK_EQ(action, 'H');
      }
    }
  }

  TEST_CASE("Hard 9 strategy") {
    StrategyChart chart;

    for (int dealer = 2; dealer <= 11; ++dealer) {
      char action = chart.get_correct_action("hard", 9, dealer);
      if (dealer >= 3 && dealer <= 6) {
        CHECK_EQ(action, 'D');
      } else {
        CHECK_EQ(action, 'H');
      }
    }
  }

  TEST_CASE("Hard 10 strategy") {
    StrategyChart chart;

    for (int dealer = 2; dealer <= 11; ++dealer) {
      char action = chart.get_correct_action("hard", 10, dealer);
      if (dealer >= 2 && dealer <= 9) {
        CHECK_EQ(action, 'D');
      } else {
        CHECK_EQ(action, 'H');
      }
    }
  }

  TEST_CASE("Hard 11 strategy") {
    StrategyChart chart;

    for (int dealer = 2; dealer <= 11; ++dealer) {
      char action = chart.get_correct_action("hard", 11, dealer);
      if (dealer <= 10) {
        CHECK_EQ(action, 'D');
      } else { // Ace
        CHECK_EQ(action, 'H');
      }
    }
  }

  TEST_CASE("Hard 12 strategy") {
    StrategyChart chart;

    for (int dealer = 2; dealer <= 11; ++dealer) {
      char action = chart.get_correct_action("hard", 12, dealer);
      if (dealer >= 4 && dealer <= 6) {
        CHECK_EQ(action, 'S');
      } else {
        CHECK_EQ(action, 'H');
      }
    }
  }

  TEST_CASE("Hard 13-16 strategy") {
    StrategyChart chart;

    for (int total = 13; total <= 16; ++total) {
      for (int dealer = 2; dealer <= 11; ++dealer) {
        char action = chart.get_correct_action("hard", total, dealer);
        if (dealer >= 2 && dealer <= 6) {
          CHECK_EQ(action, 'S');
        } else {
          CHECK_EQ(action, 'H');
        }
      }
    }
  }

  TEST_CASE("Hard 17+ strategy") {
    StrategyChart chart;

    for (int total = 17; total <= 21; ++total) {
      for (int dealer = 2; dealer <= 11; ++dealer) {
        char action = chart.get_correct_action("hard", total, dealer);
        CHECK_EQ(action, 'S');
      }
    }
  }

  TEST_CASE("Soft 13-14 strategy") {
    StrategyChart chart;

    for (int total : {13, 14}) {
      for (int dealer = 2; dealer <= 11; ++dealer) {
        char action = chart.get_correct_action("soft", total, dealer);
        if (dealer >= 5 && dealer <= 6) {
          CHECK_EQ(action, 'D');
        } else {
          CHECK_EQ(action, 'H');
        }
      }
    }
  }

  TEST_CASE("Soft 15-16 strategy") {
    StrategyChart chart;

    for (int total : {15, 16}) {
      for (int dealer = 2; dealer <= 11; ++dealer) {
        char action = chart.get_correct_action("soft", total, dealer);
        if (dealer >= 4 && dealer <= 6) {
          CHECK_EQ(action, 'D');
        } else {
          CHECK_EQ(action, 'H');
        }
      }
    }
  }

  TEST_CASE("Soft 17 strategy") {
    StrategyChart chart;

    for (int dealer = 2; dealer <= 11; ++dealer) {
      char action = chart.get_correct_action("soft", 17, dealer);
      if (dealer >= 3 && dealer <= 6) {
        CHECK_EQ(action, 'D');
      } else {
        CHECK_EQ(action, 'H');
      }
    }
  }

  TEST_CASE("Soft 18 strategy") {
    StrategyChart chart;

    for (int dealer = 2; dealer <= 11; ++dealer) {
      char action = chart.get_correct_action("soft", 18, dealer);
      if (dealer == 2 || dealer == 7 || dealer == 8) {
        CHECK_EQ(action, 'S');
      } else if (dealer >= 3 && dealer <= 6) {
        CHECK_EQ(action, 'D');
      } else { // 9, 10, A
        CHECK_EQ(action, 'H');
      }
    }
  }

  TEST_CASE("Soft 19+ strategy") {
    StrategyChart chart;

    for (int total : {19, 20, 21}) {
      for (int dealer = 2; dealer <= 11; ++dealer) {
        char action = chart.get_correct_action("soft", total, dealer);
        CHECK_EQ(action, 'S');
      }
    }
  }

  TEST_CASE("Pairs - Aces") {
    StrategyChart chart;

    for (int dealer = 2; dealer <= 11; ++dealer) {
      char action = chart.get_correct_action("pair", 11, dealer);
      CHECK_EQ(action, 'Y');
    }
  }

  TEST_CASE("Pairs - 2,2 and 3,3") {
    StrategyChart chart;

    for (int pair_val : {2, 3}) {
      for (int dealer = 2; dealer <= 11; ++dealer) {
        char action = chart.get_correct_action("pair", pair_val, dealer);
        if (dealer >= 2 && dealer <= 7) {
          CHECK_EQ(action, 'Y');
        } else {
          CHECK_EQ(action, 'H');
        }
      }
    }
  }

  TEST_CASE("Pairs - 4,4") {
    StrategyChart chart;

    for (int dealer = 2; dealer <= 11; ++dealer) {
      char action = chart.get_correct_action("pair", 4, dealer);
      if (dealer >= 5 && dealer <= 6) {
        CHECK_EQ(action, 'Y');
      } else {
        CHECK_EQ(action, 'H');
      }
    }
  }

  TEST_CASE("Pairs - 5,5") {
    StrategyChart chart;

    for (int dealer = 2; dealer <= 11; ++dealer) {
      char action = chart.get_correct_action("pair", 5, dealer);
      if (dealer >= 2 && dealer <= 9) {
        CHECK_EQ(action, 'D');
      } else {
        CHECK_EQ(action, 'H');
      }
    }
  }

  TEST_CASE("Pairs - 6,6") {
    StrategyChart chart;

    for (int dealer = 2; dealer <= 11; ++dealer) {
      char action = chart.get_correct_action("pair", 6, dealer);
      if (dealer >= 2 && dealer <= 6) {
        CHECK_EQ(action, 'Y');
      } else {
        CHECK_EQ(action, 'H');
      }
    }
  }

  TEST_CASE("Pairs - 7,7") {
    StrategyChart chart;

    for (int dealer = 2; dealer <= 11; ++dealer) {
      char action = chart.get_correct_action("pair", 7, dealer);
      if (dealer >= 2 && dealer <= 7) {
        CHECK_EQ(action, 'Y');
      } else {
        CHECK_EQ(action, 'H');
      }
    }
  }

  TEST_CASE("Pairs - 8,8") {
    StrategyChart chart;

    for (int dealer = 2; dealer <= 11; ++dealer) {
      char action = chart.get_correct_action("pair", 8, dealer);
      CHECK_EQ(action, 'Y');
    }
  }

  TEST_CASE("Pairs - 9,9") {
    StrategyChart chart;

    for (int dealer = 2; dealer <= 11; ++dealer) {
      char action = chart.get_correct_action("pair", 9, dealer);
      if (dealer == 7 || dealer == 10 || dealer == 11) {
        CHECK_EQ(action, 'S');
      } else {
        CHECK_EQ(action, 'Y');
      }
    }
  }

  TEST_CASE("Pairs - 10,10") {
    StrategyChart chart;

    for (int dealer = 2; dealer <= 11; ++dealer) {
      char action = chart.get_correct_action("pair", 10, dealer);
      CHECK_EQ(action, 'S');
    }
  }

  TEST_CASE("Absolute rules") {
    StrategyChart chart;

    // Test absolute rules identification
    CHECK(chart.is_absolute_rule("pair", 11, 5));  // A,A
    CHECK(chart.is_absolute_rule("pair", 8, 10));  // 8,8
    CHECK(chart.is_absolute_rule("pair", 10, 6));  // 10,10
    CHECK(chart.is_absolute_rule("pair", 5, 4));   // 5,5
    CHECK(chart.is_absolute_rule("hard", 17, 10)); // Hard 17+
    CHECK(chart.is_absolute_rule("soft", 19, 6));  // Soft 19+

    // Test non-absolute rules
    CHECK_FALSE(chart.is_absolute_rule("hard", 16, 7));
    CHECK_FALSE(chart.is_absolute_rule("soft", 18, 6));
    CHECK_FALSE(chart.is_absolute_rule("pair", 6, 4));
  }

  TEST_CASE("Explanations") {
    StrategyChart chart;

    // Test that explanations are returned
    std::string explanation = chart.get_explanation("pair", 11, 5);
    CHECK_FALSE(explanation.empty());
    CHECK_GT(explanation.length(), 0);

    explanation = chart.get_explanation("hard", 16, 10);
    CHECK_FALSE(explanation.empty());
    CHECK_GT(explanation.length(), 0);
  }

  TEST_CASE("Dealer groups") {
    StrategyChart chart;

    const auto &dealer_groups = chart.get_dealer_groups();

    CHECK_EQ(dealer_groups.at("weak"), std::vector<int>({4, 5, 6}));
    CHECK_EQ(dealer_groups.at("medium"), std::vector<int>({2, 3, 7, 8}));
    CHECK_EQ(dealer_groups.at("strong"), std::vector<int>({9, 10, 11}));
  }

  TEST_CASE("Edge cases") {
    StrategyChart chart;

    // Hard 12 vs 2 should be Hit (exception to 13-16 rule)
    CHECK_EQ(chart.get_correct_action("hard", 12, 2), 'H');

    // Hard 12 vs 3 should be Hit (exception to 13-16 rule)
    CHECK_EQ(chart.get_correct_action("hard", 12, 3), 'H');

    // Soft 18 vs 9 should be Hit (not stand)
    CHECK_EQ(chart.get_correct_action("soft", 18, 9), 'H');

    // Pair 9s vs 7 should be Stand (not split)
    CHECK_EQ(chart.get_correct_action("pair", 9, 7), 'S');
  }
}

TEST_SUITE("StrategyChart Comprehensive") {
  TEST_CASE("All hard totals coverage") {
    StrategyChart chart;

    // Test that all hard total combinations have valid actions
    for (int total = 5; total <= 21; ++total) {
      for (int dealer = 2; dealer <= 11; ++dealer) {
        char action = chart.get_correct_action("hard", total, dealer);
        CHECK((action == 'H' || action == 'S' || action == 'D'));
      }
    }
  }

  TEST_CASE("All soft totals coverage") {
    StrategyChart chart;

    // Test that all soft total combinations have valid actions
    for (int total = 13; total <= 21; ++total) {
      for (int dealer = 2; dealer <= 11; ++dealer) {
        char action = chart.get_correct_action("soft", total, dealer);
        CHECK((action == 'H' || action == 'S' || action == 'D'));
      }
    }
  }

  TEST_CASE("All pairs coverage") {
    StrategyChart chart;

    // Test that all pair combinations have valid actions
    for (int pair_val = 2; pair_val <= 11; ++pair_val) {
      for (int dealer = 2; dealer <= 11; ++dealer) {
        char action = chart.get_correct_action("pair", pair_val, dealer);
        CHECK(
            (action == 'H' || action == 'S' || action == 'D' || action == 'Y'));
      }
    }
  }
}