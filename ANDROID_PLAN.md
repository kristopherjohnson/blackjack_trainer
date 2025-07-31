# Android Blackjack Strategy Trainer - Expert Implementation Plan

This document outlines a comprehensive plan for creating a market-leading, production-ready Android blackjack strategy trainer using modern Android development best practices, expert architecture patterns, and advanced platform integrations. Based on the proven Python implementation, this plan leverages cutting-edge Android technologies to create a premium user experience.

## Expert Project Analysis & Android Enhancement Strategy

The Python implementation provides a mathematically sound foundation that we'll enhance with advanced Android capabilities:

### Core Strengths to Preserve
- **StrategyChart**: Complete basic strategy tables with mnemonics (enhanced with in-memory optimization)
- **TrainingSession**: Abstract base class with 4 concrete implementations (enhanced with Kotlin sealed classes and coroutines)
- **Statistics**: Progress tracking and performance analytics (enhanced with Flow-based reactive programming)
- **Clean Architecture**: Well-separated concerns (enhanced with modern MVVM + Repository pattern)

### Android-Specific Enhancements
- **Performance**: Object pooling, memory leak prevention, battery optimization
- **User Experience**: Material Design 3, adaptive layouts, haptic feedback, accessibility-first design
- **Platform Integration**: Widgets, shortcuts, Wear OS, notifications, voice commands
- **Production Readiness**: Crash reporting, analytics, security hardening, Play Store optimization

## Android App Architecture (MVVM + Jetpack Compose)

### Enhanced Data Layer - Session-Only Implementation

```kotlin
// Enhanced strategy data models with in-memory optimization and session persistence
data class StrategyChart(
    val hardTotals: Map<HandKey, Action>,
    val softTotals: Map<HandKey, Action>,
    val pairs: Map<HandKey, Action>,
    val mnemonics: Map<String, String>,
    val dealerGroups: Map<DealerStrength, List<Int>>,
    val version: Int = 1 // For future strategy updates
) {
    @WorkerThread
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
    
    fun getExplanation(scenario: GameScenario): String {
        return mnemonics["${scenario.handType}-${scenario.playerTotal}-${scenario.dealerCard.value}"] 
            ?: "Follow basic strategy patterns"
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
    }
}

// Session-only statistics with SharedPreferences backup during app lifecycle
data class SessionStatistics(
    val sessionId: String = UUID.randomUUID().toString(),
    val startTime: Long = System.currentTimeMillis(),
    var lastActivityTime: Long = System.currentTimeMillis(),
    val attempts: MutableMap<String, AttemptRecord> = mutableMapOf(),
    var correctCount: Int = 0,
    var totalCount: Int = 0
) {
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
    
    fun getAccuracy(category: String? = null): Float {
        return if (category != null) {
            attempts[category]?.let { 
                if (it.totalAttempts > 0) it.correctAttempts.toFloat() / it.totalAttempts else 0f 
            } ?: 0f
        } else {
            if (totalCount > 0) correctCount.toFloat() / totalCount else 0f
        }
    }
    
    fun isExpired(): Boolean {
        return System.currentTimeMillis() - lastActivityTime > SESSION_TIMEOUT_MS
    }
    
    companion object {
        private const val SESSION_TIMEOUT_MS = 60 * 60 * 1000L // 1 hour
    }
}

data class AttemptRecord(
    var correctAttempts: Int = 0,
    var totalAttempts: Int = 0
)

// Session persistence manager using SharedPreferences
class SessionPersistenceManager @Inject constructor(
    private val context: Context
) {
    private val preferences: SharedPreferences = context.getSharedPreferences(
        "blackjack_trainer_session", 
        Context.MODE_PRIVATE
    )
    private val gson = Gson()
    
    fun saveSession(statistics: SessionStatistics) {
        preferences.edit()
            .putString(KEY_SESSION_DATA, gson.toJson(statistics))
            .putLong(KEY_LAST_SAVE, System.currentTimeMillis())
            .apply()
    }
    
    fun loadSession(): SessionStatistics? {
        val sessionData = preferences.getString(KEY_SESSION_DATA, null) ?: return null
        return try {
            val statistics = gson.fromJson(sessionData, SessionStatistics::class.java)
            if (statistics.isExpired()) {
                clearSession()
                null
            } else {
                statistics
            }
        } catch (e: Exception) {
            Timber.w(e, "Failed to load session data")
            clearSession()
            null
        }
    }
    
    fun clearSession() {
        preferences.edit().clear().apply()
    }
    
    companion object {
        private const val KEY_SESSION_DATA = "session_statistics"
        private const val KEY_LAST_SAVE = "last_save_time"
    }
}

// Enhanced game state models with comprehensive metadata
data class GameScenario(
    val id: String = UUID.randomUUID().toString(),
    val handType: HandType,
    val playerCards: List<Card>,
    val playerTotal: Int,
    val dealerCard: Card,
    val difficulty: DifficultyLevel = DifficultyLevel.NORMAL,
    val sessionId: String? = null,
    val timestamp: Long = System.currentTimeMillis(),
    val metadata: ScenarioMetadata = ScenarioMetadata()
) {
    companion object {
        fun empty() = GameScenario(
            handType = HandType.HARD,
            playerCards = emptyList(),
            playerTotal = 0,
            dealerCard = Card.ACE_SPADES
        )
    }
}

data class ScenarioMetadata(
    val isAbsoluteRule: Boolean = false,
    val complexity: ComplexityLevel = ComplexityLevel.BASIC,
    val mnemonicHint: String? = null,
    val expectedDifficulty: Double = 0.5,
    val tags: Set<String> = emptySet()
)

enum class DifficultyLevel(val displayName: String, val multiplier: Double) {
    BEGINNER("Beginner", 0.7),
    NORMAL("Normal", 1.0),
    ADVANCED("Advanced", 1.3),
    EXPERT("Expert", 1.6)
}

enum class ComplexityLevel {
    BASIC,      // Clear-cut decisions
    MODERATE,   // Some edge cases
    COMPLEX,    // Multiple valid strategies
    EXPERT      // Requires deep understanding
}

// Enhanced action enum with comprehensive accessibility and internationalization support
enum class Action(
    val displayName: String, 
    val accessibilityLabel: String,
    val shortCode: String,
    val keyboardShortcut: Char,
    val description: String,
    @ColorInt val themeColor: Long = 0xFF1976D2
) {
    HIT(
        displayName = "Hit", 
        accessibilityLabel = "Hit - Take another card from the dealer",
        shortCode = "H",
        keyboardShortcut = 'h',
        description = "Request another card to improve your hand total",
        themeColor = 0xFF2196F3
    ),
    STAND(
        displayName = "Stand", 
        accessibilityLabel = "Stand - Keep your current hand and end your turn",
        shortCode = "S",
        keyboardShortcut = 's',
        description = "Keep your current hand and let the dealer play",
        themeColor = 0xFF4CAF50
    ),
    DOUBLE(
        displayName = "Double", 
        accessibilityLabel = "Double Down - Double your bet and take exactly one more card",
        shortCode = "D",
        keyboardShortcut = 'd',
        description = "Double your bet and receive exactly one more card",
        themeColor = 0xFFFF9800
    ),
    SPLIT(
        displayName = "Split", 
        accessibilityLabel = "Split Pair - Separate your pair into two hands",
        shortCode = "Y",
        keyboardShortcut = 'p',
        description = "Separate your pair into two hands with equal bets",
        themeColor = 0xFF9C27B0
    );
    
    companion object {
        fun fromString(value: String): Action? = when (value.uppercase().trim()) {
            "H", "HIT" -> HIT
            "S", "STAND", "STAY" -> STAND
            "D", "DOUBLE", "DOUBLE DOWN" -> DOUBLE
            "Y", "P", "SPLIT" -> SPLIT
            else -> null
        }
        
        fun fromKeyboardShortcut(key: Char): Action? = 
            values().find { it.keyboardShortcut.equals(key, ignoreCase = true) }
            
        fun getRecommendedActions(scenario: GameScenario): List<Action> {
            return when (scenario.handType) {
                HandType.PAIR -> listOf(SPLIT, HIT, STAND)
                HandType.SOFT -> if (scenario.playerTotal <= 11) listOf(HIT, DOUBLE) else listOf(HIT, STAND, DOUBLE)
                HandType.HARD -> when {
                    scenario.playerTotal <= 11 -> listOf(HIT, DOUBLE)
                    scenario.playerTotal >= 17 -> listOf(STAND)
                    else -> listOf(HIT, STAND, DOUBLE)
                }
            }
        }
    }
}

// Enhanced exception handling with detailed context and recovery suggestions
// Enhanced exception hierarchy with recovery strategies and user-friendly messages
sealed class StrategyException(message: String, cause: Throwable? = null) : Exception(message, cause) {
    abstract val userMessage: String
    abstract val recoveryAction: RecoveryAction
    abstract val severity: ErrorSeverity
    
    data class InvalidScenario(
        val details: String,
        val scenario: GameScenario,
        val suggestedAction: Action? = null
    ) : StrategyException("Invalid scenario: $details") {
        override val userMessage: String = "This hand combination isn't recognized. Please try again."
        override val recoveryAction: RecoveryAction = RecoveryAction.RETRY_WITH_NEW_SCENARIO
        override val severity: ErrorSeverity = ErrorSeverity.LOW
    }
    
    data class DataCorruption(
        val details: String,
        override val cause: Throwable? = null
    ) : StrategyException("Strategy data corrupted: $details", cause) {
        override val userMessage: String = "Strategy data needs to be refreshed. This will happen automatically."
        override val recoveryAction: RecoveryAction = RecoveryAction.REINITIALIZE_DATA
        override val severity: ErrorSeverity = ErrorSeverity.MEDIUM
    }
    
    data class NetworkError(
        val details: String,
        override val cause: Throwable? = null
    ) : StrategyException("Network operation failed: $details", cause) {
        override val userMessage: String = "Network connection issue. Working offline with cached data."
        override val recoveryAction: RecoveryAction = RecoveryAction.USE_CACHED_DATA
        override val severity: ErrorSeverity = ErrorSeverity.LOW
    }
    
    data class DatabaseError(
        val operation: String,
        override val cause: Throwable? = null
    ) : StrategyException("Database operation '$operation' failed", cause) {
        override val userMessage: String = "Data storage issue. Your progress is still saved."
        override val recoveryAction: RecoveryAction = RecoveryAction.RETRY_DATABASE_OPERATION
        override val severity: ErrorSeverity = ErrorSeverity.MEDIUM
    }
    
    data class PerformanceIssue(
        val operation: String,
        val duration: Long
    ) : StrategyException("Performance issue: $operation took ${duration}ms") {
        override val userMessage: String = "Performance optimization in progress..."
        override val recoveryAction: RecoveryAction = RecoveryAction.OPTIMIZE_PERFORMANCE
        override val severity: ErrorSeverity = ErrorSeverity.LOW
    }
}

enum class RecoveryAction {
    RETRY_WITH_NEW_SCENARIO,
    REINITIALIZE_DATA,
    USE_CACHED_DATA,
    RETRY_DATABASE_OPERATION,
    OPTIMIZE_PERFORMANCE,
    RESTART_SESSION,
    CONTACT_SUPPORT
}

enum class ErrorSeverity {
    LOW,     // User can continue normally
    MEDIUM,  // Some features may be limited
    HIGH,    // Major functionality affected
    CRITICAL // App must restart or close
}
```

### Enhanced Repository Pattern with Advanced Dependency Injection & Performance Optimization

