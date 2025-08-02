import XCTest
@testable import BlackjackTrainer

final class StrategyChartTests: XCTestCase {
    
    var strategyChart: StrategyChart!
    
    override func setUp() {
        super.setUp()
        strategyChart = StrategyChart()
    }
    
    override func tearDown() {
        strategyChart = nil
        super.tearDown()
    }
    
    // MARK: - Hard Totals Tests
    
    func testHardTotalsBasicRules() throws {
        // Hard 8 or less - always hit
        let hardEightScenario = GameScenario(
            handType: .hard,
            playerCards: [Card(value: 8)],
            playerTotal: 8,
            dealerCard: Card(value: 5)
        )
        let action = try strategyChart.getCorrectAction(for: hardEightScenario)
        XCTAssertEqual(action, .hit, "Hard 8 should always hit")
        
        // Hard 17+ - always stand
        let hardSeventeenScenario = GameScenario(
            handType: .hard,
            playerCards: [Card(value: 10), Card(value: 7)],
            playerTotal: 17,
            dealerCard: Card(value: 9)
        )
        let standAction = try strategyChart.getCorrectAction(for: hardSeventeenScenario)
        XCTAssertEqual(standAction, .stand, "Hard 17 should always stand")
    }
    
    func testHardTotalsDoubles() throws {
        // Hard 11 vs 10 - double
        let hardElevenScenario = GameScenario(
            handType: .hard,
            playerCards: [Card(value: 11)],
            playerTotal: 11,
            dealerCard: Card(value: 10)
        )
        let action = try strategyChart.getCorrectAction(for: hardElevenScenario)
        XCTAssertEqual(action, .double, "Hard 11 vs 10 should double")
        
        // Hard 11 vs Ace - hit
        let hardElevenVsAceScenario = GameScenario(
            handType: .hard,
            playerCards: [Card(value: 11)],
            playerTotal: 11,
            dealerCard: Card(value: 11)
        )
        let hitAction = try strategyChart.getCorrectAction(for: hardElevenVsAceScenario)
        XCTAssertEqual(hitAction, .hit, "Hard 11 vs Ace should hit")
    }
    
    func testHardTotalsStiffHands() throws {
        // Hard 16 vs weak dealer (5) - stand
        let hard16WeakScenario = GameScenario(
            handType: .hard,
            playerCards: [Card(value: 10), Card(value: 6)],
            playerTotal: 16,
            dealerCard: Card(value: 5)
        )
        let standAction = try strategyChart.getCorrectAction(for: hard16WeakScenario)
        XCTAssertEqual(standAction, .stand, "Hard 16 vs 5 should stand")
        
        // Hard 16 vs strong dealer (10) - hit
        let hard16StrongScenario = GameScenario(
            handType: .hard,
            playerCards: [Card(value: 10), Card(value: 6)],
            playerTotal: 16,
            dealerCard: Card(value: 10)
        )
        let hitAction = try strategyChart.getCorrectAction(for: hard16StrongScenario)
        XCTAssertEqual(hitAction, .hit, "Hard 16 vs 10 should hit")
    }
    
    // MARK: - Soft Totals Tests
    
    func testSoftTotalsBasicRules() throws {
        // Soft 19 - always stand
        let soft19Scenario = GameScenario(
            handType: .soft,
            playerCards: [Card(value: 11), Card(value: 8)],
            playerTotal: 19,
            dealerCard: Card(value: 6)
        )
        let action = try strategyChart.getCorrectAction(for: soft19Scenario)
        XCTAssertEqual(action, .stand, "Soft 19 should always stand")
        
        // Soft 18 vs 2 - stand
        let soft18Scenario = GameScenario(
            handType: .soft,
            playerCards: [Card(value: 11), Card(value: 7)],
            playerTotal: 18,
            dealerCard: Card(value: 2)
        )
        let standAction = try strategyChart.getCorrectAction(for: soft18Scenario)
        XCTAssertEqual(standAction, .stand, "Soft 18 vs 2 should stand")
    }
    
    func testSoftTotalsDoubles() throws {
        // Soft 18 vs 5 - double
        let soft18DoubleScenario = GameScenario(
            handType: .soft,
            playerCards: [Card(value: 11), Card(value: 7)],
            playerTotal: 18,
            dealerCard: Card(value: 5)
        )
        let doubleAction = try strategyChart.getCorrectAction(for: soft18DoubleScenario)
        XCTAssertEqual(doubleAction, .double, "Soft 18 vs 5 should double")
        
        // Soft 17 vs 4 - double
        let soft17DoubleScenario = GameScenario(
            handType: .soft,
            playerCards: [Card(value: 11), Card(value: 6)],
            playerTotal: 17,
            dealerCard: Card(value: 4)
        )
        let soft17DoubleAction = try strategyChart.getCorrectAction(for: soft17DoubleScenario)
        XCTAssertEqual(soft17DoubleAction, .double, "Soft 17 vs 4 should double")
    }
    
    // MARK: - Pairs Tests
    
