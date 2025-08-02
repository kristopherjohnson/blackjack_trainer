import XCTest
@testable import BlackjackTrainer

@MainActor
final class ScenarioGeneratorTests: XCTestCase {
    
    var scenarioGenerator: ScenarioGenerator!
    
    override func setUp() {
        super.setUp()
        scenarioGenerator = ScenarioGenerator()
    }
    
    override func tearDown() {
        scenarioGenerator = nil
        super.tearDown()
    }
    
    // MARK: - Random Scenario Tests
    
    func testGenerateRandomScenario() {
        let config = SessionConfiguration(sessionType: .random)
        
        // Generate multiple scenarios to test randomness
        var hardCount = 0
        var softCount = 0
        var pairCount = 0
        
        for _ in 0..<100 {
            guard let scenario = scenarioGenerator.generateScenario(for: config) else {
                XCTFail("Should generate scenario")
                continue
            }
            
            // Verify basic properties
            XCTAssertTrue((2...11).contains(scenario.dealerCard.value), "Dealer card should be 2-11")
            XCTAssertFalse(scenario.playerCards.isEmpty, "Should have player cards")
            
            // Count hand types
            switch scenario.handType {
            case .hard:
                hardCount += 1
                XCTAssertTrue((5...20).contains(scenario.playerTotal), "Hard total should be 5-20")
            case .soft:
                softCount += 1
                XCTAssertTrue((13...20).contains(scenario.playerTotal), "Soft total should be 13-20")
                XCTAssertTrue(scenario.playerCards.contains { $0.isAce }, "Soft hand should contain Ace")
            case .pair:
                pairCount += 1
                XCTAssertEqual(scenario.playerCards.count, 2, "Pair should have 2 cards")
                XCTAssertEqual(scenario.playerCards[0].value, scenario.playerCards[1].value, "Pair cards should match")
            }
        }
        
        // Verify we got some of each type (with some randomness tolerance)
        XCTAssertGreaterThan(hardCount, 10, "Should generate some hard totals")
        XCTAssertGreaterThan(softCount, 10, "Should generate some soft totals")
        XCTAssertGreaterThan(pairCount, 10, "Should generate some pairs")
    }
    
    // MARK: - Dealer Group Scenario Tests
    
    func testGenerateDealerGroupScenarios() {
        // Test weak dealers
        let weakConfig = SessionConfiguration(sessionType: .dealerGroup, subtype: .weak)
        
        for _ in 0..<20 {
            guard let scenario = scenarioGenerator.generateScenario(for: weakConfig) else {
                XCTFail("Should generate weak dealer scenario")
                continue
            }
            
            XCTAssertTrue([4, 5, 6].contains(scenario.dealerCard.value), "Weak dealer should be 4, 5, or 6")
        }
        
        // Test medium dealers
        let mediumConfig = SessionConfiguration(sessionType: .dealerGroup, subtype: .medium)
        
        for _ in 0..<20 {
            guard let scenario = scenarioGenerator.generateScenario(for: mediumConfig) else {
                XCTFail("Should generate medium dealer scenario")
                continue
            }
            
            XCTAssertTrue([2, 3, 7, 8].contains(scenario.dealerCard.value), "Medium dealer should be 2, 3, 7, or 8")
        }
        
        // Test strong dealers
        let strongConfig = SessionConfiguration(sessionType: .dealerGroup, subtype: .strong)
        
        for _ in 0..<20 {
            guard let scenario = scenarioGenerator.generateScenario(for: strongConfig) else {
                XCTFail("Should generate strong dealer scenario")
                continue
            }
            
            XCTAssertTrue([9, 10, 11].contains(scenario.dealerCard.value), "Strong dealer should be 9, 10, or 11")
        }
    }
    
    // MARK: - Hand Type Scenario Tests
    
    func testGenerateHandTypeScenarios() {
        // Test hard totals only
        let hardConfig = SessionConfiguration(sessionType: .handType, subtype: .hard)
        
        for _ in 0..<20 {
            guard let scenario = scenarioGenerator.generateScenario(for: hardConfig) else {
                XCTFail("Should generate hard total scenario")
                continue
            }
            
            XCTAssertEqual(scenario.handType, .hard, "Should generate hard total")
            XCTAssertTrue((5...20).contains(scenario.playerTotal), "Hard total should be 5-20")
        }
        
        // Test soft totals only
        let softConfig = SessionConfiguration(sessionType: .handType, subtype: .soft)
        
        for _ in 0..<20 {
            guard let scenario = scenarioGenerator.generateScenario(for: softConfig) else {
                XCTFail("Should generate soft total scenario")
                continue
            }
            
            XCTAssertEqual(scenario.handType, .soft, "Should generate soft total")
            XCTAssertTrue((13...20).contains(scenario.playerTotal), "Soft total should be 13-20")
            XCTAssertTrue(scenario.playerCards.contains { $0.isAce }, "Soft hand should contain Ace")
        }
        
        // Test pairs only
        let pairConfig = SessionConfiguration(sessionType: .handType, subtype: .pair)
        
        for _ in 0..<20 {
            guard let scenario = scenarioGenerator.generateScenario(for: pairConfig) else {
                XCTFail("Should generate pair scenario")
                continue
            }
            
            XCTAssertEqual(scenario.handType, .pair, "Should generate pair")
            XCTAssertEqual(scenario.playerCards.count, 2, "Pair should have 2 cards")
            XCTAssertEqual(scenario.playerCards[0].value, scenario.playerCards[1].value, "Pair cards should match")
        }
    }
    
    // MARK: - Absolute Scenario Tests
    