```kotlin
// Enhanced strategy repository interface with in-memory optimization and session management
interface StrategyRepository {
    suspend fun getCorrectAction(scenario: GameScenario): Result<Action>
    suspend fun getExplanation(scenario: GameScenario): String
    suspend fun getMnemonic(scenario: GameScenario): String?
    suspend fun initializeStrategy(): Result<Unit>
    fun getStrategyMetrics(): Flow<StrategyMetrics>
    suspend fun prefetchCommonScenarios(sessionType: SessionType)
}

data class StrategyMetrics(
    val cacheHitRate: Double,
    val averageResponseTime: Long,
    val totalLookups: Long,
    val errorRate: Double,
    val lastRefresh: Long
)

@Singleton
class StrategyRepositoryImpl @Inject constructor(
    private val performanceMonitor: PerformanceMonitor,
    private val errorReporter: ErrorReporter,
    @DefaultDispatcher private val defaultDispatcher: CoroutineDispatcher
) : StrategyRepository {
    
    private var cachedStrategy: StrategyChart? = null
    private val actionCache = LruCache<String, Action>(500) // Cache for 500 most recent lookups
    private val explanationCache = LruCache<String, String>(200)
    private val _strategyMetrics = MutableStateFlow(StrategyMetrics(
        cacheHitRate = 0.0,
        averageResponseTime = 0L,
        totalLookups = 0L,
        errorRate = 0.0,
        lastRefresh = System.currentTimeMillis()
    ))
    private val metricsLock = Mutex()
    
    private fun getCacheKey(scenario: GameScenario): String = 
        "${scenario.handType}-${scenario.playerTotal}-${scenario.dealerCard.value}"
    
    override suspend fun initializeStrategy(): Result<Unit> = withContext(defaultDispatcher) {
        try {
            // Initialize with default strategy in memory
            cachedStrategy = StrategyChart.createDefault()
            Result.success(Unit)
        } catch (e: Exception) {
            errorReporter.reportError("strategy_initialization_failed", e)
            Result.failure(e)
        }
    }
    
    override suspend fun getCorrectAction(scenario: GameScenario): Result<Action> = withContext(defaultDispatcher) {
        val startTime = System.currentTimeMillis()
        val cacheKey = getCacheKey(scenario)
        
        try {
            // Check L1 cache first
            actionCache.get(cacheKey)?.let { cachedAction ->
                updateMetrics(startTime, cacheHit = true)
                return@withContext Result.success(cachedAction)
            }
            
            // Fallback to strategy chart lookup
            val result = cachedStrategy?.getCorrectAction(scenario) 
                ?: return@withContext Result.failure(
                    StrategyException.DataCorruption("Strategy not initialized", null)
                )
            
            result.onSuccess { action ->
                actionCache.put(cacheKey, action)
                updateMetrics(startTime, cacheHit = false)
            }.onFailure { error ->
                errorReporter.reportNonFatalError(error as? Throwable ?: Exception(error.toString()), "StrategyLookup")
                updateMetrics(startTime, cacheHit = false, isError = true)
            }
            
            result
        } catch (e: Exception) {
            errorReporter.reportNonFatalError(e, "StrategyRepository.getCorrectAction")
            updateMetrics(startTime, cacheHit = false, isError = true)
            Result.failure(StrategyException.DataCorruption("Unexpected error during strategy lookup", e))
        }
    }
    
    private suspend fun updateMetrics(startTime: Long, cacheHit: Boolean, isError: Boolean = false) {
        val responseTime = System.currentTimeMillis() - startTime
        metricsLock.withLock {
            val current = _strategyMetrics.value
            val newTotalLookups = current.totalLookups + 1
            val newCacheHits = if (cacheHit) 1 else 0
            val newErrors = if (isError) 1 else 0
            
            _strategyMetrics.value = current.copy(
                cacheHitRate = (current.cacheHitRate * current.totalLookups + newCacheHits) / newTotalLookups,
                averageResponseTime = (current.averageResponseTime * current.totalLookups + responseTime) / newTotalLookups,
                totalLookups = newTotalLookups,
                errorRate = (current.errorRate * current.totalLookups + newErrors) / newTotalLookups
            )
        }
    }
    
    override suspend fun getExplanation(scenario: GameScenario): String = withContext(defaultDispatcher) {
        val cacheKey = "exp_${getCacheKey(scenario)}"
        
        explanationCache.get(cacheKey)?.let { return@withContext it }
        
        val explanation = cachedStrategy?.getExplanation(scenario) ?: "Strategy not loaded"
        explanationCache.put(cacheKey, explanation)
        explanation
    }
    
    override suspend fun getMnemonic(scenario: GameScenario): String? = withContext(defaultDispatcher) {
        cachedStrategy?.mnemonics?.get(getCacheKey(scenario))
    }
    
    
    override fun getStrategyMetrics(): Flow<StrategyMetrics> = _strategyMetrics.asStateFlow()
    
    override suspend fun prefetchCommonScenarios(sessionType: SessionType) = withContext(defaultDispatcher) {
        val commonScenarios = when (sessionType) {
            SessionType.ABSOLUTE -> getAbsoluteScenarios()
            SessionType.DEALER_GROUP -> getDealerGroupScenarios()
            SessionType.HAND_TYPE -> getHandTypeScenarios()
            SessionType.RANDOM -> getRandomCommonScenarios()
        }
        
        // Warm up the cache
        commonScenarios.forEach { scenario ->
            getCorrectAction(scenario)
            getExplanation(scenario)
        }
    }
    
    private fun getAbsoluteScenarios(): List<GameScenario> {
        // Return scenarios for absolute rules (always split A,A and 8,8, never split 10,10 and 5,5)
        return listOf(
            // Always split scenarios
            GameScenario(handType = HandType.PAIR, playerCards = listOf(Card.ACE_SPADES, Card.ACE_HEARTS), playerTotal = 12, dealerCard = Card.FIVE_CLUBS),
            GameScenario(handType = HandType.PAIR, playerCards = listOf(Card.EIGHT_SPADES, Card.EIGHT_HEARTS), playerTotal = 16, dealerCard = Card.KING_CLUBS),
            // Never split scenarios
            GameScenario(handType = HandType.PAIR, playerCards = listOf(Card.KING_SPADES, Card.QUEEN_HEARTS), playerTotal = 20, dealerCard = Card.FIVE_CLUBS),
            GameScenario(handType = HandType.PAIR, playerCards = listOf(Card.FIVE_SPADES, Card.FIVE_HEARTS), playerTotal = 10, dealerCard = Card.SIX_CLUBS)
        )
    }
    
    private fun getDealerGroupScenarios(): List<GameScenario> = emptyList() // Implement based on dealer strength
    private fun getHandTypeScenarios(): List<GameScenario> = emptyList() // Implement based on hand types
    private fun getRandomCommonScenarios(): List<GameScenario> = emptyList() // Implement most common scenarios
}
}

// Statistics repository with session-only persistence
interface StatisticsRepository {
    suspend fun recordAttempt(handType: HandType, dealerStrength: DealerStrength, isCorrect: Boolean)
    fun getSessionStatsFlow(): Flow<SessionStats>
    suspend fun resetSession()
    suspend fun saveSession()
    suspend fun loadSession()
}

@Singleton
class StatisticsRepositoryImpl @Inject constructor(
    private val sessionPersistenceManager: SessionPersistenceManager,
    @IoDispatcher private val ioDispatcher: CoroutineDispatcher
) : StatisticsRepository {
    
    private var currentSession = SessionStatistics()
    private val _sessionStats = MutableStateFlow(SessionStats())
    
    override suspend fun recordAttempt(handType: HandType, dealerStrength: DealerStrength, isCorrect: Boolean) {
        // Record attempt in current session
        val category = "${handType.name.lowercase()}_${dealerStrength.name.lowercase()}"
        currentSession.recordAttempt(category, isCorrect)
        
        // Update UI flow immediately
        _sessionStats.update { current ->
            current.copy(
                totalAttempts = currentSession.totalCount,
                correctAttempts = currentSession.correctCount,
                accuracy = currentSession.getAccuracy(),
                categoryStats = current.categoryStats.toMutableMap().apply {
                    val handTypeKey = handType.name.lowercase()
                    val existing = this[handTypeKey] ?: CategoryStats()
                    this[handTypeKey] = existing.copy(
                        total = existing.total + 1,
                        correct = if (isCorrect) existing.correct + 1 else existing.correct
                    )
                }
            )
    }
    
    override fun getSessionStatsFlow(): Flow<SessionStats> = _sessionStats.asStateFlow()
    
    override suspend fun resetSession() {
        currentSession = SessionStatistics()
        _sessionStats.value = SessionStats()
        sessionPersistenceManager.clearSession()
    }
    
    override suspend fun saveSession() = withContext(ioDispatcher) {
        sessionPersistenceManager.saveSession(currentSession)
    }
    
    override suspend fun loadSession() = withContext(ioDispatcher) {
        sessionPersistenceManager.loadSession()?.let { loadedSession ->
            currentSession = loadedSession
            _sessionStats.value = SessionStats(
                totalAttempts = loadedSession.totalCount,
                correctAttempts = loadedSession.correctCount,
                accuracy = loadedSession.getAccuracy(),
                categoryStats = loadedSession.attempts.mapValues { (_, record) ->
                    CategoryStats(
                        total = record.totalAttempts,
                        correct = record.correctAttempts
                    )
                }
            )
        }
    }
}
```

### Advanced ViewModels with Expert State Management & Performance Optimization

```kotlin
@HiltViewModel
class TrainingSessionViewModel @Inject constructor(
    private val strategyRepository: StrategyRepository,
    private val statisticsRepository: StatisticsRepository,
    private val scenarioGenerator: ScenarioGenerator,
    private val performanceMonitor: PerformanceMonitor,
    private val analyticsManager: AnalyticsManager,
    private val errorReporter: ErrorReporter,
    private val userPreferencesRepository: UserPreferencesRepository,
    savedStateHandle: SavedStateHandle
) : ViewModel() {
    
    private val sessionConfig: SessionConfiguration = savedStateHandle.get<SessionConfiguration>("config")
        ?: SessionConfiguration.default()
    
    private val sessionId: String = UUID.randomUUID().toString()
    private val sessionStartTime = System.currentTimeMillis()
    private var questionStartTime = 0L
    
    private val _uiState = MutableStateFlow(TrainingUiState.Loading)
    val uiState: StateFlow<TrainingUiState> = _uiState.asStateFlow()
    
    private val _sessionProgress = MutableStateFlow(SessionProgress())
    val sessionProgress: StateFlow<SessionProgress> = _sessionProgress.asStateFlow()
    
    private val _userPreferences = userPreferencesRepository.getUserPreferencesFlow()
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = UserPreferences.default()
        )
    val userPreferences: StateFlow<UserPreferences> = _userPreferences
    
    val sessionStats = statisticsRepository.getSessionStatsFlow()
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = SessionStats()
        )
    
    sealed class TrainingUiState {
        object Loading : TrainingUiState()
        data class Ready(
            val scenario: GameScenario,
            val progress: SessionProgress,
            val timeRemaining: Long? = null
        ) : TrainingUiState()
        data class ShowingFeedback(
            val scenario: GameScenario,
            val feedback: FeedbackResult,
            val progress: SessionProgress
        ) : TrainingUiState()
        data class SessionComplete(
            val finalStats: SessionStats,
            val achievements: List<Achievement> = emptyList()
        ) : TrainingUiState()
        data class Error(
            val exception: StrategyException,
            val canRetry: Boolean = true,
            val progress: SessionProgress
        ) : TrainingUiState()
        data class Paused(
            val scenario: GameScenario,
            val progress: SessionProgress
        ) : TrainingUiState()
    }
    
    data class FeedbackResult(
        val isCorrect: Boolean,
        val userAction: Action,
        val correctAction: Action,
        val explanation: String,
        val mnemonic: String? = null,
        val responseTime: Long,
        val difficulty: DifficultyLevel,
        val encouragement: String? = null,
        val streakInfo: StreakInfo? = null
    )
    
    data class SessionProgress(
        val currentQuestion: Int = 0,
        val totalQuestions: Int = 0,
        val correctAnswers: Int = 0,
        val currentStreak: Int = 0,
        val bestStreak: Int = 0,
        val timeElapsed: Long = 0,
        val averageResponseTime: Long = 0,
        val progressPercentage: Float = 0f
    ) {
        val accuracy: Float get() = if (currentQuestion > 0) correctAnswers.toFloat() / currentQuestion else 0f
    }
    
    data class StreakInfo(
        val current: Int,
        val best: Int,
        val milestone: Int? = null
    )
    
    data class Achievement(
        val id: String,
        val title: String,
        val description: String,
        val iconRes: Int,
        val timestamp: Long = System.currentTimeMillis()
    )
    
    init {
        startSession()
    }
    
    private fun startSession() {
        viewModelScope.launch {
            try {
                strategyRepository.initializeStrategy().getOrThrow()
                // Load any existing session on app restart
                statisticsRepository.loadSession()
                generateNextScenario()
            } catch (e: Exception) {
                _uiState.value = TrainingUiState.Error(e)
            }
        }
    }
    
    // Called when app goes to background - save session state
    fun onAppBackgrounded() {
        viewModelScope.launch {
            try {
                statisticsRepository.saveSession()
            } catch (e: Exception) {
                errorReporter.reportNonFatalError(e, "Failed to save session on background")
            }
        }
    }
    
    // Called when app comes to foreground - verify session is still valid
    fun onAppForegrounded() {
        viewModelScope.launch {
            try {
                statisticsRepository.loadSession()
            } catch (e: Exception) {
                errorReporter.reportNonFatalError(e, "Failed to load session on foreground")
            }
        }
    }
    
    override fun onCleared() {
        super.onCleared()
        // Save session when ViewModel is destroyed
        viewModelScope.launch {
            try {
                statisticsRepository.saveSession()
            } catch (e: Exception) {
                // Log but don't crash - app is being destroyed
                errorReporter.reportNonFatalError(e, "Failed to save session on ViewModel cleanup")
            }
        }
    }
    
    private suspend fun generateNextScenario() {
        try {
            val scenario = scenarioGenerator.generateScenario(sessionConfig)
            _uiState.value = TrainingUiState.Ready(scenario)
        } catch (e: Exception) {
            _uiState.value = TrainingUiState.Error(e)
        }
    }
    
    fun submitAnswer(action: Action) {
        val currentState = _uiState.value
        if (currentState !is TrainingUiState.Ready) return
        
        viewModelScope.launch {
            try {
                val scenario = currentState.scenario
                val correctAction = strategyRepository.getCorrectAction(scenario).getOrThrow()
                val isCorrect = action == correctAction
                
                // Record statistics
                val dealerStrength = DealerStrength.fromCard(scenario.dealerCard)
                statisticsRepository.recordAttempt(scenario.handType, dealerStrength, isCorrect)
                
                // Get explanation
                val explanation = strategyRepository.getExplanation(scenario)
                
                val feedback = FeedbackResult(
                    isCorrect = isCorrect,
                    userAction = action,
                    correctAction = correctAction,
                    explanation = explanation
                )
                
                _uiState.value = TrainingUiState.ShowingFeedback(scenario, feedback)
                
            } catch (e: Exception) {
                _uiState.value = TrainingUiState.Error(e)
            }
        }
    }
    
    fun nextQuestion() {
        viewModelScope.launch {
            val currentStats = sessionStats.value
            if (currentStats.totalAttempts >= sessionConfig.maxQuestions) {
                _uiState.value = TrainingUiState.SessionComplete
            } else {
                generateNextScenario()
            }
        }
    }
    
    fun endSession() {
        _uiState.value = TrainingUiState.SessionComplete
    }
}

// Scenario generation with caching and performance optimization
@Singleton
class ScenarioGenerator @Inject constructor(
    @DefaultDispatcher private val defaultDispatcher: CoroutineDispatcher
) {
    private val scenarioCache = mutableMapOf<SessionType, List<GameScenario>>()
    
    suspend fun generateScenario(config: SessionConfiguration): GameScenario = withContext(defaultDispatcher) {
        val cachedScenarios = scenarioCache[config.sessionType]
        if (cachedScenarios.isNullOrEmpty()) {
            precomputeScenarios(config.sessionType)
        }
        
        scenarioCache[config.sessionType]?.randomOrNull() 
            ?: generateRandomScenario(config)
    }
    
    private suspend fun precomputeScenarios(sessionType: SessionType) = withContext(defaultDispatcher) {
        val scenarios = when (sessionType) {
            SessionType.RANDOM -> generateAllRandomScenarios()
            SessionType.DEALER_GROUP -> generateDealerGroupScenarios()
            SessionType.HAND_TYPE -> generateHandTypeScenarios()
            SessionType.ABSOLUTE -> generateAbsoluteScenarios()
        }
        scenarioCache[sessionType] = scenarios.shuffled()
    }
    
    private fun generateRandomScenario(config: SessionConfiguration): GameScenario {
        val dealerCard = Card.random()
        val handType = HandType.values().random()
        
        return when (handType) {
            HandType.PAIR -> generatePairScenario(dealerCard)
            HandType.SOFT -> generateSoftScenario(dealerCard)
            HandType.HARD -> generateHardScenario(dealerCard)
        }
    }
    
    // Additional scenario generation methods...
}
```

### Application Lifecycle Management for Session Persistence

```kotlin
// Application class with lifecycle-aware session management
@HiltAndroidApp
class BlackjackTrainerApplication : Application(), Application.ActivityLifecycleCallbacks {
    
    @Inject
    lateinit var statisticsRepository: StatisticsRepository
    
    private var isAppInBackground = false
    private var activeActivities = 0
    
    override fun onCreate() {
        super.onCreate()
        registerActivityLifecycleCallbacks(this)
    }
    
    override fun onActivityStarted(activity: Activity) {
        activeActivities++
        if (isAppInBackground) {
            isAppInBackground = false
            // App came to foreground - notify ViewModels to load session
            notifyAppForegrounded()
        }
    }
    
    override fun onActivityStopped(activity: Activity) {
        activeActivities--
        if (activeActivities == 0) {
            isAppInBackground = true
            // App went to background - save session state
            notifyAppBackgrounded()
        }
    }
    
    private fun notifyAppBackgrounded() {
        // Notify all active ViewModels to save session
        // This would be implemented using a global event bus or observer pattern
        GlobalScope.launch {
            try {
                statisticsRepository.saveSession()
            } catch (e: Exception) {
                // Log error but don't crash
                Timber.w(e, "Failed to save session on app background")
            }
        }
    }
    
    private fun notifyAppForegrounded() {
        // Notify all active ViewModels to reload session if needed
        GlobalScope.launch {
            try {
                statisticsRepository.loadSession()
            } catch (e: Exception) {
                // Log error but don't crash
                Timber.w(e, "Failed to load session on app foreground")
            }
        }
    }
    
    // Unused lifecycle callbacks
    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}
    override fun onActivityResumed(activity: Activity) {}
    override fun onActivityPaused(activity: Activity) {}
    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
    override fun onActivityDestroyed(activity: Activity) {}
}
```

### Expert Jetpack Compose UI with Advanced Material Design 3 & Performance Optimization

