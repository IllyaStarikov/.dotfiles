# Test Framework Library

Shared test framework and helpers for all test suites.

## Files

- `test_helpers.zsh` - Main test framework (assertions, helpers, Neovim test utilities)

## Usage

```bash
# Source in test file
source "$TEST_DIR/lib/test_helpers.zsh"

# Write test
test_case "Feature should work"
if [[ condition ]]; then
    pass
else
    fail "Expected X but got Y"
fi
```

## Core Functions

### Test Organization

```bash
describe "Suite Name"    # Group tests
test_case "Test Name"    # Individual test
it "should do X"        # BDD style
```

### Assertions

```bash
assert_file_exists "/path"
assert_command_exists "git"
assert_equals "$actual" "$expected"
assert_contains "$text" "substring"
assert_command_succeeds "command"
```

### Test Results

```bash
pass                    # Mark success
fail "reason"          # Mark failure
skip "reason"          # Skip test
```

### Helpers

```bash
setup_test             # Prepare environment
cleanup_test           # Clean up
mock_command "cmd" 0 "output"
run_with_timeout 5 command
```

## Features

- Colored output with emoji indicators
- Test counters and summary
- Timeout support
- Command mocking
- Temporary file management
- Performance benchmarking

## Why Zsh

- Better arrays and error handling
- Native floating point math
- Extended globbing patterns
- More reliable than Bash for complex tests
