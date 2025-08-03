package net.kristopherjohnson.blackjacktrainer.presentation.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Casino
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import net.kristopherjohnson.blackjacktrainer.domain.model.*
import net.kristopherjohnson.blackjacktrainer.presentation.ui.theme.BlackjackTrainerTheme

/**
 * Card component that displays the current training scenario
 */
@Composable
fun ScenarioDisplayCard(
    scenario: GameScenario,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier,
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.primaryContainer
        )
    ) {
        Column(
            modifier = Modifier.padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Header
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.Casino,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onPrimaryContainer
                )
                Text(
                    text = "What's your move?",
                    style = MaterialTheme.typography.titleLarge,
                    color = MaterialTheme.colorScheme.onPrimaryContainer
                )
            }
            
            // Dealer Card
            Card(
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surface
                )
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        text = "Dealer shows:",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    PlayingCardView(
                        card = scenario.dealerCard,
                        modifier = Modifier.padding(top = 8.dp)
                    )
                }
            }
            
            // Player Hand
            Card(
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surface
                )
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        text = "Your hand:",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    
                    // Display player cards
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        modifier = Modifier.padding(top = 8.dp)
                    ) {
                        scenario.playerCards.forEach { card ->
                            PlayingCardView(card = card)
                        }
                    }
                    
                    Spacer(modifier = Modifier.height(8.dp))
                    
                    Text(
                        text = scenario.getHandDescription(),
                        style = MaterialTheme.typography.titleMedium,
                        color = MaterialTheme.colorScheme.primary,
                        textAlign = TextAlign.Center
                    )
                }
            }
        }
    }
}

@Composable
private fun PlayingCardView(
    card: Card,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier.size(width = 60.dp, height = 84.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.background
        ),
        border = CardDefaults.outlinedCardBorder()
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(
                text = card.displayValue,
                style = MaterialTheme.typography.titleLarge,
                color = when (card.suit) {
                    Suit.HEARTS, Suit.DIAMONDS -> MaterialTheme.colorScheme.error
                    Suit.CLUBS, Suit.SPADES -> MaterialTheme.colorScheme.onBackground
                }
            )
            Text(
                text = card.suit.symbol,
                style = MaterialTheme.typography.bodyLarge,
                color = when (card.suit) {
                    Suit.HEARTS, Suit.DIAMONDS -> MaterialTheme.colorScheme.error
                    Suit.CLUBS, Suit.SPADES -> MaterialTheme.colorScheme.onBackground
                }
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
fun ScenarioDisplayCardPreview() {
    BlackjackTrainerTheme {
        ScenarioDisplayCard(
            scenario = GameScenario.createHardTotal(16, Card.SEVEN_CLUBS),
            modifier = Modifier.fillMaxWidth().padding(16.dp)
        )
    }
}