```kotlin
// Enhanced main app entry point with comprehensive initialization and edge-to-edge design
@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    
    @Inject
    lateinit var analyticsManager: AnalyticsManager
    
    @Inject
    lateinit var shortcutsManager: ShortcutsManager
    
    @Inject
    lateinit var performanceMonitor: PerformanceMonitor
    
    private var isResumed = false
    
    override fun onCreate(savedInstanceState: Bundle?) {
        performanceMonitor.startTrace("MainActivity.onCreate")
        super.onCreate(savedInstanceState)
        
        // Enable edge-to-edge display
        enableEdgeToEdge()
        
        // Handle app shortcuts
        handleShortcutIntent(intent)
        
        // Set up window flags for optimal performance
        window.setFlags(
            WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
            WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED
        )
        
        setContent {
            val windowSizeClass = calculateWindowSizeClass(this)
            
            BlackjackTrainerTheme {
                // Provide composition locals for app-wide dependencies
                CompositionLocalProvider(
                    LocalWindowSizeClass provides windowSizeClass,
                    LocalAnalyticsManager provides analyticsManager,
                    LocalPerformanceMonitor provides performanceMonitor
                ) {
                    BlackjackTrainerApp(
                        windowSizeClass = windowSizeClass,
                        onAnalyticsEvent = { event ->
                            analyticsManager.trackEvent(event)
                        }
                    )
                }
            }
        }
        
        performanceMonitor.stopTrace("MainActivity.onCreate")
    }
    
    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        handleShortcutIntent(intent)
    }
    
    override fun onResume() {
        super.onResume()
        isResumed = true
        
        // Update app shortcuts
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
            shortcutsManager.updateShortcuts()
        }
        
        // Report app resume for analytics
        analyticsManager.trackEvent(AnalyticsEvent.AppResumed)
    }
    
    override fun onPause() {
        super.onPause()
        isResumed = false
        analyticsManager.trackEvent(AnalyticsEvent.AppPaused)
    }
    
    private fun handleShortcutIntent(intent: Intent?) {
        when (intent?.action) {
            "START_QUICK_PRACTICE" -> {
                // Handle quick practice shortcut
                analyticsManager.trackEvent(AnalyticsEvent.ShortcutUsed("quick_practice"))
            }
            "START_ABSOLUTES_DRILL" -> {
                // Handle absolutes drill shortcut
                analyticsManager.trackEvent(AnalyticsEvent.ShortcutUsed("absolutes_drill"))
            }
        }
    }
}

// Composition locals for dependency injection in Compose
val LocalWindowSizeClass = compositionLocalOf<WindowSizeClass> { error("No WindowSizeClass provided") }
val LocalAnalyticsManager = compositionLocalOf<AnalyticsManager> { error("No AnalyticsManager provided") }
val LocalPerformanceMonitor = compositionLocalOf<PerformanceMonitor> { error("No PerformanceMonitor provided") }

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BlackjackTrainerApp(
    windowSizeClass: WindowSizeClass,
    onAnalyticsEvent: (AnalyticsEvent) -> Unit = {}
) {
    val navController = rememberNavController()
    val performanceMonitor = LocalPerformanceMonitor.current
    
    // Track navigation performance
    LaunchedEffect(navController) {
        navController.addOnDestinationChangedListener { _, destination, _ ->
            performanceMonitor.startTrace("Navigation.${destination.route}")
        }
    }
    
    // Handle system UI visibility and navigation bar colors
    val systemUiController = rememberSystemUiController()
    val useDarkIcons = !isSystemInDarkTheme()
    
    LaunchedEffect(systemUiController, useDarkIcons) {
        systemUiController.setSystemBarsColor(
            color = Color.Transparent,
            darkIcons = useDarkIcons
        )
    }
    
    // Adaptive navigation based on screen size
    when (windowSizeClass.widthSizeClass) {
        WindowWidthSizeClass.Compact -> {
            CompactNavigation(
                navController = navController,
                onAnalyticsEvent = onAnalyticsEvent
            )
        }
        WindowWidthSizeClass.Medium, WindowWidthSizeClass.Expanded -> {
            AdaptiveNavigation(
                navController = navController,
                windowSizeClass = windowSizeClass,
                onAnalyticsEvent = onAnalyticsEvent
            )
        }
    }
}

@Composable
private fun CompactNavigation(
    navController: NavHostController,
    onAnalyticsEvent: (AnalyticsEvent) -> Unit
) {
    NavHost(
        navController = navController,
        startDestination = "main_menu",
        enterTransition = { slideInHorizontally(initialOffsetX = { it }) + fadeIn() },
        exitTransition = { slideOutHorizontally(targetOffsetX = { -it }) + fadeOut() },
        popEnterTransition = { slideInHorizontally(initialOffsetX = { -it }) + fadeIn() },
        popExitTransition = { slideOutHorizontally(targetOffsetX = { it }) + fadeOut() }
    ) {
        composable(
            route = "main_menu",
            deepLinks = listOf(navDeepLink { uriPattern = "blackjacktrainer://main" })
        ) {
            MainMenuScreen(
                onNavigateToSession = { config ->
                    val configJson = config.toJson()
                    navController.navigate("training_session/${Uri.encode(configJson)}")
                },
                onNavigateToStats = {
                    navController.navigate("statistics")
                },
                onNavigateToGuide = {
                    navController.navigate("strategy_guide")
                },
                onNavigateToSettings = {
                    navController.navigate("settings")
                },
                onAnalyticsEvent = onAnalyticsEvent
            )
        }
        
        composable(
            route = "training_session/{config}",
            arguments = listOf(
                navArgument("config") { 
                    type = NavType.StringType
                    nullable = false
                }
            ),
            deepLinks = listOf(
                navDeepLink { uriPattern = "blackjacktrainer://session/{config}" }
            )
        ) { backStackEntry ->
            val configJson = backStackEntry.arguments?.getString("config")
            val config = try {
                SessionConfiguration.fromJson(Uri.decode(configJson))
            } catch (e: Exception) {
                // Fallback to default config if parsing fails
                SessionConfiguration.default().also {
                    onAnalyticsEvent(AnalyticsEvent.NavigationError("invalid_config", e.message))
                }
            }
            
            TrainingSessionScreen(
                configuration = config,
                onNavigateBack = { 
                    navController.popBackStack()
                },
                onNavigateToStats = {
                    navController.navigate("statistics")
                },
                onAnalyticsEvent = onAnalyticsEvent
            )
        }
        
        composable(
            route = "statistics",
            deepLinks = listOf(navDeepLink { uriPattern = "blackjacktrainer://stats" })
        ) {
            StatisticsScreen(
                onNavigateBack = { navController.popBackStack() },
                onAnalyticsEvent = onAnalyticsEvent
            )
        }
        
        composable(
            route = "strategy_guide",
            deepLinks = listOf(navDeepLink { uriPattern = "blackjacktrainer://guide" })
        ) {
            StrategyGuideScreen(
                onNavigateBack = { navController.popBackStack() },
                onAnalyticsEvent = onAnalyticsEvent
            )
        }
        
        composable(
            route = "settings",
            deepLinks = listOf(navDeepLink { uriPattern = "blackjacktrainer://settings" })
        ) {
            SettingsScreen(
                onNavigateBack = { navController.popBackStack() },
                onAnalyticsEvent = onAnalyticsEvent
            )
        }
    }
}

// Enhanced main menu with adaptive design and comprehensive accessibility
@OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
@Composable
fun MainMenuScreen(
    onNavigateToSession: (SessionConfiguration) -> Unit,
    onNavigateToStats: () -> Unit,
    onNavigateToGuide: () -> Unit,
    onNavigateToSettings: () -> Unit,
    onAnalyticsEvent: (AnalyticsEvent) -> Unit,
    viewModel: MainMenuViewModel = hiltViewModel()
) {
    val windowSizeClass = LocalWindowSizeClass.current
    val userPreferences by viewModel.userPreferences.collectAsState()
    val recentStats by viewModel.recentStats.collectAsState()
    
    LaunchedEffect(Unit) {
        onAnalyticsEvent(AnalyticsEvent.ScreenView("main_menu"))
    }
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Casino,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.primary
                        )
                        Text(
                            text = "Blackjack Trainer",
                            style = MaterialTheme.typography.headlineMedium,
                            fontWeight = FontWeight.Bold
                        )
                    }
                },
                actions = {
                    IconButton(
                        onClick = onNavigateToSettings,
                        modifier = Modifier.semantics {
                            contentDescription = "Open settings"
                        }
                    ) {
                        Icon(
                            imageVector = Icons.Default.Settings,
                            contentDescription = "Settings"
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer,
                    titleContentColor = MaterialTheme.colorScheme.onPrimaryContainer
                ),
                scrollBehavior = TopAppBarDefaults.exitUntilCollapsedScrollBehavior()
            )
        },
        floatingActionButton = {
            if (windowSizeClass.widthSizeClass == WindowWidthSizeClass.Compact) {
                FloatingActionButton(
                    onClick = {
                        onNavigateToSession(
                            SessionConfiguration(
                                sessionType = SessionType.RANDOM,
                                maxQuestions = 50
                            )
                        )
                        onAnalyticsEvent(AnalyticsEvent.QuickActionUsed("fab_quick_practice"))
                    },
                    containerColor = MaterialTheme.colorScheme.primary,
                    modifier = Modifier.semantics {
                        contentDescription = "Start quick practice session"
                    }
                ) {
                    Icon(
                        imageVector = Icons.Default.PlayArrow,
                        contentDescription = "Quick Practice"
                    )
                }
            }
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(horizontal = 16.dp)
                .semantics {
                    heading()
                    contentDescription = "Main menu with training options"
                },
            verticalArrangement = Arrangement.spacedBy(12.dp),
            contentPadding = PaddingValues(vertical = 16.dp)
        ) {
            // Welcome section with recent stats
            item {
                WelcomeCard(
                    recentStats = recentStats,
                    userName = userPreferences.userName,
                    modifier = Modifier.animateItemPlacement()
                )
            }
            item {
                Text(
                    text = "Training Modes",
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onSurface,
                    modifier = Modifier
                        .padding(vertical = 16.dp)
                        .animateItemPlacement()
                        .semantics { heading() }
                )
            }
            
            item {
                TrainingModeCard(
                    title = "Quick Practice",
                    subtitle = "Mixed scenarios from all categories",
                    description = "Perfect for daily practice with randomized hands",
                    icon = Icons.Default.Shuffle,
                    iconColor = Color(0xFF2196F3),
                    estimatedTime = "15-20 minutes",
                    difficulty = DifficultyLevel.NORMAL,
                    onClick = {
                        val config = SessionConfiguration(
                            sessionType = SessionType.RANDOM,
                            maxQuestions = 50
                        )
                        onNavigateToSession(config)
                        onAnalyticsEvent(AnalyticsEvent.TrainingModeSelected("quick_practice"))
                    },
                    modifier = Modifier.animateItemPlacement()
                )
            }
            
            item {
                TrainingModeCard(
                    title = "Dealer Strength Groups",
                    subtitle = "Practice by dealer weakness",
                    icon = Icons.Default.Group,
                    onClick = {
                        onNavigateToSession(
                            SessionConfiguration(
                                sessionType = SessionType.DEALER_GROUP,
                                maxQuestions = 50
                            )
                        )
                    }
                )
            }
            
            item {
                TrainingModeCard(
                    title = "Hand Type Focus",
                    subtitle = "Hard totals, soft totals, or pairs",
                    icon = Icons.Default.BackHand,
                    onClick = {
                        onNavigateToSession(
                            SessionConfiguration(
                                sessionType = SessionType.HAND_TYPE,
                                maxQuestions = 50
                            )
                        )
                    }
                )
            }
            
            item {
                TrainingModeCard(
                    title = "Absolutes Drill",
                    subtitle = "Never/always rules",
                    icon = Icons.Default.Warning,
                    onClick = {
                        onNavigateToSession(
                            SessionConfiguration(
                                sessionType = SessionType.ABSOLUTE,
                                maxQuestions = 20
                            )
                        )
                    }
                )
            }
            
            // Quick actions section
            item {
                Text(
                    text = "Quick Actions",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Medium,
                    modifier = Modifier
                        .padding(top = 24.dp, bottom = 12.dp)
                        .animateItemPlacement()
                        .semantics { heading() }
                )
            }
            
            item {
                FlowRow(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .animateItemPlacement()
                ) {
                    QuickActionChip(
                        label = "Statistics",
                        icon = Icons.Default.BarChart,
                        onClick = {
                            onNavigateToStats()
                            onAnalyticsEvent(AnalyticsEvent.QuickActionUsed("statistics"))
                        }
                    )
                    
                    QuickActionChip(
                        label = "Strategy Guide",
                        icon = Icons.Default.MenuBook,
                        onClick = {
                            onNavigateToGuide()
                            onAnalyticsEvent(AnalyticsEvent.QuickActionUsed("strategy_guide"))
                        }
                    )
                    
                    QuickActionChip(
                        label = "Settings",
                        icon = Icons.Default.Settings,
                        onClick = {
                            onNavigateToSettings()
                            onAnalyticsEvent(AnalyticsEvent.QuickActionUsed("settings"))
                        }
                    )
                }
            }
            
            // Daily tip section
            item {
                DailyTipCard(
                    modifier = Modifier
                        .padding(top = 16.dp)
                        .animateItemPlacement()
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TrainingModeCard(
    title: String,
    subtitle: String,
    description: String,
    icon: ImageVector,
    iconColor: Color,
    estimatedTime: String,
    difficulty: DifficultyLevel,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        onClick = onClick,
        modifier = modifier
            .fillMaxWidth()
            .semantics {
                contentDescription = "$title training mode. $description. Estimated time: $estimatedTime"
            },
        elevation = CardDefaults.cardElevation(
            defaultElevation = 4.dp,
            pressedElevation = 8.dp,
            hoveredElevation = 6.dp
        ),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant,
            contentColor = MaterialTheme.colorScheme.onSurfaceVariant
        ),
        border = BorderStroke(
            width = 1.dp,
            color = MaterialTheme.colorScheme.outline.copy(alpha = 0.12f)
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(56.dp)
                        .background(
                            color = iconColor.copy(alpha = 0.12f),
                            shape = CircleShape
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = icon,
                        contentDescription = null,
                        tint = iconColor,
                        modifier = Modifier.size(28.dp)
                    )
                }
                
                Spacer(modifier = Modifier.width(16.dp))
                
                Column(
                    modifier = Modifier.weight(1f)
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Text(
                            text = title,
                            style = MaterialTheme.typography.titleLarge,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                        
                        DifficultyChip(difficulty = difficulty)
                    }
                    
                    Text(
                        text = subtitle,
                        style = MaterialTheme.typography.bodyLarge,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.padding(top = 4.dp)
                    )
                }
                
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.size(24.dp)
                )
            }
            
            Spacer(modifier = Modifier.height(12.dp))
            
            Text(
                text = description,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                lineHeight = 20.sp
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.Schedule,
                        contentDescription = null,
                        tint = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.size(16.dp)
                    )
                    Text(
                        text = estimatedTime,
                        style = MaterialTheme.typography.labelMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
        }
    }
}

// Enhanced training session screen with comprehensive state management and adaptive design
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TrainingSessionScreen(
    configuration: SessionConfiguration,
    onNavigateBack: () -> Unit,
    onNavigateToStats: () -> Unit,
    onAnalyticsEvent: (AnalyticsEvent) -> Unit,
    viewModel: TrainingSessionViewModel = hiltViewModel()
) {
    val windowSizeClass = LocalWindowSizeClass.current
    val uiState by viewModel.uiState.collectAsState()
    val sessionStats by viewModel.sessionStats.collectAsState()
    val sessionProgress by viewModel.sessionProgress.collectAsState()
    val userPreferences by viewModel.userPreferences.collectAsState()
    
    // Handle system back button
    var showExitDialog by remember { mutableStateOf(false) }
    
    BackHandler {
        showExitDialog = true
    }
    
    LaunchedEffect(Unit) {
        onAnalyticsEvent(AnalyticsEvent.SessionStarted(configuration.sessionType))
    }
    
    // Show exit confirmation dialog
    if (showExitDialog) {
        AlertDialog(
            onDismissRequest = { showExitDialog = false },
            title = { Text("Exit Training Session?") },
            text = { 
                Text("Your progress will be saved. Are you sure you want to exit?") 
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        showExitDialog = false
                        viewModel.endSession()
                        onNavigateBack()
                        onAnalyticsEvent(AnalyticsEvent.SessionExited("user_choice"))
                    }
                ) {
                    Text("Exit")
                }
            },
            dismissButton = {
                TextButton(
                    onClick = { showExitDialog = false }
                ) {
                    Text("Continue")
                }
            }
        )
    }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { 
                    Column {
                        Text(
                            text = configuration.sessionType.displayName,
                            style = MaterialTheme.typography.titleLarge
                        )
                        if (sessionProgress.totalQuestions > 0) {
                            Text(
                                text = "${sessionProgress.currentQuestion}/${sessionProgress.totalQuestions}",
                                style = MaterialTheme.typography.labelMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                },
                navigationIcon = {
                    IconButton(
                        onClick = { showExitDialog = true },
                        modifier = Modifier.semantics {
                            contentDescription = "Exit training session"
                        }
                    ) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    // Progress indicator
                    if (sessionProgress.totalQuestions > 0) {
                        CircularProgressIndicator(
                            progress = sessionProgress.progressPercentage,
                            modifier = Modifier
                                .size(32.dp)
                                .padding(4.dp),
                            strokeWidth = 3.dp,
                            color = MaterialTheme.colorScheme.primary,
                            trackColor = MaterialTheme.colorScheme.surfaceVariant
                        )
                    }
                    
                    IconButton(
                        onClick = { viewModel.pauseSession() },
                        modifier = Modifier.semantics {
                            contentDescription = "Pause session"
                        }
                    ) {
                        Icon(Icons.Default.Pause, contentDescription = "Pause")
                    }
                    
                    IconButton(
                        onClick = { showExitDialog = true },
                        modifier = Modifier.semantics {
                            contentDescription = "End session"
                        }
                    ) {
                        Icon(Icons.Default.Close, contentDescription = "End Session")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.surface,
                    titleContentColor = MaterialTheme.colorScheme.onSurface
                )
            )
        }
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .background(MaterialTheme.colorScheme.background)
        ) {
            AnimatedContent(
                targetState = uiState,
                transitionSpec = {
                    fadeIn(animationSpec = tween(300)) with 
                    fadeOut(animationSpec = tween(300))
                },
                label = "training_ui_state"
            ) { state ->
                when (state) {
                    is TrainingSessionViewModel.TrainingUiState.Loading -> {
                        LoadingScreen(
                            message = "Preparing your training session...",
                            modifier = Modifier.fillMaxSize()
                        )
                    }
                    
                    is TrainingSessionViewModel.TrainingUiState.Ready -> {
                        TrainingContent(
                            scenario = state.scenario,
                            progress = state.progress,
                            sessionStats = sessionStats,
                            userPreferences = userPreferences,
                            windowSizeClass = windowSizeClass,
                            onActionSelected = { action ->
                                if (userPreferences.hapticFeedbackEnabled) {
                                    // Trigger haptic feedback
                                }
                                viewModel.submitAnswer(action)
                                onAnalyticsEvent(
                                    AnalyticsEvent.ActionSelected(
                                        action.shortCode,
                                        state.scenario.handType,
                                        state.scenario.dealerCard.value
                                    )
                                )
                            },
                            modifier = Modifier.fillMaxSize()
                        )
                    }
                    
                    is TrainingSessionViewModel.TrainingUiState.ShowingFeedback -> {
                        FeedbackScreen(
                            scenario = state.scenario,
                            feedback = state.feedback,
                            progress = state.progress,
                            userPreferences = userPreferences,
                            onContinue = { 
                                viewModel.nextQuestion()
                                onAnalyticsEvent(AnalyticsEvent.FeedbackContinued)
                            },
                            onViewExplanation = {
                                onAnalyticsEvent(AnalyticsEvent.ExplanationViewed)
                            },
                            modifier = Modifier.fillMaxSize()
                        )
                    }
                    
                    is TrainingSessionViewModel.TrainingUiState.SessionComplete -> {
                        SessionCompleteScreen(
                            finalStats = state.finalStats,
                            achievements = state.achievements,
                            onNavigateBack = onNavigateBack,
                            onNavigateToStats = onNavigateToStats,
                            onRestartSession = {
                                viewModel.restartSession()
                                onAnalyticsEvent(AnalyticsEvent.SessionRestarted)
                            },
                            onAnalyticsEvent = onAnalyticsEvent,
                            modifier = Modifier.fillMaxSize()
                        )
                    }
                    
                    is TrainingSessionViewModel.TrainingUiState.Error -> {
                        ErrorScreen(
                            error = state.exception,
                            canRetry = state.canRetry,
                            progress = state.progress,
                            onRetry = { 
                                viewModel.retryOperation()
                                onAnalyticsEvent(AnalyticsEvent.ErrorRecovery("retry"))
                            },
                            onNavigateBack = onNavigateBack,
                            onReportIssue = {
                                onAnalyticsEvent(AnalyticsEvent.ErrorRecovery("report"))
                            },
                            modifier = Modifier.fillMaxSize()
                        )
                    }
                    
                    is TrainingSessionViewModel.TrainingUiState.Paused -> {
                        PausedScreen(
                            scenario = state.scenario,
                            progress = state.progress,
                            onResume = {
                                viewModel.resumeSession()
                                onAnalyticsEvent(AnalyticsEvent.SessionResumed)
                            },
                            onEndSession = {
                                viewModel.endSession()
                                onNavigateBack()
                                onAnalyticsEvent(AnalyticsEvent.SessionExited("pause_menu"))
                            },
                            modifier = Modifier.fillMaxSize()
                        )
                    }
                }
            }
        }
    }
}

// Enhanced scenario display with advanced accessibility and adaptive design
@Composable
fun ScenarioDisplay(
    scenario: GameScenario,
    windowSizeClass: WindowSizeClass,
    modifier: Modifier = Modifier
) {
    val isCompact = windowSizeClass.widthSizeClass == WindowWidthSizeClass.Compact
    Column(
        modifier = modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(24.dp)
    ) {
        // Dealer card section
        Card(
            elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
        ) {
            Column(
                modifier = Modifier.padding(16.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "Dealer Shows",
                    style = MaterialTheme.typography.titleMedium,
                    color = MaterialTheme.colorScheme.onSurface
                )
                Spacer(modifier = Modifier.height(8.dp))
                PlayingCard(
                    card = scenario.dealerCard,
                    modifier = Modifier
                        .size(80.dp, 112.dp)
                        .semantics {
                            contentDescription = "Dealer card is ${scenario.dealerCard.displayValue}"
                        }
                )
            }
        }
        
        // Player cards section
        Card(
            elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
        ) {
            Column(
                modifier = Modifier.padding(16.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "Your Hand",
                    style = MaterialTheme.typography.titleMedium,
                    color = MaterialTheme.colorScheme.onSurface
                )
                Spacer(modifier = Modifier.height(8.dp))
                
                LazyRow(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier.semantics(mergeDescendants = true) {
                        contentDescription = "Your cards total ${scenario.playerTotal}"
                    }
                ) {
                    items(scenario.playerCards) { card ->
                        PlayingCard(
                            card = card,
                            modifier = Modifier.size(64.dp, 89.dp)
                        )
                    }
                }
                
                Spacer(modifier = Modifier.height(8.dp))
                
                Text(
                    text = "${scenario.handType.displayName} ${scenario.playerTotal}",
                    style = MaterialTheme.typography.titleLarge,
                    color = MaterialTheme.colorScheme.primary,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

// Playing card component with Material Design
@Composable
fun PlayingCard(
    card: Card,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier,
        colors = CardDefaults.cardColors(
            containerColor = Color.White
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),
        border = BorderStroke(1.dp, Color.Black)
    ) {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = card.displayValue,
                    style = MaterialTheme.typography.headlineMedium,
                    color = if (card.isRed) Color.Red else Color.Black,
                    fontWeight = FontWeight.Bold
                )
                
                if (card.isFaceCard) {
                    Icon(
                        imageVector = card.faceCardIcon,
                        contentDescription = null,
                        tint = if (card.isRed) Color.Red else Color.Black,
                        modifier = Modifier.size(16.dp)
                    )
                }
            }
        }
    }
}

// Action buttons with haptic feedback
@Composable
fun ActionButtons(
    onActionSelected: (Action) -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    
    LazyVerticalGrid(
        columns = GridCells.Fixed(2),
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        items(Action.values()) { action ->
            ActionButton(
                action = action,
                onClick = {
                    // Haptic feedback
                    val vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        vibrator?.vibrate(VibrationEffect.createOneShot(50, VibrationEffect.DEFAULT_AMPLITUDE))
                    } else {
                        @Suppress("DEPRECATION")
                        vibrator?.vibrate(50)
                    }
                    
                    onActionSelected(action)
                }
            )
        }
    }
}

@Composable
fun ActionButton(
    action: Action,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Button(
        onClick = onClick,
        modifier = modifier
            .fillMaxWidth()
            .height(56.dp)
            .semantics {
                contentDescription = action.accessibilityLabel
            },
        elevation = ButtonDefaults.buttonElevation(defaultElevation = 4.dp)
    ) {
        Text(
            text = action.displayName,
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.Medium
        )
    }
}
```

