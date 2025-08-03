package net.kristopherjohnson.blackjacktrainer.domain.repository

import net.kristopherjohnson.blackjacktrainer.domain.model.*

/**
 * Repository for generating training scenarios
 */
interface ScenarioRepository {
    
    /**
     * Generate a random scenario for training
     */
    suspend fun generateRandomScenario(difficulty: DifficultyLevel = DifficultyLevel.NORMAL): GameScenario
    
    /**
     * Generate a scenario focused on specific dealer strength
     */
    suspend fun generateDealerStrengthScenario(
        strength: DealerStrength,
        difficulty: DifficultyLevel = DifficultyLevel.NORMAL
    ): GameScenario
    
    /**
     * Generate a scenario focused on specific hand type
     */
    suspend fun generateHandTypeScenario(
        handType: HandTypeFocus,
        difficulty: DifficultyLevel = DifficultyLevel.NORMAL
    ): GameScenario
    
    /**
     * Generate an absolute rules scenario (always/never situations)
     */
    suspend fun generateAbsoluteScenario(difficulty: DifficultyLevel = DifficultyLevel.NORMAL): GameScenario
}