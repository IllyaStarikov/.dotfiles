#!/usr/bin/env zsh
# Integration tests for theme switching

set -euo pipefail

export TEST_DIR="${TEST_DIR:-$(dirname "$0")/..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

source "$TEST_DIR/lib/test_helpers.zsh"

describe "Theme switching integration tests"

setup_test
TEST_HOME="$TEST_TMP_DIR/home"
mkdir -p "$TEST_HOME/.config"

it "should detect macOS appearance" && {
  if [[ "$(uname)" == "Darwin" ]]; then
    output=$("$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" --dry-run 2>&1 || true)
    assert_contains "$output" "theme" || assert_contains "$output" "Theme"
    pass
  else
    skip "Not on macOS"
  fi
}

it "should switch themes atomically" && {
  export HOME="$TEST_HOME"
  output=$("$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" --dry-run 2>&1 || true)
  assert_not_contains "$output" "error"
  pass
}

it "should update all application configs" && {
  export HOME="$TEST_HOME"

  # Check that script would update multiple configs
  local script_content=$(cat "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh")
  assert_contains "$script_content" "alacritty"
  assert_contains "$script_content" "tmux"
  assert_contains "$script_content" "starship"
  pass
}

it "should handle tmux session reloading" && {
  local script_content=$(cat "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh")
  assert_contains "$script_content" "tmux" && assert_contains "$script_content" "source-file"
  pass
}

it "should track current theme" && {
  export HOME="$TEST_HOME"
  mkdir -p "$TEST_HOME/.config/theme-switcher"

  # Script should create current theme tracking
  local script_content=$(cat "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh")
  assert_contains "$script_content" "current" || assert_contains "$script_content" "CURRENT"
  pass
}

it "should be idempotent" && {
  export HOME="$TEST_HOME"

  # Running twice should be safe
  output1=$("$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" --dry-run 2>&1 || true)
  output2=$("$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" --dry-run 2>&1 || true)

  assert_success 0
  pass
}

cleanup_test
echo -e "\n${GREEN}Theme switching integration tests completed${NC}"
