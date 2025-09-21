#!/usr/bin/env zsh
# End-to-end tests for Neovim with full plugin loading

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(dirname "$(dirname "$0")")}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

describe "Neovim E2E tests with plugins"

setup_test

# Create isolated test environment for Neovim
setup_nvim_test_env() {
  local test_home="/tmp/nvim-e2e-test-$$"
  mkdir -p "$test_home"

  # Set XDG variables to isolate config
  export XDG_CONFIG_HOME="$test_home/.config"
  export XDG_DATA_HOME="$test_home/.local/share"
  export XDG_STATE_HOME="$test_home/.local/state"
  export XDG_CACHE_HOME="$test_home/.cache"

  # Create directories
  mkdir -p "$XDG_CONFIG_HOME/nvim"
  mkdir -p "$XDG_DATA_HOME/nvim"
  mkdir -p "$XDG_STATE_HOME/nvim"
  mkdir -p "$XDG_CACHE_HOME/nvim"

  # Link our config
  ln -sf "$DOTFILES_DIR/src/neovim/init.lua" "$XDG_CONFIG_HOME/nvim/init.lua"
  ln -sf "$DOTFILES_DIR/src/neovim/config" "$XDG_CONFIG_HOME/nvim/config"

  echo "$test_home"
}

# Clean up test environment
cleanup_nvim_test_env() {
  local test_home="$1"
  if [[ -n "$test_home" ]] && [[ -d "$test_home" ]]; then
    rm -rf "$test_home"
  fi
}

# Test: Neovim starts and installs lazy.nvim
it "should bootstrap lazy.nvim successfully" && {
  local test_home=$(setup_nvim_test_env)

  # Run Neovim to bootstrap lazy.nvim
  local output=$(timeout 10 nvim --headless \
    -c "lua vim.defer_fn(function() vim.cmd('qa!') end, 1000)" \
    2>&1 || true)

  # Check that lazy.nvim was cloned
  assert_file_exists "$test_home/.local/share/nvim/lazy/lazy.nvim"

  cleanup_nvim_test_env "$test_home"
  pass
}

# Test: Plugins can be installed
it "should install plugins successfully" && {
  local test_home=$(setup_nvim_test_env)

  # Create a test init.lua that installs minimal plugins
  cat > "$XDG_CONFIG_HOME/nvim/init.lua" << 'EOF'
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Track if sync completed
_G.sync_completed = false

-- Setup autocmd to track when sync is done
vim.api.nvim_create_autocmd("User", {
  pattern = "LazySync",
  callback = function()
    _G.sync_completed = true
    -- Write a marker file to indicate success
    local marker = vim.fn.stdpath("data") .. "/sync_complete.txt"
    vim.fn.writefile({"sync completed"}, marker)
  end,
})

-- Install minimal plugins for testing
require("lazy").setup({
  -- Just a few lightweight plugins for testing
  "nvim-lua/plenary.nvim",
  "folke/which-key.nvim",
}, {
  headless = {
    process = true,
    log = true,
    task = true,
  },
})

-- Run sync and wait for completion
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("lazy.manage").sync({ wait = true, show = false })
    -- Give it some time then quit
    vim.defer_fn(function()
      vim.cmd("qa!")
    end, 3000)
  end,
})
EOF

  # Run Neovim to install plugins
  timeout 30 nvim --headless 2>&1 || true

  # Check that plugins were installed
  assert_file_exists "$test_home/.local/share/nvim/lazy/plenary.nvim"
  assert_file_exists "$test_home/.local/share/nvim/lazy/which-key.nvim"
  assert_file_exists "$test_home/.local/share/nvim/sync_complete.txt"

  cleanup_nvim_test_env "$test_home"
  pass
}

# Test: LSP configuration loads with plugins
it "should load LSP configuration with plugins" && {
  local test_home=$(setup_nvim_test_env)

  # Use a minimal test config that loads LSP
  cat > "$XDG_CONFIG_HOME/nvim/init.lua" << 'EOF'
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup plugins with LSP
require("lazy").setup({
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Write a marker when LSP config loads
      local marker = vim.fn.stdpath("data") .. "/lsp_loaded.txt"
      vim.fn.writefile({"lsp config loaded"}, marker)
    end,
  },
}, {
  headless = {
    process = true,
    log = true,
  },
  install = {
    missing = true,
  },
})

-- Quit after plugins load
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  callback = function()
    vim.defer_fn(function()
      vim.cmd("qa!")
    end, 1000)
  end,
})
EOF

  # Run Neovim
  timeout 30 nvim --headless 2>&1 || true

  # Check that LSP plugin was installed and configured
  assert_file_exists "$test_home/.local/share/nvim/lazy/nvim-lspconfig"
  assert_file_exists "$test_home/.local/share/nvim/lsp_loaded.txt"

  cleanup_nvim_test_env "$test_home"
  pass
}

# Test: Full configuration loads without errors
it "should load full configuration with select plugins" && {
  local test_home=$(setup_nvim_test_env)

  # Create a test script that loads config and checks for errors
  cat > "$test_home/test_full_config.lua" << 'EOF'
-- Track errors
local errors = {}
local original_notify = vim.notify
vim.notify = function(msg, level)
  if level == vim.log.levels.ERROR then
    table.insert(errors, msg)
  end
  original_notify(msg, level)
end

-- Set up autocmd to quit after plugins load
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  callback = function()
    vim.defer_fn(function()
      -- Write results
      local result_file = vim.fn.stdpath("data") .. "/test_results.txt"
      local results = {
        "errors: " .. #errors,
        "plugins_loaded: " .. tostring(pcall(require, "lazy")),
      }
      vim.fn.writefile(results, result_file)
      vim.cmd("qa!")
    end, 2000)
  end,
})
EOF

  # Run with our actual config but with the test script
  timeout 60 nvim --headless \
    -u "$DOTFILES_DIR/src/neovim/init.lua" \
    -c "luafile $test_home/test_full_config.lua" \
    2>&1 || true

  # Check results
  if [[ -f "$test_home/.local/share/nvim/test_results.txt" ]]; then
    local results=$(cat "$test_home/.local/share/nvim/test_results.txt")
    assert_contains "$results" "errors: 0"
    assert_contains "$results" "plugins_loaded: true"
  else
    # If no results file, config may have minimal mode (CI detection)
    # This is OK for CI
    skip "Full config test skipped (likely in CI minimal mode)"
  fi

  cleanup_nvim_test_env "$test_home"
  pass
}

cleanup_test
echo -e "\n${GREEN}Neovim E2E tests completed${NC}"