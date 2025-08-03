package net.kristopherjohnson.blackjacktrainer.presentation.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import net.kristopherjohnson.blackjacktrainer.domain.model.*
import net.kristopherjohnson.blackjacktrainer.presentation.ui.theme.BlackjackTrainerTheme

/**
 * Grid of action buttons for user to select their move
 */
@Composable
fun ActionButtonsGrid(
    scenario: GameScenario,
    onActionSelected: (Action) -> Unit,
    enabled: Boolean = true,
    modifier: Modifier = Modifier
) {
    val availableActions = Action.getAvailableActions(scenario.handType)
    
    Card(
        modifier = modifier,
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant
        )
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(
                text = "Choose your action:",
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            
            when (scenario.handType) {
                HandType.PAIR -> {
                    // For pairs, show split vs no-split options
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        ActionButton(
                            action = Action.SPLIT,
                            onClick = { onActionSelected(Action.SPLIT) },
                            enabled = enabled,
                            modifier = Modifier.weight(1f)
                        )
                        ActionButton(
                            action = Action.NO_SPLIT,
                            onClick = { onActionSelected(Action.NO_SPLIT) },
                            enabled = enabled,
                            modifier = Modifier.weight(1f)
                        )
                    }
                }
                HandType.HARD, HandType.SOFT -> {
                    // For hard/soft totals, show hit/stand/double options
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        ActionButton(
                            action = Action.HIT,
                            onClick = { onActionSelected(Action.HIT) },
                            enabled = enabled,
                            modifier = Modifier.weight(1f)
                        )
                        ActionButton(
                            action = Action.STAND,
                            onClick = { onActionSelected(Action.STAND) },
                            enabled = enabled,
                            modifier = Modifier.weight(1f)
                        )
                    }
                    
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        ActionButton(
                            action = Action.DOUBLE,
                            onClick = { onActionSelected(Action.DOUBLE) },
                            enabled = enabled,
                            modifier = Modifier.fillMaxWidth()
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun ActionButton(
    action: Action,
    onClick: () -> Unit,
    enabled: Boolean = true,
    modifier: Modifier = Modifier
) {
    Button(
        onClick = onClick,
        enabled = enabled,
        modifier = modifier.height(56.dp),
        colors = ButtonDefaults.buttonColors(
            containerColor = androidx.compose.ui.graphics.Color(action.colorValue)
        )
    ) {
        Column(
            horizontalAlignment = androidx.compose.ui.Alignment.CenterHorizontally
        ) {
            Icon(
                imageVector = getActionIcon(action),
                contentDescription = action.accessibilityLabel,
                modifier = Modifier.size(20.dp)
            )
            Text(
                text = action.displayName,
                style = MaterialTheme.typography.labelMedium
            )
        }
    }
}

private fun getActionIcon(action: Action): ImageVector {
    return when (action) {
        Action.HIT -> Icons.Default.Add
        Action.STAND -> Icons.Default.Stop
        Action.DOUBLE -> Icons.Default.DoubleArrow
        Action.SPLIT -> Icons.Default.CallSplit
        Action.NO_SPLIT -> Icons.Default.Block
    }
}

@Preview(showBackground = true)
@Composable
fun ActionButtonsGridPreview() {
    BlackjackTrainerTheme {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Hard total example
            ActionButtonsGrid(
                scenario = GameScenario.createHardTotal(16, Card.SEVEN_CLUBS),
                onActionSelected = {},
                modifier = Modifier.fillMaxWidth()
            )
            
            // Pair example
            ActionButtonsGrid(
                scenario = GameScenario.createPair(Rank.EIGHT, Card.TEN_HEARTS),
                onActionSelected = {},
                modifier = Modifier.fillMaxWidth()
            )
        }
    }
}