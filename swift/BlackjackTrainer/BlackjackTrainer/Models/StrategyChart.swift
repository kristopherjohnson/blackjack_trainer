import Foundation



// MARK: - Strategy Chart Implementation

struct StrategyChart: Codable {
    private let hardTotals: [String: Action]
    private let softTotals: [String: Action]
    private let pairs: [String: Action]
    private let mnemonics: [String: String]
    
    init() {
        self.hardTotals = Self.buildHardTotals()
        self.softTotals = Self.buildSoftTotals()
        self.pairs = Self.buildPairs()
        self.mnemonics = Self.buildMnemonics()
    }
    
    // MARK: - Strategy Chart Data Construction
    
    private static func buildHardTotals() -> [String: Action] {
        var chart: [String: Action] = [:]
        
        // Hard 5-8: Always hit
        for total in 5...8 {
            for dealer in 2...11 {
                chart["\(total)-\(dealer)"] = .hit
            }
        }
        
        // Hard 9: Double vs 3-6, otherwise hit
        for dealer in 2...11 {
            let action: Action = (3...6).contains(dealer) ? .double : .hit
            chart["9-\(dealer)"] = action
        }
        
        // Hard 10: Double vs 2-9, otherwise hit
        for dealer in 2...11 {
            let action: Action = (2...9).contains(dealer) ? .double : .hit
            chart["10-\(dealer)"] = action
        }
        
        // Hard 11: Double vs 2-10, hit vs Ace
        for dealer in 2...11 {
            let action: Action = dealer <= 10 ? .double : .hit
            chart["11-\(dealer)"] = action
        }
        
        // Hard 12: Stand vs 4-6, otherwise hit
        for dealer in 2...11 {
            let action: Action = (4...6).contains(dealer) ? .stand : .hit
            chart["12-\(dealer)"] = action
        }
        
        // Hard 13-16: Stand vs 2-6, otherwise hit
        for total in 13...16 {
            for dealer in 2...11 {
                let action: Action = (2...6).contains(dealer) ? .stand : .hit
                chart["\(total)-\(dealer)"] = action
            }
        }
        
        // Hard 17+: Always stand
        for total in 17...21 {
            for dealer in 2...11 {
                chart["\(total)-\(dealer)"] = .stand
            }
        }
        
        return chart
    }
    
    private static func buildSoftTotals() -> [String: Action] {
        var chart: [String: Action] = [:]
        
        // Soft 13-14 (A,2-A,3): Double vs 5-6, otherwise hit
        for total in [13, 14] {
            for dealer in 2...11 {
                let action: Action = (5...6).contains(dealer) ? .double : .hit
                chart["\(total)-\(dealer)"] = action
            }
        }
        
        // Soft 15-16 (A,4-A,5): Double vs 4-6, otherwise hit
        for total in [15, 16] {
            for dealer in 2...11 {
                let action: Action = (4...6).contains(dealer) ? .double : .hit
                chart["\(total)-\(dealer)"] = action
            }
        }
        
        // Soft 17 (A,6): Double vs 3-6, otherwise hit
        for dealer in 2...11 {
            let action: Action = (3...6).contains(dealer) ? .double : .hit
            chart["17-\(dealer)"] = action
        }
        
        // Soft 18 (A,7): Stand vs 2,7,8; Double vs 3-6; Hit vs 9,10,A
        for dealer in 2...11 {
            let action: Action
            if [2, 7, 8].contains(dealer) {
                action = .stand
            } else if (3...6).contains(dealer) {
                action = .double
            } else {
                action = .hit
            }
            chart["18-\(dealer)"] = action
        }
        
        // Soft 19-21: Always stand
        for total in 19...21 {
            for dealer in 2...11 {
                chart["\(total)-\(dealer)"] = .stand
            }
        }
        
        return chart
    }
    
