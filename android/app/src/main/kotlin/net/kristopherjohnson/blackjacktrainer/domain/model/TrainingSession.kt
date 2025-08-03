package net.kristopherjohnson.blackjacktrainer.domain.model

/**
 * Types of training sessions available
 */
enum class TrainingSessionType(
    val displayName: String,
    val description: String,
    val maxQuestions: Int
) {
    RANDOM(
        displayName = "Quick Practice",
        description = "Random hands vs random dealer cards",
        maxQuestions = 20
    ),
    DEALER_GROUP(
        displayName = "Dealer Strength Groups",
        description = "Practice by dealer weakness",
        maxQuestions = 15
    ),
    HAND_TYPE(
        displayName = "Hand Type Focus",
        description = "Practice specific hand categories",
        maxQuestions = 15
    ),
    ABSOLUTES(
        displayName = "Absolutes Drill",
        description = "Never/always rules",
        maxQuestions = 10
    );
    
    companion object {
        fun getDefaultSessionType(): TrainingSessionType = RANDOM
    }
}

/**
 * Dealer strength groupings for focused practice
 */
enum class DealerStrength(
    val displayName: String,
    val description: String,
    val cards: List<Int>
) {
    WEAK(
        displayName = "Weak (4,5,6)",
        description = "Dealer bust cards - player gets greedy",
        cards = listOf(4, 5, 6)
    ),
    MEDIUM(
        displayName = "Medium (2,3,7,8)",
        description = "Moderate strategy",
        cards = listOf(2, 3, 7, 8)
    ),
    STRONG(
        displayName = "Strong (9,10,A)",
        description = "Conservative approach",
        cards = listOf(9, 10, 11) // 11 represents Ace
    );
    
    fun containsCard(card: Card): Boolean {
        return cards.contains(card.value)
    }
}

/**
 * Hand type focus options
 */
enum class HandTypeFocus(
    val displayName: String,
    val description: String,
    val handType: HandType
) {
    HARD_TOTALS(
        displayName = "Hard Totals",
        description = "Standing/hitting patterns",
        handType = HandType.HARD
    ),
    SOFT_TOTALS(
        displayName = "Soft Totals", 
        description = "Ace strategies and doubling",
        handType = HandType.SOFT
    ),
    PAIRS(
        displayName = "Pairs",
        description = "Split decision logic",
        handType = HandType.PAIR
    )
}

/**
 * Training session configuration
 */
data class TrainingSessionConfig(
    val sessionType: TrainingSessionType,
    val difficulty: DifficultyLevel = DifficultyLevel.NORMAL,
    val dealerStrength: DealerStrength? = null,
    val handTypeFocus: HandTypeFocus? = null,
    val maxQuestions: Int = sessionType.maxQuestions
) {
    companion object {
        fun random(difficulty: DifficultyLevel = DifficultyLevel.NORMAL): TrainingSessionConfig {
            return TrainingSessionConfig(
                sessionType = TrainingSessionType.RANDOM,
                difficulty = difficulty
            )
        }
        
        fun dealerGroup(
            strength: DealerStrength,
            difficulty: DifficultyLevel = DifficultyLevel.NORMAL
        ): TrainingSessionConfig {
            return TrainingSessionConfig(
                sessionType = TrainingSessionType.DEALER_GROUP,
                difficulty = difficulty,
                dealerStrength = strength
            )
        }
        
        fun handType(
            focus: HandTypeFocus,
            difficulty: DifficultyLevel = DifficultyLevel.NORMAL
        ): TrainingSessionConfig {
            return TrainingSessionConfig(
                sessionType = TrainingSessionType.HAND_TYPE,
                difficulty = difficulty,
                handTypeFocus = focus
            )
        }
        
        fun absolutes(difficulty: DifficultyLevel = DifficultyLevel.NORMAL): TrainingSessionConfig {
            return TrainingSessionConfig(
                sessionType = TrainingSessionType.ABSOLUTES,
                difficulty = difficulty
            )
        }
    }
}