#!/usr/bin/env zsh
# Minimal test framework for the new test runner
# This file is kept for backward compatibility but is no longer used

# Colors (already defined in main test runner)
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export NC='\033[0m'

# Stub functions for compatibility
print_test_summary() {
    echo "Tests complete"
}

# Mock command helper
mock_command() {
    # Simple mock - just echo the expected output
    echo "$2"
}