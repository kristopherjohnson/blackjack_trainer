package net.kristopherjohnson.blackjacktrainer.presentation.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import net.kristopherjohnson.blackjacktrainer.domain.model.*
import net.kristopherjohnson.blackjacktrainer.domain.usecase.*
import javax.inject.Inject

/**
 * ViewModel for training session screens
 */
@HiltViewModel
class TrainingSessionViewModel @Inject constructor(
    private val getTrainingScenarioUseCase: GetTrainingScenarioUseCase,
    private val checkAnswerUseCase: CheckAnswerUseCase,
    private val getSessionStatisticsUseCase: GetSessionStatisticsUseCase
) : ViewModel() {
    
    private val _uiState = MutableStateFlow(TrainingSessionUiState())
    val uiState: StateFlow<TrainingSessionUiState> = _uiState.asStateFlow()
    
    private val _events = MutableSharedFlow<TrainingSessionEvent>()
    val events: SharedFlow<TrainingSessionEvent> = _events.asSharedFlow()
    
    private var sessionConfig: TrainingSessionConfig? = null
    private var questionsAnswered = 0
    
    init {
        observeSessionStatistics()
    }
    
    private fun observeSessionStatistics() {
        viewModelScope.launch {
            getSessionStatisticsUseCase().collect { statistics ->
                _uiState.value = _uiState.value.copy(sessionStatistics = statistics)
            }
        }
    }
    
    /**
     * Start a new training session
     */
    fun startSession(config: TrainingSessionConfig) {
        sessionConfig = config
        questionsAnswered = 0
        _uiState.value = _uiState.value.copy(
            isSessionActive = true,
            sessionConfig = config,
            questionsAnswered = 0,
            showFeedback = false,
            lastAnswerResult = null
        )
        generateNewScenario()
    }
    
    /**
     * Generate a new scenario for the current session
     */
    fun generateNewScenario() {
        val config = sessionConfig ?: return
        
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)
            
            try {
                val scenario = getTrainingScenarioUseCase(config)
                _uiState.value = _uiState.value.copy(
                    currentScenario = scenario,
                    isLoading = false,
                    showFeedback = false,
                    lastAnswerResult = null
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    error = "Failed to generate scenario: ${e.message}"
                )
            }
        }
    }
    
    /**
     * Submit an answer for the current scenario
     */
    fun submitAnswer(action: Action) {
        val scenario = _uiState.value.currentScenario ?: return
        
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)
            
            try {
                val result = checkAnswerUseCase(scenario, action)
                when (result) {
                    is AnswerResult.Success -> {
                        questionsAnswered++
                        val updatedState = _uiState.value.copy(
                            lastAnswerResult = result,
                            showFeedback = true,
                            isLoading = false,
                            questionsAnswered = questionsAnswered,
                            error = null
                        )
                        _uiState.value = updatedState
                        
                        // Check if session is complete
                        val config = sessionConfig
                        if (config != null && questionsAnswered >= config.maxQuestions) {
                            _events.emit(TrainingSessionEvent.SessionComplete)
                        }
                    }
                    is AnswerResult.Error -> {
                        _uiState.value = _uiState.value.copy(
                            isLoading = false,
                            error = result.message
                        )
                    }
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    error = "Failed to check answer: ${e.message}"
                )
            }
        }
    }
    
    /**
     * Continue to next question after viewing feedback
     */
    fun continueToNext() {
        val config = sessionConfig
        if (config != null && questionsAnswered < config.maxQuestions) {
            generateNewScenario()
        } else {
            endSession()
        }
    }
    
    /**
     * End the current training session
     */
    fun endSession() {
        _uiState.value = _uiState.value.copy(
            isSessionActive = false,
            currentScenario = null,
            showFeedback = false,
            lastAnswerResult = null
        )
        sessionConfig = null
        questionsAnswered = 0
        
        viewModelScope.launch {
            _events.emit(TrainingSessionEvent.SessionEnded)
        }
    }
    
    /**
     * Clear any error state
     */
    fun clearError() {
        _uiState.value = _uiState.value.copy(error = null)
    }
    
    /**
     * Get progress percentage for current session
     */
    fun getProgressPercentage(): Float {
        val config = sessionConfig ?: return 0f
        return if (config.maxQuestions > 0) {
            questionsAnswered.toFloat() / config.maxQuestions.toFloat()
        } else {
            0f
        }
    }
}

/**
 * UI state for training session
 */
data class TrainingSessionUiState(
    val isSessionActive: Boolean = false,
    val sessionConfig: TrainingSessionConfig? = null,
    val currentScenario: GameScenario? = null,
    val sessionStatistics: SessionStatistics = SessionStatistics(),
    val questionsAnswered: Int = 0,
    val showFeedback: Boolean = false,
    val lastAnswerResult: AnswerResult.Success? = null,
    val isLoading: Boolean = false,
    val error: String? = null
)

/**
 * Events that can be emitted from the training session
 */
sealed class TrainingSessionEvent {
    object SessionComplete : TrainingSessionEvent()
    object SessionEnded : TrainingSessionEvent()
}