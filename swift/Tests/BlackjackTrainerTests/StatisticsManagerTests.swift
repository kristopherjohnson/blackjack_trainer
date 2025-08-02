import XCTest
@testable import BlackjackTrainer

@MainActor
final class StatisticsManagerTests: XCTestCase {
    
    var statisticsManager: StatisticsManager!
    
    override func setUp() {
        super.setUp()
        statisticsManager = StatisticsManager.shared
        statisticsManager.startNewSession() // Start fresh
    }
    
    override func tearDown() {
        statisticsManager.startNewSession() // Clean up
        statisticsManager = nil
        super.tearDown()
    }
    
    // MARK: - Basic Statistics Tests
    
    func testRecordAttempt() {
        // Test initial state
        XCTAssertEqual(statisticsManager.currentSessionStats.totalCount, 0)
        XCTAssertEqual(statisticsManager.currentSessionStats.correctCount, 0)
        XCTAssertEqual(statisticsManager.currentSessionStats.accuracy, 0.0)
        
        // Record correct attempt
        statisticsManager.recordAttempt(handType: .hard, dealerStrength: .weak, isCorrect: true)
        
        XCTAssertEqual(statisticsManager.currentSessionStats.totalCount, 1)
        XCTAssertEqual(statisticsManager.currentSessionStats.correctCount, 1)
        XCTAssertEqual(statisticsManager.currentSessionStats.accuracy, 100.0)
        
        // Record incorrect attempt
        statisticsManager.recordAttempt(handType: .soft, dealerStrength: .strong, isCorrect: false)
        
        XCTAssertEqual(statisticsManager.currentSessionStats.totalCount, 2)
        XCTAssertEqual(statisticsManager.currentSessionStats.correctCount, 1)
        XCTAssertEqual(statisticsManager.currentSessionStats.accuracy, 50.0)
    }
    
    func testCategoryTracking() {
        // Record attempts for different categories
        statisticsManager.recordAttempt(handType: .hard, dealerStrength: .weak, isCorrect: true)
        statisticsManager.recordAttempt(handType: .hard, dealerStrength: .weak, isCorrect: false)
        statisticsManager.recordAttempt(handType: .soft, dealerStrength: .strong, isCorrect: true)
        
        let hardWeakCategory = "hard-weak"
        let softStrongCategory = "soft-strong"
        
        // Check category stats
        XCTAssertEqual(statisticsManager.currentSessionStats.categoryStats[hardWeakCategory]?.total, 2)
        XCTAssertEqual(statisticsManager.currentSessionStats.categoryStats[hardWeakCategory]?.correct, 1)
        XCTAssertEqual(statisticsManager.currentSessionStats.categoryStats[hardWeakCategory]?.accuracy, 50.0)
        
        XCTAssertEqual(statisticsManager.currentSessionStats.categoryStats[softStrongCategory]?.total, 1)
        XCTAssertEqual(statisticsManager.currentSessionStats.categoryStats[softStrongCategory]?.correct, 1)
        XCTAssertEqual(statisticsManager.currentSessionStats.categoryStats[softStrongCategory]?.accuracy, 100.0)
    }
    
    func testSessionReset() {
        // Record some attempts
        statisticsManager.recordAttempt(handType: .hard, dealerStrength: .weak, isCorrect: true)
        statisticsManager.recordAttempt(handType: .soft, dealerStrength: .strong, isCorrect: false)
        
        XCTAssertEqual(statisticsManager.currentSessionStats.totalCount, 2)
        XCTAssertFalse(statisticsManager.currentSessionStats.categoryStats.isEmpty)
        
        // Start new session
        statisticsManager.startNewSession()
        
        XCTAssertEqual(statisticsManager.currentSessionStats.totalCount, 0)
        XCTAssertEqual(statisticsManager.currentSessionStats.correctCount, 0)
        XCTAssertTrue(statisticsManager.currentSessionStats.categoryStats.isEmpty)
    }
    
    // MARK: - Hand Type Accuracy Tests
    
