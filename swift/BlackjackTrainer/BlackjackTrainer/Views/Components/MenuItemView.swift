import SwiftUI

// MARK: - Menu Item View

struct MenuItemView: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                    .frame(width: 30, height: 30)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(title). \(subtitle)")
        .accessibilityHint("Tap to start this training mode")
    }
}

// MARK: - Preview

#Preview {
    List {
        Section("Training Modes") {
            MenuItemView(
                title: "Quick Practice",
                subtitle: "Mixed scenarios from all categories",
                icon: "shuffle"
            ) {
                print("Quick Practice selected")
            }
            
            MenuItemView(
                title: "Dealer Strength Groups",
                subtitle: "Practice by dealer weakness",
                icon: "person.3"
            ) {
                print("Dealer Groups selected")
            }
            
            MenuItemView(
                title: "Hand Type Focus",
                subtitle: "Hard totals, soft totals, or pairs",
                icon: "hand.raised"
            ) {
                print("Hand Types selected")
            }
        }
    }
}