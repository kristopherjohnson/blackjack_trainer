import random
from strategy import StrategyChart
from ui import (display_session_header, display_hand, get_user_action, 
                display_feedback, display_dealer_groups, display_hand_types)

class TrainingSession:
    def __init__(self, mode, difficulty):
        self.mode = mode
        self.difficulty = difficulty
        self.strategy = StrategyChart()
        self.correct_count = 0
        self.total_count = 0
        self.session_stats = {}
    
    def generate_scenario(self, submode=None):
        if self.mode == 'random':
            return self._generate_random_scenario()
        elif self.mode == 'dealer_groups':
            return self._generate_dealer_group_scenario(submode)
        elif self.mode == 'hand_types':
            return self._generate_hand_type_scenario(submode)
        elif self.mode == 'absolutes':
            return self._generate_absolute_scenario()
        else:
            return self._generate_random_scenario()
    
    def _generate_random_scenario(self):
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
            if player_total <= 11:
                player_cards = [player_total]
            else:
                first_card = random.randint(2, min(10, player_total - 2))
                second_card = player_total - first_card
                player_cards = [first_card, second_card]
        
        return hand_type, player_cards, player_total, dealer_card
    
    def _generate_dealer_group_scenario(self, group_choice):
        if group_choice == 1:  # Weak
            dealer_card = random.choice([4, 5, 6])
        elif group_choice == 2:  # Medium
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
            if player_total <= 11:
                player_cards = [player_total]
            else:
                first_card = random.randint(2, min(10, player_total - 2))
                second_card = player_total - first_card
                player_cards = [first_card, second_card]
        
        return hand_type, player_cards, player_total, dealer_card
    
    def _generate_hand_type_scenario(self, type_choice):
        dealer_card = random.randint(2, 11)
        
        if type_choice == 1:  # Hard totals
            player_total = random.randint(5, 20)
            if player_total <= 11:
                player_cards = [player_total]
            else:
                first_card = random.randint(2, min(10, player_total - 2))
                second_card = player_total - first_card
                player_cards = [first_card, second_card]
            hand_type = 'hard'
        elif type_choice == 2:  # Soft totals
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
    
    def _generate_absolute_scenario(self):
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
            if player_total <= 11:
                player_cards = [player_total]
            else:
                first_card = random.randint(2, min(10, player_total - 2))
                second_card = player_total - first_card
                player_cards = [first_card, second_card]
        
        return hand_type, player_cards, player_total, dealer_card
    
    def check_answer(self, user_action, correct_action):
        # Handle split variations
        if user_action == 'P':
            user_action = 'Y'
        
        return user_action == correct_action
    
    def show_feedback(self, scenario, user_action, correct_action):
        hand_type, player_cards, player_total, dealer_card = scenario
        correct = self.check_answer(user_action, correct_action)
        explanation = self.strategy.get_explanation(hand_type, player_total, dealer_card)
        
        response = display_feedback(correct, user_action, correct_action, explanation)
        return correct, response
    
    def run(self, stats):
        display_session_header(self.mode)
        
        submode = None
        if self.mode == 'dealer_groups':
            submode = display_dealer_groups()
            if submode is None:
                return
        elif self.mode == 'hand_types':
            submode = display_hand_types()
            if submode is None:
                return
        
        question_count = 0
        max_questions = 20 if self.mode == 'absolutes' else 50
        
        while question_count < max_questions:
            scenario = self.generate_scenario(submode)
            hand_type, player_cards, player_total, dealer_card = scenario
            
            display_hand(player_cards, dealer_card, hand_type, player_total)
            
            user_action = get_user_action()
            if user_action is None:  # User quit
                break
            
            correct_action = self.strategy.get_correct_action(hand_type, player_total, dealer_card)
            correct, response = self.show_feedback(scenario, user_action, correct_action)
            
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
            print(f"\nSession complete! Final score: {self.correct_count}/{self.total_count} ({accuracy:.1f}%)")
        
        input("Press Enter to return to main menu...")