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

// Complete basic strategy chart
private val hardTotalsStrategy = mapOf(
    // (playerTotal, dealerCard) -> action
    Pair(8, "2") to "H", Pair(8, "3") to "H", Pair(8, "4") to "H", Pair(8, "5") to "H", Pair(8, "6") to "H", Pair(8, "7") to "H", Pair(8, "8") to "H", Pair(8, "9") to "H", Pair(8, "10") to "H", Pair(8, "A") to "H",
    Pair(9, "2") to "H", Pair(9, "3") to "D", Pair(9, "4") to "D", Pair(9, "5") to "D", Pair(9, "6") to "D", Pair(9, "7") to "H", Pair(9, "8") to "H", Pair(9, "9") to "H", Pair(9, "10") to "H", Pair(9, "A") to "H",
    Pair(10, "2") to "D", Pair(10, "3") to "D", Pair(10, "4") to "D", Pair(10, "5") to "D", Pair(10, "6") to "D", Pair(10, "7") to "D", Pair(10, "8") to "D", Pair(10, "9") to "D", Pair(10, "10") to "H", Pair(10, "A") to "H",
    Pair(11, "2") to "D", Pair(11, "3") to "D", Pair(11, "4") to "D", Pair(11, "5") to "D", Pair(11, "6") to "D", Pair(11, "7") to "D", Pair(11, "8") to "D", Pair(11, "9") to "D", Pair(11, "10") to "D", Pair(11, "A") to "H",
    Pair(12, "2") to "H", Pair(12, "3") to "H", Pair(12, "4") to "S", Pair(12, "5") to "S", Pair(12, "6") to "S", Pair(12, "7") to "H", Pair(12, "8") to "H", Pair(12, "9") to "H", Pair(12, "10") to "H", Pair(12, "A") to "H",
    Pair(13, "2") to "S", Pair(13, "3") to "S", Pair(13, "4") to "S", Pair(13, "5") to "S", Pair(13, "6") to "S", Pair(13, "7") to "H", Pair(13, "8") to "H", Pair(13, "9") to "H", Pair(13, "10") to "H", Pair(13, "A") to "H",
    Pair(14, "2") to "S", Pair(14, "3") to "S", Pair(14, "4") to "S", Pair(14, "5") to "S", Pair(14, "6") to "S", Pair(14, "7") to "H", Pair(14, "8") to "H", Pair(14, "9") to "H", Pair(14, "10") to "H", Pair(14, "A") to "H",
    Pair(15, "2") to "S", Pair(15, "3") to "S", Pair(15, "4") to "S", Pair(15, "5") to "S", Pair(15, "6") to "S", Pair(15, "7") to "H", Pair(15, "8") to "H", Pair(15, "9") to "H", Pair(15, "10") to "H", Pair(15, "A") to "H",
    Pair(16, "2") to "S", Pair(16, "3") to "S", Pair(16, "4") to "S", Pair(16, "5") to "S", Pair(16, "6") to "S", Pair(16, "7") to "H", Pair(16, "8") to "H", Pair(16, "9") to "H", Pair(16, "10") to "H", Pair(16, "A") to "H",
    Pair(17, "2") to "S", Pair(17, "3") to "S", Pair(17, "4") to "S", Pair(17, "5") to "S", Pair(17, "6") to "S", Pair(17, "7") to "S", Pair(17, "8") to "S", Pair(17, "9") to "S", Pair(17, "10") to "S", Pair(17, "A") to "S",
    Pair(18, "2") to "S", Pair(18, "3") to "S", Pair(18, "4") to "S", Pair(18, "5") to "S", Pair(18, "6") to "S", Pair(18, "7") to "S", Pair(18, "8") to "S", Pair(18, "9") to "S", Pair(18, "10") to "S", Pair(18, "A") to "S",
    Pair(19, "2") to "S", Pair(19, "3") to "S", Pair(19, "4") to "S", Pair(19, "5") to "S", Pair(19, "6") to "S", Pair(19, "7") to "S", Pair(19, "8") to "S", Pair(19, "9") to "S", Pair(19, "10") to "S", Pair(19, "A") to "S",
    Pair(20, "2") to "S", Pair(20, "3") to "S", Pair(20, "4") to "S", Pair(20, "5") to "S", Pair(20, "6") to "S", Pair(20, "7") to "S", Pair(20, "8") to "S", Pair(20, "9") to "S", Pair(20, "10") to "S", Pair(20, "A") to "S",
    Pair(21, "2") to "S", Pair(21, "3") to "S", Pair(21, "4") to "S", Pair(21, "5") to "S", Pair(21, "6") to "S", Pair(21, "7") to "S", Pair(21, "8") to "S", Pair(21, "9") to "S", Pair(21, "10") to "S", Pair(21, "A") to "S"
)

