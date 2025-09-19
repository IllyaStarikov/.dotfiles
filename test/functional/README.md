# /test/functional - Functional Test Suite

## 1. What's in this directory and how to use it

This directory contains functional tests that validate actual features and workflows of the dotfiles configuration. Unlike unit tests that check individual components, functional tests verify that features work end-to-end in realistic scenarios.

### Directory Structure:

```
functional/
├── git/                         # Git workflow tests
│   └── git_workflow_test.sh
├── nvim/                        # Neovim feature tests
│   ├── plugin_functionality_test.sh
│   └── lsp_features_test.sh
├── tmux/                        # Tmux functionality tests
│   └── session_management_test.sh
├── zsh/                         # Shell feature tests
│   └── completion_test.sh
└── lsp_completion_test.sh      # LSP & completion integration (9.9KB)
```

### How to run:

```bash
# Run all functional tests
./test/runner.zsh --functional

# Run specific category
./test/runner.zsh functional/nvim
./test/runner.zsh functional/git

# Run single test
./test/functional/lsp_completion_test.sh

# Run with debugging
TEST_DEBUG=1 ./test/runner.zsh --functional

# Skip slow tests
SKIP_SLOW_TESTS=1 ./test/runner.zsh --functional
```

### Expected output:

```
━━━ Functional Tests ━━━
▶ Testing: LSP completion integration
  ✓ Python completions work
  ✓ Go to definition works
  ✓ Hover documentation appears
Results: 3 passed, 0 failed, 0 skipped
Time: 8.3s
```

## 2. Why this directory exists

### Purpose:

Functional tests ensure that features actually work for users, not just that code is syntactically correct. They catch integration issues, workflow problems, and user experience bugs that unit tests miss.

### Why functional vs unit tests:

1. **User perspective** - Tests what users actually do
2. **Integration** - Validates component interactions
3. **Real environment** - Uses actual configurations
4. **Workflow validation** - Ensures common tasks work
5. **Regression prevention** - Catches feature breaks

### Why organized by component:

- **Clear scope** - Each directory tests specific functionality
- **Parallel execution** - Independent test suites
- **Easy debugging** - Isolate feature problems
- **Maintenance** - Update tests with features

### Why these specific tests:

- **LSP completion** - Core development feature
- **Git workflows** - Daily version control tasks
- **Plugin functionality** - Expensive features to break
- **Session management** - Complex tmux operations
- **Shell completions** - Critical for productivity

## 3. Comprehensive overview

### Test Categories:

#### LSP & Completion Tests (lsp_completion_test.sh):

Tests the integration between Language Server Protocol and completion:

```bash
# Test Python completion
test_case "Python import completion"
create_python_file
start_nvim_with_file
trigger_completion_after "import "
assert_completion_contains "os"
assert_completion_contains "sys"

# Test go-to-definition
test_case "Go to definition works"
place_cursor_on_symbol
send_keys "gd"
assert_cursor_moved
assert_file_changed

# Test hover documentation
test_case "Hover shows documentation"
place_cursor_on_function
send_keys "K"
assert_float_window_visible
assert_contains "function documentation"
```

#### Git Workflow Tests (git/):

Validates common git operations:

```bash
# Test staging workflow
test_case "Stage and commit workflow"
create_test_repo
modify_files
run_git_status_in_nvim
stage_files_with_fugitive
create_commit_with_message
assert_clean_working_tree

# Test merge conflict resolution
test_case "Merge conflict handling"
create_conflict_scenario
open_in_nvim_with_diffview
resolve_conflicts
assert_conflicts_resolved
```

#### Neovim Plugin Tests (nvim/):

Ensures plugins work correctly:

```bash
# Test Telescope
test_case "Telescope file finding"
start_nvim_in_project
trigger_telescope_find_files
type_search_query "test"
select_first_result
assert_file_opened

# Test Treesitter
test_case "Syntax highlighting works"
open_code_file
assert_treesitter_active
assert_highlights_present
test_code_folding

# Test file explorer
test_case "NvimTree operations"
open_file_tree
navigate_to_file
create_new_file
rename_file
assert_filesystem_changes
```

#### Tmux Session Tests (tmux/):

Complex multiplexer operations:

