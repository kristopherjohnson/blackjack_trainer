package net.kristopherjohnson.blackjacktrainer.domain.usecase

import net.kristopherjohnson.blackjacktrainer.domain.model.Action
import net.kristopherjohnson.blackjacktrainer.domain.model.GameScenario
import net.kristopherjohnson.blackjacktrainer.domain.model.SessionStatistics
import net.kristopherjohnson.blackjacktrainer.domain.repository.StatisticsRepository
import net.kristopherjohnson.blackjacktrainer.domain.repository.StrategyRepository
import javax.inject.Inject

/**
 * Use case for checking user answers and recording statistics
 */
class CheckAnswerUseCase @Inject constructor(
    private val strategyRepository: StrategyRepository,
    private val statisticsRepository: StatisticsRepository
) {
    
    suspend operator fun invoke(
        scenario: GameScenario,
        userAction: Action
    ): AnswerResult {
        val correctActionResult = strategyRepository.getCorrectAction(scenario)
        val correctAction = correctActionResult.getOrNull()
            ?: return AnswerResult.Error("Unable to determine correct action")
        
        val isCorrect = userAction == correctAction
        val explanation = if (!isCorrect) {
            strategyRepository.getExplanation(scenario)
        } else {
            "Correct!"
        }
        
        // Record attempt in statistics
        val category = getCategoryForScenario(scenario)
        statisticsRepository.recordAttempt(category, isCorrect)
        
        return AnswerResult.Success(
            isCorrect = isCorrect,
            correctAction = correctAction,
            userAction = userAction,
            explanation = explanation
        )
    }
    
    private fun getCategoryForScenario(scenario: GameScenario): String {
        return when (scenario.handType) {
            net.kristopherjohnson.blackjacktrainer.domain.model.HandType.HARD -> SessionStatistics.CATEGORY_HARD_TOTALS
            net.kristopherjohnson.blackjacktrainer.domain.model.HandType.SOFT -> SessionStatistics.CATEGORY_SOFT_TOTALS
            net.kristopherjohnson.blackjacktrainer.domain.model.HandType.PAIR -> SessionStatistics.CATEGORY_PAIRS
        }
    }
}

/**
 * Result of checking an answer
 */
sealed class AnswerResult {
    data class Success(
        val isCorrect: Boolean,
        val correctAction: Action,
        val userAction: Action,
        val explanation: String
    ) : AnswerResult()
    
    data class Error(val message: String) : AnswerResult()
}