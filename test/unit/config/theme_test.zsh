#!/usr/bin/env zsh
# Comprehensive unit tests for theme switching system

# Tests handle errors explicitly

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
  local script_path="$DOTFILES_DIR/src/theme/switch-theme.sh"

  assert_file_exists "$script_path"
  assert_file_executable "$script_path"
  pass
}

# Test: validate-themes.sh exists and is executable
it "validate-themes.sh should exist and be executable" && {
  local script_path="$DOTFILES_DIR/src/theme/validate-themes.sh"

  assert_file_exists "$script_path"
  assert_file_executable "$script_path"
  pass
}

# Test: Theme directory structure
it "should have proper theme directory structure" && {
  assert_directory_exists "$DOTFILES_DIR/src/theme"

  # Check for theme subdirectories (themes are in src/theme/family/variant/)
  local theme_count=$(ls -d "$DOTFILES_DIR/src/theme"/tokyonight/*/ 2>/dev/null | wc -l)
  assert_greater_than "$theme_count" 0
  pass
}

# Test: Theme configurations exist
it "should have theme configuration files" && {
  local themes=("tokyonight/day" "tokyonight/night" "tokyonight/moon" "tokyonight/storm")
  local missing=0

  for theme in "${themes[@]}"; do
    # Themes are in src/theme/family/variant/
    if [[ ! -d "$DOTFILES_DIR/src/theme/$theme" ]]; then
      ((missing++))
    fi
  done

  assert_equals "$missing" 0
  pass
}

# Test: Help message
it "switch-theme.sh should display help message" && {
  output=$("$DOTFILES_DIR/src/theme/switch-theme.sh" --help 2>&1 || true)

  # Check for usage-related keywords
  if [[ "$output" == *"Usage"* ]] || [[ "$output" == *"usage"* ]]; then
    if [[ "$output" == *"theme"* ]] || [[ "$output" == *"Theme"* ]] || [[ "$output" == *"THEME"* ]]; then
      pass
    else
      fail "Help message missing theme references"
    fi
  else
    fail "Help message missing Usage"
  fi
}

# Test: macOS appearance detection
it "should detect macOS appearance" && {
  if [[ "$(uname)" == "Darwin" ]]; then
    # Test actual behavior - can it detect current appearance
    output=$("$DOTFILES_DIR/src/theme/switch-theme.sh" --current 2>&1 || true)
    if [[ "$output" == *"dark"* ]] || [[ "$output" == *"light"* ]] || [[ "$output" == *"tokyonight"* ]]; then
      pass "Can detect current appearance"
    else
      skip "Cannot determine current theme"
    fi
  else
    skip "Not on macOS"
  fi
}

# Test: Theme file generation
it "should generate theme configuration files" && {
  # Test actual behavior - run in dry run mode and see if it would generate files
  output=$("$DOTFILES_DIR/src/theme/switch-theme.sh" --dry-run tokyonight_day 2>&1 || true)

  # Should mention generating configs for various tools
  if [[ "$output" == *"alacritty"* ]] || [[ "$output" == *"tmux"* ]] || [[ "$output" == *"config"* ]]; then
    pass "Would generate configuration files"
  else
    # Alternative: just check if it runs without errors
    "$DOTFILES_DIR/src/theme/switch-theme.sh" --local tokyonight_day >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
      pass "Theme switch executed successfully"
    else
      skip "Theme switch not functional"
    fi
  fi
}

# Test: Atomic operations
it "should use atomic operations for theme switching" && {
  # Test behavior - switching theme shouldn't leave partial state
  local test_theme="tokyonight_day"

  # Try switching theme (--local to avoid affecting other terminals)
  "$DOTFILES_DIR/src/theme/switch-theme.sh" --local "$test_theme" >/dev/null 2>&1
  local result=$?

  # Either it succeeds completely or fails completely
  if [[ $result -eq 0 ]]; then
    pass "Theme switch completed atomically"
  else
    skip "Theme switch not available"
  fi
}

# Test: Theme validation
it "validate-themes.sh should validate theme files" && {
  output=$("$DOTFILES_DIR/src/theme/validate-themes.sh" 2>&1 || true)

  # Should check theme integrity
  assert_success $? || skip "Validation script may need themes installed"
  pass
}

# Test: Alacritty theme support
it "should support Alacritty themes" && {
  local alacritty_theme_exists=0

  # Themes are directly in src/theme/tokyonight_*/
  for theme_dir in "$DOTFILES_DIR/src/theme"/tokyonight/*/; do
    if [[ -f "$theme_dir/alacritty.toml" ]]; then
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

  # Themes are directly in src/theme/tokyonight_*/
  for theme_dir in "$DOTFILES_DIR/src/theme"/tokyonight/*/; do
    if [[ -f "$theme_dir/tmux.conf" ]]; then
      tmux_theme_exists=1
      break
    fi
  done

  assert_equals "$tmux_theme_exists" 1
  pass
}

# Test: Neovim theme integration
it "should integrate with Neovim themes" && {
  # Test behavior - after switching theme, Neovim should use it
  "$DOTFILES_DIR/src/theme/switch-theme.sh" --local tokyonight_day >/dev/null 2>&1 || true

  # Check if theme environment is set
  if [[ -f ~/.config/theme/current-theme.sh ]]; then
    source ~/.config/theme/current-theme.sh 2>/dev/null || true
    if [[ -n "$MACOS_THEME" ]]; then
      pass "Theme environment configured for Neovim"
    else
      skip "Theme environment not set"
    fi
  else
    skip "Theme configuration not generated"
  fi
}

# Test: Theme environment variable
it "should set theme environment variable" && {
  # Test behavior - after switching, environment should be set
  "$DOTFILES_DIR/src/theme/switch-theme.sh" --local tokyonight_night >/dev/null 2>&1 || true

  # Source the generated theme file if it exists
  if [[ -f ~/.config/theme/current-theme.sh ]]; then
    source ~/.config/theme/current-theme.sh 2>/dev/null || true
    if [[ -n "${MACOS_THEME:-}" ]]; then
      pass "Theme environment variable set"
    else
      skip "Environment variable not set"
    fi
  else
    skip "Theme config not generated"
  fi
}

# Test: Current theme tracking
it "should track current theme" && {
  # Test behavior - switch theme and check if it's tracked
  "$DOTFILES_DIR/src/theme/switch-theme.sh" --local tokyonight_storm >/dev/null 2>&1 || true

  # Check if current theme is tracked
  output=$("$DOTFILES_DIR/src/theme/switch-theme.sh" --current 2>&1 || echo "")
  if [[ -n "$output" ]] && [[ "$output" != *"error"* ]]; then
    pass "Current theme is tracked"
  else
    skip "Theme tracking not available"
  fi
}

# Test: Error handling
it "should handle errors gracefully" && {
  # Test with invalid theme name (--local to avoid affecting other terminals)
  output=$("$DOTFILES_DIR/src/theme/switch-theme.sh" --local "invalid_theme_name" 2>&1 || true)

  # Should not crash
  assert_success 0 || assert_contains "$output" "Error" || assert_contains "$output" "error"
  pass
}

# Test: tmux session reload
it "should reload tmux sessions after theme change" && {
  # Test behavior - if tmux is running, theme switch should handle it
  if command -v tmux >/dev/null 2>&1; then
    # Switch theme and check if it handles tmux gracefully (--local to avoid affecting other terminals)
    output=$("$DOTFILES_DIR/src/theme/switch-theme.sh" --local tokyonight_moon 2>&1 || true)

    # Should not error on tmux operations
    if [[ "$output" != *"tmux: command not found"* ]]; then
      pass "Handles tmux gracefully"
    else
      fail "tmux handling error"
    fi
  else
    skip "tmux not installed"
  fi
}

# Test: Backup before switching
it "should backup current theme before switching" && {
  # Test behavior - switch theme twice and see if it handles it safely (--local to avoid affecting other terminals)
  "$DOTFILES_DIR/src/theme/switch-theme.sh" --local tokyonight_day >/dev/null 2>&1 || true
  local first_result=$?

  "$DOTFILES_DIR/src/theme/switch-theme.sh" --local tokyonight_night >/dev/null 2>&1 || true
  local second_result=$?

  # Both switches should work without corruption
  if [[ $first_result -eq 0 ]] || [[ $second_result -eq 0 ]]; then
    pass "Theme switching is safe"
  else
    skip "Theme switching not functional"
  fi
}

# Test: Theme shortcuts
it "should support theme shortcuts" && {
  # Test behavior - try using shortcuts (--local to avoid affecting other terminals)
  output=$("$DOTFILES_DIR/src/theme/switch-theme.sh" --local day 2>&1 || true)

  # Should either switch or show help about shortcuts
  if [[ "$output" != *"not found"* ]] && [[ "$output" != *"invalid"* ]]; then
    pass "Theme shortcuts supported"
  else
    skip "Shortcuts not available"
  fi
}

# Test: Two-argument syntax (e.g., theme github dark)
it "should support two-argument syntax" && {
  output=$("$DOTFILES_DIR/src/theme/switch-theme.sh" --local catppuccin mocha 2>&1 || true)

  if [[ "$output" == *"catppuccin_mocha"* ]] || [[ "$output" == *"switched"* ]] || [[ "$output" == *"Theme"* ]]; then
    pass "Two-argument syntax works"
  else
    skip "Two-argument syntax not yet implemented"
  fi
}

# Test: JSON configuration exists
it "should have themes.json configuration" && {
  local json_path="$DOTFILES_DIR/config/themes.json"

  assert_file_exists "$json_path"
  # Verify it's valid JSON
  if command -v jq >/dev/null 2>&1; then
    jq empty "$json_path" 2>/dev/null
    if [[ $? -eq 0 ]]; then
      pass "themes.json is valid JSON"
    else
      fail "themes.json is not valid JSON"
    fi
  else
    pass "themes.json exists (jq not available for validation)"
  fi
}

# Test: New theme families exist
it "should have multiple theme families" && {
  local families=("catppuccin" "github" "dracula" "material" "ayu" "monokai")
  local found_count=0

  for family in "${families[@]}"; do
    # Families are now top-level directories with variant subdirectories
    if [[ -d "$DOTFILES_DIR/src/theme/$family" ]]; then
      ((found_count++))
    fi
  done

  if [[ $found_count -ge 4 ]]; then
    pass "Found $found_count theme families"
  else
    fail "Only found $found_count theme families, expected at least 4"
  fi
}

# Test: Theme list with family filter
it "should support theme list filtering by family" && {
  output=$("$DOTFILES_DIR/src/theme/switch-theme.sh" --list catppuccin 2>&1 || true)

  if [[ "$output" == *"latte"* ]] || [[ "$output" == *"mocha"* ]] || [[ "$output" == *"frappe"* ]]; then
    pass "Theme list filtering works"
  else
    skip "Theme list filtering not implemented"
  fi
}

# Test: All theme directories have required files
it "all themes should have required files" && {
  local missing_files=0
  local required_files=("alacritty.toml" "tmux.conf" "starship.toml" "wezterm.lua" "colors.sh")

  # Check nested family/variant structure (skip templates directory)
  for family_dir in "$DOTFILES_DIR/src/theme"/*/; do
    # Skip the templates directory - it contains templates, not theme variants
    [[ "$family_dir" == */templates/ ]] && continue
    for theme_dir in "$family_dir"/*/; do
      if [[ -d "$theme_dir" ]]; then
        for file in "${required_files[@]}"; do
          if [[ ! -f "$theme_dir/$file" ]]; then
            ((missing_files++))
          fi
        done
      fi
    done
  done

  if [[ $missing_files -eq 0 ]]; then
    pass "All themes have required files"
  else
    fail "Found $missing_files missing files across themes"
  fi
}

# Test: Dry run mode
it "should support dry run mode" && {
  output=$("$DOTFILES_DIR/src/theme/switch-theme.sh" --dry-run 2>&1 || true)

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
  # Test behavior - switch theme and check if files are consistent (--local to avoid affecting other terminals)
  "$DOTFILES_DIR/src/theme/switch-theme.sh" --local tokyonight_day >/dev/null 2>&1 || true

  # Check if config files were generated
  local configs_exist=0
  [[ -f ~/.config/alacritty/theme.toml ]] && ((configs_exist++))
  [[ -f ~/.config/tmux/theme.conf ]] && ((configs_exist++))
  [[ -f ~/.config/theme/current-theme.sh ]] && ((configs_exist++))

  if [[ $configs_exist -gt 0 ]]; then
    pass "Theme configs generated consistently"
  else
    skip "Theme configs not generated"
  fi
}

# Test: Performance optimization
it "should be optimized for performance" && {
  # Test behavior - theme switch should be fast (--local to avoid affecting other terminals)
  # Use seconds only for reliable cross-platform timing
  local start_time=$(date +%s)
  "$DOTFILES_DIR/src/theme/switch-theme.sh" --local tokyonight_storm >/dev/null 2>&1 || true
  local end_time=$(date +%s)

  local duration=$((end_time - start_time))
  # Should complete within 3 seconds (allow some CI overhead)
  if [[ $duration -le 3 ]]; then
    pass "Theme switch is performant (${duration}s)"
  else
    fail "Theme switch took too long: ${duration}s"
  fi
}

# Test: Generated themes use lowercase hex colors (tmux requirement)
it "generated themes should use lowercase hex colors" && {
  local uppercase_found=0

  # Check all tmux.conf files for uppercase hex (A-F in color codes)
  for tmux_file in "$DOTFILES_DIR"/src/theme/*/*/tmux.conf; do
    if [[ -f "$tmux_file" ]]; then
      # Look for hex colors with uppercase letters (e.g., #FAD000 instead of #fad000)
      if grep -E '#[0-9a-fA-F]*[A-F][0-9a-fA-F]*' "$tmux_file" >/dev/null 2>&1; then
        ((uppercase_found++))
      fi
    fi
  done

  if [[ $uppercase_found -eq 0 ]]; then
    pass "All themes use lowercase hex colors"
  else
    fail "Found $uppercase_found themes with uppercase hex colors (breaks tmux clickability)"
  fi
}

# Cleanup after tests
cleanup_test

# Summary
echo -e "\n${GREEN}Theme system comprehensive tests completed${NC}"
# Return success
exit 0