### Session-Only Statistics with Lifecycle Management

```kotlin
// IMPORTANT: This section contains legacy Room database code. 
// The updated session-only approach uses SharedPreferences and in-memory statistics.
// See the SessionStatistics, SessionPersistenceManager, and StatisticsRepository 
// implementations in the Data Layer section above for the simplified approach.

// Advanced statistics with comprehensive Room persistence and performance optimization
@Entity(
    tableName = "statistic_records",
    indices = [
        Index(value = ["timestamp"]),
        Index(value = ["sessionId"]),
        Index(value = ["handType", "dealerStrength"]),
        Index(value = ["isCorrect", "timestamp"])
    ]
)
data class StatisticRecord(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val handType: HandType,
    val dealerStrength: DealerStrength,
    val isCorrect: Boolean,
    val timestamp: Long,
    val sessionId: String,
    val responseTime: Long, // Time taken to answer in milliseconds
    val difficultyLevel: DifficultyLevel,
    val scenarioComplexity: ComplexityLevel,
    val userConfidence: Float? = null, // 0.0 to 1.0 scale
    val hintUsed: Boolean = false,
    val deviceInfo: String? = null,
    val appVersion: String? = null
)

@Entity(
    tableName = "session_records",
    indices = [
        Index(value = ["startTime"]),
        Index(value = ["sessionType"]),
        Index(value = ["completed"])
    ]
)
data class SessionRecord(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val sessionType: SessionType,
    val startTime: Long,
    val endTime: Long? = null,
    val totalQuestions: Int = 0,
    val correctAnswers: Int = 0,
    val completed: Boolean = false,
    val averageResponseTime: Long = 0,
    val bestStreak: Int = 0,
    val deviceInfo: String? = null,
    val metadata: Map<String, String> = emptyMap()
)

@Entity(
    tableName = "user_preferences",
    indices = [Index(value = ["lastUpdated"])]
)
data class UserPreferences(
    @PrimaryKey val id: Int = 1,
    val userName: String = "",
    val darkModeEnabled: Boolean = false,
    val highContrastEnabled: Boolean = false,
    val hapticFeedbackEnabled: Boolean = true,
    val soundEnabled: Boolean = true,
    val analyticsConsent: Boolean = false,
    val notificationEnabled: Boolean = true,
    val preferredDifficulty: DifficultyLevel = DifficultyLevel.NORMAL,
    val trainingReminders: Boolean = true,
    val showHints: Boolean = true,
    val autoAdvance: Boolean = false,
    val sessionLength: Int = 50,
    val lastUpdated: Long = System.currentTimeMillis()
) {
    companion object {
        fun default() = UserPreferences()
    }
}

// Advanced DAO with comprehensive queries and performance optimization
@Dao
interface StatisticsDao {
    
    // Basic CRUD operations
    @Query("SELECT * FROM statistic_records ORDER BY timestamp DESC LIMIT :limit")
    fun getRecentRecords(limit: Int = 100): Flow<List<StatisticRecord>>
    
    @Query("SELECT * FROM statistic_records WHERE timestamp >= :since ORDER BY timestamp DESC")
    fun getRecordsSince(since: Long): Flow<List<StatisticRecord>>
    
    @Query("SELECT * FROM statistic_records WHERE sessionId = :sessionId ORDER BY timestamp")
    suspend fun getRecordsForSession(sessionId: String): List<StatisticRecord>
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertStatistics(records: List<StatisticRecord>)
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertStatistic(record: StatisticRecord)
    
    @Query("DELETE FROM statistic_records WHERE timestamp < :before")
    suspend fun deleteOldRecords(before: Long)
    
    @Query("SELECT COUNT(*) FROM statistic_records")
    suspend fun getTotalRecordCount(): Int
    
    // Advanced analytics queries
    @Query("""
        SELECT handType, 
               SUM(CASE WHEN isCorrect THEN 1 ELSE 0 END) as correct,
               COUNT(*) as total,
               AVG(responseTime) as avgResponseTime,
               MIN(responseTime) as minResponseTime,
               MAX(responseTime) as maxResponseTime
        FROM statistic_records 
        WHERE timestamp >= :since
        GROUP BY handType
    """)
    fun getCategoryStatsFlow(since: Long = 0): Flow<List<CategoryStatsResult>>
    
    @Query("""
        SELECT dealerStrength,
               SUM(CASE WHEN isCorrect THEN 1 ELSE 0 END) as correct,
               COUNT(*) as total,
               AVG(responseTime) as avgResponseTime
        FROM statistic_records 
        WHERE timestamp >= :since
        GROUP BY dealerStrength
    """)
    fun getDealerStatsFlow(since: Long = 0): Flow<List<DealerStatsResult>>
    
    @Query("""
        SELECT 
            DATE(timestamp/1000, 'unixepoch') as date,
            SUM(CASE WHEN isCorrect THEN 1 ELSE 0 END) as correct,
            COUNT(*) as total,
            AVG(responseTime) as avgResponseTime
        FROM statistic_records 
        WHERE timestamp >= :since
        GROUP BY DATE(timestamp/1000, 'unixepoch')
        ORDER BY date DESC
        LIMIT :limit
    """)
    fun getDailyProgressFlow(since: Long, limit: Int = 30): Flow<List<DailyProgressResult>>
    
    @Query("""
        SELECT 
            difficultyLevel,
            SUM(CASE WHEN isCorrect THEN 1 ELSE 0 END) as correct,
            COUNT(*) as total,
            AVG(responseTime) as avgResponseTime
        FROM statistic_records 
        WHERE timestamp >= :since
        GROUP BY difficultyLevel
    """)
    fun getDifficultyStatsFlow(since: Long = 0): Flow<List<DifficultyStatsResult>>
    
    @Query("""
        SELECT AVG(responseTime) as avgResponseTime,
               COUNT(*) as totalQuestions,
               SUM(CASE WHEN isCorrect THEN 1 ELSE 0 END) as correctAnswers,
               (SUM(CASE WHEN isCorrect THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) as accuracy
        FROM statistic_records 
        WHERE timestamp >= :since
    """)
    fun getOverallStatsFlow(since: Long = 0): Flow<OverallStatsResult?>
    
    @Query("""
        SELECT 
            sessionId,
            COUNT(*) as questionCount,
            SUM(CASE WHEN isCorrect THEN 1 ELSE 0 END) as correctCount,
            AVG(responseTime) as avgResponseTime,
            MIN(timestamp) as startTime,
            MAX(timestamp) as endTime
        FROM statistic_records 
        WHERE sessionId IS NOT NULL AND timestamp >= :since
        GROUP BY sessionId
        ORDER BY startTime DESC
        LIMIT :limit
    """)
    fun getRecentSessionsFlow(since: Long = 0, limit: Int = 10): Flow<List<SessionSummaryResult>>
    
    // Performance improvement queries
    @Query("""
        WITH streak_data AS (
            SELECT *, 
                   ROW_NUMBER() OVER (ORDER BY timestamp) - 
                   ROW_NUMBER() OVER (PARTITION BY isCorrect ORDER BY timestamp) as streak_group
            FROM statistic_records 
            WHERE timestamp >= :since
            ORDER BY timestamp
        )
        SELECT MAX(streak_length) as longestStreak
        FROM (
            SELECT COUNT(*) as streak_length
            FROM streak_data
            WHERE isCorrect = 1
            GROUP BY streak_group
        )
    """)
    suspend fun getLongestCorrectStreak(since: Long = 0): Int?
    
    @Query("""
        SELECT handType, dealerStrength, 
               SUM(CASE WHEN isCorrect = 0 THEN 1 ELSE 0 END) as errors,
               COUNT(*) as total
        FROM statistic_records 
        WHERE timestamp >= :since
        GROUP BY handType, dealerStrength
        HAVING errors > 0
        ORDER BY (errors * 100.0 / total) DESC
        LIMIT :limit
    """)
    suspend fun getWeakestAreas(since: Long = 0, limit: Int = 5): List<WeakAreaResult>
}

// Session DAO for session management
@Dao
interface SessionDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertSession(session: SessionRecord)
    
    @Update
    suspend fun updateSession(session: SessionRecord)
    
    @Query("SELECT * FROM session_records WHERE id = :sessionId")
    suspend fun getSession(sessionId: String): SessionRecord?
    
    @Query("SELECT * FROM session_records ORDER BY startTime DESC LIMIT :limit")
    fun getRecentSessions(limit: Int = 20): Flow<List<SessionRecord>>
    
    @Query("SELECT * FROM session_records WHERE completed = 1 ORDER BY startTime DESC LIMIT :limit")
    fun getCompletedSessions(limit: Int = 10): Flow<List<SessionRecord>>
    
    @Query("DELETE FROM session_records WHERE startTime < :before")
    suspend fun deleteOldSessions(before: Long)
}

// User preferences DAO
@Dao
interface UserPreferencesDao {
    @Query("SELECT * FROM user_preferences WHERE id = 1")
    fun getUserPreferencesFlow(): Flow<UserPreferences?>
    
    @Query("SELECT * FROM user_preferences WHERE id = 1")
    suspend fun getUserPreferences(): UserPreferences?
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertUserPreferences(preferences: UserPreferences)
    
    @Update
    suspend fun updateUserPreferences(preferences: UserPreferences)
}

// Result data classes for complex queries
data class CategoryStatsResult(
    val handType: HandType,
    val correct: Int,
    val total: Int,
    val avgResponseTime: Double,
    val minResponseTime: Long,
    val maxResponseTime: Long
) {
    val accuracy: Double get() = if (total > 0) correct.toDouble() / total else 0.0
}

data class DealerStatsResult(
    val dealerStrength: DealerStrength,
    val correct: Int,
    val total: Int,
    val avgResponseTime: Double
) {
    val accuracy: Double get() = if (total > 0) correct.toDouble() / total else 0.0
}

data class DailyProgressResult(
    val date: String,
    val correct: Int,
    val total: Int,
    val avgResponseTime: Double
) {
    val accuracy: Double get() = if (total > 0) correct.toDouble() / total else 0.0
}

data class DifficultyStatsResult(
    val difficultyLevel: DifficultyLevel,
    val correct: Int,
    val total: Int,
    val avgResponseTime: Double
) {
    val accuracy: Double get() = if (total > 0) correct.toDouble() / total else 0.0
}

data class OverallStatsResult(
    val avgResponseTime: Double,
    val totalQuestions: Int,
    val correctAnswers: Int,
    val accuracy: Double
)

data class SessionSummaryResult(
    val sessionId: String,
    val questionCount: Int,
    val correctCount: Int,
    val avgResponseTime: Double,
    val startTime: Long,
    val endTime: Long
) {
    val accuracy: Double get() = if (questionCount > 0) correctCount.toDouble() / questionCount else 0.0
    val duration: Long get() = endTime - startTime
}

data class WeakAreaResult(
    val handType: HandType,
    val dealerStrength: DealerStrength,
    val errors: Int,
    val total: Int
) {
    val errorRate: Double get() = if (total > 0) errors.toDouble() / total else 0.0
}

// Statistics UI with Material Design 3 charts
@Composable
fun StatisticsScreen(
    onNavigateBack: () -> Unit,
    viewModel: StatisticsViewModel = hiltViewModel()
) {
    val overallStats by viewModel.overallStats.collectAsState()
    val categoryStats by viewModel.categoryStats.collectAsState()
    val recentSessions by viewModel.recentSessions.collectAsState()
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Statistics") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            item {
                OverallStatsCard(stats = overallStats)
            }
            
            item {
                CategoryStatsCard(stats = categoryStats)
            }
            
            item {
                AccuracyChart(stats = categoryStats)
            }
            
            item {
                RecentSessionsCard(sessions = recentSessions)
            }
        }
    }
}
```

