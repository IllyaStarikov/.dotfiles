#!/usr/bin/env zsh
# Unit tests for Kitty terminal configuration

# Get the test directory path
TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

# Test framework
source "${TEST_DIR}/lib/test_helpers.zsh"

# Test Kitty configuration exists and is valid
test_kitty_config_exists() {
    local kitty_conf="${DOTFILES_DIR}/src/kitty/kitty.conf"

    assert_file_exists "$kitty_conf" "Kitty configuration file should exist"

    # Check for required configuration entries
    assert_file_contains "$kitty_conf" "font_family" "Font family should be configured"
    assert_file_contains "$kitty_conf" "font_size" "Font size should be configured"
    assert_file_contains "$kitty_conf" "window_padding_width" "Window padding should be configured"
}

# Test Kitty theme integration
test_kitty_theme_support() {
    local theme_conf="${DOTFILES_DIR}/src/kitty/theme.conf"
    local kitty_conf="${DOTFILES_DIR}/src/kitty/kitty.conf"

    # Theme file should exist (even if it's a placeholder)
    assert_file_exists "$theme_conf" "Theme configuration should exist"

    # Main config should include theme
    assert_file_contains "$kitty_conf" "include.*theme.conf" "Main config should include theme"
}

# Test Kitty configuration syntax
test_kitty_config_syntax() {
    local kitty_conf="${DOTFILES_DIR}/src/kitty/kitty.conf"

    # Check for common syntax issues
    if grep -E "^\s*[^#].*[[:space:]]+$" "$kitty_conf" >/dev/null 2>&1; then
        fail "Kitty config has trailing whitespace"
    fi

    # Check for valid configuration format (key value pairs)
    local invalid_lines=$(grep -v -E "^(#|$|[a-z_]+\s+.+$|include\s+.+$)" "$kitty_conf" 2>/dev/null | wc -l)
    assert_equals "$invalid_lines" "0" "All non-comment lines should be valid config entries"
}

# Test Kitty README documentation
test_kitty_readme_exists() {
    local readme="${DOTFILES_DIR}/src/kitty/README.md"

    assert_file_exists "$readme" "Kitty README should exist"
    assert_file_contains "$readme" "Kitty" "README should document Kitty"
    assert_file_contains "$readme" "Configuration" "README should explain configuration"
}

# Run all tests
test_suite "Kitty Configuration" \
    test_kitty_config_exists \
    test_kitty_theme_support \
    test_kitty_config_syntax \
    test_kitty_readme_exists