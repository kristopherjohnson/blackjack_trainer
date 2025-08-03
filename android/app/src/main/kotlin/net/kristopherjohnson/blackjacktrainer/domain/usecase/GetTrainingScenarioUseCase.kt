package net.kristopherjohnson.blackjacktrainer.domain.usecase

import net.kristopherjohnson.blackjacktrainer.domain.model.*
import net.kristopherjohnson.blackjacktrainer.domain.repository.ScenarioRepository
import javax.inject.Inject

/**
 * Use case for generating training scenarios based on session configuration
 */
class GetTrainingScenarioUseCase @Inject constructor(
    private val scenarioRepository: ScenarioRepository
) {
    
    suspend operator fun invoke(config: TrainingSessionConfig): GameScenario {
        return when (config.sessionType) {
            TrainingSessionType.RANDOM -> {
                scenarioRepository.generateRandomScenario(config.difficulty)
            }
            TrainingSessionType.DEALER_GROUP -> {
                val strength = config.dealerStrength 
                    ?: throw IllegalArgumentException("Dealer strength required for dealer group session")
                scenarioRepository.generateDealerStrengthScenario(strength, config.difficulty)
            }
            TrainingSessionType.HAND_TYPE -> {
                val handType = config.handTypeFocus
                    ?: throw IllegalArgumentException("Hand type focus required for hand type session")
                scenarioRepository.generateHandTypeScenario(handType, config.difficulty)
            }
            TrainingSessionType.ABSOLUTES -> {
                scenarioRepository.generateAbsoluteScenario(config.difficulty)
            }
        }
    }
}