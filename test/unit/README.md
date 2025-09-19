# /test/unit - Unit Test Suite

## 1. What's in this directory and how to use it

This directory contains isolated unit tests that validate individual components of the dotfiles repository. Each subdirectory tests a specific component in isolation, ensuring basic functionality without dependencies on other systems.

### Directory Structure:

```
unit/
├── core_validation.zsh    # Core system validation (9.6KB)
├── git/                   # Git configuration tests
│   ├── git_scripts_test.sh
│   ├── pre_commit_zsh_test.sh
│   └── setup_git_signing_zsh_test.sh
├── keybindings/           # Key binding validation
│   └── keybinding_test.sh
├── nvim/                  # Neovim configuration tests
│   ├── init_zsh_test.sh
│   ├── lsp_zsh_test.sh
│   ├── plugin_loading_test.sh
│   └── plugins_zsh_test.sh
├── scripts/               # Utility script tests
│   ├── comprehensive_scripts_test.sh
│   ├── fixy_zsh_test.sh
│   ├── scratchpad_zsh_test.sh
│   └── update_zsh_test.sh
├── setup/                 # Setup script tests
│   ├── comprehensive_setup_test.sh
│   ├── setup_zsh_test.sh
│   └── symlinks_zsh_test.sh
├── theme/                 # Theme system tests
│   ├── comprehensive_theme_test.sh
│   └── theme_zsh_test.sh
├── tmux/                  # Tmux configuration tests
│   └── tmux_conf_zsh_test.sh
└── zsh/                   # Shell configuration tests
    ├── aliases_zsh_test.sh
    ├── plugins_zsh_test.sh
    └── zshrc_zsh_test.sh
```

### How to run unit tests:

```bash
# Run all unit tests
./test/runner.zsh --unit

# Run specific component tests
./test/runner.zsh unit/nvim
./test/runner.zsh unit/setup

# Run single test file
./test/unit/nvim/init_zsh_test.sh

# Run with verbose output
TEST_DEBUG=1 ./test/runner.zsh --unit

# Run in CI mode
CI=true ./test/runner.zsh --unit
```

### Expected output:

```
▶ Testing: Neovim configuration
  ✓ init.lua exists and is valid
  ✓ Neovim starts without errors
  ✓ Required Neovim version
Results: 3 passed, 0 failed, 0 skipped
```

## 2. Why this directory exists

### Purpose:

Unit tests provide the first line of defense against configuration errors. They catch basic problems before they can cascade into system-wide failures.

### Why unit tests specifically:

1. **Fast feedback** - Unit tests run in < 5 seconds total
2. **Isolation** - Test one thing at a time without side effects
3. **Early detection** - Catch syntax errors and missing files immediately
4. **CI-friendly** - Can run in minimal environments without full setup
5. **Regression prevention** - Ensure fixes stay fixed

### Why organized by component:

- **Clarity** - Easy to find tests for specific functionality
- **Parallelization** - Different components can be tested simultaneously
- **Ownership** - Clear responsibility for test maintenance
- **Scalability** - New components get their own test directory

### Why we test these specific things:

- **Configuration syntax** - Invalid syntax breaks everything
- **File existence** - Missing files cause cascading failures
- **Version requirements** - Old versions lack required features
- **Permissions** - Wrong permissions prevent execution
- **Dependencies** - Missing dependencies cause runtime failures

## 3. Comprehensive overview

### Test Categories:

#### Configuration Validation (core_validation.zsh)

Tests fundamental system requirements:

- Shell version (Zsh 5.8+)
- Required commands (git, nvim, tmux)
- Directory structure
- Symlink integrity
- Environment variables

#### Component-Specific Tests:

**Git Tests** (`git/`)

- Configuration file syntax
- Hook executability
- GPG signing setup
- Alias definitions
- Ignore patterns

**Neovim Tests** (`nvim/`)

- Lua syntax validation
- Plugin loading checks
- LSP configuration
- Startup performance
- Version requirements

**Script Tests** (`scripts/`)

