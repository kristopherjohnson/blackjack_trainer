import SwiftUI

// MARK: - Training Session View

struct TrainingSessionView: View {
    @State private var viewModel: TrainingSessionViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    init(configuration: SessionConfiguration) {
        self._viewModel = State(wrappedValue: TrainingSessionViewModel(sessionConfig: configuration))
    }
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .ready, .active:
                activeSessionView
            case .showingFeedback:
                feedbackView
            case .completed:
                completionView
            }
        }
        .navigationTitle(viewModel.sessionTitle)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("End Session") {
                    viewModel.endSessionEarly()
                }
                .foregroundColor(.red)
            }
            #else
            ToolbarItem(placement: .primaryAction) {
                Button("End Session") {
                    viewModel.endSessionEarly()
                }
                .foregroundColor(.red)
            }
            #endif
        }
        .onAppear {
            viewModel.startSession()
        }
        .onChange(of: viewModel.isSessionComplete) { _, isComplete in
            if isComplete {
                // Auto-dismiss after a delay when session is complete
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - Active Session View
    
    @ViewBuilder
    private var activeSessionView: some View {
        if horizontalSizeClass == .regular {
            // iPad landscape layout
            HStack(spacing: 40) {
                scenarioSection
                    .frame(maxWidth: .infinity)
                
                VStack(spacing: 30) {
                    actionSection
                    statsSection
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
        } else {
            // iPhone portrait layout
            VStack(spacing: 30) {
                progressSection
                scenarioSection
                actionSection
                statsSection
                Spacer()
            }
            .padding()
        }
    }
    
    // MARK: - Feedback View
    
    @ViewBuilder
    private var feedbackView: some View {
        VStack(spacing: 30) {
            if let feedback = viewModel.feedback {
                FeedbackDisplayView(feedback: feedback)
            }
            
            Button("Continue") {
                viewModel.continueToNextQuestion()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!viewModel.canContinue)
        }
        .padding()
    }
    
    // MARK: - Completion View
    
    @ViewBuilder
    private var completionView: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Session Complete!")
                .font(.largeTitle.bold())
            
            VStack(spacing: 12) {
                Text("Final Score: \(viewModel.correctAnswersCount)/\(viewModel.questionsAnswered)")
                    .font(.title2)
                
                Text("Accuracy: \(viewModel.currentAccuracy, specifier: "%.1f")%")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            Button("Back to Menu") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
    
    
    // MARK: - Section Views
    
    private var progressSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Question \(viewModel.questionsAnswered + 1) of \(viewModel.sessionConfig.maxQuestions)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(viewModel.currentAccuracy, specifier: "%.0f")% Correct")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: viewModel.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
        }
    }
    
    private var scenarioSection: some View {
        VStack(spacing: 20) {
            if let scenario = viewModel.currentScenario {
                ScenarioDisplayView(scenario: scenario)
            } else {
                ProgressView("Generating scenario...")
                    .frame(height: 200)
            }
        }
    }
    
    private var actionSection: some View {
        VStack(spacing: 16) {
            Text("What's your move?")
                .font(.headline)
                .foregroundColor(.primary)
            
            ActionButtonsView { action in
                viewModel.submitAnswer(action)
            }
        }
    }
    
    private var statsSection: some View {
        SessionStatsView(stats: viewModel.sessionStats)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TrainingSessionView(configuration: SessionConfiguration(sessionType: .random))
    }
}