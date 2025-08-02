import SwiftUI

// MARK: - Strategy Guide View

public struct StrategyGuideView: View {
    @State private var selectedHandType: HandType = .hard
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Hand type picker
                Picker("Hand Type", selection: $selectedHandType) {
                    ForEach(HandType.allCases, id: \.self) { handType in
                        Text(handType.displayName).tag(handType)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Strategy chart
                ScrollView([.horizontal, .vertical]) {
                    strategyChart
                        .padding()
                }
            }
            .navigationTitle("Strategy Guide")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
    
    // MARK: - Strategy Chart
    
    @ViewBuilder
    private var strategyChart: some View {
        VStack(spacing: 12) {
            Text("\(selectedHandType.displayName) Strategy")
                .font(.headline)
                .padding(.bottom, 8)
            
            LazyVGrid(columns: gridColumns, spacing: 1) {
                // Header row
                headerRow
                
                // Data rows
                ForEach(playerTotals, id: \.self) { playerTotal in
                    dataRow(for: playerTotal)
                }
            }
            .background(Color.secondary.opacity(0.2))
            .cornerRadius(8)
            
            // Legend
            legend
        }
    }
    
    // MARK: - Grid Configuration
    
    private var gridColumns: [GridItem] {
        // Player total column + dealer card columns (2-A)
        Array(repeating: GridItem(.flexible(), spacing: 1), count: 11)
    }
    
    private var dealerCards: [String] {
        ["2", "3", "4", "5", "6", "7", "8", "9", "10", "A"]
    }
    
    private var playerTotals: [Int] {
        switch selectedHandType {
        case .hard:
            return Array(5...21)
        case .soft:
            return Array(13...21)
        case .pair:
            return [2, 3, 4, 5, 6, 7, 8, 9, 10, 11] // Ace = 11
        }
    }
    
    // MARK: - Grid Rows
    
    @ViewBuilder
    private var headerRow: some View {
        // Player total header
        Text("Player")
            .font(.caption.bold())
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 30)
            .background(Color.secondary.opacity(0.1))
        
        // Dealer card headers
        ForEach(dealerCards, id: \.self) { card in
            Text(card)
                .font(.caption.bold())
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 30)
                .background(Color.secondary.opacity(0.1))
        }
    }
    
    @ViewBuilder
    private func dataRow(for playerTotal: Int) -> some View {
        // Player total cell
        Text(playerTotalLabel(playerTotal))
            .font(.caption.bold())
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 30)
            .background(Color.secondary.opacity(0.1))
        
        // Action cells
        ForEach(Array(2...11), id: \.self) { dealerCard in
            actionCell(playerTotal: playerTotal, dealerCard: dealerCard)
        }
    }
    
    @ViewBuilder
    private func actionCell(playerTotal: Int, dealerCard: Int) -> some View {
        let action = getAction(playerTotal: playerTotal, dealerCard: dealerCard)
        
        Text(action.rawValue)
            .font(.caption.bold())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 30)
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
            if total == 21 {
                return "A,10"
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
        VStack(spacing: 8) {
            Text("Legend")
                .font(.headline)
                .padding(.top)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                legendItem("H", "Hit", .red)
                legendItem("S", "Stand", .blue)
                legendItem("D", "Double", .green)
                legendItem("Y", "Split", .orange)
            }
        }
        .padding(.top)
    }
    
    @ViewBuilder
    private func legendItem(_ symbol: String, _ name: String, _ color: Color) -> some View {
        HStack(spacing: 8) {
            Text(symbol)
                .font(.caption.bold())
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(color)
                .cornerRadius(4)
            
            Text(name)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Preview

#Preview {
    StrategyGuideView()
}