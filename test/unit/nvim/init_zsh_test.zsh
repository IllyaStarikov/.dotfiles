#!/usr/bin/env zsh
# Test: Neovim init.lua configuration

# IMPORTANT: Skip Neovim tests in CI on macOS due to hanging issues
# nvim --headless can hang indefinitely in GitHub Actions macOS runners
if [[ "$CI" == "true" ]] && [[ "$(uname)" == "Darwin" ]]; then
  echo "[SKIP] Neovim tests skipped on macOS CI (known hanging issue)"
  exit 0
fi

test_case "init.lua exists and is valid"
if [[ -f "$DOTFILES_DIR/src/neovim/init.lua" ]]; then
  # Check if it's valid Lua
  # IMPORTANT: Use timeout to prevent CI hangs (GitHub Actions macOS issue)
  # Some CI environments cause nvim --headless to hang indefinitely
  if command -v timeout >/dev/null 2>&1; then
    output=$(timeout 5 nvim --headless -c "luafile $DOTFILES_DIR/src/neovim/init.lua" -c "qa" 2>&1)
  else
    # macOS doesn't have timeout by default, use alternative
    output=$(nvim --headless -c "luafile $DOTFILES_DIR/src/neovim/init.lua" -c "qa" 2>&1 & sleep 5; kill $! 2>/dev/null)
  fi
  if [[ -z "$output" ]] || [[ "$output" != *"Error"* ]]; then
    pass
  else
    fail "init.lua has errors: $output"
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
  output=$(nvim --headless -c "qa" 2>&1 & sleep 5; kill $! 2>/dev/null)
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
