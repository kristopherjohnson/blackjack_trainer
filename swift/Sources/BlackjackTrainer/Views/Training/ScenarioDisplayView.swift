import SwiftUI

// MARK: - Scenario Display View

struct ScenarioDisplayView: View {
    let scenario: GameScenario
    
    var body: some View {
        VStack(spacing: 30) {
            // Dealer card section
            VStack(spacing: 12) {
                Text("Dealer Shows")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                CardView(card: scenario.dealerCard)
                    .accessibilityLabel("Dealer card is \(scenario.dealerCard.accessibilityDescription)")
            }
            
            // Player cards section
            VStack(spacing: 16) {
                Text("Your Hand")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    ForEach(scenario.playerCards, id: \.id) { card in
                        CardView(card: card)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Your cards total \(scenario.playerTotal)")
                
                handDescriptionView
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Practice scenario: Your \(scenario.handType.displayName) \(scenario.playerTotal) versus dealer \(scenario.dealerCard.displayValue)")
    }
    
    private var handDescriptionView: some View {
        VStack(spacing: 8) {
            Text("\(scenario.handType.displayName) \(scenario.playerTotal)")
                .font(.title2.bold())
                .foregroundColor(.primary)
            
            if scenario.handType == .pair {
                Text("Pair of \(scenario.playerCards.first?.displayValue ?? "?")'s")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else if scenario.handType == .soft {
                Text("Soft total (Ace as 11)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        // Hard total example
        ScenarioDisplayView(
            scenario: GameScenario(
                handType: .hard,
                playerCards: [Card(value: 7), Card(value: 9)],
                playerTotal: 16,
                dealerCard: Card(value: 10)
            )
        )
        
        // Soft total example
        ScenarioDisplayView(
            scenario: GameScenario(
                handType: .soft,
                playerCards: [Card(value: 11), Card(value: 6)],
                playerTotal: 17,
                dealerCard: Card(value: 3)
            )
        )
        
        // Pair example
        ScenarioDisplayView(
            scenario: GameScenario(
                handType: .pair,
                playerCards: [Card(value: 8), Card(value: 8)],
                playerTotal: 8,
                dealerCard: Card(value: 5)
            )
        )
    }
    .padding()
}