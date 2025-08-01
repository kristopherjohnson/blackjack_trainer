# Blackjack Strategy Trainer

A terminal-based Python program for macOS to help memorize blackjack basic strategy using progressive learning methods and reinforcement techniques.

## Features

- Complete basic strategy chart implementation (hard totals, soft totals, pairs)
- Multiple practice modes:
  - Quick Practice (random scenarios)
  - Learn by Dealer Strength (weak/medium/strong dealers)
  - Focus on Hand Types (hard/soft/pairs only)
  - Absolutes Drill (never/always rules)
- Real-time feedback with explanations and mnemonics
- Session statistics tracking
- Progressive difficulty system

## Requirements

- Python 3.8 or higher
- macOS Terminal (or any compatible terminal)
- No external dependencies required

## Running the Program

The blackjack strategy trainer is packaged as a Python module and can be executed in multiple ways:

### Interactive Mode (Default)

Start the interactive trainer with the main menu:

```bash
python3 bjst
```

### Command-line Mode

Run specific session types directly via command-line arguments:

```bash
# Quick practice (random scenarios)
python3 bjst --session random

# Learn by dealer strength groups
python3 bjst --session dealer

# Focus on specific hand types
python3 bjst --session hand

# Practice absolute rules
python3 bjst --session absolute

# Specify difficulty level
python3 bjst --session random --difficulty easy
python3 bjst -s absolute -d hard

# Show help and all options
python3 bjst --help
```

#### Available Options

- `--session, -s`: Choose session type
  - `random`: Mixed practice with all scenarios
  - `dealer`: Practice by dealer strength (weak/medium/strong)
  - `hand`: Focus on hand types (hard/soft/pairs)
  - `absolute`: Practice absolute rules (always/never)

- `--difficulty, -d`: Set difficulty level
  - `easy`: Simpler scenarios
  - `normal`: Standard difficulty (default)
  - `hard`: More challenging scenarios

### Menu Options

1. **Quick Practice** - Random hands vs random dealer cards
2. **Learn by Dealer Strength** - Practice against specific dealer card groups:
   - Weak dealers (4, 5, 6) - "bust cards"
   - Medium dealers (2, 3, 7, 8)
   - Strong dealers (9, 10, A)
3. **Focus on Hand Types** - Practice specific categories:
   - Hard totals only
   - Soft totals only
   - Pairs only
4. **Absolutes Drill** - Practice never/always rules first
5. **View Statistics** - See your session performance
6. **Quit** - Exit the program

### How to Play

1. Choose a practice mode from the main menu
2. You'll be shown a dealer up-card and your hand
3. Choose your action: (H)it, (S)tand, (D)ouble, s(P)lit
4. Get immediate feedback with the correct answer and explanation
5. Continue practicing to improve your accuracy

### Example Session

```
Dealer shows: 7
Your hand: 10, 6 (Hard 16)

What's your move?
(H)it, (S)tand, (D)ouble, s(P)lit: H

✓ Correct!

Press Enter to continue...
```

## Running Unit Tests

The project includes comprehensive unit tests to verify the strategy chart implementation.

### Run All Tests

```bash
python3 -m unittest tests.test_strategy -v
```

### Run Tests with Coverage Information

```bash
python3 -m unittest discover tests -v
```

### Test Structure

- `tests/test_strategy.py` - Complete strategy chart validation
  - Tests all hard totals (5-21)
  - Tests all soft totals (13-21)
  - Tests all pairs (2-A)
  - Validates edge cases and absolute rules
  - Ensures 100% coverage of strategy combinations

All tests should pass, confirming that the strategy chart matches standard blackjack basic strategy.

## Project Structure

```
blackjack_trainer/
├── bjst/                      # Main package directory
│   ├── __init__.py            # Package initialization and exports
│   ├── __main__.py            # Entry point for `python3 bjst`
│   ├── main.py                # Main application logic
│   ├── strategy.py            # Strategy chart data and lookup
│   ├── trainer.py             # Training session classes (inheritance-based)
│   ├── ui.py                  # Terminal interface utilities
│   └── stats.py               # Statistics tracking
├── tests/                     # Unit tests
│   └── test_strategy.py       # Strategy chart validation tests
├── .pylintrc                  # Code quality configuration
├── .gitignore                 # Git ignore patterns
├── LICENSE                    # MIT license
├── README.md                  # This file
├── CLAUDE.md                  # Development workflow
├── blackjack_basic_strategy.md    # Official strategy reference
└── blackjack_trainer_plan.md     # Implementation plan
```

## Strategy Rules

The trainer implements standard blackjack basic strategy with these rules:
- 4-8 decks
- Dealer stands on soft 17
- Double after split allowed
- Surrender not available

### Key Mnemonics

- "Aces and eights, don't hesitate" (always split)
- "Tens and fives, keep them alive" (never split)
- "Dealer bust cards (4,5,6) = player gets greedy"
- "Teens stay vs weak, flee from strong"

## Tips for Learning

1. Start with the **Absolutes Drill** to learn never/always rules
2. Progress to **Dealer Strength** practice to understand patterns
3. Use **Hand Type Focus** to master specific scenarios
4. Practice regularly with **Quick Practice** for mixed scenarios
5. Pay attention to the explanations and mnemonics provided

## Development

This project includes implementations in multiple programming languages for learning and comparison purposes:

- **Python** (`bjst/`) - Main implementation with complete feature set
- **Rust** (`rust/`) - High-performance implementation
- **C++** (`cpp/`) - Native implementation with CMake build system
- **Go** (`go/`) - Concurrent implementation

### Running Pre-commit Checks

A comprehensive script is provided to run formatters, linters, and tests across all implementations:

```bash
./precommit.sh
```

This script will:
- Format code using language-specific formatters (autopep8, cargo fmt, clang-format, go fmt)
- Run linters and static analysis (pylint, cargo clippy, go vet)
- Execute all test suites across all implementations
- Provide a summary of results with colored output

Individual implementation checks can also be run:

```bash
# Python only
pylint bjst/ && python3 -m unittest discover tests/

# Rust only
cd rust && cargo fmt && cargo clippy && cargo test

# C++ only
cd cpp && cmake --build build && cmake --build build --target test

# Go only
cd go && go fmt ./... && go vet ./... && go test ./...
```

### Development Setup

To run in development mode or make modifications:

1. Clone or download the project
2. All core functionality is in the main Python files
3. Tests are in the `tests/` directory
4. Run `./precommit.sh` before making changes to ensure code quality
5. Each implementation has comprehensive test coverage including hand generation validation

## License

This project is for educational purposes to help learn blackjack basic strategy.