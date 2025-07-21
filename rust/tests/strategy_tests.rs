use blackjack_trainer::StrategyChart;

#[cfg(test)]
mod strategy_tests {
    use super::*;

    fn setup_chart() -> StrategyChart {
        StrategyChart::new()
    }

    #[test]
    fn test_hard_totals_low_values() {
        let chart = setup_chart();

        for total in 5..=8 {
            for dealer in 2..=11 {
                let action = chart.get_correct_action("hard", total, dealer);
                assert_eq!(action, 'H', "Hard {} vs {} should be Hit", total, dealer);
            }
        }
    }

    #[test]
    fn test_hard_9_strategy() {
        let chart = setup_chart();

        for dealer in 2..=11 {
            let action = chart.get_correct_action("hard", 9, dealer);
            if (3..=6).contains(&dealer) {
                assert_eq!(action, 'D', "Hard 9 vs {} should be Double", dealer);
            } else {
                assert_eq!(action, 'H', "Hard 9 vs {} should be Hit", dealer);
            }
        }
    }

    #[test]
    fn test_hard_10_strategy() {
        let chart = setup_chart();

        for dealer in 2..=11 {
            let action = chart.get_correct_action("hard", 10, dealer);
            if (2..=9).contains(&dealer) {
                assert_eq!(action, 'D', "Hard 10 vs {} should be Double", dealer);
            } else {
                assert_eq!(action, 'H', "Hard 10 vs {} should be Hit", dealer);
            }
        }
    }

    #[test]
    fn test_hard_11_strategy() {
        let chart = setup_chart();

        for dealer in 2..=11 {
            let action = chart.get_correct_action("hard", 11, dealer);
            if dealer <= 10 {
                assert_eq!(action, 'D', "Hard 11 vs {} should be Double", dealer);
            } else {
                // Ace
                assert_eq!(action, 'H', "Hard 11 vs Ace should be Hit");
            }
        }
    }

    #[test]
    fn test_hard_12_strategy() {
        let chart = setup_chart();

        for dealer in 2..=11 {
            let action = chart.get_correct_action("hard", 12, dealer);
            if (4..=6).contains(&dealer) {
                assert_eq!(action, 'S', "Hard 12 vs {} should be Stand", dealer);
            } else {
                assert_eq!(action, 'H', "Hard 12 vs {} should be Hit", dealer);
            }
        }
    }

    #[test]
    fn test_hard_13_16_strategy() {
        let chart = setup_chart();

        for total in 13..=16 {
            for dealer in 2..=11 {
                let action = chart.get_correct_action("hard", total, dealer);
                if (2..=6).contains(&dealer) {
                    assert_eq!(action, 'S', "Hard {} vs {} should be Stand", total, dealer);
                } else {
                    assert_eq!(action, 'H', "Hard {} vs {} should be Hit", total, dealer);
                }
            }
        }
    }

    #[test]
    fn test_hard_17_plus_strategy() {
        let chart = setup_chart();

        for total in 17..=21 {
            for dealer in 2..=11 {
                let action = chart.get_correct_action("hard", total, dealer);
                assert_eq!(action, 'S', "Hard {} vs {} should be Stand", total, dealer);
            }
        }
    }

    #[test]
    fn test_soft_13_14_strategy() {
        let chart = setup_chart();

        for total in [13, 14] {
            for dealer in 2..=11 {
                let action = chart.get_correct_action("soft", total, dealer);
                if (5..=6).contains(&dealer) {
                    assert_eq!(action, 'D', "Soft {} vs {} should be Double", total, dealer);
                } else {
                    assert_eq!(action, 'H', "Soft {} vs {} should be Hit", total, dealer);
                }
            }
        }
    }

    #[test]
    fn test_soft_15_16_strategy() {
        let chart = setup_chart();

        for total in [15, 16] {
            for dealer in 2..=11 {
                let action = chart.get_correct_action("soft", total, dealer);
                if (4..=6).contains(&dealer) {
                    assert_eq!(action, 'D', "Soft {} vs {} should be Double", total, dealer);
                } else {
                    assert_eq!(action, 'H', "Soft {} vs {} should be Hit", total, dealer);
                }
            }
        }
    }

    #[test]
    fn test_soft_17_strategy() {
        let chart = setup_chart();

        for dealer in 2..=11 {
            let action = chart.get_correct_action("soft", 17, dealer);
            if (3..=6).contains(&dealer) {
                assert_eq!(action, 'D', "Soft 17 vs {} should be Double", dealer);
            } else {
                assert_eq!(action, 'H', "Soft 17 vs {} should be Hit", dealer);
            }
        }
    }

