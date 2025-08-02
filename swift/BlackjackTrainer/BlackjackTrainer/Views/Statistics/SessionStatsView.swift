import SwiftUI

// MARK: - Session Stats View

struct SessionStatsView: View {
    let stats: SessionStats
    
    var body: some View {
        // Compact single-line progress display
        HStack(spacing: 16) {
            if stats.totalCount > 0 {
                // Accuracy percentage
                HStack(spacing: 4) {
                    Text(String(format: "%.0f%%", stats.accuracy))
                        .font(.body.bold())
                        .foregroundColor(accuracyColor(stats.accuracy))
                    
                    Text("Accuracy")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("•")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Questions count
                HStack(spacing: 4) {
                    Text("\(stats.correctCount)/\(stats.totalCount)")
                        .font(.body.bold())
                        .foregroundColor(.primary)
                    
                    Text("Questions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if stats.sessionDuration > 0 {
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Duration
                    HStack(spacing: 4) {
                        Text(formatDuration(stats.sessionDuration))
                            .font(.body.bold())
                            .foregroundColor(.secondary)
                        
                        Text("Time")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            } else {
                Text("Ready to start")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.05))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }
    
    // MARK: - Helper Methods
    
    private func accuracyColor(_ accuracy: Double) -> Color {
        switch accuracy {
        case 90...100:
            return .green
        case 70..<90:
            return .orange
        default:
            return .red
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes)m \(seconds)s"
    }
    
    private var accessibilityDescription: String {
        if stats.totalCount > 0 {
            return String(format: "Session progress: %.1f percent accuracy, %d correct out of %d questions, duration %@", stats.accuracy, stats.correctCount, stats.totalCount, formatDuration(stats.sessionDuration))
        } else {
            return "Session progress: No questions answered yet"
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 30) {
        // Active session stats
        SessionStatsView(
            stats: {
                var stats = SessionStats()
                stats.record(attempt: true)
                stats.record(attempt: true)
                stats.record(attempt: false)
                stats.record(attempt: true)
                return stats
            }()
        )
        
        // Empty session stats
        SessionStatsView(stats: SessionStats())
    }
    .padding()
}