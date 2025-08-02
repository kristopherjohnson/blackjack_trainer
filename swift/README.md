# BlackjackTrainer for iOS/macOS

A SwiftUI implementation of the Blackjack Strategy Trainer, designed to help users master basic blackjack strategy through interactive practice sessions.

## Overview

This iOS/macOS app provides the same core functionality as the Python trainer while leveraging native iOS capabilities and following modern Swift development practices. The app uses a session-only statistics model, ensuring user privacy while providing immediate feedback on practice performance.

## Architecture

### Modern Swift Patterns
- **Swift 6**: Full concurrency safety with Sendable protocols
- **SwiftUI**: Declarative UI with Observation framework
- **Structured Concurrency**: Modern async/await patterns
- **Actor Isolation**: Thread-safe data management
- **Navigation Stack**: Type-safe navigation flows

### Core Components

#### Models
- `Card`: Represents playing cards with accessibility support
- `GameScenario`: Practice scenarios with hand types and totals
- `StrategyChart`: Complete basic strategy implementation
- `SessionStats`: Session-only statistics tracking

#### Services
- `ScenarioGenerator`: Creates practice scenarios for different session types
- `StatisticsManager`: Manages session statistics with privacy-first design
- `StrategyChart`: Provides strategy lookup and explanations

#### ViewModels
- `TrainingSessionViewModel`: Manages training session state and logic
- `NavigationState`: Handles app navigation flow
- `AppState`: Global app state management

#### Views
- `MainMenuView`: Primary navigation and session selection
- `TrainingSessionView`: Interactive practice sessions with adaptive layouts
- `StatisticsView`: Session performance analytics
- `StrategyGuideView`: Complete strategy reference charts

## Features

### Training Modes
1. **Quick Practice**: Mixed scenarios from all categories
2. **Dealer Strength Groups**: Practice against weak/medium/strong dealers
3. **Hand Type Focus**: Concentrate on hard totals, soft totals, or pairs
4. **Absolutes Drill**: Never/always rules for fundamental patterns

### Learning Features
- **Immediate Feedback**: Correct/incorrect indication with explanations
- **Strategy Mnemonics**: Memory aids for key patterns
- **Progress Tracking**: Real-time session statistics
- **Adaptive Layouts**: Optimized for iPhone and iPad

### Accessibility
- **VoiceOver Support**: Complete screen reader compatibility
- **Dynamic Type**: Automatic font scaling
- **High Contrast**: Automatic dark mode adaptation
- **Voice Control**: Full voice navigation support

## Requirements

- iOS 17.0+ / macOS 14.0+
- Xcode 16+
- Swift 6.0+

## Building and Running

### Using Swift Package Manager

```bash
# Clone the repository
cd swift/

# Build the project
swift build

# Run tests
swift test

# Generate Xcode project (optional)
swift package generate-xcodeproj
```

### Using Xcode

1. Open `Package.swift` in Xcode
2. Select your target device or simulator
3. Build and run (⌘R)

## Testing

The project includes comprehensive test coverage:

```bash
# Run all tests
swift test

# Run specific test file
swift test --filter StrategyChartTests

# Run with coverage (in Xcode)
# Product → Test (⌘U)
```

### Test Coverage
- **StrategyChartTests**: Complete strategy validation
- **StatisticsManagerTests**: Session statistics functionality
- **GameModelTests**: Core data model validation
- **ScenarioGeneratorTests**: Scenario generation logic
- **TrainingSessionViewModelTests**: Session management with mocks

## Privacy and Data

### Session-Only Design
- **No Persistent Storage**: Statistics reset when app terminates
- **Temporary History**: Recent sessions kept in memory only
- **Privacy First**: No user tracking or data collection
- **Clean Slate**: Each new session starts fresh

This design philosophy maintains focus on immediate practice feedback rather than long-term data collection, consistent with the original Python trainer.

## Project Structure

```
Sources/BlackjackTrainer/
├── App/
│   └── BlackjackTrainerApp.swift      # Main app entry point
├── Models/
│   ├── GameModels.swift               # Core data models
│   ├── StrategyChart.swift            # Strategy implementation
│   └── Statistics.swift               # Statistics models
├── Services/
│   ├── ScenarioGenerator.swift        # Scenario creation
│   └── StatisticsManager.swift        # Statistics management
├── ViewModels/
│   ├── TrainingSessionViewModel.swift # Session logic
│   └── NavigationState.swift          # Navigation state
└── Views/
    ├── Components/                    # Reusable UI components
    ├── Menu/                         # Navigation views
    ├── Training/                     # Practice session views
    ├── Statistics/                   # Statistics views
    └── Guide/                        # Strategy reference views

Tests/BlackjackTrainerTests/
├── StrategyChartTests.swift          # Strategy validation
├── StatisticsManagerTests.swift      # Statistics testing
├── GameModelTests.swift              # Model testing
├── ScenarioGeneratorTests.swift      # Generation testing
└── TrainingSessionViewModelTests.swift # Session testing
```

## Strategy Implementation

The app implements complete basic strategy based on:
- **4-8 decks**, dealer stands on soft 17
- **Double after split allowed**, surrender not allowed
- **Hard totals** (5-21): No aces or ace counts as 1
- **Soft totals** (13-21): Ace counts as 11
- **Pairs** (2,2 through A,A): Split decisions

All strategy decisions match the reference implementation exactly, ensuring consistent learning across platform versions.

## Development Practices

### Code Quality
- **Swift 6 Strict Concurrency**: Compile-time data race safety
- **Protocol-Oriented Design**: Testable architecture with dependency injection
- **Comprehensive Testing**: 90%+ code coverage target
- **Modern SwiftUI**: Observation framework and navigation patterns

### Performance
- **Lazy Loading**: Efficient scenario generation
- **Memory Management**: Automatic cleanup of temporary data
- **Smooth Animations**: Native SwiftUI transitions
- **Responsive UI**: Adaptive layouts for all device sizes

## Contributing

1. Follow Swift API Design Guidelines
2. Maintain test coverage for new features
3. Use SwiftUI and modern Swift patterns
4. Ensure accessibility compliance
5. Preserve session-only data model

## License

MIT License - matches the parent project licensing.

## Acknowledgments

This SwiftUI implementation maintains the proven educational approach of the original Python trainer while leveraging native iOS capabilities for an enhanced user experience. The session-only statistics model preserves the focus on immediate learning feedback rather than long-term data collection.