- Shebang correctness
- Syntax validation
- Required dependencies
- Permission checks
- Function definitions

**Setup Tests** (`setup/`)

- Installation script integrity
- Symlink creation logic
- Backup mechanisms
- Platform detection
- Dry-run mode

**Theme Tests** (`theme/`)

- Theme file existence
- Color scheme validation
- Application integration
- Switching logic
- Lock file handling

**Tmux Tests** (`tmux/`)

- Configuration syntax
- Plugin availability
- Key binding conflicts
- Status bar scripts
- Version compatibility

**Zsh Tests** (`zsh/`)

- RC file syntax
- Plugin loading
- Alias definitions
- Function availability
- Completion setup

### Test Framework:

All tests use the shared test helper library (`../lib/test_helpers.zsh`):

```zsh
# Test structure
test_case "Description of what we're testing"
if [[ condition ]]; then
    pass
else
    fail "Reason for failure"
fi

# Assertions available
assert_file_exists "/path/to/file"
assert_command_exists "git"
assert_equals "$actual" "$expected"
assert_contains "$output" "substring"
```

### Performance Requirements:

- Individual test: < 100ms
- Component suite: < 1 second
- Full unit tests: < 5 seconds
- Memory usage: < 50MB

## 4. LLM Guidance

### For AI Assistants:

When working with unit tests, understand:

1. **Test independence** - Each test must work in isolation
2. **No side effects** - Tests shouldn't modify system state
3. **Fast execution** - Avoid network calls or slow operations
4. **Clear failures** - Error messages must be actionable
5. **Deterministic** - Same input always produces same output

### Writing new tests:

```bash
# Template for new unit test
#!/usr/bin/env zsh
set -euo pipefail

# Source test helpers
source "$TEST_DIR/lib/test_helpers.zsh"

# Describe the test suite
describe "Component Name"

# Setup (if needed)
setup_test

# Test cases
test_case "Feature works correctly"
if [[ -f "$DOTFILES_DIR/path/to/file" ]]; then
    pass
else
    fail "File not found at expected location"
fi

# Cleanup (if needed)
cleanup_test
```

### Test patterns to follow:

1. **Arrange-Act-Assert** - Setup, execute, verify
2. **One assertion per test** - Clear what failed
3. **Descriptive names** - Test name explains what's tested
4. **Guard clauses** - Skip tests that can't run
5. **Cleanup always** - Even after failures

### Common pitfalls to avoid:

- Don't test external dependencies (internet, servers)
- Don't rely on user-specific paths
- Don't assume tool versions
- Don't modify production configs
- Don't leave temp files

## 5. Lessons Learned

### What NOT to do:

#### ❌ Don't test with production configs

```bash
# BAD - Modifies real config
echo "test" >> ~/.zshrc

# GOOD - Use temp file
temp_rc=$(mktemp)
echo "test" >> "$temp_rc"
```

#### ❌ Don't assume environment

```bash
# BAD - Assumes brew is installed
brew list | grep -q package

# GOOD - Check first
if command -v brew >/dev/null; then
    brew list | grep -q package
else
    skip "Homebrew not installed"
fi
```

#### ❌ Don't use absolute timeouts

```bash
# BAD - Might be too short on slow systems
timeout 1 nvim --headless -c ':q'

# GOOD - Use generous timeout
timeout 10 nvim --headless -c ':q'
```

### Known Issues:

#### Issue: Tests pass locally but fail in CI

**Symptom**: Green locally, red in GitHub Actions
**Cause**: Different environment (macOS vs Linux)
**Fix**: Add platform detection

```bash
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS-specific test
else
    skip "Test only runs on macOS"
fi
```

#### Issue: Neovim tests hang

**Symptom**: Test never completes
**Cause**: Plugin trying to download/install
**Fix**: Use --headless and timeout

```bash
timeout 5 nvim --headless -c ':qa' 2>&1
```

#### Issue: Permission denied errors

**Symptom**: Scripts fail with permission errors
**Cause**: Files not marked executable in git
**Fix**: Check and fix in setup