### Advanced Android Platform Integration & Expert Features

```kotlin
// Advanced App Widgets with Glance API and Material You theming
class BlackjackStatsWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = BlackjackStatsWidget()
}

class BlackjackStatsWidget : GlanceAppWidget() {
    
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val repository = (context.applicationContext as BlackjackTrainerApplication)
            .appContainer.statsRepository
        
        provideContent {
            GlanceTheme {
                BlackjackStatsWidgetContent(
                    repository = repository,
                    context = context
                )
            }
        }
    }
}

@Composable
private fun BlackjackStatsWidgetContent(
    repository: StatisticsRepository,
    context: Context
) {
    var overallStats by remember { mutableStateOf(OverallStats()) }
    var recentSessions by remember { mutableStateOf<List<SessionSummary>>(emptyList()) }
    
    LaunchedEffect(Unit) {
        // Collect stats in widget context
        launch {
            repository.getOverallStatsFlow().collect {
                overallStats = it
            }
        }
        launch {
            repository.getRecentSessionsFlow(limit = 3).collect {
                recentSessions = it
            }
        }
    }
    
    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(GlanceTheme.colors.primaryContainer)
            .padding(16.dp)
            .cornerRadius(16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Header with app icon
        Row(
            modifier = GlanceModifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalAlignment = Alignment.Start
        ) {
            Image(
                provider = ImageProvider(R.drawable.ic_widget_logo),
                contentDescription = null,
                modifier = GlanceModifier.size(24.dp)
            )
            Spacer(modifier = GlanceModifier.width(8.dp))
            Text(
                text = "Blackjack Trainer",
                style = TextStyle(
                    color = GlanceTheme.colors.onPrimaryContainer,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold
                )
            )
        }
        
        Spacer(modifier = GlanceModifier.height(12.dp))
        
        // Main stats display
        Column(
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "Overall Accuracy",
                style = TextStyle(
                    color = GlanceTheme.colors.onPrimaryContainer,
                    fontSize = 12.sp
                )
            )
            
            Text(
                text = "${overallStats.accuracy.roundToInt()}%",
                style = TextStyle(
                    color = GlanceTheme.colors.primary,
                    fontSize = 32.sp,
                    fontWeight = FontWeight.Bold
                )
            )
            
            Text(
                text = "${overallStats.totalQuestions} questions answered",
                style = TextStyle(
                    color = GlanceTheme.colors.onPrimaryContainer.copy(alpha = 0.7f),
                    fontSize = 10.sp
                )
            )
        }
        
        Spacer(modifier = GlanceModifier.height(8.dp))
        
        // Recent session indicator
        if (recentSessions.isNotEmpty()) {
            val latestSession = recentSessions.first()
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Last session: ${latestSession.accuracy.roundToInt()}%",
                    style = TextStyle(
                        color = GlanceTheme.colors.onPrimaryContainer,
                        fontSize = 10.sp
                    )
                )
            }
        }
        
        Spacer(modifier = GlanceModifier.height(8.dp))
        
        // Action button
        Button(
            text = "Practice Now",
            onClick = actionStartActivity(
                Intent(context, MainActivity::class.java).apply {
                    action = "START_QUICK_PRACTICE"
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                }
            ),
            style = ButtonDefaults.buttonStyle(
                backgroundColor = GlanceTheme.colors.primary,
                contentColor = GlanceTheme.colors.onPrimary
            ),
            modifier = GlanceModifier.fillMaxWidth()
        )
    }
}

// Widget configuration activity
class BlackjackWidgetConfigActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID
        
        setContent {
            BlackjackTrainerTheme {
                WidgetConfigScreen(
                    appWidgetId = appWidgetId,
                    onConfigComplete = { config ->
                        // Save widget configuration
                        val resultValue = Intent().apply {
                            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                        }
                        setResult(RESULT_OK, resultValue)
                        finish()
                    }
                )
            }
        }
    }
}

@Composable
fun WidgetConfigScreen(
    appWidgetId: Int,
    onConfigComplete: (WidgetConfig) -> Unit
) {
    var selectedTheme by remember { mutableStateOf(WidgetTheme.DYNAMIC) }
    var showDetailedStats by remember { mutableStateOf(true) }
    var updateFrequency by remember { mutableStateOf(WidgetUpdateFrequency.HOURLY) }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Widget Settings") }
            )
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            item {
                Text(
                    text = "Appearance",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold
                )
            }
            
            item {
                WidgetThemeSelector(
                    selectedTheme = selectedTheme,
                    onThemeSelected = { selectedTheme = it }
                )
            }
            
            item {
                SwitchPreference(
                    title = "Show Detailed Stats",
                    subtitle = "Include recent session information",
                    checked = showDetailedStats,
                    onCheckedChange = { showDetailedStats = it }
                )
            }
            
            item {
                Text(
                    text = "Updates",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold
                )
            }
            
            item {
                UpdateFrequencySelector(
                    selectedFrequency = updateFrequency,
                    onFrequencySelected = { updateFrequency = it }
                )
            }
            
            item {
                Spacer(modifier = Modifier.height(32.dp))
                
                Button(
                    onClick = {
                        val config = WidgetConfig(
                            theme = selectedTheme,
                            showDetailedStats = showDetailedStats,
                            updateFrequency = updateFrequency
                        )
                        onConfigComplete(config)
                    },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("Create Widget")
                }
            }
        }
    }
}

data class WidgetConfig(
    val theme: WidgetTheme,
    val showDetailedStats: Boolean,
    val updateFrequency: WidgetUpdateFrequency
)

enum class WidgetTheme {
    DYNAMIC, // Material You colors
    LIGHT,
    DARK,
    HIGH_CONTRAST
}

enum class WidgetUpdateFrequency(val displayName: String, val intervalMillis: Long) {
    REAL_TIME("Real-time", 0L),
    EVERY_15_MIN("Every 15 minutes", 15 * 60 * 1000L),
    HOURLY("Hourly", 60 * 60 * 1000L),
    DAILY("Daily", 24 * 60 * 60 * 1000L)
}

// Advanced App Shortcuts with Dynamic and Pinned Shortcuts
@Singleton
class ShortcutsManager @Inject constructor(
    private val context: Context,
    private val statisticsRepository: StatisticsRepository,
    private val analyticsManager: AnalyticsManager
) {
    
    @RequiresApi(Build.VERSION_CODES.N_MR1)
    suspend fun updateShortcuts() {
        val shortcutManager = context.getSystemService(ShortcutManager::class.java) ?: return
        
        try {
            // Get user's most used training modes from statistics
            val recentStats = statisticsRepository.getRecentSessionsFlow(limit = 10).first()
            val mostUsedMode = recentStats.groupBy { it.sessionType }
                .maxByOrNull { it.value.size }?.key ?: SessionType.RANDOM
            
            val shortcuts = buildList {
                // Quick Practice (always include)
                add(
                    ShortcutInfo.Builder(context, "quick_practice")
                        .setShortLabel("Quick Practice")
                        .setLongLabel("Start Quick Practice Session")
                        .setIcon(Icon.createWithAdaptiveBitmap(
                            createShortcutIcon(R.drawable.ic_shuffle, Color(0xFF2196F3))
                        ))
                        .setIntent(
                            Intent(context, MainActivity::class.java).apply {
                                action = "START_QUICK_PRACTICE"
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                            }
                        )
                        .setRank(0)
                        .build()
                )
                
                // Most used mode (if different from quick practice)
                if (mostUsedMode != SessionType.RANDOM) {
                    add(
                        ShortcutInfo.Builder(context, "favorite_mode")
                            .setShortLabel(mostUsedMode.shortName)
                            .setLongLabel("Start ${mostUsedMode.displayName}")
                            .setIcon(Icon.createWithAdaptiveBitmap(
                                createShortcutIcon(mostUsedMode.iconRes, mostUsedMode.color)
                            ))
                            .setIntent(
                                Intent(context, MainActivity::class.java).apply {
                                    action = "START_FAVORITE_MODE"
                                    putExtra("session_type", mostUsedMode.name)
                                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                                }
                            )
                            .setRank(1)
                            .build()
                    )
                }
                
                // Absolutes Drill (for beginners)
                add(
                    ShortcutInfo.Builder(context, "absolutes_drill")
                        .setShortLabel("Absolutes")
                        .setLongLabel("Practice Absolute Rules")
                        .setIcon(Icon.createWithAdaptiveBitmap(
                            createShortcutIcon(R.drawable.ic_warning, Color(0xFFFF9800))
                        ))
                        .setIntent(
                            Intent(context, MainActivity::class.java).apply {
                                action = "START_ABSOLUTES_DRILL"
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                            }
                        )
                        .setRank(2)
                        .build()
                )
                
                // Statistics shortcut
                add(
                    ShortcutInfo.Builder(context, "view_stats")
                        .setShortLabel("Statistics")
                        .setLongLabel("View Your Progress")
                        .setIcon(Icon.createWithAdaptiveBitmap(
                            createShortcutIcon(R.drawable.ic_bar_chart, Color(0xFF4CAF50))
                        ))
                        .setIntent(
                            Intent(context, MainActivity::class.java).apply {
                                action = "VIEW_STATISTICS"
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                            }
                        )
                        .setRank(3)
                        .build()
                )
            }
            
            shortcutManager.dynamicShortcuts = shortcuts
            analyticsManager.trackEvent(AnalyticsEvent.ShortcutsUpdated(shortcuts.size))
            
        } catch (e: Exception) {
            Timber.e(e, "Failed to update app shortcuts")
            analyticsManager.trackEvent(AnalyticsEvent.ShortcutsUpdateFailed(e.message))
        }
    }
    
    @RequiresApi(Build.VERSION_CODES.O)
    fun createPinnedShortcut(sessionType: SessionType, context: Activity) {
        val shortcutManager = context.getSystemService(ShortcutManager::class.java) ?: return
        
        if (shortcutManager.isRequestPinShortcutSupported) {
            val shortcut = ShortcutInfo.Builder(context, "pinned_${sessionType.name}")
                .setShortLabel(sessionType.shortName)
                .setLongLabel("${sessionType.displayName} Training")
                .setIcon(Icon.createWithAdaptiveBitmap(
                    createShortcutIcon(sessionType.iconRes, sessionType.color)
                ))
                .setIntent(
                    Intent(context, MainActivity::class.java).apply {
                        action = "START_PINNED_SESSION"
                        putExtra("session_type", sessionType.name)
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                    }
                )
                .build()
            
            val pinnedShortcutCallbackIntent = shortcutManager.createShortcutResultIntent(shortcut)
            val successCallback = PendingIntent.getBroadcast(
                context,
                0,
                pinnedShortcutCallbackIntent,
                PendingIntent.FLAG_IMMUTABLE
            )
            
            shortcutManager.requestPinShortcut(shortcut, successCallback.intentSender)
            analyticsManager.trackEvent(AnalyticsEvent.PinnedShortcutRequested(sessionType.name))
        }
    }
    
    private fun createShortcutIcon(@DrawableRes iconRes: Int, color: Color): Bitmap {
        val size = 108 // Adaptive icon size
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        
        // Background circle with Material You color
        val paint = Paint().apply {
            this.color = color.toArgb()
            isAntiAlias = true
        }
        canvas.drawCircle(size / 2f, size / 2f, size / 2f, paint)
        
        // Icon in center
        val drawable = ContextCompat.getDrawable(context, iconRes)
        drawable?.let {
            val iconSize = (size * 0.6f).toInt()
            val iconOffset = (size - iconSize) / 2
            it.setBounds(iconOffset, iconOffset, iconOffset + iconSize, iconOffset + iconSize)
            it.setTint(android.graphics.Color.WHITE)
            it.draw(canvas)
        }
        
        return bitmap
    }
}

// Extension properties for SessionType
val SessionType.shortName: String
    get() = when (this) {
        SessionType.RANDOM -> "Practice"
        SessionType.DEALER_GROUP -> "Dealer"
        SessionType.HAND_TYPE -> "Hands"
        SessionType.ABSOLUTE -> "Rules"
    }

val SessionType.iconRes: Int
    get() = when (this) {
        SessionType.RANDOM -> R.drawable.ic_shuffle
        SessionType.DEALER_GROUP -> R.drawable.ic_group
        SessionType.HAND_TYPE -> R.drawable.ic_back_hand
        SessionType.ABSOLUTE -> R.drawable.ic_warning
    }

val SessionType.color: Color
    get() = when (this) {
        SessionType.RANDOM -> Color(0xFF2196F3)
        SessionType.DEALER_GROUP -> Color(0xFF4CAF50)
        SessionType.HAND_TYPE -> Color(0xFF9C27B0)
        SessionType.ABSOLUTE -> Color(0xFFFF9800)
    }

// Wear OS companion app
@Composable
fun WearTrainingScreen(
    viewModel: WearTrainingViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    
    when (uiState) {
        is WearTrainingViewModel.UiState.Ready -> {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(16.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Text(
                    text = "Hand: ${uiState.scenario.playerTotal}",
                    style = MaterialTheme.typography.titleMedium
                )
                
                Text(
                    text = "Dealer: ${uiState.scenario.dealerCard.displayValue}",
                    style = MaterialTheme.typography.bodyMedium
                )
                
                Spacer(modifier = Modifier.height(8.dp))
                
                // Rotary input for action selection
                var selectedActionIndex by remember { mutableStateOf(0) }
                val actions = Action.values()
                
                Button(
                    onClick = {
                        viewModel.submitAnswer(actions[selectedActionIndex])
                    },
                    modifier = Modifier
                        .fillMaxWidth()
                        .onRotaryScrollEvent { event ->
                            selectedActionIndex = (selectedActionIndex + event.verticalScrollPixels.sign.toInt())
                                .coerceIn(0, actions.size - 1)
                            true
                        }
                ) {
                    Text(actions[selectedActionIndex].displayName)
                }
            }
        }
        
        // Other states...
    }
}

// Notifications for training reminders
class NotificationManager @Inject constructor(
    private val context: Context
) {
    companion object {
        private const val CHANNEL_ID = "training_reminders"
        private const val NOTIFICATION_ID = 1001
    }
    
    init {
        createNotificationChannel()
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Training Reminders",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Reminders to practice blackjack strategy"
                setShowBadge(true)
            }
            
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    fun scheduleTrainingReminder() {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        
        val pendingIntent = PendingIntent.getActivity(
            context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle("Ready to Practice?")
            .setContentText("Keep your blackjack skills sharp with a quick training session.")
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()
        
        // Schedule with WorkManager for reliability
        val workRequest = OneTimeWorkRequestBuilder<TrainingReminderWorker>()
            .setInitialDelay(24, TimeUnit.HOURS)
            .build()
        
        WorkManager.getInstance(context).enqueue(workRequest)
    }
}
```

