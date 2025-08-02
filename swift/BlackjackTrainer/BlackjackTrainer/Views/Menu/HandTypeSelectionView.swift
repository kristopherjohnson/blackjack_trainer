import SwiftUI

// MARK: - Hand Type Selection View

struct HandTypeSelectionView: View {
    @Environment(NavigationState.self) private var navigationState
    
    var body: some View {
        List {
            Section {
                MenuItemView(
                    title: "Hard Totals",
                    subtitle: "No aces or ace counts as 1",
                    icon: "number"
                ) {
                    let config = SessionConfiguration(
                        sessionType: .handType,
                        subtype: .hard,
                        difficulty: .normal
                    )
                    navigationState.navigateToSession(config)
                }
                
                MenuItemView(
                    title: "Soft Totals",
                    subtitle: "Hands with ace counting as 11",
                    icon: "a.circle"
                ) {
                    let config = SessionConfiguration(
                        sessionType: .handType,
                        subtype: .soft,
                        difficulty: .normal
                    )
                    navigationState.navigateToSession(config)
                }
                
                MenuItemView(
                    title: "Pairs",
                    subtitle: "Identical cards - split decisions",
                    icon: "rectangle.split.2x1"
                ) {
                    let config = SessionConfiguration(
                        sessionType: .handType,
                        subtype: .pair,
                        difficulty: .normal
                    )
                    navigationState.navigateToSession(config)
                }
            } header: {
                Text("Practice by Hand Type")
            } footer: {
                Text("Focus on specific hand categories to master the unique strategic patterns for each type. Hard totals emphasize basic hitting and standing, soft totals focus on doubling opportunities, and pairs require split timing decisions.")
            }
        }
        .navigationTitle("Hand Types")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HandTypeSelectionView()
            .environment(NavigationState())
    }
}