    #[test]
    fn test_soft_18_strategy() {
        let chart = setup_chart();

        for dealer in 2..=11 {
            let action = chart.get_correct_action("soft", 18, dealer);
            match dealer {
                2 | 7 | 8 => assert_eq!(action, 'S', "Soft 18 vs {} should be Stand", dealer),
                3..=6 => assert_eq!(action, 'D', "Soft 18 vs {} should be Double", dealer),
                _ => assert_eq!(action, 'H', "Soft 18 vs {} should be Hit", dealer), // 9, 10, A
            }
        }
    }

    #[test]
    fn test_soft_19_plus_strategy() {
        let chart = setup_chart();

        for total in [19, 20, 21] {
            for dealer in 2..=11 {
                let action = chart.get_correct_action("soft", total, dealer);
                assert_eq!(action, 'S', "Soft {} vs {} should be Stand", total, dealer);
            }
        }
    }

    #[test]
    fn test_pairs_aces_strategy() {
        let chart = setup_chart();

        for dealer in 2..=11 {
            let action = chart.get_correct_action("pair", 11, dealer);
            assert_eq!(action, 'Y', "Pair of Aces vs {} should be Split", dealer);
        }
    }

    #[test]
    fn test_pairs_2_3_strategy() {
        let chart = setup_chart();

        for pair_val in [2, 3] {
            for dealer in 2..=11 {
                let action = chart.get_correct_action("pair", pair_val, dealer);
                if (2..=7).contains(&dealer) {
                    assert_eq!(
                        action, 'Y',
                        "Pair of {}s vs {} should be Split",
                        pair_val, dealer
                    );
                } else {
                    assert_eq!(
                        action, 'H',
                        "Pair of {}s vs {} should be Hit",
                        pair_val, dealer
                    );
                }
            }
        }
    }

    #[test]
    fn test_pairs_4_strategy() {
        let chart = setup_chart();

        for dealer in 2..=11 {
            let action = chart.get_correct_action("pair", 4, dealer);
            if (5..=6).contains(&dealer) {
                assert_eq!(action, 'Y', "Pair of 4s vs {} should be Split", dealer);
            } else {
                assert_eq!(action, 'H', "Pair of 4s vs {} should be Hit", dealer);
            }
        }
    }

    #[test]
    fn test_pairs_5_strategy() {
        let chart = setup_chart();

        for dealer in 2..=11 {
            let action = chart.get_correct_action("pair", 5, dealer);
            if (2..=9).contains(&dealer) {
                assert_eq!(action, 'D', "Pair of 5s vs {} should be Double", dealer);
            } else {
                assert_eq!(action, 'H', "Pair of 5s vs {} should be Hit", dealer);
            }
        }
    }

    #[test]
    fn test_pairs_6_strategy() {
        let chart = setup_chart();

        for dealer in 2..=11 {
            let action = chart.get_correct_action("pair", 6, dealer);
            if (2..=6).contains(&dealer) {
                assert_eq!(action, 'Y', "Pair of 6s vs {} should be Split", dealer);
            } else {
                assert_eq!(action, 'H', "Pair of 6s vs {} should be Hit", dealer);
            }
        }
    }

    #[test]
    fn test_pairs_7_strategy() {
        let chart = setup_chart();

        for dealer in 2..=11 {
            let action = chart.get_correct_action("pair", 7, dealer);
            if (2..=7).contains(&dealer) {
                assert_eq!(action, 'Y', "Pair of 7s vs {} should be Split", dealer);
            } else {
                assert_eq!(action, 'H', "Pair of 7s vs {} should be Hit", dealer);
            }
        }
    }

    #[test]
    fn test_pairs_8_strategy() {
        let chart = setup_chart();

        for dealer in 2..=11 {
            let action = chart.get_correct_action("pair", 8, dealer);
            assert_eq!(action, 'Y', "Pair of 8s vs {} should be Split", dealer);
        }
    }

    #[test]
    fn test_pairs_9_strategy() {
        let chart = setup_chart();

        for dealer in 2..=11 {
            let action = chart.get_correct_action("pair", 9, dealer);
            if matches!(dealer, 7 | 10 | 11) {
                assert_eq!(action, 'S', "Pair of 9s vs {} should be Stand", dealer);
            } else {
                assert_eq!(action, 'Y', "Pair of 9s vs {} should be Split", dealer);
            }
        }
    }

