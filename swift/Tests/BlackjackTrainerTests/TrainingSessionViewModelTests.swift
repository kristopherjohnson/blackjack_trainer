import XCTest
@testable import BlackjackTrainer

@MainActor
final class TrainingSessionViewModelTests: XCTestCase {
    
    var viewModel: TrainingSessionViewModel!
    var mockStatisticsManager: MockStatisticsManager!
    var mockScenarioGenerator: MockScenarioGenerator!
    
    override func setUp() {
        super.setUp()
        mockStatisticsManager = MockStatisticsManager()
        mockScenarioGenerator = MockScenarioGenerator()
        
        let config = SessionConfiguration(sessionType: .random)
        viewModel = TrainingSessionViewModel(
            statisticsManager: mockStatisticsManager,
            scenarioGenerator: mockScenarioGenerator,
            sessionConfig: config
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockStatisticsManager = nil
        mockScenarioGenerator = nil
        super.tearDown()
    }
    
    // MARK: - Session Management Tests
    
    func testSessionInitialization() {
        XCTAssertEqual(viewModel.state, .ready)
        XCTAssertNil(viewModel.currentScenario)
        XCTAssertEqual(viewModel.questionsAnswered, 0)
        XCTAssertEqual(viewModel.progress, 0.0)
        XCTAssertNil(viewModel.feedback)
    }
    
    func testStartSession() {
        // Mock should provide a scenario
        mockScenarioGenerator.nextScenario = createMockScenario()
        
        viewModel.startSession()
        
        XCTAssertEqual(viewModel.state, .active)
        XCTAssertNotNil(viewModel.currentScenario)
        XCTAssertEqual(viewModel.questionsAnswered, 0)
        XCTAssertEqual(viewModel.progress, 0.0)
    }
    
    func testSubmitCorrectAnswer() {
        // Setup scenario
        let scenario = createMockScenario()
        mockScenarioGenerator.nextScenario = scenario
        viewModel.startSession()
        
        // Submit correct answer
        viewModel.submitAnswer(.hit) // Mock scenario expects hit
        
        XCTAssertEqual(viewModel.state, .showingFeedback)
        XCTAssertNotNil(viewModel.feedback)
        XCTAssertTrue(viewModel.feedback?.isCorrect == true)
        XCTAssertEqual(viewModel.feedback?.userAction, .hit)
        XCTAssertEqual(viewModel.feedback?.correctAction, .hit)
    }
    
    func testSubmitIncorrectAnswer() {
        // Setup scenario
        let scenario = createMockScenario()
        mockScenarioGenerator.nextScenario = scenario
        viewModel.startSession()
        
        // Submit incorrect answer
        viewModel.submitAnswer(.stand) // Mock scenario expects hit
        
        XCTAssertEqual(viewModel.state, .showingFeedback)
        XCTAssertNotNil(viewModel.feedback)
        XCTAssertTrue(viewModel.feedback?.isCorrect == false)
        XCTAssertEqual(viewModel.feedback?.userAction, .stand)
        XCTAssertEqual(viewModel.feedback?.correctAction, .hit)
    }
    
    func testContinueToNextQuestion() {
        // Setup and answer first question
        mockScenarioGenerator.nextScenario = createMockScenario()
        viewModel.startSession()
        viewModel.submitAnswer(.hit)
        
        XCTAssertEqual(viewModel.questionsAnswered, 0) // Not incremented until continue
        
        // Prepare next scenario
        mockScenarioGenerator.nextScenario = createMockScenario(playerTotal: 17)
        
        viewModel.continueToNextQuestion()
        
        XCTAssertEqual(viewModel.questionsAnswered, 1)
        XCTAssertEqual(viewModel.progress, 1.0 / 50.0) // 1 out of 50 questions
        XCTAssertEqual(viewModel.state, .active)
        XCTAssertNotNil(viewModel.currentScenario)
    }
    
    func testSessionCompletion() {
        let config = SessionConfiguration(sessionType: .absolute) // Only 20 questions
        viewModel = TrainingSessionViewModel(
            statisticsManager: mockStatisticsManager,
            scenarioGenerator: mockScenarioGenerator,
            sessionConfig: config
        )
        
        // Answer all questions
        for i in 0..<20 {
            mockScenarioGenerator.nextScenario = createMockScenario(playerTotal: 10 + i)
            
            if i == 0 {
                viewModel.startSession()
            }
            
            viewModel.submitAnswer(.hit)
            
            if i < 19 { // Don't continue after last question
                viewModel.continueToNextQuestion()
            }
        }
        
        // Complete the session
        viewModel.continueToNextQuestion()
        
        XCTAssertEqual(viewModel.state, .completed)
        XCTAssertEqual(viewModel.questionsAnswered, 20)
        XCTAssertEqual(viewModel.progress, 1.0)
    }
    
    func testEarlySessionEnd() {
        mockScenarioGenerator.nextScenario = createMockScenario()
        viewModel.startSession()
        
        viewModel.endSessionEarly()
        
        XCTAssertEqual(viewModel.state, .completed)
        XCTAssertTrue(mockStatisticsManager.sessionCompleted)
    }
    
    // MARK: - Statistics Tests
    
    func testStatisticsRecording() {
        mockScenarioGenerator.nextScenario = createMockScenario()
        viewModel.startSession()
        
        // Submit correct answer
        viewModel.submitAnswer(.hit)
        
        XCTAssertEqual(mockStatisticsManager.recordedAttempts.count, 1)
        XCTAssertEqual(mockStatisticsManager.recordedAttempts[0].handType, .hard)
        XCTAssertEqual(mockStatisticsManager.recordedAttempts[0].dealerStrength, .strong)
        XCTAssertTrue(mockStatisticsManager.recordedAttempts[0].isCorrect)
    }
    
    func testSessionStatsUpdate() {
        mockScenarioGenerator.nextScenario = createMockScenario()
        viewModel.startSession()
        
        XCTAssertEqual(viewModel.sessionStats.totalCount, 0)
        XCTAssertEqual(viewModel.sessionStats.correctCount, 0)
        
        // Submit correct answer
        viewModel.submitAnswer(.hit)
        
        XCTAssertEqual(viewModel.sessionStats.totalCount, 1)
        XCTAssertEqual(viewModel.sessionStats.correctCount, 1)
        XCTAssertEqual(viewModel.sessionStats.accuracy, 100.0)
    }
    
    // MARK: - Computed Properties Tests
    
    func testSessionTitle() {
        // Test without subtype
        let randomConfig = SessionConfiguration(sessionType: .random)
        let randomViewModel = TrainingSessionViewModel(sessionConfig: randomConfig)
        XCTAssertEqual(randomViewModel.sessionTitle, "Quick Practice")
        
        // Test with subtype
        let dealerConfig = SessionConfiguration(sessionType: .dealerGroup, subtype: .weak)
        let dealerViewModel = TrainingSessionViewModel(sessionConfig: dealerConfig)
        XCTAssertEqual(dealerViewModel.sessionTitle, "Dealer Strength - Weak Dealers")
    }
    
    func testQuestionsRemaining() {
        let config = SessionConfiguration(sessionType: .absolute) // 20 questions
        let testViewModel = TrainingSessionViewModel(sessionConfig: config)
        
        XCTAssertEqual(testViewModel.questionsRemaining, 20)
        
        // Simulate answering questions
        testViewModel.questionsAnswered = 5
        XCTAssertEqual(testViewModel.questionsRemaining, 15)
        
        testViewModel.questionsAnswered = 20
        XCTAssertEqual(testViewModel.questionsRemaining, 0)
    }
    
    func testCanContinue() {
        XCTAssertFalse(viewModel.canContinue) // Not in feedback state
        
        mockScenarioGenerator.nextScenario = createMockScenario()
        viewModel.startSession()
        viewModel.submitAnswer(.hit)
        
        XCTAssertTrue(viewModel.canContinue) // In feedback state with questions remaining
        
        // Simulate completing all questions
        viewModel.questionsAnswered = 50
        XCTAssertFalse(viewModel.canContinue) // No questions remaining
    }
    
    func testIsSessionComplete() {
        XCTAssertFalse(viewModel.isSessionComplete)
        
        viewModel.state = .completed
        XCTAssertTrue(viewModel.isSessionComplete)
    }
    
    // MARK: - Helper Methods
    
    private func createMockScenario(playerTotal: Int = 16) -> GameScenario {
        return GameScenario(
            handType: .hard,
            playerCards: [Card(value: 10), Card(value: playerTotal - 10)],
            playerTotal: playerTotal,
            dealerCard: Card(value: 10) // Strong dealer
        )
    }
}

// MARK: - Mock Objects

class MockStatisticsManager: StatisticsManaging {
    var sessionCompleted = false
    var recordedAttempts: [(handType: HandType, dealerStrength: DealerStrength, isCorrect: Bool)] = []
    
    func recordAttempt(handType: HandType, dealerStrength: DealerStrength, isCorrect: Bool) {
        recordedAttempts.append((handType: handType, dealerStrength: dealerStrength, isCorrect: isCorrect))
    }
    
    func getSessionStats() -> SessionStats {
        return SessionStats()
    }
    
    func startNewSession() {
        // Mock implementation
    }
    
    func completeSession(configuration: SessionConfiguration) {
        sessionCompleted = true
    }
}

@MainActor
class MockScenarioGenerator: ScenarioGenerator {
    var nextScenario: GameScenario?
    
    override func generateScenario(for configuration: SessionConfiguration) -> GameScenario? {
        return nextScenario
    }
}