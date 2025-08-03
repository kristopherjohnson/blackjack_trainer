package net.kristopherjohnson.blackjacktrainer.presentation.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import net.kristopherjohnson.blackjacktrainer.domain.model.*
import net.kristopherjohnson.blackjacktrainer.domain.usecase.AnswerResult
import net.kristopherjohnson.blackjacktrainer.presentation.ui.theme.BlackjackTrainerTheme

/**
 * Card component that displays feedback after user submits an answer
 */
@Composable
fun FeedbackCard(
    answerResult: AnswerResult.Success,
    onContinue: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier,
        colors = CardDefaults.cardColors(
            containerColor = if (answerResult.isCorrect) {
                MaterialTheme.colorScheme.primaryContainer
            } else {
                MaterialTheme.colorScheme.errorContainer
            }
        )
    ) {
        Column(
            modifier = Modifier.padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Result Header
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Icon(
                    imageVector = if (answerResult.isCorrect) Icons.Default.CheckCircle else Icons.Default.Cancel,
                    contentDescription = null,
                    tint = if (answerResult.isCorrect) {
                        MaterialTheme.colorScheme.onPrimaryContainer
                    } else {
                        MaterialTheme.colorScheme.onErrorContainer
                    },
                    modifier = Modifier.size(32.dp)
                )
                Text(
                    text = if (answerResult.isCorrect) "Correct!" else "Incorrect",
                    style = MaterialTheme.typography.headlineSmall,
                    color = if (answerResult.isCorrect) {
                        MaterialTheme.colorScheme.onPrimaryContainer
                    } else {
                        MaterialTheme.colorScheme.onErrorContainer
                    }
                )
            }
            
            // Answer Details
            if (!answerResult.isCorrect) {
                Card(
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surface
                    )
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceEvenly
                        ) {
                            // User's Answer
                            Column(
                                horizontalAlignment = Alignment.CenterHorizontally
                            ) {
                                Text(
                                    text = "Your Answer",
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant
                                )
                                ActionChip(
                                    action = answerResult.userAction,
                                    isCorrect = false
                                )
                            }
                            
                            // Correct Answer
                            Column(
                                horizontalAlignment = Alignment.CenterHorizontally
                            ) {
                                Text(
                                    text = "Correct Answer",
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant
                                )
                                ActionChip(
                                    action = answerResult.correctAction,
                                    isCorrect = true
                                )
                            }
                        }
                    }
                }
            }
            
            // Explanation
            if (answerResult.explanation.isNotBlank()) {
                Card(
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surface
                    )
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Icon(
                            imageVector = Icons.Default.Lightbulb,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.onSurface,
                            modifier = Modifier.size(24.dp)
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = answerResult.explanation,
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurface,
                            textAlign = TextAlign.Center
                        )
                    }
                }
            }
            
            // Continue Button
            Button(
                onClick = onContinue,
                modifier = Modifier.fillMaxWidth()
            ) {
                Icon(
                    imageVector = Icons.Default.ArrowForward,
                    contentDescription = null,
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Continue",
                    style = MaterialTheme.typography.labelLarge
                )
            }
        }
    }
}

@Composable
private fun ActionChip(
    action: Action,
    isCorrect: Boolean,
    modifier: Modifier = Modifier
) {
    AssistChip(
        onClick = { /* No-op */ },
        label = { Text(action.displayName) },
        modifier = modifier,
        colors = AssistChipDefaults.assistChipColors(
            containerColor = if (isCorrect) {
                MaterialTheme.colorScheme.primaryContainer
            } else {
                MaterialTheme.colorScheme.errorContainer
            },
            labelColor = if (isCorrect) {
                MaterialTheme.colorScheme.onPrimaryContainer
            } else {
                MaterialTheme.colorScheme.onErrorContainer
            }
        ),
        leadingIcon = {
            Icon(
                imageVector = if (isCorrect) Icons.Default.Check else Icons.Default.Close,
                contentDescription = null,
                modifier = Modifier.size(16.dp)
            )
        }
    )
}

@Preview(showBackground = true)
@Composable
fun FeedbackCardPreview() {
    BlackjackTrainerTheme {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Correct answer
            FeedbackCard(
                answerResult = AnswerResult.Success(
                    isCorrect = true,
                    correctAction = Action.STAND,
                    userAction = Action.STAND,
                    explanation = "Great job! Always stand on hard 17 or higher."
                ),
                onContinue = {}
            )
            
            // Incorrect answer
            FeedbackCard(
                answerResult = AnswerResult.Success(
                    isCorrect = false,
                    correctAction = Action.HIT,
                    userAction = Action.STAND,
                    explanation = "Hit 16 vs dealer 7+. The dealer has a strong card and you need to improve your hand."
                ),
                onContinue = {}
            )
        }
    }
}