    func testHandTypeAccuracy() {
        // Record mixed attempts for hard totals
        statisticsManager.recordAttempt(handType: .hard, dealerStrength: .weak, isCorrect: true)
        statisticsManager.recordAttempt(handType: .hard, dealerStrength: .medium, isCorrect: true)
        statisticsManager.recordAttempt(handType: .hard, dealerStrength: .strong, isCorrect: false)
        
        // Record attempts for soft totals
        statisticsManager.recordAttempt(handType: .soft, dealerStrength: .weak, isCorrect: true)
        statisticsManager.recordAttempt(handType: .soft, dealerStrength: .strong, isCorrect: true)
        
        // Test hand type accuracy calculations
        let hardAccuracy = statisticsManager.getHandTypeAccuracy(.hard)
        XCTAssertEqual(hardAccuracy, 66.7, accuracy: 0.1, "Hard totals: 2/3 correct = 66.7%")
        
        let softAccuracy = statisticsManager.getHandTypeAccuracy(.soft)
        XCTAssertEqual(softAccuracy, 100.0, "Soft totals: 2/2 correct = 100%")
        
        let pairAccuracy = statisticsManager.getHandTypeAccuracy(.pair)
        XCTAssertEqual(pairAccuracy, 0.0, "Pairs: no attempts = 0%")
    }
    
    func testDealerStrengthAccuracy() {
        // Record attempts against different dealer strengths
        statisticsManager.recordAttempt(handType: .hard, dealerStrength: .weak, isCorrect: true)
        statisticsManager.recordAttempt(handType: .soft, dealerStrength: .weak, isCorrect: true)
        statisticsManager.recordAttempt(handType: .pair, dealerStrength: .weak, isCorrect: false)
        
        statisticsManager.recordAttempt(handType: .hard, dealerStrength: .strong, isCorrect: false)
        statisticsManager.recordAttempt(handType: .soft, dealerStrength: .strong, isCorrect: true)
        
        // Test dealer strength accuracy calculations
        let weakAccuracy = statisticsManager.getDealerStrengthAccuracy(.weak)
        XCTAssertEqual(weakAccuracy, 66.7, accuracy: 0.1, "Weak dealers: 2/3 correct = 66.7%")
        
        let strongAccuracy = statisticsManager.getDealerStrengthAccuracy(.strong)
        XCTAssertEqual(strongAccuracy, 50.0, "Strong dealers: 1/2 correct = 50%")
        
        let mediumAccuracy = statisticsManager.getDealerStrengthAccuracy(.medium)
        XCTAssertEqual(mediumAccuracy, 0.0, "Medium dealers: no attempts = 0%")
    }
    
    // MARK: - Session History Tests
    
    func testSessionHistory() {
        XCTAssertTrue(statisticsManager.recentSessions.isEmpty, "Should start with no session history")
        
        // Record some attempts
        statisticsManager.recordAttempt(handType: .hard, dealerStrength: .weak, isCorrect: true)
        statisticsManager.recordAttempt(handType: .soft, dealerStrength: .strong, isCorrect: false)
        
        // Complete session
        let config = SessionConfiguration(sessionType: .random)
        statisticsManager.completeSession(configuration: config)
        
        // Should still have current session data but also history
        XCTAssertEqual(statisticsManager.sessionHistory.count, 1)
        XCTAssertEqual(statisticsManager.sessionHistory.first?.sessionType, .random)
        XCTAssertEqual(statisticsManager.sessionHistory.first?.stats.totalCount, 2)
    }
    
    func testSessionHistoryLimit() {
        // Create more than 10 sessions to test limit
        for i in 0..<12 {
            statisticsManager.recordAttempt(handType: .hard, dealerStrength: .weak, isCorrect: i % 2 == 0)
            let config = SessionConfiguration(sessionType: .random)
            statisticsManager.completeSession(configuration: config)
            statisticsManager.startNewSession()
        }
        
        // Should only keep last 10 sessions
        XCTAssertEqual(statisticsManager.sessionHistory.count, 10)
    }
    
    func testClearSessionHistory() {
        // Add some sessions
        statisticsManager.recordAttempt(handType: .hard, dealerStrength: .weak, isCorrect: true)
        let config = SessionConfiguration(sessionType: .random)
        statisticsManager.completeSession(configuration: config)
        
        XCTAssertFalse(statisticsManager.sessionHistory.isEmpty)
        
        // Clear history
        statisticsManager.clearSessionHistory()
        
        XCTAssertTrue(statisticsManager.sessionHistory.isEmpty)
    }
    
    // MARK: - Utility Tests
    
    func testHasSessionData() {
        XCTAssertFalse(statisticsManager.hasSessionData, "Should have no session data initially")
        
        statisticsManager.recordAttempt(handType: .hard, dealerStrength: .weak, isCorrect: true)
        
        XCTAssertTrue(statisticsManager.hasSessionData, "Should have session data after recording attempt")
    }
    
    func testSessionDurationFormatted() {
        // Since we can't easily control the session start time in tests,
        // we'll just verify the format is correct
        let formatted = statisticsManager.sessionDurationFormatted
        XCTAssertTrue(formatted.contains("m"), "Should contain minutes")
        XCTAssertTrue(formatted.contains("s"), "Should contain seconds")
    }
}