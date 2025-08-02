import SwiftUI

// MARK: - Session Stats View

struct SessionStatsView: View {
    let stats: SessionStats
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Session Progress")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if stats.totalCount > 0 {
                VStack(spacing: 12) {
                    // Overall accuracy
                    HStack {
                        Text("Accuracy")
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f%%", stats.accuracy))
                            .font(.body.bold())
                            .foregroundColor(accuracyColor(stats.accuracy))
                    }
                    
                    // Questions answered
                    HStack {
                        Text("Questions")
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(stats.correctCount)/\(stats.totalCount)")
                            .font(.body.bold())
                            .foregroundColor(.primary)
                    }
                    
                    // Session duration
                    HStack {
                        Text("Duration")
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(formatDuration(stats.sessionDuration))
                            .font(.body.bold())
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.secondary.opacity(0.1))
                )
            } else {
                Text("No questions answered yet")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.secondary.opacity(0.1))
                    )
            }
        }
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