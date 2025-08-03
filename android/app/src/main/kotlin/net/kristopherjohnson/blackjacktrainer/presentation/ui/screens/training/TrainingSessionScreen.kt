package net.kristopherjohnson.blackjacktrainer.presentation.ui.screens.training

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import net.kristopherjohnson.blackjacktrainer.domain.model.*
import net.kristopherjohnson.blackjacktrainer.domain.usecase.AnswerResult
import net.kristopherjohnson.blackjacktrainer.presentation.ui.components.*
import net.kristopherjohnson.blackjacktrainer.presentation.ui.theme.BlackjackTrainerTheme
import net.kristopherjohnson.blackjacktrainer.presentation.viewmodel.TrainingSessionUiState

/**
 * Training session screen where users practice blackjack strategy
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TrainingSessionScreen(
    uiState: TrainingSessionUiState,
    sessionConfig: TrainingSessionConfig,
    onStartSession: (TrainingSessionConfig) -> Unit,
    onSubmitAnswer: (Action) -> Unit,
    onContinueToNext: () -> Unit,
    onEndSession: () -> Unit,
    onBackToMenu: () -> Unit,
    modifier: Modifier = Modifier
) {
    // Start session when screen is first displayed
    LaunchedEffect(sessionConfig) {
        if (!uiState.isSessionActive) {
            onStartSession(sessionConfig)
        }
    }
    
    Column(
        modifier = modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Session Header
        TrainingSessionHeader(
            sessionConfig = sessionConfig,
            questionsAnswered = uiState.questionsAnswered,
            onEndSession = onEndSession,
            onBackToMenu = onBackToMenu
        )
        
        // Progress Indicator
        if (uiState.sessionConfig != null) {
            val progress = uiState.questionsAnswered.toFloat() / uiState.sessionConfig.maxQuestions.toFloat()
            LinearProgressIndicator(
                progress = progress,
                modifier = Modifier.fillMaxWidth()
            )
            Text(
                text = "${uiState.questionsAnswered} of ${uiState.sessionConfig.maxQuestions} questions",
                style = MaterialTheme.typography.bodyMedium,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )
        }
        
        // Error State
        uiState.error?.let { error ->
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.errorContainer
                )
            ) {
                Row(
                    modifier = Modifier.padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = Icons.Default.Error,
                        contentDescription = null,
                        tint = MaterialTheme.colorScheme.onErrorContainer
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = error,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onErrorContainer
                    )
                }
            }
        }
        
        // Loading State
        if (uiState.isLoading) {
            Card(
                modifier = Modifier.fillMaxWidth()
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(48.dp),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator()
                }
            }
        }
        
        // Current Scenario
        uiState.currentScenario?.let { scenario ->
            ScenarioDisplayCard(
                scenario = scenario,
                modifier = Modifier.fillMaxWidth()
            )
            
            if (!uiState.showFeedback) {
                // Action Buttons
                ActionButtonsGrid(
                    scenario = scenario,
                    onActionSelected = onSubmitAnswer,
                    enabled = !uiState.isLoading,
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }
        
        // Feedback Display
        if (uiState.showFeedback && uiState.lastAnswerResult != null) {
            FeedbackCard(
                answerResult = uiState.lastAnswerResult,
                onContinue = onContinueToNext,
                modifier = Modifier.fillMaxWidth()
            )
        }
        
        // Session Statistics
        if (uiState.sessionStatistics.totalCount > 0) {
            StatisticsCard(
                statistics = uiState.sessionStatistics,
                modifier = Modifier.fillMaxWidth()
            )
        }
    }
}

@Composable
private fun TrainingSessionHeader(
    sessionConfig: TrainingSessionConfig,
    questionsAnswered: Int,
    onEndSession: () -> Unit,
    onBackToMenu: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.primaryContainer
        )
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = sessionConfig.sessionType.displayName,
                        style = MaterialTheme.typography.titleLarge,
                        color = MaterialTheme.colorScheme.onPrimaryContainer
                    )
                    Text(
                        text = sessionConfig.sessionType.description,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onPrimaryContainer
                    )
                    
                    // Additional context based on session type
                    when (sessionConfig.sessionType) {
                        TrainingSessionType.DEALER_GROUP -> {
                            sessionConfig.dealerStrength?.let { strength ->
                                Text(
                                    text = "Focus: ${strength.displayName}",
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onPrimaryContainer
                                )
                            }
                        }
                        TrainingSessionType.HAND_TYPE -> {
                            sessionConfig.handTypeFocus?.let { handType ->
                                Text(
                                    text = "Focus: ${handType.displayName}",
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onPrimaryContainer
                                )
                            }
                        }
                        else -> {}
                    }
                }
                
                Row {
                    IconButton(onClick = onEndSession) {
                        Icon(
                            imageVector = Icons.Default.Stop,
                            contentDescription = "End Session",
                            tint = MaterialTheme.colorScheme.onPrimaryContainer
                        )
                    }
                    IconButton(onClick = onBackToMenu) {
                        Icon(
                            imageVector = Icons.Default.ArrowBack,
                            contentDescription = "Back to Menu",
                            tint = MaterialTheme.colorScheme.onPrimaryContainer
                        )
                    }
                }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun TrainingSessionScreenPreview() {
    BlackjackTrainerTheme {
        TrainingSessionScreen(
            uiState = TrainingSessionUiState(
                isSessionActive = true,
                currentScenario = GameScenario.createHardTotal(16, Card.SEVEN_CLUBS),
                questionsAnswered = 3,
                sessionConfig = TrainingSessionConfig.random()
            ),
            sessionConfig = TrainingSessionConfig.random(),
            onStartSession = {},
            onSubmitAnswer = {},
            onContinueToNext = {},
            onEndSession = {},
            onBackToMenu = {}
        )
    }
}