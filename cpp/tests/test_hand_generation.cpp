#include "trainer.h"
#include <algorithm>
#include <doctest/doctest.h>
#include <numeric>

using namespace blackjack;

// Test fixture class that exposes protected methods
class TestableTrainingSession : public RandomTrainingSession {
public:
  TestableTrainingSession() : RandomTrainingSession() {}

  // Expose the protected method for testing
  std::vector<int> test_generate_hand_cards(const std::string &hand_type,
                                            int player_total) {
    return generate_hand_cards(hand_type, player_total);
  }
};

TEST_CASE("Hand generation produces valid card combinations") {

  SUBCASE("Pair hand generation") {
    for (int pair_value : {2, 3, 4, 5, 6, 7, 8, 9, 10, 11}) {
      TestableTrainingSession session;
      auto cards = session.test_generate_hand_cards("pair", pair_value);

      CHECK(cards.size() == 2);
      CHECK(cards[0] == pair_value);
      CHECK(cards[1] == pair_value);
    }
  }

  SUBCASE("Soft hand generation") {
    for (int soft_total = 13; soft_total <= 21;
         ++soft_total) { // A,2 through A,10 (13-21)
      TestableTrainingSession session;
      auto cards = session.test_generate_hand_cards("soft", soft_total);

      CHECK(cards.size() == 2);
      CHECK(std::find(cards.begin(), cards.end(), 11) != cards.end());

      int other_card = soft_total - 11;
      CHECK(std::find(cards.begin(), cards.end(), other_card) != cards.end());
      CHECK(other_card >= 2);
      CHECK(other_card <= 10);
    }
  }

  SUBCASE("Hard hand valid cards") {
    for (int total = 5; total <= 21; ++total) { // Hard 5-21
      TestableTrainingSession session;
      auto cards = session.test_generate_hand_cards("hard", total);

      // All cards must be valid (2-11)
      for (int card : cards) {
        CHECK(card >= 2);
        CHECK(card <= 11);
      }

      // Cards must sum to the total
      int sum = std::accumulate(cards.begin(), cards.end(), 0);
      CHECK(sum == total);
    }
  }

  SUBCASE("Hard hand no aces for low totals") {
    for (int total = 5; total <= 10;
         ++total) { // Hard 5-10 (11 can be a single Ace)
      TestableTrainingSession session;
      auto cards = session.test_generate_hand_cards("hard", total);

      // For totals 5-10, we shouldn't need aces (would make it soft)
      for (int card : cards) {
        CHECK(card != 11);
      }
    }
  }

  SUBCASE("Hard hand realistic combinations") {
    // Test many iterations to catch edge cases
    for (int iteration = 0; iteration < 100; ++iteration) {
      for (int total = 12; total <= 21; ++total) { // Hard 12-21
        TestableTrainingSession session;
        auto cards = session.test_generate_hand_cards("hard", total);

        // All cards must be 2-10 (no aces in hard totals)
        for (int card : cards) {
          CHECK(card >= 2);
          CHECK(card <= 10);
        }

        // Should have reasonable number of cards
        CHECK(cards.size() <= 6);
      }
    }
  }

  SUBCASE("Edge case totals") {
    // Test hard 20 and 21
    for (int total : {20, 21}) {
      TestableTrainingSession session;
      auto cards = session.test_generate_hand_cards("hard", total);

      // Should still be valid
      int sum = std::accumulate(cards.begin(), cards.end(), 0);
      CHECK(sum == total);

      for (int card : cards) {
        CHECK(card >= 2);
        CHECK(card <= 10);
      }
    }
  }

  SUBCASE("Single card totals") {
    for (int total = 2; total <= 11; ++total) { // 2-11
      TestableTrainingSession session;
      auto cards = session.test_generate_hand_cards("hard", total);

      if (total <= 11) {
        // Should be single card for low totals
        CHECK(cards.size() == 1);
        CHECK(cards[0] == total);
      }
    }
  }

  SUBCASE("No invalid card values") {
    std::vector<int> invalid_values = {0,  1,  12, 13, 14, 15,
                                       16, 17, 18, 19, 20, 21};

    for (int iteration = 0; iteration < 200;
         ++iteration) { // Many iterations to catch rare cases
      std::vector<std::string> hand_types = {"hard", "soft", "pair"};
      for (const std::string &hand_type : hand_types) {
        std::vector<int> totals;

        if (hand_type == "pair") {
          totals = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11};
        } else if (hand_type == "soft") {
          for (int i = 13; i <= 21; ++i)
            totals.push_back(i);
        } else { // hard
          for (int i = 5; i <= 21; ++i)
            totals.push_back(i);
        }

        for (int total : totals) {
          TestableTrainingSession session;
          auto cards = session.test_generate_hand_cards(hand_type, total);

          for (int card : cards) {
            CHECK(std::find(invalid_values.begin(), invalid_values.end(),
                            card) == invalid_values.end());
          }
        }
      }
    }
  }

  SUBCASE("Hard 18 specific case") {
    // Test hard 18 many times to ensure no invalid cards
    for (int iteration = 0; iteration < 50; ++iteration) {
      TestableTrainingSession session;
      auto cards = session.test_generate_hand_cards("hard", 18);

      // Should sum to 18
      int sum = std::accumulate(cards.begin(), cards.end(), 0);
      CHECK(sum == 18);

      // All cards should be valid (2-10)
      for (int card : cards) {
        CHECK(card >= 2);
        CHECK(card <= 10);
      }

      // Should not contain the problematic card 16
      CHECK(std::find(cards.begin(), cards.end(), 16) == cards.end());
    }
  }
}