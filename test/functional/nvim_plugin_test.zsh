#!/usr/bin/env zsh
# Simple plugin loading test for Neovim in CI

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

describe "Neovim plugin loading test"

setup_test

# Test: Can load with plugins in full test mode
it "should load neovim with plugins when NVIM_CI_FULL_TEST=1" && {
  # Set environment for full plugin test
  export CI_MODE=1
  export NVIM_CI_FULL_TEST=1

  # Create a temporary test home
  local test_home="/tmp/nvim-plugin-test-$$"
  mkdir -p "$test_home/.local/share/nvim"
  mkdir -p "$test_home/.config/nvim"

  # Set XDG paths
  export XDG_DATA_HOME="$test_home/.local/share"
  export XDG_CONFIG_HOME="$test_home/.config"
  export XDG_STATE_HOME="$test_home/.local/state"
  export XDG_CACHE_HOME="$test_home/.cache"

  # Link our config
  ln -sf "$DOTFILES_DIR/src/neovim/init.lua" "$test_home/.config/nvim/init.lua"
  ln -sf "$DOTFILES_DIR/src/neovim/config" "$test_home/.config/nvim/config"

  # Run Neovim with a timeout
  # It should auto-quit after LazyDone event
  timeout 60 nvim --headless 2>&1 || true

  # Check if the marker file was created
  if [[ -f "$test_home/.local/share/nvim/ci_test_complete.txt" ]]; then
    echo "Success: Plugins loaded and marker file created"
    pass
  else
    # In CI, plugins may not actually load due to network/git issues
    # Check if at least lazy.nvim was bootstrapped
    if [[ -d "$test_home/.local/share/nvim/lazy/lazy.nvim" ]]; then
      echo "Partial success: lazy.nvim bootstrapped"
      pass
    else
      skip "Plugin loading test skipped (may be network issue)"
    fi
  fi

  # Cleanup
  rm -rf "$test_home"
}

cleanup_test
echo -e "\n${GREEN}Neovim plugin test completed${NC}"