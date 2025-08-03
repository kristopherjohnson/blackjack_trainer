package net.kristopherjohnson.blackjacktrainer.presentation.ui.navigation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import net.kristopherjohnson.blackjacktrainer.domain.model.TrainingSessionConfig
import net.kristopherjohnson.blackjacktrainer.presentation.ui.screens.training.MainMenuScreen
import net.kristopherjohnson.blackjacktrainer.presentation.ui.screens.training.TrainingSessionScreen
import net.kristopherjohnson.blackjacktrainer.presentation.viewmodel.MainMenuViewModel
import net.kristopherjohnson.blackjacktrainer.presentation.viewmodel.TrainingSessionViewModel

/**
 * Main navigation component for the Blackjack Trainer app
 */
@Composable
fun BlackjackTrainerNavigation(
    navController: NavHostController = rememberNavController()
) {
    NavHost(
        navController = navController,
        startDestination = "main_menu"
    ) {
        composable("main_menu") {
            val viewModel: MainMenuViewModel = hiltViewModel()
            val uiState by viewModel.uiState.collectAsState()
            
            MainMenuScreen(
                uiState = uiState,
                onTrainingModeSelected = viewModel::onTrainingModeSelected,
                onDealerStrengthSelected = viewModel::onDealerStrengthSelected,
                onHandTypeSelected = viewModel::onHandTypeSelected,
                onDifficultySelected = viewModel::onDifficultySelected,
                onStartTraining = { config ->
                    navController.navigate("training_session") {
                        // Pass the config through the navigation arguments
                        // For now, we'll handle this in the TrainingSessionScreen
                    }
                }
            )
        }
        
        composable("training_session") {
            val viewModel: TrainingSessionViewModel = hiltViewModel()
            val uiState by viewModel.uiState.collectAsState()
            
            // Get the config from the previous screen
            val mainMenuViewModel: MainMenuViewModel = hiltViewModel(
                navController.getBackStackEntry("main_menu")
            )
            val config = mainMenuViewModel.createSessionConfig()
            
            TrainingSessionScreen(
                uiState = uiState,
                sessionConfig = config,
                onStartSession = viewModel::startSession,
                onSubmitAnswer = viewModel::submitAnswer,
                onContinueToNext = viewModel::continueToNext,
                onEndSession = {
                    viewModel.endSession()
                    navController.popBackStack()
                },
                onBackToMenu = {
                    navController.popBackStack()
                }
            )
        }
    }
}