```bash
# Test session creation
test_case "Tmuxinator session loads"
load_tmuxinator_template "dev"
assert_windows_created 3
assert_panes_split
assert_commands_running

# Test resurrection
test_case "Session restore after crash"
create_session_with_state
kill_tmux_server
start_tmux
restore_session
assert_state_preserved
```

#### Shell Completion Tests (zsh/):

Validates intelligent completions:

```bash
# Test git completions
test_case "Git branch completion"
create_test_branches
type_in_shell "git checkout "
press_tab
assert_branches_shown
select_completion
assert_branch_switched

# Test custom completions
test_case "Dotfiles commands complete"
type_in_shell "theme "
press_tab
assert_themes_listed ["day", "night", "moon"]
```

### Test Helpers:

#### Neovim Interaction:

```bash
# Start headless Neovim with test file
start_nvim() {
    local file="$1"
    nvim --headless -u "$DOTFILES_DIR/src/neovim/init.lua" \
         +"set noswapfile" \
         "$file" \
         -c "startinsert" &
    NVIM_PID=$!
    sleep 2  # Wait for LSP to initialize
}

# Send keys to Neovim
send_keys() {
    echo -n "$1" | nvim --headless --remote-send -
}

# Get buffer content
get_buffer_content() {
    nvim --headless --remote-expr "getline(1, '$')"
}
```

#### Timing Considerations:

```bash
# Wait for async operations
wait_for_lsp() {
    local timeout=10
    local elapsed=0
    while [[ $elapsed -lt $timeout ]]; do
        if nvim --remote-expr "luaeval('#vim.lsp.get_active_clients()')" -gt 0; then
            return 0
        fi
        sleep 0.5
        elapsed=$((elapsed + 1))
    done
    return 1
}

# Wait for completion menu
wait_for_completion() {
    wait_with_timeout 5 'pumvisible()' 1
}
```

## 4. LLM Guidance

### For AI Assistants:

When writing functional tests:

1. **Setup realistic environment**

   ```bash
   # Create actual project structure
   setup_test_project() {
       mkdir -p test_project/{src,tests,docs}
       echo "def main(): pass" > test_project/src/main.py
   }
   ```

2. **Use proper waits**

   ```bash
   # Don't use arbitrary sleep
   sleep 2  # BAD

   # Wait for specific condition
   wait_for_lsp  # GOOD
   ```

3. **Clean up thoroughly**

   ```bash
   cleanup() {
       [[ -n "$NVIM_PID" ]] && kill $NVIM_PID 2>/dev/null
       [[ -n "$TMUX_SESSION" ]] && tmux kill-session -t "$TMUX_SESSION"
       rm -rf "$TEST_PROJECT"
   }
   trap cleanup EXIT
   ```

4. **Test user workflows**

   ```bash
   # Test what users actually do
   test_case "Edit, save, commit workflow"
   # Not just individual commands
   ```

5. **Handle async operations**
   ```bash
   # LSP and plugins are async
   trigger_action
   wait_for_result
   assert_outcome
   ```

### Common patterns:

```bash
# Test with timeout
test_with_timeout() {
    timeout 30 bash -c "
        source test_helpers.zsh
        $1
    "
}

# Mock user input
simulate_typing() {
    for char in $(echo "$1" | sed 's/./& /g'); do
        send_keys "$char"
        sleep 0.05  # Simulate typing speed
    done
}

# Validate visual elements
assert_ui_element() {
    local element="$1"
    nvim --remote-expr "luaeval('pcall(require, \"$element\")')"
}
```

## 5. Lessons Learned

### What NOT to do:

#### ❌ Don't test in production environment

```bash
# BAD - Modifies user's actual config
nvim ~/.config/nvim/init.lua

# GOOD - Use test configuration
nvim -u test/fixtures/init.lua
```

#### ❌ Don't ignore timing issues

```bash
# BAD - Race condition
start_nvim
send_keys "gd"  # LSP not ready yet!

# GOOD - Wait for readiness
start_nvim
wait_for_lsp
send_keys "gd"
```

#### ❌ Don't test implementation details

```bash
# BAD - Testing internal function
assert_equals "$(get_internal_state)" "expected"

# GOOD - Test user-visible behavior
trigger_user_action
assert_visible_result
```

