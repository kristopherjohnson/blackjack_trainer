# Blackjack Strategy Trainer - Go Implementation

A terminal-based blackjack basic strategy trainer written in Go. This is a translation of the Python version that helps users memorize optimal blackjack strategy through interactive practice sessions.

## Features

- **Four Practice Modes:**
  - Quick Practice (random scenarios)
  - Learn by Dealer Strength (weak/medium/strong dealer cards)
  - Focus on Hand Types (hard totals, soft totals, pairs)
  - Absolutes Drill (always/never rules)

- **Learning Features:**
  - Wrong answer feedback with explanations
  - Pattern reinforcement with mnemonics
  - Session statistics tracking
  - Progressive difficulty

- **Complete Strategy Implementation:**
  - Hard totals (5-21) vs dealer cards 2-A
  - Soft totals (A,2 through A,9) vs dealer cards 2-A
  - Pairs (2,2 through A,A) vs dealer cards 2-A

## Prerequisites

- Go 1.19 or later
- No external dependencies (uses only Go standard library)

## Building the Program

### Clone and Navigate
```bash
cd /path/to/blackjack_trainer/go
```

### Build Release Version
```bash
go build -o blackjack_trainer
```

### Build with Optimization
```bash
go build -ldflags="-s -w" -o blackjack_trainer
```

## Running the Program

### Interactive Mode (Default)
```bash
go run main.go
# or after building:
./blackjack_trainer
```

### Command-line Options
```bash
# Run specific session types directly
go run main.go -session random          # Quick practice
go run main.go -session dealer          # Dealer strength groups
go run main.go -session hand            # Hand type focus
go run main.go -session absolute        # Absolutes drill

# Specify difficulty level
go run main.go -session random -difficulty easy
go run main.go -session absolute -difficulty hard

# Show help
go run main.go -help
```

### Run Built Binary
```bash
# After building
./blackjack_trainer

# With arguments
./blackjack_trainer -session random -difficulty normal
```

## Available Options

### Session Types
- `random`: Mixed practice with all hand types and dealer cards
- `dealer`: Practice by dealer strength groups (weak/medium/strong)
- `hand`: Focus on specific hand types (hard/soft/pairs)
- `absolute`: Practice absolute rules (always/never scenarios)

### Difficulty Levels
- `easy`: Simplified scenarios
- `normal`: Standard practice (default)
- `hard`: Advanced scenarios

*Note: Difficulty levels are recognized but not yet implemented in the game logic*

## Running Unit Tests

### Run All Tests
```bash
go test ./...
```

### Run Tests with Verbose Output
```bash
go test -v ./...
```

### Run Tests with Coverage
```bash
go test -cover ./...
```

### Run Specific Package Tests
```bash
go test ./internal/strategy
go test ./internal/stats
```

### Run Single Test
```bash
go test -run TestHardTotalsLowValues ./internal/strategy
```

### Test Coverage Summary
- **36 total tests** (28 strategy + 8 statistics)
- **Strategy tests:** Validate all basic strategy decisions against the official chart
- **Statistics tests:** Verify accuracy calculations and session tracking

## Code Quality Checks

### Format Code
```bash
go fmt ./...
```

### Run Static Analysis
```bash
go vet ./...
```

### Check for Common Issues
```bash
# Install golint if not already installed
go install golang.org/x/lint/golint@latest
golint ./...
```

### Build Without Running
```bash
go build
```

## Project Structure

```
go/
├── go.mod                  # Go module definition
├── main.go                 # Main application entry point
├── CLAUDE.md               # Development workflow instructions
├── README.md               # This file
└── internal/               # Internal packages (not importable externally)
    ├── strategy/           # Strategy chart implementation
    │   ├── strategy.go     # Core strategy logic
    │   └── strategy_test.go # Strategy validation tests (28 tests)
    ├── stats/              # Statistics tracking
    │   ├── stats.go        # Session statistics logic
    │   └── stats_test.go   # Statistics tests (8 tests)
    ├── trainer/            # Training session types
    │   └── trainer.go      # Session interface and implementations
    └── ui/                 # Terminal user interface
        └── ui.go           # Menu and display functions
```

## Dependencies

- **Standard Library Only:** No external dependencies required
- **Go Version:** Requires Go 1.19+ for modern language features

## Strategy Reference

The strategy implementation follows the standard basic strategy chart:
- **Assumptions:** 4-8 decks, dealer stands on soft 17, double after split allowed
- **Actions:** Hit (H), Stand (S), Double (D), Split (Y)
- **Coverage:** Complete matrix for all player hands vs dealer up-cards

## Example Usage

```bash
# Start interactive mode
go run main.go

# Quick practice session
go run main.go -session random

# Focus on pairs with hard difficulty
go run main.go -session hand -difficulty hard

# Practice against weak dealer cards
go run main.go -session dealer
```

## Performance

- **Compile time:** ~1-2 seconds
- **Binary size:** ~6-8 MB (statically linked)
- **Memory usage:** Minimal (~2-3 MB runtime)
- **Startup time:** Instant

## Go-Specific Features

- **Interfaces:** Clean separation using Go interfaces for training sessions
- **Packages:** Well-organized internal package structure
- **Error Handling:** Idiomatic Go error handling patterns
- **Zero Dependencies:** Uses only Go standard library
- **Static Binary:** Single executable with no external dependencies

## Compatibility

- **Operating Systems:** Any platform supported by Go (Linux, macOS, Windows, etc.)
- **Architecture:** Any architecture supported by Go (amd64, arm64, etc.)
- **Terminal:** Any ANSI-compatible terminal
- **Cross-compilation:** Supports cross-compilation to different platforms

## Troubleshooting

### Build Issues
```bash
# Check Go version
go version

# Update Go modules
go mod tidy

# Clean module cache
go clean -modcache
```

### Test Failures
```bash
# Run tests with detailed output
go test -v ./...

# Check for compilation errors
go build
```

### Runtime Issues
- Ensure terminal supports ANSI escape sequences
- Check that stdin/stdout are properly connected
- Verify Go version with `go version`

## Cross-Compilation Examples

```bash
# Build for Linux
GOOS=linux GOARCH=amd64 go build -o blackjack_trainer_linux

# Build for Windows
GOOS=windows GOARCH=amd64 go build -o blackjack_trainer.exe

# Build for macOS ARM64
GOOS=darwin GOARCH=arm64 go build -o blackjack_trainer_mac_arm64
```

For additional help, see the parent directory's documentation or the original Python implementation.