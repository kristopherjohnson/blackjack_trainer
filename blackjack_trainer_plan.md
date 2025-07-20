# Blackjack Strategy Trainer - Plan and Specification

## Project Overview
Build a terminal-based Python program for macOS to help memorize blackjack basic strategy using progressive learning methods and reinforcement techniques.

## Core Requirements

### 1. Strategy Data
- Implement the complete basic strategy chart from blackjack_basic_strategy.md
- Hard totals, soft totals, and pairs tables
- Standard rules: 4-8 decks, dealer stands soft 17, double after split allowed

### 2. Practice Modes
1. **Full Random Practice** - Random hands vs random dealer cards
2. **Dealer Card Groups** - Practice by dealer weakness:
   - Weak cards (4,5,6) - "bust cards"
   - Medium cards (2,3,7,8)
   - Strong cards (9,10,A)
3. **Hand Type Focus** - Practice specific categories:
   - Hard totals only
   - Soft totals only
   - Pairs only
4. **Absolutes Drill** - Practice never/always rules first

### 3. Learning Features
- **Progressive difficulty**: Start with absolutes, advance to complex scenarios
- **Wrong answer feedback**: Show correct answer + explanation
- **Pattern reinforcement**: Display relevant mnemonics and patterns
- **Statistics tracking**: Accuracy per category, session progress

### 4. User Interface
- Terminal-based, keyboard input
- Clear display of current hand and dealer up-card
- Menu system for selecting practice modes
- Progress indicators and statistics display

## Technical Specifications

### File Structure
```
blackjack_trainer/
├── main.py              # Main program entry point
├── strategy.py          # Strategy chart data and lookup
├── trainer.py           # Practice session logic
├── ui.py               # Terminal interface utilities
├── stats.py            # Statistics tracking
└── README.md           # Usage instructions
```

### Core Classes

#### StrategyChart
```python
class StrategyChart:
    def __init__(self):
        self.hard_totals = {}    # Hard total strategy matrix
        self.soft_totals = {}    # Soft total strategy matrix
        self.pairs = {}          # Pairs strategy matrix
        self.mnemonics = {}      # Learning aids by scenario

    def get_correct_action(self, hand_type, player_total, dealer_card):
        # Returns correct action (H/S/D/Y/N)

    def get_explanation(self, hand_type, player_total, dealer_card):
        # Returns mnemonic/pattern for this scenario
```

#### TrainingSession
```python
class TrainingSession:
    def __init__(self, mode, difficulty):
        self.mode = mode         # Practice mode selection
        self.difficulty = difficulty
        self.correct_count = 0
        self.total_count = 0
        self.session_stats = {}

    def generate_scenario(self):
        # Generate hand based on current mode

    def check_answer(self, user_action, correct_action):
        # Validate and provide feedback

    def show_feedback(self, scenario, correct_action):
        # Display explanation and mnemonics
```

#### Statistics
```python
class Statistics:
    def __init__(self):
        self.session_data = {}
        self.overall_accuracy = {}

    def record_attempt(self, category, correct):
        # Track performance by category

    def display_progress(self):
        # Show current session and overall stats
```

### Practice Mode Details

#### 1. Absolutes Mode
- Focus on never/always rules
- Always split: A,A and 8,8
- Never split: 10,10 and 5,5
- Never take insurance
- Always stand: hard 17+, soft 19+
- Reinforcement: "Aces and eights, don't hesitate"

#### 2. Dealer Group Mode
Select dealer strength category:
- **Weak (4,5,6)**: More doubles/splits, "dealer bust cards = player gets greedy"
- **Medium (2,3,7,8)**: Moderate strategy
- **Strong (9,10,A)**: Conservative approach, fewer risks

#### 3. Hand Type Focus
- **Hard Totals**: Practice the standing/hitting patterns
- **Soft Totals**: Focus on A,7 complexity and doubling patterns
- **Pairs**: Split decision logic

#### 4. Progressive Learning Path
1. Start with absolutes (95% accuracy required)
2. Move to hard totals basic patterns
3. Add soft totals
4. Complete with pairs
5. Mixed practice

### User Experience Flow

#### Main Menu
```
Blackjack Basic Strategy Trainer
1. Quick Practice (random)
2. Learn by Dealer Strength
3. Focus on Hand Types
4. Absolutes Drill
5. View Statistics
6. Quit
```

#### Practice Session
```
Dealer shows: 7
Your hand: 10, 6 (Hard 16)

What's your move?
(H)it, (S)tand, (D)ouble, s(P)lit: _
```

#### Feedback Display
```
❌ Incorrect!

Correct answer: HIT
Your answer: STAND

Pattern: "Teens stay vs weak, flee from strong"
Explanation: Hard 16 vs 7+ always hits. Dealer 7 is strong.

Press Enter to continue...
```

### Implementation Plan

#### Phase 1: Core Structure
- [ ] Set up project structure
- [ ] Implement StrategyChart class with complete data
- [ ] Create basic UI utilities
- [ ] Build simple random practice mode

#### Phase 2: Practice Modes
- [ ] Implement dealer strength grouping
- [ ] Add hand type focus modes
- [ ] Create absolutes drill mode
- [ ] Add progressive difficulty system

#### Phase 3: Learning Features
- [ ] Implement feedback system with explanations
- [ ] Add mnemonics and pattern reinforcement
- [ ] Create statistics tracking
- [ ] Build progress indicators

#### Phase 4: Polish
- [ ] Enhance terminal UI
- [ ] Add session persistence
- [ ] Create comprehensive help system
- [ ] Performance optimization

### Data Structures

#### Strategy Chart Encoding
```python
# Actions: H=Hit, S=Stand, D=Double, Y=Split, N=No Split
HARD_TOTALS = {
    (5, 2): 'H', (5, 3): 'H', ...,  # (player_total, dealer_card): action
    (16, 7): 'H', (16, 10): 'H', ...
}

DEALER_GROUPS = {
    'weak': [4, 5, 6],
    'medium': [2, 3, 7, 8],
    'strong': [9, 10, 11]  # 11 represents Ace
}
```

#### Mnemonics Database
```python
MNEMONICS = {
    'dealer_weak': "Dealer bust cards (4,5,6) = player gets greedy",
    'always_split': "Aces and eights, don't hesitate",
    'teens_vs_strong': "Teens stay vs weak, flee from strong",
    'soft_17': "A,7 is the tricky soft hand"
}
```

## Success Criteria
- Runs smoothly on macOS Terminal
- Complete strategy chart implementation
- All practice modes functional
- Clear feedback and learning reinforcement
- Session statistics and progress tracking
- Intuitive terminal interface

## Dependencies
- Python 3.8+ (standard library only)
- No external packages required
- Compatible with macOS Terminal

## Usage Instructions for Claude Code
1. Create the project structure as specified
2. Implement classes in order: StrategyChart → TrainingSession → Statistics
3. Build practice modes incrementally
4. Test each component before moving to next phase
5. Focus on clear terminal output and user experience

## Notes for Continuation
- User is experienced developer familiar with Python
- Prefers concise, functional code
- Will test on macOS Terminal environment
- Strategy chart data from blackjack_basic_strategy.md must be preserved exactly

## Strategy Reference
The complete basic strategy implementation is based on the official chart in blackjack_basic_strategy.md, which defines the optimal play for:
- Hard totals (5-21) vs dealer cards 2-A
- Soft totals (A,2 through A,9) vs dealer cards 2-A  
- Pairs (2,2 through A,A) vs dealer cards 2-A

All strategy decisions in the trainer must match this reference chart exactly.