"""
Unit tests for hand generation functionality.

Tests to ensure that generate_hand_cards produces valid card combinations
that are realistic for blackjack gameplay.
"""

import unittest
from bjst.trainer import RandomTrainingSession


class TestHandGeneration(unittest.TestCase):
    """Test hand generation produces valid card combinations."""

    def setUp(self):
        """Set up test fixtures."""
        self.session = RandomTrainingSession()

    def test_pair_hand_generation(self):
        """Test that pair hands generate correctly."""
        for pair_value in [2, 3, 4, 5, 6, 7, 8, 9, 10, 11]:
            cards = self.session._generate_hand_cards('pair', pair_value)
            self.assertEqual(len(cards), 2, f"Pair {pair_value} should have 2 cards")
            self.assertEqual(cards[0], pair_value, f"First card should be {pair_value}")
            self.assertEqual(cards[1], pair_value, f"Second card should be {pair_value}")

    def test_soft_hand_generation(self):
        """Test that soft hands generate correctly."""
        for soft_total in range(13, 22):  # A,2 through A,10 (13-21)
            cards = self.session._generate_hand_cards('soft', soft_total)
            self.assertEqual(len(cards), 2, f"Soft {soft_total} should have 2 cards")
            self.assertIn(11, cards, f"Soft hand should contain an Ace (11)")
            other_card = soft_total - 11
            self.assertIn(other_card, cards, f"Soft {soft_total} should contain {other_card}")
            self.assertTrue(2 <= other_card <= 10, f"Other card {other_card} should be 2-10")

    def test_hard_hand_valid_cards(self):
        """Test that hard hands only contain valid card values."""
        for total in range(5, 22):  # Hard 5-21
            cards = self.session._generate_hand_cards('hard', total)
            
            # All cards must be valid (2-10 or 11)
            for card in cards:
                self.assertTrue(
                    2 <= card <= 11,
                    f"Invalid card value {card} in hard {total}: {cards}"
                )
            
            # Cards must sum to the total
            self.assertEqual(
                sum(cards), total,
                f"Cards {cards} don't sum to {total} (sum={sum(cards)})"
            )

    def test_hard_hand_no_aces_for_low_totals(self):
        """Test that hard hands don't use aces when not necessary."""
        for total in range(5, 11):  # Hard 5-10 (11 can be a single Ace)
            cards = self.session._generate_hand_cards('hard', total)
            
            # For totals 5-10, we shouldn't need aces (would make it soft)
            for card in cards:
                self.assertNotEqual(
                    card, 11,
                    f"Hard {total} shouldn't contain Ace: {cards}"
                )

    def test_hard_hand_realistic_combinations(self):
        """Test that hard hands use realistic card combinations."""
        # Test many iterations to catch edge cases
        for _ in range(100):
            for total in range(12, 22):  # Hard 12-21
                cards = self.session._generate_hand_cards('hard', total)
                
                # All cards must be 2-10 (no aces in hard totals)
                for card in cards:
                    self.assertTrue(
                        2 <= card <= 10,
                        f"Hard total shouldn't contain Ace: {cards} for total {total}"
                    )
                
                # Should have reasonable number of cards
                self.assertTrue(
                    len(cards) <= 6,
                    f"Too many cards for hard {total}: {cards}"
                )

    def test_edge_case_totals(self):
        """Test edge cases like very high totals."""
        # Test hard 20 and 21
        for total in [20, 21]:
            cards = self.session._generate_hand_cards('hard', total)
            
            # Should still be valid
            self.assertEqual(sum(cards), total)
            for card in cards:
                self.assertTrue(2 <= card <= 10)

    def test_single_card_totals(self):
        """Test that single-card totals work correctly."""
        for total in range(2, 12):  # 2-11
            cards = self.session._generate_hand_cards('hard', total)
            
            if total <= 11:
                # Should be single card for low totals
                self.assertEqual(len(cards), 1, f"Total {total} should be single card")
                self.assertEqual(cards[0], total)

    def test_no_invalid_card_values(self):
        """Test that no invalid card values (0, 1, >11) are generated."""
        invalid_values = [0, 1, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21]
        
        for _ in range(200):  # Many iterations to catch rare cases
            for hand_type in ['hard', 'soft', 'pair']:
                if hand_type == 'pair':
                    totals = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
                elif hand_type == 'soft':
                    totals = range(13, 22)
                else:  # hard
                    totals = range(5, 22)
                
                for total in totals:
                    cards = self.session._generate_hand_cards(hand_type, total)
                    
                    for card in cards:
                        self.assertNotIn(
                            card, invalid_values,
                            f"Invalid card {card} in {hand_type} {total}: {cards}"
                        )

    def test_hard_18_specific_case(self):
        """Test the specific case that was reported as buggy."""
        # Test hard 18 many times to ensure no invalid cards
        for _ in range(50):
            cards = self.session._generate_hand_cards('hard', 18)
            
            # Should sum to 18
            self.assertEqual(sum(cards), 18)
            
            # All cards should be valid (2-10)
            for card in cards:
                self.assertTrue(
                    2 <= card <= 10,
                    f"Invalid card {card} in hard 18: {cards}"
                )
            
            # Should not contain the problematic card 16
            self.assertNotIn(16, cards, f"Found invalid card 16 in: {cards}")


if __name__ == '__main__':
    unittest.main()