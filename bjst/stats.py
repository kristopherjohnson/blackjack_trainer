class Statistics:
    """Statistics tracking for blackjack strategy training sessions.

    This class tracks performance metrics during training sessions, including:
    - Overall accuracy (correct answers / total attempts)
    - Accuracy by hand type (hard totals, soft totals, pairs)
    - Accuracy by dealer strength (weak, medium, strong dealer cards)

    Dealer strength categories:
    - Weak: 4, 5, 6 (dealer bust cards)
    - Medium: 2, 3, 7, 8 (moderate dealer cards)
    - Strong: 9, 10, A (strong dealer cards)

    The statistics are maintained for the current session and can be displayed
    to show the user's progress and identify areas for improvement.
    """

    def __init__(self):
        self.session_data = {
            'total_attempts': 0,
            'correct_answers': 0,
            'by_category': {
                'hard': {'correct': 0, 'total': 0},
                'soft': {'correct': 0, 'total': 0},
                'pair': {'correct': 0, 'total': 0}
            },
            'by_dealer_strength': {
                'weak': {'correct': 0, 'total': 0},
                'medium': {'correct': 0, 'total': 0},
                'strong': {'correct': 0, 'total': 0}
            }
        }
        self.overall_accuracy = {}

    def record_attempt(self, hand_type, dealer_strength, correct):
        self.session_data['total_attempts'] += 1
        if correct:
            self.session_data['correct_answers'] += 1

        # Record by hand type
        if hand_type in self.session_data['by_category']:
            self.session_data['by_category'][hand_type]['total'] += 1
            if correct:
                self.session_data['by_category'][hand_type]['correct'] += 1

        # Record by dealer strength
        if dealer_strength in self.session_data['by_dealer_strength']:
            self.session_data['by_dealer_strength'][dealer_strength]['total'] += 1
            if correct:
                self.session_data['by_dealer_strength'][dealer_strength]['correct'] += 1

    def get_category_accuracy(self, category):
        data = self.session_data['by_category'].get(
            category, {'correct': 0, 'total': 0})
        if data['total'] == 0:
            return 0.0
        return (data['correct'] / data['total']) * 100

    def get_dealer_strength_accuracy(self, strength):
        data = self.session_data['by_dealer_strength'].get(
            strength, {'correct': 0, 'total': 0})
        if data['total'] == 0:
            return 0.0
        return (data['correct'] / data['total']) * 100

    def get_session_accuracy(self):
        if self.session_data['total_attempts'] == 0:
            return 0.0
        return (self.session_data['correct_answers'] /
                self.session_data['total_attempts']) * 100

    def display_progress(self):
        print("\n" + "=" * 50)
        print("SESSION STATISTICS")
        print("=" * 50)

        total = self.session_data['total_attempts']
        correct = self.session_data['correct_answers']

        if total == 0:
            print("No practice attempts yet this session.")
            return

        print(
            f"Overall: {correct}/{total} ({self.get_session_accuracy():.1f}%)")

        print("\nBy Hand Type:")
        for hand_type in ['hard', 'soft', 'pair']:
            data = self.session_data['by_category'][hand_type]
            if data['total'] > 0:
                accuracy = (data['correct'] / data['total']) * 100
                print(f"  {hand_type.capitalize()}: {data['correct']}/{data['total']} "
                      f"({accuracy:.1f}%)")

        print("\nBy Dealer Strength:")
        for strength in ['weak', 'medium', 'strong']:
            data = self.session_data['by_dealer_strength'][strength]
            if data['total'] > 0:
                accuracy = (data['correct'] / data['total']) * 100
                print(f"  {strength.capitalize()}: {data['correct']}/{data['total']} "
                      f"({accuracy:.1f}%)")

        input("\nPress Enter to continue...")

    def reset_session(self):
        self.session_data = {
            'total_attempts': 0,
            'correct_answers': 0,
            'by_category': {
                'hard': {'correct': 0, 'total': 0},
                'soft': {'correct': 0, 'total': 0},
                'pair': {'correct': 0, 'total': 0}
            },
            'by_dealer_strength': {
                'weak': {'correct': 0, 'total': 0},
                'medium': {'correct': 0, 'total': 0},
                'strong': {'correct': 0, 'total': 0}
            }
        }

    def get_dealer_strength(self, dealer_card):
        if dealer_card in [4, 5, 6]:
            return 'weak'
        if dealer_card in [2, 3, 7, 8]:
            return 'medium'
        # 9, 10, 11 (Ace)
        return 'strong'
