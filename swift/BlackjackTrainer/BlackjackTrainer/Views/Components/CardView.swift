import SwiftUI

// MARK: - Card View

struct CardView: View {
    let card: Card
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(cardBackground)
            .frame(width: 60, height: 84)
            .overlay(
                VStack(spacing: 4) {
                    Text(card.displayValue)
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    if card.isFaceCard {
                        Image(systemName: card.faceCardIcon)
                            .foregroundColor(.primary)
                            .font(.caption)
                    }
                }
            )
            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            .accessibilityLabel(card.accessibilityDescription)
    }
    
    private var cardBackground: Color {
        colorScheme == .dark ? Color.secondary.opacity(0.1) : .white
    }
}

// MARK: - Card Extensions

private extension Card {
    var faceCardIcon: String {
        switch displayValue {
        case "J": return "person.crop.circle"
        case "Q": return "crown"
        case "K": return "crown.fill"
        default: return "crown.fill"
        }
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 12) {
        CardView(card: Card(value: 11))
        CardView(card: Card(value: 10))
        CardView(card: Card(value: 7))
    }
    .padding()
}