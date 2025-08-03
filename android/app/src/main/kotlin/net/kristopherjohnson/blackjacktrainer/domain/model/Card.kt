package net.kristopherjohnson.blackjacktrainer.domain.model

/**
 * Represents a playing card with suit and rank
 */
data class Card(
    val suit: Suit,
    val rank: Rank
) {
    /**
     * Numeric value for blackjack strategy calculations
     * Ace = 11 for soft total calculations, 1 for hard totals
     */
    val value: Int get() = rank.value
    
    /**
     * Display value for dealer cards (Ace shows as 'A' but calculates as 11)
     */
    val displayValue: String get() = rank.displayValue

    companion object {
        // Common cards for quick access
        val ACE_SPADES = Card(Suit.SPADES, Rank.ACE)
        val TWO_HEARTS = Card(Suit.HEARTS, Rank.TWO)
        val THREE_CLUBS = Card(Suit.CLUBS, Rank.THREE)
        val FOUR_DIAMONDS = Card(Suit.DIAMONDS, Rank.FOUR)
        val FIVE_SPADES = Card(Suit.SPADES, Rank.FIVE)
        val SIX_HEARTS = Card(Suit.HEARTS, Rank.SIX)
        val SEVEN_CLUBS = Card(Suit.CLUBS, Rank.SEVEN)
        val EIGHT_DIAMONDS = Card(Suit.DIAMONDS, Rank.EIGHT)
        val NINE_SPADES = Card(Suit.SPADES, Rank.NINE)
        val TEN_HEARTS = Card(Suit.HEARTS, Rank.TEN)
        val JACK_CLUBS = Card(Suit.CLUBS, Rank.JACK)
        val QUEEN_DIAMONDS = Card(Suit.DIAMONDS, Rank.QUEEN)
        val KING_SPADES = Card(Suit.SPADES, Rank.KING)
        
        fun randomCard(): Card {
            return Card(Suit.values().random(), Rank.values().random())
        }
        
        fun randomDealerCard(): Card {
            // Dealer cards 2-A (using 11 for Ace in strategy calculations)
            return when ((2..11).random()) {
                2 -> Card(Suit.values().random(), Rank.TWO)
                3 -> Card(Suit.values().random(), Rank.THREE)
                4 -> Card(Suit.values().random(), Rank.FOUR)
                5 -> Card(Suit.values().random(), Rank.FIVE)
                6 -> Card(Suit.values().random(), Rank.SIX)
                7 -> Card(Suit.values().random(), Rank.SEVEN)
                8 -> Card(Suit.values().random(), Rank.EIGHT)
                9 -> Card(Suit.values().random(), Rank.NINE)
                10 -> Card(Suit.values().random(), listOf(Rank.TEN, Rank.JACK, Rank.QUEEN, Rank.KING).random())
                11 -> Card(Suit.values().random(), Rank.ACE)
                else -> throw IllegalStateException("Invalid dealer card value")
            }
        }
    }
}

enum class Suit(val symbol: String) {
    HEARTS("♥"),
    DIAMONDS("♦"),
    CLUBS("♣"),
    SPADES("♠")
}

enum class Rank(val value: Int, val displayValue: String) {
    TWO(2, "2"),
    THREE(3, "3"),
    FOUR(4, "4"),
    FIVE(5, "5"),
    SIX(6, "6"),
    SEVEN(7, "7"),
    EIGHT(8, "8"),
    NINE(9, "9"),
    TEN(10, "10"),
    JACK(10, "J"),
    QUEEN(10, "Q"),
    KING(10, "K"),
    ACE(11, "A")  // Ace is 11 for strategy calculations, adjusts to 1 when needed
}