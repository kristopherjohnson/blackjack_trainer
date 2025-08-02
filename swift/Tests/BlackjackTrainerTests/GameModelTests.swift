import XCTest
@testable import BlackjackTrainer

final class GameModelTests: XCTestCase {
    
    // MARK: - Card Tests
    
    func testCardCreation() {
        let aceCard = Card(value: 11)
        XCTAssertEqual(aceCard.value, 11)
        XCTAssertEqual(aceCard.displayValue, "A")
        XCTAssertTrue(aceCard.isAce)
        XCTAssertFalse(aceCard.isFaceCard)
        
        let tenCard = Card(value: 10)
        XCTAssertEqual(tenCard.value, 10)
        XCTAssertEqual(tenCard.displayValue, "10")
        XCTAssertFalse(tenCard.isAce)
        XCTAssertFalse(tenCard.isFaceCard)
        
        let numberCard = Card(value: 7)
        XCTAssertEqual(numberCard.value, 7)
        XCTAssertEqual(numberCard.displayValue, "7")
        XCTAssertFalse(numberCard.isAce)
        XCTAssertFalse(numberCard.isFaceCard)
    }
    
    func testCardAccessibility() {
        let aceCard = Card(value: 11)
        XCTAssertEqual(aceCard.accessibilityDescription, "Ace")
        
        let tenCard = Card(value: 10)
        XCTAssertEqual(tenCard.accessibilityDescription, "Ten")
        
        let sevenCard = Card(value: 7)
        XCTAssertEqual(sevenCard.accessibilityDescription, "7")
    }
    
    // MARK: - HandType Tests
    
    func testHandTypeDisplayNames() {
        XCTAssertEqual(HandType.hard.displayName, "Hard Total")
        XCTAssertEqual(HandType.soft.displayName, "Soft Total")
        XCTAssertEqual(HandType.pair.displayName, "Pair")
    }
    
    // MARK: - Action Tests
    
    func testActionDisplayNames() {
        XCTAssertEqual(Action.hit.displayName, "Hit")
        XCTAssertEqual(Action.stand.displayName, "Stand")
        XCTAssertEqual(Action.double.displayName, "Double")
        XCTAssertEqual(Action.split.displayName, "Split")
    }
    
    func testActionAccessibility() {
        XCTAssertEqual(Action.hit.accessibilityLabel, "Hit - Take another card")
        XCTAssertEqual(Action.stand.accessibilityLabel, "Stand - Keep current hand")
        XCTAssertEqual(Action.double.accessibilityLabel, "Double Down - Double bet and take one card")
        XCTAssertEqual(Action.split.accessibilityLabel, "Split Pair - Separate cards into two hands")
        
        XCTAssertEqual(Action.hit.accessibilityHint, "Increases hand total")
        XCTAssertEqual(Action.stand.accessibilityHint, "Ends your turn")
        XCTAssertEqual(Action.double.accessibilityHint, "Doubles your bet")
        XCTAssertEqual(Action.split.accessibilityHint, "Creates two separate hands")
    }
    
    // MARK: - DealerStrength Tests
    
    func testDealerStrengthFromCard() {
        // Weak dealers
        let weak4 = DealerStrength.from(card: Card(value: 4))
        XCTAssertEqual(weak4, .weak)
        
        let weak5 = DealerStrength.from(card: Card(value: 5))
        XCTAssertEqual(weak5, .weak)
        
        let weak6 = DealerStrength.from(card: Card(value: 6))
        XCTAssertEqual(weak6, .weak)
        
        // Medium dealers
        let medium2 = DealerStrength.from(card: Card(value: 2))
        XCTAssertEqual(medium2, .medium)
        
        let medium3 = DealerStrength.from(card: Card(value: 3))
        XCTAssertEqual(medium3, .medium)
        
        let medium7 = DealerStrength.from(card: Card(value: 7))
        XCTAssertEqual(medium7, .medium)
        
        let medium8 = DealerStrength.from(card: Card(value: 8))
        XCTAssertEqual(medium8, .medium)
        
        // Strong dealers
        let strong9 = DealerStrength.from(card: Card(value: 9))
        XCTAssertEqual(strong9, .strong)
        
        let strong10 = DealerStrength.from(card: Card(value: 10))
        XCTAssertEqual(strong10, .strong)
        
        let strongAce = DealerStrength.from(card: Card(value: 11))
        XCTAssertEqual(strongAce, .strong)
    }
    
    func testDealerStrengthCards() {
        XCTAssertEqual(DealerStrength.weak.cards, [4, 5, 6])
        XCTAssertEqual(DealerStrength.medium.cards, [2, 3, 7, 8])
        XCTAssertEqual(DealerStrength.strong.cards, [9, 10, 11])
    }
    
