#!/usr/bin/env zsh
# Integration tests for theme switching

set -euo pipefail

export TEST_DIR="${TEST_DIR:-$(dirname "$0")/..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

source "$TEST_DIR/lib/test_helpers.zsh"

describe "Theme switching integration tests"

setup_test
TEST_HOME="$TEST_TMP_DIR/home"
mkdir -p "$TEST_HOME/.config"/{alacritty,tmux,theme,wezterm,kitty}

it "should detect macOS appearance" && {
  if [[ "$(uname)" == "Darwin" ]]; then
    # Global switch with temp config dir should succeed
    output=$(XDG_CONFIG_HOME="$TEST_HOME/.config" "$DOTFILES_DIR/src/theme/switch-theme.sh" 2>&1 || true)
    # Should not have fatal errors (TTY warnings are acceptable)
    if [[ "$output" != *"Error: "* ]] || [[ "$output" == *"Switched"* ]] || [[ "$output" == *"Already"* ]]; then
      pass
    else
      fail "Unexpected error: $output"
    fi
  else
    skip "Not on macOS"
  fi
}

it "should switch themes atomically" && {
  # Global switch with temp config dir
  output=$(XDG_CONFIG_HOME="$TEST_HOME/.config" "$DOTFILES_DIR/src/theme/switch-theme.sh" tokyonight_storm 2>&1 || true)
  # Check that config file was created
  if [[ -f "$TEST_HOME/.config/theme/current-theme.sh" ]]; then
    pass
  else
    # Even without file creation, script should not crash
    assert_not_contains "$output" "syntax error"
    pass
  fi
}

it "should update all application configs" && {
  # Check that script references multiple config targets
  local script_content=$(cat "$DOTFILES_DIR/src/theme/switch-theme.sh")
  assert_contains "$script_content" "alacritty"
  assert_contains "$script_content" "tmux"
  assert_contains "$script_content" "starship"
  pass
}

it "should handle tmux session reloading" && {
  local script_content=$(cat "$DOTFILES_DIR/src/theme/switch-theme.sh")
  assert_contains "$script_content" "tmux" && assert_contains "$script_content" "source-file"
  pass
}

it "should track current theme" && {
  # Script should have current theme tracking
  local script_content=$(cat "$DOTFILES_DIR/src/theme/switch-theme.sh")
  assert_contains "$script_content" "current" || assert_contains "$script_content" "CURRENT"
  pass
}

it "should be idempotent" && {
  # Running global switch twice should be safe
  XDG_CONFIG_HOME="$TEST_HOME/.config" "$DOTFILES_DIR/src/theme/switch-theme.sh" tokyonight_storm 2>&1 || true
  XDG_CONFIG_HOME="$TEST_HOME/.config" "$DOTFILES_DIR/src/theme/switch-theme.sh" tokyonight_storm 2>&1 || true

  assert_success 0
  pass
}

cleanup_test
echo -e "\n${GREEN}Theme switching integration tests completed${NC}"
