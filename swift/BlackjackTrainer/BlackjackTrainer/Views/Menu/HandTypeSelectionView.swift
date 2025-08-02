import SwiftUI

// MARK: - Hand Type Selection View

struct HandTypeSelectionView: View {
    @Environment(NavigationState.self) private var navigationState
    
    var body: some View {
        List {
            Section {
                ForEach([SessionSubtype.hard, .soft, .pair], id: \.self) { subtype in
                    MenuItemView(
                        title: subtypeTitle(subtype),
                        subtitle: subtypeSubtitle(subtype),
                        icon: subtypeIcon(subtype)
                    ) {
                        let config = SessionConfiguration(sessionType: .handType, subtype: subtype)
                        navigationState.navigateToSession(config)
                    }
                }
            } header: {
                Text("Practice by Hand Type")
            }
        }
        .navigationTitle("Hand Types")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
    
    private func subtypeTitle(_ subtype: SessionSubtype) -> String {
        switch subtype {
        case .hard: return "Hard Totals"
        case .soft: return "Soft Totals"
        case .pair: return "Pairs"
        default: return ""
        }
    }
    
    private func subtypeSubtitle(_ subtype: SessionSubtype) -> String {
        switch subtype {
        case .hard: return "No aces or ace counts as 1"
        case .soft: return "Hands with ace counting as 11"
        case .pair: return "Identical cards - split decisions"
        default: return ""
        }
    }
    
    private func subtypeIcon(_ subtype: SessionSubtype) -> String {
        switch subtype {
        case .hard: return "number"
        case .soft: return "a.circle"
        case .pair: return "rectangle.split.2x1"
        default: return "number"
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HandTypeSelectionView()
            .environment(NavigationState())
    }
}