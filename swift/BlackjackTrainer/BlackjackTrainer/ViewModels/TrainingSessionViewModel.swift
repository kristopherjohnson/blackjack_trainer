import Foundation
import Observation

// MARK: - Training Session View Model

@MainActor
@Observable
class TrainingSessionViewModel {
    // MARK: - Published Properties
    
    var state: SessionState = .ready
    var currentScenario: GameScenario?
    var sessionStats: SessionStats = SessionStats()
    var feedback: FeedbackResult?
    var progress: Double = 0.0
    var questionsAnswered: Int = 0
    
    // MARK: - Session State
    
    enum SessionState: Equatable {
        case ready
        case active
        case showingFeedback
        case completed
    }
    
    // MARK: - Dependencies
    
    private let strategyChart = StrategyChart()
    private let statisticsManager = StatisticsManager.shared
    private let scenarioGenerator = ScenarioGenerator()
    let sessionConfig: SessionConfiguration
    
    // MARK: - Initialization
    
    init(sessionConfig: SessionConfiguration) {
        self.sessionConfig = sessionConfig
    }
    
    // MARK: - Session Management
    
    func startSession() {
        state = .ready
        sessionStats = SessionStats()
        questionsAnswered = 0
        progress = 0.0
        feedback = nil
        generateNextScenario()
    }
    
    func generateNextScenario() {
        guard questionsAnswered < sessionConfig.maxQuestions else {
            completeSession()
            return
        }
        
        currentScenario = scenarioGenerator.generateScenario(for: sessionConfig)
        state = .active
        feedback = nil
    }
    
    func submitAnswer(_ action: Action) {
        guard let scenario = currentScenario else { return }
        
        let correctAction = strategyChart.getCorrectAction(for: scenario)
        let isCorrect = action == correctAction
        
        updateStatistics(scenario: scenario, userAction: action, isCorrect: isCorrect)
        
        let explanation = strategyChart.getExplanation(for: scenario)
        feedback = FeedbackResult(
            isCorrect: isCorrect,
            userAction: action,
            correctAction: correctAction,
            explanation: explanation,
            scenario: scenario
        )
        
        state = .showingFeedback
    }
    
    func continueToNextQuestion() {
        questionsAnswered += 1
        updateProgress()
        
        if questionsAnswered >= sessionConfig.maxQuestions {
            completeSession()
        } else {
            generateNextScenario()
        }
    }
    
    func completeSession() {
        statisticsManager.completeSession(configuration: sessionConfig)
        state = .completed
    }
    
    func endSessionEarly() {
        statisticsManager.completeSession(configuration: sessionConfig)
        state = .completed
    }
    
    // MARK: - Statistics Management
    
    private func updateStatistics(scenario: GameScenario, userAction: Action, isCorrect: Bool) {
        let dealerStrength = DealerStrength.from(card: scenario.dealerCard)
        statisticsManager.recordAttempt(
            handType: scenario.handType,
            dealerStrength: dealerStrength,
            isCorrect: isCorrect
        )
        
        sessionStats.record(attempt: isCorrect)
    }
    
    private func updateProgress() {
        progress = Double(questionsAnswered) / Double(sessionConfig.maxQuestions)
    }
    
    // MARK: - Computed Properties
    
    var sessionTitle: String {
        let baseTitle = sessionConfig.sessionType.displayName
        if let subtype = sessionConfig.subtype {
            return "\(baseTitle) - \(subtype.displayName)"
        }
        return baseTitle
    }
    
    var questionsRemaining: Int {
        return max(0, sessionConfig.maxQuestions - questionsAnswered)
    }
    
    var canContinue: Bool {
        return state == .showingFeedback && questionsAnswered < sessionConfig.maxQuestions
    }
    
    var isSessionComplete: Bool {
        return state == .completed
    }
    
    var currentAccuracy: Double {
        return sessionStats.accuracy
    }
    
    var correctAnswersCount: Int {
        return sessionStats.correctCount
    }
}