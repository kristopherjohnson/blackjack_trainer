import Foundation
import Observation


// MARK: - Statistics Manager

@MainActor
@Observable
public class StatisticsManager {
    var currentSessionStats = SessionStats()
    var sessionHistory: [SessionResult] = [] // Temporary in-memory only
    
    // Session-only design - no persistent storage
    nonisolated public static let shared = StatisticsManager()
    
    nonisolated private init() {
        // Private initializer for singleton
    }
    
    // MARK: - Statistics Recording
    
    func recordAttempt(handType: HandType, dealerStrength: DealerStrength, isCorrect: Bool) {
        let category = "\(handType.rawValue)-\(dealerStrength.rawValue)"
        currentSessionStats.record(category: category, correct: isCorrect)
    }
    
    func getSessionStats() -> SessionStats {
        return currentSessionStats
    }
    
    func startNewSession() {
        // Save current session to temporary history if it has data
        if currentSessionStats.totalCount > 0 {
            let sessionResult = SessionResult(
                sessionType: .random, // Default type for session results
                subtype: nil,
                stats: currentSessionStats
            )
            sessionHistory.append(sessionResult)
        }
        
        // Reset current session
        currentSessionStats = SessionStats()
        
        // Keep only recent sessions in memory (limit to 10)
        if sessionHistory.count > 10 {
            sessionHistory = Array(sessionHistory.suffix(10))
        }
    }
    
    func completeSession(configuration: SessionConfiguration) {
        if currentSessionStats.totalCount > 0 {
            let sessionResult = SessionResult(
                sessionType: configuration.sessionType,
                subtype: configuration.subtype,
                stats: currentSessionStats
            )
            sessionHistory.append(sessionResult)
            
            // Keep only recent sessions in memory
            if sessionHistory.count > 10 {
                sessionHistory = Array(sessionHistory.suffix(10))
            }
        }
    }
    
    // MARK: - Statistics Analysis
    
    func getCategoryAccuracy(_ category: String) -> Double {
        return currentSessionStats.categoryStats[category]?.accuracy ?? 0.0
    }
    
    func getHandTypeAccuracy(_ handType: HandType) -> Double {
        let relevantCategories = currentSessionStats.categoryStats.filter { key, _ in
            key.hasPrefix(handType.rawValue)
        }
        
        let totalCorrect = relevantCategories.values.reduce(0) { $0 + $1.correct }
        let totalAttempts = relevantCategories.values.reduce(0) { $0 + $1.total }
        
        guard totalAttempts > 0 else { return 0.0 }
        return Double(totalCorrect) / Double(totalAttempts) * 100
    }
    
    func getDealerStrengthAccuracy(_ strength: DealerStrength) -> Double {
        let relevantCategories = currentSessionStats.categoryStats.filter { key, _ in
            key.hasSuffix(strength.rawValue)
        }
        
        let totalCorrect = relevantCategories.values.reduce(0) { $0 + $1.correct }
        let totalAttempts = relevantCategories.values.reduce(0) { $0 + $1.total }
        
        guard totalAttempts > 0 else { return 0.0 }
        return Double(totalCorrect) / Double(totalAttempts) * 100
    }
    
    var hasSessionData: Bool {
        return currentSessionStats.totalCount > 0
    }
    
    var sessionDurationFormatted: String {
        let duration = currentSessionStats.sessionDuration
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes)m \(seconds)s"
    }
    
    // MARK: - Recent Session History (Temporary)
    
    var recentSessions: [SessionResult] {
        return Array(sessionHistory.suffix(5)) // Show last 5 sessions
    }
    
    func clearSessionHistory() {
        sessionHistory.removeAll()
    }
}