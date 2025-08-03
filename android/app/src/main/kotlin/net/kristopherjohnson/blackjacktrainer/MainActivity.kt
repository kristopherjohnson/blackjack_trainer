package net.kristopherjohnson.blackjacktrainer

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import net.kristopherjohnson.blackjacktrainer.ui.theme.BlackjackTrainerTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            BlackjackTrainerTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    BlackjackTrainerApp()
                }
            }
        }
    }
}

@Composable
fun BlackjackTrainerApp() {
    var currentScreen by remember { mutableStateOf("menu") }
    var currentScenario by remember { mutableStateOf<GameScenario?>(null) }
    var feedback by remember { mutableStateOf<String?>(null) }
    var stats by remember { mutableStateOf(SessionStats()) }
    
    when (currentScreen) {
        "menu" -> MainMenu(
            onModeSelected = { mode ->
                currentScenario = generateScenario(mode)
                currentScreen = "training"
                feedback = null
            }
        )
        "training" -> currentScenario?.let { scenario ->
            TrainingScreen(
                scenario = scenario,
                feedback = feedback,
                stats = stats,
                onAnswerSelected = { action ->
                    val correctAction = getCorrectAction(scenario)
                    val isCorrect = action == correctAction
                    
                    stats = stats.copy(
                        totalAttempts = stats.totalAttempts + 1,
                        correctAttempts = if (isCorrect) stats.correctAttempts + 1 else stats.correctAttempts
                    )
                    
                    feedback = if (isCorrect) {
                        "✅ Correct! $action was the right choice."
                    } else {
                        "❌ Incorrect. The correct answer was $correctAction.\n\n" +
                        getExplanation(scenario, correctAction)
                    }
                },
                onNextScenario = {
                    currentScenario = generateScenario("random")
                    feedback = null
                },
                onBackToMenu = {
                    currentScreen = "menu"
                    stats = SessionStats()
                    feedback = null
                }
            )
        }
    }
}

@Composable
fun MainMenu(onModeSelected: (String) -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "Blackjack Strategy Trainer",
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(bottom = 48.dp)
        )
        
        val modes = listOf(
            "Quick Practice" to "random",
            "Dealer Groups" to "dealer",
            "Hand Types" to "hand",
            "Absolutes Drill" to "absolute"
        )
        
        LazyColumn(
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            items(modes) { (title, mode) ->
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    onClick = { onModeSelected(mode) }
                ) {
                    Text(
                        text = title,
                        fontSize = 18.sp,
                        modifier = Modifier.padding(24.dp),
                        textAlign = TextAlign.Center
                    )
                }
            }
        }
    }
}

@Composable
fun TrainingScreen(
    scenario: GameScenario,
    feedback: String?,
    stats: SessionStats,
    onAnswerSelected: (String) -> Unit,
    onNextScenario: () -> Unit,
    onBackToMenu: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Stats
        Card(
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(
                text = "Session: ${stats.correctAttempts}/${stats.totalAttempts} " +
                       if (stats.totalAttempts > 0) "(${(stats.correctAttempts * 100f / stats.totalAttempts).toInt()}%)" else "(0%)",
                modifier = Modifier.padding(16.dp),
                textAlign = TextAlign.Center
            )
        }
        
        Spacer(modifier = Modifier.height(24.dp))
        
        // Scenario
        Card(
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(
                modifier = Modifier.padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "Dealer shows: ${scenario.dealerCard}",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold
                )
                Spacer(modifier = Modifier.height(16.dp))
                Text(
                    text = "Your hand: ${scenario.playerHand} (${scenario.handType} ${scenario.playerTotal})",
                    fontSize = 18.sp
                )
            }
        }
        
        Spacer(modifier = Modifier.height(32.dp))
        
        // Action buttons
        if (feedback == null) {
            Text(
                text = "What's your move?",
                fontSize = 18.sp,
                fontWeight = FontWeight.Medium,
                modifier = Modifier.padding(bottom = 16.dp)
            )
            
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                val actions = if (scenario.handType == "Pair") {
                    listOf("Hit" to "H", "Stand" to "S", "Double" to "D", "Split" to "Y")
                } else {
                    listOf("Hit" to "H", "Stand" to "S", "Double" to "D")
                }
                
                actions.forEach { (name, code) ->
                    Button(
                        onClick = { onAnswerSelected(code) },
                        modifier = Modifier.weight(1f)
                    ) {
                        Text(name)
                    }
                }
            }
        } else {
            // Feedback
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = if (feedback.startsWith("✅")) 
                        MaterialTheme.colorScheme.primaryContainer 
                    else 
                        MaterialTheme.colorScheme.errorContainer
                )
            ) {
                Text(
                    text = feedback,
                    modifier = Modifier.padding(16.dp),
                    fontSize = 16.sp
                )
            }
            
            Spacer(modifier = Modifier.height(24.dp))
            
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Button(
                    onClick = onNextScenario,
                    modifier = Modifier.weight(1f)
                ) {
                    Text("Next Hand")
                }
                OutlinedButton(
                    onClick = onBackToMenu,
                    modifier = Modifier.weight(1f)
                ) {
                    Text("Main Menu")
                }
            }
        }
    }
}

