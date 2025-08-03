package net.kristopherjohnson.blackjacktrainer.domain.model

import java.util.UUID

/**
 * Session-only statistics - no persistence
 * All data exists only in memory during app execution
 */
data class SessionStatistics(
    val sessionId: String = UUID.randomUUID().toString(),
    val startTime: Long = System.currentTimeMillis(),
    var lastActivityTime: Long = System.currentTimeMillis(),
    val attempts: MutableMap<String, AttemptRecord> = mutableMapOf(),
    var correctCount: Int = 0,
    var totalCount: Int = 0
) {
    
    /**
     * Record an attempt for a specific category
     */
    fun recordAttempt(category: String, isCorrect: Boolean) {
        val record = attempts.getOrPut(category) { AttemptRecord() }
        record.totalAttempts++
        if (isCorrect) {
            record.correctAttempts++
            correctCount++
        }
        totalCount++
        lastActivityTime = System.currentTimeMillis()
    }
    
    /**
     * Get accuracy for a category or overall
     */
    fun getAccuracy(category: String? = null): Float {
        return if (category != null) {
            attempts[category]?.let { 
                if (it.totalAttempts > 0) it.correctAttempts.toFloat() / it.totalAttempts else 0f 
            } ?: 0f
        } else {
            if (totalCount > 0) correctCount.toFloat() / totalCount else 0f
        }
    }
    
    /**
     * Get percentage accuracy for display
     */
    fun getAccuracyPercentage(category: String? = null): Int {
        return (getAccuracy(category) * 100).toInt()
    }
    
    /**
     * Check if session has expired due to inactivity
     */
    fun isExpired(): Boolean {
        return System.currentTimeMillis() - lastActivityTime > SESSION_TIMEOUT_MS
    }
    
    /**
     * Get session duration in milliseconds
     */
    fun getSessionDuration(): Long {
        return lastActivityTime - startTime
    }
    
    /**
     * Get session duration in human-readable format
     */
    fun getSessionDurationString(): String {
        val duration = getSessionDuration()
        val minutes = duration / 60_000
        val seconds = (duration % 60_000) / 1_000
        return "${minutes}m ${seconds}s"
    }
    
    /**
     * Get attempts per category for detailed breakdown
     */
    fun getCategoryBreakdown(): Map<String, AttemptRecord> {
        return attempts.toMap()
    }
    
    /**
     * Reset all statistics while keeping session metadata
     */
    fun reset() {
        attempts.clear()
        correctCount = 0
        totalCount = 0
        lastActivityTime = System.currentTimeMillis()
    }
    
    companion object {
        private const val SESSION_TIMEOUT_MS = 60 * 60 * 1000L // 1 hour
        
        // Standard categories for tracking
        const val CATEGORY_HARD_TOTALS = "hard_totals"
        const val CATEGORY_SOFT_TOTALS = "soft_totals"
        const val CATEGORY_PAIRS = "pairs"
        const val CATEGORY_DEALER_WEAK = "dealer_weak"
        const val CATEGORY_DEALER_MEDIUM = "dealer_medium"
        const val CATEGORY_DEALER_STRONG = "dealer_strong"
        const val CATEGORY_ABSOLUTES = "absolutes"
    }
}

/**
 * Record of attempts for a specific category
 */
data class AttemptRecord(
    var correctAttempts: Int = 0,
    var totalAttempts: Int = 0
) {
    fun getAccuracy(): Float {
        return if (totalAttempts > 0) correctAttempts.toFloat() / totalAttempts else 0f
    }
    
    fun getAccuracyPercentage(): Int {
        return (getAccuracy() * 100).toInt()
    }
}