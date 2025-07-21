#pragma once

#include <string>
#include <tuple>
#include <vector>

namespace blackjack {

/**
 * Display the main menu and get user choice.
 * @return User's menu choice (1-6)
 */
int display_menu();

/**
 * Display session header with mode name.
 * @param mode_name Name of the training mode
 */
void display_session_header(const std::string &mode_name);

/**
 * Display the current hand and dealer card.
 * @param player_cards Vector of player's cards
 * @param dealer_card Dealer's up card
 * @param hand_type Type of hand ("hard", "soft", "pair")
 * @param player_total Player's hand total
 */
void display_hand(const std::vector<int> &player_cards, int dealer_card,
                  const std::string &hand_type, int player_total);

/**
 * Get user's action choice.
 * @return User's action character ('H', 'S', 'D', 'P') or '\0' if quit
 */
char get_user_action();

/**
 * Display feedback after user's answer.
 * @param correct Whether the answer was correct
 * @param user_action User's chosen action
 * @param correct_action The correct action
 * @param explanation Explanatory text
 * @return True if user wants to quit
 */
bool display_feedback(bool correct, char user_action, char correct_action,
                      const std::string &explanation);

/**
 * Display dealer groups menu and get user choice.
 * @return User's choice (1-3) or 0 if cancelled
 */
int display_dealer_groups();

/**
 * Display hand types menu and get user choice.
 * @return User's choice (1-3) or 0 if cancelled
 */
int display_hand_types();

/**
 * Convert card value to display string.
 * @param card Card value (2-11, where 11 = Ace)
 * @return String representation of card
 */
std::string card_to_string(int card);

/**
 * Convert action character to full word.
 * @param action Action character ('H', 'S', 'D', 'Y')
 * @return Full action name
 */
std::string action_to_string(char action);

} // namespace blackjack