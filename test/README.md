# Dotfiles Test Suite v4.0

A comprehensive test suite that validates actual functionality, not just file existence.

## Quick Start

```bash
# Run standard test suite (recommended)
./tests/test

# Quick sanity check (< 10 seconds)
./tests/test --quick

# Full test suite with all deep functionality tests
./tests/test --full

# Run specific test categories
./tests/test --unit          # Configuration validation
./tests/test --functional    # Tool functionality + deep plugin tests
./tests/test --integration   # Multi-component workflows
./tests/test --performance   # Performance regression tests
./tests/test --workflows     # Real-world development scenarios

# CI mode with JUnit output
./tests/test --ci
```

## Test Categories

### 1. Unit Tests (< 5s)
- Configuration syntax validation
- Lua modules load without errors
- Script executable permissions
- Plugin spec validation

### 2. Functional Tests (< 30s)
- Critical plugins load and initialize (10+ plugins)
- Custom keybindings work
- LSP server configuration
- Theme switching synchronization

#### Deep Plugin Functionality Tests
- **Telescope**: Tests file finding respects gitignore
- **Gitsigns**: Verifies diff display and staging
- **Treesitter**: Validates syntax highlighting works
- **Blink.cmp**: Context-aware completion
- **Snacks.nvim**: Dashboard and features

### 3. Integration Tests (< 60s)
- Python LSP with diagnostics and hover
- Git workflow with gitsigns
- Complete development workflow
- Neovim + tmux integration

### 4. Performance Tests (--performance or --full)
- Neovim startup time (cold < 300ms, warm < 150ms)
- Plugin loading time (< 500ms)
- Theme switching speed (< 500ms)
- Memory usage and leak detection
- Large file handling performance

### 5. Real-World Workflows (--workflows or --full)
- Full stack web development (React + Python)
- Machine learning projects
- Infrastructure as Code
- Microservices development

## Key Features

✅ **Tests actual functionality**, not just file existence  
✅ **Measures real performance**, not synthetic benchmarks  
✅ **Validates complete workflows**, not isolated features  
✅ **Detects memory leaks** and performance regressions  
✅ **Provides actionable feedback** when tests fail

## Test Infrastructure

### Helpers (`lib/test_helpers.zsh`)
- `test_case` - Define a test
- `pass/fail/skip` - Test outcomes
- `nvim_headless` - Run Neovim tests
- `measure_time_ms` - Performance timing

### Fixtures (`fixtures/`)
- Language-specific test files for LSP testing
- Sample configurations
- Test data for various scenarios

## Options

- `--quick` - Essential tests only (< 10s)
- `--unit` - Unit tests only
- `--functional` - Functional tests only
- `--integration` - Integration tests only
- `--performance` - Performance regression tests
- `--workflows` - Real-world workflow tests
- `--full` - All tests including deep functionality
- `--ci` - CI mode (generates reports)
- `-v, --verbose` - Detailed output
- `-h, --help` - Show help

## Performance Targets

- Neovim startup: < 300ms cold, < 150ms warm
- Plugin loading: < 500ms total
- Completion: < 100ms to show
- Theme switch: < 500ms complete
- Memory growth: < 10% in extended session
- File scaling: < 20x slowdown for 100x size

## CI/CD Integration

Add to GitHub Actions:

```yaml
- name: Run Dotfiles Tests
  run: |
    cd tests
    ./test --ci
    
- name: Run Performance Tests
  run: ./tests/test --performance

- name: Test Real Workflows
  run: ./tests/test --workflows
```

## Interpreting Results

### When Tests Pass
```
✓ All tests passed!
```
Your dotfiles are working correctly for real-world usage.

### When Tests Fail
```
✗ Some tests failed
```
Check the specific failures - they indicate real issues affecting functionality.

### When Tests Skip
```
⚠ SKIPPED: Feature needs additional setup
```
The feature requires additional configuration or dependencies.

## Writing New Tests

Tests follow a simple pattern:
```zsh
test_case "Description of what we're testing"
if [[ condition ]]; then
    pass
else
    fail "Reason for failure"
fi
```

For deep functionality tests:
1. Test real operations, not just loading
2. Use actual project structures
3. Verify user-visible outcomes
4. Include performance measurements

## Summary

This test suite provides confidence that your development environment actually works for real tasks. It goes beyond checking if files exist to validate that:

- Plugins provide their advertised functionality
- LSP servers catch real errors and provide completions
- Performance meets acceptable targets
- Memory usage stays reasonable
- Complete workflows function end-to-end

Run `./tests/test --full` for the complete validation of your dotfiles.