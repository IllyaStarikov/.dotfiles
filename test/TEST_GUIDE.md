# Dotfiles Test Suite - Comprehensive Guide

## Overview

This test suite provides comprehensive coverage for the dotfiles repository, ensuring reliability, performance, and correctness across all components.

## Test Structure

```
test/
├── test                    # Main test runner
├── lib/
│   └── test_helpers.zsh   # Shared test utilities and assertions
├── unit/                   # Unit tests (<5s)
│   ├── setup/             # Setup script tests
│   ├── theme/             # Theme system tests
│   ├── scripts/           # Utility script tests
│   ├── nvim/              # Neovim config tests
│   ├── zsh/               # Shell config tests
│   ├── tmux/              # tmux config tests
│   └── git/               # Git config tests
├── functional/            # Functional tests (<30s)
│   ├── nvim/             # Neovim functionality
│   └── lsp_completion_test.sh
├── integration/          # Integration tests (<60s)
│   └── setup_workflow_test.sh
├── performance/          # Performance tests
│   └── performance_test.sh
├── fixtures/             # Test data and configs
└── examples/             # Example test implementations
```

## Running Tests

### Quick Tests (< 10s)
```bash
./test/test --quick
```
Runs essential sanity checks to verify basic functionality.

### Unit Tests Only
```bash
./test/test --unit
```
Tests individual components in isolation.

### Functional Tests Only
```bash
./test/test --functional
```
Tests component behavior and integration.

### Integration Tests Only
```bash
./test/test --integration
```
Tests complete workflows and system-wide behavior.

### Performance Tests
```bash
./test/test --performance
```
Runs performance regression tests with timing benchmarks.

### Full Test Suite
```bash
./test/test --full
```
Runs all tests including performance and workflow tests.

### CI Mode
```bash
./test/test --ci
```
Generates JUnit XML reports for CI/CD pipelines.

## Test Categories

### 1. Unit Tests
- **Purpose**: Validate individual components
- **Timeout**: < 5 seconds
- **Coverage**:
  - Setup scripts (setup.sh, symlinks.sh)
  - Theme switcher system
  - Utility scripts (fixy, tmux-utils, etc.)
  - Configuration file syntax
  - Function definitions

### 2. Functional Tests
- **Purpose**: Test actual functionality
- **Timeout**: < 30 seconds
- **Coverage**:
  - Neovim plugin loading
  - LSP server configuration
  - Key mappings
  - Snippet expansion
  - Shell aliases
  - Terminal configurations

### 3. Integration Tests
- **Purpose**: Test complete workflows
- **Timeout**: < 60 seconds
- **Coverage**:
  - Full setup process
  - Upgrade workflow
  - Theme switching across apps
  - Dotfiles synchronization
  - Private repo integration

### 4. Performance Tests
- **Purpose**: Prevent performance regression
- **Benchmarks**:
  - Neovim startup: < 300ms
  - Plugin loading: < 500ms
  - Zsh startup: < 200ms
  - Theme switching: < 1000ms

## Writing Tests

### Test Helpers

The test framework provides comprehensive assertion helpers:

```zsh
# File assertions
assert_file_exists "/path/to/file"
assert_file_executable "/path/to/script"
assert_directory_exists "/path/to/dir"
assert_symlink_exists "/path/to/link"

# Command assertions
assert_command_exists "git"

# String assertions
assert_contains "$output" "expected"
assert_not_contains "$output" "unexpected"
assert_equals "$actual" "$expected"
assert_not_equals "$val1" "$val2"
assert_empty "$variable"
assert_not_empty "$variable"

# Numeric assertions
assert_greater_than "$value" 10
assert_less_than "$value" 100

# Exit code assertions
assert_success $?
assert_failure $?

# Test control
pass              # Mark test as passed
fail "message"    # Mark test as failed with message
skip "reason"     # Skip test with reason
```

### Mock Framework

Mock external commands for testing:

```zsh
# Create a mock
mock_command "brew" 0 "mock output"

# Use the mock
brew install something  # Returns 0, outputs "mock output"

# Clean up
unmock_command "brew"
```

