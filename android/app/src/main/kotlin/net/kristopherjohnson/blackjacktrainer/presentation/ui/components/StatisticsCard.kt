package net.kristopherjohnson.blackjacktrainer.presentation.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Analytics
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import net.kristopherjohnson.blackjacktrainer.domain.model.SessionStatistics
import net.kristopherjohnson.blackjacktrainer.presentation.ui.theme.BlackjackTrainerTheme

/**
 * Card component that displays session statistics
 */
@Composable
fun StatisticsCard(
    statistics: SessionStatistics,
    modifier: Modifier = Modifier
) {
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
            // Header
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.Analytics,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                    text = "Session Statistics",
                    style = MaterialTheme.typography.titleMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            
            // Overall Stats
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                StatisticItem(
                    label = "Total",
                    value = statistics.totalCount.toString(),
                    modifier = Modifier.weight(1f)
                )
                StatisticItem(
                    label = "Correct",
                    value = statistics.correctCount.toString(),
                    modifier = Modifier.weight(1f)
                )
                StatisticItem(
                    label = "Accuracy",
                    value = "${statistics.getAccuracyPercentage()}%",
                    modifier = Modifier.weight(1f)
                )
            }
            
            // Category Breakdown (if available)
            val categoryBreakdown = statistics.getCategoryBreakdown()
            if (categoryBreakdown.isNotEmpty()) {
                Divider()
                
                Text(
                    text = "Category Breakdown",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                
                categoryBreakdown.forEach { (category, record) ->
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = formatCategoryName(category),
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            modifier = Modifier.weight(1f)
                        )
                        Text(
                            text = "${record.correctAttempts}/${record.totalAttempts} (${record.getAccuracyPercentage()}%)",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }
            
            // Session Duration
            if (statistics.getSessionDuration() > 0) {
                Text(
                    text = "Session Duration: ${statistics.getSessionDurationString()}",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

@Composable
private fun StatisticItem(
    label: String,
    value: String,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = value,
            style = MaterialTheme.typography.titleLarge,
            color = MaterialTheme.colorScheme.primary
        )
        Text(
            text = label,
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

private fun formatCategoryName(category: String): String {
    return when (category) {
        SessionStatistics.CATEGORY_HARD_TOTALS -> "Hard Totals"
        SessionStatistics.CATEGORY_SOFT_TOTALS -> "Soft Totals"
        SessionStatistics.CATEGORY_PAIRS -> "Pairs"
        SessionStatistics.CATEGORY_DEALER_WEAK -> "Weak Dealer"
        SessionStatistics.CATEGORY_DEALER_MEDIUM -> "Medium Dealer"
        SessionStatistics.CATEGORY_DEALER_STRONG -> "Strong Dealer"
        SessionStatistics.CATEGORY_ABSOLUTES -> "Absolutes"
        else -> category.replace("_", " ").lowercase().replaceFirstChar { it.uppercase() }
    }
}

@Preview(showBackground = true)
@Composable
fun StatisticsCardPreview() {
    BlackjackTrainerTheme {
        val sampleStats = SessionStatistics().apply {
            recordAttempt(SessionStatistics.CATEGORY_HARD_TOTALS, true)
            recordAttempt(SessionStatistics.CATEGORY_HARD_TOTALS, false)
            recordAttempt(SessionStatistics.CATEGORY_SOFT_TOTALS, true)
            recordAttempt(SessionStatistics.CATEGORY_PAIRS, true)
        }
        
        StatisticsCard(
            statistics = sampleStats,
            modifier = Modifier.fillMaxWidth().padding(16.dp)
        )
    }
}