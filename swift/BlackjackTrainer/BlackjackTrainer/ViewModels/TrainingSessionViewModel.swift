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
        case error(TrainingError)
        
        static func == (lhs: SessionState, rhs: SessionState) -> Bool {
            switch (lhs, rhs) {
            case (.ready, .ready),
                 (.active, .active),
                 (.showingFeedback, .showingFeedback),
                 (.completed, .completed):
                return true
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
    
    enum TrainingError: LocalizedError {
        case scenarioGenerationFailed
        case statisticsUpdateFailed
        
        var errorDescription: String? {
            switch self {
            case .scenarioGenerationFailed:
                return "Unable to generate practice scenario. Please try again."
            case .statisticsUpdateFailed:
                return "Failed to save your progress. Your session will continue."
            }
        }
    }
    
    // MARK: - Dependencies
    
    private let strategyProvider: StrategyChartProviding
    private let statisticsManager: StatisticsManaging
    private let scenarioGenerator: ScenarioGenerator
    let sessionConfig: SessionConfiguration
    
    // MARK: - Initialization
    
    init(
        strategyProvider: StrategyChartProviding = StrategyChart(),
        statisticsManager: StatisticsManaging,
        scenarioGenerator: ScenarioGenerator,
        sessionConfig: SessionConfiguration
    ) {
        self.strategyProvider = strategyProvider
        self.statisticsManager = statisticsManager
        self.scenarioGenerator = scenarioGenerator
        self.sessionConfig = sessionConfig
    }
    
    // Convenience initializer with default dependencies
    convenience init(sessionConfig: SessionConfiguration) {
        self.init(
            strategyProvider: StrategyChart(),
            statisticsManager: StatisticsManager.shared,
            scenarioGenerator: ScenarioGenerator(),
            sessionConfig: sessionConfig
        )
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
        
        guard let scenario = scenarioGenerator.generateScenario(for: sessionConfig) else {
            state = .error(.scenarioGenerationFailed)
            return
        }
        
        currentScenario = scenario
        state = .active
        feedback = nil
    }
    
    func submitAnswer(_ action: Action) {
        guard let scenario = currentScenario else { return }
        
        do {
            let correctAction = try strategyProvider.getCorrectAction(for: scenario)
            let isCorrect = action == correctAction
            
            updateStatistics(scenario: scenario, userAction: action, isCorrect: isCorrect)
            
            let explanation = strategyProvider.getExplanation(for: scenario)
            feedback = FeedbackResult(
                isCorrect: isCorrect,
                userAction: action,
                correctAction: correctAction,
                explanation: explanation,
                scenario: scenario
            )
            
            state = .showingFeedback
            
        } catch {
            state = .error(.scenarioGenerationFailed)
        }
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
        if let manager = statisticsManager as? StatisticsManager {
            manager.completeSession(configuration: sessionConfig)
        }
        state = .completed
    }
    
    func endSessionEarly() {
        if let manager = statisticsManager as? StatisticsManager {
            manager.completeSession(configuration: sessionConfig)
        }
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