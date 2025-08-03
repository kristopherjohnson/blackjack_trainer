package net.kristopherjohnson.blackjacktrainer.domain.repository

import kotlinx.coroutines.flow.Flow
import net.kristopherjohnson.blackjacktrainer.domain.model.SessionStatistics

/**
 * Repository for managing session statistics (session-only, no persistence)
 */
interface StatisticsRepository {
    
    /**
     * Get current session statistics as a flow
     */
    fun getSessionStatistics(): Flow<SessionStatistics>
    
    /**
     * Record an attempt in the current session
     */
    suspend fun recordAttempt(category: String, isCorrect: Boolean)
    
    /**
     * Reset current session statistics
     */
    suspend fun resetSession()
    
    /**
     * Get current session ID
     */
    suspend fun getCurrentSessionId(): String
}