package net.kristopherjohnson.blackjacktrainer.presentation.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import net.kristopherjohnson.blackjacktrainer.domain.model.*
import net.kristopherjohnson.blackjacktrainer.domain.usecase.GetSessionStatisticsUseCase
import javax.inject.Inject

/**
 * ViewModel for the main menu screen
 */
@HiltViewModel
class MainMenuViewModel @Inject constructor(
    private val getSessionStatisticsUseCase: GetSessionStatisticsUseCase
) : ViewModel() {
    
    private val _uiState = MutableStateFlow(MainMenuUiState())
    val uiState: StateFlow<MainMenuUiState> = _uiState.asStateFlow()
    
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
    
    fun onTrainingModeSelected(sessionType: TrainingSessionType) {
        _uiState.value = _uiState.value.copy(selectedSessionType = sessionType)
    }
    
    fun onDealerStrengthSelected(strength: DealerStrength) {
        _uiState.value = _uiState.value.copy(selectedDealerStrength = strength)
    }
    
    fun onHandTypeSelected(handType: HandTypeFocus) {
        _uiState.value = _uiState.value.copy(selectedHandType = handType)
    }
    
    fun onDifficultySelected(difficulty: DifficultyLevel) {
        _uiState.value = _uiState.value.copy(selectedDifficulty = difficulty)
    }
    
    fun createSessionConfig(): TrainingSessionConfig {
        val state = _uiState.value
        return when (state.selectedSessionType) {
            TrainingSessionType.RANDOM -> TrainingSessionConfig.random(state.selectedDifficulty)
            TrainingSessionType.DEALER_GROUP -> {
                val strength = state.selectedDealerStrength ?: DealerStrength.WEAK
                TrainingSessionConfig.dealerGroup(strength, state.selectedDifficulty)
            }
            TrainingSessionType.HAND_TYPE -> {
                val handType = state.selectedHandType ?: HandTypeFocus.HARD_TOTALS
                TrainingSessionConfig.handType(handType, state.selectedDifficulty)
            }
            TrainingSessionType.ABSOLUTES -> TrainingSessionConfig.absolutes(state.selectedDifficulty)
        }
    }
}

/**
 * UI state for the main menu screen
 */
data class MainMenuUiState(
    val sessionStatistics: SessionStatistics = SessionStatistics(),
    val selectedSessionType: TrainingSessionType = TrainingSessionType.RANDOM,
    val selectedDealerStrength: DealerStrength? = null,
    val selectedHandType: HandTypeFocus? = null,
    val selectedDifficulty: DifficultyLevel = DifficultyLevel.NORMAL,
    val isLoading: Boolean = false
)