private val softTotalsStrategy = mapOf(
    // (playerTotal, dealerCard) -> action (soft totals A,2 through A,9)
    Pair(13, "2") to "H", Pair(13, "3") to "H", Pair(13, "4") to "H", Pair(13, "5") to "D", Pair(13, "6") to "D", Pair(13, "7") to "H", Pair(13, "8") to "H", Pair(13, "9") to "H", Pair(13, "10") to "H", Pair(13, "A") to "H", // A,2
    Pair(14, "2") to "H", Pair(14, "3") to "H", Pair(14, "4") to "H", Pair(14, "5") to "D", Pair(14, "6") to "D", Pair(14, "7") to "H", Pair(14, "8") to "H", Pair(14, "9") to "H", Pair(14, "10") to "H", Pair(14, "A") to "H", // A,3
    Pair(15, "2") to "H", Pair(15, "3") to "H", Pair(15, "4") to "D", Pair(15, "5") to "D", Pair(15, "6") to "D", Pair(15, "7") to "H", Pair(15, "8") to "H", Pair(15, "9") to "H", Pair(15, "10") to "H", Pair(15, "A") to "H", // A,4
    Pair(16, "2") to "H", Pair(16, "3") to "H", Pair(16, "4") to "D", Pair(16, "5") to "D", Pair(16, "6") to "D", Pair(16, "7") to "H", Pair(16, "8") to "H", Pair(16, "9") to "H", Pair(16, "10") to "H", Pair(16, "A") to "H", // A,5
    Pair(17, "2") to "H", Pair(17, "3") to "D", Pair(17, "4") to "D", Pair(17, "5") to "D", Pair(17, "6") to "D", Pair(17, "7") to "H", Pair(17, "8") to "H", Pair(17, "9") to "H", Pair(17, "10") to "H", Pair(17, "A") to "H", // A,6
    Pair(18, "2") to "S", Pair(18, "3") to "D", Pair(18, "4") to "D", Pair(18, "5") to "D", Pair(18, "6") to "D", Pair(18, "7") to "S", Pair(18, "8") to "S", Pair(18, "9") to "H", Pair(18, "10") to "H", Pair(18, "A") to "H", // A,7
    Pair(19, "2") to "S", Pair(19, "3") to "S", Pair(19, "4") to "S", Pair(19, "5") to "S", Pair(19, "6") to "S", Pair(19, "7") to "S", Pair(19, "8") to "S", Pair(19, "9") to "S", Pair(19, "10") to "S", Pair(19, "A") to "S", // A,8
    Pair(20, "2") to "S", Pair(20, "3") to "S", Pair(20, "4") to "S", Pair(20, "5") to "S", Pair(20, "6") to "S", Pair(20, "7") to "S", Pair(20, "8") to "S", Pair(20, "9") to "S", Pair(20, "10") to "S", Pair(20, "A") to "S"  // A,9
)

