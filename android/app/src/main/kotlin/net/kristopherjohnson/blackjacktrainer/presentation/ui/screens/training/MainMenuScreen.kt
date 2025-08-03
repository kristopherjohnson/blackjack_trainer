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
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import net.kristopherjohnson.blackjacktrainer.domain.model.*
import net.kristopherjohnson.blackjacktrainer.presentation.ui.components.StatisticsCard
import net.kristopherjohnson.blackjacktrainer.presentation.ui.components.TrainingModeCard
import net.kristopherjohnson.blackjacktrainer.presentation.ui.theme.BlackjackTrainerTheme
import net.kristopherjohnson.blackjacktrainer.presentation.viewmodel.MainMenuUiState

/**
 * Main menu screen for selecting training modes
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainMenuScreen(
    uiState: MainMenuUiState,
    onTrainingModeSelected: (TrainingSessionType) -> Unit,
    onDealerStrengthSelected: (DealerStrength) -> Unit,
    onHandTypeSelected: (HandTypeFocus) -> Unit,
    onDifficultySelected: (DifficultyLevel) -> Unit,
    onStartTraining: (TrainingSessionConfig) -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // App Title
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.primaryContainer
            )
        ) {
            Column(
                modifier = Modifier.padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "♠ Blackjack Strategy Trainer ♥",
                    style = MaterialTheme.typography.headlineMedium,
                    color = MaterialTheme.colorScheme.onPrimaryContainer,
                    textAlign = TextAlign.Center
                )
                Text(
                    text = "Master basic strategy with focused practice",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onPrimaryContainer,
                    textAlign = TextAlign.Center
                )
            }
        }
        
        // Session Statistics
        if (uiState.sessionStatistics.totalCount > 0) {
            StatisticsCard(
                statistics = uiState.sessionStatistics,
                modifier = Modifier.fillMaxWidth()
            )
        }
        
        // Training Mode Selection
        Text(
            text = "Choose Your Training Mode",
            style = MaterialTheme.typography.titleLarge,
            modifier = Modifier.padding(top = 8.dp)
        )
        
        // Quick Practice
        TrainingModeCard(
            title = TrainingSessionType.RANDOM.displayName,
            description = TrainingSessionType.RANDOM.description,
            icon = Icons.Default.Shuffle,
            isSelected = uiState.selectedSessionType == TrainingSessionType.RANDOM,
            onClick = { onTrainingModeSelected(TrainingSessionType.RANDOM) }
        )
        
        // Dealer Groups
        TrainingModeCard(
            title = TrainingSessionType.DEALER_GROUP.displayName,
            description = TrainingSessionType.DEALER_GROUP.description,
            icon = Icons.Default.Groups,
            isSelected = uiState.selectedSessionType == TrainingSessionType.DEALER_GROUP,
            onClick = { onTrainingModeSelected(TrainingSessionType.DEALER_GROUP) }
        )
        
        // Dealer Strength Selection (if dealer group mode selected)
        if (uiState.selectedSessionType == TrainingSessionType.DEALER_GROUP) {
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant
                )
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = "Select Dealer Strength:",
                        style = MaterialTheme.typography.titleMedium
                    )
                    
                    DealerStrength.values().forEach { strength ->
                        FilterChip(
                            onClick = { onDealerStrengthSelected(strength) },
                            label = { Text(strength.displayName) },
                            selected = uiState.selectedDealerStrength == strength,
                            modifier = Modifier.fillMaxWidth()
                        )
                    }
                }
            }
        }
        
        // Hand Type Focus
        TrainingModeCard(
            title = TrainingSessionType.HAND_TYPE.displayName,
            description = TrainingSessionType.HAND_TYPE.description,
            icon = Icons.Default.Category,
            isSelected = uiState.selectedSessionType == TrainingSessionType.HAND_TYPE,
            onClick = { onTrainingModeSelected(TrainingSessionType.HAND_TYPE) }
        )
        
        // Hand Type Selection (if hand type mode selected)
        if (uiState.selectedSessionType == TrainingSessionType.HAND_TYPE) {
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant
                )
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = "Select Hand Type:",
                        style = MaterialTheme.typography.titleMedium
                    )
                    
                    HandTypeFocus.values().forEach { handType ->
                        FilterChip(
                            onClick = { onHandTypeSelected(handType) },
                            label = { Text(handType.displayName) },
                            selected = uiState.selectedHandType == handType,
                            modifier = Modifier.fillMaxWidth()
                        )
                    }
                }
            }
        }
        
        // Absolutes Drill
        TrainingModeCard(
            title = TrainingSessionType.ABSOLUTES.displayName,
            description = TrainingSessionType.ABSOLUTES.description,
            icon = Icons.Default.Rule,
            isSelected = uiState.selectedSessionType == TrainingSessionType.ABSOLUTES,
            onClick = { onTrainingModeSelected(TrainingSessionType.ABSOLUTES) }
        )
        
        // Difficulty Selection
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.surfaceVariant
            )
        ) {
            Column(
                modifier = Modifier.padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Text(
                    text = "Difficulty Level:",
                    style = MaterialTheme.typography.titleMedium
                )
                
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    DifficultyLevel.values().forEach { difficulty ->
                        FilterChip(
                            onClick = { onDifficultySelected(difficulty) },
                            label = { Text(difficulty.displayName) },
                            selected = uiState.selectedDifficulty == difficulty,
                            modifier = Modifier.weight(1f)
                        )
                    }
                }
            }
        }
        
        // Start Training Button
        Button(
            onClick = {
                // Create config based on current selections
                val config = when (uiState.selectedSessionType) {
                    TrainingSessionType.RANDOM -> TrainingSessionConfig.random(uiState.selectedDifficulty)
                    TrainingSessionType.DEALER_GROUP -> {
                        val strength = uiState.selectedDealerStrength ?: DealerStrength.WEAK
                        TrainingSessionConfig.dealerGroup(strength, uiState.selectedDifficulty)
                    }
                    TrainingSessionType.HAND_TYPE -> {
                        val handType = uiState.selectedHandType ?: HandTypeFocus.HARD_TOTALS
                        TrainingSessionConfig.handType(handType, uiState.selectedDifficulty)
                    }
                    TrainingSessionType.ABSOLUTES -> TrainingSessionConfig.absolutes(uiState.selectedDifficulty)
                }
                onStartTraining(config)
            },
            modifier = Modifier
                .fillMaxWidth()
                .height(56.dp),
            enabled = !uiState.isLoading && isConfigurationValid(uiState)
        ) {
            if (uiState.isLoading) {
                CircularProgressIndicator(
                    modifier = Modifier.size(24.dp),
                    color = MaterialTheme.colorScheme.onPrimary
                )
            } else {
                Icon(
                    imageVector = Icons.Default.PlayArrow,
                    contentDescription = null,
                    modifier = Modifier.size(24.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Start Training",
                    style = MaterialTheme.typography.labelLarge
                )
            }
        }
    }
}

private fun isConfigurationValid(uiState: MainMenuUiState): Boolean {
    return when (uiState.selectedSessionType) {
        TrainingSessionType.DEALER_GROUP -> uiState.selectedDealerStrength != null
        TrainingSessionType.HAND_TYPE -> uiState.selectedHandType != null
        else -> true
    }
}

@Preview(showBackground = true)
@Composable
fun MainMenuScreenPreview() {
    BlackjackTrainerTheme {
        MainMenuScreen(
            uiState = MainMenuUiState(),
            onTrainingModeSelected = {},
            onDealerStrengthSelected = {},
            onHandTypeSelected = {},
            onDifficultySelected = {},
            onStartTraining = {}
        )
    }
}