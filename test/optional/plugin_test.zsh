#!/usr/bin/env zsh
# Optional test for plugin installation
# Run this manually or in CI when you want to test full plugin setup
# Usage: ./test/optional/plugin_test.zsh

echo "Testing Neovim plugin installation..."

# Create temporary isolated environment
test_dir=$(mktemp -d)
export XDG_DATA_HOME="$test_dir/data"
export XDG_CONFIG_HOME="$test_dir/config"
export XDG_STATE_HOME="$test_dir/state"
export XDG_CACHE_HOME="$test_dir/cache"

# Link config
mkdir -p "$XDG_CONFIG_HOME/nvim"
ln -sf ~/.dotfiles/src/neovim/init.lua "$XDG_CONFIG_HOME/nvim/init.lua"
ln -sf ~/.dotfiles/src/neovim/config "$XDG_CONFIG_HOME/nvim/config"

echo "Installing plugins..."

# Install plugins using lazy.nvim's sync command
# The bang (!) makes it wait for completion
nvim --headless "+Lazy! sync" +qa

# Check if some key plugins were installed
if [[ -d "$XDG_DATA_HOME/nvim/lazy/lazy.nvim" ]]; then
  echo "✓ lazy.nvim installed"
else
  echo "✗ lazy.nvim not found"
  exit 1
fi

if [[ -d "$XDG_DATA_HOME/nvim/lazy/telescope.nvim" ]]; then
  echo "✓ telescope.nvim installed"
else
  echo "✗ telescope.nvim not found"
fi

# Test that nvim can start with plugins
nvim --headless \
  -c "lua print('Config loaded with plugins')" \
  -c "qa!" 2>&1 | grep -q "Config loaded with plugins"

if [[ $? -eq 0 ]]; then
  echo "✓ Neovim starts with plugins"
else
  echo "✗ Failed to start with plugins"
  exit 1
fi

# Cleanup
rm -rf "$test_dir"

echo "Plugin test completed successfully!"