private val pairsStrategy = mapOf(
    // (pairValue, dealerCard) -> action
    Pair("A", "2") to "Y", Pair("A", "3") to "Y", Pair("A", "4") to "Y", Pair("A", "5") to "Y", Pair("A", "6") to "Y", Pair("A", "7") to "Y", Pair("A", "8") to "Y", Pair("A", "9") to "Y", Pair("A", "10") to "Y", Pair("A", "A") to "Y", // A,A
    Pair("10", "2") to "N", Pair("10", "3") to "N", Pair("10", "4") to "N", Pair("10", "5") to "N", Pair("10", "6") to "N", Pair("10", "7") to "N", Pair("10", "8") to "N", Pair("10", "9") to "N", Pair("10", "10") to "N", Pair("10", "A") to "N", // 10,10
    Pair("9", "2") to "Y", Pair("9", "3") to "Y", Pair("9", "4") to "Y", Pair("9", "5") to "Y", Pair("9", "6") to "Y", Pair("9", "7") to "N", Pair("9", "8") to "Y", Pair("9", "9") to "Y", Pair("9", "10") to "N", Pair("9", "A") to "N", // 9,9
    Pair("8", "2") to "Y", Pair("8", "3") to "Y", Pair("8", "4") to "Y", Pair("8", "5") to "Y", Pair("8", "6") to "Y", Pair("8", "7") to "Y", Pair("8", "8") to "Y", Pair("8", "9") to "Y", Pair("8", "10") to "Y", Pair("8", "A") to "Y", // 8,8
    Pair("7", "2") to "Y", Pair("7", "3") to "Y", Pair("7", "4") to "Y", Pair("7", "5") to "Y", Pair("7", "6") to "Y", Pair("7", "7") to "Y", Pair("7", "8") to "N", Pair("7", "9") to "N", Pair("7", "10") to "N", Pair("7", "A") to "N", // 7,7
    Pair("6", "2") to "Y", Pair("6", "3") to "Y", Pair("6", "4") to "Y", Pair("6", "5") to "Y", Pair("6", "6") to "Y", Pair("6", "7") to "N", Pair("6", "8") to "N", Pair("6", "9") to "N", Pair("6", "10") to "N", Pair("6", "A") to "N", // 6,6
    Pair("5", "2") to "N", Pair("5", "3") to "N", Pair("5", "4") to "N", Pair("5", "5") to "N", Pair("5", "6") to "N", Pair("5", "7") to "N", Pair("5", "8") to "N", Pair("5", "9") to "N", Pair("5", "10") to "N", Pair("5", "A") to "N", // 5,5
    Pair("4", "2") to "N", Pair("4", "3") to "N", Pair("4", "4") to "N", Pair("4", "5") to "Y", Pair("4", "6") to "Y", Pair("4", "7") to "N", Pair("4", "8") to "N", Pair("4", "9") to "N", Pair("4", "10") to "N", Pair("4", "A") to "N", // 4,4
    Pair("3", "2") to "Y", Pair("3", "3") to "Y", Pair("3", "4") to "Y", Pair("3", "5") to "Y", Pair("3", "6") to "Y", Pair("3", "7") to "Y", Pair("3", "8") to "N", Pair("3", "9") to "N", Pair("3", "10") to "N", Pair("3", "A") to "N", // 3,3
    Pair("2", "2") to "Y", Pair("2", "3") to "Y", Pair("2", "4") to "Y", Pair("2", "5") to "Y", Pair("2", "6") to "Y", Pair("2", "7") to "Y", Pair("2", "8") to "N", Pair("2", "9") to "N", Pair("2", "10") to "N", Pair("2", "A") to "N"  // 2,2
)

