use std::io::{self, Write};

/// Display the main menu and get user choice.
pub fn display_menu() -> Option<u8> {
    println!("\nBlackjack Basic Strategy Trainer");
    println!("1. Quick Practice (random)");
    println!("2. Learn by Dealer Strength");
    println!("3. Focus on Hand Types");
    println!("4. Absolutes Drill");
    println!("5. View Statistics");
    println!("6. Quit");
    print!("\nChoice (1-6): ");
    io::stdout().flush().unwrap();

    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap();

    input.trim().parse().ok().filter(|&n| (1..=6).contains(&n))
}

/// Display session header with mode name.
pub fn display_session_header(mode_name: &str) {
    println!("\n{}", "=".repeat(40));
    println!("Training Mode: {mode_name}");
    println!("{}", "=".repeat(40));
    println!("(Press 'q' + Enter to quit at any time)");
}

/// Display the current hand and dealer card.
pub fn display_hand(player_cards: &[u8], dealer_card: u8, hand_type: &str, player_total: u8) {
    println!("\nDealer shows: {}", card_to_string(dealer_card));

    print!("Your hand: ");
    for (i, &card) in player_cards.iter().enumerate() {
        if i > 0 {
            print!(", ");
        }
        print!("{}", card_to_string(card));
    }

    let hand_desc = hand_type.chars().next().unwrap().to_uppercase().to_string() + &hand_type[1..];
    println!(" ({hand_desc} {player_total})");
}

/// Get user's action choice.
pub fn get_user_action() -> Option<char> {
    println!("\nWhat's your move?");
    print!("(H)it, (S)tand, (D)ouble, s(P)lit: ");
    io::stdout().flush().unwrap();

    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap();

    if input.trim().is_empty() {
        return None;
    }

    let action = input.trim().chars().next()?.to_uppercase().next()?;

    // Check for quit
    if action == 'Q' {
        None
    } else {
        Some(action)
    }
}

/// Display feedback after user's answer.
/// Returns true if user wants to quit.
pub fn display_feedback(
    correct: bool,
    user_action: char,
    correct_action: char,
    explanation: &str,
) -> bool {
    if correct {
        println!("\n✓ Correct!");
    } else {
        println!("\n❌ Incorrect!");
        println!("\nCorrect answer: {}", action_to_string(correct_action));
        println!("Your answer: {}", action_to_string(user_action));
        println!("\nPattern: {explanation}");
    }

    print!("\nPress Enter to continue (or 'q' + Enter to quit): ");
    io::stdout().flush().unwrap();

    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap();

    !input.trim().is_empty() && input.trim().to_uppercase().starts_with('Q')
}

/// Display dealer groups menu and get user choice.
pub fn display_dealer_groups() -> Option<u8> {
    println!("\nChoose dealer strength group to practice:");
    println!("1. Weak cards (4, 5, 6) - 'Bust cards'");
    println!("2. Medium cards (2, 3, 7, 8)");
    println!("3. Strong cards (9, 10, A)");
    println!("0. Cancel");
    print!("\nChoice (0-3): ");
    io::stdout().flush().unwrap();

    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap();

    match input.trim().parse::<u8>() {
        Ok(0) => None,
        Ok(n) if (1..=3).contains(&n) => Some(n),
        _ => None,
    }
}

/// Display hand types menu and get user choice.
pub fn display_hand_types() -> Option<u8> {
    println!("\nChoose hand type to practice:");
    println!("1. Hard totals (no ace or ace = 1)");
    println!("2. Soft totals (ace = 11)");
    println!("3. Pairs");
    println!("0. Cancel");
    print!("\nChoice (0-3): ");
    io::stdout().flush().unwrap();

    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap();

    match input.trim().parse::<u8>() {
        Ok(0) => None,
        Ok(n) if (1..=3).contains(&n) => Some(n),
        _ => None,
    }
}

/// Convert card value to display string.
fn card_to_string(card: u8) -> String {
    match card {
        11 => "A".to_string(),
        10 => "10".to_string(),
        n => n.to_string(),
    }
}

/// Convert action character to full word.
fn action_to_string(action: char) -> &'static str {
    match action {
        'H' => "HIT",
        'S' => "STAND",
        'D' => "DOUBLE",
        'Y' | 'P' => "SPLIT",
        _ => "UNKNOWN",
    }
}
