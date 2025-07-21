use std::collections::HashMap;

/// Complete blackjack basic strategy chart implementation.
///
/// This struct encapsulates the optimal basic strategy for blackjack based on
/// standard casino rules: 4-8 decks, dealer stands on soft 17, double after
/// split allowed, surrender not allowed.
///
/// The strategy chart covers three main categories:
/// - Hard totals (5-21): Hands without aces or where ace counts as 1
/// - Soft totals (13-21): Hands with ace counting as 11 (A,2 through A,9)
/// - Pairs (2,2 through A,A): Identical card pairs for split decisions
///
/// Action codes:
/// - H: Hit (take another card)
/// - S: Stand (keep current total)
/// - D: Double down (double bet, take exactly one more card)
/// - Y: Split (for pairs - split into two separate hands)
///
/// The struct also provides:
/// - Explanatory mnemonics for learning key patterns
/// - Dealer strength groupings (weak/medium/strong)
/// - Absolute rule identification for never/always scenarios
///
/// All strategy decisions are based on mathematically optimal play that
/// minimizes the house edge over the long term.
pub struct StrategyChart {
    hard_totals: HashMap<(u8, u8), char>,
    soft_totals: HashMap<(u8, u8), char>,
    pairs: HashMap<(u8, u8), char>,
    mnemonics: HashMap<String, String>,
    dealer_groups: HashMap<String, Vec<u8>>,
}

impl StrategyChart {
    /// Create a new strategy chart with all data initialized.
    pub fn new() -> Self {
        let mut chart = StrategyChart {
            hard_totals: HashMap::new(),
            soft_totals: HashMap::new(),
            pairs: HashMap::new(),
            mnemonics: HashMap::new(),
            dealer_groups: HashMap::new(),
        };

        chart.build_hard_totals();
        chart.build_soft_totals();
        chart.build_pairs();
        chart.build_mnemonics();
        chart.build_dealer_groups();

        chart
    }

    /// Get the correct action for a given scenario.
    pub fn get_correct_action(&self, hand_type: &str, player_total: u8, dealer_card: u8) -> char {
        let key = (player_total, dealer_card);

        match hand_type {
            "pair" => self.pairs.get(&key).copied().unwrap_or('H'),
            "soft" => self.soft_totals.get(&key).copied().unwrap_or('H'),
            "hard" => self.hard_totals.get(&key).copied().unwrap_or('H'),
            _ => 'H',
        }
    }

    /// Get an explanation/mnemonic for a given scenario.
    pub fn get_explanation(&self, hand_type: &str, player_total: u8, dealer_card: u8) -> String {
        // Specific explanations for key scenarios
        match (hand_type, player_total) {
            ("pair", 11) => self
                .mnemonics
                .get("always_split")
                .cloned()
                .unwrap_or_default(),
            ("pair", 8) => self
                .mnemonics
                .get("always_split")
                .cloned()
                .unwrap_or_default(),
            ("pair", 10) => self
                .mnemonics
                .get("never_split")
                .cloned()
                .unwrap_or_default(),
            ("pair", 5) => self
                .mnemonics
                .get("never_split")
                .cloned()
                .unwrap_or_default(),
            ("soft", 18) => self.mnemonics.get("soft_17").cloned().unwrap_or_default(),
            ("hard", 12) => self.mnemonics.get("hard_12").cloned().unwrap_or_default(),
            _ => {
                // Dealer strength based explanations
                if let Some(weak_cards) = self.dealer_groups.get("weak") {
                    if weak_cards.contains(&dealer_card) {
                        return self
                            .mnemonics
                            .get("dealer_weak")
                            .cloned()
                            .unwrap_or_default();
                    }
                }

                if let Some(strong_cards) = self.dealer_groups.get("strong") {
                    if (13..=16).contains(&player_total) && strong_cards.contains(&dealer_card) {
                        return self
                            .mnemonics
                            .get("teens_vs_strong")
                            .cloned()
                            .unwrap_or_default();
                    }
                }

                "Follow basic strategy patterns".to_string()
            }
        }
    }

    /// Check if a scenario represents an absolute rule (always/never).
    #[allow(dead_code)]
    pub fn is_absolute_rule(&self, hand_type: &str, player_total: u8, _dealer_card: u8) -> bool {
        match hand_type {
            "pair" => matches!(player_total, 11 | 8 | 10 | 5),
            "hard" => player_total >= 17,
            "soft" => player_total >= 19,
            _ => false,
        }
    }

    /// Get dealer strength groups.
    #[allow(dead_code)]
    pub fn get_dealer_groups(&self) -> &HashMap<String, Vec<u8>> {
        &self.dealer_groups
    }

    fn build_hard_totals(&mut self) {
        // Hard 5-8: Always hit
        for total in 5..=8 {
            for dealer in 2..=11 {
                self.hard_totals.insert((total, dealer), 'H');
            }
        }

        // Hard 9: Double vs 3-6, otherwise hit
        for dealer in 2..=11 {
            let action = if (3..=6).contains(&dealer) { 'D' } else { 'H' };
            self.hard_totals.insert((9, dealer), action);
        }

        // Hard 10: Double vs 2-9, otherwise hit
        for dealer in 2..=11 {
            let action = if (2..=9).contains(&dealer) { 'D' } else { 'H' };
            self.hard_totals.insert((10, dealer), action);
        }

        // Hard 11: Double vs 2-10, hit vs Ace
        for dealer in 2..=11 {
            let action = if dealer <= 10 { 'D' } else { 'H' };
            self.hard_totals.insert((11, dealer), action);
        }

        // Hard 12: Stand vs 4-6, otherwise hit
        for dealer in 2..=11 {
            let action = if (4..=6).contains(&dealer) { 'S' } else { 'H' };
            self.hard_totals.insert((12, dealer), action);
        }

        // Hard 13-16: Stand vs 2-6, otherwise hit
        for total in 13..=16 {
            for dealer in 2..=11 {
                let action = if (2..=6).contains(&dealer) { 'S' } else { 'H' };
                self.hard_totals.insert((total, dealer), action);
            }
        }

        // Hard 17+: Always stand
        for total in 17..=21 {
            for dealer in 2..=11 {
                self.hard_totals.insert((total, dealer), 'S');
            }
        }
    }

