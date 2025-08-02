import SwiftUI

// MARK: - Training Session View

struct TrainingSessionView: View {
    @State private var viewModel: TrainingSessionViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Namespace private var transitionNamespace
    @State private var isShowingFeedback = false
    @State private var actionButtonsVisible = true
    @State private var feedbackContentVisible = false
    
    init(configuration: SessionConfiguration) {
        self._viewModel = State(wrappedValue: TrainingSessionViewModel(sessionConfig: configuration))
    }
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .ready, .active:
                activeSessionView
            case .showingFeedback:
                animatedFeedbackView
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
        .onChange(of: viewModel.state) { _, newState in
            handleStateTransition(to: newState)
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
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
        } else {
            // iPhone portrait layout
            VStack(spacing: 20) {
                progressSection
                scenarioSection
                actionSection
                Spacer(minLength: 20)
            }
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 8)
        }
    }
    
    // MARK: - Animated Feedback View
    
    @ViewBuilder
    private var animatedFeedbackView: some View {
        ZStack {
            // Background tint based on correctness
            if let feedback = viewModel.feedback {
                backgroundTintOverlay(isCorrect: feedback.isCorrect)
            }
            
            if horizontalSizeClass == .regular {
                // iPad landscape layout with card flip
                iPadFeedbackLayout
            } else {
                // iPhone portrait layout with card flip
                iPhoneFeedbackLayout
            }
        }
        .onAppear {
            announceResultForAccessibility()
        }
    }
    
    // MARK: - iPad Feedback Layout
    
    @ViewBuilder
    private var iPadFeedbackLayout: some View {
        HStack(spacing: 40) {
            // Scenario section with smooth transition
            VStack(spacing: 30) {
                if let scenario = viewModel.currentScenario {
                    ScenarioDisplayView(scenario: scenario)
                        .matchedGeometryEffect(id: "scenario", in: transitionNamespace)
                        .opacity(isShowingFeedback ? 0.7 : 1.0)
                        .scaleEffect(isShowingFeedback ? 0.95 : 1.0)
                        .animation(
                            reduceMotion ? .none : .easeInOut(duration: 0.2),
                            value: isShowingFeedback
                        )
                }
            }
            .frame(maxWidth: .infinity)
            
            // Feedback content section
            VStack(spacing: 30) {
                if let feedback = viewModel.feedback, feedbackContentVisible {
                    FeedbackDisplayView(feedback: feedback)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    
                    Button("Continue") {
                        handleContinueAction()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!viewModel.canContinue)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
    }
    
    // MARK: - iPhone Feedback Layout
    
    @ViewBuilder
    private var iPhoneFeedbackLayout: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 20) {
                    // Scenario with smooth transition
                    if let scenario = viewModel.currentScenario {
                        ScenarioDisplayView(scenario: scenario)
                            .matchedGeometryEffect(id: "scenario", in: transitionNamespace)
                            .opacity(isShowingFeedback ? 0.7 : 1.0)
                            .scaleEffect(isShowingFeedback ? 0.95 : 1.0)
                            .animation(
                                reduceMotion ? .none : .easeInOut(duration: 0.2),
                                value: isShowingFeedback
                            )
                    }
                    
                    // Feedback content
                    if let feedback = viewModel.feedback, feedbackContentVisible {
                        FeedbackDisplayView(feedback: feedback)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                        
                        // Continue button with proper bottom spacing
                        Button("Continue") {
                            handleContinueAction()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(!viewModel.canContinue)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .id("continueButton") // ID for automatic scrolling
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 60) // Bottom padding for tab bar + safe area
            }
            .scrollBounceBehavior(.basedOnSize)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                // Ensure ScrollView content doesn't overlap with tab bar
                Color.clear.frame(height: 0)
            }
            .onChange(of: feedbackContentVisible) { _, isVisible in
                if isVisible {
                    // Auto-scroll to Continue button when feedback appears with delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.6)) {
                            proxy.scrollTo("continueButton", anchor: .center)
                        }
                    }
                }
            }
        }
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
        VStack(spacing: 6) {
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
        VStack(spacing: 12) {
            Text("What's your move?")
                .font(.headline)
                .foregroundColor(.primary)
                .opacity(actionButtonsVisible ? 1.0 : 0.0)
                .animation(
                    reduceMotion ? .none : .easeOut(duration: 0.15),
                    value: actionButtonsVisible
                )
            
            if actionButtonsVisible {
                ActionButtonsView { action in
                    handleActionSelection(action)
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .scale(scale: 0.8).combined(with: .opacity)
                ))
            }
        }
    }
    
    
    // MARK: - Animation Helpers
    
    private func handleStateTransition(to newState: TrainingSessionViewModel.SessionState) {
        switch newState {
        case .showingFeedback:
            withAnimation(reduceMotion ? .none : .easeOut(duration: 0.1)) {
                actionButtonsVisible = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (reduceMotion ? 0 : 0.15)) {
                withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.3)) {
                    isShowingFeedback = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + (reduceMotion ? 0 : 0.2)) {
                    withAnimation(reduceMotion ? .none : .easeIn(duration: 0.2)) {
                        feedbackContentVisible = true
                    }
                }
            }
            
        case .active:
            withAnimation(reduceMotion ? .none : .easeOut(duration: 0.15)) {
                isShowingFeedback = false
                feedbackContentVisible = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (reduceMotion ? 0 : 0.15)) {
                withAnimation(reduceMotion ? .none : .easeIn(duration: 0.15)) {
                    actionButtonsVisible = true
                }
            }
            
        default:
            break
        }
    }
    
    private func handleActionSelection(_ action: Action) {
        // Provide haptic feedback for action selection
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        viewModel.submitAnswer(action)
    }
    
    private func handleContinueAction() {
        // Reset animation states
        withAnimation(reduceMotion ? .none : .easeOut(duration: 0.15)) {
            feedbackContentVisible = false
            isShowingFeedback = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (reduceMotion ? 0 : 0.15)) {
            viewModel.continueToNextQuestion()
        }
    }
    
    private func backgroundTintOverlay(isCorrect: Bool) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        (isCorrect ? Color.green : Color.red).opacity(0.1),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .opacity(feedbackContentVisible ? 1.0 : 0.0)
            .animation(
                reduceMotion ? .none : .easeInOut(duration: 0.2),
                value: feedbackContentVisible
            )
    }
    
    private func announceResultForAccessibility() {
        guard let feedback = viewModel.feedback else { return }
        
        let announcement = feedback.isCorrect ? "Correct answer!" : "Incorrect answer."
        
        // Delay the announcement to allow screen reader to catch up with UI changes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIAccessibility.post(notification: .announcement, argument: announcement)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TrainingSessionView(configuration: SessionConfiguration(sessionType: .random))
    }
}