### Expert Performance Optimizations & Production-Ready Features

```kotlin
// Expert database optimization with comprehensive performance tuning
@Database(
    entities = [
        StrategyChart::class, 
        StatisticRecord::class,
        UserPreferences::class,
        SessionRecord::class,
        CacheEntry::class
    ],
    version = 3,
    exportSchema = true,
    autoMigrations = [
        AutoMigration(from = 1, to = 2),
        AutoMigration(from = 2, to = 3, spec = DatabaseMigration_2_3::class)
    ]
)
@TypeConverters(Converters::class)
abstract class BlackjackDatabase : RoomDatabase() {
    
    companion object {
        // Comprehensive migration strategy
        val MIGRATION_1_2 = object : Migration(1, 2) {
            override fun migrate(database: SupportSQLiteDatabase) {
                // Performance indices
                database.execSQL("CREATE INDEX IF NOT EXISTS index_statistic_records_timestamp ON statistic_records(timestamp)")
                database.execSQL("CREATE INDEX IF NOT EXISTS index_statistic_records_handType ON statistic_records(handType)")
                database.execSQL("CREATE INDEX IF NOT EXISTS index_statistic_records_dealerStrength ON statistic_records(dealerStrength)")
                database.execSQL("CREATE INDEX IF NOT EXISTS index_statistic_records_sessionId ON statistic_records(sessionId)")
                database.execSQL("CREATE INDEX IF NOT EXISTS index_statistic_records_isCorrect ON statistic_records(isCorrect)")
                
                // Composite indices for complex queries
                database.execSQL("CREATE INDEX IF NOT EXISTS index_statistic_records_composite_accuracy ON statistic_records(handType, dealerStrength, isCorrect)")
                database.execSQL("CREATE INDEX IF NOT EXISTS index_statistic_records_composite_time ON statistic_records(timestamp, isCorrect)")
                
                // Add user preferences table
                database.execSQL("""
                    CREATE TABLE IF NOT EXISTS user_preferences (
                        id INTEGER PRIMARY KEY NOT NULL,
                        userName TEXT NOT NULL DEFAULT '',
                        darkModeEnabled INTEGER NOT NULL DEFAULT 0,
                        highContrastEnabled INTEGER NOT NULL DEFAULT 0,
                        hapticFeedbackEnabled INTEGER NOT NULL DEFAULT 1,
                        soundEnabled INTEGER NOT NULL DEFAULT 1,
                        analyticsConsent INTEGER NOT NULL DEFAULT 0,
                        notificationEnabled INTEGER NOT NULL DEFAULT 1,
                        preferredDifficulty TEXT NOT NULL DEFAULT 'NORMAL',
                        trainingReminders INTEGER NOT NULL DEFAULT 1,
                        showHints INTEGER NOT NULL DEFAULT 1,
                        autoAdvance INTEGER NOT NULL DEFAULT 0,
                        sessionLength INTEGER NOT NULL DEFAULT 50,
                        lastUpdated INTEGER NOT NULL
                    )
                """)
                
                // Add session records table
                database.execSQL("""
                    CREATE TABLE IF NOT EXISTS session_records (
                        id TEXT PRIMARY KEY NOT NULL,
                        sessionType TEXT NOT NULL,
                        startTime INTEGER NOT NULL,
                        endTime INTEGER,
                        totalQuestions INTEGER NOT NULL DEFAULT 0,
                        correctAnswers INTEGER NOT NULL DEFAULT 0,
                        completed INTEGER NOT NULL DEFAULT 0,
                        averageResponseTime INTEGER NOT NULL DEFAULT 0,
                        bestStreak INTEGER NOT NULL DEFAULT 0,
                        deviceInfo TEXT,
                        metadata TEXT NOT NULL DEFAULT '{}'
                    )
                """)
                
                database.execSQL("CREATE INDEX IF NOT EXISTS index_session_records_startTime ON session_records(startTime)")
                database.execSQL("CREATE INDEX IF NOT EXISTS index_session_records_sessionType ON session_records(sessionType)")
                database.execSQL("CREATE INDEX IF NOT EXISTS index_session_records_completed ON session_records(completed)")
            }
        }
        
        val MIGRATION_2_3 = object : Migration(2, 3) {
            override fun migrate(database: SupportSQLiteDatabase) {
                // Add caching table for performance optimization
                database.execSQL("""
                    CREATE TABLE IF NOT EXISTS cache_entries (
                        key TEXT PRIMARY KEY NOT NULL,
                        value TEXT NOT NULL,
                        expiration INTEGER NOT NULL,
                        created INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
                    )
                """)
                
                database.execSQL("CREATE INDEX IF NOT EXISTS index_cache_entries_expiration ON cache_entries(expiration)")
                
                // Add performance monitoring columns
                database.execSQL("ALTER TABLE statistic_records ADD COLUMN responseTime INTEGER NOT NULL DEFAULT 0")
                database.execSQL("ALTER TABLE statistic_records ADD COLUMN difficultyLevel TEXT NOT NULL DEFAULT 'NORMAL'")
                database.execSQL("ALTER TABLE statistic_records ADD COLUMN scenarioComplexity TEXT NOT NULL DEFAULT 'BASIC'")
                database.execSQL("ALTER TABLE statistic_records ADD COLUMN userConfidence REAL")
                database.execSQL("ALTER TABLE statistic_records ADD COLUMN hintUsed INTEGER NOT NULL DEFAULT 0")
                database.execSQL("ALTER TABLE statistic_records ADD COLUMN deviceInfo TEXT")
                database.execSQL("ALTER TABLE statistic_records ADD COLUMN appVersion TEXT")
            }
        }
    }
}

@DeleteColumn.Entries(
    DeleteColumn(tableName = "statistic_records", columnName = "old_column")
)
class DatabaseMigration_2_3 : AutoMigrationSpec

// Cache entity for performance optimization
@Entity(
    tableName = "cache_entries",
    indices = [Index(value = ["expiration"])]
)
data class CacheEntry(
    @PrimaryKey val key: String,
    val value: String,
    val expiration: Long,
    val created: Long = System.currentTimeMillis()
)

@Dao
interface CacheDao {
    @Query("SELECT * FROM cache_entries WHERE key = :key AND expiration > :currentTime")
    suspend fun getCacheEntry(key: String, currentTime: Long = System.currentTimeMillis()): CacheEntry?
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertCacheEntry(entry: CacheEntry)
    
    @Query("DELETE FROM cache_entries WHERE expiration <= :currentTime")
    suspend fun deleteExpiredEntries(currentTime: Long = System.currentTimeMillis())
    
    @Query("DELETE FROM cache_entries WHERE key LIKE :keyPattern")
    suspend fun deleteCacheByPattern(keyPattern: String)
}

// Advanced memory management with comprehensive object pooling and lifecycle management
@Singleton
class MemoryManager @Inject constructor(
    private val performanceMonitor: PerformanceMonitor,
    private val analyticsManager: AnalyticsManager,
    @ApplicationScope private val applicationScope: CoroutineScope
) {
    
    // Object pools for frequent allocations
    private val scenarioPool = ObjectPool<GameScenario>(
        factory = { GameScenario.empty() },
        reset = { scenario ->
            scenario.copy(
                id = UUID.randomUUID().toString(),
                playerCards = emptyList(),
                playerTotal = 0,
                timestamp = System.currentTimeMillis(),
                metadata = ScenarioMetadata()
            )
        },
        maxSize = 100
    )
    
    private val cardPool = ObjectPool<Card>(
        factory = { Card.ACE_SPADES },
        reset = { it }, // Cards are immutable
        maxSize = 200
    )
    
    private val statisticRecordPool = ObjectPool<StatisticRecord>(
        factory = { 
            StatisticRecord(
                handType = HandType.HARD,
                dealerStrength = DealerStrength.MEDIUM,
                isCorrect = false,
                timestamp = 0L,
                sessionId = "",
                responseTime = 0L,
                difficultyLevel = DifficultyLevel.NORMAL,
                scenarioComplexity = ComplexityLevel.BASIC
            )
        },
        reset = { record ->
            record.copy(
                id = UUID.randomUUID().toString(),
                timestamp = 0L,
                sessionId = "",
                responseTime = 0L,
                userConfidence = null,
                hintUsed = false
            )
        },
        maxSize = 50
    )
    
    // Memory monitoring
    private var lastGcTime = 0L
    private val memoryThresholdBytes = 50 * 1024 * 1024 // 50MB
    
    init {
        // Start memory monitoring
        applicationScope.launch {
            while (true) {
                delay(30_000) // Check every 30 seconds
                checkMemoryUsage()
            }
        }
    }
    
    fun borrowScenario(): GameScenario = scenarioPool.borrow()
    fun returnScenario(scenario: GameScenario) = scenarioPool.return(scenario)
    
    fun borrowCard(): Card = cardPool.borrow()
    fun returnCard(card: Card) = cardPool.return(card)
    
    fun borrowStatisticRecord(): StatisticRecord = statisticRecordPool.borrow()
    fun returnStatisticRecord(record: StatisticRecord) = statisticRecordPool.return(record)
    
    private suspend fun checkMemoryUsage() {
        val runtime = Runtime.getRuntime()
        val usedMemory = runtime.totalMemory() - runtime.freeMemory()
        val maxMemory = runtime.maxMemory()
        val memoryUsagePercent = (usedMemory.toDouble() / maxMemory * 100).toInt()
        
        performanceMonitor.recordMemoryUsage(usedMemory, maxMemory)
        
        if (usedMemory > memoryThresholdBytes && System.currentTimeMillis() - lastGcTime > 60_000) {
            // Suggest garbage collection if memory usage is high
            System.gc()
            lastGcTime = System.currentTimeMillis()
            
            analyticsManager.trackEvent(
                AnalyticsEvent.MemoryPressure(memoryUsagePercent, usedMemory)
            )
            
            // Clear object pools if memory pressure is severe
            if (memoryUsagePercent > 80) {
                clearPools()
            }
        }
    }
    
    private fun clearPools() {
        scenarioPool.clear()
        cardPool.clear()
        statisticRecordPool.clear()
        
        analyticsManager.trackEvent(AnalyticsEvent.PoolsCleared)
    }
    
    fun getMemoryStats(): MemoryStats {
        val runtime = Runtime.getRuntime()
        return MemoryStats(
            usedMemory = runtime.totalMemory() - runtime.freeMemory(),
            maxMemory = runtime.maxMemory(),
            scenarioPoolSize = scenarioPool.size(),
            cardPoolSize = cardPool.size(),
            statisticPoolSize = statisticRecordPool.size()
        )
    }
}

// Generic object pool implementation
class ObjectPool<T>(
    private val factory: () -> T,
    private val reset: (T) -> T,
    private val maxSize: Int
) {
    private val available = ConcurrentLinkedQueue<T>()
    private val activeCount = AtomicInteger(0)
    
    fun borrow(): T {
        activeCount.incrementAndGet()
        return available.poll() ?: factory()
    }
    
    fun return(item: T) {
        activeCount.decrementAndGet()
        if (available.size < maxSize) {
            val resetItem = reset(item)
            available.offer(resetItem)
        }
    }
    
    fun size(): Int = available.size
    fun activeSize(): Int = activeCount.get()
    
    fun clear() {
        available.clear()
        activeCount.set(0)
    }
}

data class MemoryStats(
    val usedMemory: Long,
    val maxMemory: Long,
    val scenarioPoolSize: Int,
    val cardPoolSize: Int,
    val statisticPoolSize: Int
) {
    val memoryUsagePercent: Int get() = (usedMemory.toDouble() / maxMemory * 100).toInt()
    val availableMemory: Long get() = maxMemory - usedMemory
}

// Advanced analytics with comprehensive privacy compliance and GDPR support
@Singleton
class AnalyticsManager @Inject constructor(
    private val preferences: SharedPreferences,
    private val logger: AppLogger,
    private val context: Context,
    private val encryptionManager: EncryptionManager,
    @ApplicationScope private val applicationScope: CoroutineScope
) {
    
    private val consentKey = "analytics_consent"
    private val dataRetentionDays = 90L
    private val batchSize = 50
    private val analyticsQueue = mutableListOf<AnalyticsEvent>()
    private val queueMutex = Mutex()
    
    // Privacy-compliant user ID (generated, not tied to device)
    private val anonymousUserId: String by lazy {
        preferences.getString("anonymous_user_id", null) ?: run {
            val id = UUID.randomUUID().toString()
            preferences.edit().putString("anonymous_user_id", id).apply()
            id
        }
    }
    
    init {
        // Start background processing of analytics events
        applicationScope.launch {
            while (true) {
                delay(30_000) // Process every 30 seconds
                processAnalyticsQueue()
            }
        }
        
        // Clean up old analytics data
        applicationScope.launch {
            while (true) {
                delay(24 * 60 * 60 * 1000) // Daily cleanup
                cleanupOldAnalyticsData()
            }
        }
    }
    
    fun hasAnalyticsConsent(): Boolean = preferences.getBoolean(consentKey, false)
    
    fun setAnalyticsConsent(consent: Boolean) {
        preferences.edit().putBoolean(consentKey, consent).apply()
        
        if (!consent) {
            // Clear all stored analytics data when user revokes consent
            clearAllAnalyticsData()
        }
        
        trackEvent(AnalyticsEvent.ConsentChanged(consent))
    }
    
    fun trackEvent(event: AnalyticsEvent) {
        if (!hasAnalyticsConsent() && event !is AnalyticsEvent.ConsentChanged) return
        
        applicationScope.launch {
            queueMutex.withLock {
                // Add timestamp and session info to event
                val enrichedEvent = enrichEvent(event)
                analyticsQueue.add(enrichedEvent)
                
                // Process immediately if queue is full
                if (analyticsQueue.size >= batchSize) {
                    processAnalyticsQueue()
                }
            }
        }
    }
    
    private suspend fun processAnalyticsQueue() {
        queueMutex.withLock {
            if (analyticsQueue.isEmpty()) return@withLock
            
            val eventsToProcess = analyticsQueue.toList()
            analyticsQueue.clear()
            
            // Process events in background
            withContext(Dispatchers.IO) {
                eventsToProcess.forEach { event ->
                    processEvent(event)
                }
            }
        }
    }
    
    private fun processEvent(event: AnalyticsEvent) {
        try {
            val eventData = when (event) {
                is AnalyticsEvent.SessionStarted -> mapOf(
                    "event_type" to "session_started",
                    "session_type" to event.sessionType.name,
                    "difficulty" to event.difficulty?.name,
                    "timestamp" to event.timestamp
                )
                
                is AnalyticsEvent.SessionCompleted -> mapOf(
                    "event_type" to "session_completed",
                    "session_type" to event.sessionType.name,
                    "accuracy" to event.accuracy,
                    "duration_ms" to event.duration,
                    "questions_answered" to event.questionsAnswered,
                    "streak_best" to event.bestStreak,
                    "timestamp" to event.timestamp
                )
                
                is AnalyticsEvent.ActionSelected -> mapOf(
                    "event_type" to "action_selected",
                    "action" to event.action,
                    "hand_type" to event.handType.name,
                    "dealer_card" to event.dealerCard,
                    "response_time_ms" to event.responseTime,
                    "is_correct" to event.isCorrect,
                    "timestamp" to event.timestamp
                )
                
                is AnalyticsEvent.ErrorOccurred -> mapOf(
                    "event_type" to "error_occurred",
                    "error_type" to event.errorType,
                    "error_message" to event.message?.take(100), // Limit error message length
                    "screen" to event.screen,
                    "user_action" to event.userAction,
                    "timestamp" to event.timestamp
                )
                
                is AnalyticsEvent.PerformanceMetric -> mapOf(
                    "event_type" to "performance_metric",
                    "metric_name" to event.metricName,
                    "metric_value" to event.value,
                    "context" to event.context,
                    "timestamp" to event.timestamp
                )
                
                is AnalyticsEvent.UserEngagement -> mapOf(
                    "event_type" to "user_engagement",
                    "engagement_type" to event.engagementType,
                    "duration_ms" to event.duration,
                    "screen" to event.screen,
                    "timestamp" to event.timestamp
                )
                
                else -> mapOf(
                    "event_type" to "unknown",
                    "timestamp" to System.currentTimeMillis()
                )
            }
            
            // Add common properties
            val commonData = mapOf(
                "user_id" to anonymousUserId,
                "app_version" to getAppVersion(),
                "device_model" to Build.MODEL,
                "android_version" to Build.VERSION.RELEASE,
                "session_id" to getCurrentSessionId()
            )
            
            val finalEventData = eventData + commonData
            
            // Log locally (encrypted if sensitive)
            if (event.isSensitive) {
                logger.logEventEncrypted("analytics_event", finalEventData, encryptionManager)
            } else {
                logger.logEvent("analytics_event", finalEventData)
            }
            
            // Send to analytics service (if implemented)
            // sendToAnalyticsService(finalEventData)
            
        } catch (e: Exception) {
            logger.logError("Failed to process analytics event", e)
        }
    }
    
    private fun enrichEvent(event: AnalyticsEvent): AnalyticsEvent {
        return when (event) {
            is AnalyticsEvent.SessionStarted -> event.copy(
                timestamp = System.currentTimeMillis()
            )
            is AnalyticsEvent.SessionCompleted -> event.copy(
                timestamp = System.currentTimeMillis()
            )
            is AnalyticsEvent.ActionSelected -> event.copy(
                timestamp = System.currentTimeMillis()
            )
            else -> event
        }
    }
    
    private fun getAppVersion(): String {
        return try {
            context.packageManager.getPackageInfo(context.packageName, 0).versionName
        } catch (e: Exception) {
            "unknown"
        }
    }
    
    private fun getCurrentSessionId(): String {
        // Implementation depends on session management
        return preferences.getString("current_session_id", "unknown") ?: "unknown"
    }
    
    private suspend fun cleanupOldAnalyticsData() {
        val cutoffTime = System.currentTimeMillis() - (dataRetentionDays * 24 * 60 * 60 * 1000)
        
        try {
            // Clear old analytics logs
            logger.clearOldLogs(cutoffTime)
        } catch (e: Exception) {
            logger.logError("Failed to cleanup old analytics data", e)
        }
    }
    
    private fun clearAllAnalyticsData() {
        try {
            // Clear all analytics-related data
            logger.clearAllAnalyticsLogs()
            preferences.edit().remove("anonymous_user_id").apply()
        } catch (e: Exception) {
            logger.logError("Failed to clear analytics data", e)
        }
    }
    
    // GDPR compliance methods
    fun exportUserData(): String {
        if (!hasAnalyticsConsent()) return "No data available - analytics not consented"
        
        return try {
            val userData = mapOf(
                "anonymous_user_id" to anonymousUserId,
                "consent_status" to hasAnalyticsConsent(),
                "data_retention_days" to dataRetentionDays,
                "analytics_events" to logger.getAnalyticsLogs()
            )
            
            Json.encodeToString(userData)
        } catch (e: Exception) {
            "Error exporting user data: ${e.message}"
        }
    }
    
    fun deleteAllUserData() {
        clearAllAnalyticsData()
        setAnalyticsConsent(false)
        
        // Reset anonymous user ID
        preferences.edit().remove("anonymous_user_id").apply()
    }
}

// Enhanced analytics event hierarchy
sealed class AnalyticsEvent {
    abstract val timestamp: Long
    abstract val isSensitive: Boolean
    
    data class SessionStarted(
        val sessionType: SessionType,
        val difficulty: DifficultyLevel? = null,
        override val timestamp: Long = System.currentTimeMillis()
    ) : AnalyticsEvent() {
        override val isSensitive: Boolean = false
    }
    
    data class SessionCompleted(
        val sessionType: SessionType,
        val accuracy: Double,
        val duration: Long,
        val questionsAnswered: Int,
        val bestStreak: Int,
        override val timestamp: Long = System.currentTimeMillis()
    ) : AnalyticsEvent() {
        override val isSensitive: Boolean = false
    }
    
    data class ActionSelected(
        val action: String,
        val handType: HandType,
        val dealerCard: Int,
        val responseTime: Long,
        val isCorrect: Boolean,
        override val timestamp: Long = System.currentTimeMillis()
    ) : AnalyticsEvent() {
        override val isSensitive: Boolean = false
    }
    
    data class ErrorOccurred(
        val errorType: String,
        val message: String?,
        val screen: String,
        val userAction: String?,
        override val timestamp: Long = System.currentTimeMillis()
    ) : AnalyticsEvent() {
        override val isSensitive: Boolean = true
    }
    
    data class PerformanceMetric(
        val metricName: String,
        val value: Long,
        val context: String,
        override val timestamp: Long = System.currentTimeMillis()
    ) : AnalyticsEvent() {
        override val isSensitive: Boolean = false
    }
    
    data class UserEngagement(
        val engagementType: String,
        val duration: Long,
        val screen: String,
        override val timestamp: Long = System.currentTimeMillis()
    ) : AnalyticsEvent() {
        override val isSensitive: Boolean = false
    }
    
    data class ConsentChanged(
        val consentGiven: Boolean,
        override val timestamp: Long = System.currentTimeMillis()
    ) : AnalyticsEvent() {
        override val isSensitive: Boolean = false
    }
    
    // Additional events for comprehensive tracking
    data class ScreenView(
        val screenName: String,
        override val timestamp: Long = System.currentTimeMillis()
    ) : AnalyticsEvent() {
        override val isSensitive: Boolean = false
    }
    
    data class FeatureUsed(
        val featureName: String,
        val parameters: Map<String, Any> = emptyMap(),
        override val timestamp: Long = System.currentTimeMillis()
    ) : AnalyticsEvent() {
        override val isSensitive: Boolean = false
    }
    
    data class AppLaunched(
        val launchType: String, // cold, warm, hot
        val launchTime: Long,
        override val timestamp: Long = System.currentTimeMillis()
    ) : AnalyticsEvent() {
        override val isSensitive: Boolean = false
    }
    
    data class AppBackgrounded(
        val sessionDuration: Long,
        override val timestamp: Long = System.currentTimeMillis()
    ) : AnalyticsEvent() {
        override val isSensitive: Boolean = false
    }
}

// Advanced crash reporting and error handling with contextual information
@Singleton
class CrashReporter @Inject constructor(
    private val logger: AppLogger,
    private val analyticsManager: AnalyticsManager,
    private val context: Context,
    private val memoryManager: MemoryManager
) {
    
    private val maxCrashReports = 50
    private val crashReports = mutableListOf<CrashReport>()
    private val crashReportsMutex = Mutex()
    
    suspend fun reportCrash(throwable: Throwable, context: String, userAction: String? = null) {
        val crashReport = createCrashReport(throwable, context, userAction, isFatal = true)
        
        crashReportsMutex.withLock {
            crashReports.add(crashReport)
            if (crashReports.size > maxCrashReports) {
                crashReports.removeFirst()
            }
        }
        
        logger.logError("Fatal crash in $context", throwable)
        
        analyticsManager.trackEvent(
            AnalyticsEvent.ErrorOccurred(
                errorType = "fatal_crash",
                message = throwable.message,
                screen = context,
                userAction = userAction
            )
        )
        
        // In production, integrate with Firebase Crashlytics or similar
        // FirebaseCrashlytics.getInstance().recordException(throwable)
        // FirebaseCrashlytics.getInstance().setCustomKey("context", context)
        // FirebaseCrashlytics.getInstance().setCustomKey("user_action", userAction ?: "unknown")
    }
    
    suspend fun reportNonFatalError(
        throwable: Throwable, 
        context: String, 
        userAction: String? = null,
        recoveryAction: String? = null
    ) {
        val crashReport = createCrashReport(throwable, context, userAction, isFatal = false)
        crashReport.recoveryAction = recoveryAction
        
        crashReportsMutex.withLock {
            crashReports.add(crashReport)
            if (crashReports.size > maxCrashReports) {
                crashReports.removeFirst()
            }
        }
        
        logger.logWarning("Non-fatal error in $context", throwable)
        
        analyticsManager.trackEvent(
            AnalyticsEvent.ErrorOccurred(
                errorType = "non_fatal_error",
                message = throwable.message,
                screen = context,
                userAction = userAction
            )
        )
        
        // FirebaseCrashlytics.getInstance().recordException(throwable)
    }
    
    private suspend fun createCrashReport(
        throwable: Throwable,
        context: String,
        userAction: String?,
        isFatal: Boolean
    ): CrashReport {
        val memoryStats = memoryManager.getMemoryStats()
        
        return CrashReport(
            id = UUID.randomUUID().toString(),
            timestamp = System.currentTimeMillis(),
            throwable = throwable,
            context = context,
            userAction = userAction,
            isFatal = isFatal,
            deviceInfo = DeviceInfo(
                model = Build.MODEL,
                manufacturer = Build.MANUFACTURER,
                androidVersion = Build.VERSION.RELEASE,
                apiLevel = Build.VERSION.SDK_INT,
                appVersion = getAppVersion(),
                memoryUsed = memoryStats.usedMemory,
                memoryMax = memoryStats.maxMemory,
                memoryPercent = memoryStats.memoryUsagePercent,
                batteryLevel = getBatteryLevel(),
                networkType = getNetworkType(),
                screenDensity = context.resources.displayMetrics.density,
                screenWidth = context.resources.displayMetrics.widthPixels,
                screenHeight = context.resources.displayMetrics.heightPixels
            ),
            stackTrace = throwable.stackTraceToString(),
            breadcrumbs = getBreadcrumbs()
        )
    }
    
    private fun getAppVersion(): String {
        return try {
            context.packageManager.getPackageInfo(context.packageName, 0).versionName
        } catch (e: Exception) {
            "unknown"
        }
    }
    
    private fun getBatteryLevel(): Int {
        return try {
            val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } catch (e: Exception) {
            -1
        }
    }
    
    private fun getNetworkType(): String {
        return try {
            val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            val activeNetwork = connectivityManager.activeNetwork
            val networkCapabilities = connectivityManager.getNetworkCapabilities(activeNetwork)
            
            when {
                networkCapabilities?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true -> "WiFi"
                networkCapabilities?.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) == true -> "Cellular"
                networkCapabilities?.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) == true -> "Ethernet"
                else -> "Unknown"
            }
        } catch (e: Exception) {
            "Unknown"
        }
    }
    
    private fun getBreadcrumbs(): List<Breadcrumb> {
        // Implementation would track user actions leading up to the crash
        // This is a simplified version
        return emptyList()
    }
    
    suspend fun getCrashReports(): List<CrashReport> {
        return crashReportsMutex.withLock {
            crashReports.toList()
        }
    }
    
    suspend fun clearCrashReports() {
        crashReportsMutex.withLock {
            crashReports.clear()
        }
    }
}

data class CrashReport(
    val id: String,
    val timestamp: Long,
    val throwable: Throwable,
    val context: String,
    val userAction: String?,
    val isFatal: Boolean,
    val deviceInfo: DeviceInfo,
    val stackTrace: String,
    val breadcrumbs: List<Breadcrumb>,
    var recoveryAction: String? = null
)

data class DeviceInfo(
    val model: String,
    val manufacturer: String,
    val androidVersion: String,
    val apiLevel: Int,
    val appVersion: String,
    val memoryUsed: Long,
    val memoryMax: Long,
    val memoryPercent: Int,
    val batteryLevel: Int,
    val networkType: String,
    val screenDensity: Float,
    val screenWidth: Int,
    val screenHeight: Int
)

data class Breadcrumb(
    val timestamp: Long,
    val action: String,
    val screen: String,
    val data: Map<String, String> = emptyMap()
)

// ProGuard/R8 rules for release builds
"""
# Keep strategy data classes
-keep class com.blackjacktrainer.data.model.** { *; }

# Keep session management classes
-keep class * extends java.lang.Enum { *; }
-keep class com.blackjacktrainer.data.model.** { *; }
-keep class com.blackjacktrainer.data.persistence.** { *; }

# Keep Hilt generated classes
-keep class dagger.hilt.** { *; }
-keep class * extends dagger.hilt.android.lifecycle.HiltViewModel

# Keep Kotlin coroutines
-keepclassmembers class kotlinx.coroutines.** {
    volatile <fields>;
}
"""
```

