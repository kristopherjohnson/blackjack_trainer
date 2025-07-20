import unittest
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from strategy import StrategyChart  # pylint: disable=wrong-import-position


class TestStrategyChart(unittest.TestCase):  # pylint: disable=too-many-public-methods

    def setUp(self):
        self.chart = StrategyChart()

    def test_hard_totals_low_values(self):
        # Hard 5-8: Always hit
        for total in range(5, 9):
            for dealer in range(2, 12):
                action = self.chart.get_correct_action('hard', total, dealer)
                self.assertEqual(action, 'H',
                                 f"Hard {total} vs {dealer} should be Hit")

    def test_hard_9_strategy(self):
        # Hard 9: Double vs 3-6, otherwise hit
        for dealer in range(2, 12):
            action = self.chart.get_correct_action('hard', 9, dealer)
            if 3 <= dealer <= 6:
                self.assertEqual(action, 'D',
                                 f"Hard 9 vs {dealer} should be Double")
            else:
                self.assertEqual(action, 'H',
                                 f"Hard 9 vs {dealer} should be Hit")

    def test_hard_10_strategy(self):
        # Hard 10: Double vs 2-9, otherwise hit
        for dealer in range(2, 12):
            action = self.chart.get_correct_action('hard', 10, dealer)
            if 2 <= dealer <= 9:
                self.assertEqual(action, 'D',
                                 f"Hard 10 vs {dealer} should be Double")
            else:
                self.assertEqual(action, 'H',
                                 f"Hard 10 vs {dealer} should be Hit")

    def test_hard_11_strategy(self):
        # Hard 11: Double vs 2-10, hit vs Ace
        for dealer in range(2, 12):
            action = self.chart.get_correct_action('hard', 11, dealer)
            if dealer <= 10:
                self.assertEqual(action, 'D',
                                 f"Hard 11 vs {dealer} should be Double")
            else:  # Ace
                self.assertEqual(action, 'H',
                                 "Hard 11 vs Ace should be Hit")

    def test_hard_12_strategy(self):
        # Hard 12: Stand vs 4-6, otherwise hit
        for dealer in range(2, 12):
            action = self.chart.get_correct_action('hard', 12, dealer)
            if 4 <= dealer <= 6:
                self.assertEqual(action, 'S',
                                 f"Hard 12 vs {dealer} should be Stand")
            else:
                self.assertEqual(action, 'H',
                                 f"Hard 12 vs {dealer} should be Hit")

    def test_hard_13_16_strategy(self):
        # Hard 13-16: Stand vs 2-6, otherwise hit
        for total in range(13, 17):
            for dealer in range(2, 12):
                action = self.chart.get_correct_action('hard', total, dealer)
                if 2 <= dealer <= 6:
                    self.assertEqual(
                        action, 'S', f"Hard {total} vs {dealer} should be Stand")
                else:
                    self.assertEqual(action, 'H',
                                     f"Hard {total} vs {dealer} should be Hit")

    def test_hard_17_plus_strategy(self):
        # Hard 17+: Always stand
        for total in range(17, 22):
            for dealer in range(2, 12):
                action = self.chart.get_correct_action('hard', total, dealer)
                self.assertEqual(action, 'S',
                                 f"Hard {total} vs {dealer} should be Stand")

    def test_soft_13_14_strategy(self):
        # Soft 13-14: Double vs 5-6, otherwise hit
        for total in [13, 14]:
            for dealer in range(2, 12):
                action = self.chart.get_correct_action('soft', total, dealer)
                if 5 <= dealer <= 6:
                    self.assertEqual(
                        action, 'D', f"Soft {total} vs {dealer} should be Double")
                else:
                    self.assertEqual(action, 'H',
                                     f"Soft {total} vs {dealer} should be Hit")

    def test_soft_15_16_strategy(self):
        # Soft 15-16: Double vs 4-6, otherwise hit
        for total in [15, 16]:
            for dealer in range(2, 12):
                action = self.chart.get_correct_action('soft', total, dealer)
                if 4 <= dealer <= 6:
                    self.assertEqual(
                        action, 'D', f"Soft {total} vs {dealer} should be Double")
                else:
                    self.assertEqual(action, 'H',
                                     f"Soft {total} vs {dealer} should be Hit")

    def test_soft_17_strategy(self):
        # Soft 17: Double vs 3-6, otherwise hit
        for dealer in range(2, 12):
            action = self.chart.get_correct_action('soft', 17, dealer)
            if 3 <= dealer <= 6:
                self.assertEqual(action, 'D',
                                 f"Soft 17 vs {dealer} should be Double")
            else:
                self.assertEqual(action, 'H',
                                 f"Soft 17 vs {dealer} should be Hit")

    def test_soft_18_strategy(self):
        # Soft 18: Stand vs 2,7,8; Double vs 3-6; Hit vs 9,10,A
        for dealer in range(2, 12):
            action = self.chart.get_correct_action('soft', 18, dealer)
            if dealer in [2, 7, 8]:
                self.assertEqual(action, 'S',
                                 f"Soft 18 vs {dealer} should be Stand")
            elif 3 <= dealer <= 6:
                self.assertEqual(action, 'D',
                                 f"Soft 18 vs {dealer} should be Double")
            else:  # 9, 10, A
                self.assertEqual(action, 'H',
                                 f"Soft 18 vs {dealer} should be Hit")

    def test_soft_19_plus_strategy(self):
        # Soft 19-21: Always stand
        for total in [19, 20, 21]:
            for dealer in range(2, 12):
                action = self.chart.get_correct_action('soft', total, dealer)
                self.assertEqual(action, 'S',
                                 f"Soft {total} vs {dealer} should be Stand")

    def test_pairs_aces_strategy(self):
        # A,A: Always split
        for dealer in range(2, 12):
            action = self.chart.get_correct_action('pair', 11, dealer)
            self.assertEqual(action, 'Y',
                             f"Pair of Aces vs {dealer} should be Split")

    def test_pairs_2_3_strategy(self):
        # 2,2 and 3,3: Split vs 2-7, otherwise hit
        for pair_val in [2, 3]:
            for dealer in range(2, 12):
                action = self.chart.get_correct_action(
                    'pair', pair_val, dealer)
                if 2 <= dealer <= 7:
                    self.assertEqual(
                        action, 'Y', f"Pair of {pair_val}s vs {dealer} should be Split")
                else:
                    self.assertEqual(
                        action, 'H', f"Pair of {pair_val}s vs {dealer} should be Hit")

    def test_pairs_4_strategy(self):
        # 4,4: Split vs 5-6, otherwise hit
        for dealer in range(2, 12):
            action = self.chart.get_correct_action('pair', 4, dealer)
            if 5 <= dealer <= 6:
                self.assertEqual(action, 'Y',
                                 f"Pair of 4s vs {dealer} should be Split")
            else:
                self.assertEqual(action, 'H',
                                 f"Pair of 4s vs {dealer} should be Hit")

    def test_pairs_5_strategy(self):
        # 5,5: Never split, treat as hard 10
        for dealer in range(2, 12):
            action = self.chart.get_correct_action('pair', 5, dealer)
            if 2 <= dealer <= 9:
                self.assertEqual(action, 'D',
                                 f"Pair of 5s vs {dealer} should be Double")
            else:
                self.assertEqual(action, 'H',
                                 f"Pair of 5s vs {dealer} should be Hit")

    def test_pairs_6_strategy(self):
        # 6,6: Split vs 2-6, otherwise hit
        for dealer in range(2, 12):
            action = self.chart.get_correct_action('pair', 6, dealer)
            if 2 <= dealer <= 6:
                self.assertEqual(action, 'Y',
                                 f"Pair of 6s vs {dealer} should be Split")
            else:
                self.assertEqual(action, 'H',
                                 f"Pair of 6s vs {dealer} should be Hit")

    def test_pairs_7_strategy(self):
        # 7,7: Split vs 2-7, otherwise hit
        for dealer in range(2, 12):
            action = self.chart.get_correct_action('pair', 7, dealer)
            if 2 <= dealer <= 7:
                self.assertEqual(action, 'Y',
                                 f"Pair of 7s vs {dealer} should be Split")
            else:
                self.assertEqual(action, 'H',
                                 f"Pair of 7s vs {dealer} should be Hit")

    def test_pairs_8_strategy(self):
        # 8,8: Always split
        for dealer in range(2, 12):
            action = self.chart.get_correct_action('pair', 8, dealer)
            self.assertEqual(action, 'Y',
                             f"Pair of 8s vs {dealer} should be Split")

    def test_pairs_9_strategy(self):
        # 9,9: Split vs 2-9 except 7, stand vs 7,10,A
        for dealer in range(2, 12):
            action = self.chart.get_correct_action('pair', 9, dealer)
            if dealer in [7, 10, 11]:
                self.assertEqual(action, 'S',
                                 f"Pair of 9s vs {dealer} should be Stand")
            else:
                self.assertEqual(action, 'Y',
                                 f"Pair of 9s vs {dealer} should be Split")

    def test_pairs_10_strategy(self):
        # 10,10: Never split, always stand
        for dealer in range(2, 12):
            action = self.chart.get_correct_action('pair', 10, dealer)
            self.assertEqual(action, 'S',
                             f"Pair of 10s vs {dealer} should be Stand")

    def test_absolute_rules(self):
        # Test the absolute rules identification
        self.assertTrue(self.chart.is_absolute_rule('pair', 11, 5))  # A,A
        self.assertTrue(self.chart.is_absolute_rule('pair', 8, 10))  # 8,8
        self.assertTrue(self.chart.is_absolute_rule('pair', 10, 6))  # 10,10
        self.assertTrue(self.chart.is_absolute_rule('pair', 5, 4))   # 5,5
        self.assertTrue(
            self.chart.is_absolute_rule(
                'hard', 17, 10))  # Hard 17+
        self.assertTrue(self.chart.is_absolute_rule('soft', 19, 6))  # Soft 19+

        # Test non-absolute rules
        self.assertFalse(self.chart.is_absolute_rule('hard', 16, 7))
        self.assertFalse(self.chart.is_absolute_rule('soft', 18, 6))
        self.assertFalse(self.chart.is_absolute_rule('pair', 6, 4))

    def test_explanations(self):
        # Test that explanations are returned
        explanation = self.chart.get_explanation('pair', 11, 5)
        self.assertIsInstance(explanation, str)
        self.assertGreater(len(explanation), 0)

        explanation = self.chart.get_explanation('hard', 16, 10)
        self.assertIsInstance(explanation, str)
        self.assertGreater(len(explanation), 0)

    def test_dealer_groups(self):
        # Test dealer group classifications
        self.assertEqual(self.chart.dealer_groups['weak'], [4, 5, 6])
        self.assertEqual(self.chart.dealer_groups['medium'], [2, 3, 7, 8])
        self.assertEqual(self.chart.dealer_groups['strong'], [9, 10, 11])

    def test_edge_cases(self):
        # Test some specific edge cases from the strategy

        # Hard 12 vs 2 should be Hit (exception to 13-16 rule)
        self.assertEqual(self.chart.get_correct_action('hard', 12, 2), 'H')

        # Hard 12 vs 3 should be Hit (exception to 13-16 rule)
        self.assertEqual(self.chart.get_correct_action('hard', 12, 3), 'H')

        # Soft 18 vs 9 should be Hit (not stand)
        self.assertEqual(self.chart.get_correct_action('soft', 18, 9), 'H')

        # Pair 9s vs 7 should be Stand (not split)
        self.assertEqual(self.chart.get_correct_action('pair', 9, 7), 'S')


