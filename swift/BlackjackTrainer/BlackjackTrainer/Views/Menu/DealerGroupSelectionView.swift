import SwiftUI

// MARK: - Dealer Group Selection View

struct DealerGroupSelectionView: View {
    @Environment(NavigationState.self) private var navigationState
    
    var body: some View {
        List {
            Section {
                ForEach([SessionSubtype.weak, .medium, .strong], id: \.self) { subtype in
                    MenuItemView(
                        title: subtypeTitle(subtype),
                        subtitle: subtypeSubtitle(subtype),
                        icon: subtypeIcon(subtype)
                    ) {
                        let config = SessionConfiguration(sessionType: .dealerGroup, subtype: subtype)
                        navigationState.navigateToSession(config)
                    }
                }
            } header: {
                Text("Practice by Dealer Strength")
            }
        }
        .navigationTitle("Dealer Strength")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
    
    private func subtypeTitle(_ subtype: SessionSubtype) -> String {
        switch subtype {
        case .weak: return "Weak Cards (4, 5, 6)"
        case .medium: return "Medium Cards (2, 3, 7, 8)"
        case .strong: return "Strong Cards (9, 10, A)"
        default: return ""
        }
    }
    
    private func subtypeSubtitle(_ subtype: SessionSubtype) -> String {
        switch subtype {
        case .weak: return "Dealer bust cards - be aggressive"
        case .medium: return "Moderate dealer strength"
        case .strong: return "Dealer strength - play conservative"
        default: return ""
        }
    }
    
    private func subtypeIcon(_ subtype: SessionSubtype) -> String {
        switch subtype {
        case .weak: return "hand.thumbsdown"
        case .medium: return "hand.raised"
        case .strong: return "hand.thumbsup"
        default: return "hand.raised"
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DealerGroupSelectionView()
            .environment(NavigationState())
    }
}