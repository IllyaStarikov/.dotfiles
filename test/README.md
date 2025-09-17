# Dotfiles Test Suite

A focused, signal-driven test suite for validating dotfiles functionality.

## Quick Start

```bash
# Run all tests
./test/runner.py

# Run with debug output
./test/runner.py --debug

# Run in CI mode
./test/runner.py --ci

# Save artifacts to specific directory
./test/runner.py --artifacts /tmp/test-results
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

The test runner generates artifacts in `test/artifacts/`:

- **test-report-TIMESTAMP.json** - Machine-readable test results
- **debug-TIMESTAMP.log** - Detailed debug output (when using --debug)
- **nvim-startup.log** - Neovim startup timing details

## Architecture

```
test/
├── runner.py           # Main test runner (Python 3.6+)
├── artifacts/          # Test results and logs
├── fixtures/           # Test files for LSP/formatter testing
│   ├── sample.py
│   ├── sample.js
│   ├── sample.ts
│   └── sample.cpp
└── README.md          # This file
```

## Key Features

- **Fast** - All tests complete in <1 second
- **Focused** - Only tests that provide real signal
- **Debuggable** - Comprehensive debug mode and artifacts
- **CI-Ready** - Supports CI mode with JSON reporting
- **Portable** - Pure Python, no external dependencies

## Exit Codes

- `0` - All tests passed
- `1` - One or more tests failed
- `130` - Interrupted by user (Ctrl+C)
- `1` - Test runner error

## Adding New Tests

To add a new test, create a method in the `TestRunner` class:

```python
def test_my_feature(self) -> TestResult:
    """One-line description of what this tests."""
    start = time.time()

    # Your test logic here
    passed = check_something()

    return TestResult(
        name="My feature test",
        passed=passed,
        duration=time.time() - start,
        output="What succeeded",
        error="What failed" if not passed else ""
    )
```

Then add it to the appropriate suite in `run_all()`:

```python
self.run_suite("Core Validation", [
    'test_essential_files',
    'test_my_feature',  # Add here
    ...
])
```

## Design Principles

1. **Signal over Coverage** - Test what matters, not everything
2. **Fast Feedback** - All tests should complete quickly
3. **Clear Failures** - Error messages should be actionable
4. **No Dependencies** - Use only Python stdlib
5. **Reproducible** - Tests should be deterministic

## Legacy Tests

The old test framework files are preserved but deprecated. They contained:

- Over 50 individual test files
- Complex categorization (unit/functional/integration/performance/etc.)
- Redundant tests that didn't provide signal
- Slow execution (some tests took minutes)

The new `runner.py` consolidates all meaningful tests into a single, fast, maintainable suite.
