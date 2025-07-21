# Blackjack Strategy Trainer - C++ Version

A terminal-based C++ implementation of a blackjack basic strategy trainer to help memorize optimal blackjack play using progressive learning methods and reinforcement techniques.

## Features

- **Complete Basic Strategy**: Implements the mathematically optimal strategy for standard blackjack rules
- **Multiple Training Modes**: Random practice, dealer strength focus, hand type focus, and absolutes drill
- **Progressive Learning**: Start with absolute rules, advance to complex scenarios
- **Statistics Tracking**: Track accuracy by category and session progress
- **Command-line Interface**: Professional CLI using CLI11 library
- **Comprehensive Testing**: Full unit test suite using doctest framework

## Requirements

- C++17 compatible compiler (GCC 7+, Clang 5+, MSVC 2017+)
- CMake 3.10 or higher
- Internet connection (for automatic dependency download)

## Building the Program

### Quick Start

```bash
# Create build directory and configure
mkdir build && cd build
cmake ..

# Build the project
make -j$(nproc)
```

### Detailed Build Instructions

1. **Configure the build system:**
   ```bash
   mkdir build
   cd build
   cmake ..
   ```

2. **Compile the project:**
   ```bash
   # Use all available cores for faster compilation
   make -j$(nproc)

   # Or specify number of cores manually
   make -j4
   ```

3. **Optional: Install the program:**
   ```bash
   sudo make install
   ```

### Build Configuration Options

- **Debug build:**
  ```bash
  cmake -DCMAKE_BUILD_TYPE=Debug ..
  make -j$(nproc)
  ```

- **Release build (default):**
  ```bash
  cmake -DCMAKE_BUILD_TYPE=Release ..
  make -j$(nproc)
  ```

## Running the Program

### Interactive Mode

Run the program without arguments to access the interactive menu:

```bash
./blackjack_trainer
```

### Command-line Mode

Run specific training sessions directly:

```bash
# Random practice (mixed scenarios)
./blackjack_trainer -s random

# Dealer strength groups
./blackjack_trainer -s dealer

# Hand type focus (hard/soft/pairs)
./blackjack_trainer -s hand

# Absolutes drill (always/never rules)
./blackjack_trainer -s absolute

# Specify difficulty level
./blackjack_trainer -s random -d easy
./blackjack_trainer -s absolute -d hard
```

### Help and Options

```bash
# View all available options
./blackjack_trainer --help
```

**Available session types:**
- `random`: Mixed practice with all hand types and dealer cards
- `dealer`: Practice by dealer strength groups (weak/medium/strong)
- `hand`: Focus on specific hand types (hard/soft/pairs)
- `absolute`: Practice absolute rules (always/never scenarios)

**Available difficulty levels:**
- `easy`: Simplified scenarios
- `normal`: Standard difficulty (default)
- `hard`: Advanced scenarios

## Building and Running Tests

### Build Tests

Tests are built automatically with the main project:

```bash
mkdir build && cd build
cmake ..
make -j$(nproc)
```

### Run Unit Tests

```bash
# Run all tests
./test_blackjack

# Run tests with verbose output
./test_blackjack --help  # Shows doctest options

# Run specific test suites
./test_blackjack --test-suite="StrategyChart"
./test_blackjack --test-suite="Statistics"
```

### Using CTest

CMake also provides CTest integration:

```bash
# Run tests through CTest
ctest --verbose

# Run tests in parallel
ctest -j$(nproc)

# Custom target for running tests
make check
```

### Test Coverage

The test suite includes:
- **Strategy Chart Tests**: 28 test cases covering all strategy scenarios
- **Statistics Tests**: 8 test cases covering accuracy tracking
- **Comprehensive Coverage**: Tests for hard totals, soft totals, pairs, edge cases, and error conditions

## Dependencies

The project automatically downloads and configures its dependencies:

- **CLI11** (v2.3.2): Modern command-line parser for C++11
- **doctest** (v2.4.8): Fast C++ testing framework

No manual dependency installation is required - CMake handles everything automatically.

## Project Structure

```
cpp/
├── CMakeLists.txt          # Build configuration
├── README.md              # This file
├── include/               # Header files
│   ├── strategy.h         # Strategy chart implementation
│   ├── stats.h           # Statistics tracking
│   ├── trainer.h         # Training session types
│   └── ui.h              # User interface utilities
├── src/                  # Source files
│   ├── main.cpp          # Main application
│   ├── strategy.cpp      # Strategy implementation
│   ├── stats.cpp         # Statistics implementation
│   ├── trainer.cpp       # Training sessions
│   └── ui.cpp            # UI implementation
└── tests/                # Unit tests
    ├── test_strategy.cpp # Strategy chart tests
    └── test_stats.cpp    # Statistics tests
```

## Compilation Notes

- **C++17 Standard**: The project uses modern C++17 features
- **Compiler Warnings**: Compiled with `-Wall -Wextra -Wpedantic` for code quality
- **Optimization**: Release builds use `-O3` optimization
- **Cross-platform**: Compatible with Linux, macOS, and Windows

## Troubleshooting

### Build Issues

1. **CMake version too old:**
   ```
   Error: CMake 3.10 or higher is required
   ```
   Solution: Update CMake or use a newer system.

2. **Compiler not C++17 compatible:**
   ```
   Error: C++17 features not supported
   ```
   Solution: Use GCC 7+, Clang 5+, or MSVC 2017+.

3. **Network issues during dependency download:**
   ```
   Error: Failed to download dependencies
   ```
   Solution: Check internet connection or use a VPN if behind a firewall.

### Runtime Issues

1. **Command not found:**
   ```bash
   # Make sure you're in the build directory
   cd build
   ./blackjack_trainer
   ```

2. **Permission denied:**
   ```bash
   # Make the binary executable
   chmod +x blackjack_trainer
   ```

## Performance

The C++ version provides:
- **Fast startup**: Minimal initialization overhead
- **Low memory usage**: Efficient data structures
- **Responsive UI**: Immediate user input handling
- **Quick compilation**: Typical build time under 10 seconds

## Contributing

When contributing to the C++ implementation:

1. Follow the existing code style and naming conventions
2. Add unit tests for new functionality
3. Ensure all tests pass before submitting
4. Use modern C++17 features appropriately
5. Maintain cross-platform compatibility

## License

This project is licensed under the MIT License - see the main project LICENSE file for details.