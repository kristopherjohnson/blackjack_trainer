# Blackjack Strategy Trainer - Rust Implementation

A terminal-based blackjack basic strategy trainer written in Rust. This is a translation of the Python version that helps users memorize optimal blackjack strategy through interactive practice sessions.

## Features

- **Four Practice Modes:**
  - Quick Practice (random scenarios)
  - Learn by Dealer Strength (weak/medium/strong dealer cards)
  - Focus on Hand Types (hard totals, soft totals, pairs)
  - Absolutes Drill (always/never rules)

- **Learning Features:**
  - Wrong answer feedback with explanations
  - Pattern reinforcement with mnemonics
  - Session statistics tracking
  - Progressive difficulty

- **Complete Strategy Implementation:**
  - Hard totals (5-21) vs dealer cards 2-A
  - Soft totals (A,2 through A,9) vs dealer cards 2-A
  - Pairs (2,2 through A,A) vs dealer cards 2-A

## Prerequisites

- Rust 1.70.0 or later
- Cargo (included with Rust)

## Building the Program

### Clone and Navigate
```bash
cd /path/to/blackjack_trainer/rust
```

### Build Release Version
```bash
cargo build --release
```

### Build Debug Version
```bash
cargo build
```

## Running the Program

### Interactive Mode (Default)
```bash
cargo run
```

### Command-line Options
```bash
# Run specific session types directly
cargo run -- --session random          # Quick practice
cargo run -- --session dealer          # Dealer strength groups
cargo run -- --session hand            # Hand type focus
cargo run -- --session absolute        # Absolutes drill

# Specify difficulty level
cargo run -- --session random --difficulty easy
cargo run -- -s absolute -d hard

# Show help
cargo run -- --help
```

### Run Release Binary
```bash
# After building with --release
./target/release/blackjack_trainer

# With arguments
./target/release/blackjack_trainer --session random --difficulty normal
```

## Available Options

### Session Types
- `random`: Mixed practice with all hand types and dealer cards
- `dealer`: Practice by dealer strength groups (weak/medium/strong)
- `hand`: Focus on specific hand types (hard/soft/pairs)
- `absolute`: Practice absolute rules (always/never scenarios)

### Difficulty Levels
- `easy`: Simplified scenarios
- `normal`: Standard practice (default)
- `hard`: Advanced scenarios

## Running Unit Tests

### Run All Tests
```bash
cargo test
```

### Run Tests with Output
```bash
cargo test -- --nocapture
```

### Run Specific Test Module
```bash
cargo test strategy_tests
cargo test stats_tests
```

### Run Single Test
```bash
cargo test test_hard_totals_low_values
```

### Test Coverage Summary
- **36 total tests** (28 strategy + 8 statistics)
- **Strategy tests:** Validate all basic strategy decisions against the official chart
- **Statistics tests:** Verify accuracy calculations and session tracking

## Code Quality Checks

### Run Clippy (Rust Linter)
```bash
cargo clippy
```

### Format Code
```bash
cargo fmt
```

### Check Without Building
```bash
cargo check
```

## Project Structure

```
rust/
├── Cargo.toml              # Project configuration and dependencies
├── CLAUDE.md               # Development workflow instructions
├── README.md               # This file
├── src/
│   ├── lib.rs              # Library root module
│   ├── main.rs             # Binary entry point with CLI
│   ├── strategy.rs         # Strategy chart implementation
│   ├── stats.rs            # Statistics tracking
│   ├── trainer.rs          # Training session types
│   └── ui.rs               # Terminal user interface
└── tests/
    ├── strategy_tests.rs   # Strategy chart validation tests
    └── stats_tests.rs      # Statistics functionality tests
```

## Dependencies

- **clap** (4.5): Command-line argument parsing
- **rand** (0.8): Random number generation
- **crossterm** (0.27): Cross-platform terminal manipulation

## Strategy Reference

The strategy implementation follows the standard basic strategy chart:
- **Assumptions:** 4-8 decks, dealer stands on soft 17, double after split allowed
- **Actions:** Hit (H), Stand (S), Double (D), Split (Y)
- **Coverage:** Complete matrix for all player hands vs dealer up-cards

## Example Usage

```bash
# Start interactive mode
cargo run

# Quick practice session
cargo run -- --session random

# Focus on pairs with hard difficulty
cargo run -- --session hand --difficulty hard

# Practice against weak dealer cards
cargo run -- --session dealer
```

## Compatibility

- **Operating Systems:** macOS, Linux, Windows
- **Terminal:** Any ANSI-compatible terminal
- **Rust Version:** 1.70.0+ (uses 2021 edition features)

## Troubleshooting

### Build Issues
```bash
# Update Rust toolchain
rustup update

# Clean and rebuild
cargo clean && cargo build
```

### Test Failures
```bash
# Run tests with detailed output
cargo test -- --nocapture

# Check for compilation errors
cargo check
```

### Runtime Issues
- Ensure terminal supports ANSI escape sequences
- Check that stdin/stdout are properly connected
- Verify Rust version with `rustc --version`

For additional help, see the parent directory's documentation or the original Python implementation.