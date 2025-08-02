import SwiftUI

// MARK: - Main Menu View

public struct MainMenuView: View {
    @Environment(NavigationState.self) private var navigationState
    
    public init() {}
    
    public var body: some View {
        NavigationStack(path: Bindable(navigationState).path) {
            List {
                Section("Training Modes") {
                    MenuItemView(
                        title: "Quick Practice",
                        subtitle: "Mixed scenarios from all categories",
                        icon: "shuffle"
                    ) {
                        let config = SessionConfiguration(
                            sessionType: .random,
                            subtype: nil,
                            difficulty: .normal
                        )
                        navigationState.navigateToSession(config)
                    }
                    
                    MenuItemView(
                        title: "Dealer Strength Groups",
                        subtitle: "Practice by dealer weakness",
                        icon: "person.3"
                    ) {
                        navigationState.navigateToDealerGroups()
                    }
                    
                    MenuItemView(
                        title: "Hand Type Focus",
                        subtitle: "Hard totals, soft totals, or pairs",
                        icon: "hand.raised"
                    ) {
                        navigationState.navigateToHandTypes()
                    }
                    
                    MenuItemView(
                        title: "Absolutes Drill",
                        subtitle: "Never/always rules",
                        icon: "exclamationmark.triangle"
                    ) {
                        let config = SessionConfiguration(
                            sessionType: .absolute,
                            subtype: nil,
                            difficulty: .easy
                        )
                        navigationState.navigateToSession(config)
                    }
                }
                
                Section("Learn") {
                    MenuItemView(
                        title: "Strategy Guide",
                        subtitle: "Complete basic strategy reference",
                        icon: "book"
                    ) {
                        navigationState.navigateToStrategyGuide()
                    }
                }
            }
            .navigationTitle("Blackjack Trainer")
            .navigationDestination(for: NavigationDestination.self) { destination in
                destinationView(for: destination)
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .trainingSession(let config):
            TrainingSessionView(configuration: config)
        case .dealerGroupSelection:
            DealerGroupSelectionView()
        case .handTypeSelection:
            HandTypeSelectionView()
        case .statistics:
            StatisticsView()
        case .strategyGuide:
            StrategyGuideView()
        }
    }
}

// MARK: - Preview

#Preview {
    MainMenuView()
        .environment(NavigationState())
}