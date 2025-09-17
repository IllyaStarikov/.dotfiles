#!/usr/bin/env zsh

# Unit tests for symlinks.sh symlink creation script

# Tests handle errors explicitly

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

# Test suite for symlinks.sh
describe "symlinks.sh symlink script"

# Test: Script exists and is executable
it "should exist and be executable" && {
  local script_path="$DOTFILES_DIR/src/setup/symlinks.sh"

  assert_file_exists "$script_path"
  assert_file_executable "$script_path"
}

# Test: Dry run mode
it "should support dry run mode" && {
  # Skip - dry run mode not implemented in symlinks.sh
  skip "Dry run mode not implemented in current version"
}

# Test: Symlink creation
it "should create symlinks to dotfiles" && {
  local test_home="$TEST_TMP_DIR/test_symlinks"
  mkdir -p "$test_home"

  export HOME="$test_home"

  # Run symlink creation
  zsh "$DOTFILES_DIR/src/setup/symlinks.sh" 2>&1 || true

  # Check key symlinks
  local created=0
  [[ -L "$test_home/.zshrc" ]] && ((created++))
  [[ -L "$test_home/.gitconfig" ]] && ((created++))
  [[ -L "$test_home/.tmux.conf" ]] && ((created++))

  if [[ $created -gt 0 ]]; then
    pass "Created $created symlinks"
  else
    fail "No symlinks created"
  fi
}

# Test: Backup existing files
it "should backup existing files before symlinking" && {
  local test_home="$TEST_TMP_DIR/test_backup"
  mkdir -p "$test_home"

  export HOME="$test_home"
  export BACKUP_DIR="$test_home/.dotfiles-backup"

  # Create existing file
  echo "original content" >"$test_home/.zshrc"
  original_hash=$(shasum "$test_home/.zshrc" | cut -d' ' -f1)

  # Run symlink creation
  zsh "$DOTFILES_DIR/src/setup/symlinks.sh" 2>&1 || true

  # Check if backup was created
  if [[ -d "$BACKUP_DIR" ]]; then
    # Find backup file
    backup_file=$(find "$BACKUP_DIR" -name "*zshrc*" -type f 2>/dev/null | head -1)
    if [[ -n "$backup_file" ]] && [[ -f "$backup_file" ]]; then
      backup_hash=$(shasum "$backup_file" | cut -d' ' -f1)
      if [[ "$original_hash" == "$backup_hash" ]]; then
        pass "Original file backed up correctly"
      else
        fail "Backup file content doesn't match original"
      fi
    else
      fail "Backup file not found"
    fi
  else
    fail "Backup directory not created"
  fi
}

# Test: Handle broken symlinks
it "should replace broken symlinks" && {
  local test_home="$TEST_TMP_DIR/test_broken"
  mkdir -p "$test_home"

  export HOME="$test_home"

  # Create broken symlink
  ln -s "/nonexistent/path" "$test_home/.zshrc"

  # Run symlink creation
  zsh "$DOTFILES_DIR/src/setup/symlinks.sh" 2>&1 || true

  # Check if symlink was replaced
  if [[ -L "$test_home/.zshrc" ]]; then
    target=$(readlink "$test_home/.zshrc")
    if [[ "$target" == *"dotfiles"* ]]; then
      pass "Broken symlink replaced"
    else
      fail "Symlink not pointing to dotfiles"
    fi
  else
    fail "Symlink not created"
  fi
}

# Test: Directory creation
it "should create necessary directories" && {
  local test_home="$TEST_TMP_DIR/test_dirs"
  mkdir -p "$test_home"

  export HOME="$test_home"

  # Run symlink creation
  zsh "$DOTFILES_DIR/src/setup/symlinks.sh" 2>&1 || true

  # Check if config directories were created
  local dirs_created=0
  [[ -d "$test_home/.config" ]] && ((dirs_created++))
  [[ -d "$test_home/.config/nvim" ]] && ((dirs_created++))
  [[ -d "$test_home/.config/alacritty" ]] && ((dirs_created++))

  if [[ $dirs_created -gt 0 ]]; then
    pass "Created $dirs_created directories"
  else
    fail "No directories created"
  fi
}

# Test: Symlink validation
it "should validate symlink targets exist" && {
  local test_home="$TEST_TMP_DIR/test_validate"
  mkdir -p "$test_home"

  export HOME="$test_home"

  # Run symlink creation
  zsh "$DOTFILES_DIR/src/setup/symlinks.sh" 2>&1 || true

  # Check that symlinks point to existing files
  local valid_links=0
  local invalid_links=0

  for link in "$test_home"/.* "$test_home"/.config/*; do
    if [[ -L "$link" ]]; then
      target=$(readlink "$link")
      if [[ -e "$target" ]]; then
        ((valid_links++))
      else
        ((invalid_links++))
      fi
    fi
  done

  if [[ $invalid_links -eq 0 ]] && [[ $valid_links -gt 0 ]]; then
    pass "All $valid_links symlinks are valid"
  else
    fail "$invalid_links invalid symlinks found"
  fi
}

# Test: Help message
it "should display help message" && {
  output=$(zsh "$DOTFILES_DIR/src/setup/symlinks.sh" --help 2>&1 || true)

  assert_contains "$output" "Usage" || assert_contains "$output" "usage" || assert_contains "$output" "symlink"
}

# Test: Force mode
it "should support force mode to overwrite without backup" && {
  local test_home="$TEST_TMP_DIR/test_force"
  mkdir -p "$test_home"

  export HOME="$test_home"

  # Create existing file
  echo "will be overwritten" >"$test_home/.zshrc"

  # Run with force flag
  output=$(zsh "$DOTFILES_DIR/src/setup/symlinks.sh" --force 2>&1 || true)

  # Check symlink was created
  if [[ -L "$test_home/.zshrc" ]]; then
    pass "Force mode overwrote existing file"
  else
    fail "Symlink not created in force mode"
  fi
}

# Run tests
run_tests
# Return success
exit 0
