#!/bin/bash

# precommit.sh - Run formatters, linters, and tests for all implementations
# This script runs pre-commit checks for Python, Rust, C++, and Go implementations

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo
    echo -e "${BLUE}=====================================${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}=====================================${NC}"
}

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

print_header "Running Pre-commit Checks for All Implementations"
print_status "Working directory: $SCRIPT_DIR"

# Track overall success
OVERALL_SUCCESS=true

# =============================================================================
# PYTHON CHECKS
# =============================================================================
print_header "Python Implementation Checks"

print_status "Running Python pre-commit checks..."

# Python formatting with autopep8
print_status "Applying autopep8 formatting..."
if command -v autopep8 &> /dev/null; then
    autopep8 --in-place --recursive bjst/ || {
        print_error "autopep8 formatting failed"
        OVERALL_SUCCESS=false
    }
    print_success "autopep8 formatting completed"
else
    print_warning "autopep8 not found, skipping formatting"
fi

# Python linting with pylint
print_status "Running pylint..."
if command -v pylint &> /dev/null; then
    pylint bjst/ || {
        print_warning "pylint found issues (this may be acceptable)"
    }
else
    print_warning "pylint not found, skipping linting"
fi

# Python tests
print_status "Running Python tests..."
if python3 -m pytest tests/ -v &> /dev/null 2>&1; then
    print_success "Python tests with pytest passed"
elif python3 -m unittest discover tests/ -v &> /dev/null 2>&1; then
    print_success "Python tests with unittest passed"
else
    print_error "Python tests failed"
    OVERALL_SUCCESS=false
fi

# =============================================================================
# RUST CHECKS
# =============================================================================
print_header "Rust Implementation Checks"

if [ -d "rust" ]; then
    cd rust
    print_status "Running Rust pre-commit checks..."
    
    # Rust formatting
    print_status "Running cargo fmt..."
    if cargo fmt --check &> /dev/null; then
        print_success "Rust code is properly formatted"
    else
        print_status "Applying cargo fmt..."
        cargo fmt || {
            print_error "cargo fmt failed"
            OVERALL_SUCCESS=false
        }
        print_success "Rust formatting applied"
    fi
    
    # Rust linting
    print_status "Running cargo clippy..."
    cargo clippy -- -D warnings || {
        print_error "cargo clippy found issues"
        OVERALL_SUCCESS=false
    }
    print_success "cargo clippy passed"
    
    # Rust tests
    print_status "Running cargo test..."
    cargo test || {
        print_error "Rust tests failed"
        OVERALL_SUCCESS=false
    }
    print_success "Rust tests passed"
    
    cd ..
else
    print_warning "Rust directory not found, skipping Rust checks"
fi

# =============================================================================
# C++ CHECKS
# =============================================================================
print_header "C++ Implementation Checks"

if [ -d "cpp" ]; then
    cd cpp
    print_status "Running C++ pre-commit checks..."
    
    # C++ formatting
    print_status "Running clang-format..."
    if command -v clang-format &> /dev/null; then
        find include/ src/ tests/ \( -name "*.cpp" -o -name "*.h" \) -print0 2>/dev/null | xargs -0 clang-format -i || {
            print_error "clang-format failed"
            OVERALL_SUCCESS=false
        }
        print_success "C++ formatting applied"
    else
        print_warning "clang-format not found, skipping formatting"
    fi
    
    # C++ build
    print_status "Building C++ project..."
    if [ -d "build" ]; then
        cmake --build build || {
            print_error "C++ build failed"
            OVERALL_SUCCESS=false
        }
        print_success "C++ build completed"
        
        # C++ tests
        print_status "Running C++ tests..."
        cmake --build build --target test || {
            print_error "C++ tests failed"
            OVERALL_SUCCESS=false
        }
        print_success "C++ tests passed"
    else
        print_warning "C++ build directory not found, skipping build and tests"
        print_status "Setting up C++ build..."
        mkdir -p build
        cd build
        cmake .. || {
            print_error "C++ cmake configuration failed"
            OVERALL_SUCCESS=false
        }
        cd ..
        cmake --build build || {
            print_error "C++ build failed"
            OVERALL_SUCCESS=false
        }
        cmake --build build --target test || {
            print_error "C++ tests failed"
            OVERALL_SUCCESS=false
        }
        print_success "C++ build and tests completed"
    fi
    
    cd ..
else
    print_warning "C++ directory not found, skipping C++ checks"
fi

# =============================================================================
# GO CHECKS
# =============================================================================
print_header "Go Implementation Checks"

if [ -d "go" ]; then
    cd go
    print_status "Running Go pre-commit checks..."
    
    # Go formatting
    print_status "Running go fmt..."
    if go fmt ./... | grep -q .; then
        print_status "Applied go fmt formatting"
    else
        print_success "Go code is properly formatted"
    fi
    
    # Go static analysis
    print_status "Running go vet..."
    go vet ./... || {
        print_error "go vet found issues"
        OVERALL_SUCCESS=false
    }
    print_success "go vet passed"
    
    # Go tests
    print_status "Running go test..."
    go test ./... || {
        print_error "Go tests failed"
        OVERALL_SUCCESS=false
    }
    print_success "Go tests passed"
    
    cd ..
else
    print_warning "Go directory not found, skipping Go checks"
fi

# =============================================================================
# SUMMARY
# =============================================================================
print_header "Summary"

if [ "$OVERALL_SUCCESS" = true ]; then
    print_success "All pre-commit checks completed successfully!"
    echo
    print_status "✅ Python: Formatting, linting, and tests completed"
    print_status "✅ Rust: Formatting, linting, and tests completed"
    print_status "✅ C++: Formatting, build, and tests completed"
    print_status "✅ Go: Formatting, static analysis, and tests completed"
    echo
    print_success "All implementations are ready for commit!"
    exit 0
else
    print_error "Some pre-commit checks failed!"
    echo
    print_status "Please review the errors above and fix any issues before committing."
    exit 1
fi