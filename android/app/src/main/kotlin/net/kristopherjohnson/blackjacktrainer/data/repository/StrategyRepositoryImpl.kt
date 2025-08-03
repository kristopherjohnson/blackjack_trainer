package net.kristopherjohnson.blackjacktrainer.data.repository

import net.kristopherjohnson.blackjacktrainer.data.model.StrategyChart
import net.kristopherjohnson.blackjacktrainer.domain.model.Action
import net.kristopherjohnson.blackjacktrainer.domain.model.GameScenario
import net.kristopherjohnson.blackjacktrainer.domain.repository.StrategyRepository
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Implementation of StrategyRepository using in-memory StrategyChart
 */
@Singleton
class StrategyRepositoryImpl @Inject constructor() : StrategyRepository {
    
    private val strategyChart = StrategyChart.createDefault()
    
    override suspend fun getCorrectAction(scenario: GameScenario): Result<Action> {
        return strategyChart.getCorrectAction(scenario)
    }
    
    override suspend fun getExplanation(scenario: GameScenario): String {
        return strategyChart.getExplanation(scenario)
    }
    
    override suspend fun isCorrectAction(scenario: GameScenario, action: Action): Boolean {
        return getCorrectAction(scenario).getOrNull() == action
    }
}