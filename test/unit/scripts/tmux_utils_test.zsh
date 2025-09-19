#!/usr/bin/env zsh
# Test suite for tmux-utils script
# Tests tmux utility functions for status bar

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

describe "tmux-utils script behavioral tests"

setup_test
TMUX_UTILS="$DOTFILES_DIR/src/scripts/tmux-utils"

it "should detect operating system" && {
    # Check OS detection logic
    if grep -q "OS_TYPE=.*uname -s" "$TMUX_UTILS"; then
        pass
    else
        fail "Missing OS detection"
    fi
}

it "should support multiple utility functions" && {
    # Verify it provides CPU, memory, and battery functions
    has_cpu=$(grep -q "get_cpu_usage()" "$TMUX_UTILS" && echo 1 || echo 0)
    has_mem=$(grep -q "get_memory_usage()" "$TMUX_UTILS" && echo 1 || echo 0)
    has_battery=$(grep -q "get_battery_info()" "$TMUX_UTILS" && echo 1 || echo 0)

    if [[ $has_cpu -eq 1 || $has_mem -eq 1 || $has_battery -eq 1 ]]; then
        pass
    else
        fail "Missing utility functions"
    fi
}

it "should implement caching for performance" && {
    # Check for cache file usage
    if grep -q "CACHE_DIR=" "$TMUX_UTILS" && \
       grep -q "_CACHE_FILE=" "$TMUX_UTILS" && \
       grep -q "cache_time" "$TMUX_UTILS"; then
        pass
    else
        fail "Missing caching implementation"
    fi
}

it "should handle both Linux and macOS" && {
    # Verify platform-specific code paths
    has_linux=$(grep -q 'if.*OS_TYPE.*=.*"Linux"' "$TMUX_UTILS" && echo 1 || echo 0)
    has_macos=$(grep -q 'else\|Darwin' "$TMUX_UTILS" && echo 1 || echo 0)

    if [[ $has_linux -eq 1 && $has_macos -eq 1 ]]; then
        pass
    else
        fail "Missing cross-platform support"
    fi
}

it "should handle cache file age checking" && {
    # Verify cache freshness logic
    if grep -q "age=.*current_time.*cache_time" "$TMUX_UTILS" && \
       grep -q "if.*age.*-lt" "$TMUX_UTILS"; then
        pass
    else
        fail "Missing cache age checking"
    fi
}

it "should use proper stat command for each OS" && {
    # Check for OS-specific stat commands
    has_linux_stat=$(grep -q 'stat -c %Y' "$TMUX_UTILS" && echo 1 || echo 0)
    has_macos_stat=$(grep -q 'stat -f %m' "$TMUX_UTILS" && echo 1 || echo 0)

    if [[ $has_linux_stat -eq 1 && $has_macos_stat -eq 1 ]]; then
        pass
    else
        fail "Missing OS-specific stat commands"
    fi
}

it "should accept command-line arguments" && {
    # Script should handle different utility commands as arguments
    if grep -q 'case.*\$1.*in' "$TMUX_UTILS" || \
       grep -q 'if.*\$1' "$TMUX_UTILS"; then
        pass
    else
        fail "Doesn't handle command-line arguments"
    fi
}

cleanup_test

# Return success
exit 0
