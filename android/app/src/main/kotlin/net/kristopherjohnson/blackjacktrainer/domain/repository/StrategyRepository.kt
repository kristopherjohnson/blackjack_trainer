package net.kristopherjohnson.blackjacktrainer.domain.repository

import net.kristopherjohnson.blackjacktrainer.domain.model.Action
import net.kristopherjohnson.blackjacktrainer.domain.model.GameScenario

/**
 * Repository for accessing blackjack strategy data
 */
interface StrategyRepository {
    
    /**
     * Get the correct action for a given scenario
     */
    suspend fun getCorrectAction(scenario: GameScenario): Result<Action>
    
    /**
     * Get explanation/mnemonic for a scenario
     */
    suspend fun getExplanation(scenario: GameScenario): String
    
    /**
     * Check if a given action is correct for the scenario
     */
    suspend fun isCorrectAction(scenario: GameScenario, action: Action): Boolean
}