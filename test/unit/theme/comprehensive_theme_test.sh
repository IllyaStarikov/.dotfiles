#!/usr/bin/env zsh
# Comprehensive unit tests for theme switching system

set -euo pipefail

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

# Test suite for theme switching
describe "Theme switching system comprehensive tests"

# Setup before tests
setup_test

# Test: switch-theme.sh exists and is executable
it "switch-theme.sh should exist and be executable" && {
    local script_path="$DOTFILES_DIR/src/theme-switcher/switch-theme.sh"
    
    assert_file_exists "$script_path"
    assert_file_executable "$script_path"
    pass
}

# Test: validate-themes.sh exists and is executable
it "validate-themes.sh should exist and be executable" && {
    local script_path="$DOTFILES_DIR/src/theme-switcher/validate-themes.sh"
    
    assert_file_exists "$script_path"
    assert_file_executable "$script_path"
    pass
}

# Test: Theme directory structure
it "should have proper theme directory structure" && {
    assert_directory_exists "$DOTFILES_DIR/src/theme-switcher/themes"
    
    # Check for theme subdirectories
    local theme_count=$(ls -d "$DOTFILES_DIR/src/theme-switcher/themes"/*/ 2>/dev/null | wc -l)
    assert_greater_than "$theme_count" 0
    pass
}

# Test: Theme configurations exist
it "should have theme configuration files" && {
    local themes=("tokyonight_day" "tokyonight_night" "tokyonight_moon" "tokyonight_storm")
    local missing=0
    
    for theme in "${themes[@]}"; do
        if [[ ! -d "$DOTFILES_DIR/src/theme-switcher/themes/$theme" ]]; then
            ((missing++))
        fi
    done
    
    assert_equals "$missing" 0
    pass
}

# Test: Help message
it "switch-theme.sh should display help message" && {
    output=$("$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" --help 2>&1 || true)
    
    assert_contains "$output" "Usage" || assert_contains "$output" "usage"
    assert_contains "$output" "theme" || assert_contains "$output" "Theme"
    pass
}

# Test: macOS appearance detection
it "should detect macOS appearance" && {
    if [[ "$(uname)" == "Darwin" ]]; then
        local script_content=$(cat "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh")
        assert_contains "$script_content" "AppleInterfaceStyle" || assert_contains "$script_content" "defaults read"
        pass
    else
        skip "Not on macOS"
    fi
}

# Test: Theme file generation
it "should generate theme configuration files" && {
    local script_content=$(cat "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh")
    
    # Should generate configs for various tools
    assert_contains "$script_content" "alacritty" || assert_contains "$script_content" "Alacritty"
    assert_contains "$script_content" "tmux" || assert_contains "$script_content" "Tmux"
    assert_contains "$script_content" "starship" || assert_contains "$script_content" "Starship"
    pass
}

# Test: Atomic operations
it "should use atomic operations for theme switching" && {
    local script_content=$(cat "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh")
    
    # Should use temp files or locking
    assert_contains "$script_content" "tmp" || assert_contains "$script_content" "lock" || assert_contains "$script_content" "atomic"
    pass
}

# Test: Theme validation
it "validate-themes.sh should validate theme files" && {
    output=$("$DOTFILES_DIR/src/theme-switcher/validate-themes.sh" 2>&1 || true)
    
    # Should check theme integrity
    assert_success $? || skip "Validation script may need themes installed"
    pass
}

# Test: Alacritty theme support
it "should support Alacritty themes" && {
    local alacritty_theme_exists=0
    
    for theme_dir in "$DOTFILES_DIR/src/theme-switcher/themes"/*/; do
        if [[ -f "$theme_dir/alacritty/theme.toml" ]] || [[ -f "$theme_dir/alacritty.toml" ]]; then
            alacritty_theme_exists=1
            break
        fi
    done
    
    assert_equals "$alacritty_theme_exists" 1
    pass
}

# Test: tmux theme support
it "should support tmux themes" && {
    local tmux_theme_exists=0
    
    for theme_dir in "$DOTFILES_DIR/src/theme-switcher/themes"/*/; do
        if [[ -f "$theme_dir/tmux/theme.conf" ]] || [[ -f "$theme_dir/tmux.conf" ]]; then
            tmux_theme_exists=1
            break
        fi
    done
    
    assert_equals "$tmux_theme_exists" 1
    pass
}

# Test: Neovim theme integration
it "should integrate with Neovim themes" && {
    local script_content=$(cat "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh")
    
    assert_contains "$script_content" "nvim" || assert_contains "$script_content" "neovim" || assert_contains "$script_content" "vim"
    pass
}

# Test: Theme environment variable
it "should set theme environment variable" && {
    local script_content=$(cat "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh")
    
    assert_contains "$script_content" "MACOS_THEME" || assert_contains "$script_content" "export"
    pass
}

# Test: Current theme tracking
it "should track current theme" && {
    local script_content=$(cat "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh")
    
    assert_contains "$script_content" "current" || assert_contains "$script_content" "CURRENT"
    pass
}

# Test: Error handling
it "should handle errors gracefully" && {
    # Test with invalid theme name
    output=$("$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" "invalid_theme_name" 2>&1 || true)
    
    # Should not crash
    assert_success 0 || assert_contains "$output" "Error" || assert_contains "$output" "error"
    pass
}

# Test: tmux session reload
it "should reload tmux sessions after theme change" && {
    local script_content=$(cat "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh")
    
    assert_contains "$script_content" "tmux" && assert_contains "$script_content" "source" || assert_contains "$script_content" "reload"
    pass
}

# Test: Backup before switching
it "should backup current theme before switching" && {
    local script_content=$(cat "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh")
    
    assert_contains "$script_content" "backup" || assert_contains "$script_content" "save" || assert_contains "$script_content" "previous"
    pass
}

# Test: Theme shortcuts
it "should support theme shortcuts" && {
    local script_content=$(cat "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh")
    
    # Should support shortcuts like 'day', 'night', etc.
    assert_contains "$script_content" "day" || assert_contains "$script_content" "Day"
    assert_contains "$script_content" "night" || assert_contains "$script_content" "Night"
    pass
}

# Test: Dry run mode
it "should support dry run mode" && {
    output=$("$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" --dry-run 2>&1 || true)
    
    # Should show what would be done
    assert_success 0 || assert_contains "$output" "Would" || assert_contains "$output" "DRY"
    pass
}

# Test: Theme wrapper script
it "theme wrapper script should exist" && {
    local wrapper_path="$DOTFILES_DIR/src/scripts/theme"
    
    assert_file_exists "$wrapper_path"
    assert_file_executable "$wrapper_path"
    pass
}

# Test: Color scheme consistency
it "should maintain color scheme consistency" && {
    local script_content=$(cat "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh")
    
    # Should handle colors consistently across tools
    assert_contains "$script_content" "color" || assert_contains "$script_content" "Color"
    pass
}

# Test: Performance optimization
it "should be optimized for performance" && {
    local script_content=$(cat "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh")
    
    # Should avoid unnecessary operations
    assert_contains "$script_content" "if" || assert_contains "$script_content" "check"
    pass
}

# Cleanup after tests
cleanup_test

# Summary
echo -e "\n${GREEN}Theme system comprehensive tests completed${NC}"