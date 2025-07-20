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

To start the interactive blackjack strategy trainer:

```bash
python3 main.py
```

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
├── main.py              # Main program entry point
├── strategy.py          # Strategy chart data and lookup
├── trainer.py           # Practice session logic
├── ui.py               # Terminal interface utilities
├── stats.py            # Statistics tracking
├── tests/              # Unit tests
│   ├── __init__.py
│   └── test_strategy.py
├── README.md           # This file
├── CLAUDE.md           # Project instructions
└── blackjack_trainer_plan.md  # Implementation plan
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

To run in development mode or make modifications:

1. Clone or download the project
2. All core functionality is in the main Python files
3. Tests are in the `tests/` directory
4. Run tests before making changes to ensure strategy accuracy

## License

This project is for educational purposes to help learn blackjack basic strategy.