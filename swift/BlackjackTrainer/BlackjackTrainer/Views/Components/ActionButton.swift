import SwiftUI

// MARK: - Action Button

struct ActionButton: View {
    let action: Action
    let isEnabled: Bool
    let onTap: (Action) -> Void
    
    init(action: Action, isEnabled: Bool = true, onTap: @escaping (Action) -> Void) {
        self.action = action
        self.isEnabled = isEnabled
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action.displayName) {
            onTap(action)
        }
        .buttonStyle(ActionButtonStyle(isEnabled: isEnabled))
        .disabled(!isEnabled)
    }
}

// MARK: - Action Button Style

struct ActionButtonStyle: ButtonStyle {
    let isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor(for: configuration))
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
    
    private func backgroundColor(for configuration: Configuration) -> Color {
        if !isEnabled {
            return Color.gray.opacity(0.3)
        }
        
        return Color.accentColor.opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

// MARK: - Action Buttons Grid

struct ActionButtonsView: View {
    let onActionSelected: (Action) -> Void
    let availableActions: [Action]
    
    init(onActionSelected: @escaping (Action) -> Void, availableActions: [Action] = Action.allCases) {
        self.onActionSelected = onActionSelected
        self.availableActions = availableActions
    }
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            ForEach(availableActions, id: \.self) { action in
                ActionButton(action: action) { selectedAction in
                    onActionSelected(selectedAction)
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        ActionButtonsView { action in
            print("Selected: \(action)")
        }
        
        Spacer()
        
        // Individual button examples
        VStack(spacing: 12) {
            ActionButton(action: .hit) { _ in }
            ActionButton(action: .stand, isEnabled: false) { _ in }
        }
        .padding()
    }
}