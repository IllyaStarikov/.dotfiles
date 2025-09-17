#!/usr/bin/env zsh
# Functional tests for tmux configuration

# Tests handle errors explicitly

export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

source "$TEST_DIR/lib/test_helpers.zsh"

describe "tmux configuration functional tests"

setup_test

it "tmux.conf should exist" && {
    assert_file_exists "$DOTFILES_DIR/src/tmux.conf"
    pass
}

it "should set custom prefix key" && {
    local tmux_content=$(cat "$DOTFILES_DIR/src/tmux.conf")
    assert_contains "$tmux_content" "prefix" || assert_contains "$tmux_content" "C-a"
    pass
}

it "should configure vi mode" && {
    local tmux_content=$(cat "$DOTFILES_DIR/src/tmux.conf")
    assert_contains "$tmux_content" "vi" || assert_contains "$tmux_content" "vim"
    pass
}

it "should set up status bar" && {
    local tmux_content=$(cat "$DOTFILES_DIR/src/tmux.conf")
    assert_contains "$tmux_content" "status" || assert_contains "$tmux_content" "Status"
    pass
}

it "should configure pane navigation" && {
    local tmux_content=$(cat "$DOTFILES_DIR/src/tmux.conf")
    assert_contains "$tmux_content" "pane" || assert_contains "$tmux_content" "select-pane"
    pass
}

it "should set up window management" && {
    local tmux_content=$(cat "$DOTFILES_DIR/src/tmux.conf")
    assert_contains "$tmux_content" "window" || assert_contains "$tmux_content" "new-window"
    pass
}

it "should configure copy mode" && {
    local tmux_content=$(cat "$DOTFILES_DIR/src/tmux.conf")
    assert_contains "$tmux_content" "copy" || assert_contains "$tmux_content" "Copy"
    pass
}

it "should integrate with system clipboard" && {
    local tmux_content=$(cat "$DOTFILES_DIR/src/tmux.conf")
    assert_contains "$tmux_content" "clipboard" || assert_contains "$tmux_content" "pbcopy" || assert_contains "$tmux_content" "xclip"
    pass
}

it "should use TPM plugin manager" && {
    local tmux_content=$(cat "$DOTFILES_DIR/src/tmux.conf")
    assert_contains "$tmux_content" "tpm" || assert_contains "$tmux_content" "TPM" || assert_contains "$tmux_content" "plugin"
    pass
}

it "should configure mouse support" && {
    local tmux_content=$(cat "$DOTFILES_DIR/src/tmux.conf")
    assert_contains "$tmux_content" "mouse" || assert_contains "$tmux_content" "Mouse"
    pass
}

it "should set terminal colors" && {
    local tmux_content=$(cat "$DOTFILES_DIR/src/tmux.conf")
    assert_contains "$tmux_content" "256color" || assert_contains "$tmux_content" "terminal"
    pass
}

it "should configure tmux-utils integration" && {
    local tmux_content=$(cat "$DOTFILES_DIR/src/tmux.conf")
    assert_contains "$tmux_content" "tmux-utils" || assert_contains "$tmux_content" "cpu" || assert_contains "$tmux_content" "battery"
    pass
}

cleanup_test
echo -e "\n${GREEN}tmux functional tests completed${NC}"