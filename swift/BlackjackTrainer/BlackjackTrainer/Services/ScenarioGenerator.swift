import Foundation

// MARK: - Scenario Generator

@MainActor
class ScenarioGenerator: ObservableObject {
    private let strategyChart: StrategyChart
    
    nonisolated init(strategyChart: StrategyChart = StrategyChart()) {
        self.strategyChart = strategyChart
    }
    
    // MARK: - Scenario Generation Methods
    
    func generateScenario(for configuration: SessionConfiguration) -> GameScenario? {
        switch configuration.sessionType {
        case .random:
            return generateRandomScenario()
        case .dealerGroup:
            guard let subtype = configuration.subtype else { return nil }
            return generateDealerGroupScenario(strength: dealerStrengthFromSubtype(subtype))
        case .handType:
            guard let subtype = configuration.subtype else { return nil }
            return generateHandTypeScenario(handType: handTypeFromSubtype(subtype))
        case .absolute:
            return generateAbsoluteScenario()
        }
    }
    
    private func generateRandomScenario() -> GameScenario {
        let dealerCard = Card(value: Int.random(in: 2...11))
        let handType = HandType.allCases.randomElement()!
        
        switch handType {
        case .pair:
            let pairValue = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11].randomElement()!
            let playerCards = [Card(value: pairValue), Card(value: pairValue)]
            return GameScenario(handType: .pair, playerCards: playerCards, playerTotal: pairValue, dealerCard: dealerCard)
            
        case .soft:
            let otherCard = Int.random(in: 2...9)
            let playerCards = [Card(value: 11), Card(value: otherCard)]
            return GameScenario(handType: .soft, playerCards: playerCards, playerTotal: 11 + otherCard, dealerCard: dealerCard)
            
        case .hard:
            let playerTotal = Int.random(in: 5...20)
            let playerCards = generateHardHandCards(total: playerTotal)
            return GameScenario(handType: .hard, playerCards: playerCards, playerTotal: playerTotal, dealerCard: dealerCard)
        }
    }
    
    private func generateDealerGroupScenario(strength: DealerStrength) -> GameScenario {
        let dealerCard = Card(value: strength.cards.randomElement()!)
        let handType = HandType.allCases.randomElement()!
        
        switch handType {
        case .pair:
            let pairValue = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11].randomElement()!
            let playerCards = [Card(value: pairValue), Card(value: pairValue)]
            return GameScenario(handType: .pair, playerCards: playerCards, playerTotal: pairValue, dealerCard: dealerCard)
            
        case .soft:
            let otherCard = Int.random(in: 2...9)
            let playerCards = [Card(value: 11), Card(value: otherCard)]
            return GameScenario(handType: .soft, playerCards: playerCards, playerTotal: 11 + otherCard, dealerCard: dealerCard)
            
        case .hard:
            let playerTotal = Int.random(in: 5...20)
            let playerCards = generateHardHandCards(total: playerTotal)
            return GameScenario(handType: .hard, playerCards: playerCards, playerTotal: playerTotal, dealerCard: dealerCard)
        }
    }
    
    private func generateHandTypeScenario(handType: HandType) -> GameScenario {
        let dealerCard = Card(value: Int.random(in: 2...11))
        
        switch handType {
        case .pair:
            let pairValue = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11].randomElement()!
            let playerCards = [Card(value: pairValue), Card(value: pairValue)]
            return GameScenario(handType: .pair, playerCards: playerCards, playerTotal: pairValue, dealerCard: dealerCard)
            
        case .soft:
            let otherCard = Int.random(in: 2...9)
            let playerCards = [Card(value: 11), Card(value: otherCard)]
            return GameScenario(handType: .soft, playerCards: playerCards, playerTotal: 11 + otherCard, dealerCard: dealerCard)
            
        case .hard:
            let playerTotal = Int.random(in: 5...20)
            let playerCards = generateHardHandCards(total: playerTotal)
            return GameScenario(handType: .hard, playerCards: playerCards, playerTotal: playerTotal, dealerCard: dealerCard)
        }
    }
    
    private func generateAbsoluteScenario() -> GameScenario {
        let dealerCard = Card(value: Int.random(in: 2...11))
        
        let absoluteScenarios: [(HandType, [Card], Int)] = [
            (.pair, [Card(value: 11), Card(value: 11)], 11),  // A,A
            (.pair, [Card(value: 8), Card(value: 8)], 8),     // 8,8
            (.pair, [Card(value: 10), Card(value: 10)], 10),  // 10,10
            (.pair, [Card(value: 5), Card(value: 5)], 5),     // 5,5
            (.hard, generateHardHandCards(total: 17), 17),    // Hard 17
            (.hard, generateHardHandCards(total: 18), 18),    // Hard 18
            (.hard, generateHardHandCards(total: 19), 19),    // Hard 19
            (.hard, generateHardHandCards(total: 20), 20),    // Hard 20
            (.soft, [Card(value: 11), Card(value: 8)], 19),   // Soft 19
            (.soft, [Card(value: 11), Card(value: 9)], 20),   // Soft 20
        ]
        
        let (handType, playerCards, playerTotal) = absoluteScenarios.randomElement()!
        return GameScenario(handType: handType, playerCards: playerCards, playerTotal: playerTotal, dealerCard: dealerCard)
    }
    
    // MARK: - Helper Methods
    
    private func generateHardHandCards(total: Int) -> [Card] {
        guard total >= 2 else { return [Card(value: 2)] }
        
        if total <= 11 {
            return [Card(value: total)]
        }
        
        // Generate two cards for totals 12-20
        let firstCard = Int.random(in: 2...min(10, total - 2))
        let secondCard = total - firstCard
        
        if secondCard > 10 || secondCard < 2 {
            // If we can't make it with two cards, use more cards
            var cards: [Card] = [Card(value: firstCard)]
            var remaining = total - firstCard
            
            while remaining > 10 {
                let cardValue = Int.random(in: 2...min(10, remaining - 2))
                cards.append(Card(value: cardValue))
                remaining -= cardValue
            }
            
            if remaining >= 2 {
                cards.append(Card(value: remaining))
            }
            
            return cards
        }
        
        return [Card(value: firstCard), Card(value: secondCard)]
    }
    
    private func dealerStrengthFromSubtype(_ subtype: SessionSubtype) -> DealerStrength {
        switch subtype {
        case .weak: return .weak
        case .medium: return .medium
        case .strong: return .strong
        default: return .medium
        }
    }
    
    private func handTypeFromSubtype(_ subtype: SessionSubtype) -> HandType {
        switch subtype {
        case .hard: return .hard
        case .soft: return .soft
        case .pair: return .pair
        default: return .hard
        }
    }
}