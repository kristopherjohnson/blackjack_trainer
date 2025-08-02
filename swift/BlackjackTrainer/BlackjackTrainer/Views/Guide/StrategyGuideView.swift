import SwiftUI

// MARK: - Strategy Guide View

public struct StrategyGuideView: View {
    @State private var selectedHandType: HandType = .hard
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                // Hand type picker with better visibility
                VStack(spacing: 4) {
                    Text("Strategy Chart")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Picker("Hand Type", selection: $selectedHandType) {
                        ForEach(HandType.allCases, id: \.self) { handType in
                            Text(handType.displayName).tag(handType)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                
                // Strategy chart
                ScrollView([.horizontal, .vertical]) {
                    strategyChart
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Strategy Chart
    
    @ViewBuilder
    private var strategyChart: some View {
        VStack(spacing: 2) {
            VStack(spacing: 1) {
                // Header row
                HStack(spacing: 1) {
                    headerCell("Player", isHeader: true)
                    ForEach(dealerCards, id: \.self) { card in
                        headerCell(card, isHeader: true)
                    }
                }
                
                // Data rows
                ForEach(playerTotals, id: \.self) { playerTotal in
                    HStack(spacing: 1) {
                        headerCell(playerTotalLabel(playerTotal), isHeader: false)
                        ForEach(Array(2...11), id: \.self) { dealerCard in
                            actionCell(playerTotal: playerTotal, dealerCard: dealerCard)
                        }
                    }
                }
            }
            .background(Color.secondary.opacity(0.2))
            .cornerRadius(6)
            
            // Legend
            legend
        }
    }
    
    // MARK: - Table Configuration
    
    private var dealerCards: [String] {
        ["2", "3", "4", "5", "6", "7", "8", "9", "10", "A"]
    }
    
    private var playerTotals: [Int] {
        switch selectedHandType {
        case .hard:
            return Array(5...21)
        case .soft:
            return [13, 14, 15, 16, 17, 18, 19, 20] // A,2 through A,9 (A,10 is blackjack, not strategy)
        case .pair:
            return [2, 3, 4, 5, 6, 7, 8, 9, 10, 11] // Individual card values for pairs (11 = A,A)
        }
    }
    
    // MARK: - Table Cells
    
    @ViewBuilder
    private func headerCell(_ text: String, isHeader: Bool) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundColor(.primary)
            .frame(minWidth: 24, maxWidth: .infinity)
            .frame(height: 24)
            .background(isHeader ? Color.secondary.opacity(0.3) : Color.secondary.opacity(0.15))
    }
    
    @ViewBuilder
    private func actionCell(playerTotal: Int, dealerCard: Int) -> some View {
        let action = getAction(playerTotal: playerTotal, dealerCard: dealerCard)
        
        Text(action.rawValue)
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
            .frame(minWidth: 24, maxWidth: .infinity)
            .frame(height: 24)
            .background(actionColor(action))
    }
    
    // MARK: - Strategy Logic
    
    private func getAction(playerTotal: Int, dealerCard: Int) -> Action {
        let strategyChart = StrategyChart()
        let scenario = createScenario(playerTotal: playerTotal, dealerCard: dealerCard)
        
        do {
            return try strategyChart.getCorrectAction(for: scenario)
        } catch {
            return .hit // Default fallback
        }
    }
    
    private func createScenario(playerTotal: Int, dealerCard: Int) -> GameScenario {
        let dealerCardObj = Card(value: dealerCard)
        let playerCards: [Card]
        
        switch selectedHandType {
        case .pair:
            playerCards = [Card(value: playerTotal), Card(value: playerTotal)]
        case .soft:
            let otherCard = playerTotal - 11
            playerCards = [Card(value: 11), Card(value: otherCard)]
        case .hard:
            if playerTotal <= 11 {
                playerCards = [Card(value: playerTotal)]
            } else {
                // Simple two-card hard total
                let firstCard = min(10, playerTotal - 2)
                let secondCard = playerTotal - firstCard
                playerCards = [Card(value: firstCard), Card(value: secondCard)]
            }
        }
        
        return GameScenario(
            handType: selectedHandType,
            playerCards: playerCards,
            playerTotal: playerTotal,
            dealerCard: dealerCardObj
        )
    }
    
    // MARK: - Display Helpers
    
    private func playerTotalLabel(_ total: Int) -> String {
        switch selectedHandType {
        case .hard:
            return String(total)
        case .soft:
            if total == 20 {
                return "A,9"
            } else {
                let otherCard = total - 11
                return "A,\(otherCard)"
            }
        case .pair:
            if total == 11 {
                return "A,A"
            } else {
                return "\(total),\(total)"
            }
        }
    }
    
    private func actionColor(_ action: Action) -> Color {
        switch action {
        case .hit:
            return .red
        case .stand:
            return .blue
        case .double:
            return .green
        case .split:
            return .orange
        }
    }
    
    // MARK: - Legend
    
    private var legend: some View {
        VStack(spacing: 2) {
            Text("Legend")
                .font(.caption.bold())
            
            HStack(spacing: 12) {
                legendItem("H", "Hit", .red)
                legendItem("S", "Stand", .blue)
                legendItem("D", "Double", .green)
                legendItem("Y", "Split", .orange)
            }
        }
        .padding(.top, 2)
    }
    
    @ViewBuilder
    private func legendItem(_ symbol: String, _ name: String, _ color: Color) -> some View {
        VStack(spacing: 2) {
            Text(symbol)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(color)
                .cornerRadius(3)
            
            Text(name)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    StrategyGuideView()
}