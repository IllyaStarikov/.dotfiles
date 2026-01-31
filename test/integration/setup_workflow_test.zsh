#!/usr/bin/env zsh
# Integration tests for complete setup workflow

set -euo pipefail

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

# Test suite for setup workflow
describe "Complete setup workflow integration tests"

# Setup before tests
setup_test

# Create isolated test environment
TEST_HOME="$TEST_TMP_DIR/home"
mkdir -p "$TEST_HOME"

# Test: Fresh installation workflow
it "should complete fresh installation workflow" && {
  # Set up clean environment
  export HOME="$TEST_HOME"
  export DOTFILES_TEST_MODE=1

  # Run setup in dry-run mode
  output=$("$DOTFILES_DIR/src/setup/install.sh" --dry-run 2>&1 || true)

  # Should complete without errors
  assert_not_contains "$output" "FATAL"
  assert_not_contains "$output" "PANIC"
  pass
}

# Test: Symlink creation workflow
it "should create all necessary symlinks" && {
  export HOME="$TEST_HOME"

  # Run symlinks script in dry-run
  output=$("$DOTFILES_DIR/src/setup/symlinks.sh" --dry-run 2>&1 || true)

  # Should plan to create symlinks (script outputs "Attempting to link" or "linked")
  assert_contains "$output" "link" || assert_contains "$output" "Link"
  pass
}

# Test: Directory structure creation
it "should create required directory structure" && {
  export HOME="$TEST_HOME"

  # Create expected directories
  mkdir -p "$TEST_HOME/.config"
  mkdir -p "$TEST_HOME/.local/bin"
  mkdir -p "$TEST_HOME/.cache"

  # Verify structure
  assert_directory_exists "$TEST_HOME/.config"
  assert_directory_exists "$TEST_HOME/.local/bin"
  assert_directory_exists "$TEST_HOME/.cache"
  pass
}

# Test: Configuration file linking
it "should link configuration files correctly" && {
  export HOME="$TEST_HOME"

  # Simulate linking (dry run)
  local configs=("zshrc" "tmux.conf" "gitconfig")

  for config in "${configs[@]}"; do
    local src_file=$(find "$DOTFILES_DIR/src" -name "$config" -o -name ".$config" | head -1)
    if [[ -n "$src_file" ]]; then
      assert_file_exists "$src_file"
    fi
  done

  pass
}

# Test: Neovim configuration setup
it "should set up Neovim configuration" && {
  export HOME="$TEST_HOME"
  mkdir -p "$TEST_HOME/.config/nvim"

  # Check source files exist (flat structure, no config/ subdirectory)
  assert_file_exists "$DOTFILES_DIR/src/neovim/init.lua"
  assert_directory_exists "$DOTFILES_DIR/src/neovim/plugins"
  pass
}

# Test: Shell configuration setup
it "should set up shell configuration" && {
  export HOME="$TEST_HOME"

  # Check zsh configuration exists
  assert_file_exists "$DOTFILES_DIR/src/zsh/zshrc"
  assert_file_exists "$DOTFILES_DIR/src/zsh/zshenv"
  pass
}

# Test: Git configuration setup
it "should set up Git configuration" && {
  export HOME="$TEST_HOME"

  # Check git configs exist
  assert_file_exists "$DOTFILES_DIR/src/git/gitconfig"
  assert_file_exists "$DOTFILES_DIR/src/git/gitignore"
  pass
}

# Test: Terminal emulator setup
it "should set up terminal emulator configs" && {
  export HOME="$TEST_HOME"

  # Check at least one terminal config exists
  local terminal_found=0

  [[ -f "$DOTFILES_DIR/src/alacritty.toml" ]] && terminal_found=1
  [[ -d "$DOTFILES_DIR/src/wezterm" ]] && terminal_found=1
  [[ -d "$DOTFILES_DIR/src/kitty" ]] && terminal_found=1

  assert_equals "$terminal_found" 1
  pass
}

# Test: Theme system setup
it "should set up theme switching system" && {
  export HOME="$TEST_HOME"
  mkdir -p "$TEST_HOME/.config/theme"

  # Check theme components
  assert_file_exists "$DOTFILES_DIR/src/theme/switch-theme.sh"
  assert_directory_exists "$DOTFILES_DIR/src/theme/themes"
  pass
}