```bash
chmod +x "$DOTFILES_DIR/src/scripts/"*.sh
```

### Failed Approaches:

1. **Testing plugin functionality** - Too slow, moved to functional tests
   - Tried loading all plugins in unit tests
   - Took 30+ seconds just for plugin downloads
   - Now only test plugin specifications exist

2. **Network-dependent tests** - Unreliable in CI
   - Tried testing GitHub API integrations
   - Failed when rate limited or offline
   - Now mock network responses

3. **Interactive command testing** - Can't automate
   - Attempted testing fzf, telescope interactions
   - Required human input
   - Now only test they load without error

4. **Full installation testing** - Too destructive
   - Tried testing actual installation
   - Modified system state
   - Moved to integration tests with containers

### Bugs discovered through unit testing:

1. **Missing shebang** (scripts/fixy)
   - Test revealed script had no shebang
   - Caused "command not found" errors
   - Fixed by adding `#!/usr/bin/env bash`

2. **Syntax error in rarely-used alias** (zsh/aliases.zsh:287)
   - Unclosed quote in `gitlog` alias
   - Only found through systematic testing
   - Fixed and added syntax validation

3. **Version detection bug** (nvim/init.lua)
   - Used `vim.version()` which doesn't exist in 0.8
   - Caused startup failures on older versions
   - Fixed with proper version checking

4. **Race condition in theme switcher**
   - Lock file not atomic
   - Two processes could run simultaneously
   - Fixed with proper locking mechanism

### Best practices discovered:

1. **Always set pipefail**

   ```bash
   set -euo pipefail  # Fail on any error in pipeline
   ```

2. **Guard against missing variables**

   ```bash
   : ${DOTFILES_DIR:?"DOTFILES_DIR must be set"}
   ```

3. **Use process substitution for temp files**

   ```bash
   diff <(sort file1) <(sort file2)  # No temp files needed
   ```

4. **Check commands exist before use**

   ```bash
   command -v rg >/dev/null || skip "ripgrep not installed"
   ```

5. **Cleanup in trap for reliability**
   ```bash
   trap 'rm -f "$tmp_file"' EXIT
   ```

### Performance optimizations:

1. **Parallel test execution** - Run independent tests simultaneously
2. **Skip expensive tests in CI** - Use `CI` environment variable
3. **Cache test results** - Don't re-test unchanged files
4. **Lazy load test helpers** - Only source what's needed
5. **Early exit on failure** - Don't continue after critical failure

### Testing philosophy evolution:

1. **Started with monolithic tests** - One big test file
2. **Moved to component tests** - Separate files per component
3. **Added test helpers** - Shared assertion library
4. **Implemented categories** - Unit/functional/integration
5. **Added performance tests** - Regression prevention

## Troubleshooting

### Common Problems:

1. **Test not found**

   ```bash
   # Check file is executable
   ls -l test/unit/component/test.sh
   # Fix if needed
   chmod +x test/unit/component/test.sh
   ```

2. **Helper functions not available**

   ```bash
   # Ensure TEST_DIR is set
   export TEST_DIR="$DOTFILES_DIR/test"
   # Source helpers
   source "$TEST_DIR/lib/test_helpers.zsh"
   ```

3. **Tests skipped unexpectedly**
   ```bash
   # Check prerequisites
   command -v required_command
   # Check environment
   echo $OSTYPE
   ```

### Debug techniques:

```bash
# Enable trace mode
set -x

# Add debug output
echo "DEBUG: variable = $variable" >&2

# Check exit codes
command || echo "Failed with code: $?"

# Time operations
time {
    expensive_operation
}
```

## Related Documentation

- [Test Helpers](../lib/README.md) - Assertion library
- [Functional Tests](../functional/README.md) - Feature testing
- [Integration Tests](../integration/README.md) - End-to-end testing
- [Test Guide](../TEST_GUIDE.md) - Testing best practices
- [CI Configuration](../../.github/workflows/test.yml) - Automated testing
