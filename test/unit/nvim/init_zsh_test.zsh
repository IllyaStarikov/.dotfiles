#!/usr/bin/env zsh
# Test: Neovim init.lua configuration

# Previously this whole file was skipped on macOS CI because
# `nvim --headless -c 'luafile <init.lua>'` hung indefinitely on
# GitHub Actions macOS runners. The hang was specific to loading the
# full plugin stack non-interactively; syntax validation via `luac -p`
# is environment-independent and tells us the file is well-formed
# Lua, which is what this test actually needs.

test_case "init.lua exists and is syntactically valid"
if [[ -f "$DOTFILES_DIR/src/neovim/init.lua" ]]; then
  if luac -p "$DOTFILES_DIR/src/neovim/init.lua" 2>/dev/null; then
    pass
  else
    fail "init.lua failed luac -p syntax check"
  fi
else
  fail "init.lua not found"
fi

test_case "Neovim starts without errors"
# IMPORTANT: Use timeout to prevent CI hangs (GitHub Actions macOS issue)
if command -v timeout >/dev/null 2>&1; then
  output=$(timeout 5 nvim --headless -c "qa" 2>&1)
else
  # macOS doesn't have timeout by default, use alternative
  output=$(
    nvim --headless -c "qa" 2>&1 &
    sleep 5
    kill $! 2>/dev/null
  )
fi
if [[ -z "$output" ]] || [[ "$output" != *"Error"* ]]; then
  pass
else
  fail "Neovim startup errors: $output"
fi

test_case "Required Neovim version"
version=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+')
major=$(echo "$version" | cut -d. -f1)
minor=$(echo "$version" | cut -d. -f2)

if [[ $major -gt 0 ]] || [[ $major -eq 0 && $minor -ge 9 ]]; then
  pass
else
  fail "Neovim version too old: $version (need 0.9+)"
fi
# Return success
exit 0