// Enhanced scenario generation
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
        "dealer" -> {
            // Focus on dealer strength groups
            val dealerStrengthGroups = mapOf(
                "weak" to listOf("4", "5", "6"),
                "medium" to listOf("2", "3", "7", "8"),
                "strong" to listOf("9", "10", "A")
            )
            val group = dealerStrengthGroups.values.random()
            val selectedDealer = group.random()
            
            generateRandomScenario(selectedDealer)
        }
        "hand" -> {
            // Focus on specific hand types
            val handTypes = listOf("Hard", "Soft", "Pair")
            val selectedType = handTypes.random()
            
            when (selectedType) {
                "Hard" -> {
                    val totals = listOf(9, 10, 11, 12, 13, 14, 15, 16)
                    val total = totals.random()
                    GameScenario("Hard", generateHardHand(total), total, dealerCard)
                }
                "Soft" -> {
                    val totals = listOf(13, 14, 15, 16, 17, 18, 19, 20) // A,2 through A,9
                    val total = totals.random()
                    val kicker = total - 11
                    GameScenario("Soft", "A, $kicker", total, dealerCard)
                }
                "Pair" -> {
                    val pairValues = listOf("2", "3", "4", "5", "6", "7", "8", "9", "10", "A")
                    val pairValue = pairValues.random()
                    val total = if (pairValue == "A") 12 else pairValue.toIntOrNull()?.times(2) ?: 20
                    GameScenario("Pair", "$pairValue, $pairValue", total, dealerCard)
                }
                else -> generateRandomScenario(dealerCard)
            }
        }
        else -> generateRandomScenario(dealerCard)
    }
}

private fun generateRandomScenario(dealerCard: String): GameScenario {
    val scenarios = listOf(
        // Hard totals
        GameScenario("Hard", "10, 6", 16, dealerCard),
        GameScenario("Hard", "9, 3", 12, dealerCard),
        GameScenario("Hard", "8, 5", 13, dealerCard),
        GameScenario("Hard", "7, 7", 14, dealerCard),
        GameScenario("Hard", "9, 6", 15, dealerCard),
        GameScenario("Hard", "10, 5", 15, dealerCard),
        GameScenario("Hard", "6, 5", 11, dealerCard),
        GameScenario("Hard", "5, 4", 9, dealerCard),
        GameScenario("Hard", "6, 4", 10, dealerCard),
        // Soft totals
        GameScenario("Soft", "A, 2", 13, dealerCard),
        GameScenario("Soft", "A, 3", 14, dealerCard),
        GameScenario("Soft", "A, 4", 15, dealerCard),
        GameScenario("Soft", "A, 5", 16, dealerCard),
        GameScenario("Soft", "A, 6", 17, dealerCard),
        GameScenario("Soft", "A, 7", 18, dealerCard),
        GameScenario("Soft", "A, 8", 19, dealerCard),
        GameScenario("Soft", "A, 9", 20, dealerCard),
        // Pairs
        GameScenario("Pair", "2, 2", 4, dealerCard),
        GameScenario("Pair", "3, 3", 6, dealerCard),
        GameScenario("Pair", "6, 6", 12, dealerCard),
        GameScenario("Pair", "7, 7", 14, dealerCard),
        GameScenario("Pair", "9, 9", 18, dealerCard)
    )
    return scenarios.random()
}

private fun generateHardHand(total: Int): String {
    val combinations = when (total) {
        9 -> listOf("5, 4", "6, 3", "7, 2")
        10 -> listOf("6, 4", "7, 3", "8, 2", "5, 5")
        11 -> listOf("7, 4", "8, 3", "9, 2", "6, 5")
        12 -> listOf("8, 4", "9, 3", "10, 2", "7, 5", "6, 6")
        13 -> listOf("9, 4", "10, 3", "8, 5", "7, 6")
        14 -> listOf("10, 4", "9, 5", "8, 6", "7, 7")
        15 -> listOf("10, 5", "9, 6", "8, 7")
        16 -> listOf("10, 6", "9, 7", "8, 8")
        else -> listOf("10, ${total - 10}")
    }
    return combinations.random()
}

