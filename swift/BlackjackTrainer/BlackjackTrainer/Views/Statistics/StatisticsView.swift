import SwiftUI

// MARK: - Statistics View

public struct StatisticsView: View {
    @Environment(StatisticsManager.self) var statsManager
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                currentSessionSection
                
                if !statsManager.currentSessionStats.categoryStats.isEmpty {
                    categoriesSection
                }
                
                if !statsManager.recentSessions.isEmpty {
                    recentSessionsSection
                }
                
                actionsSection
            }
            .navigationTitle("Statistics")
        }
    }
    
    // MARK: - Current Session Section
    
    private var currentSessionSection: some View {
        Section("Current Session") {
            if statsManager.hasSessionData {
                StatRow(
                    title: "Session Accuracy",
                    value: String(format: "%.1f%%", statsManager.currentSessionStats.accuracy),
                    valueColor: accuracyColor(statsManager.currentSessionStats.accuracy)
                )
                
                StatRow(
                    title: "Questions Answered",
                    value: "\(statsManager.currentSessionStats.totalCount)"
                )
                
                StatRow(
                    title: "Correct Answers",
                    value: "\(statsManager.currentSessionStats.correctCount)"
                )
                
                StatRow(
                    title: "Session Duration",
                    value: statsManager.sessionDurationFormatted
                )
            } else {
                Text("No current session data")
                    .foregroundColor(.secondary)
                    .font(.body)
            }
        }
    }
    
    // MARK: - Categories Section
    
    private var categoriesSection: some View {
        Section("By Category (This Session)") {
            ForEach(statsManager.currentSessionStats.categoryStats.keys.sorted(), id: \.self) { category in
                let stats = statsManager.currentSessionStats.categoryStats[category]!
                StatRow(
                    title: formatCategoryName(category),
                    value: String(format: "%.1f%% (%d/%d)", stats.accuracy, stats.correct, stats.total),
                    valueColor: accuracyColor(stats.accuracy)
                )
            }
        }
    }
    
    // MARK: - Recent Sessions Section
    
    private var recentSessionsSection: some View {
        Section("Recent Sessions") {
            ForEach(statsManager.recentSessions) { session in
                RecentSessionRow(session: session)
            }
        }
    }
    
    // MARK: - Actions Section
    
    private var actionsSection: some View {
        Section {
            Button("Start New Session") {
                statsManager.startNewSession()
            }
            .foregroundColor(.blue)
            
            if !statsManager.recentSessions.isEmpty {
                Button("Clear History") {
                    statsManager.clearSessionHistory()
                }
                .foregroundColor(.red)
            }
        } footer: {
            Text("Statistics are session-only and reset when starting a new session. Recent sessions are kept temporarily in memory.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
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
    
    private func formatCategoryName(_ category: String) -> String {
        let components = category.split(separator: "-")
        guard components.count == 2 else { return category.capitalized }
        
        let handType = String(components[0]).capitalized
        let dealerStrength = String(components[1]).capitalized
        
        return "\(handType) vs \(dealerStrength)"
    }
}

// MARK: - Stat Row

struct StatRow: View {
    let title: String
    let value: String
    let valueColor: Color
    
    init(title: String, value: String, valueColor: Color = .primary) {
        self.title = title
        self.value = value
        self.valueColor = valueColor
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.body.bold())
                .foregroundColor(valueColor)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

// MARK: - Recent Session Row

struct RecentSessionRow: View {
    let session: SessionResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(sessionTitle)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(String(format: "%.0f%%", session.stats.accuracy))
                    .font(.body.bold())
                    .foregroundColor(accuracyColor(session.stats.accuracy))
            }
            
            HStack {
                Text("\(session.stats.correctCount)/\(session.stats.totalCount) correct")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(RelativeDateTimeFormatter().localizedString(for: session.completedAt, relativeTo: Date()))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
    
    private var sessionTitle: String {
        let baseTitle = session.sessionType.displayName
        if let subtype = session.subtype {
            return "\(baseTitle) - \(subtype.displayName)"
        }
        return baseTitle
    }
    
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
}

// MARK: - Preview

#Preview {
    StatisticsView()
        .environment(StatisticsManager.shared)
}