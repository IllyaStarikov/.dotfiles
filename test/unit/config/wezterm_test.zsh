#!/usr/bin/env zsh
# Test: WezTerm configuration

test_case "wezterm.lua exists"
if [[ -f "$DOTFILES_DIR/src/wezterm/wezterm.lua" ]]; then
  pass
else
  fail "wezterm.lua not found"
fi

test_case "wezterm.lua has valid Lua syntax"
if command -v luac >/dev/null 2>&1; then
  if luac -p "$DOTFILES_DIR/src/wezterm/wezterm.lua" 2>/dev/null; then
    pass
  else
    fail "wezterm.lua has Lua syntax errors"
  fi
else
  skip "luac not available"
fi

test_case "wezterm-minimal.lua exists"
if [[ -f "$DOTFILES_DIR/src/wezterm/wezterm-minimal.lua" ]]; then
  pass
else
  fail "wezterm-minimal.lua not found"
fi

test_case "wezterm-minimal.lua has valid Lua syntax"
if command -v luac >/dev/null 2>&1; then
  if luac -p "$DOTFILES_DIR/src/wezterm/wezterm-minimal.lua" 2>/dev/null; then
    pass
  else
    fail "wezterm-minimal.lua has Lua syntax errors"
  fi
else
  skip "luac not available"
fi

test_case "Minimal config is smaller than main config"
local main_lines=$(wc -l < "$DOTFILES_DIR/src/wezterm/wezterm.lua")
local minimal_lines=$(wc -l < "$DOTFILES_DIR/src/wezterm/wezterm-minimal.lua")
if [[ $minimal_lines -lt $main_lines ]]; then
  pass
else
  fail "Minimal config ($minimal_lines lines) should be smaller than main ($main_lines lines)"
fi

test_case "JetBrainsMono font is configured"
if grep -q "JetBrainsMono" "$DOTFILES_DIR/src/wezterm/wezterm.lua" 2>/dev/null; then
  pass
else
  fail "Should use JetBrainsMono font"
fi

test_case "Theme loading is configured"
if grep -q "theme" "$DOTFILES_DIR/src/wezterm/wezterm.lua" 2>/dev/null; then
  pass
else
  fail "Should have theme support"
fi

test_case "Key bindings are configured"
if grep -q "config.keys" "$DOTFILES_DIR/src/wezterm/wezterm.lua" 2>/dev/null; then
  pass
else
  fail "Should have key bindings"
fi

test_case "README exists and documents WezTerm"
if [[ -f "$DOTFILES_DIR/src/wezterm/README.md" ]] \
  && grep -q "WezTerm" "$DOTFILES_DIR/src/wezterm/README.md" 2>/dev/null; then
  pass
else
  fail "README should exist and document WezTerm"
fi

test_case "TokyoNight WezTerm theme variants exist"
local themes_dir="$DOTFILES_DIR/src/theme/tokyonight"
local missing=()
for variant in day night moon storm; do
  if [[ ! -f "$themes_dir/$variant/wezterm.lua" ]]; then
    missing+=("$variant")
  fi
done
if [[ ${#missing[@]} -eq 0 ]]; then
  pass
else
  fail "Missing WezTerm themes: ${missing[*]}"
fi

test_case "WezTerm theme files have valid Lua syntax"
if command -v luac >/dev/null 2>&1; then
  local bad=()
  for theme_file in "$DOTFILES_DIR"/src/theme/tokyonight/*/wezterm.lua; do
    if [[ -f "$theme_file" ]] && ! luac -p "$theme_file" 2>/dev/null; then
      bad+=("$(basename "$(dirname "$theme_file")")")
    fi
  done
  if [[ ${#bad[@]} -eq 0 ]]; then
    pass
  else
    fail "Syntax errors in themes: ${bad[*]}"
  fi
else
  skip "luac not available"
fi

test_case "All WezTerm Lua files have valid syntax"
if command -v luac >/dev/null 2>&1; then
  local bad=()
  for lua_file in "$DOTFILES_DIR"/src/wezterm/*.lua; do
    if [[ -f "$lua_file" ]] && ! luac -p "$lua_file" 2>/dev/null; then
      bad+=("$(basename "$lua_file")")
    fi
  done
  if [[ ${#bad[@]} -eq 0 ]]; then
    pass
  else
    fail "Syntax errors in: ${bad[*]}"
  fi
else
  skip "luac not available"
fi

exit 0
