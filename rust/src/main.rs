mod stats;
mod strategy;
mod trainer;
mod ui;

use clap::{Arg, Command};
use stats::Statistics;
use trainer::{
    AbsoluteTrainingSession, DealerGroupTrainingSession, HandTypeTrainingSession,
    RandomTrainingSession, TrainingSession,
};
use ui::display_menu;

/// Create a training session based on type.
fn create_session(session_type: &str, _difficulty: &str) -> Option<Box<dyn TrainingSession>> {
    match session_type {
        "random" => Some(Box::new(RandomTrainingSession::new())),
        "dealer" => Some(Box::new(DealerGroupTrainingSession::new())),
        "hand" => Some(Box::new(HandTypeTrainingSession::new())),
        "absolute" => Some(Box::new(AbsoluteTrainingSession::new())),
        _ => None,
    }
}

/// Main entry point for the Blackjack Basic Strategy Trainer.
///
/// This function serves as the primary entry point for the training application,
/// supporting both command-line and interactive modes of operation.
///
/// Command-line mode:
///     When session type is specified via --session argument, runs that specific
///     training session directly and exits. Supports session types: random,
///     dealer, hand, absolute with optional difficulty levels.
///
/// Interactive mode:
///     When no session type is specified, displays the main menu allowing users
///     to choose from multiple training options:
///     1. Quick Practice (random scenarios)
///     2. Learn by Dealer Strength (weak/medium/strong dealer groups)
///     3. Focus on Hand Types (hard/soft/pairs)
///     4. Absolutes Drill (never/always rules)
///     5. View Statistics (session performance)
///     6. Quit
///
/// The function initializes statistics tracking that persists across all
/// training sessions within the same execution, allowing users to see
/// cumulative progress.
///
/// Usage:
///     ./blackjack_trainer                    # Interactive mode
///     ./blackjack_trainer -s random          # Direct random practice
///     ./blackjack_trainer -s absolute -d easy # Absolutes drill, easy difficulty
fn main() {
    let matches = Command::new("Blackjack Basic Strategy Trainer")
        .version("1.0.0")
        .about("Learn optimal blackjack strategy through interactive training")
        .arg(
            Arg::new("session")
                .short('s')
                .long("session")
                .value_name("TYPE")
                .help("Training session type")
                .value_parser(["random", "dealer", "hand", "absolute"]),
        )
        .arg(
            Arg::new("difficulty")
                .short('d')
                .long("difficulty")
                .value_name("LEVEL")
                .help("Difficulty level")
                .default_value("normal")
                .value_parser(["easy", "normal", "hard"]),
        )
        .get_matches();

    println!("Blackjack Basic Strategy Trainer");
    println!("{}", "=".repeat(40));

    let mut stats = Statistics::new();

    // If session type specified via command line, run it directly
    if let Some(session_type) = matches.get_one::<String>("session") {
        let difficulty = matches.get_one::<String>("difficulty").unwrap();

        if let Some(mut session) = create_session(session_type, difficulty) {
            session.run(&mut stats);
        } else {
            println!("Invalid session type: {session_type}");
            std::process::exit(1);
        }
        return;
    }

    // Otherwise show the interactive menu
    loop {
        let choice = match display_menu() {
            Some(choice) => choice,
            None => {
                println!("Invalid choice. Please try again.");
                continue;
            }
        };

        match choice {
            1 => {
                let mut session = RandomTrainingSession::new();
                session.run(&mut stats);
            }
            2 => {
                let mut session = DealerGroupTrainingSession::new();
                session.run(&mut stats);
            }
            3 => {
                let mut session = HandTypeTrainingSession::new();
                session.run(&mut stats);
            }
            4 => {
                let mut session = AbsoluteTrainingSession::new();
                session.run(&mut stats);
            }
            5 => {
                stats.display_progress();
            }
            6 => {
                println!("Thanks for practicing! Keep those strategies sharp!");
                break;
            }
            _ => {
                println!("Invalid choice. Please try again.");
            }
        }
    }
}