### Known Issues:

#### Issue: LSP tests flaky in CI

**Symptom**: Random failures on GitHub Actions
**Cause**: LSP servers take longer to start in CI
**Fix**: Increased timeouts for CI

```bash
if [[ "$CI" == "true" ]]; then
    LSP_TIMEOUT=30  # CI is slower
else
    LSP_TIMEOUT=10
fi
wait_for_lsp $LSP_TIMEOUT
```

#### Issue: Tmux tests fail on macOS

**Symptom**: "no server running" errors
**Cause**: macOS security restrictions
**Fix**: Start server explicitly

```bash
# Ensure tmux server is running
tmux start-server 2>/dev/null || true
tmux new-session -d -s test_session
```

#### Issue: Completion tests inconsistent

**Symptom**: Different results each run
**Cause**: Completion sources have different priorities
**Fix**: Disable non-deterministic sources

```bash
# Disable fuzzy matching for tests
nvim +"lua require('blink.cmp').setup({ fuzzy = { enabled = false } })"
```

### Failed Approaches:

1. **Recording/playback testing** - Too brittle
   - Tried recording user sessions
   - Broke with minor UI changes
   - Now test outcomes, not exact sequences

2. **Visual regression testing** - Too slow
   - Screenshot comparisons
   - 30+ seconds per test
   - Now test logical state

3. **Full integration tests** - Too complex
   - Testing entire workflows end-to-end
   - Difficult to debug failures
   - Split into smaller functional tests

4. **Mocking LSP servers** - Unrealistic
   - Created fake LSP responses
   - Didn't catch real server issues
   - Now use actual servers with fixtures

### Performance Discoveries:

1. **Reuse Neovim instances**

   ```bash
   # Start once, run multiple tests
   start_nvim_server
   for test in tests/*; do
       run_test_in_server "$test"
   done
   kill_nvim_server
   ```

2. **Parallel test execution**

   ```bash
   # Run independent tests simultaneously
   test_git &
   test_completion &
   test_plugins &
   wait
   ```

3. **Skip expensive operations in CI**
   ```bash
   if [[ "$CI" != "true" ]]; then
       test_case "Treesitter parsing performance"
       # Expensive test only locally
   fi
   ```

### Best Practices:

1. **Use fixtures for consistency**

   ```bash
   # Known good test data
   cp test/fixtures/sample.py "$TEST_FILE"
   ```

2. **Test error conditions**

   ```bash
   test_case "Handles missing LSP server"
   uninstall_lsp_server
   open_file
   assert_graceful_degradation
   ```

3. **Document timing requirements**

   ```bash
   # This test requires fast machine
   # Typically completes in 2-3 seconds
   # Timeout at 10 seconds
   ```

4. **Test multiple scenarios**
   ```bash
   for language in python javascript rust; do
       test_case "Completion works for $language"
       test_completion_for_language "$language"
   done
   ```

## Troubleshooting

### Debug Commands:

```bash
# Run with verbose output
TEST_DEBUG=1 ./test/functional/lsp_completion_test.sh

# Keep test environment for inspection
NO_CLEANUP=1 ./test/functional/nvim/plugin_test.sh

# Run specific test case
RUN_ONLY="Python completion" ./test.sh

# Generate detailed logs
NVIM_LOG_FILE=/tmp/nvim.log ./test.sh
```

### Common Problems:

1. **Test hangs**

   ```bash
   # Find stuck process
   ps aux | grep nvim
   # Kill if needed
   killall nvim
   ```

2. **Cannot connect to Neovim**

   ```bash
   # Check server is running
   nvim --remote-expr "v:servername"
   # Restart server
   ```

3. **LSP not working**
   ```bash
   # Check server installed
   nvim +"checkhealth lsp"
   # Install if missing
   nvim +":MasonInstall pyright"
   ```

## Related Documentation

- [Unit Tests](../unit/README.md) - Component validation
- [Integration Tests](../integration/README.md) - System-wide tests
- [Test Helpers](../lib/README.md) - Shared utilities
- [Performance Tests](../performance/README.md) - Speed benchmarks
- [Test Guide](../TEST_GUIDE.md) - Testing best practices
