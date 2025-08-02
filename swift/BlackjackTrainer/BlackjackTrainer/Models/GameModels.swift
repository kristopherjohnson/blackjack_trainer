import Foundation

// MARK: - Core Game Models

/// Represents a playing card
struct Card: Codable, Identifiable, Hashable {
    let id = UUID()
    let value: Int // 2-11 (11 for Ace)
    
    var displayValue: String {
        switch value {
        case 11: return "A"
        case 10: return "10"
        default: return String(value)
        }
    }
    
    var isAce: Bool { value == 11 }
}

/// Types of blackjack hands
enum HandType: String, CaseIterable, Codable {
    case hard, soft, pair
    
    var displayName: String {
        switch self {
        case .hard: return "Hard Total"
        case .soft: return "Soft Total"
        case .pair: return "Pair"
        }
    }
}

/// Possible player actions
enum Action: String, CaseIterable, Codable {
    case hit = "H"
    case stand = "S"
    case double = "D"
    case split = "Y"
    
    var displayName: String {
        switch self {
        case .hit: return "Hit"
        case .stand: return "Stand"
        case .double: return "Double"
        case .split: return "Split"
        }
    }
}

/// Dealer card strength categories
enum DealerStrength: String, CaseIterable, Codable {
    case weak, medium, strong
    
    var cards: [Int] {
        switch self {
        case .weak: return [4, 5, 6]
        case .medium: return [2, 3, 7, 8]
        case .strong: return [9, 10, 11]
        }
    }
    
    static func from(card: Card) -> DealerStrength {
        let value = card.value
        if [4, 5, 6].contains(value) {
            return .weak
        } else if [2, 3, 7, 8].contains(value) {
            return .medium
        } else {
            return .strong
        }
    }
}

/// Game scenario for training
struct GameScenario: Identifiable, Codable {
    let id = UUID()
    let handType: HandType
    let playerCards: [Card]
    let playerTotal: Int
    let dealerCard: Card
    
    init(handType: HandType, playerCards: [Card], playerTotal: Int, dealerCard: Card) {
        self.handType = handType
        self.playerCards = playerCards
        self.playerTotal = playerTotal
        self.dealerCard = dealerCard
    }
}



/// Training session types
enum SessionType: String, CaseIterable, Codable {
    case random, dealerGroup, handType, absolute
    
    var displayName: String {
        switch self {
        case .random: return "Quick Practice"
        case .dealerGroup: return "Dealer Strength"
        case .handType: return "Hand Types"
        case .absolute: return "Absolutes Drill"
        }
    }
    
    var maxQuestions: Int {
        switch self {
        case .absolute: return 20
        default: return 50
        }
    }
}

/// Session subtypes for specific training modes
enum SessionSubtype: String, CaseIterable, Codable {
    case weak, medium, strong  // For dealer groups
    case hard, soft, pair      // For hand types
    
    var displayName: String {
        switch self {
        case .weak: return "Weak Dealers"
        case .medium: return "Medium Dealers"
        case .strong: return "Strong Dealers"
        case .hard: return "Hard Totals"
        case .soft: return "Soft Totals"
        case .pair: return "Pairs"
        }
    }
}

/// Configuration for a training session
struct SessionConfiguration: Hashable, Codable {
    let sessionType: SessionType
    let subtype: SessionSubtype?
    let maxQuestions: Int
    
    init(sessionType: SessionType, subtype: SessionSubtype? = nil) {
        self.sessionType = sessionType
        self.subtype = subtype
        self.maxQuestions = sessionType.maxQuestions
    }
}