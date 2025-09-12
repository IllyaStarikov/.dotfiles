# Dotfiles Test Suite v5.0

Production-grade testing framework with comprehensive coverage for all aspects of dotfiles functionality.

## Quick Start

```bash
# Run tests by size (default: large)
./test/run --small           # Quick unit tests (< 30s)
./test/run --medium          # Unit + integration (< 5m)
./test/run --large           # All tests (< 30m)

# Run specific test categories
./test/run --unit            # Configuration validation
./test/run --smoke           # Quick functionality checks
./test/run --regression      # Prevent feature breakage
./test/run --performance     # Performance benchmarks
./test/run --security        # Security vulnerability scans

# Generate bug report with tests
./src/scripts/bugreport --test

# Run with verbose output
./test/run --verbose --format text
```

## Test Architecture

### Test Sizes
- **Small** (`--small`): Unit tests, smoke tests, quick validation (< 30s)
- **Medium** (`--medium`): Integration, system, acceptance tests (< 5m)
- **Large** (`--large`): All tests including performance and security (< 30m)

### Test Categories

#### Functional Testing
- **unit**: Configuration validation, syntax checking, file structure
- **integration**: Component interaction, cross-tool functionality
- **system**: System-wide functionality validation
- **acceptance**: User acceptance criteria verification
- **smoke**: Quick health checks for critical features
- **sanity**: Basic functionality verification
- **regression**: Prevent feature breakage and regressions
- **e2e**: End-to-end workflow validation

#### Non-Functional Testing
- **performance**: Startup time, memory usage, operation speed
- **load**: System behavior under load
- **stress**: Behavior at system limits
- **security**: Vulnerability scanning, secret detection
- **configuration**: Config file validation
- **snapshot**: State comparison and regression detection
- **fuzz**: Randomized input testing

### Key Tests Implemented

#### Unit Tests (`test/unit/core_validation.zsh`)
- Dotfiles structure validation
- Essential file existence
- Script executability
- Shell/Lua syntax validation
- JSON/YAML configuration validity
- No hardcoded paths or secrets

#### Smoke Tests (`test/smoke/quick_check.zsh`)
- Neovim startup
- Zsh configuration loading
- tmux config validation
- Git configuration
- Theme switcher availability
- Essential commands presence
- Symlink integrity

#### Performance Tests (`test/performance/benchmarks.zsh`)
- Neovim startup time (< 300ms)
- Zsh startup time (< 500ms)
- Theme switching (< 500ms)
- Plugin loading (< 500ms)
- Memory usage (< 200MB)
- File operations
- Concurrent operations
- Performance regression detection

#### Security Tests (`test/security/vulnerability_scan.zsh`)
- No hardcoded secrets/API keys
- No exposed SSH/GPG keys
- Secure file permissions
- Command injection prevention
- Secure temp file usage
- Safe curl/wget usage
- Git hooks security
- Dependency vulnerabilities

#### Regression Tests (`test/regression/key_functionality.zsh`)
- Plugin loading consistency
- Alias availability
- Theme switching functionality
- Formatter functionality
- Update script operation
- Critical keybindings
- LSP server configuration

## Test Framework Features

### Core Library (`lib/framework.zsh`)

The comprehensive test framework provides:

✅ **Advanced Logging**: Multi-level logging with automatic sanitization  
✅ **Rich Assertions**: Complete assertion library for all test scenarios  
✅ **Performance Benchmarking**: Built-in timing and memory tracking  
✅ **Parallel Execution**: Run tests concurrently for faster results  
✅ **Multiple Report Formats**: Text, JSON, JUnit XML, HTML  
✅ **Progress Tracking**: Real-time progress with ETA  
✅ **Test Isolation**: Each test runs in isolated environment  
✅ **Automatic Cleanup**: Tests clean up after themselves  

### Key Functions

```zsh
# Assertions
assert "condition" "error message"
assert_equals "expected" "actual" "message"
assert_contains "haystack" "needle" "message"
assert_file_exists "/path/to/file" "message"
assert_command_succeeds "command" "message"

# Benchmarking
benchmark "operation_name" command_to_benchmark

# Test execution
run_test "test_name" "test_function" "category" "size" "timeout"
run_test_suite "suite_name" "suite_dir" "category" "size_filter"

# Parallel execution
run_tests_parallel "test1" "test2" "test3"

# Logging
log "LEVEL" "message"  # LEVEL: ERROR, WARNING, INFO, DEBUG, TRACE
```

