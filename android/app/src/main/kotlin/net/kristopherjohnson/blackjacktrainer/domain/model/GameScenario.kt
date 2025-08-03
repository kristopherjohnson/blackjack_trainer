package net.kristopherjohnson.blackjacktrainer.domain.model

import java.util.UUID

/**
 * Represents a blackjack training scenario
 */
data class GameScenario(
    val id: String = UUID.randomUUID().toString(),
    val handType: HandType,
    val playerCards: List<Card>,
    val playerTotal: Int,
    val dealerCard: Card,
    val difficulty: DifficultyLevel = DifficultyLevel.NORMAL,
    val sessionId: String? = null,
    val timestamp: Long = System.currentTimeMillis(),
    val metadata: ScenarioMetadata = ScenarioMetadata()
) {
    /**
     * Get the display string for player cards
     */
    fun getPlayerCardsDisplay(): String {
        return when {
            playerCards.isEmpty() -> "No cards"
            playerCards.size == 1 -> playerCards[0].displayValue
            handType == HandType.PAIR -> "${playerCards[0].displayValue},${playerCards[1].displayValue}"
            handType == HandType.SOFT -> "A,${playerCards.find { it.rank != Rank.ACE }?.displayValue ?: "?"}"
            else -> playerCards.joinToString(",") { it.displayValue }
        }
    }
    
    /**
     * Get descriptive text for the hand
     */
    fun getHandDescription(): String {
        return when (handType) {
            HandType.HARD -> "Hard $playerTotal"
            HandType.SOFT -> "Soft $playerTotal" 
            HandType.PAIR -> "Pair of ${playerCards.firstOrNull()?.displayValue ?: "?"}s"
        }
    }
    
    companion object {
        fun empty() = GameScenario(
            handType = HandType.HARD,
            playerCards = emptyList(),
            playerTotal = 0,
            dealerCard = Card.ACE_SPADES
        )
        
        fun createHardTotal(total: Int, dealerCard: Card): GameScenario {
            // Generate two cards that sum to the total (no ace)
            val cards = generateHardTotalCards(total)
            return GameScenario(
                handType = HandType.HARD,
                playerCards = cards,
                playerTotal = total,
                dealerCard = dealerCard
            )
        }
        
        fun createSoftTotal(total: Int, dealerCard: Card): GameScenario {
            // Generate ace plus another card
            val otherCardValue = total - 11
            val otherCard = when (otherCardValue) {
                2 -> Card(Suit.HEARTS, Rank.TWO)
                3 -> Card(Suit.HEARTS, Rank.THREE)
                4 -> Card(Suit.HEARTS, Rank.FOUR)
                5 -> Card(Suit.HEARTS, Rank.FIVE)
                6 -> Card(Suit.HEARTS, Rank.SIX)
                7 -> Card(Suit.HEARTS, Rank.SEVEN)
                8 -> Card(Suit.HEARTS, Rank.EIGHT)
                9 -> Card(Suit.HEARTS, Rank.NINE)
                else -> throw IllegalArgumentException("Invalid soft total: $total")
            }
            
            return GameScenario(
                handType = HandType.SOFT,
                playerCards = listOf(Card.ACE_SPADES, otherCard),
                playerTotal = total,
                dealerCard = dealerCard
            )
        }
        
        fun createPair(rank: Rank, dealerCard: Card): GameScenario {
            val cards = listOf(
                Card(Suit.SPADES, rank),
                Card(Suit.HEARTS, rank)
            )
            return GameScenario(
                handType = HandType.PAIR,
                playerCards = cards,
                playerTotal = rank.value * 2,
                dealerCard = dealerCard
            )
        }
        
        private fun generateHardTotalCards(total: Int): List<Card> {
            // Generate two non-ace cards that sum to total
            val validRanks = Rank.values().filter { it != Rank.ACE }
            
            for (first in validRanks) {
                for (second in validRanks) {
                    if (first.value + second.value == total) {
                        return listOf(
                            Card(Suit.SPADES, first),
                            Card(Suit.HEARTS, second)
                        )
                    }
                }
            }
            
            // Fallback: use 10-value cards if needed
            val remaining = total - 10
            val secondRank = validRanks.find { it.value == remaining } ?: Rank.TWO
            return listOf(
                Card(Suit.SPADES, Rank.TEN),
                Card(Suit.HEARTS, secondRank)
            )
        }
    }
}

/**
 * Additional metadata for training scenarios
 */
data class ScenarioMetadata(
    val isAbsoluteRule: Boolean = false,
    val complexity: ComplexityLevel = ComplexityLevel.BASIC,
    val mnemonicHint: String? = null,
    val expectedDifficulty: Double = 0.5,
    val tags: Set<String> = emptySet()
)

enum class DifficultyLevel(val displayName: String, val multiplier: Double) {
    BEGINNER("Beginner", 0.7),
    NORMAL("Normal", 1.0),
    ADVANCED("Advanced", 1.3),
    EXPERT("Expert", 1.6)
}

enum class ComplexityLevel {
    BASIC,      // Clear-cut decisions
    MODERATE,   // Some edge cases
    COMPLEX,    // Multiple valid strategies
    EXPERT      // Requires deep understanding
}