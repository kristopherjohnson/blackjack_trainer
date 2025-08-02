import Foundation

// MARK: - Statistics Models

/// Statistics for a specific category
struct CategoryStats: Codable {
    var correct: Int = 0
    var total: Int = 0
    
    var accuracy: Double {
        guard total > 0 else { return 0 }
        return Double(correct) / Double(total) * 100
    }
    
    mutating func record(isCorrect: Bool) {
        total += 1
        if isCorrect {
            correct += 1
        }
    }
}

/// Session statistics tracking
struct SessionStats: Codable {
    var correctCount: Int = 0
    var totalCount: Int = 0
    var categoryStats: [String: CategoryStats] = [:]
    var startTime: Date = Date()
    
    var accuracy: Double {
        guard totalCount > 0 else { return 0 }
        return Double(correctCount) / Double(totalCount) * 100
    }
    
    var sessionDuration: TimeInterval {
        Date().timeIntervalSince(startTime)
    }
    
    mutating func record(attempt isCorrect: Bool) {
        totalCount += 1
        if isCorrect {
            correctCount += 1
        }
    }
    
    mutating func record(category: String, correct: Bool) {
        if categoryStats[category] == nil {
            categoryStats[category] = CategoryStats()
        }
        categoryStats[category]?.record(isCorrect: correct)
        record(attempt: correct)
    }
}

/// Complete session result for temporary storage
struct SessionResult: Codable, Identifiable {
    let id = UUID()
    let sessionType: SessionType
    let subtype: SessionSubtype?
    let stats: SessionStats
    let completedAt: Date
    
    init(sessionType: SessionType, subtype: SessionSubtype?, stats: SessionStats) {
        self.sessionType = sessionType
        self.subtype = subtype
        self.stats = stats
        self.completedAt = Date()
    }
}

/// Feedback result for displaying to user
struct FeedbackResult {
    let isCorrect: Bool
    let userAction: Action
    let correctAction: Action
    let explanation: String
    let scenario: GameScenario
    
    init(isCorrect: Bool, userAction: Action, correctAction: Action, explanation: String, scenario: GameScenario) {
        self.isCorrect = isCorrect
        self.userAction = userAction
        self.correctAction = correctAction
        self.explanation = explanation
        self.scenario = scenario
    }
}