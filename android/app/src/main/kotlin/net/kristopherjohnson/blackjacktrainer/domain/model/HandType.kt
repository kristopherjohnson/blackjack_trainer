package net.kristopherjohnson.blackjacktrainer.domain.model

/**
 * Types of blackjack hands for strategy purposes
 */
enum class HandType(
    val displayName: String,
    val description: String
) {
    HARD(
        displayName = "Hard Total",
        description = "No ace or ace counts as 1"
    ),
    SOFT(
        displayName = "Soft Total", 
        description = "Ace counts as 11"
    ),
    PAIR(
        displayName = "Pair",
        description = "Two cards of same rank"
    );
    
    companion object {
        /**
         * Determine hand type from player cards
         */
        fun fromCards(cards: List<Card>): HandType {
            if (cards.size != 2) {
                // For multi-card hands, check if we have a usable ace
                val hasAce = cards.any { it.rank == Rank.ACE }
                val total = cards.sumOf { it.value }
                
                return if (hasAce && total <= 21) {
                    // Check if ace can count as 11 without busting
                    val hardTotal = cards.sumOf { if (it.rank == Rank.ACE) 1 else it.value }
                    if (hardTotal + 10 <= 21) SOFT else HARD
                } else {
                    HARD
                }
            }
            
            // Two-card hands
            val first = cards[0]
            val second = cards[1]
            
            return when {
                first.rank == second.rank -> PAIR
                cards.any { it.rank == Rank.ACE } -> SOFT
                else -> HARD
            }
        }
    }
}