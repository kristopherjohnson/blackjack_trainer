package net.kristopherjohnson.blackjacktrainer.data.model

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import net.kristopherjohnson.blackjacktrainer.domain.model.*
import timber.log.Timber

/**
 * Complete basic strategy chart implementation
 * Based on blackjack_basic_strategy.md specification
 */
data class StrategyChart(
    val hardTotals: Map<HandKey, Action>,
    val softTotals: Map<HandKey, Action>,
    val pairs: Map<HandKey, Action>,
    val mnemonics: Map<String, String>,
    val dealerGroups: Map<DealerStrength, List<Int>>,
    val version: Int = 1
) {
    
    /**
     * Get the correct action for a given scenario
     */
    suspend fun getCorrectAction(scenario: GameScenario): Result<Action> = withContext(Dispatchers.Default) {
        try {
            val key = HandKey(scenario.playerTotal, scenario.dealerCard.value)
            val action = when (scenario.handType) {
                HandType.HARD -> hardTotals[key]
                HandType.SOFT -> softTotals[key]
                HandType.PAIR -> pairs[key]
            }
            
            action?.let { Result.success(it) } 
                ?: Result.failure(
                    StrategyException.InvalidScenario(
                        "No strategy found for ${scenario.handType} ${scenario.playerTotal} vs ${scenario.dealerCard.displayValue}",
                        scenario.copy()
                    )
                )
        } catch (e: Exception) {
            Timber.e(e, "Strategy lookup failed for scenario: $scenario")
            Result.failure(StrategyException.DataCorruption("Strategy data corrupted", e))
        }
    }
    
    /**
     * Get explanation/mnemonic for a scenario
     */
    fun getExplanation(scenario: GameScenario): String {
        val key = "${scenario.handType}-${scenario.playerTotal}-${scenario.dealerCard.value}"
        return mnemonics[key] ?: getGeneralExplanation(scenario)
    }
    
    private fun getGeneralExplanation(scenario: GameScenario): String {
        return when (scenario.handType) {
            HandType.HARD -> when {
                scenario.playerTotal <= 8 -> "Always hit low hard totals"
                scenario.playerTotal >= 17 -> "Always stand on hard 17+"
                scenario.dealerCard.value in 4..6 -> "Dealer has bust card - be conservative"
                scenario.dealerCard.value >= 9 -> "Dealer is strong - hit to improve"
                else -> "Follow basic strategy patterns"
            }
            HandType.SOFT -> when {
                scenario.playerTotal >= 19 -> "Always stand on soft 19+"
                scenario.dealerCard.value in 4..6 -> "Double against dealer bust cards"
                else -> "Soft hands are flexible - be aggressive"
            }
            HandType.PAIR -> when {
                scenario.playerTotal == 22 -> "Always split Aces"
                scenario.playerTotal == 16 && scenario.playerCards.first().rank == Rank.EIGHT -> "Always split 8s"
                scenario.playerTotal == 20 -> "Never split 10s"
                else -> "Consider dealer strength for split decisions"
            }
        }
    }
    
    companion object {
        fun createDefault(): StrategyChart {
            return StrategyChart(
                hardTotals = initializeHardTotals(),
                softTotals = initializeSoftTotals(),
                pairs = initializePairs(),
                mnemonics = initializeMnemonics(),
                dealerGroups = mapOf(
                    DealerStrength.WEAK to listOf(4, 5, 6),
                    DealerStrength.MEDIUM to listOf(2, 3, 7, 8),
                    DealerStrength.STRONG to listOf(9, 10, 11)
                )
            )
        }
        
        private fun initializeHardTotals(): Map<HandKey, Action> {
            val strategy = mutableMapOf<HandKey, Action>()
            
            // 8 or less - Always Hit
            for (total in 5..8) {
                for (dealer in 2..11) {
                    strategy[HandKey(total, dealer)] = Action.HIT
                }
            }
            
            // 9 - Hit except double vs 3-6
            for (dealer in 2..11) {
                strategy[HandKey(9, dealer)] = when (dealer) {
                    3, 4, 5, 6 -> Action.DOUBLE
                    else -> Action.HIT
                }
            }
            
            // 10 - Double vs 2-9, Hit vs 10,A
            for (dealer in 2..11) {
                strategy[HandKey(10, dealer)] = when (dealer) {
                    10, 11 -> Action.HIT
                    else -> Action.DOUBLE
                }
            }
            
            // 11 - Double vs 2-10, Hit vs A
            for (dealer in 2..11) {
                strategy[HandKey(11, dealer)] = when (dealer) {
                    11 -> Action.HIT
                    else -> Action.DOUBLE
                }
            }
            
            // 12 - Stand vs 4-6, Hit vs rest
            for (dealer in 2..11) {
                strategy[HandKey(12, dealer)] = when (dealer) {
                    4, 5, 6 -> Action.STAND
                    else -> Action.HIT
                }
            }
            
            // 13-16 - Stand vs 2-6, Hit vs 7-A
            for (total in 13..16) {
                for (dealer in 2..11) {
                    strategy[HandKey(total, dealer)] = when (dealer) {
                        2, 3, 4, 5, 6 -> Action.STAND
                        else -> Action.HIT
                    }
                }
            }
            
            // 17+ - Always Stand
            for (total in 17..21) {
                for (dealer in 2..11) {
                    strategy[HandKey(total, dealer)] = Action.STAND
                }
            }
            
            return strategy
        }
        
        private fun initializeSoftTotals(): Map<HandKey, Action> {
            val strategy = mutableMapOf<HandKey, Action>()
            
            // A,2 (13) - Hit except Double vs 5,6
            for (dealer in 2..11) {
                strategy[HandKey(13, dealer)] = when (dealer) {
                    5, 6 -> Action.DOUBLE
                    else -> Action.HIT
                }
            }
            
            // A,3 (14) - Hit except Double vs 5,6
            for (dealer in 2..11) {
                strategy[HandKey(14, dealer)] = when (dealer) {
                    5, 6 -> Action.DOUBLE
                    else -> Action.HIT
                }
            }
            
            // A,4 (15) - Hit except Double vs 4,5,6
            for (dealer in 2..11) {
                strategy[HandKey(15, dealer)] = when (dealer) {
                    4, 5, 6 -> Action.DOUBLE
                    else -> Action.HIT
                }
            }
            
            // A,5 (16) - Hit except Double vs 4,5,6
            for (dealer in 2..11) {
                strategy[HandKey(16, dealer)] = when (dealer) {
                    4, 5, 6 -> Action.DOUBLE
                    else -> Action.HIT
                }
            }
            
            // A,6 (17) - Hit except Double vs 3,4,5,6
            for (dealer in 2..11) {
                strategy[HandKey(17, dealer)] = when (dealer) {
                    3, 4, 5, 6 -> Action.DOUBLE
                    else -> Action.HIT
                }
            }
            
            // A,7 (18) - Stand vs 2,7,8; Double vs 3,4,5,6; Hit vs 9,10,A
            for (dealer in 2..11) {
                strategy[HandKey(18, dealer)] = when (dealer) {
                    2, 7, 8 -> Action.STAND
                    3, 4, 5, 6 -> Action.DOUBLE
                    9, 10, 11 -> Action.HIT
                    else -> Action.STAND
                }
            }
            
            // A,8 (19) - Always Stand
            for (dealer in 2..11) {
                strategy[HandKey(19, dealer)] = Action.STAND
            }
            
            // A,9 (20) - Always Stand
            for (dealer in 2..11) {
                strategy[HandKey(20, dealer)] = Action.STAND
            }
            
            return strategy
        }
        
        private fun initializePairs(): Map<HandKey, Action> {
            val strategy = mutableMapOf<HandKey, Action>()
            
            // A,A - Always Split
            for (dealer in 2..11) {
                strategy[HandKey(22, dealer)] = Action.SPLIT
            }
            
            // 10,10 - Never Split
            for (dealer in 2..11) {
                strategy[HandKey(20, dealer)] = Action.NO_SPLIT
            }
            
            // 9,9 - Split vs 2-6,8,9; Don't split vs 7,10,A
            for (dealer in 2..11) {
                strategy[HandKey(18, dealer)] = when (dealer) {
                    7, 10, 11 -> Action.NO_SPLIT
                    else -> Action.SPLIT
                }
            }
            
            // 8,8 - Always Split
            for (dealer in 2..11) {
                strategy[HandKey(16, dealer)] = Action.SPLIT
            }
            
            // 7,7 - Split vs 2-7; Don't split vs 8-A
            for (dealer in 2..11) {
                strategy[HandKey(14, dealer)] = when (dealer) {
                    2, 3, 4, 5, 6, 7 -> Action.SPLIT
                    else -> Action.NO_SPLIT
                }
            }
            
            // 6,6 - Split vs 2-6; Don't split vs 7-A
            for (dealer in 2..11) {
                strategy[HandKey(12, dealer)] = when (dealer) {
                    2, 3, 4, 5, 6 -> Action.SPLIT
                    else -> Action.NO_SPLIT
                }
            }
            
            // 5,5 - Never Split
            for (dealer in 2..11) {
                strategy[HandKey(10, dealer)] = Action.NO_SPLIT
            }
            
            // 4,4 - Don't split except vs 5,6
            for (dealer in 2..11) {
                strategy[HandKey(8, dealer)] = when (dealer) {
                    5, 6 -> Action.SPLIT
                    else -> Action.NO_SPLIT
                }
            }
            
            // 3,3 - Split vs 2-7; Don't split vs 8-A
            for (dealer in 2..11) {
                strategy[HandKey(6, dealer)] = when (dealer) {
                    2, 3, 4, 5, 6, 7 -> Action.SPLIT
                    else -> Action.NO_SPLIT
                }
            }
            
            // 2,2 - Split vs 2-7; Don't split vs 8-A
            for (dealer in 2..11) {
                strategy[HandKey(4, dealer)] = when (dealer) {
                    2, 3, 4, 5, 6, 7 -> Action.SPLIT
                    else -> Action.NO_SPLIT
                }
            }
            
            return strategy
        }
        
        private fun initializeMnemonics(): Map<String, String> {
            return mapOf(
                // Hard totals
                "HARD-9-3" to "Double 9 vs dealer weak cards (3-6)",
                "HARD-10-10" to "Don't double 10 vs dealer 10 or Ace",
                "HARD-11-11" to "Don't double 11 vs dealer Ace",
                "HARD-12-4" to "Stand 12 vs dealer bust cards (4-6)",
                "HARD-16-7" to "Hit 16 vs dealer strong cards (7+)",
                
                // Soft totals
                "SOFT-18-9" to "A,7 is tricky - hit vs strong dealer cards",
                "SOFT-17-3" to "Double soft 17 vs dealer weak cards",
                
                // Pairs
                "PAIR-22-2" to "Aces and eights, don't hesitate",
                "PAIR-16-2" to "Always split 8s - turn disaster into opportunity",
                "PAIR-20-2" to "Never split 10s - 20 is too good to break up",
                "PAIR-18-7" to "Don't split 9s vs 7 - 18 vs 7 is good",
                
                // General patterns
                "dealer_weak" to "Dealer bust cards (4,5,6) = player gets greedy",
                "dealer_strong" to "Dealer strong (9,10,A) = player plays conservatively",
                "always_split" to "Always split Aces and 8s",
                "never_split" to "Never split 10s and 5s",
                "teens_vs_strong" to "Teen totals (13-16) flee from strong dealer cards"
            )
        }
    }
}

/**
 * Key for strategy lookup
 */
data class HandKey(
    val playerTotal: Int,
    val dealerCard: Int
)

/**
 * Strategy-related exceptions
 */
sealed class StrategyException(message: String, cause: Throwable? = null) : Exception(message, cause) {
    data class InvalidScenario(val details: String, val scenario: GameScenario) : StrategyException(details)
    data class DataCorruption(val details: String, override val cause: Throwable) : StrategyException(details, cause)
}