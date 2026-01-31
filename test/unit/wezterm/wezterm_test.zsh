#!/usr/bin/env zsh
# Unit tests for WezTerm configuration

# Get the test directory path
TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

# Test framework
source "${TEST_DIR}/lib/test_helpers.zsh"

# Test WezTerm configuration exists
test_wezterm_config_exists() {
  local wezterm_conf="${DOTFILES_DIR}/src/wezterm/wezterm.lua"

  assert_file_exists "$wezterm_conf" "WezTerm configuration should exist"

  # Check for Lua configuration structure
  assert_file_contains "$wezterm_conf" "wezterm" "Should reference wezterm module"
  assert_file_contains "$wezterm_conf" "config" "Should have config setup"
}

# Test WezTerm font configuration
test_wezterm_font_config() {
  local wezterm_conf="${DOTFILES_DIR}/src/wezterm/wezterm.lua"

  # Check font settings match other terminals
  assert_file_contains "$wezterm_conf" "font" "Font should be configured"
  assert_file_contains "$wezterm_conf" "font_size" "Font size should be configured"

  # Verify JetBrains Mono is used (consistency)
  assert_file_contains "$wezterm_conf" "JetBrainsMono" "Should use JetBrains Mono font"
}

# Test WezTerm theme integration
test_wezterm_theme_support() {
  local theme_lua="${DOTFILES_DIR}/src/wezterm/theme.lua"

  # Theme file might be generated, but check for theme support
  local wezterm_conf="${DOTFILES_DIR}/src/wezterm/wezterm.lua"

  # Check for theme loading mechanism
  if ! grep -q "theme" "$wezterm_conf" 2>/dev/null; then
    fail "WezTerm should have theme support"
  fi
}

# Test WezTerm minimal config exists
test_wezterm_minimal_config() {
  local minimal="${DOTFILES_DIR}/src/wezterm/wezterm-minimal.lua"

  assert_file_exists "$minimal" "Minimal WezTerm config should exist"

  # Minimal config should be simpler than main
  local main_lines=$(wc -l <"${DOTFILES_DIR}/src/wezterm/wezterm.lua")
  local minimal_lines=$(wc -l <"$minimal")

  if [[ $minimal_lines -ge $main_lines ]]; then
    fail "Minimal config should be smaller than main config"
  fi
}

# Test WezTerm Lua syntax
test_wezterm_lua_syntax() {
  local wezterm_conf="${DOTFILES_DIR}/src/wezterm/wezterm.lua"

  # Basic Lua syntax check using luac if available
  if command -v luac >/dev/null 2>&1; then
    if ! luac -p "$wezterm_conf" 2>/dev/null; then
      fail "WezTerm configuration has Lua syntax errors"
    fi
  else
    # Fallback: check for basic Lua structure
    assert_file_contains "$wezterm_conf" "return" "Lua config should return configuration"
  fi
}

# Test WezTerm documentation
test_wezterm_readme() {
  local readme="${DOTFILES_DIR}/src/wezterm/README.md"

  assert_file_exists "$readme" "WezTerm README should exist"
  assert_file_contains "$readme" "WezTerm" "README should document WezTerm"
  assert_file_contains "$readme" "Configuration" "README should explain configuration"
}

# Test WezTerm template configuration
test_wezterm_template_exists() {
  local template="${DOTFILES_DIR}/src/wezterm/wezterm-template.lua"

  assert_file_exists "$template" "WezTerm template should exist"

  # Template should have placeholder for theme
  if ! grep -q "theme\|Theme\|THEME" "$template" 2>/dev/null; then
    fail "Template should reference theme"
  fi
}

# Test WezTerm theme files exist
test_wezterm_themes_exist() {
  local themes_dir="${DOTFILES_DIR}/src/theme"

  assert_directory_exists "$themes_dir" "Themes directory should exist"

  # Check for TokyoNight variants
  local themes=("tokyonight_day.lua" "tokyonight_night.lua" "tokyonight_moon.lua" "tokyonight_storm.lua")
  for theme in "${themes[@]}"; do
    if [[ ! -f "${themes_dir}/${theme}" ]]; then
      fail "Missing theme: $theme"
    fi
  done
}

# Test WezTerm theme files have valid syntax
test_wezterm_theme_syntax() {
  local themes_dir="${DOTFILES_DIR}/src/theme"

  if [[ ! -d "$themes_dir" ]]; then
    fail "Themes directory missing"
    return
  fi

  if command -v luac >/dev/null 2>&1; then
    for theme_file in "$themes_dir"/*.lua; do
      if [[ -f "$theme_file" ]]; then
        if ! luac -p "$theme_file" 2>/dev/null; then
          fail "Theme has Lua syntax errors: $(basename $theme_file)"
        fi
      fi
    done
  fi
}

# Test WezTerm theme files return tables
test_wezterm_theme_structure() {
  local themes_dir="${DOTFILES_DIR}/src/theme"

  for theme_file in "$themes_dir"/*.lua; do
    if [[ -f "$theme_file" ]]; then
      # Check for return statement with colors
      if ! grep -q "return" "$theme_file" 2>/dev/null; then
        fail "Theme should return configuration: $(basename $theme_file)"
      fi
      if ! grep -q "colors\|Colors" "$theme_file" 2>/dev/null; then
        fail "Theme should define colors: $(basename $theme_file)"
      fi
    fi
  done
}

# Test WezTerm keybindings are configured
test_wezterm_keybindings() {
  local wezterm_conf="${DOTFILES_DIR}/src/wezterm/wezterm.lua"

  # Check for key bindings
  if ! grep -q "keys\|Keys\|key_tables\|SendKey" "$wezterm_conf" 2>/dev/null; then
    fail "WezTerm should have key bindings configured"
  fi
}

# Test WezTerm window configuration
test_wezterm_window_config() {
  local wezterm_conf="${DOTFILES_DIR}/src/wezterm/wezterm.lua"

  # Check for window settings
  window_settings=("window_decorations" "window_padding" "window_background_opacity")
  local found=0
  for setting in "${window_settings[@]}"; do
    if grep -q "$setting" "$wezterm_conf" 2>/dev/null; then
      ((found++))
    fi
  done

  if [[ $found -lt 2 ]]; then
    fail "WezTerm should have window configuration"
  fi
}

# Test all Lua files have valid syntax
test_wezterm_all_lua_syntax() {
  local wezterm_dir="${DOTFILES_DIR}/src/wezterm"

  if command -v luac >/dev/null 2>&1; then
    for lua_file in "$wezterm_dir"/*.lua; do
      if [[ -f "$lua_file" ]]; then
        if ! luac -p "$lua_file" 2>/dev/null; then
          fail "Lua syntax error in: $(basename $lua_file)"
        fi
      fi
    done
  fi
}

# Run all tests
test_suite "WezTerm Configuration" \
  test_wezterm_config_exists \
  test_wezterm_font_config \
  test_wezterm_theme_support \
  test_wezterm_minimal_config \
  test_wezterm_lua_syntax \
  test_wezterm_readme \
  test_wezterm_template_exists \
  test_wezterm_themes_exist \
  test_wezterm_theme_syntax \
  test_wezterm_theme_structure \
  test_wezterm_keybindings \
  test_wezterm_window_config \
  test_wezterm_all_lua_syntax
