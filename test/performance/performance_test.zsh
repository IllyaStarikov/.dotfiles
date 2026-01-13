#!/usr/bin/env zsh
# Performance tests for critical components

set -euo pipefail

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

# Test suite for performance
describe "Performance regression tests"

# Setup before tests
setup_test

# Performance thresholds (in milliseconds)
NVIM_STARTUP_THRESHOLD=300
PLUGIN_LOAD_THRESHOLD=500
ZSH_STARTUP_THRESHOLD=200
THEME_SWITCH_THRESHOLD=1000

# Test: Neovim startup performance
it "Neovim should start within ${NVIM_STARTUP_THRESHOLD}ms" && {
    # Measure startup time
    local start_time=$(date +%s%N)
    timeout 5 nvim --headless -u "$DOTFILES_DIR/src/neovim/init.lua" -c "qa!" 2>&1 >/dev/null
    local end_time=$(date +%s%N)

    local duration=$(( (end_time - start_time) / 1000000 ))

    if [[ $duration -lt $NVIM_STARTUP_THRESHOLD ]]; then
        echo "  Startup time: ${duration}ms"
        pass
    else
        fail "Startup took ${duration}ms (threshold: ${NVIM_STARTUP_THRESHOLD}ms)"
    fi
}

# Test: Neovim plugin loading performance
it "Neovim plugins should load within ${PLUGIN_LOAD_THRESHOLD}ms" && {
    # Create test file to trigger plugin loading
    echo "test content" > "$TEST_TMP_DIR/test.lua"

    # Measure plugin loading time
    local start_time=$(date +%s%N)
    timeout 5 nvim --headless -u "$DOTFILES_DIR/src/neovim/init.lua" \
        "$TEST_TMP_DIR/test.lua" \
        -c "lua vim.cmd('Lazy! sync')" \
        -c "qa!" 2>&1 >/dev/null || true
    local end_time=$(date +%s%N)

    local duration=$(( (end_time - start_time) / 1000000 ))

    if [[ $duration -lt $PLUGIN_LOAD_THRESHOLD ]]; then
        echo "  Plugin load time: ${duration}ms"
        pass
    else
        fail "Plugin loading took ${duration}ms (threshold: ${PLUGIN_LOAD_THRESHOLD}ms)"
    fi
}

# Test: Zsh startup performance
it "Zsh should start within ${ZSH_STARTUP_THRESHOLD}ms" && {
    # Skip if zshrc doesn't exist
    if [[ ! -f "$DOTFILES_DIR/src/zsh/zshrc" ]]; then
        skip "zshrc not found"
        return
    fi

    # Measure zsh startup time
    local start_time=$(date +%s%N)
    zsh -c "source $DOTFILES_DIR/src/zsh/zshrc; exit" 2>/dev/null || true
    local end_time=$(date +%s%N)

    local duration=$(( (end_time - start_time) / 1000000 ))

    if [[ $duration -lt $ZSH_STARTUP_THRESHOLD ]]; then
        echo "  Zsh startup time: ${duration}ms"
        pass
    else
        fail "Zsh startup took ${duration}ms (threshold: ${ZSH_STARTUP_THRESHOLD}ms)"
    fi
}

# Test: Theme switching performance
it "Theme switching should complete within ${THEME_SWITCH_THRESHOLD}ms" && {
    if [[ ! -x "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" ]]; then
        skip "Theme switcher not found"
        return
    fi

    # Measure theme switch time
    local start_time=$(date +%s%N)
    "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" --dry-run 2>&1 >/dev/null || true
    local end_time=$(date +%s%N)

    local duration=$(( (end_time - start_time) / 1000000 ))

    if [[ $duration -lt $THEME_SWITCH_THRESHOLD ]]; then
        echo "  Theme switch time: ${duration}ms"
        pass
    else
        fail "Theme switch took ${duration}ms (threshold: ${THEME_SWITCH_THRESHOLD}ms)"
    fi
}

# Test: Script execution performance
it "Utility scripts should execute quickly" && {
    local scripts=(
        "$DOTFILES_DIR/src/scripts/tmux-utils"
        "$DOTFILES_DIR/src/scripts/scratchpad"
    )

    for script in "${scripts[@]}"; do
        if [[ -x "$script" ]]; then
            local start_time=$(date +%s%N)
            timeout 2 "$script" --help 2>&1 >/dev/null || true
            local end_time=$(date +%s%N)

            local duration=$(( (end_time - start_time) / 1000000 ))

            if [[ $duration -gt 100 ]]; then
                fail "$(basename "$script") took ${duration}ms"
                return
            fi
        fi
    done

    pass
}

