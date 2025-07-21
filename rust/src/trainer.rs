use crate::stats::Statistics;
use crate::strategy::StrategyChart;
use crate::ui::{
    display_dealer_groups, display_feedback, display_hand, display_hand_types,
    display_session_header, get_user_action,
};
use rand::prelude::*;

/// Trait for all training session types.
pub trait TrainingSession {
    /// Return the mode name for display purposes.
    fn get_mode_name(&self) -> &'static str;

    /// Return the maximum number of questions for this session type.
    fn get_max_questions(&self) -> u32;

    /// Generate a scenario for this training mode.
    /// Returns (hand_type, player_cards, player_total, dealer_card)
    fn generate_scenario(&mut self) -> (String, Vec<u8>, u8, u8);

    /// Setup the session. Override in implementations if additional setup is needed.
    /// Returns true if setup successful, false if user cancelled.
    fn setup_session(&mut self) -> bool {
        true // Default implementation - no additional setup needed
    }

    /// Run the training session.
    fn run(&mut self, stats: &mut Statistics) {
        display_session_header(self.get_mode_name());

        if !self.setup_session() {
            return; // User cancelled setup
        }

        let strategy = StrategyChart::new();
        let mut correct_count = 0;
        let mut total_count = 0;
        let mut question_count = 0;

        while question_count < self.get_max_questions() {
            let (hand_type, player_cards, player_total, dealer_card) = self.generate_scenario();

            display_hand(&player_cards, dealer_card, &hand_type, player_total);

            let user_action = match get_user_action() {
                Some(action) => action,
                None => break, // User quit
            };

            let correct_action = strategy.get_correct_action(&hand_type, player_total, dealer_card);
            let correct = check_answer(user_action, correct_action);
            let explanation = strategy.get_explanation(&hand_type, player_total, dealer_card);

            let quit_requested =
                display_feedback(correct, user_action, correct_action, &explanation);

            // Record statistics
            let dealer_strength = stats.get_dealer_strength(dealer_card);
            stats.record_attempt(&hand_type, dealer_strength, correct);

            question_count += 1;

            if correct {
                correct_count += 1;
            }
            total_count += 1;

            if quit_requested {
                break;
            }
        }

        // Show session summary
        if total_count > 0 {
            let accuracy = (correct_count as f64 / total_count as f64) * 100.0;
            println!(
                "\nSession complete! Final score: {correct_count}/{total_count} ({accuracy:.1}%)"
            );
        }
    }
}

/// Helper method to generate card representation for a hand.
pub fn generate_hand_cards(hand_type: &str, player_total: u8, rng: &mut ThreadRng) -> Vec<u8> {
    match hand_type {
        "pair" => vec![player_total, player_total],
        "soft" => {
            let other_card = player_total - 11;
            vec![11, other_card]
        }
        "hard" => {
            if player_total <= 11 {
                vec![player_total]
            } else {
                // Generate two valid cards (2-10) that sum to player_total
                let first_card = rng.gen_range(2..=std::cmp::min(10, player_total - 2));
                let second_card = player_total - first_card;

                // If second card would be > 10, we need more cards
                if second_card > 10 {
                    // For totals > 20, generate 3+ cards
                    let mut cards = vec![first_card];
                    let mut remaining = player_total - first_card;

                    while remaining > 10 {
                        // Take a card between 2 and min(10, remaining-2) to ensure we can finish
                        let max_card = std::cmp::min(10, remaining - 2);
                        if max_card < 2 {
                            break;
                        }
                        let card = rng.gen_range(2..=max_card);
                        cards.push(card);
                        remaining -= card;
                    }

                    if remaining >= 2 {
                        cards.push(remaining);
                    }
                    cards
                } else if second_card < 2 {
                    // If second card would be < 2, just use single card
                    vec![player_total]
                } else {
                    vec![first_card, second_card]
                }
            }
        }
        _ => vec![player_total],
    }
}

/// Check if user's action matches the correct action.
fn check_answer(user_action: char, correct_action: char) -> bool {
    let normalized_user = if user_action == 'P' { 'Y' } else { user_action };
    normalized_user == correct_action
}

/// Random practice session with all hand types and dealer cards.
pub struct RandomTrainingSession {
    rng: ThreadRng,
}

impl Default for RandomTrainingSession {
    fn default() -> Self {
        Self::new()
    }
}

impl RandomTrainingSession {
    pub fn new() -> Self {
        Self { rng: thread_rng() }
    }
}

impl TrainingSession for RandomTrainingSession {
    fn get_mode_name(&self) -> &'static str {
        "random"
    }

    fn get_max_questions(&self) -> u32 {
        50
    }

    fn generate_scenario(&mut self) -> (String, Vec<u8>, u8, u8) {
        let dealer_card = self.rng.gen_range(2..=11);
        let hand_types = ["hard", "soft", "pair"];
        let hand_type = hand_types[self.rng.gen_range(0..hand_types.len())].to_string();

        let (player_cards, player_total) = match hand_type.as_str() {
            "pair" => {
                let pair_values = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
                let pair_value = pair_values[self.rng.gen_range(0..pair_values.len())];
                (vec![pair_value, pair_value], pair_value)
            }
            "soft" => {
                let other_card = self.rng.gen_range(2..=9);
                (vec![11, other_card], 11 + other_card)
            }
            "hard" => {
                let player_total = self.rng.gen_range(5..=20);
                let player_cards = generate_hand_cards("hard", player_total, &mut self.rng);
                (player_cards, player_total)
            }
            _ => unreachable!(),
        };

        (hand_type, player_cards, player_total, dealer_card)
    }
}

/// Training session focused on specific dealer strength groups.
pub struct DealerGroupTrainingSession {
    rng: ThreadRng,
    dealer_group: Option<u8>,
}

