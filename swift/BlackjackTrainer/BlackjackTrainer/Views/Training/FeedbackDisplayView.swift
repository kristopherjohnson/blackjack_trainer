import SwiftUI

// MARK: - Feedback Display View

struct FeedbackDisplayView: View {
    let feedback: FeedbackResult
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var animateElements = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Result indicator with staggered animation
            resultHeader
                .opacity(animateElements ? 1.0 : 0.0)
                .scaleEffect(animateElements ? 1.0 : 0.8)
                .animation(
                    reduceMotion ? .none : .spring(response: 0.6, dampingFraction: 0.7),
                    value: animateElements
                )
            
            // Scenario summary
            scenarioSummary
                .opacity(animateElements ? 1.0 : 0.0)
                .offset(y: animateElements ? 0 : 20)
                .animation(
                    reduceMotion ? .none : .easeOut(duration: 0.4).delay(0.1),
                    value: animateElements
                )
            
            // Action comparison
            actionComparison
                .opacity(animateElements ? 1.0 : 0.0)
                .offset(y: animateElements ? 0 : 20)
                .animation(
                    reduceMotion ? .none : .easeOut(duration: 0.4).delay(0.2),
                    value: animateElements
                )
            
            // Explanation
            explanationSection
                .opacity(animateElements ? 1.0 : 0.0)
                .offset(y: animateElements ? 0 : 20)
                .animation(
                    reduceMotion ? .none : .easeOut(duration: 0.4).delay(0.3),
                    value: animateElements
                )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
                .stroke(borderColor, lineWidth: 2)
                .scaleEffect(animateElements ? 1.0 : 0.95)
                .animation(
                    reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.8),
                    value: animateElements
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .onAppear {
            withAnimation {
                animateElements = true
            }
        }
    }
    
    // MARK: - Result Header
    
    private var resultHeader: some View {
        HStack(spacing: 10) {
            Image(systemName: feedback.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(feedback.isCorrect ? .green : .red)
                .symbolEffect(.bounce, value: animateElements)
                .shadow(
                    color: feedback.isCorrect ? .green.opacity(0.3) : .red.opacity(0.3),
                    radius: animateElements ? 6 : 0
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(feedback.isCorrect ? "Correct!" : "Incorrect")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                
                if !feedback.isCorrect {
                    Text("Keep practicing!")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Scenario Summary
    
    private var scenarioSummary: some View {
        VStack(spacing: 6) {
            Text("Scenario")
                .font(.subheadline.bold())
                .foregroundColor(.secondary)
            
            HStack {
                Text("\(feedback.scenario.handType.displayName) \(feedback.scenario.playerTotal)")
                    .font(.callout.bold())
                
                Text("vs")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Dealer \(feedback.scenario.dealerCard.displayValue)")
                    .font(.callout.bold())
            }
        }
    }
    
    // MARK: - Action Comparison
    
    private var actionComparison: some View {
        HStack(spacing: 20) {
            VStack(spacing: 6) {
                Text("Your Action")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text(feedback.userAction.displayName)
                    .font(.callout.bold())
                    .foregroundColor(feedback.isCorrect ? .green : .red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(feedback.isCorrect ? .green.opacity(0.1) : .red.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(
                                        feedback.isCorrect ? .green.opacity(0.4) : .red.opacity(0.4),
                                        lineWidth: animateElements ? 1.5 : 0
                                    )
                            )
                    )
                    .scaleEffect(animateElements ? 1.0 : 0.9)
            }
            
            if !feedback.isCorrect {
                VStack(spacing: 6) {
                    Text("Correct Action")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(feedback.correctAction.displayName)
                        .font(.callout.bold())
                        .foregroundColor(.green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.green.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(.green.opacity(0.4), lineWidth: animateElements ? 1.5 : 0)
                                )
                        )
                        .scaleEffect(animateElements ? 1.0 : 0.9)
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Explanation Section
    
    private var explanationSection: some View {
        VStack(spacing: 8) {
            Text("Strategy Tip")
                .font(.subheadline.bold())
                .foregroundColor(.secondary)
            
            Text(feedback.explanation)
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .lineLimit(4)
        }
    }
    
    // MARK: - Visual Properties
    
    private var backgroundColor: Color {
        if feedback.isCorrect {
            return Color.green.opacity(0.05)
        } else {
            return Color.red.opacity(0.05)
        }
    }
    
    private var borderColor: Color {
        if feedback.isCorrect {
            return Color.green.opacity(0.3)
        } else {
            return Color.red.opacity(0.3)
        }
    }
    
    private var accessibilityDescription: String {
        let result = feedback.isCorrect ? "Correct" : "Incorrect"
        let scenario = "\(feedback.scenario.handType.displayName) \(feedback.scenario.playerTotal) versus dealer \(feedback.scenario.dealerCard.displayValue)"
        let actions = feedback.isCorrect 
            ? "Your action \(feedback.userAction.displayName) was correct"
            : "Your action \(feedback.userAction.displayName) was incorrect. The correct action is \(feedback.correctAction.displayName)"
        
        return "\(result). \(scenario). \(actions). Strategy explanation: \(feedback.explanation)"
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 30) {
        // Correct feedback
        FeedbackDisplayView(
            feedback: FeedbackResult(
                isCorrect: true,
                userAction: .hit,
                correctAction: .hit,
                explanation: "Hit on hard 16 vs dealer 10. The dealer has a strong card, so take the risk to improve your hand.",
                scenario: GameScenario(
                    handType: .hard,
                    playerCards: [Card(value: 7), Card(value: 9)],
                    playerTotal: 16,
                    dealerCard: Card(value: 10)
                )
            )
        )
        
        // Incorrect feedback
        FeedbackDisplayView(
            feedback: FeedbackResult(
                isCorrect: false,
                userAction: .stand,
                correctAction: .split,
                explanation: "Always split Aces and Eights, don't hesitate! This gives you the best chance to improve both hands.",
                scenario: GameScenario(
                    handType: .pair,
                    playerCards: [Card(value: 8), Card(value: 8)],
                    playerTotal: 8,
                    dealerCard: Card(value: 6)
                )
            )
        )
    }
    .padding()
}