# Test: Configuration file parsing performance
it "Configuration files should parse quickly" && {
    local configs=(
        "$DOTFILES_DIR/src/neovim/init.lua"
        "$DOTFILES_DIR/src/zsh/zshrc"
        "$DOTFILES_DIR/src/tmux.conf"
    )

    for config in "${configs[@]}"; do
        if [[ -f "$config" ]]; then
            local start_time=$(date +%s%N)

            case "$config" in
                *.lua)
                    timeout 1 lua -e "dofile('$config')" 2>/dev/null || true
                    ;;
                *.sh|*zshrc)
                    timeout 1 zsh -n "$config" 2>/dev/null || true
                    ;;
                *)
                    # Just read the file
                    cat "$config" >/dev/null 2>&1
                    ;;
            esac

            local end_time=$(date +%s%N)
            local duration=$(( (end_time - start_time) / 1000000 ))

            if [[ $duration -gt 50 ]]; then
                fail "$(basename "$config") parsing took ${duration}ms"
                return
            fi
        fi
    done

    pass
}

# Test: Memory usage
it "Neovim should not leak memory" && {
    if ! command -v nvim &>/dev/null; then
        skip "Neovim not installed"
        return
    fi

    # Start Neovim and check memory
    nvim --headless -u "$DOTFILES_DIR/src/neovim/init.lua" \
        -c "lua collectgarbage('collect')" \
        -c "lua local mem = collectgarbage('count'); if mem > 50000 then vim.cmd('cq!') end" \
        -c "qa!" 2>&1 >/dev/null

    if [[ $? -eq 0 ]]; then
        pass
    else
        fail "Memory usage exceeds threshold"
    fi
}

# Test: File I/O performance
it "File operations should be efficient" && {
    local test_file="$TEST_TMP_DIR/perf_test.txt"

    # Write test
    local start_time=$(date +%s%N)
    for i in {1..100}; do
        echo "Line $i" >> "$test_file"
    done
    local end_time=$(date +%s%N)

    local write_duration=$(( (end_time - start_time) / 1000000 ))

    # Read test
    start_time=$(date +%s%N)
    while read -r line; do
        : # No-op
    done < "$test_file"
    end_time=$(date +%s%N)

    local read_duration=$(( (end_time - start_time) / 1000000 ))

    if [[ $write_duration -lt 100 ]] && [[ $read_duration -lt 50 ]]; then
        echo "  Write: ${write_duration}ms, Read: ${read_duration}ms"
        pass
    else
        fail "I/O too slow - Write: ${write_duration}ms, Read: ${read_duration}ms"
    fi
}

# Test: Parallel execution capability
it "Scripts should handle parallel execution" && {
    local script="$DOTFILES_DIR/src/scripts/tmux-utils"

    if [[ ! -x "$script" ]]; then
        skip "tmux-utils not found"
        return
    fi

    # Run multiple instances in parallel
    local start_time=$(date +%s%N)

    {
        "$script" cpu 2>&1 >/dev/null &
        "$script" memory 2>&1 >/dev/null &
        "$script" battery 2>&1 >/dev/null &
        wait
    }

    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))

    if [[ $duration -lt 500 ]]; then
        echo "  Parallel execution time: ${duration}ms"
        pass
    else
        fail "Parallel execution took ${duration}ms"
    fi
}

# Test: Cache effectiveness
it "Cache should improve performance" && {
    local script="$DOTFILES_DIR/src/scripts/tmux-utils"

    if [[ ! -x "$script" ]]; then
        skip "tmux-utils not found"
        return
    fi

    # First run (cold cache)
    local start_time=$(date +%s%N)
    "$script" cpu 2>&1 >/dev/null || true
    local end_time=$(date +%s%N)
    local cold_duration=$(( (end_time - start_time) / 1000000 ))

    # Second run (warm cache)
    start_time=$(date +%s%N)
    "$script" cpu 2>&1 >/dev/null || true
    end_time=$(date +%s%N)
    local warm_duration=$(( (end_time - start_time) / 1000000 ))

    if [[ $warm_duration -lt $cold_duration ]]; then
        echo "  Cold: ${cold_duration}ms, Warm: ${warm_duration}ms"
        pass
    else
        fail "Cache not effective - Cold: ${cold_duration}ms, Warm: ${warm_duration}ms"
    fi
}

# Cleanup after tests
cleanup_test

# Summary with performance metrics
echo -e "\n${GREEN}Performance tests completed${NC}"
echo -e "${CYAN}Performance Summary:${NC}"
echo "  - Tests should maintain performance baselines"
echo "  - Monitor for regression in critical paths"
echo "  - Consider optimization if thresholds are exceeded"