    func testDealerStrengthDisplayNames() {
        XCTAssertEqual(DealerStrength.weak.displayName, "Weak (4,5,6)")
        XCTAssertEqual(DealerStrength.medium.displayName, "Medium (2,3,7,8)")
        XCTAssertEqual(DealerStrength.strong.displayName, "Strong (9,10,A)")
    }
    
    // MARK: - SessionType Tests
    
    func testSessionTypeDisplayNames() {
        XCTAssertEqual(SessionType.random.displayName, "Quick Practice")
        XCTAssertEqual(SessionType.dealerGroup.displayName, "Dealer Strength")
        XCTAssertEqual(SessionType.handType.displayName, "Hand Types")
        XCTAssertEqual(SessionType.absolute.displayName, "Absolutes Drill")
    }
    
    func testSessionTypeMaxQuestions() {
        XCTAssertEqual(SessionType.random.maxQuestions, 50)
        XCTAssertEqual(SessionType.dealerGroup.maxQuestions, 50)
        XCTAssertEqual(SessionType.handType.maxQuestions, 50)
        XCTAssertEqual(SessionType.absolute.maxQuestions, 20)
    }
    
    // MARK: - SessionSubtype Tests
    
    func testSessionSubtypeDisplayNames() {
        XCTAssertEqual(SessionSubtype.weak.displayName, "Weak Dealers")
        XCTAssertEqual(SessionSubtype.medium.displayName, "Medium Dealers")
        XCTAssertEqual(SessionSubtype.strong.displayName, "Strong Dealers")
        XCTAssertEqual(SessionSubtype.hard.displayName, "Hard Totals")
        XCTAssertEqual(SessionSubtype.soft.displayName, "Soft Totals")
        XCTAssertEqual(SessionSubtype.pair.displayName, "Pairs")
    }
    
    // MARK: - SessionConfiguration Tests
    
    func testSessionConfigurationInitialization() {
        let config = SessionConfiguration(sessionType: .random, subtype: nil, difficulty: .normal)
        
        XCTAssertEqual(config.sessionType, .random)
        XCTAssertNil(config.subtype)
        XCTAssertEqual(config.difficulty, .normal)
        XCTAssertEqual(config.maxQuestions, 50)
    }
    
    func testSessionConfigurationWithSubtype() {
        let config = SessionConfiguration(sessionType: .dealerGroup, subtype: .weak, difficulty: .easy)
        
        XCTAssertEqual(config.sessionType, .dealerGroup)
        XCTAssertEqual(config.subtype, .weak)
        XCTAssertEqual(config.difficulty, .easy)
        XCTAssertEqual(config.maxQuestions, 50)
    }
    
    func testSessionConfigurationAbsolute() {
        let config = SessionConfiguration(sessionType: .absolute)
        
        XCTAssertEqual(config.sessionType, .absolute)
        XCTAssertNil(config.subtype)
        XCTAssertEqual(config.difficulty, .normal)
        XCTAssertEqual(config.maxQuestions, 20) // Absolute sessions have different max
    }
    
    // MARK: - GameScenario Tests
    
    func testGameScenarioCreation() {
        let dealerCard = Card(value: 10)
        let playerCards = [Card(value: 7), Card(value: 9)]
        
        let scenario = GameScenario(
            handType: .hard,
            playerCards: playerCards,
            playerTotal: 16,
            dealerCard: dealerCard
        )
        
        XCTAssertEqual(scenario.handType, .hard)
        XCTAssertEqual(scenario.playerCards.count, 2)
        XCTAssertEqual(scenario.playerTotal, 16)
        XCTAssertEqual(scenario.dealerCard.value, 10)
    }
    
    // MARK: - HandKey Tests
    
    func testHandKeyEquality() {
        let key1 = HandKey(playerTotal: 16, dealerCard: 10)
        let key2 = HandKey(playerTotal: 16, dealerCard: 10)
        let key3 = HandKey(playerTotal: 17, dealerCard: 10)
        
        XCTAssertEqual(key1, key2)
        XCTAssertNotEqual(key1, key3)
    }
    
    func testHandKeyHashable() {
        let key1 = HandKey(playerTotal: 16, dealerCard: 10)
        let key2 = HandKey(playerTotal: 16, dealerCard: 10)
        
        var dict: [HandKey: String] = [:]
        dict[key1] = "test"
        
        XCTAssertEqual(dict[key2], "test")
    }
    
    // MARK: - Difficulty Tests
    
    func testDifficultyDisplayNames() {
        XCTAssertEqual(Difficulty.easy.displayName, "Easy")
        XCTAssertEqual(Difficulty.normal.displayName, "Normal")
        XCTAssertEqual(Difficulty.hard.displayName, "Hard")
    }
}