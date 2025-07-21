use blackjack_trainer::Statistics;

#[cfg(test)]
mod stats_tests {
    use super::*;

    fn setup_stats() -> Statistics {
        Statistics::new()
    }

    #[test]
    fn test_initial_state() {
        let stats = setup_stats();

        // Test initial state
        assert_eq!(stats.get_session_accuracy(), 0.0);
        assert_eq!(stats.get_category_accuracy("hard"), 0.0);
        assert_eq!(stats.get_category_accuracy("soft"), 0.0);
        assert_eq!(stats.get_category_accuracy("pair"), 0.0);
        assert_eq!(stats.get_dealer_strength_accuracy("weak"), 0.0);
        assert_eq!(stats.get_dealer_strength_accuracy("medium"), 0.0);
        assert_eq!(stats.get_dealer_strength_accuracy("strong"), 0.0);
    }

    #[test]
    fn test_record_correct_attempt() {
        let mut stats = setup_stats();
        stats.record_attempt("hard", "weak", true);

        assert_eq!(stats.get_session_accuracy(), 100.0);
        assert_eq!(stats.get_category_accuracy("hard"), 100.0);
        assert_eq!(stats.get_dealer_strength_accuracy("weak"), 100.0);

        // Other categories should still be 0
        assert_eq!(stats.get_category_accuracy("soft"), 0.0);
        assert_eq!(stats.get_category_accuracy("pair"), 0.0);
        assert_eq!(stats.get_dealer_strength_accuracy("medium"), 0.0);
        assert_eq!(stats.get_dealer_strength_accuracy("strong"), 0.0);
    }

    #[test]
    fn test_record_incorrect_attempt() {
        let mut stats = setup_stats();
        stats.record_attempt("soft", "strong", false);

        assert_eq!(stats.get_session_accuracy(), 0.0);
        assert_eq!(stats.get_category_accuracy("soft"), 0.0);
        assert_eq!(stats.get_dealer_strength_accuracy("strong"), 0.0);
    }

    #[test]
    fn test_multiple_attempts() {
        let mut stats = setup_stats();

        // Record mixed attempts
        stats.record_attempt("hard", "weak", true); // 1/1 = 100%
        stats.record_attempt("hard", "weak", false); // 1/2 = 50%
        stats.record_attempt("soft", "medium", true); // Overall: 2/3 = 66.7%
        stats.record_attempt("pair", "strong", true); // Overall: 3/4 = 75%

        assert!((stats.get_session_accuracy() - 75.0).abs() < 0.1);
        assert!((stats.get_category_accuracy("hard") - 50.0).abs() < 0.1);
        assert!((stats.get_category_accuracy("soft") - 100.0).abs() < 0.1);
        assert!((stats.get_category_accuracy("pair") - 100.0).abs() < 0.1);

        assert!((stats.get_dealer_strength_accuracy("weak") - 50.0).abs() < 0.1);
        assert!((stats.get_dealer_strength_accuracy("medium") - 100.0).abs() < 0.1);
        assert!((stats.get_dealer_strength_accuracy("strong") - 100.0).abs() < 0.1);
    }

    #[test]
    fn test_reset_session() {
        let mut stats = setup_stats();

        // Record some attempts
        stats.record_attempt("hard", "weak", true);
        stats.record_attempt("soft", "strong", false);

        assert!(stats.get_session_accuracy() > 0.0);

        // Reset and verify all stats are back to 0
        stats.reset_session();

        assert_eq!(stats.get_session_accuracy(), 0.0);
        assert_eq!(stats.get_category_accuracy("hard"), 0.0);
        assert_eq!(stats.get_category_accuracy("soft"), 0.0);
        assert_eq!(stats.get_category_accuracy("pair"), 0.0);
        assert_eq!(stats.get_dealer_strength_accuracy("weak"), 0.0);
        assert_eq!(stats.get_dealer_strength_accuracy("medium"), 0.0);
        assert_eq!(stats.get_dealer_strength_accuracy("strong"), 0.0);
    }

    #[test]
    fn test_dealer_strength_classification() {
        let stats = setup_stats();

        // Test weak cards (4, 5, 6)
        assert_eq!(stats.get_dealer_strength(4), "weak");
        assert_eq!(stats.get_dealer_strength(5), "weak");
        assert_eq!(stats.get_dealer_strength(6), "weak");

        // Test medium cards (2, 3, 7, 8)
        assert_eq!(stats.get_dealer_strength(2), "medium");
        assert_eq!(stats.get_dealer_strength(3), "medium");
        assert_eq!(stats.get_dealer_strength(7), "medium");
        assert_eq!(stats.get_dealer_strength(8), "medium");

        // Test strong cards (9, 10, 11/A)
        assert_eq!(stats.get_dealer_strength(9), "strong");
        assert_eq!(stats.get_dealer_strength(10), "strong");
        assert_eq!(stats.get_dealer_strength(11), "strong");
    }

    #[test]
    fn test_invalid_categories() {
        let mut stats = setup_stats();

        // Test with invalid categories - should not crash and return 0
        assert_eq!(stats.get_category_accuracy("invalid"), 0.0);
        assert_eq!(stats.get_dealer_strength_accuracy("invalid"), 0.0);

        // Recording with invalid categories should not crash
        stats.record_attempt("invalid", "weak", true);
        stats.record_attempt("hard", "invalid", true);

        // Hard category should have been recorded even with invalid dealer strength
        assert_eq!(stats.get_category_accuracy("hard"), 100.0);
    }

    #[test]
    fn test_accuracy_calculations() {
        let mut stats = setup_stats();

        // Test precise accuracy calculations
        for _ in 0..7 {
            stats.record_attempt("hard", "weak", true);
        }
        for _ in 0..3 {
            stats.record_attempt("hard", "weak", false);
        }

        // 7 correct out of 10 = 70%
        assert!((stats.get_session_accuracy() - 70.0).abs() < 0.01);
        assert!((stats.get_category_accuracy("hard") - 70.0).abs() < 0.01);
        assert!((stats.get_dealer_strength_accuracy("weak") - 70.0).abs() < 0.01);
    }
}