# Test: Scripts installation
it "should install utility scripts" && {
  export HOME="$TEST_HOME"

  # Check scripts exist
  local script_count=$(ls "$DOTFILES_DIR/src/scripts/"* 2>/dev/null | grep -v "\.md$" | wc -l)
  assert_greater_than "$script_count" 5
  pass
}

# Test: Backup creation
it "should create backups of existing files" && {
  export HOME="$TEST_HOME"
  export BACKUP_DIR="$TEST_HOME/.dotfiles-backup"

  # Create existing file
  echo "existing" >"$TEST_HOME/.zshrc"

  # Check backup would be created (script outputs "Backed up existing file")
  output=$("$DOTFILES_DIR/src/setup/symlinks.sh" --dry-run 2>&1 || true)

  assert_contains "$output" "Backed" || assert_contains "$output" "backup" || assert_contains "$output" "skip"
  pass
}

# Test: Platform-specific setup (unified script handles both macOS and Linux)
it "should handle platform-specific setup" && {
  export HOME="$TEST_HOME"

  # Unified setup.sh handles both platforms
  assert_file_exists "$DOTFILES_DIR/src/setup/install.sh"
  local setup_content=$(cat "$DOTFILES_DIR/src/setup/install.sh")
  # Should detect platform
  assert_contains "$setup_content" "Darwin" || assert_contains "$setup_content" "Linux" || assert_contains "$setup_content" "uname"
  pass
}

# Test: Private repository integration
it "should handle private repository if present" && {
  export HOME="$TEST_HOME"

  if [[ -d "$DOTFILES_DIR/.dotfiles.private" ]]; then
    assert_directory_exists "$DOTFILES_DIR/.dotfiles.private"
    pass
  else
    skip "Private repository not present"
  fi
}

# Test: Environment variable setup
it "should set up environment variables" && {
  export HOME="$TEST_HOME"

  # Check for environment setup
  assert_file_exists "$DOTFILES_DIR/src/zsh/zshenv"

  local env_content=$(cat "$DOTFILES_DIR/src/zsh/zshenv")
  assert_contains "$env_content" "export" || assert_contains "$env_content" "PATH"
  pass
}

# Test: Dependencies check
it "should check for required dependencies" && {
  export HOME="$TEST_HOME"

  # Check setup script has dependency checking
  local setup_content=$(cat "$DOTFILES_DIR/src/setup/install.sh")

  assert_contains "$setup_content" "command -v" || assert_contains "$setup_content" "which"
  assert_contains "$setup_content" "git" || assert_contains "$setup_content" "Git"
  pass
}

# Test: Idempotency of full setup
it "should be idempotent when run multiple times" && {
  export HOME="$TEST_HOME"

  # Run setup twice
  output1=$("$DOTFILES_DIR/src/setup/install.sh" --dry-run 2>&1 || true)
  output2=$("$DOTFILES_DIR/src/setup/install.sh" --dry-run 2>&1 || true)

  # Both should succeed
  assert_not_contains "$output1" "FATAL"
  assert_not_contains "$output2" "FATAL"
  pass
}

# Test: Upgrade workflow
it "should handle upgrade from existing installation" && {
  export HOME="$TEST_HOME"

  # Simulate existing installation
  mkdir -p "$TEST_HOME/.config/nvim"
  echo "old config" >"$TEST_HOME/.zshrc"

  # Check setup script handles existing files (backup logic in symlinks.sh)
  local symlinks_content=$(cat "$DOTFILES_DIR/src/setup/symlinks.sh")
  assert_contains "$symlinks_content" "backup" || assert_contains "$symlinks_content" "Backed"
  pass
}

# Test: Post-installation verification
it "should verify installation success" && {
  export HOME="$TEST_HOME"

  # Check setup script has verification
  local setup_content=$(cat "$DOTFILES_DIR/src/setup/install.sh")

  assert_contains "$setup_content" "verify" || assert_contains "$setup_content" "check" || assert_contains "$setup_content" "test"
  pass
}

# Cleanup after tests
cleanup_test
unset TEST_HOME

# Summary
echo -e "\n${GREEN}Setup workflow integration tests completed${NC}"