    private static func buildPairs() -> [String: Action] {
        var chart: [String: Action] = [:]
        
        // A,A: Always split
        for dealer in 2...11 {
            chart["11-\(dealer)"] = .split
        }
        
        // 2,2 and 3,3: Split vs 2-7, otherwise hit
        for pairValue in [2, 3] {
            for dealer in 2...11 {
                let action: Action = (2...7).contains(dealer) ? .split : .hit
                chart["\(pairValue)-\(dealer)"] = action
            }
        }
        
        // 4,4: Split vs 5-6, otherwise hit
        for dealer in 2...11 {
            let action: Action = (5...6).contains(dealer) ? .split : .hit
            chart["4-\(dealer)"] = action
        }
        
        // 5,5: Never split, treat as hard 10
        for dealer in 2...11 {
            let action: Action = (2...9).contains(dealer) ? .double : .hit
            chart["5-\(dealer)"] = action
        }
        
        // 6,6: Split vs 2-6, otherwise hit
        for dealer in 2...11 {
            let action: Action = (2...6).contains(dealer) ? .split : .hit
            chart["6-\(dealer)"] = action
        }
        
        // 7,7: Split vs 2-7, otherwise hit
        for dealer in 2...11 {
            let action: Action = (2...7).contains(dealer) ? .split : .hit
            chart["7-\(dealer)"] = action
        }
        
        // 8,8: Always split
        for dealer in 2...11 {
            chart["8-\(dealer)"] = .split
        }
        
        // 9,9: Split vs 2-9 except 7, stand vs 7,10,A
        for dealer in 2...11 {
            let action: Action
            if [7, 10, 11].contains(dealer) {
                action = .stand
            } else {
                action = .split
            }
            chart["9-\(dealer)"] = action
        }
        
        // 10,10: Never split, always stand
        for dealer in 2...11 {
            chart["10-\(dealer)"] = .stand
        }
        
        return chart
    }
    
    private static func buildMnemonics() -> [String: String] {
        return [
            "dealer_weak": "Dealer bust cards (4,5,6) = player gets greedy",
            "always_split": "Aces and eights, don't hesitate",
            "never_split": "Tens and fives, keep them alive",
            "teens_vs_strong": "Teens stay vs weak, flee from strong",
            "soft_17": "A,7 is the tricky soft hand",
            "hard_12": "12 is the exception - only stand vs 4,5,6",
            "doubles": "Double when dealer is weak and you can improve"
        ]
    }
    
    // MARK: - Strategy Chart Interface
    
    func getCorrectAction(for scenario: GameScenario) -> Action {
        let key = "\(scenario.playerTotal)-\(scenario.dealerCard.value)"
        
        switch scenario.handType {
        case .hard:
            return hardTotals[key] ?? .hit
        case .soft:
            return softTotals[key] ?? .hit
        case .pair:
            return pairs[key] ?? .hit
        }
    }
    
    func getExplanation(for scenario: GameScenario) -> String {
        // Check for specific scenario explanations
        let specificExplanations: [(HandType, Int) -> String?] = [
            { handType, playerTotal in
                if handType == .pair && playerTotal == 11 { return mnemonics["always_split"] }
                return nil
            },
            { handType, playerTotal in
                if handType == .pair && playerTotal == 8 { return mnemonics["always_split"] }
                return nil
            },
            { handType, playerTotal in
                if handType == .pair && [10, 5].contains(playerTotal) { return mnemonics["never_split"] }
                return nil
            },
            { handType, playerTotal in
                if handType == .soft && playerTotal == 18 { return mnemonics["soft_17"] }
                return nil
            },
            { handType, playerTotal in
                if handType == .hard && playerTotal == 12 { return mnemonics["hard_12"] }
                return nil
            }
        ]
        
        for explanation in specificExplanations {
            if let result = explanation(scenario.handType, scenario.playerTotal) {
                return result
            }
        }
        
        // Check dealer strength patterns
        let dealerStrength = DealerStrength.from(card: scenario.dealerCard)
        if dealerStrength == .weak {
            return mnemonics["dealer_weak"] ?? "Follow basic strategy patterns"
        }
        
        if scenario.handType == .hard && (13...16).contains(scenario.playerTotal) && dealerStrength == .strong {
            return mnemonics["teens_vs_strong"] ?? "Follow basic strategy patterns"
        }
        
        return "Follow basic strategy patterns"
    }
    
    func isAbsoluteRule(for scenario: GameScenario) -> Bool {
        let absolutes: [(HandType, Int)] = [
            (.pair, 11),  // Always split A,A
            (.pair, 8),   // Always split 8,8
            (.pair, 10),  // Never split 10,10
            (.pair, 5),   // Never split 5,5
        ]
        
        // Check for specific absolute rules
        if absolutes.contains(where: { $0.0 == scenario.handType && $0.1 == scenario.playerTotal }) {
            return true
        }
        
        // Hard 17+ always stand
        if scenario.handType == .hard && scenario.playerTotal >= 17 {
            return true
        }
        
        // Soft 19+ always stand
        if scenario.handType == .soft && scenario.playerTotal >= 19 {
            return true
        }
        
        return false
    }
}