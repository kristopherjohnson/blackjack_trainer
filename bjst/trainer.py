import random
from abc import ABC, abstractmethod
from .strategy import StrategyChart
from .ui import (display_session_header, display_hand, get_user_action,
                 display_feedback, display_dealer_groups, display_hand_types)


class TrainingSession(ABC):
    """Base class for all training session types."""

    def __init__(self, difficulty='normal'):
        self.difficulty = difficulty
        self.strategy = StrategyChart()
        self.correct_count = 0
        self.total_count = 0
        self.session_stats = {}

    @property
    @abstractmethod
    def mode_name(self):
        """Return the mode name for display purposes."""

    @property
    @abstractmethod
    def max_questions(self):
        """Return the maximum number of questions for this session type."""

    @abstractmethod
    def generate_scenario(self):
        """Generate a scenario for this training mode."""

    def _generate_hand_cards(self, hand_type, player_total):
        """Helper method to generate card representation for a hand."""
        if hand_type == 'pair':
            return [player_total, player_total]
        if hand_type == 'soft':
            other_card = player_total - 11
            return [11, other_card]
        # hard
        if player_total <= 11:
            return [player_total]
        # Generate two valid cards (2-10) that sum to player_total
        first_card = random.randint(2, min(10, player_total - 2))
        second_card = player_total - first_card

        # If second card would be > 10, we need more cards
        if second_card > 10:
            # For totals > 20, generate 3+ cards
            cards = [first_card]
            remaining = player_total - first_card

            while remaining > 10:
                # Take a card between 2 and min(10, remaining-2) to ensure we can finish
                max_card = min(10, remaining - 2)
                if max_card < 2:
                    break
                card = random.randint(2, max_card)
                cards.append(card)
                remaining -= card

            if remaining >= 2:
                cards.append(remaining)
            return cards
        if second_card < 2:
            # If second card would be < 2, just use single card
            return [player_total]
        return [first_card, second_card]

    def check_answer(self, user_action, correct_action):
        """Check if user's action matches the correct action."""
        # Handle split variations
        if user_action == 'P':
            user_action = 'Y'
        return user_action == correct_action

    def show_feedback(self, scenario, user_action, correct_action):
        """Display feedback for the user's answer."""
        hand_type, _, player_total, dealer_card = scenario
        correct = self.check_answer(user_action, correct_action)
        explanation = self.strategy.get_explanation(
            hand_type, player_total, dealer_card)
        response = display_feedback(
            correct, user_action, correct_action, explanation)
        return correct, response

    def setup_session(self):
        """Setup the session. Override in subclasses if additional setup is needed."""
        return None  # Return submode if applicable

    def run(self, stats):
        """Run the training session."""
        display_session_header(self.mode_name)

        if hasattr(self, '_requires_submode'):
            submode = self.setup_session()  # pylint: disable=assignment-from-none
            if submode is None:
                return  # User cancelled selection

        question_count = 0
        while question_count < self.max_questions:
            scenario = self.generate_scenario()
            hand_type, player_cards, player_total, dealer_card = scenario

            display_hand(player_cards, dealer_card, hand_type, player_total)

            user_action = get_user_action()
            if user_action is None:  # User quit
                break

            correct_action = self.strategy.get_correct_action(
                hand_type, player_total, dealer_card)
            correct, response = self.show_feedback(
                scenario, user_action, correct_action)

            # Record statistics
            dealer_strength = stats.get_dealer_strength(dealer_card)
            stats.record_attempt(hand_type, dealer_strength, correct)

            question_count += 1

            if correct:
                self.correct_count += 1
            self.total_count += 1

            # Check if user wants to quit
            if response == 'quit':
                break

        # Show session summary
        if self.total_count > 0:
            accuracy = (self.correct_count / self.total_count) * 100
            print(f"\nSession complete! Final score: {self.correct_count}/"
                  f"{self.total_count} ({accuracy:.1f}%)")