### Test Template

```zsh
#!/usr/bin/env zsh
set -euo pipefail

# Setup environment
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

# Test suite
describe "Component tests"

# Setup
setup_test

# Test cases
it "should do something" && {
    # Test implementation
    assert_file_exists "$DOTFILES_DIR/src/file"
    pass
}

# Cleanup
cleanup_test
```

## Performance Baselines

### Critical Path Metrics
- **Neovim startup**: 300ms maximum
- **Plugin loading**: 500ms maximum
- **Zsh startup**: 200ms maximum
- **Theme switch**: 1000ms maximum
- **Script execution**: 100ms maximum

### Memory Constraints
- **Neovim memory**: < 50MB after garbage collection
- **No memory leaks** in long-running processes

## CI/CD Integration

### GitHub Actions
Tests run automatically on:
- Push to main branch
- Pull requests
- Manual dispatch

### Test Matrix
- **Operating Systems**: Ubuntu, macOS-latest, macOS-14
- **Environments**: Fresh install, upgrade scenarios
- **Modes**: Quick, full, performance

### Output Formats
- Console output with color coding
- JUnit XML for CI reporting
- HTML reports for detailed analysis
- Performance metrics tracking

## Troubleshooting

### Common Issues

1. **Test timeouts**
   - Increase timeout values in test scripts
   - Check for blocking operations
   - Verify network dependencies

2. **Permission errors**
   - Ensure scripts are executable
   - Check directory permissions
   - Run with appropriate user context

3. **Missing dependencies**
   - Install required tools (shellcheck, etc.)
   - Mock external commands
   - Use conditional skipping

4. **Flaky tests**
   - Add retry mechanisms
   - Increase timing tolerances
   - Improve test isolation

### Debug Mode

Run tests with verbose output:
```bash
./test/test -v --unit
```

Generate detailed logs:
```bash
TEST_DEBUG=1 ./test/test
```

## Best Practices

1. **Test Isolation**
   - Use TEST_TMP_DIR for temporary files
   - Clean up after each test
   - Don't modify system state

2. **Performance**
   - Keep unit tests under 5 seconds
   - Use caching where appropriate
   - Run expensive tests only when needed

3. **Reliability**
   - Handle errors gracefully
   - Use timeouts for blocking operations
   - Provide clear failure messages

4. **Maintainability**
   - Use descriptive test names
   - Group related tests
   - Document complex test logic
   - Keep tests simple and focused

## Coverage Goals

### Current Coverage
- ✅ Core setup scripts
- ✅ Theme switching system
- ✅ Utility scripts
- ✅ Neovim configuration
- ✅ Performance benchmarks

### Future Improvements
- [ ] Zsh plugin testing
- [ ] Terminal emulator configs
- [ ] Git hook execution
- [ ] Cross-platform validation
- [ ] Security scanning

## Contributing

When adding new features:
1. Write tests first (TDD approach)
2. Ensure all tests pass
3. Add performance benchmarks if applicable
4. Update this documentation
5. Run full test suite before committing

## Test Commands Reference

```bash
# Run all tests
./test/test

# Quick sanity check
./test/test --quick

# Specific test level
./test/test --unit
./test/test --functional
./test/test --integration

# Performance testing
./test/test --performance

# Full suite with all tests
./test/test --full

# CI mode with reporting
./test/test --ci

# Verbose output
./test/test -v

# Run specific test file
./test/unit/setup/comprehensive_setup_test.sh

# Run with custom environment
TEST_DIR=/path/to/test DOTFILES_DIR=/path/to/dotfiles ./test/test
```

## Maintenance

### Regular Tasks
- Review and update performance baselines
- Remove obsolete tests
- Add tests for new features
- Monitor test execution times
- Update dependencies

### Quarterly Review
- Analyze test coverage
- Identify flaky tests
- Optimize slow tests
- Update documentation
- Review CI/CD logs

---

*Last updated: August 2024*
*Test suite version: 4.0*