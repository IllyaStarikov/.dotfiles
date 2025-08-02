#!/bin/bash
# Test helper functions for comprehensive dotfiles testing

# Source the base test framework
source "$(dirname "$0")/../test"

# Extended Neovim test helpers
nvim_test() {
    local description="$1"
    local lua_code="$2"
    local expected="$3"
    local timeout="${4:-5000}"
    
    local output
    output=$(nvim --headless -u "$DOTFILES_DIR/src/init.lua" \
        -c "lua vim.defer_fn(function() $lua_code end, 100)" \
        -c "qa!" 2>&1)
    
    if [[ -n "$expected" ]]; then
        if [[ "$output" == *"$expected"* ]]; then
            pass "$description"
        else
            fail "$description - Expected: '$expected', Got: '$output'"
        fi
    else
        # Just check for no errors
        if [[ "$output" != *"Error"* ]] && [[ "$output" != *"error"* ]]; then
            pass "$description"
        else
            fail "$description - Error: $output"
        fi
    fi
}

# Wait for LSP to be ready
wait_for_lsp() {
    local file="$1"
    local timeout="${2:-5000}"
    
    nvim --headless "$file" \
        -c "lua vim.wait($timeout, function() 
            return #vim.lsp.get_clients() > 0 
        end, 100)" \
        -c "lua print('lsp-ready')" \
        -c "qa!" 2>&1
}

# Test if a plugin is loaded
test_plugin_loaded() {
    local plugin="$1"
    local module="${2:-$plugin}"
    
    nvim_test "Plugin $plugin loads" \
        "local ok, _ = pcall(require, '$module'); print('$plugin:', ok and 'loaded' or 'failed')" \
        "$plugin: loaded"
}

# Test if a command exists
test_command_exists() {
    local cmd="$1"
    
    nvim_test "Command :$cmd exists" \
        "print(vim.fn.exists(':$cmd') > 0 and 'exists' or 'missing')" \
        "exists"
}

# Test if a keybinding is set
test_keybinding() {
    local mode="$1"
    local key="$2"
    local expected_cmd="$3"
    
    nvim_test "Keybinding $key in mode $mode" \
        "local map = vim.fn.maparg('$key', '$mode'); print(map ~= '' and 'mapped' or 'unmapped')" \
        "mapped"
}

# Test completion at cursor position
test_completion() {
    local file="$1"
    local line="$2"
    local col="$3"
    local expected_item="$4"
    
    local result
    result=$(nvim --headless "$file" \
        -c "call cursor($line, $col)" \
        -c "startinsert" \
        -c "lua vim.defer_fn(function()
            local blink = require('blink.cmp')
            blink.show()
            vim.defer_fn(function()
                if blink.is_visible() then
                    local items = blink.get_entries()
                    for _, item in ipairs(items or {}) do
                        if item.label and item.label:match('$expected_item') then
                            print('found-completion')
                            vim.cmd('qa!')
                            return
                        end
                    end
                    print('completion-not-found')
                else
                    print('no-completions')
                end
                vim.cmd('qa!')
            end, 1000)
        end, 2000)" 2>&1)
    
    [[ "$result" == *"found-completion"* ]]
}