    fn build_soft_totals(&mut self) {
        // Soft 13-14 (A,2-A,3): Double vs 5-6, otherwise hit
        for total in [13, 14] {
            for dealer in 2..=11 {
                let action = if (5..=6).contains(&dealer) { 'D' } else { 'H' };
                self.soft_totals.insert((total, dealer), action);
            }
        }

        // Soft 15-16 (A,4-A,5): Double vs 4-6, otherwise hit
        for total in [15, 16] {
            for dealer in 2..=11 {
                let action = if (4..=6).contains(&dealer) { 'D' } else { 'H' };
                self.soft_totals.insert((total, dealer), action);
            }
        }

        // Soft 17 (A,6): Double vs 3-6, otherwise hit
        for dealer in 2..=11 {
            let action = if (3..=6).contains(&dealer) { 'D' } else { 'H' };
            self.soft_totals.insert((17, dealer), action);
        }

        // Soft 18 (A,7): Stand vs 2,7,8; Double vs 3-6; Hit vs 9,10,A
        for dealer in 2..=11 {
            let action = match dealer {
                2 | 7 | 8 => 'S',
                3..=6 => 'D',
                _ => 'H', // 9, 10, A
            };
            self.soft_totals.insert((18, dealer), action);
        }

        // Soft 19-21: Always stand
        for total in [19, 20, 21] {
            for dealer in 2..=11 {
                self.soft_totals.insert((total, dealer), 'S');
            }
        }
    }

    fn build_pairs(&mut self) {
        // A,A: Always split
        for dealer in 2..=11 {
            self.pairs.insert((11, dealer), 'Y');
        }

        // 2,2 and 3,3: Split vs 2-7, otherwise hit
        for pair_val in [2, 3] {
            for dealer in 2..=11 {
                let action = if (2..=7).contains(&dealer) { 'Y' } else { 'H' };
                self.pairs.insert((pair_val, dealer), action);
            }
        }

        // 4,4: Split vs 5-6, otherwise hit
        for dealer in 2..=11 {
            let action = if (5..=6).contains(&dealer) { 'Y' } else { 'H' };
            self.pairs.insert((4, dealer), action);
        }

        // 5,5: Never split, treat as hard 10
        for dealer in 2..=11 {
            let action = if (2..=9).contains(&dealer) { 'D' } else { 'H' };
            self.pairs.insert((5, dealer), action);
        }

        // 6,6: Split vs 2-6, otherwise hit
        for dealer in 2..=11 {
            let action = if (2..=6).contains(&dealer) { 'Y' } else { 'H' };
            self.pairs.insert((6, dealer), action);
        }

        // 7,7: Split vs 2-7, otherwise hit
        for dealer in 2..=11 {
            let action = if (2..=7).contains(&dealer) { 'Y' } else { 'H' };
            self.pairs.insert((7, dealer), action);
        }

        // 8,8: Always split
        for dealer in 2..=11 {
            self.pairs.insert((8, dealer), 'Y');
        }

        // 9,9: Split vs 2-9 except 7, stand vs 7,10,A
        for dealer in 2..=11 {
            let action = if matches!(dealer, 7 | 10 | 11) {
                'S'
            } else {
                'Y'
            };
            self.pairs.insert((9, dealer), action);
        }

        // 10,10: Never split, always stand
        for dealer in 2..=11 {
            self.pairs.insert((10, dealer), 'S');
        }
    }

    fn build_mnemonics(&mut self) {
        self.mnemonics.insert(
            "dealer_weak".to_string(),
            "Dealer bust cards (4,5,6) = player gets greedy".to_string(),
        );
        self.mnemonics.insert(
            "always_split".to_string(),
            "Aces and eights, don't hesitate".to_string(),
        );
        self.mnemonics.insert(
            "never_split".to_string(),
            "Tens and fives, keep them alive".to_string(),
        );
        self.mnemonics.insert(
            "teens_vs_strong".to_string(),
            "Teens stay vs weak, flee from strong".to_string(),
        );
        self.mnemonics.insert(
            "soft_17".to_string(),
            "A,7 is the tricky soft hand".to_string(),
        );
        self.mnemonics.insert(
            "hard_12".to_string(),
            "12 is the exception - only stand vs 4,5,6".to_string(),
        );
        self.mnemonics.insert(
            "doubles".to_string(),
            "Double when dealer is weak and you can improve".to_string(),
        );
    }

    fn build_dealer_groups(&mut self) {
        self.dealer_groups.insert("weak".to_string(), vec![4, 5, 6]);
        self.dealer_groups
            .insert("medium".to_string(), vec![2, 3, 7, 8]);
        self.dealer_groups
            .insert("strong".to_string(), vec![9, 10, 11]);
    }
}

impl Default for StrategyChart {
    fn default() -> Self {
        Self::new()
    }
}
