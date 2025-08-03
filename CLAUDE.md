This is an implementation of a Blackjack Strategy Trainer

Read the plan and specification from @blackjack_trainer_plan.md

The trainer must use the strategy given in @blackjack_basic_strategy.md

All code generation **MUST** respect the `.editorconfig` settings of trimming
trailing whitespace and adding an empty line at the end of every source file.

## Translations

These directories contain translations of the Python program into other
programming languages:

- `cpp/`: C++
- `rust/`: Rust
- `go/`: Go
- `android/`: Android (Kotlin/Java)
- `swift/`: iOS (Swift)

Each of these translations should have feature parity, have the same unit tests,
and use the same high-level structure as the Python program. If a change is made
to the Python implementation that affects behavior, make sure the same change is
made to the other implementations.

## Language-Specific Expert Agents

All work in language-specific subdirectories should be handled by the appropriate expert agent:

- **`android/`**: Use **android-expert** for all Android development, including Kotlin/Java code, Gradle build configuration, APK building, emulator management, and Android-specific debugging
- **`swift/`**: Use **swift-expert** for all iOS development, including Swift code, Xcode project configuration, iOS deployment, and Apple platform-specific features
- **`cpp/`**: Use **cpp-expert** for C++ code development, CMake configuration, and C++ best practices
- **`rust/`**: Use **rust-expert** for Rust development, Cargo configuration, and async/tokio patterns
- **`go/`**: Use **go-expert** for Go development, module management, and Go-specific patterns

In general, always use the appropriate programming-language-specific expert agent for each language implementation to ensure proper expertise and best practices are applied.

## Development Workflow

After any series of changes to Python files, or when asked to "run
pre-commit checks", perform these steps to ensure the code is in good shape:

1. Run `pylint` and address any issues, and if necessary, update .pylintrc with any new rules
2. Run `autopep8` to apply a consistent formatting style
3. Run unit tests to ensure code is still working
4. Ensure that the instructions in `README.md` are still correct
5. Ensure that `blackjack_trainer_plan.md` is up to date with the current state of the project

Alternatively, you can run the comprehensive pre-commit script that handles all
implementations:

```bash
./precommit.sh
```

This script runs formatters, linters, and tests for Python, Rust, C++, and Go
implementations automatically.

## SwiftUI Implementation

The `swift/BlackjackTrainer/` directory contains a complete SwiftUI implementation of the Blackjack Strategy Trainer for iOS. This implementation includes several UI improvements made during development:

### UI Improvements Applied
- **Card suit icons**: Main menu uses outline card suit symbols (♣ ♦ ♥ ♠) for the four practice modes
- **Removed statistics display**: Training sessions no longer show ongoing statistics at the bottom for cleaner focus
- **Optimized animations**: Faster transition timing (~50-60% reduction) for more responsive feel
- **Safe area handling**: Proper bottom padding (60pt) ensures Continue button stays above tab bar
- **Automatic scrolling**: ScrollViewReader automatically positions Continue button when feedback appears
- **Compact layouts**: Reduced spacing throughout for efficient screen space usage
- **No 3D effects**: Removed disorienting 3D card flip animations, kept smooth fade/scale transitions
- **Visual feedback**: Subtle color tints (green/red) for correct/incorrect answers with accessibility support

### Key Features
- Complete SwiftUI app with Observation framework (iOS 17+)
- Swift 6 concurrency compliance with proper main actor isolation
- Full accessibility support including reduced motion preferences
- Cross-device layout optimization for iPhone and iPad
- Session-only statistics (no persistent storage as per design)
- Proper Xcode project structure for iOS deployment

