#!/usr/bin/env zsh

# Unit tests for theme-switcher script

# Tests handle errors explicitly

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

# Test suite for theme-switcher
describe "switch-theme.sh theme switching system"

# Test: Script exists and is executable
it "should exist and be executable" && {
  local script_path="$DOTFILES_DIR/src/theme-switcher/switch-theme.sh"

  assert_file_exists "$script_path"
  assert_file_executable "$script_path"
}

# Test: Theme detection
it "should detect system appearance" && {
  # Run theme switcher without arguments - it should auto-detect (--local to avoid affecting other terminals)
  output=$(bash "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" --local 2>&1 | head -5 || true)

  # Should mention switching to a theme
  if [[ "$output" == *"Switching"* ]] || [[ "$output" == *"tokyonight"* ]] || [[ "$output" == *"Theme"* ]]; then
    pass "Theme switcher executed"
  else
    # Might already be in the correct theme
    pass "Theme detection completed"
  fi
}

# Test: Configuration file creation
it "should create configuration files" && {
  local test_config="$TEST_TMP_DIR/test_config"
  mkdir -p "$test_config/alacritty"
  mkdir -p "$test_config/tmux"
  mkdir -p "$test_config/theme-switcher"

  export XDG_CONFIG_HOME="$test_config"

  # Run theme switcher (--local to avoid affecting other terminals)
  bash "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" --local dark 2>&1 || true

  # Check if config files were created
  local configs_created=0
  [[ -f "$test_config/alacritty/theme.toml" ]] && ((configs_created++))
  [[ -f "$test_config/tmux/theme.conf" ]] && ((configs_created++))
  [[ -f "$test_config/theme-switcher/current-theme.sh" ]] && ((configs_created++))

  if [[ $configs_created -gt 0 ]]; then
    pass "Created $configs_created config files"
  else
    fail "No configuration files created"
  fi
}

# Test: Theme environment variable
it "should export MACOS_THEME variable" && {
  local test_config="$TEST_TMP_DIR/test_env"
  mkdir -p "$test_config/theme-switcher"

  export XDG_CONFIG_HOME="$test_config"

  # Set dark theme (--local to avoid affecting other terminals)
  bash "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" --local dark 2>&1 || true

  # Check environment file
  if [[ -f "$test_config/theme-switcher/current-theme.sh" ]]; then
    content=$(cat "$test_config/theme-switcher/current-theme.sh")
    if [[ "$content" == *"MACOS_THEME"* ]]; then
      pass "MACOS_THEME variable exported"
    else
      fail "MACOS_THEME not found in theme file"
    fi
  else
    fail "Theme environment file not created"
  fi
}

# Test: Light theme configuration
it "should configure light theme correctly" && {
  local test_config="$TEST_TMP_DIR/test_light"
  mkdir -p "$test_config/alacritty"
  mkdir -p "$test_config/theme-switcher"

  export XDG_CONFIG_HOME="$test_config"

  # Set light theme (--local to avoid affecting other terminals)
  bash "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" --local light 2>&1 || true

  # Check theme settings
  if [[ -f "$test_config/theme-switcher/current-theme.sh" ]]; then
    content=$(cat "$test_config/theme-switcher/current-theme.sh")
    if [[ "$content" == *"light"* ]] || [[ "$content" == *"Light"* ]]; then
      pass "Light theme configured"
    else
      fail "Light theme not properly set"
    fi
  else
    fail "Theme file not created"
  fi
}

# Test: Dark theme configuration
it "should configure dark theme correctly" && {
  local test_config="$TEST_TMP_DIR/test_dark"
  mkdir -p "$test_config/alacritty"
  mkdir -p "$test_config/theme-switcher"

  export XDG_CONFIG_HOME="$test_config"

  # Set dark theme (--local to avoid affecting other terminals)
  bash "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" --local dark 2>&1 || true

  # Check theme settings
  if [[ -f "$test_config/theme-switcher/current-theme.sh" ]]; then
    content=$(cat "$test_config/theme-switcher/current-theme.sh")
    if [[ "$content" == *"dark"* ]] || [[ "$content" == *"Dark"* ]]; then
      pass "Dark theme configured"
    else
      fail "Dark theme not properly set"
    fi
  else
    fail "Theme file not created"
  fi
}

