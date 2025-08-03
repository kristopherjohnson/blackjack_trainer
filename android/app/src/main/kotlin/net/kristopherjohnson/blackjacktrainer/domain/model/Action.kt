package net.kristopherjohnson.blackjacktrainer.domain.model

/**
 * Blackjack actions available to the player
 */
enum class Action(
    val displayName: String,
    val accessibilityLabel: String,
    val shortCode: String,
    val keyboardShortcut: Char,
    val description: String,
    val colorValue: Long = 0xFF1976D2L
) {
    HIT(
        displayName = "Hit",
        accessibilityLabel = "Hit - Take another card",
        shortCode = "H",
        keyboardShortcut = 'H',
        description = "Take another card",
        colorValue = 0xFF1976D2L // Blue
    ),
    STAND(
        displayName = "Stand",
        accessibilityLabel = "Stand - Keep current hand",
        shortCode = "S",
        keyboardShortcut = 'S',
        description = "Keep current hand",
        colorValue = 0xFF388E3CL // Green
    ),
    DOUBLE(
        displayName = "Double",
        accessibilityLabel = "Double - Double bet and take one card",
        shortCode = "D",
        keyboardShortcut = 'D',
        description = "Double bet and take exactly one more card",
        colorValue = 0xFFFF9800L // Orange
    ),
    SPLIT(
        displayName = "Split",
        accessibilityLabel = "Split - Split pair into two hands",
        shortCode = "Y",
        keyboardShortcut = 'Y',
        description = "Split pair into two separate hands",
        colorValue = 0xFF9C27B0L // Purple
    ),
    NO_SPLIT(
        displayName = "Don't Split",
        accessibilityLabel = "Don't Split - Play pair as regular hand",
        shortCode = "N",
        keyboardShortcut = 'N',
        description = "Don't split, play as regular hand",
        colorValue = 0xFFF44336L // Red
    );

    companion object {
        /**
         * Get action from user input character
         */
        fun fromChar(char: Char): Action? {
            return values().find { 
                it.keyboardShortcut.equals(char, ignoreCase = true) 
            }
        }
        
        /**
         * Get action from short code used in strategy charts
         */
        fun fromShortCode(code: String): Action? {
            return values().find { 
                it.shortCode.equals(code, ignoreCase = true) 
            }
        }
        
        /**
         * Get available actions for a given hand type
         */
        fun getAvailableActions(handType: HandType): List<Action> {
            return when (handType) {
                HandType.PAIR -> listOf(SPLIT, NO_SPLIT)
                HandType.HARD, HandType.SOFT -> listOf(HIT, STAND, DOUBLE)
            }
        }
    }
}