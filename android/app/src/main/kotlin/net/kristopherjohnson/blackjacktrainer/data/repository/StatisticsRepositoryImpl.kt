package net.kristopherjohnson.blackjacktrainer.data.repository

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import net.kristopherjohnson.blackjacktrainer.domain.model.SessionStatistics
import net.kristopherjohnson.blackjacktrainer.domain.repository.StatisticsRepository
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Implementation of StatisticsRepository using in-memory session data
 * No persistence - all data lost when app terminates
 */
@Singleton
class StatisticsRepositoryImpl @Inject constructor() : StatisticsRepository {
    
    private val _sessionStatistics = MutableStateFlow(SessionStatistics())
    
    override fun getSessionStatistics(): Flow<SessionStatistics> {
        return _sessionStatistics.asStateFlow()
    }
    
    override suspend fun recordAttempt(category: String, isCorrect: Boolean) {
        val current = _sessionStatistics.value
        current.recordAttempt(category, isCorrect)
        // Trigger flow update by creating new instance
        _sessionStatistics.value = current.copy()
    }
    
    override suspend fun resetSession() {
        _sessionStatistics.value = SessionStatistics()
    }
    
    override suspend fun getCurrentSessionId(): String {
        return _sessionStatistics.value.sessionId
    }
}