class TestStrategyChartComprehensive(unittest.TestCase):
    """Additional comprehensive tests for full coverage"""

    def setUp(self):
        self.chart = StrategyChart()

    def test_all_hard_totals_coverage(self):
        """Test that all hard total combinations have valid actions"""
        for total in range(5, 22):
            for dealer in range(2, 12):
                action = self.chart.get_correct_action('hard', total, dealer)
                self.assertIn(
                    action, [
                        'H', 'S', 'D'], f"Invalid action '{action}' for Hard {total} vs {dealer}")

    def test_all_soft_totals_coverage(self):
        """Test that all soft total combinations have valid actions"""
        for total in range(13, 22):
            for dealer in range(2, 12):
                action = self.chart.get_correct_action('soft', total, dealer)
                self.assertIn(
                    action, [
                        'H', 'S', 'D'], f"Invalid action '{action}' for Soft {total} vs {dealer}")

    def test_all_pairs_coverage(self):
        """Test that all pair combinations have valid actions"""
        for pair_val in range(2, 12):
            for dealer in range(2, 12):
                action = self.chart.get_correct_action(
                    'pair', pair_val, dealer)
                self.assertIn(action, ['H', 'S', 'D', 'Y'],
                              f"Invalid action '{action}' for Pair {pair_val}s vs {dealer}")


if __name__ == '__main__':
    unittest.main()
