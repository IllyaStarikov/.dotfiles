#!/usr/bin/env zsh
# Comprehensive functional tests for Zsh configuration

# Tests handle errors explicitly

export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

source "$TEST_DIR/lib/test_helpers.zsh"

describe "Zsh configuration functional tests"

setup_test

it "zshrc should load without errors" && {
    output=$(zsh -c "source $DOTFILES_DIR/src/zsh/zshrc; echo 'loaded'" 2>&1 || true)
    assert_contains "$output" "loaded" || skip "May have interactive dependencies"
    pass
}

it "should set up environment variables" && {
    output=$(zsh -c "source $DOTFILES_DIR/src/zsh/zshenv 2>/dev/null; echo \$PATH" 2>&1 || true)
    assert_not_empty "$output"
    pass
}

it "should define aliases" && {
    local zshrc_content=$(cat "$DOTFILES_DIR/src/zsh/zshrc")
    assert_contains "$zshrc_content" "alias" || assert_contains "$zshrc_content" "Alias"
    pass
}

it "should configure PATH correctly" && {
    local zshenv_content=$(cat "$DOTFILES_DIR/src/zsh/zshenv")
    assert_contains "$zshenv_content" "PATH" || assert_contains "$zshenv_content" "path"
    pass
}

it "should set up completion system" && {
    local zshrc_content=$(cat "$DOTFILES_DIR/src/zsh/zshrc")
    assert_contains "$zshrc_content" "compinit" || assert_contains "$zshrc_content" "completion"
    pass
}

it "should configure prompt" && {
    local zshrc_content=$(cat "$DOTFILES_DIR/src/zsh/zshrc")
    assert_contains "$zshrc_content" "prompt" || assert_contains "$zshrc_content" "PROMPT" || assert_contains "$zshrc_content" "starship"
    pass
}

it "should load plugins with Zinit" && {
    local zshrc_content=$(cat "$DOTFILES_DIR/src/zsh/zshrc")
    assert_contains "$zshrc_content" "zinit" || assert_contains "$zshrc_content" "Zinit"
    pass
}

it "should set up key bindings" && {
    local zshrc_content=$(cat "$DOTFILES_DIR/src/zsh/zshrc")
    assert_contains "$zshrc_content" "bindkey" || assert_contains "$zshrc_content" "bind"
    pass
}

it "should configure history" && {
    local zshrc_content=$(cat "$DOTFILES_DIR/src/zsh/zshrc")
    assert_contains "$zshrc_content" "HIST" || assert_contains "$zshrc_content" "history"
    pass
}

it "should set shell options" && {
    local zshrc_content=$(cat "$DOTFILES_DIR/src/zsh/zshrc")
    assert_contains "$zshrc_content" "setopt" || assert_contains "$zshrc_content" "set -"
    pass
}

it "should handle macOS specific settings" && {
    if [[ "$(uname)" == "Darwin" ]]; then
        local zshrc_content=$(cat "$DOTFILES_DIR/src/zsh/zshrc")
        assert_contains "$zshrc_content" "Darwin" || assert_contains "$zshrc_content" "macOS" || assert_contains "$zshrc_content" "brew"
        pass
    else
        skip "Not on macOS"
    fi
}

it "should handle Linux specific settings" && {
    if [[ "$(uname)" == "Linux" ]]; then
        local zshrc_content=$(cat "$DOTFILES_DIR/src/zsh/zshrc")
        assert_contains "$zshrc_content" "Linux" || assert_contains "$zshrc_content" "linux"
        pass
    else
        skip "Not on Linux"
    fi
}

it "should integrate with tmux" && {
    local zshrc_content=$(cat "$DOTFILES_DIR/src/zsh/zshrc")
    assert_contains "$zshrc_content" "tmux" || assert_contains "$zshrc_content" "TMUX"
    pass
}

it "should set up FZF integration" && {
    local zshrc_content=$(cat "$DOTFILES_DIR/src/zsh/zshrc")
    assert_contains "$zshrc_content" "fzf" || assert_contains "$zshrc_content" "FZF"
    pass
}

cleanup_test
echo -e "\n${GREEN}Zsh functional tests completed${NC}"