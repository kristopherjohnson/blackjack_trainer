def display_menu():
    print("\nBlackjack Basic Strategy Trainer")
    print("1. Quick Practice (random)")
    print("2. Learn by Dealer Strength")
    print("3. Focus on Hand Types")
    print("4. Absolutes Drill")
    print("5. View Statistics")
    print("6. Quit")
    
    while True:
        try:
            choice = int(input("\nEnter your choice (1-6): "))
            if 1 <= choice <= 6:
                return choice
            else:
                print("Please enter a number between 1 and 6.")
        except ValueError:
            print("Please enter a valid number.")

def display_hand(player_cards, dealer_card, hand_type, player_total):
    print(f"\nDealer shows: {card_name(dealer_card)}")
    
    if hand_type == 'pair':
        card_val = player_cards[0]
        print(f"Your hand: {card_name(card_val)}, {card_name(card_val)} (Pair of {card_name(card_val)}s)")
    else:
        card_str = ", ".join([card_name(card) for card in player_cards])
        total_type = "Soft" if hand_type == 'soft' else "Hard"
        print(f"Your hand: {card_str} ({total_type} {player_total})")

def card_name(value):
    if value == 11:
        return "A"
    elif value == 10:
        return "10"
    else:
        return str(value)

def get_user_action():
    print("\nWhat's your move?")
    print("(H)it, (S)tand, (D)ouble, s(P)lit")
    
    while True:
        action = input("Enter your choice: ").upper().strip()
        if action in ['H', 'S', 'D', 'P']:
            return action
        else:
            print("Please enter H, S, D, or P.")

def action_name(action):
    names = {'H': 'HIT', 'S': 'STAND', 'D': 'DOUBLE', 'P': 'SPLIT', 'Y': 'SPLIT', 'N': 'NO SPLIT'}
    return names.get(action, action)

def display_feedback(correct, user_action, correct_action, explanation):
    if correct:
        print("✓ Correct!")
    else:
        print("❌ Incorrect!")
        print(f"\nCorrect answer: {action_name(correct_action)}")
        print(f"Your answer: {action_name(user_action)}")
        print(f"\nExplanation: {explanation}")
    
    response = input("\nPress Enter to continue, or q to quit: ").strip().lower()
    if response in ['q', 'quit']:
        return 'quit'
    return 'continue'

def display_session_header(mode):
    mode_names = {
        'random': 'Quick Practice',
        'dealer_groups': 'Dealer Strength Practice',
        'hand_types': 'Hand Type Focus',
        'absolutes': 'Absolutes Drill'
    }
    
    print(f"\n{'='*50}")
    print(f"Starting {mode_names.get(mode, mode)} Session")
    print("Type 'quit' at any time to return to main menu")
    print(f"{'='*50}")

def get_user_choice(prompt, choices):
    while True:
        try:
            choice = input(prompt)
            if choice.lower() == 'quit':
                return None
            choice = int(choice)
            if choice in choices:
                return choice
            else:
                print(f"Please choose from: {', '.join(map(str, choices))}")
        except ValueError:
            print("Please enter a valid number or 'quit'.")

def display_dealer_groups():
    print("\nChoose dealer strength group:")
    print("1. Weak dealers (4, 5, 6) - Bust cards")
    print("2. Medium dealers (2, 3, 7, 8)")
    print("3. Strong dealers (9, 10, A)")
    return get_user_choice("Enter choice (1-3): ", [1, 2, 3])

def display_hand_types():
    print("\nChoose hand type to practice:")
    print("1. Hard totals only")
    print("2. Soft totals only") 
    print("3. Pairs only")
    return get_user_choice("Enter choice (1-3): ", [1, 2, 3])

def clear_screen():
    import os
    os.system('clear')