class RandomTrainingSession(TrainingSession):
    """Random practice session with all hand types and dealer cards."""

    @property
    def mode_name(self):
        return 'random'

    @property
    def max_questions(self):
        return 50

    def generate_scenario(self):
        dealer_card = random.randint(2, 11)
        hand_type = random.choice(['hard', 'soft', 'pair'])

        if hand_type == 'pair':
            pair_value = random.choice([2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
            player_cards = [pair_value, pair_value]
            player_total = pair_value
        elif hand_type == 'soft':
            other_card = random.randint(2, 9)
            player_cards = [11, other_card]
            player_total = 11 + other_card
        else:  # hard
            player_total = random.randint(5, 20)
            player_cards = self._generate_hand_cards(hand_type, player_total)

        return hand_type, player_cards, player_total, dealer_card


class DealerGroupTrainingSession(TrainingSession):
    """Training session focused on specific dealer strength groups."""

    def __init__(self, difficulty='normal'):
        super().__init__(difficulty)
        self.dealer_group = None
        self._requires_submode = True

    @property
    def mode_name(self):
        return 'dealer_groups'

    @property
    def max_questions(self):
        return 50

    def setup_session(self):
        """Setup dealer group selection."""
        self.dealer_group = display_dealer_groups()
        return self.dealer_group

    def generate_scenario(self):
        # Select dealer card based on chosen group
        if self.dealer_group == 1:  # Weak
            dealer_card = random.choice([4, 5, 6])
        elif self.dealer_group == 2:  # Medium
            dealer_card = random.choice([2, 3, 7, 8])
        else:  # Strong
            dealer_card = random.choice([9, 10, 11])

        hand_type = random.choice(['hard', 'soft', 'pair'])

        if hand_type == 'pair':
            pair_value = random.choice([2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
            player_cards = [pair_value, pair_value]
            player_total = pair_value
        elif hand_type == 'soft':
            other_card = random.randint(2, 9)
            player_cards = [11, other_card]
            player_total = 11 + other_card
        else:  # hard
            player_total = random.randint(5, 20)
            player_cards = self._generate_hand_cards(hand_type, player_total)

        return hand_type, player_cards, player_total, dealer_card


class HandTypeTrainingSession(TrainingSession):
    """Training session focused on specific hand types."""

    def __init__(self, difficulty='normal'):
        super().__init__(difficulty)
        self.hand_type_choice = None
        self._requires_submode = True

    @property
    def mode_name(self):
        return 'hand_types'

    @property
    def max_questions(self):
        return 50

    def setup_session(self):
        """Setup hand type selection."""
        self.hand_type_choice = display_hand_types()
        return self.hand_type_choice

    def generate_scenario(self):
        dealer_card = random.randint(2, 11)

        if self.hand_type_choice == 1:  # Hard totals
            player_total = random.randint(5, 20)
            player_cards = self._generate_hand_cards('hard', player_total)
            hand_type = 'hard'
        elif self.hand_type_choice == 2:  # Soft totals
            other_card = random.randint(2, 9)
            player_cards = [11, other_card]
            player_total = 11 + other_card
            hand_type = 'soft'
        else:  # Pairs
            pair_value = random.choice([2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
            player_cards = [pair_value, pair_value]
            player_total = pair_value
            hand_type = 'pair'

        return hand_type, player_cards, player_total, dealer_card


class AbsoluteTrainingSession(TrainingSession):
    """Training session focused on absolute rules (always/never scenarios)."""

    @property
    def mode_name(self):
        return 'absolutes'

    @property
    def max_questions(self):
        return 20

    def generate_scenario(self):
        absolutes = [
            ('pair', [11, 11], 11),  # A,A
            ('pair', [8, 8], 8),     # 8,8
            ('pair', [10, 10], 10),  # 10,10
            ('pair', [5, 5], 5),     # 5,5
            ('hard', None, 17),      # Hard 17
            ('hard', None, 18),      # Hard 18
            ('hard', None, 19),      # Hard 19
            ('hard', None, 20),      # Hard 20
            ('soft', [11, 8], 19),   # Soft 19
            ('soft', [11, 9], 20),   # Soft 20
        ]

        hand_type, player_cards, player_total = random.choice(absolutes)
        dealer_card = random.randint(2, 11)

        if player_cards is None:  # Hard totals
            player_cards = self._generate_hand_cards(hand_type, player_total)

        return hand_type, player_cards, player_total, dealer_card
