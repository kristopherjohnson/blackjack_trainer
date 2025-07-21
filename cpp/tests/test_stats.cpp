#include "stats.h"
#include <doctest/doctest.h>

using namespace blackjack;

TEST_SUITE("Statistics") {
  TEST_CASE("Initial state") {
    Statistics stats;

    // Test initial state
    CHECK_EQ(stats.get_session_accuracy(), 0.0);
    CHECK_EQ(stats.get_category_accuracy("hard"), 0.0);
    CHECK_EQ(stats.get_category_accuracy("soft"), 0.0);
    CHECK_EQ(stats.get_category_accuracy("pair"), 0.0);
    CHECK_EQ(stats.get_dealer_strength_accuracy("weak"), 0.0);
    CHECK_EQ(stats.get_dealer_strength_accuracy("medium"), 0.0);
    CHECK_EQ(stats.get_dealer_strength_accuracy("strong"), 0.0);
  }

  TEST_CASE("Record correct attempt") {
    Statistics stats;
    stats.record_attempt("hard", "weak", true);

    CHECK_EQ(stats.get_session_accuracy(), 100.0);
    CHECK_EQ(stats.get_category_accuracy("hard"), 100.0);
    CHECK_EQ(stats.get_dealer_strength_accuracy("weak"), 100.0);

    // Other categories should still be 0
    CHECK_EQ(stats.get_category_accuracy("soft"), 0.0);
    CHECK_EQ(stats.get_category_accuracy("pair"), 0.0);
    CHECK_EQ(stats.get_dealer_strength_accuracy("medium"), 0.0);
    CHECK_EQ(stats.get_dealer_strength_accuracy("strong"), 0.0);
  }

  TEST_CASE("Record incorrect attempt") {
    Statistics stats;
    stats.record_attempt("soft", "strong", false);

    CHECK_EQ(stats.get_session_accuracy(), 0.0);
    CHECK_EQ(stats.get_category_accuracy("soft"), 0.0);
    CHECK_EQ(stats.get_dealer_strength_accuracy("strong"), 0.0);
  }

  TEST_CASE("Multiple attempts") {
    Statistics stats;

    // Record mixed attempts
    stats.record_attempt("hard", "weak", true);   // 1/1 = 100%
    stats.record_attempt("hard", "weak", false);  // 1/2 = 50%
    stats.record_attempt("soft", "medium", true); // Overall: 2/3 = 66.7%
    stats.record_attempt("pair", "strong", true); // Overall: 3/4 = 75%

    CHECK(doctest::Approx(stats.get_session_accuracy()).epsilon(0.1) == 75.0);
    CHECK(doctest::Approx(stats.get_category_accuracy("hard")).epsilon(0.1) ==
          50.0);
    CHECK(doctest::Approx(stats.get_category_accuracy("soft")).epsilon(0.1) ==
          100.0);
    CHECK(doctest::Approx(stats.get_category_accuracy("pair")).epsilon(0.1) ==
          100.0);

    CHECK(doctest::Approx(stats.get_dealer_strength_accuracy("weak"))
              .epsilon(0.1) == 50.0);
    CHECK(doctest::Approx(stats.get_dealer_strength_accuracy("medium"))
              .epsilon(0.1) == 100.0);
    CHECK(doctest::Approx(stats.get_dealer_strength_accuracy("strong"))
              .epsilon(0.1) == 100.0);
  }

  TEST_CASE("Reset session") {
    Statistics stats;

    // Record some attempts
    stats.record_attempt("hard", "weak", true);
    stats.record_attempt("soft", "strong", false);

    CHECK_GT(stats.get_session_accuracy(), 0.0);

    // Reset and verify all stats are back to 0
    stats.reset_session();

    CHECK_EQ(stats.get_session_accuracy(), 0.0);
    CHECK_EQ(stats.get_category_accuracy("hard"), 0.0);
    CHECK_EQ(stats.get_category_accuracy("soft"), 0.0);
    CHECK_EQ(stats.get_category_accuracy("pair"), 0.0);
    CHECK_EQ(stats.get_dealer_strength_accuracy("weak"), 0.0);
    CHECK_EQ(stats.get_dealer_strength_accuracy("medium"), 0.0);
    CHECK_EQ(stats.get_dealer_strength_accuracy("strong"), 0.0);
  }

  TEST_CASE("Dealer strength classification") {
    Statistics stats;

    // Test weak cards (4, 5, 6)
    CHECK_EQ(stats.get_dealer_strength(4), "weak");
    CHECK_EQ(stats.get_dealer_strength(5), "weak");
    CHECK_EQ(stats.get_dealer_strength(6), "weak");

    // Test medium cards (2, 3, 7, 8)
    CHECK_EQ(stats.get_dealer_strength(2), "medium");
    CHECK_EQ(stats.get_dealer_strength(3), "medium");
    CHECK_EQ(stats.get_dealer_strength(7), "medium");
    CHECK_EQ(stats.get_dealer_strength(8), "medium");

    // Test strong cards (9, 10, 11/A)
    CHECK_EQ(stats.get_dealer_strength(9), "strong");
    CHECK_EQ(stats.get_dealer_strength(10), "strong");
    CHECK_EQ(stats.get_dealer_strength(11), "strong");
  }

  TEST_CASE("Invalid categories") {
    Statistics stats;

    // Test with invalid categories - should not crash and return 0
    CHECK_EQ(stats.get_category_accuracy("invalid"), 0.0);
    CHECK_EQ(stats.get_dealer_strength_accuracy("invalid"), 0.0);

    // Recording with invalid categories should not crash
    stats.record_attempt("invalid", "weak", true);
    stats.record_attempt("hard", "invalid", true);

    // Valid categories should still work - "hard" was recorded with "invalid"
    // dealer strength
    CHECK_EQ(stats.get_category_accuracy("hard"),
             100.0); // "hard" category was recorded
  }

  TEST_CASE("Accuracy calculations") {
    Statistics stats;

    // Test precise accuracy calculations
    for (int i = 0; i < 7; ++i) {
      stats.record_attempt("hard", "weak", true);
    }
    for (int i = 0; i < 3; ++i) {
      stats.record_attempt("hard", "weak", false);
    }

    // 7 correct out of 10 = 70%
    CHECK(doctest::Approx(stats.get_session_accuracy()).epsilon(0.01) == 70.0);
    CHECK(doctest::Approx(stats.get_category_accuracy("hard")).epsilon(0.01) ==
          70.0);
    CHECK(doctest::Approx(stats.get_dealer_strength_accuracy("weak"))
              .epsilon(0.01) == 70.0);
  }
}