### Expert Accessibility Implementation with Universal Design Principles

```kotlin
// Accessibility service integration
@Composable
fun AccessibilityEnhancedTrainingScreen(
    scenario: GameScenario,
    onActionSelected: (Action) -> Unit
) {
    val context = LocalContext.current
    val talkBackEnabled = remember {
        val accessibilityManager = context.getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager
        accessibilityManager.isEnabled && accessibilityManager.isTouchExplorationEnabled
    }
    
    LaunchedEffect(scenario) {
        if (talkBackEnabled) {
            // Announce new scenario
            val announcement = "New practice scenario: Your ${scenario.handType.displayName} ${scenario.playerTotal} versus dealer ${scenario.dealerCard.displayValue}"
            announceForAccessibility(context, announcement)
        }
    }
    
    Column(
        modifier = Modifier
            .fillMaxSize()
            .semantics {
                contentDescription = "Blackjack training session"
            }
    ) {
        ScenarioDisplay(
            scenario = scenario,
            modifier = Modifier
                .weight(1f)
                .semantics {
                    heading()
                    contentDescription = "Current hand: ${scenario.handType.displayName} ${scenario.playerTotal} versus dealer ${scenario.dealerCard.displayValue}"
                }
        )
        
        ActionButtons(
            onActionSelected = onActionSelected,
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
                .semantics {
                    heading()
                    contentDescription = "Choose your action"
                }
        )
    }
}

private fun announceForAccessibility(context: Context, text: String) {
    val accessibilityManager = context.getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager
    if (accessibilityManager.isEnabled) {
        val event = AccessibilityEvent.obtain(AccessibilityEvent.TYPE_ANNOUNCEMENT).apply {
            this.text.add(text)
            packageName = context.packageName
        }
        accessibilityManager.sendAccessibilityEvent(event)
    }
}

// Voice commands integration
class VoiceCommandProcessor @Inject constructor() {
    
    fun processVoiceCommand(command: String): Action? {
        return when (command.lowercase().trim()) {
            "hit", "take card", "card" -> Action.HIT
            "stand", "stay", "keep" -> Action.STAND
            "double", "double down" -> Action.DOUBLE
            "split", "separate" -> Action.SPLIT
            else -> null
        }
    }
}

// High contrast theme support
@Composable
fun BlackjackTrainerTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    highContrast: Boolean = false,
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        highContrast && darkTheme -> highContrastDarkColorScheme()
        highContrast && !darkTheme -> highContrastLightColorScheme()
        darkTheme -> darkColorScheme()
        else -> lightColorScheme()
    }
    
    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography(),
        content = content
    )
}

private fun highContrastLightColorScheme() = lightColorScheme(
    primary = Color.Black,
    onPrimary = Color.White,
    secondary = Color.Black,
    onSecondary = Color.White,
    background = Color.White,
    onBackground = Color.Black,
    surface = Color.White,
    onSurface = Color.Black
)

private fun highContrastDarkColorScheme() = darkColorScheme(
    primary = Color.White,
    onPrimary = Color.Black,
    secondary = Color.White,
    onSecondary = Color.Black,
    background = Color.Black,
    onBackground = Color.White,
    surface = Color.Black,
    onSurface = Color.White
)
```

