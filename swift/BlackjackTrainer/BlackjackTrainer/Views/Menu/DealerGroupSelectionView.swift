import SwiftUI

// MARK: - Dealer Group Selection View

struct DealerGroupSelectionView: View {
    @Environment(NavigationState.self) private var navigationState
    
    var body: some View {
        List {
            Section {
                MenuItemView(
                    title: "Weak Cards (4, 5, 6)",
                    subtitle: "Dealer bust cards - be aggressive",
                    icon: "hand.thumbsdown"
                ) {
                    let config = SessionConfiguration(
                        sessionType: .dealerGroup,
                        subtype: .weak,
                        difficulty: .normal
                    )
                    navigationState.navigateToSession(config)
                }
                
                MenuItemView(
                    title: "Medium Cards (2, 3, 7, 8)",
                    subtitle: "Moderate dealer strength",
                    icon: "hand.raised"
                ) {
                    let config = SessionConfiguration(
                        sessionType: .dealerGroup,
                        subtype: .medium,
                        difficulty: .normal
                    )
                    navigationState.navigateToSession(config)
                }
                
                MenuItemView(
                    title: "Strong Cards (9, 10, A)",
                    subtitle: "Dealer strength - play conservative",
                    icon: "hand.thumbsup"
                ) {
                    let config = SessionConfiguration(
                        sessionType: .dealerGroup,
                        subtype: .strong,
                        difficulty: .normal
                    )
                    navigationState.navigateToSession(config)
                }
            } header: {
                Text("Practice by Dealer Strength")
            } footer: {
                Text("Each dealer card strength requires different strategic approaches. Weak dealer cards favor aggressive play, while strong dealer cards require conservative decisions.")
            }
        }
        .navigationTitle("Dealer Strength")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DealerGroupSelectionView()
            .environment(NavigationState())
    }
}