    #[test]
    fn test_pairs_10_strategy() {
        let chart = setup_chart();

        for dealer in 2..=11 {
            let action = chart.get_correct_action("pair", 10, dealer);
            assert_eq!(action, 'S', "Pair of 10s vs {} should be Stand", dealer);
        }
    }

    #[test]
    fn test_absolute_rules() {
        let chart = setup_chart();

        // Test absolute rules identification
        assert!(
            chart.is_absolute_rule("pair", 11, 5),
            "A,A should be absolute"
        );
        assert!(
            chart.is_absolute_rule("pair", 8, 10),
            "8,8 should be absolute"
        );
        assert!(
            chart.is_absolute_rule("pair", 10, 6),
            "10,10 should be absolute"
        );
        assert!(
            chart.is_absolute_rule("pair", 5, 4),
            "5,5 should be absolute"
        );
        assert!(
            chart.is_absolute_rule("hard", 17, 10),
            "Hard 17+ should be absolute"
        );
        assert!(
            chart.is_absolute_rule("soft", 19, 6),
            "Soft 19+ should be absolute"
        );

        // Test non-absolute rules
        assert!(
            !chart.is_absolute_rule("hard", 16, 7),
            "Hard 16 vs 7 should not be absolute"
        );
        assert!(
            !chart.is_absolute_rule("soft", 18, 6),
            "Soft 18 vs 6 should not be absolute"
        );
        assert!(
            !chart.is_absolute_rule("pair", 6, 4),
            "Pair 6s vs 4 should not be absolute"
        );
    }

    #[test]
    fn test_explanations() {
        let chart = setup_chart();

        // Test that explanations are returned
        let explanation = chart.get_explanation("pair", 11, 5);
        assert!(!explanation.is_empty(), "Explanation should not be empty");
        assert!(explanation.len() > 0, "Explanation should have content");

        let explanation = chart.get_explanation("hard", 16, 10);
        assert!(!explanation.is_empty(), "Explanation should not be empty");
        assert!(explanation.len() > 0, "Explanation should have content");
    }

    #[test]
    fn test_dealer_groups() {
        let chart = setup_chart();

        let dealer_groups = chart.get_dealer_groups();

        assert_eq!(dealer_groups.get("weak"), Some(&vec![4, 5, 6]));
        assert_eq!(dealer_groups.get("medium"), Some(&vec![2, 3, 7, 8]));
        assert_eq!(dealer_groups.get("strong"), Some(&vec![9, 10, 11]));
    }

    #[test]
    fn test_edge_cases() {
        let chart = setup_chart();

        // Hard 12 vs 2 should be Hit (exception to 13-16 rule)
        assert_eq!(chart.get_correct_action("hard", 12, 2), 'H');

        // Hard 12 vs 3 should be Hit (exception to 13-16 rule)
        assert_eq!(chart.get_correct_action("hard", 12, 3), 'H');

        // Soft 18 vs 9 should be Hit (not stand)
        assert_eq!(chart.get_correct_action("soft", 18, 9), 'H');

        // Pair 9s vs 7 should be Stand (not split)
        assert_eq!(chart.get_correct_action("pair", 9, 7), 'S');
    }

    #[test]
    fn test_all_hard_totals_coverage() {
        let chart = setup_chart();

        // Test that all hard total combinations have valid actions
        for total in 5..=21 {
            for dealer in 2..=11 {
                let action = chart.get_correct_action("hard", total, dealer);
                assert!(
                    matches!(action, 'H' | 'S' | 'D'),
                    "Invalid action '{}' for Hard {} vs {}",
                    action,
                    total,
                    dealer
                );
            }
        }
    }

    #[test]
    fn test_all_soft_totals_coverage() {
        let chart = setup_chart();

        // Test that all soft total combinations have valid actions
        for total in 13..=21 {
            for dealer in 2..=11 {
                let action = chart.get_correct_action("soft", total, dealer);
                assert!(
                    matches!(action, 'H' | 'S' | 'D'),
                    "Invalid action '{}' for Soft {} vs {}",
                    action,
                    total,
                    dealer
                );
            }
        }
    }

    #[test]
    fn test_all_pairs_coverage() {
        let chart = setup_chart();

        // Test that all pair combinations have valid actions
        for pair_val in 2..=11 {
            for dealer in 2..=11 {
                let action = chart.get_correct_action("pair", pair_val, dealer);
                assert!(
                    matches!(action, 'H' | 'S' | 'D' | 'Y'),
                    "Invalid action '{}' for Pair {}s vs {}",
                    action,
                    pair_val,
                    dealer
                );
            }
        }
    }
}
