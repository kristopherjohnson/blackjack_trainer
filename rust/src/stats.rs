use std::collections::HashMap;
use std::io::{self, Write};

/// Statistics tracking for blackjack strategy training sessions.
///
/// This struct tracks performance metrics during training sessions, including:
/// - Overall accuracy (correct answers / total attempts)
/// - Accuracy by hand type (hard totals, soft totals, pairs)
/// - Accuracy by dealer strength (weak, medium, strong dealer cards)
///
/// Dealer strength categories:
/// - Weak: 4, 5, 6 (dealer bust cards)
/// - Medium: 2, 3, 7, 8 (moderate dealer cards)
/// - Strong: 9, 10, A (strong dealer cards)
///
/// The statistics are maintained for the current session and can be displayed
/// to show the user's progress and identify areas for improvement.
#[derive(Debug, Clone)]
pub struct Statistics {
    total_attempts: u32,
    correct_answers: u32,
    by_category: HashMap<String, CategoryData>,
    by_dealer_strength: HashMap<String, CategoryData>,
}

#[derive(Debug, Clone, Default)]
struct CategoryData {
    correct: u32,
    total: u32,
}

impl Statistics {
    /// Create a new statistics tracker.
    pub fn new() -> Self {
        let mut stats = Statistics {
            total_attempts: 0,
            correct_answers: 0,
            by_category: HashMap::new(),
            by_dealer_strength: HashMap::new(),
        };

        // Initialize category tracking
        stats
            .by_category
            .insert("hard".to_string(), CategoryData::default());
        stats
            .by_category
            .insert("soft".to_string(), CategoryData::default());
        stats
            .by_category
            .insert("pair".to_string(), CategoryData::default());

        // Initialize dealer strength tracking
        stats
            .by_dealer_strength
            .insert("weak".to_string(), CategoryData::default());
        stats
            .by_dealer_strength
            .insert("medium".to_string(), CategoryData::default());
        stats
            .by_dealer_strength
            .insert("strong".to_string(), CategoryData::default());

        stats
    }

    /// Record an attempt in the training session.
    pub fn record_attempt(&mut self, hand_type: &str, dealer_strength: &str, correct: bool) {
        self.total_attempts += 1;
        if correct {
            self.correct_answers += 1;
        }

        // Record by hand type
        if let Some(category) = self.by_category.get_mut(hand_type) {
            category.total += 1;
            if correct {
                category.correct += 1;
            }
        }

        // Record by dealer strength
        if let Some(strength) = self.by_dealer_strength.get_mut(dealer_strength) {
            strength.total += 1;
            if correct {
                strength.correct += 1;
            }
        }
    }

    /// Get accuracy percentage for a specific category.
    #[allow(dead_code)]
    pub fn get_category_accuracy(&self, category: &str) -> f64 {
        if let Some(data) = self.by_category.get(category) {
            if data.total == 0 {
                0.0
            } else {
                (data.correct as f64 / data.total as f64) * 100.0
            }
        } else {
            0.0
        }
    }

    /// Get accuracy percentage for a dealer strength category.
    #[allow(dead_code)]
    pub fn get_dealer_strength_accuracy(&self, strength: &str) -> f64 {
        if let Some(data) = self.by_dealer_strength.get(strength) {
            if data.total == 0 {
                0.0
            } else {
                (data.correct as f64 / data.total as f64) * 100.0
            }
        } else {
            0.0
        }
    }

    /// Get overall session accuracy percentage.
    pub fn get_session_accuracy(&self) -> f64 {
        if self.total_attempts == 0 {
            0.0
        } else {
            (self.correct_answers as f64 / self.total_attempts as f64) * 100.0
        }
    }

    /// Display progress statistics to the console.
    pub fn display_progress(&self) {
        println!("\n{}", "=".repeat(50));
        println!("SESSION STATISTICS");
        println!("{}", "=".repeat(50));

        if self.total_attempts == 0 {
            println!("No practice attempts yet this session.");
            print!("\nPress Enter to continue...");
            io::stdout().flush().unwrap();
            let mut input = String::new();
            io::stdin().read_line(&mut input).unwrap();
            return;
        }

        println!(
            "Overall: {}/{} ({:.1}%)",
            self.correct_answers,
            self.total_attempts,
            self.get_session_accuracy()
        );

        println!("\nBy Hand Type:");
        for hand_type in ["hard", "soft", "pair"] {
            if let Some(data) = self.by_category.get(hand_type) {
                if data.total > 0 {
                    let accuracy = (data.correct as f64 / data.total as f64) * 100.0;
                    let capitalized = hand_type.chars().next().unwrap().to_uppercase().to_string()
                        + &hand_type[1..];
                    println!(
                        "  {}: {}/{} ({:.1}%)",
                        capitalized, data.correct, data.total, accuracy
                    );
                }
            }
        }

        println!("\nBy Dealer Strength:");
        for strength in ["weak", "medium", "strong"] {
            if let Some(data) = self.by_dealer_strength.get(strength) {
                if data.total > 0 {
                    let accuracy = (data.correct as f64 / data.total as f64) * 100.0;
                    let capitalized = strength.chars().next().unwrap().to_uppercase().to_string()
                        + &strength[1..];
                    println!(
                        "  {}: {}/{} ({:.1}%)",
                        capitalized, data.correct, data.total, accuracy
                    );
                }
            }
        }

        print!("\nPress Enter to continue...");
        io::stdout().flush().unwrap();
        let mut input = String::new();
        io::stdin().read_line(&mut input).unwrap();
    }

    /// Reset session statistics.
    #[allow(dead_code)]
    pub fn reset_session(&mut self) {
        self.total_attempts = 0;
        self.correct_answers = 0;

        for category in self.by_category.values_mut() {
            *category = CategoryData::default();
        }

        for strength in self.by_dealer_strength.values_mut() {
            *strength = CategoryData::default();
        }
    }

    /// Determine dealer strength from dealer card.
    pub fn get_dealer_strength(&self, dealer_card: u8) -> &'static str {
        match dealer_card {
            4..=6 => "weak",
            2 | 3 | 7 | 8 => "medium",
            _ => "strong", // 9, 10, 11 (Ace)
        }
    }
}

impl Default for Statistics {
    fn default() -> Self {
        Self::new()
    }
}