impl Default for DealerGroupTrainingSession {
    fn default() -> Self {
        Self::new()
    }
}

impl DealerGroupTrainingSession {
    pub fn new() -> Self {
        Self {
            rng: thread_rng(),
            dealer_group: None,
        }
    }
}

impl TrainingSession for DealerGroupTrainingSession {
    fn get_mode_name(&self) -> &'static str {
        "dealer_groups"
    }

    fn get_max_questions(&self) -> u32 {
        50
    }

    fn setup_session(&mut self) -> bool {
        self.dealer_group = display_dealer_groups();
        self.dealer_group.is_some()
    }

    fn generate_scenario(&mut self) -> (String, Vec<u8>, u8, u8) {
        // Select dealer card based on chosen group
        let dealer_card = match self.dealer_group.unwrap_or(1) {
            1 => {
                // Weak
                let weak_cards = [4, 5, 6];
                weak_cards[self.rng.gen_range(0..weak_cards.len())]
            }
            2 => {
                // Medium
                let medium_cards = [2, 3, 7, 8];
                medium_cards[self.rng.gen_range(0..medium_cards.len())]
            }
            _ => {
                // Strong
                let strong_cards = [9, 10, 11];
                strong_cards[self.rng.gen_range(0..strong_cards.len())]
            }
        };

        let hand_types = ["hard", "soft", "pair"];
        let hand_type = hand_types[self.rng.gen_range(0..hand_types.len())].to_string();

        let (player_cards, player_total) = match hand_type.as_str() {
            "pair" => {
                let pair_values = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
                let pair_value = pair_values[self.rng.gen_range(0..pair_values.len())];
                (vec![pair_value, pair_value], pair_value)
            }
            "soft" => {
                let other_card = self.rng.gen_range(2..=9);
                (vec![11, other_card], 11 + other_card)
            }
            "hard" => {
                let player_total = self.rng.gen_range(5..=20);
                let player_cards = generate_hand_cards("hard", player_total, &mut self.rng);
                (player_cards, player_total)
            }
            _ => unreachable!(),
        };

        (hand_type, player_cards, player_total, dealer_card)
    }
}

/// Training session focused on specific hand types.
pub struct HandTypeTrainingSession {
    rng: ThreadRng,
    hand_type_choice: Option<u8>,
}

impl Default for HandTypeTrainingSession {
    fn default() -> Self {
        Self::new()
    }
}

impl HandTypeTrainingSession {
    pub fn new() -> Self {
        Self {
            rng: thread_rng(),
            hand_type_choice: None,
        }
    }
}

impl TrainingSession for HandTypeTrainingSession {
    fn get_mode_name(&self) -> &'static str {
        "hand_types"
    }

    fn get_max_questions(&self) -> u32 {
        50
    }

    fn setup_session(&mut self) -> bool {
        self.hand_type_choice = display_hand_types();
        self.hand_type_choice.is_some()
    }

    fn generate_scenario(&mut self) -> (String, Vec<u8>, u8, u8) {
        let dealer_card = self.rng.gen_range(2..=11);

        let (hand_type, player_cards, player_total) = match self.hand_type_choice.unwrap_or(1) {
            1 => {
                // Hard totals
                let player_total = self.rng.gen_range(5..=20);
                let player_cards = generate_hand_cards("hard", player_total, &mut self.rng);
                ("hard".to_string(), player_cards, player_total)
            }
            2 => {
                // Soft totals
                let other_card = self.rng.gen_range(2..=9);
                let player_cards = vec![11, other_card];
                let player_total = 11 + other_card;
                ("soft".to_string(), player_cards, player_total)
            }
            _ => {
                // Pairs
                let pair_values = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
                let pair_value = pair_values[self.rng.gen_range(0..pair_values.len())];
                let player_cards = vec![pair_value, pair_value];
                ("pair".to_string(), player_cards, pair_value)
            }
        };

        (hand_type, player_cards, player_total, dealer_card)
    }
}

/// Training session focused on absolute rules (always/never scenarios).
pub struct AbsoluteTrainingSession {
    rng: ThreadRng,
}

impl Default for AbsoluteTrainingSession {
    fn default() -> Self {
        Self::new()
    }
}

impl AbsoluteTrainingSession {
    pub fn new() -> Self {
        Self { rng: thread_rng() }
    }
}

impl TrainingSession for AbsoluteTrainingSession {
    fn get_mode_name(&self) -> &'static str {
        "absolutes"
    }

    fn get_max_questions(&self) -> u32 {
        20
    }

    fn generate_scenario(&mut self) -> (String, Vec<u8>, u8, u8) {
        let absolutes = [
            ("pair", vec![11, 11], 11), // A,A
            ("pair", vec![8, 8], 8),    // 8,8
            ("pair", vec![10, 10], 10), // 10,10
            ("pair", vec![5, 5], 5),    // 5,5
            ("hard", vec![], 17),       // Hard 17
            ("hard", vec![], 18),       // Hard 18
            ("hard", vec![], 19),       // Hard 19
            ("hard", vec![], 20),       // Hard 20
            ("soft", vec![11, 8], 19),  // Soft 19
            ("soft", vec![11, 9], 20),  // Soft 20
        ];

        let (hand_type, mut player_cards, player_total) =
            absolutes[self.rng.gen_range(0..absolutes.len())].clone();
        let dealer_card = self.rng.gen_range(2..=11);

        if player_cards.is_empty() {
            // Hard totals
            player_cards = generate_hand_cards(hand_type, player_total, &mut self.rng);
        }

        (
            hand_type.to_string(),
            player_cards,
            player_total,
            dealer_card,
        )
    }
}