## Bug Report Generation

The `bugreport` script provides comprehensive system diagnostics:

```bash
# Generate basic bug report
./src/scripts/bugreport

# Include test results
./src/scripts/bugreport --test

# Include medium test suite
./src/scripts/bugreport --test medium

# Skip log collection
./src/scripts/bugreport --no-logs
```

### Bug Report Contents
- System information (OS, hardware, shell)
- Tool versions (editors, languages, package managers)
- Dotfiles configuration and structure
- Neovim health check and configuration
- Shell environment and aliases
- Performance metrics
- Recent logs (optional)
- Test execution results (optional)
- System fingerprint for debugging

All sensitive data is automatically sanitized.

## Private Repository Testing

The `.dotfiles.private` has separate tests for work configurations:

```bash
# Run private tests
cd ~/.dotfiles/.dotfiles.private
./test/run --small|medium|large

# Test categories
- unit: Basic validation
- configuration: Config file integrity
- integration: Main dotfiles interaction
- machine_detection: Work environment detection
- security: Security compliance
- compliance: Company policy validation
```

## Writing Tests

### Test Structure

```zsh
#!/usr/bin/env zsh
# Test Description
# TEST_SIZE: small|medium|large

source "${TEST_DIR}/lib/framework.zsh"

test_feature_name() {
    log "TRACE" "Starting test for feature"
    
    # Setup
    local test_data=$(setup_test_data)
    
    # Execute
    local result=$(run_feature "$test_data")
    
    # Assert
    assert_equals "expected" "$result" "Feature should produce expected result"
    
    # Cleanup happens automatically
    return 0  # Pass
}
```

### Return Codes
- `0`: Test passed
- `1`: Test failed
- `77`: Test skipped (missing dependencies)
- `124`: Test timeout

## CI/CD Integration

```yaml
# GitHub Actions example
- name: Run Small Tests (PR)
  run: ./test/run --small --format junit --report test-results.xml
  
- name: Run Medium Tests (main branch)
  run: ./test/run --medium --verbose
  
- name: Run Full Test Suite (nightly)
  run: ./test/run --large --format json --report nightly-results.json
  
- name: Performance Regression Check
  run: ./test/run --performance --regression
```

## Performance Standards

Current thresholds enforced by tests:

| Metric | Threshold | Test File |
|--------|-----------|-----------|
| Neovim startup | < 300ms | `performance/benchmarks.zsh` |
| Zsh startup | < 500ms | `performance/benchmarks.zsh` |
| Theme switch | < 500ms | `performance/benchmarks.zsh` |
| Plugin loading | < 500ms | `performance/benchmarks.zsh` |
| Memory usage | < 200MB | `performance/benchmarks.zsh` |

## Debugging Failed Tests

### Verbose Output
```bash
# Maximum verbosity
./test/run -vv --debug

# Run specific category with debug
DEBUG=1 ./test/run --unit --verbose

# Dry run to see what would execute
DRY_RUN=1 ./test/run
```

### Test Artifacts
- `test/logs/`: Execution logs per test
- `test/reports/`: Generated test reports
- `test/snapshots/`: Performance baselines

### Environment Variables
```bash
TEST_SIZE=small       # Override default test size
VERBOSE=1            # Enable verbose output
DEBUG=1              # Enable debug output
PARALLEL=0           # Disable parallel execution
MAX_PARALLEL_JOBS=8  # Set parallel job limit
TEST_TIMEOUT=600     # Set test timeout (seconds)
DRY_RUN=1           # Show what would run
```

## Maintenance

### Update Performance Baselines
```bash
rm test/snapshots/*.json
./test/run --performance
```

### Clean Test Data
```bash
rm -rf test/logs/* test/reports/*
find /tmp -name "test_*" -mtime +1 -delete
```

## Summary

This production-grade test suite ensures:

- **Reliability**: All configurations work as expected
- **Performance**: Operations meet speed requirements
- **Security**: No vulnerabilities or exposed secrets
- **Compatibility**: Works across environments
- **Regression Prevention**: Features don't break over time

Run `./test/run` regularly to maintain confidence in your development environment.