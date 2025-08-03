package net.kristopherjohnson.blackjacktrainer.domain.usecase

import kotlinx.coroutines.flow.Flow
import net.kristopherjohnson.blackjacktrainer.domain.model.SessionStatistics
import net.kristopherjohnson.blackjacktrainer.domain.repository.StatisticsRepository
import javax.inject.Inject

/**
 * Use case for accessing session statistics
 */
class GetSessionStatisticsUseCase @Inject constructor(
    private val statisticsRepository: StatisticsRepository
) {
    
    operator fun invoke(): Flow<SessionStatistics> {
        return statisticsRepository.getSessionStatistics()
    }
}