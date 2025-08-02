import SwiftUI
import BlackjackTrainer

// MARK: - Main App

@main
struct BlackjackTrainerApp: App {
    @State private var statisticsManager = StatisticsManager.shared
    @State private var navigationState = NavigationState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(statisticsManager)
                .environment(navigationState)
        }
    }
}

// MARK: - Content View

struct ContentView: View {
    @Environment(StatisticsManager.self) private var statisticsManager
    @Environment(NavigationState.self) private var navigationState
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainMenuView()
                .tabItem {
                    Label("Practice", systemImage: "gamecontroller")
                }
                .tag(0)
            
            StatisticsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
                .tag(1)
            
            StrategyGuideView()
                .tabItem {
                    Label("Guide", systemImage: "book")
                }
                .tag(2)
        }
        .accentColor(.blue)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environment(StatisticsManager.shared)
        .environment(NavigationState())
}