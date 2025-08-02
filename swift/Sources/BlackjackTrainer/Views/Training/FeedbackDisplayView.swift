import SwiftUI

// MARK: - Feedback Display View

struct FeedbackDisplayView: View {
    let feedback: FeedbackResult
    
    var body: some View {
        VStack(spacing: 24) {
            // Result indicator
            resultHeader
            
            // Scenario summary
            scenarioSummary
            
            // Action comparison
            actionComparison
            
            // Explanation
            explanationSection
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
                .stroke(borderColor, lineWidth: 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }
    
    // MARK: - Result Header
    
    private var resultHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: feedback.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(feedback.isCorrect ? .green : .red)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(feedback.isCorrect ? "Correct!" : "Incorrect")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                
                if !feedback.isCorrect {
                    Text("Keep practicing!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Scenario Summary
    
    private var scenarioSummary: some View {
        VStack(spacing: 8) {
            Text("Scenario")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack {
                Text("\(feedback.scenario.handType.displayName) \(feedback.scenario.playerTotal)")
                    .font(.body.bold())
                
                Text("vs")
                    .foregroundColor(.secondary)
                
                Text("Dealer \(feedback.scenario.dealerCard.displayValue)")
                    .font(.body.bold())
            }
        }
    }
    
    // MARK: - Action Comparison
    
    private var actionComparison: some View {
        HStack(spacing: 30) {
            VStack(spacing: 8) {
                Text("Your Action")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(feedback.userAction.displayName)
                    .font(.title3.bold())
                    .foregroundColor(feedback.isCorrect ? .green : .red)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(feedback.isCorrect ? .green.opacity(0.1) : .red.opacity(0.1))
                    )
            }
            
            if !feedback.isCorrect {
                VStack(spacing: 8) {
                    Text("Correct Action")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(feedback.correctAction.displayName)
                        .font(.title3.bold())
                        .foregroundColor(.green)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.green.opacity(0.1))
                        )
                }
            }
        }
    }
    
    // MARK: - Explanation Section
    
    private var explanationSection: some View {
        VStack(spacing: 12) {
            Text("Strategy Tip")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(feedback.explanation)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding(.horizontal)
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