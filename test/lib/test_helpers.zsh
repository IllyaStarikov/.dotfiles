#!/bin/zsh
# Shared test helpers and utilities

# Ensure we have required variables
: ${DOTFILES_DIR:?"DOTFILES_DIR must be set"}
: ${TEST_TMP_DIR:?"TEST_TMP_DIR must be set"}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Initialize counters if not already set
: ${PASSED:=0}
: ${FAILED:=0}
: ${SKIPPED:=0}

# Test framework functions
test_case() {
    echo -e "${BLUE}▶${NC} $1"
}

pass() {
    echo -e "  ${GREEN}✓ PASSED${NC}"
    ((PASSED++))
    return 0
}

fail() {
    echo -e "  ${RED}✗ FAILED${NC}: ${1:-Test failed}"
    ((FAILED++))
    return 1
}

skip() {
    echo -e "  ${YELLOW}⚠ SKIPPED${NC}: ${1:-Not applicable}"
    ((SKIPPED++))
    return 0
}

# Timing helper
measure_time_ms() {
    local start=$(date +%s%N)
    eval "$1" >/dev/null 2>&1
    local end=$(date +%s%N)
    echo $(( (end - start) / 1000000 ))
}

# Test suite functions for organization
describe() {
    echo -e "\n${CYAN}━━━ $1 ━━━${NC}"
}

it() {
    test_case "$1"
    return 0
}

# Assertion helpers
assert_file_exists() {
    if [[ -f "$1" ]]; then
        return 0
    else
        fail "File does not exist: $1"
        return 1
    fi
}

assert_file_executable() {
    if [[ -x "$1" ]]; then
        return 0
    else
        fail "File is not executable: $1"
        return 1
    fi
}

assert_directory_exists() {
    if [[ -d "$1" ]]; then
        return 0
    else
        fail "Directory does not exist: $1"
        return 1
    fi
}

assert_command_exists() {
    if command -v "$1" &>/dev/null; then
        return 0
    else
        fail "Command not found: $1"
        return 1
    fi
}

assert_contains() {
    if [[ "$1" == *"$2"* ]]; then
        return 0
    else
        fail "String does not contain expected text"
        return 1
    fi
}

assert_not_contains() {
    if [[ "$1" != *"$2"* ]]; then
        return 0
    else
        fail "String contains unexpected text"
        return 1
    fi
}

assert_equals() {
    local actual="$1"
    local expected="$2"
    local tolerance="${3:-0}"
    
    if [[ "$tolerance" -gt 0 ]]; then
        # Numeric comparison with tolerance
        local diff=$((actual - expected))
        [[ ${diff#-} -le $tolerance ]] && return 0
        fail "Values differ by more than $tolerance"
    else
        # String comparison
        [[ "$actual" == "$expected" ]] && return 0
        fail "Expected '$expected' but got '$actual'"
    fi
    return 1
}

assert_greater_than() {
    if [[ "$1" -gt "$2" ]]; then
        return 0
    else
        fail "$1 is not greater than $2"
        return 1
    fi
}

assert_success() {
    if [[ "$1" -eq 0 ]]; then
        return 0
    else
        fail "Command did not succeed (exit code: $1)"
        return 1
    fi
}

# Run all test functions
run_tests() {
    local total=$((PASSED + FAILED + SKIPPED))
    echo -e "\n${CYAN}━━━ Test Results ━━━${NC}"
    echo -e "${GREEN}Passed: $PASSED${NC}"
    [[ $FAILED -gt 0 ]] && echo -e "${RED}Failed: $FAILED${NC}"
    [[ $SKIPPED -gt 0 ]] && echo -e "${YELLOW}Skipped: $SKIPPED${NC}"
    echo -e "Total: $total"
    
    [[ $FAILED -eq 0 ]] && return 0 || return 1
}

# Neovim headless test helper
nvim_headless() {
    nvim --headless -u "$DOTFILES_DIR/src/neovim/init.lua" -c "$1" -c "qa!" 2>&1
}

# Headless Neovim helper with better error handling
nvim_headless() {
    local timeout=${2:-5000}
    local output
    
    output=$(timeout 10s nvim --headless --noplugin -u "$DOTFILES_DIR/src/neovim/init.lua" \
        -c "set noswapfile" \
        -c "$1" \
        -c "qa!" 2>&1)
    
    local exit_code=$?
    
    if [[ $exit_code -eq 124 ]]; then
        echo "TIMEOUT: Command took too long"
        return 1
    elif [[ $exit_code -ne 0 ]]; then
        echo "ERROR: Neovim exited with code $exit_code"
        echo "$output"
        return 1
    else
        echo "$output"
        return 0
    fi
}

# Wait for LSP to attach
wait_for_lsp() {
    local file=$1
    local timeout=${2:-5000}
    
    nvim_headless "
        edit $file
        lua vim.wait($timeout, function() 
            return #vim.lsp.get_clients() > 0 
        end)
        lua print(#vim.lsp.get_clients() > 0 and 'lsp-attached' or 'lsp-timeout')
    " $((timeout + 1000))
}

# Check if a command exists in Neovim
nvim_command_exists() {
    local cmd=$1
    nvim_headless "lua print(vim.fn.exists(':$cmd') > 0 and 'exists' or 'missing')"
}

# Check if a plugin is loaded
nvim_plugin_loaded() {
    local plugin=$1
    nvim_headless "
        lua vim.defer_fn(function()
            local lazy = require('lazy')
            local loaded = require('lazy.core.loader').is_loaded('$plugin')
            print(loaded and 'loaded' or 'not-loaded')
            vim.cmd('qa!')
        end, 2000)
    "
}

# Test keybinding exists
nvim_key_mapped() {
    local mode=$1
    local key=$2
    
    nvim_headless "
        lua local map = vim.fn.maparg('$key', '$mode')
        lua print(map ~= '' and 'mapped' or 'unmapped')
    "
}

# Create a test file with content
create_test_file() {
    local filename=$1
    local content=$2
    
    cat > "$TEST_TMP_DIR/$filename" << EOF
$content
EOF
}

# Run a command and check exit code
run_and_check() {
    local cmd=$1
    local expected_exit=${2:-0}
    
    eval "$cmd" >/dev/null 2>&1
    local actual_exit=$?
    
    if [[ $actual_exit -eq $expected_exit ]]; then
        return 0
    else
        echo "Expected exit code $expected_exit, got $actual_exit"
        return 1
    fi
}

# Check if a process is running
is_process_running() {
    local process=$1
    pgrep -f "$process" >/dev/null 2>&1
}

# Cleanup helper
cleanup_test_processes() {
    # Kill any leftover Neovim instances
    pkill -f "nvim.*--headless" 2>/dev/null || true
    
    # Kill test tmux sessions
    tmux kill-session -t test-session 2>/dev/null || true
}

# Setup test environment
setup_test_env() {
    # Ensure clean test directory
    rm -rf "$TEST_TMP_DIR"
    mkdir -p "$TEST_TMP_DIR"
    
    # Set up test-specific config if needed
    export NVIM_APPNAME="nvim-test"
    
    # Disable any auto-commands that might interfere
    export NVIM_TEST_MODE=1
}

# Teardown test environment
teardown_test_env() {
    cleanup_test_processes
    
    # Clean up test directory
    rm -rf "$TEST_TMP_DIR"
    
    # Unset test variables
    unset NVIM_APPNAME
    unset NVIM_TEST_MODE
}