## Implementation Roadmap

### Phase 1: Architecture Foundation (3-4 weeks)
**Target**: Robust Android architecture with modern patterns

- [ ] Create Android Studio project with Kotlin and Jetpack Compose
- [ ] Implement Hilt dependency injection setup
- [ ] Build data layer with SharedPreferences session management
- [ ] Create repository pattern with coroutines and Flow
- [ ] Implement strategy chart data models with error handling
- [ ] Set up comprehensive logging with Timber
- [ ] Create unit testing framework with MockK and Turbine
- [ ] Add CI/CD pipeline with GitHub Actions

### Phase 2: Core Training Engine (3-4 weeks)
**Target**: All 4 training modes with performance optimization

- [ ] Implement scenario generation with caching and object pooling
- [ ] Build all training session types with proper state management
- [ ] Add comprehensive feedback system with mnemonics
- [ ] Implement session-only statistics with lifecycle management
- [ ] Add progress tracking with SharedPreferences session backup
- [ ] Create performance monitoring with profiling
- [ ] Implement memory leak detection and optimization
- [ ] Add crash reporting integration

### Phase 3: Modern Android UI (2-3 weeks)
**Target**: Production-ready Jetpack Compose interface

- [ ] Implement Material Design 3 theming system
- [ ] Create adaptive layouts for phones and tablets
- [ ] Add comprehensive accessibility support (TalkBack, Switch Access)
- [ ] Implement smooth animations and haptic feedback
- [ ] Build navigation with Navigation Compose
- [ ] Add Dark Mode and high contrast theme support
- [ ] Create statistics visualizations with custom charts
- [ ] Implement responsive design patterns

### Phase 4: Android Platform Integration (2-3 weeks)
**Target**: Full Android ecosystem integration

- [ ] Add App Shortcuts for quick session access
- [ ] Implement App Widgets for statistics display
- [ ] Create Wear OS companion app with rotary input
- [ ] Add notification system with WorkManager
- [ ] Implement privacy-compliant analytics with user consent
- [ ] Add voice command support with Speech Recognition
- [ ] Create sharing functionality for progress
- [ ] Implement backup and restore with Android Backup Service

### Phase 5: Production Readiness (1-2 weeks)
**Target**: Google Play Store submission ready

- [ ] Comprehensive testing (unit, integration, UI with Espresso)
- [ ] Performance profiling with Android Profiler
- [ ] Security audit and penetration testing
- [ ] ProGuard/R8 optimization for release builds
- [ ] Play Console assets and store listing preparation
- [ ] Beta testing with Google Play Internal Testing
- [ ] Final submission and Google Play approval
- [ ] Post-launch monitoring setup

### Phase 6: Advanced Features (Optional - Post Launch)
**Target**: Premium functionality and user growth

- [ ] Cloud backup with Google Drive API integration
- [ ] Advanced analytics dashboard with Firebase Analytics
- [ ] Gamification with achievements and leaderboards
- [ ] Social features with Play Games Services
- [ ] Advanced training modes with machine learning personalization
- [ ] In-app purchases for premium features
- [ ] Multi-language support and localization
- [ ] Tablet-optimized layouts and features

## Technical Specifications

**Minimum Android Version**: Android 7.0 (API 24)+  
**Target Android Version**: Android 14 (API 34)  
**Development Tools**: Android Studio Hedgehog+, Kotlin 1.9+  
**Architecture**: MVVM + Repository with Jetpack Compose, Coroutines, and Flow  
**Persistence**: Session-only with SharedPreferences for lifecycle management, Google Drive Backup (Phase 6)  
**Testing**: JUnit, MockK, Turbine, Espresso, Robolectric  
**Performance**: Android Profiler, LeakCanary, Performance monitoring  
**Analytics**: Privacy-compliant local analytics with optional Firebase

**Production Project Structure**:
```
app/
├── src/
│   ├── main/
│   │   ├── java/com/blackjacktrainer/
│   │   │   ├── data/
│   │   │   │   ├── persistence/       # SharedPreferences and session management
│   │   │   │   ├── repository/        # Repository implementations
│   │   │   │   └── model/             # Data models and session classes
│   │   │   ├── domain/
│   │   │   │   ├── usecase/           # Business logic use cases
│   │   │   │   └── repository/        # Repository interfaces
│   │   │   ├── presentation/
│   │   │   │   ├── ui/
│   │   │   │   │   ├── training/      # Training session screens
│   │   │   │   │   ├── statistics/    # Statistics screens
│   │   │   │   │   ├── settings/      # Settings screens
│   │   │   │   │   └── common/        # Reusable UI components
│   │   │   │   └── viewmodel/         # ViewModels for each screen
│   │   │   ├── di/                    # Hilt dependency injection modules
│   │   │   ├── util/                  # Utility classes and extensions
│   │   │   └── BlackjackTrainerApplication.kt
│   │   ├── res/
│   │   │   ├── layout/                # XML layouts (if any)
│   │   │   ├── values/                # Strings, colors, themes
│   │   │   ├── drawable/              # Vector graphics and images
│   │   │   └── raw/                   # Strategy data JSON
│   │   └── AndroidManifest.xml
│   ├── test/                          # Unit tests
│   │   └── java/com/blackjacktrainer/
│   └── androidTest/                   # Integration tests
│       └── java/com/blackjacktrainer/
├── wear/                              # Wear OS app module
│   ├── src/main/java/com/blackjacktrainer/wear/
│   └── src/main/res/
├── build.gradle.kts                   # App-level build configuration
├── proguard-rules.pro                 # ProGuard rules for release
└── README.md
```

## Google Play Store Optimization

### App Store Listing Strategy

**App Title**: "Blackjack Strategy Trainer - Learn Basic Strategy"  
**Short Description**: "Master blackjack basic strategy with interactive training sessions"  
**Long Description**:
```
Master blackjack basic strategy with the most comprehensive training app available! 

🃏 COMPLETE STRATEGY COVERAGE
• Hard totals, soft totals, and pairs
• All standard casino rules (4-8 decks, dealer stands soft 17)
• Mathematical optimal play for minimum house edge

🎯 SMART TRAINING MODES
• Quick Practice: Mixed scenarios from all categories
• Dealer Strength Groups: Focus on weak/medium/strong dealer cards
• Hand Type Focus: Master hard totals, soft totals, or pairs separately  
• Absolutes Drill: Never/always rules for instant recognition

📊 DETAILED PROGRESS TRACKING
• Real-time accuracy statistics
• Performance by hand type and dealer strength
• Session history and improvement trends
• Identify weak areas for focused practice

🎨 MODERN ANDROID EXPERIENCE
• Beautiful Material Design 3 interface
• Dark mode and high contrast support
• Phone and tablet optimized layouts
• Haptic feedback and smooth animations

♿ ACCESSIBILITY FIRST
• Full TalkBack and Switch Access support
• Voice command recognition
• High contrast themes
• Comprehensive screen reader descriptions

⌚ WEAR OS COMPANION
• Practice on your smartwatch
• Rotary input support
• Synchronized progress tracking

🔒 PRIVACY FOCUSED
• All data stored locally on your device
• Optional analytics with user consent
• No account required, works offline

Perfect for beginners learning basic strategy or experienced players maintaining their skills. Based on mathematically proven optimal play strategies used by professional players worldwide.

Download now and start reducing the house edge!
```

**Keywords**: blackjack, basic strategy, card counting, casino, training, practice, cards, gambling, strategy trainer

### Monetization Strategy (Post-Launch)

**Free Version**:
- All 4 training modes with limited sessions (10 per day)
- Basic statistics tracking
- Ad-supported with banner ads

**Premium Version** ($4.99 one-time purchase):
- Unlimited training sessions
- Advanced statistics with historical trends
- Cloud backup and sync
- Ad-free experience
- Exclusive training modes
- Strategy guide with detailed explanations

**Subscription Model** ($1.99/month or $9.99/year):
- All premium features
- Personalized AI coaching
- Advanced analytics dashboard  
- Priority customer support
- Early access to new features

## Success Metrics & KPIs

**User Engagement**:
- Daily Active Users (DAU) > 1,000 within 6 months
- Session duration > 5 minutes average
- User retention rate > 40% after 7 days
- Training completion rate > 80%

**App Store Performance**:
- Average rating > 4.5 stars
- Download growth rate > 10% month-over-month
- Featured in "Educational" or "Casino" categories
- Organic search ranking in top 10 for "blackjack strategy"

**Technical Performance**:
- App startup time < 2 seconds
- Memory usage < 100MB during training
- Crash rate < 0.1%
- Battery usage optimization rating > 4.0

**Revenue Goals** (Premium Version):
- Conversion rate > 5% from free to premium
- Monthly recurring revenue > $5,000 by year 1
- Customer lifetime value > $15
- Refund rate < 2%

## Summary

This Android implementation plan transforms the proven Python blackjack trainer into a modern, production-ready Android application that leverages the full power of the Android ecosystem:

**Core Strengths Preserved**:
- Complete basic strategy implementation with mathematical accuracy
- 4 distinct training modes (Random, Dealer Groups, Hand Types, Absolutes)
- Comprehensive statistics tracking and progress analytics  
- Educational mnemonics and pattern reinforcement system

**Android-Specific Enhancements**:
- Native Jetpack Compose UI with Material Design 3
- Session-only persistence with SharedPreferences for lifecycle management
- Kotlin coroutines and Flow for reactive programming
- Hilt dependency injection for maintainable architecture
- Comprehensive accessibility support exceeding Android guidelines
- Full Android ecosystem integration (widgets, shortcuts, Wear OS)

**Production-Ready Features**:
- Performance optimizations with caching and object pooling
- Privacy-compliant analytics with user consent
- Crash reporting and comprehensive error handling
- ProGuard optimization and security hardening
- Google Play Store optimization and monetization strategy

**Development Timeline**: 10-19 weeks for production-ready implementation
- **Core Implementation**: 10-13 weeks (Phases 1-5)
- **Advanced Features**: Additional 6-8 weeks (Phase 6)
- **Total to Google Play**: 3-4 months for professional release

**Expert Assessment**: This plan creates a premium Android application that not only matches the educational value of the Python trainer but significantly exceeds it through native Android advantages. The architecture follows modern Android development best practices with:

- **Enterprise-grade reliability** with comprehensive error handling and testing
- **Peak performance** through coroutines, caching, and memory optimization
- **Universal accessibility** meeting and exceeding Android accessibility guidelines
- **Full platform integration** leveraging Android-specific capabilities
- **Google Play readiness** with proper analytics, privacy compliance, and monetization

This implementation will create a market-leading blackjack strategy training app that could successfully compete in the Google Play Store, providing users with the most comprehensive and user-friendly way to master basic blackjack strategy on Android devices.