    func testGenerateAbsoluteScenarios() {
        let config = SessionConfiguration(sessionType: .absolute)
        
        // Generate multiple absolute scenarios
        var foundAbsolutes: Set<String> = []
        
        for _ in 0..<100 {
            guard let scenario = scenarioGenerator.generateScenario(for: config) else {
                XCTFail("Should generate absolute scenario")
                continue
            }
            
            let absoluteKey = "\(scenario.handType.rawValue)-\(scenario.playerTotal)"
            foundAbsolutes.insert(absoluteKey)
            
            // Verify this is actually an absolute rule
            let strategyChart = StrategyChart()
            XCTAssertTrue(strategyChart.isAbsoluteRule(for: scenario), "Generated scenario should be absolute rule")
        }
        
        // Should find some variety of absolute scenarios
        XCTAssertGreaterThan(foundAbsolutes.count, 3, "Should generate variety of absolute scenarios")
        
        // Check for some specific absolutes
        let possibleAbsolutes = [
            "pair-11",  // A,A
            "pair-8",   // 8,8
            "pair-10",  // 10,10
            "pair-5",   // 5,5
            "hard-17", "hard-18", "hard-19", "hard-20",
            "soft-19", "soft-20"
        ]
        
        let foundMatches = foundAbsolutes.intersection(Set(possibleAbsolutes))
        XCTAssertGreaterThan(foundMatches.count, 0, "Should find some expected absolute scenarios")
    }
    
    // MARK: - Invalid Configuration Tests
    
    func testInvalidConfigurations() {
        // Test dealer group without subtype
        let invalidDealerConfig = SessionConfiguration(sessionType: .dealerGroup, subtype: nil)
        let dealerScenario = scenarioGenerator.generateScenario(for: invalidDealerConfig)
        XCTAssertNil(dealerScenario, "Should return nil for dealer group without subtype")
        
        // Test hand type without subtype
        let invalidHandConfig = SessionConfiguration(sessionType: .handType, subtype: nil)
        let handScenario = scenarioGenerator.generateScenario(for: invalidHandConfig)
        XCTAssertNil(handScenario, "Should return nil for hand type without subtype")
    }
    
    // MARK: - Scenario Validity Tests
    
    func testScenarioValidityForStrategy() {
        let config = SessionConfiguration(sessionType: .random)
        let strategyChart = StrategyChart()
        
        // Generate scenarios and verify they can be looked up in strategy chart
        for _ in 0..<50 {
            guard let scenario = scenarioGenerator.generateScenario(for: config) else {
                XCTFail("Should generate scenario")
                continue
            }
            
            // This should not throw an error
            XCTAssertNoThrow(try strategyChart.getCorrectAction(for: scenario), "Generated scenario should be valid for strategy lookup")
        }
    }
    
    // MARK: - Card Generation Tests
    
    func testHardHandCardGeneration() {
        let config = SessionConfiguration(sessionType: .handType, subtype: .hard)
        
        for _ in 0..<20 {
            guard let scenario = scenarioGenerator.generateScenario(for: config) else {
                XCTFail("Should generate hard scenario")
                continue
            }
            
            // Verify the cards actually sum to the total
            let cardSum = scenario.playerCards.reduce(0) { $0 + $1.value }
            XCTAssertEqual(cardSum, scenario.playerTotal, "Card values should sum to player total")
            
            // Verify no aces counting as 11 in hard totals
            let hasAce11 = scenario.playerCards.contains { $0.value == 11 }
            if hasAce11 {
                // If there's an ace, the total should be > 21 if ace counted as 11
                let totalWithAce11 = scenario.playerCards.reduce(0) { sum, card in
                    sum + (card.value == 11 ? 11 : card.value)
                }
                XCTAssertLessThanOrEqual(totalWithAce11, 21, "Hard hand with ace should not bust when ace is 11")
            }
        }
    }
    
    func testSoftHandCardGeneration() {
        let config = SessionConfiguration(sessionType: .handType, subtype: .soft)
        
        for _ in 0..<20 {
            guard let scenario = scenarioGenerator.generateScenario(for: config) else {
                XCTFail("Should generate soft scenario")
                continue
            }
            
            // Should have exactly one ace
            let aceCount = scenario.playerCards.filter { $0.isAce }.count
            XCTAssertEqual(aceCount, 1, "Soft hand should have exactly one ace")
            
            // Should have exactly 2 cards
            XCTAssertEqual(scenario.playerCards.count, 2, "Soft hand should have exactly 2 cards")
            
            // Total should be ace (11) + other card
            let nonAceCard = scenario.playerCards.first { !$0.isAce }
            XCTAssertNotNil(nonAceCard, "Should have non-ace card")
            if let nonAce = nonAceCard {
                XCTAssertEqual(scenario.playerTotal, 11 + nonAce.value, "Soft total should be 11 + other card")
            }
        }
    }
    
    func testPairCardGeneration() {
        let config = SessionConfiguration(sessionType: .handType, subtype: .pair)
        
        for _ in 0..<20 {
            guard let scenario = scenarioGenerator.generateScenario(for: config) else {
                XCTFail("Should generate pair scenario")
                continue
            }
            
            // Should have exactly 2 cards
            XCTAssertEqual(scenario.playerCards.count, 2, "Pair should have exactly 2 cards")
            
            // Cards should be identical
            XCTAssertEqual(scenario.playerCards[0].value, scenario.playerCards[1].value, "Pair cards should be identical")
            
            // Player total should be the value of one card (for pairs, we use the single card value)
            XCTAssertEqual(scenario.playerTotal, scenario.playerCards[0].value, "Pair total should be single card value")
        }
    }
}