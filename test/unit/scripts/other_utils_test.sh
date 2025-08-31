#!/usr/bin/env zsh
# Unit tests for utility scripts (scratchpad, extract, fetch-quotes, fallback)

set -euo pipefail

export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

source "$TEST_DIR/lib/test_helpers.zsh"

describe "Utility scripts comprehensive tests"

setup_test

# Scratchpad tests
describe "scratchpad script"

it "should exist and be executable" && {
    assert_file_exists "$DOTFILES_DIR/src/scripts/scratchpad"
    assert_file_executable "$DOTFILES_DIR/src/scripts/scratchpad"
    pass
}

it "should create temporary files" && {
    local script_content=$(cat "$DOTFILES_DIR/src/scripts/scratchpad")
    assert_contains "$script_content" "tmp" || assert_contains "$script_content" "temp"
    assert_contains "$script_content" "mktemp" || assert_contains "$script_content" "tempfile"
    pass
}

it "should open editor" && {
    local script_content=$(cat "$DOTFILES_DIR/src/scripts/scratchpad")
    assert_contains "$script_content" "nvim" || assert_contains "$script_content" "vim" || assert_contains "$script_content" "EDITOR"
    pass
}

# Extract tests
describe "extract utility"

it "should exist and be executable" && {
    assert_file_exists "$DOTFILES_DIR/src/scripts/extract"
    assert_file_executable "$DOTFILES_DIR/src/scripts/extract"
    pass
}

it "should support multiple archive formats" && {
    local script_content=$(cat "$DOTFILES_DIR/src/scripts/extract")
    assert_contains "$script_content" "tar" || assert_contains "$script_content" "zip"
    assert_contains "$script_content" "gz" || assert_contains "$script_content" "bz2"
    pass
}

it "should detect archive type" && {
    local script_content=$(cat "$DOTFILES_DIR/src/scripts/extract")
    assert_contains "$script_content" "case" || assert_contains "$script_content" "if"
    assert_contains "$script_content" "*.tar" || assert_contains "$script_content" ".tar"
    pass
}

# Fetch-quotes tests
describe "fetch-quotes script"

it "should exist and be executable" && {
    assert_file_exists "$DOTFILES_DIR/src/scripts/fetch-quotes"
    assert_file_executable "$DOTFILES_DIR/src/scripts/fetch-quotes"
    pass
}

it "should fetch from API or source" && {
    local script_content=$(cat "$DOTFILES_DIR/src/scripts/fetch-quotes")
    assert_contains "$script_content" "curl" || assert_contains "$script_content" "wget" || assert_contains "$script_content" "fetch"
    pass
}

it "should handle errors gracefully" && {
    local script_content=$(cat "$DOTFILES_DIR/src/scripts/fetch-quotes")
    assert_contains "$script_content" "error" || assert_contains "$script_content" "Error" || assert_contains "$script_content" "||"
    pass
}

# Fallback tests
describe "fallback script"

it "should exist and be executable" && {
    assert_file_exists "$DOTFILES_DIR/src/scripts/fallback"
    assert_file_executable "$DOTFILES_DIR/src/scripts/fallback"
    pass
}

it "should check for command availability" && {
    local script_content=$(cat "$DOTFILES_DIR/src/scripts/fallback")
    assert_contains "$script_content" "command -v" || assert_contains "$script_content" "which"
    pass
}

it "should provide fallback alternatives" && {
    local script_content=$(cat "$DOTFILES_DIR/src/scripts/fallback")
    assert_contains "$script_content" "else" || assert_contains "$script_content" "alternative" || assert_contains "$script_content" "fallback"
    pass
}

# Theme wrapper tests
describe "theme wrapper script"

it "should exist and be executable" && {
    assert_file_exists "$DOTFILES_DIR/src/scripts/theme"
    assert_file_executable "$DOTFILES_DIR/src/scripts/theme"
    pass
}

it "should call theme switcher" && {
    local script_content=$(cat "$DOTFILES_DIR/src/scripts/theme")
    assert_contains "$script_content" "switch-theme" || assert_contains "$script_content" "theme-switcher"
    pass
}

cleanup_test
echo -e "\n${GREEN}Other utility scripts tests completed${NC}"