fun getCorrectAction(scenario: GameScenario): String {
    return when (scenario.handType) {
        "Pair" -> {
            // Extract pair value from hand (e.g., "A, A" -> "A")
            val pairValue = scenario.playerHand.split(",")[0].trim()
            pairsStrategy[Pair(pairValue, scenario.dealerCard)] ?: "H"
        }
        "Soft" -> {
            // Soft totals (A,2 through A,9)
            softTotalsStrategy[Pair(scenario.playerTotal, scenario.dealerCard)] ?: "H"
        }
        "Hard" -> {
            // Hard totals
            hardTotalsStrategy[Pair(scenario.playerTotal, scenario.dealerCard)] ?: "H"
        }
        else -> "H"
    }
}

fun getExplanation(scenario: GameScenario, correctAction: String): String {
    val actionName = when (correctAction) {
        "H" -> "HIT"
        "S" -> "STAND"
        "D" -> "DOUBLE"
        "Y" -> "SPLIT"
        "N" -> "DON'T SPLIT"
        else -> correctAction
    }
    
    return when {
        // Absolute rules
        scenario.handType == "Pair" && scenario.playerHand.contains("A") -> 
            "Always split Aces! \"Aces and eights, don't hesitate!\""
        scenario.handType == "Pair" && scenario.playerHand.contains("8") -> 
            "Always split 8s! \"Aces and eights, don't hesitate!\" - 16 is terrible, 8 gives hope."
        scenario.handType == "Pair" && scenario.playerHand.contains("10") -> 
            "Never split 10s! 20 is an excellent hand - don't mess with perfection."
        scenario.handType == "Pair" && scenario.playerHand.contains("5") -> 
            "Never split 5s! Treat it as hard 10 and double when possible."
            
        // Dealer strength patterns
        scenario.dealerCard in listOf("4", "5", "6") && correctAction == "S" -> 
            "Dealer bust cards (4,5,6)! Let them bust first - \"dealer weak, player speaks.\""
        scenario.dealerCard in listOf("4", "5", "6") && correctAction == "D" -> 
            "Dealer bust cards (4,5,6)! Get greedy and double - maximum profit opportunity."
        scenario.dealerCard in listOf("9", "10", "A") && correctAction == "H" -> 
            "Dealer strong cards (9,10,A)! \"Teens flee from strong\" - must improve your hand."
        scenario.dealerCard in listOf("9", "10", "A") && scenario.playerTotal >= 17 -> 
            "Even vs strong dealer, 17+ must stand - risk of busting too high."
            
        // Soft hand patterns
        scenario.handType == "Soft" && scenario.playerTotal == 18 && scenario.dealerCard in listOf("9", "10", "A") -> 
            "A,7 vs strong dealer - hit to improve! Soft 18 isn't strong enough."
        scenario.handType == "Soft" && correctAction == "D" -> 
            "Soft double opportunity! Can't bust and dealer looks weak."
        scenario.handType == "Soft" && scenario.playerTotal >= 19 -> 
            "Soft 19+ always stands - excellent hand, don't risk it."
            
        // Hard hand patterns
        scenario.handType == "Hard" && scenario.playerTotal == 11 && correctAction == "D" -> 
            "Always double 11! (Except vs dealer Ace) - best doubling opportunity."
        scenario.handType == "Hard" && scenario.playerTotal == 10 && scenario.dealerCard != "10" && scenario.dealerCard != "A" -> 
            "Double hard 10 vs 2-9! Strong doubling hand."
        scenario.handType == "Hard" && scenario.playerTotal in 12..16 && scenario.dealerCard in listOf("2", "3", "7", "8", "9", "10", "A") -> 
            "Stiff hand vs strong dealer - must hit despite bust risk."
        scenario.handType == "Hard" && scenario.playerTotal >= 17 -> 
            "Hard 17+ always stands - risk of busting too high."
            
        else -> "Basic strategy: $actionName is mathematically optimal here."
    }
}