// Simple data classes
data class GameScenario(
    val handType: String,
    val playerHand: String,
    val playerTotal: Int,
    val dealerCard: String
)

data class SessionStats(
    val correctAttempts: Int = 0,
    val totalAttempts: Int = 0
)

// Simplified game logic
fun generateScenario(mode: String): GameScenario {
    val dealerCards = listOf("2", "3", "4", "5", "6", "7", "8", "9", "10", "A")
    val dealerCard = dealerCards.random()
    
    return when (mode) {
        "absolute" -> {
            // Always split A,A and 8,8, never split 10,10 and 5,5
            val absoluteHands = listOf(
                GameScenario("Pair", "A, A", 12, dealerCard),
                GameScenario("Pair", "8, 8", 16, dealerCard),
                GameScenario("Pair", "10, 10", 20, dealerCard),
                GameScenario("Pair", "5, 5", 10, dealerCard)
            )
            absoluteHands.random()
        }
        else -> {
            // Random scenarios
            val scenarios = listOf(
                GameScenario("Hard", "10, 6", 16, dealerCard),
                GameScenario("Hard", "9, 3", 12, dealerCard),
                GameScenario("Soft", "A, 6", 17, dealerCard),
                GameScenario("Soft", "A, 7", 18, dealerCard),
                GameScenario("Pair", "7, 7", 14, dealerCard),
                GameScenario("Pair", "9, 9", 18, dealerCard)
            )
            scenarios.random()
        }
    }
}

fun getCorrectAction(scenario: GameScenario): String {
    // Simplified basic strategy
    return when {
        scenario.handType == "Pair" && scenario.playerHand.contains("A") -> "Y" // Always split aces
        scenario.handType == "Pair" && scenario.playerHand.contains("8") -> "Y" // Always split 8s
        scenario.handType == "Pair" && (scenario.playerHand.contains("10") || scenario.playerHand.contains("5")) -> "H" // Never split 10s or 5s
        scenario.playerTotal >= 17 -> "S" // Stand on 17+
        scenario.playerTotal <= 11 -> "H" // Hit on 11 or less
        scenario.dealerCard in listOf("4", "5", "6") && scenario.playerTotal >= 12 -> "S" // Stand vs weak dealer
        else -> "H" // Default to hit
    }
}

fun getExplanation(scenario: GameScenario, correctAction: String): String {
    return when {
        scenario.handType == "Pair" && scenario.playerHand.contains("A") -> 
            "Always split Aces - they're too valuable not to split!"
        scenario.handType == "Pair" && scenario.playerHand.contains("8") -> 
            "Always split 8s - 16 is a terrible hand, but 8 gives you a fresh start!"
        scenario.handType == "Pair" && scenario.playerHand.contains("10") -> 
            "Never split 10s - 20 is an excellent hand!"
        scenario.playerTotal >= 17 -> 
            "Stand on 17 or higher - the risk of busting is too high."
        scenario.dealerCard in listOf("4", "5", "6") -> 
            "Dealer shows a bust card (4,5,6) - let them bust first!"
        else -> "Follow basic strategy patterns for optimal play."
    }
}