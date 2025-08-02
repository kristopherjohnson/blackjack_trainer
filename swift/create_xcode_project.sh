#!/bin/bash

# Create BlackjackTrainer Xcode project
PROJECT_DIR="BlackjackTrainer"
PROJECT_NAME="BlackjackTrainer"

# Remove existing directory if it exists
rm -rf "$PROJECT_DIR"

# Create the project directory structure
mkdir -p "$PROJECT_DIR/$PROJECT_NAME"

# Copy all source files
cp -r "Sources/BlackjackTrainer/"* "$PROJECT_DIR/$PROJECT_NAME/"

# Create the main App.swift file
cat > "$PROJECT_DIR/$PROJECT_NAME/App.swift" << 'EOF'
import SwiftUI

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
EOF

# Create Info.plist
cat > "$PROJECT_DIR/$PROJECT_NAME/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleDisplayName</key>
	<string>Blackjack Trainer</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	<key>UILaunchScreen</key>
	<dict/>
	<key>UIRequiredDeviceCapabilities</key>
	<array>
		<string>armv7</string>
	</array>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>UISupportedInterfaceOrientations~ipad</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationPortraitUpsideDown</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>ITSAppUsesNonExemptEncryption</key>
	<false/>
</dict>
</plist>
EOF

echo "Project structure created. Please open Xcode and create a new iOS project named '$PROJECT_NAME' in the current directory, then replace the default files with the ones in $PROJECT_DIR/$PROJECT_NAME/"