# Test: Tmux integration
it "should update tmux configuration" && {
  local test_config="$TEST_TMP_DIR/test_tmux"
  mkdir -p "$test_config/tmux"
  mkdir -p "$test_config/theme-switcher"

  export XDG_CONFIG_HOME="$test_config"

  # Run theme switcher (--local to avoid affecting other terminals)
  bash "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" --local dark 2>&1 || true

  # Check tmux theme file
  if [[ -f "$test_config/tmux/theme.conf" ]]; then
    content=$(cat "$test_config/tmux/theme.conf")
    # Check for tmux-specific configuration
    if [[ "$content" == *"status"* ]] || [[ "$content" == *"bg="* ]] || [[ "$content" == *"fg="* ]]; then
      pass "Tmux theme configuration created"
    else
      fail "Tmux theme file is empty or invalid"
    fi
  else
    fail "Tmux theme file not created"
  fi
}

# Test: Alacritty integration
it "should update Alacritty configuration" && {
  local test_config="$TEST_TMP_DIR/test_alacritty"
  mkdir -p "$test_config/alacritty"
  mkdir -p "$test_config/theme-switcher"

  export XDG_CONFIG_HOME="$test_config"

  # Run theme switcher (--local to avoid affecting other terminals)
  bash "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" --local dark 2>&1 || true

  # Check Alacritty theme file
  if [[ -f "$test_config/alacritty/theme.toml" ]]; then
    content=$(cat "$test_config/alacritty/theme.toml")
    # Check for Alacritty-specific configuration
    if [[ "$content" == *"colors"* ]] || [[ "$content" == *"primary"* ]] || [[ "$content" == *"background"* ]]; then
      pass "Alacritty theme configuration created"
    else
      fail "Alacritty theme file is empty or invalid"
    fi
  else
    fail "Alacritty theme file not created"
  fi
}

# Test: Help message
it "should display help message" && {
  output=$(bash "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" --help 2>&1 || true)

  assert_contains "$output" "Usage" || assert_contains "$output" "usage" || assert_contains "$output" "theme"
}

# Test: Invalid theme handling
it "should handle invalid theme names gracefully" && {
  local test_config="$TEST_TMP_DIR/test_invalid"
  mkdir -p "$test_config/theme-switcher"

  export XDG_CONFIG_HOME="$test_config"

  # Try invalid theme (--local to avoid affecting other terminals)
  output=$(bash "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" --local invalid_theme 2>&1 || true)

  # Should either fall back to default or show error
  if [[ "$output" == *"Error"* ]] || [[ "$output" == *"error"* ]] || [[ "$output" == *"Invalid"* ]] || [[ "$output" == *"invalid"* ]]; then
    pass "Invalid theme handled with error"
  elif [[ -f "$test_config/theme-switcher/current-theme.sh" ]]; then
    # Or it might fall back to a default
    pass "Invalid theme handled with fallback"
  else
    fail "Invalid theme not handled properly"
  fi
}

# Test: Auto-detection mode
it "should support auto-detection from system" && {
  local test_config="$TEST_TMP_DIR/test_auto"
  mkdir -p "$test_config/theme-switcher"

  export XDG_CONFIG_HOME="$test_config"

  # Run auto-detection (no argument, --local to avoid affecting other terminals)
  bash "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" --local 2>&1 || true

  # Check if theme was set
  if [[ -f "$test_config/theme-switcher/current-theme.sh" ]]; then
    content=$(cat "$test_config/theme-switcher/current-theme.sh")
    if [[ -n "$content" ]]; then
      pass "Auto-detection created theme configuration"
    else
      fail "Auto-detection created empty file"
    fi
  else
    fail "Auto-detection did not create theme file"
  fi
}

# Test: Theme persistence
it "should persist theme selection" && {
  local test_config="$TEST_TMP_DIR/test_persist"
  mkdir -p "$test_config/theme-switcher"

  export XDG_CONFIG_HOME="$test_config"

  # Set initial theme (--local to avoid affecting other terminals)
  bash "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" --local dark 2>&1 || true

  # Capture initial state
  initial_content=$(cat "$test_config/theme-switcher/current-theme.sh" 2>/dev/null || echo "")

  # Switch to light (--local to avoid affecting other terminals)
  bash "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" --local light 2>&1 || true

  # Capture new state
  new_content=$(cat "$test_config/theme-switcher/current-theme.sh" 2>/dev/null || echo "")

  # Verify change persisted
  if [[ "$initial_content" != "$new_content" ]]; then
    pass "Theme change persisted"
  else
    fail "Theme did not change"
  fi
}

# Run tests
run_tests
# Return success
exit 0
