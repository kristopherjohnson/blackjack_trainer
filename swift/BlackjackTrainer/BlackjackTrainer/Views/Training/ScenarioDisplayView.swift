import SwiftUI

// MARK: - Scenario Display View

struct ScenarioDisplayView: View {
    let scenario: GameScenario
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        VStack(spacing: 30) {
            // Dealer card section
            VStack(spacing: 12) {
                Text("Dealer Shows")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                CardView(card: scenario.dealerCard)
                    .accessibilityLabel("Dealer card is \(scenario.dealerCard.displayValue)")
                    .scaleEffect(1.0)
                    .animation(
                        reduceMotion ? .none : .spring(response: 0.4, dampingFraction: 0.8),
                        value: scenario.dealerCard.id
                    )
            }
            
            // Player cards section
            VStack(spacing: 16) {
                Text("Your Hand")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    ForEach(scenario.playerCards.indices, id: \.self) { index in
                        let card = scenario.playerCards[index]
                        CardView(card: card)
                            .scaleEffect(1.0)
                            .animation(
                                reduceMotion ? .none : .spring(response: 0.4, dampingFraction: 0.8)
                                    .delay(Double(index) * 0.1),
                                value: card.id
                            )
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Your cards total \(scenario.playerTotal)")
                
                handDescriptionView
                    .animation(
                        reduceMotion ? .none : .easeInOut(duration: 0.3),
                        value: scenario.id
                    )
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
                .transition(.scale.combined(with: .opacity))
            
            if scenario.handType == .pair {
                Text("Pair of \(scenario.playerCards.first?.displayValue ?? "?")'s")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else if scenario.handType == .soft {
                Text("Soft total (Ace as 11)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
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