    func testPairsAbsoluteRules() throws {
        // Always split Aces
        let acesScenario = GameScenario(
            handType: .pair,
            playerCards: [Card(value: 11), Card(value: 11)],
            playerTotal: 11,
            dealerCard: Card(value: 10)
        )
        let acesAction = try strategyChart.getCorrectAction(for: acesScenario)
        XCTAssertEqual(acesAction, .split, "Always split Aces")
        
        // Always split 8s
        let eightsScenario = GameScenario(
            handType: .pair,
            playerCards: [Card(value: 8), Card(value: 8)],
            playerTotal: 8,
            dealerCard: Card(value: 10)
        )
        let eightsAction = try strategyChart.getCorrectAction(for: eightsScenario)
        XCTAssertEqual(eightsAction, .split, "Always split 8s")
        
        // Never split 10s
        let tensScenario = GameScenario(
            handType: .pair,
            playerCards: [Card(value: 10), Card(value: 10)],
            playerTotal: 10,
            dealerCard: Card(value: 5)
        )
        let tensAction = try strategyChart.getCorrectAction(for: tensScenario)
        XCTAssertEqual(tensAction, .stand, "Never split 10s")
        
        // Never split 5s (treat as hard 10)
        let fivesScenario = GameScenario(
            handType: .pair,
            playerCards: [Card(value: 5), Card(value: 5)],
            playerTotal: 5,
            dealerCard: Card(value: 6)
        )
        let fivesAction = try strategyChart.getCorrectAction(for: fivesScenario)
        XCTAssertEqual(fivesAction, .double, "Never split 5s - double vs 6")
    }
    
    func testPairsConditionalSplits() throws {
        // 9,9 vs 7 - stand
        let nines7Scenario = GameScenario(
            handType: .pair,
            playerCards: [Card(value: 9), Card(value: 9)],
            playerTotal: 9,
            dealerCard: Card(value: 7)
        )
        let nines7Action = try strategyChart.getCorrectAction(for: nines7Scenario)
        XCTAssertEqual(nines7Action, .stand, "9,9 vs 7 should stand")
        
        // 9,9 vs 6 - split
        let nines6Scenario = GameScenario(
            handType: .pair,
            playerCards: [Card(value: 9), Card(value: 9)],
            playerTotal: 9,
            dealerCard: Card(value: 6)
        )
        let nines6Action = try strategyChart.getCorrectAction(for: nines6Scenario)
        XCTAssertEqual(nines6Action, .split, "9,9 vs 6 should split")
    }
    
    // MARK: - Absolute Rules Tests
    
    func testAbsoluteRules() {
        // Test always split scenarios
        let acesScenario = GameScenario(
            handType: .pair,
            playerCards: [Card(value: 11), Card(value: 11)],
            playerTotal: 11,
            dealerCard: Card(value: 5)
        )
        XCTAssertTrue(strategyChart.isAbsoluteRule(for: acesScenario), "Aces should be absolute rule")
        
        let eightsScenario = GameScenario(
            handType: .pair,
            playerCards: [Card(value: 8), Card(value: 8)],
            playerTotal: 8,
            dealerCard: Card(value: 9)
        )
        XCTAssertTrue(strategyChart.isAbsoluteRule(for: eightsScenario), "8s should be absolute rule")
        
        // Test never split scenarios
        let tensScenario = GameScenario(
            handType: .pair,
            playerCards: [Card(value: 10), Card(value: 10)],
            playerTotal: 10,
            dealerCard: Card(value: 5)
        )
        XCTAssertTrue(strategyChart.isAbsoluteRule(for: tensScenario), "10s should be absolute rule")
        
        // Test hard 17+ always stand
        let hard17Scenario = GameScenario(
            handType: .hard,
            playerCards: [Card(value: 10), Card(value: 7)],
            playerTotal: 17,
            dealerCard: Card(value: 10)
        )
        XCTAssertTrue(strategyChart.isAbsoluteRule(for: hard17Scenario), "Hard 17 should be absolute rule")
        
        // Test soft 19+ always stand
        let soft19Scenario = GameScenario(
            handType: .soft,
            playerCards: [Card(value: 11), Card(value: 8)],
            playerTotal: 19,
            dealerCard: Card(value: 10)
        )
        XCTAssertTrue(strategyChart.isAbsoluteRule(for: soft19Scenario), "Soft 19 should be absolute rule")
    }
    
    // MARK: - Explanation Tests
    
    func testExplanations() {
        // Test mnemonic explanations
        let acesScenario = GameScenario(
            handType: .pair,
            playerCards: [Card(value: 11), Card(value: 11)],
            playerTotal: 11,
            dealerCard: Card(value: 7)
        )
        let acesExplanation = strategyChart.getExplanation(for: acesScenario)
        XCTAssertTrue(acesExplanation.contains("Aces and eights"), "Should contain aces mnemonic")
        
        // Test dealer weakness explanation
        let dealerWeakScenario = GameScenario(
            handType: .hard,
            playerCards: [Card(value: 10), Card(value: 6)],
            playerTotal: 16,
            dealerCard: Card(value: 5)
        )
        let weakExplanation = strategyChart.getExplanation(for: dealerWeakScenario)
        XCTAssertTrue(weakExplanation.contains("bust cards"), "Should contain dealer weakness explanation")
    }
}