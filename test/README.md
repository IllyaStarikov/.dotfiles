# Dotfiles Test Suite

A focused, signal-driven test suite for validating dotfiles functionality.

## Quick Start

```bash
# Run all tests
./test/runner.zsh

# Run with debug output
./test/runner.zsh --debug

# Run in CI mode
CI=1 ./test/runner.zsh

# Run quick tests only
./test/runner.zsh --quick
```

## Test Philosophy

This test suite focuses on **meaningful signal** rather than exhaustive coverage. Each test should answer a specific question about the health of the dotfiles setup:

1. **Does it work?** - Core functionality tests
2. **Is it fast?** - Performance regression tests
3. **Is it correct?** - Configuration validation
4. **Will it deploy?** - Integration tests

## Test Categories

### Core Validation (Must Pass)

- **Essential files exist** - Verifies core configuration files are present
- **Neovim configuration loads** - Ensures Neovim starts without errors
- **Shell scripts syntax** - Validates all shell scripts have correct syntax
- **Language configurations** - Checks formatter/linter configs are present

### Integration Tests (Should Pass)

- **Theme switcher** - Validates theme switching functionality
- **Symlinks integrity** - Ensures symlink script would create proper links
- **Critical commands** - Tests availability of custom commands (fixy, theme)
- **Git hooks** - Verifies git security hooks are configured

### Performance Tests (Nice to Pass)

- **Neovim startup** - Measures and validates startup time (<300ms excellent, <500ms acceptable)

## Test Artifacts

Test results are logged to standard output with color-coded status:

- **Green** - Tests passed
- **Red** - Tests failed
- **Yellow** - Warnings or skipped tests

## Architecture

```
test/
├── runner.zsh          # Main test runner (Zsh)
├── unit/               # Unit tests (< 5s)
├── functional/         # Functional tests (< 30s)
├── integration/        # Integration tests (< 60s)
├── performance/        # Performance regression tests
├── lib/                # Test framework and helpers
├── fixtures/           # Test files for LSP/formatter testing
│   ├── sample.py
│   ├── sample.js
│   ├── sample.ts
│   └── sample.cpp
└── README.md          # This file
```

## Key Features

- **Fast** - Quick tests complete in <10 seconds
- **Comprehensive** - Unit, functional, integration, and performance tests
- **Debuggable** - Detailed error messages and logging
- **CI-Ready** - Runs in GitHub Actions on multiple platforms
- **Modular** - Easy to add new tests in appropriate category

## Exit Codes

- `0` - All tests passed
- `1` - One or more tests failed

## Adding New Tests

Create a new test file in the appropriate category:

```bash
#!/usr/bin/env zsh
set -euo pipefail

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

describe "My Feature"

test_case "Feature should work"
if [[ condition ]]; then
    pass
else
    fail "Expected X but got Y"
fi
```

Make it executable and run via `runner.zsh`.

## Design Principles

1. **Signal over Coverage** - Test what matters, not everything
2. **Fast Feedback** - All tests should complete quickly
3. **Clear Failures** - Error messages should be actionable
4. **No Dependencies** - Use only Python stdlib
5. **Reproducible** - Tests should be deterministic

## Test Coverage

The suite includes:

- **40+ test files** across all categories
- **Unit tests** for each script and configuration
- **Functional tests** for plugin functionality
- **Integration tests** for multi-component workflows
- **Performance benchmarks** with < 300ms Neovim startup target
- **Security scanning** with Gitleaks integration
