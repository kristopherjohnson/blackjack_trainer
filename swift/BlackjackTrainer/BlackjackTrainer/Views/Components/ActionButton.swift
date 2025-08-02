import SwiftUI

// MARK: - Action Button

struct ActionButton: View {
    let action: Action
    let isEnabled: Bool
    let onTap: (Action) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var isAnimating = false
    
    init(action: Action, isEnabled: Bool = true, onTap: @escaping (Action) -> Void) {
        self.action = action
        self.isEnabled = isEnabled
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action.displayName) {
            handleButtonTap()
        }
        .buttonStyle(ActionButtonStyle(isEnabled: isEnabled, reduceMotion: reduceMotion))
        .disabled(!isEnabled)
        .accessibilityHint(accessibilityHint)
        .scaleEffect(isAnimating ? 1.05 : 1.0)
        .animation(
            reduceMotion ? .none : .spring(response: 0.15, dampingFraction: 0.7),
            value: isAnimating
        )
    }
    
    private func handleButtonTap() {
        if !reduceMotion {
            withAnimation(.spring(response: 0.1, dampingFraction: 0.8)) {
                isAnimating = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.spring(response: 0.1, dampingFraction: 0.8)) {
                    isAnimating = false
                }
            }
        }
        
        onTap(action)
    }
    
    private var accessibilityHint: String {
        switch action {
        case .hit:
            return "Take another card"
        case .stand:
            return "Keep your current total"
        case .double:
            return "Double your bet and take exactly one more card"
        case .split:
            return "Split your pair into two separate hands"
        }
    }
}

// MARK: - Action Button Style

struct ActionButtonStyle: ButtonStyle {
    let isEnabled: Bool
    let reduceMotion: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(textColor(for: configuration))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor(for: configuration))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                Color.accentColor.opacity(0.3),
                                lineWidth: configuration.isPressed ? 2 : 1
                            )
                    )
                    .shadow(
                        color: .black.opacity(configuration.isPressed ? 0.1 : 0.2),
                        radius: configuration.isPressed ? 2 : 4,
                        y: configuration.isPressed ? 1 : 2
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(
                reduceMotion ? .none : .easeInOut(duration: 0.05),
                value: configuration.isPressed
            )
    }
    
    private func backgroundColor(for configuration: Configuration) -> Color {
        if !isEnabled {
            return Color.gray.opacity(0.3)
        }
        
        return Color.accentColor.opacity(configuration.isPressed ? 0.8 : 1.0)
    }
    
    private func textColor(for configuration: Configuration) -> Color {
        if !isEnabled {
            return Color.gray
        }
        
        return .white
    }
}

// MARK: - Action Buttons Grid

struct ActionButtonsView: View {
    let onActionSelected: (Action) -> Void
    let availableActions: [Action]
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var animateButtons = false
    
    init(onActionSelected: @escaping (Action) -> Void, availableActions: [Action] = Action.allCases) {
        self.onActionSelected = onActionSelected
        self.availableActions = availableActions
    }
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            ForEach(availableActions.indices, id: \.self) { index in
                let action = availableActions[index]
                ActionButton(action: action) { selectedAction in
                    onActionSelected(selectedAction)
                }
                .opacity(animateButtons ? 1.0 : 0.0)
                .scaleEffect(animateButtons ? 1.0 : 0.8)
                .animation(
                    reduceMotion ? .none : .spring(response: 0.2, dampingFraction: 0.8)
                        .delay(Double(index) * 0.05),
                    value: animateButtons
                )
            }
        }
        .padding(.horizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Action buttons")
        .onAppear {
            withAnimation {
                animateButtons = true
            }
        }
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
            ActionButton(action: .hit) { _ in print("Hit") }
            ActionButton(action: .stand, isEnabled: false) { _ in print("Stand") }
        }
        .padding()
    }
}