use blackjack_trainer::trainer::generate_hand_cards;
use rand::prelude::*;

/// Test hand generation produces valid card combinations
#[cfg(test)]
mod hand_generation_tests {
    use super::*;

    #[test]
    fn test_pair_hand_generation() {
        let mut rng = thread_rng();

        for pair_value in [2, 3, 4, 5, 6, 7, 8, 9, 10, 11] {
            let cards = generate_hand_cards("pair", pair_value, &mut rng);
            assert_eq!(cards.len(), 2, "Pair {} should have 2 cards", pair_value);
            assert_eq!(cards[0], pair_value, "First card should be {}", pair_value);
            assert_eq!(cards[1], pair_value, "Second card should be {}", pair_value);
        }
    }

    #[test]
    fn test_soft_hand_generation() {
        let mut rng = thread_rng();

        for soft_total in 13..=21u8 {
            // A,2 through A,10 (13-21)
            let cards = generate_hand_cards("soft", soft_total, &mut rng);
            assert_eq!(cards.len(), 2, "Soft {} should have 2 cards", soft_total);
            assert!(cards.contains(&11), "Soft hand should contain an Ace (11)");

            let other_card = soft_total - 11;
            assert!(
                cards.contains(&other_card),
                "Soft {} should contain {}",
                soft_total,
                other_card
            );
            assert!(
                other_card >= 2 && other_card <= 10,
                "Other card {} should be 2-10",
                other_card
            );
        }
    }

    #[test]
    fn test_hard_hand_valid_cards() {
        let mut rng = thread_rng();

        for total in 5..=21u8 {
            // Hard 5-21
            let cards = generate_hand_cards("hard", total, &mut rng);

            // All cards must be valid (2-11)
            for &card in &cards {
                assert!(
                    card >= 2 && card <= 11,
                    "Invalid card value {} in hard {}: {:?}",
                    card,
                    total,
                    cards
                );
            }

            // Cards must sum to the total
            let sum: u8 = cards.iter().sum();
            assert_eq!(
                sum, total,
                "Cards {:?} don't sum to {} (sum={})",
                cards, total, sum
            );
        }
    }

    #[test]
    fn test_hard_hand_no_aces_for_low_totals() {
        let mut rng = thread_rng();

        for total in 5..=10u8 {
            // Hard 5-10 (11 can be a single Ace)
            let cards = generate_hand_cards("hard", total, &mut rng);

            // For totals 5-10, we shouldn't need aces (would make it soft)
            for &card in &cards {
                assert_ne!(
                    card, 11,
                    "Hard {} shouldn't contain Ace: {:?}",
                    total, cards
                );
            }
        }
    }

    #[test]
    fn test_hard_hand_realistic_combinations() {
        let mut rng = thread_rng();

        // Test many iterations to catch edge cases
        for _ in 0..100 {
            for total in 12..=21u8 {
                // Hard 12-21
                let cards = generate_hand_cards("hard", total, &mut rng);

                // All cards must be 2-10 (no aces in hard totals)
                for &card in &cards {
                    assert!(
                        card >= 2 && card <= 10,
                        "Hard total shouldn't contain Ace: {:?} for total {}",
                        cards,
                        total
                    );
                }

                // Should have reasonable number of cards
                assert!(
                    cards.len() <= 6,
                    "Too many cards for hard {}: {:?}",
                    total,
                    cards
                );
            }
        }
    }

    #[test]
    fn test_edge_case_totals() {
        let mut rng = thread_rng();

        // Test hard 20 and 21
        for total in [20, 21] {
            let cards = generate_hand_cards("hard", total, &mut rng);

            // Should still be valid
            let sum: u8 = cards.iter().sum();
            assert_eq!(sum, total);

            for &card in &cards {
                assert!(card >= 2 && card <= 10);
            }
        }
    }

    #[test]
    fn test_single_card_totals() {
        let mut rng = thread_rng();

        for total in 2..=11u8 {
            // 2-11
            let cards = generate_hand_cards("hard", total, &mut rng);

            if total <= 11 {
                // Should be single card for low totals
                assert_eq!(cards.len(), 1, "Total {} should be single card", total);
                assert_eq!(cards[0], total);
            }
        }
    }

    #[test]
    fn test_no_invalid_card_values() {
        let mut rng = thread_rng();
        let invalid_values = [0, 1, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21];

        for _ in 0..200 {
            // Many iterations to catch rare cases
            for hand_type in ["hard", "soft", "pair"] {
                let totals: Vec<u8> = match hand_type {
                    "pair" => vec![2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
                    "soft" => (13..=21).collect(),
                    "hard" => (5..=21).collect(),
                    _ => continue,
                };

                for total in totals {
                    let cards = generate_hand_cards(hand_type, total, &mut rng);

                    for &card in &cards {
                        assert!(
                            !invalid_values.contains(&card),
                            "Invalid card {} in {} {}: {:?}",
                            card,
                            hand_type,
                            total,
                            cards
                        );
                    }
                }
            }
        }
    }

    #[test]
    fn test_hard_18_specific_case() {
        let mut rng = thread_rng();

        // Test hard 18 many times to ensure no invalid cards
        for _ in 0..50 {
            let cards = generate_hand_cards("hard", 18, &mut rng);

            // Should sum to 18
            let sum: u8 = cards.iter().sum();
            assert_eq!(sum, 18);

            // All cards should be valid (2-10)
            for &card in &cards {
                assert!(
                    card >= 2 && card <= 10,
                    "Invalid card {} in hard 18: {:?}",
                    card,
                    cards
                );
            }

            // Should not contain the problematic card 16
            assert!(
                !cards.contains(&16),
                "Found invalid card 16 in: {:?}",
                cards
            );
        }
    }
}