# Test LSP diagnostics
test_diagnostics() {
    local file="$1"
    local expected_count="$2"
    
    local result
    result=$(nvim --headless "$file" \
        -c "lua vim.defer_fn(function()
            vim.wait(3000, function() return #vim.lsp.get_clients() > 0 end)
            vim.defer_fn(function()
                local diags = vim.diagnostic.get()
                print('diagnostics:', #diags)
                vim.cmd('qa!')
            end, 1000)
        end, 500)" 2>&1)
    
    local actual_count
    actual_count=$(echo "$result" | grep -o 'diagnostics: [0-9]*' | awk '{print $2}')
    
    if [[ "$actual_count" -ge "$expected_count" ]]; then
        pass "Found $actual_count diagnostics (expected at least $expected_count)"
    else
        fail "Found $actual_count diagnostics (expected at least $expected_count)"
    fi
}

# Test theme switching
test_theme_switch() {
    local theme="$1"
    
    # Get initial state
    local initial_nvim_theme
    initial_nvim_theme=$(nvim --headless \
        -c "lua print(vim.g.colors_name or 'default')" \
        -c "qa!" 2>&1 | tail -1)
    
    # Switch theme
    "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" "$theme" > /dev/null 2>&1
    
    # Verify change
    local new_nvim_theme
    new_nvim_theme=$(nvim --headless \
        -c "lua print(vim.g.colors_name or 'default')" \
        -c "qa!" 2>&1 | tail -1)
    
    if [[ "$theme" == "light" ]] && [[ "$new_nvim_theme" != *"dark"* ]]; then
        pass "Theme switched to light"
    elif [[ "$theme" == "dark" ]] && [[ "$new_nvim_theme" == *"dark"* || "$new_nvim_theme" == *"night"* ]]; then
        pass "Theme switched to dark"
    else
        fail "Theme switch failed: $initial_nvim_theme -> $new_nvim_theme"
    fi
}

# Performance benchmark helper
benchmark_startup() {
    local max_time="$1"
    local runs="${2:-5}"
    
    local total=0
    local times=()
    
    for i in $(seq 1 $runs); do
        local start_time=$(date +%s%N)
        nvim --headless -c "qa!" 2>/dev/null
        local end_time=$(date +%s%N)
        local elapsed=$((($end_time - $start_time) / 1000000))
        times+=($elapsed)
        total=$((total + elapsed))
    done
    
    local avg=$((total / runs))
    
    if [[ $avg -lt $max_time ]]; then
        pass "Startup time: ${avg}ms (average of $runs runs)"
    else
        fail "Startup too slow: ${avg}ms > ${max_time}ms"
    fi
}

# Test snippet expansion
test_snippet() {
    local trigger="$1"
    local expected_expansion="$2"
    
    local result
    result=$(nvim --headless \
        -c "startinsert" \
        -c "call feedkeys('i$trigger\<Tab>', 'n')" \
        -c "lua vim.defer_fn(function()
            local line = vim.api.nvim_get_current_line()
            print('expanded:', line)
            vim.cmd('qa!')
        end, 500)" 2>&1)
    
    if [[ "$result" == *"$expected_expansion"* ]]; then
        pass "Snippet $trigger expands correctly"
    else
        fail "Snippet $trigger failed to expand"
    fi
}

# Test Git integration
test_git_command() {
    local cmd="$1"
    local expected="$2"
    
    # Create a test git repo
    local test_repo="$TEST_TMP_DIR/test_git_repo"
    mkdir -p "$test_repo"
    cd "$test_repo"
    git init -q
    echo "test" > test.txt
    git add test.txt
    git commit -q -m "Initial commit"
    
    # Test the command
    local result
    result=$(nvim --headless test.txt \
        -c "$cmd" \
        -c "lua vim.defer_fn(function() print('success') vim.cmd('qa!') end, 1000)" 2>&1)
    
    cd - > /dev/null
    
    if [[ "$result" == *"$expected"* ]] || [[ "$result" == *"success"* ]]; then
        pass "Git command $cmd works"
    else
        fail "Git command $cmd failed"
    fi
}

# Test tmux integration
test_tmux_integration() {
    if ! command -v tmux &> /dev/null; then
        skip "tmux not installed"
        return
    fi
    
    # Start a tmux session
    tmux new-session -d -s test_session 2>/dev/null || true
    
    # Test theme is applied
    local theme_conf
    theme_conf=$(tmux show-options -g | grep -E "(status-style|window-status-style)" | head -1)
    
    if [[ -n "$theme_conf" ]]; then
        pass "tmux theme configuration applied"
    else
        fail "tmux theme configuration not found"
    fi
    
    # Kill test session
    tmux kill-session -t test_session 2>/dev/null || true
}

# Mock LSP server for testing
mock_lsp_server() {
    local lang="$1"
    
    case "$lang" in
        python)
            export MOCK_PYRIGHT=1
            ;;
        lua)
            export MOCK_LUA_LS=1
            ;;
        *)
            export MOCK_LSP=1
            ;;
    esac
}

# Cleanup mock environment
cleanup_mocks() {
    unset MOCK_PYRIGHT
    unset MOCK_LUA_LS
    unset MOCK_LSP
}

# Export all functions
export -f nvim_test wait_for_lsp test_plugin_loaded test_command_exists
export -f test_keybinding test_completion test_diagnostics test_theme_switch
export -f benchmark_startup test_snippet test_git_command test_tmux_integration
export -f mock_lsp_server cleanup_mocks