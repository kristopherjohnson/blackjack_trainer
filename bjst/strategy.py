class StrategyChart:
    """Complete blackjack basic strategy chart implementation.

    This class encapsulates the optimal basic strategy for blackjack based on
    standard casino rules: 4-8 decks, dealer stands on soft 17, double after
    split allowed, surrender not allowed.

    The strategy chart covers three main categories:
    - Hard totals (5-21): Hands without aces or where ace counts as 1
    - Soft totals (13-21): Hands with ace counting as 11 (A,2 through A,9)
    - Pairs (2,2 through A,A): Identical card pairs for split decisions

    Action codes:
    - H: Hit (take another card)
    - S: Stand (keep current total)
    - D: Double down (double bet, take exactly one more card)
    - Y: Split (for pairs - split into two separate hands)

    The class also provides:
    - Explanatory mnemonics for learning key patterns
    - Dealer strength groupings (weak/medium/strong)
    - Absolute rule identification for never/always scenarios

    All strategy decisions are based on mathematically optimal play that
    minimizes the house edge over the long term.
    """

    def __init__(self):
        self.hard_totals = self._build_hard_totals()
        self.soft_totals = self._build_soft_totals()
        self.pairs = self._build_pairs()
        self.mnemonics = self._build_mnemonics()
        self.dealer_groups = {
            'weak': [4, 5, 6],
            'medium': [2, 3, 7, 8],
            'strong': [9, 10, 11]
        }

    def _build_hard_totals(self):
        chart = {}

        # Hard 5-8: Always hit
        for total in range(5, 9):
            for dealer in range(2, 12):
                chart[(total, dealer)] = 'H'

        # Hard 9: Double vs 3-6, otherwise hit
        for dealer in range(2, 12):
            if 3 <= dealer <= 6:
                chart[(9, dealer)] = 'D'
            else:
                chart[(9, dealer)] = 'H'

        # Hard 10: Double vs 2-9, otherwise hit
        for dealer in range(2, 12):
            if 2 <= dealer <= 9:
                chart[(10, dealer)] = 'D'
            else:
                chart[(10, dealer)] = 'H'

        # Hard 11: Double vs 2-10, hit vs Ace
        for dealer in range(2, 12):
            if dealer <= 10:
                chart[(11, dealer)] = 'D'
            else:
                chart[(11, dealer)] = 'H'

        # Hard 12: Stand vs 4-6, otherwise hit
        for dealer in range(2, 12):
            if 4 <= dealer <= 6:
                chart[(12, dealer)] = 'S'
            else:
                chart[(12, dealer)] = 'H'

        # Hard 13-16: Stand vs 2-6, otherwise hit
        for total in range(13, 17):
            for dealer in range(2, 12):
                if 2 <= dealer <= 6:
                    chart[(total, dealer)] = 'S'
                else:
                    chart[(total, dealer)] = 'H'

        # Hard 17+: Always stand
        for total in range(17, 22):
            for dealer in range(2, 12):
                chart[(total, dealer)] = 'S'

        return chart

    def _build_soft_totals(self):
        chart = {}

        # Soft 13-14 (A,2-A,3): Double vs 5-6, otherwise hit
        for total in [13, 14]:
            for dealer in range(2, 12):
                if 5 <= dealer <= 6:
                    chart[(total, dealer)] = 'D'
                else:
                    chart[(total, dealer)] = 'H'

        # Soft 15-16 (A,4-A,5): Double vs 4-6, otherwise hit
        for total in [15, 16]:
            for dealer in range(2, 12):
                if 4 <= dealer <= 6:
                    chart[(total, dealer)] = 'D'
                else:
                    chart[(total, dealer)] = 'H'

        # Soft 17 (A,6): Double vs 3-6, otherwise hit
        for dealer in range(2, 12):
            if 3 <= dealer <= 6:
                chart[(17, dealer)] = 'D'
            else:
                chart[(17, dealer)] = 'H'

        # Soft 18 (A,7): Stand vs 2,7,8; Double vs 3-6; Hit vs 9,10,A
        for dealer in range(2, 12):
            if dealer in [2, 7, 8]:
                chart[(18, dealer)] = 'S'
            elif 3 <= dealer <= 6:
                chart[(18, dealer)] = 'D'
            else:
                chart[(18, dealer)] = 'H'

        # Soft 19-21: Always stand
        for total in [19, 20, 21]:
            for dealer in range(2, 12):
                chart[(total, dealer)] = 'S'

        return chart

    def _build_pairs(self):
        chart = {}

        # A,A: Always split
        for dealer in range(2, 12):
            chart[(11, dealer)] = 'Y'

        # 2,2 and 3,3: Split vs 2-7, otherwise hit
        for pair_val in [2, 3]:
            for dealer in range(2, 12):
                if 2 <= dealer <= 7:
                    chart[(pair_val, dealer)] = 'Y'
                else:
                    chart[(pair_val, dealer)] = 'H'

        # 4,4: Split vs 5-6, otherwise hit
        for dealer in range(2, 12):
            if 5 <= dealer <= 6:
                chart[(4, dealer)] = 'Y'
            else:
                chart[(4, dealer)] = 'H'

        # 5,5: Never split, treat as hard 10
        for dealer in range(2, 12):
            if 2 <= dealer <= 9:
                chart[(5, dealer)] = 'D'
            else:
                chart[(5, dealer)] = 'H'

        # 6,6: Split vs 2-6, otherwise hit
        for dealer in range(2, 12):
            if 2 <= dealer <= 6:
                chart[(6, dealer)] = 'Y'
            else:
                chart[(6, dealer)] = 'H'

        # 7,7: Split vs 2-7, otherwise hit
        for dealer in range(2, 12):
            if 2 <= dealer <= 7:
                chart[(7, dealer)] = 'Y'
            else:
                chart[(7, dealer)] = 'H'

        # 8,8: Always split
        for dealer in range(2, 12):
            chart[(8, dealer)] = 'Y'

        # 9,9: Split vs 2-9 except 7, stand vs 7,10,A
        for dealer in range(2, 12):
            if dealer in [7, 10, 11]:
                chart[(9, dealer)] = 'S'
            else:
                chart[(9, dealer)] = 'Y'

        # 10,10: Never split, always stand
        for dealer in range(2, 12):
            chart[(10, dealer)] = 'S'

        return chart

    def _build_mnemonics(self):
        return {
            'dealer_weak': "Dealer bust cards (4,5,6) = player gets greedy",
            'always_split': "Aces and eights, don't hesitate",
            'never_split': "Tens and fives, keep them alive",
            'teens_vs_strong': "Teens stay vs weak, flee from strong",
            'soft_17': "A,7 is the tricky soft hand",
            'hard_12': "12 is the exception - only stand vs 4,5,6",
            'doubles': "Double when dealer is weak and you can improve"
        }

    def get_correct_action(self, hand_type, player_total, dealer_card):
        if hand_type == 'pair':
            return self.pairs.get((player_total, dealer_card), 'H')
        if hand_type == 'soft':
            return self.soft_totals.get((player_total, dealer_card), 'H')
        # hard
        return self.hard_totals.get((player_total, dealer_card), 'H')

    def get_explanation(self, hand_type, player_total, dealer_card):
        explanations = {
            ('pair', 11): self.mnemonics['always_split'],
            ('pair', 8): self.mnemonics['always_split'],
            ('pair', 10): self.mnemonics['never_split'],
            ('pair', 5): self.mnemonics['never_split'],
            ('soft', 18): self.mnemonics['soft_17'],
            ('hard', 12): self.mnemonics['hard_12']
        }

        key = (hand_type, player_total)
        if key in explanations:
            return explanations[key]

        if dealer_card in self.dealer_groups['weak']:
            return self.mnemonics['dealer_weak']
        if player_total in range(
                13, 17) and dealer_card in self.dealer_groups['strong']:
            return self.mnemonics['teens_vs_strong']
        return "Follow basic strategy patterns"

    def is_absolute_rule(self, hand_type, player_total, dealer_card):  # pylint: disable=unused-argument
        absolutes = [
            ('pair', 11),  # Always split A,A
            ('pair', 8),   # Always split 8,8
            ('pair', 10),  # Never split 10,10
            ('pair', 5),   # Never split 5,5
        ]

        # Add hard 17+ always stand
        if hand_type == 'hard' and player_total >= 17:
            return True

        # Add soft 19+ always stand
        if hand_type == 'soft' and player_total >= 19:
            return True

        return (hand_type, player_total) in absolutes
