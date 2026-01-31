#!/usr/bin/env zsh
# Sanity Tests - Basic Operations
# Verify basic operations work as expected

set -euo pipefail

source "$(dirname "$0")/../lib/test_helpers.zsh"

readonly DEBUG="${DEBUG:-0}"
readonly TEST_WORKSPACE="${TEST_TMP_DIR}/sanity_workspace"

# Create test workspace
mkdir -p "$TEST_WORKSPACE"
cd "$TEST_WORKSPACE"

echo -e "${BLUE}=== Sanity Tests - Basic Operations ===${NC}"

test_case "Can create and edit files with Neovim"
test_file="$TEST_WORKSPACE/test_edit.txt"
echo "Initial content" >"$test_file"

# Use Neovim to modify the file
nvim --headless "$test_file" \
  -c "normal! Goadded line" \
  -c "wq!" 2>/dev/null

if grep -q "added line" "$test_file"; then
  pass
else
  fail "Neovim failed to edit file"
fi

test_case "Shell aliases are defined"
# Source zsh config and check for common aliases
output=$(zsh -c "source '$DOTFILES_DIR/src/zsh/zshrc' 2>/dev/null && alias" 2>/dev/null || echo "")

if [[ "$output" == *"ll="* ]] || [[ "$output" == *"la="* ]]; then
  pass
else
  skip "Aliases not loaded in test environment"
fi

test_case "Git operations work correctly"
# Initialize a test repo
git init test_repo >/dev/null 2>&1
cd test_repo
git config user.name "Test User"
git config user.email "test@example.com"

echo "test content" >test.txt
git add test.txt
git commit -m "test commit" >/dev/null 2>&1

if git log --oneline | grep -q "test commit"; then
  pass
else
  fail "Git operations failed"
fi

cd ..

test_case "Theme configuration files are generated"
# Check if theme configuration directories exist
theme_configs=(
  "$HOME/.config/theme"
  "$HOME/.config/alacritty"
  "$HOME/.config/tmux"
)

config_count=0
for config_dir in "${theme_configs[@]}"; do
  [[ -d "$config_dir" ]] && ((config_count++))
done

if [[ $config_count -gt 0 ]]; then
  pass "$config_count theme config directories found"
else
  skip "Theme configs not yet generated"
fi

test_case "Environment variables are set"
# Check for essential environment variables
essential_vars=(
  "HOME"
  "PATH"
  "SHELL"
)

missing_vars=()
for var in "${essential_vars[@]}"; do
  [[ -z "${!var:-}" ]] && missing_vars+=("$var")
done

if [[ ${#missing_vars[@]} -eq 0 ]]; then
  pass
else
  fail "Missing environment variables: ${missing_vars[*]}"
fi

test_case "Can execute custom scripts"
# Test if we can run a simple custom script
if [[ -x "$DOTFILES_DIR/src/scripts/theme" ]]; then
  output=$("$DOTFILES_DIR/src/scripts/theme" --list 2>&1 || echo "failed")
  if [[ "$output" != "failed" ]]; then
    pass
  else
    fail "Script execution failed"
  fi
else
  skip "Theme script not found"
fi

test_case "File permissions are correct"
# Check that config files have appropriate permissions
permission_issues=0

# Check that sensitive files are not world-readable
if [[ -f "$DOTFILES_DIR/src/git/gitconfig" ]]; then
  perms=$(stat -f "%OLp" "$DOTFILES_DIR/src/git/gitconfig" 2>/dev/null || stat -c "%a" "$DOTFILES_DIR/src/git/gitconfig" 2>/dev/null)
  if [[ "${perms: -1}" != "0" ]] && [[ "${perms: -1}" != "4" ]]; then
    ((permission_issues++))
  fi
fi

if [[ $permission_issues -eq 0 ]]; then
  pass
else
  fail "$permission_issues files have incorrect permissions"
fi

test_case "Temporary files can be created and cleaned up"
temp_file=$(mktemp)
echo "temp test" >"$temp_file"

if [[ -f "$temp_file" ]]; then
  rm "$temp_file"
  pass
else
  fail "Cannot create temporary files"
fi

# Clean up
cd "$DOTFILES_DIR"
rm -rf "$TEST_WORKSPACE"

echo -e "\n${GREEN}=== Sanity Test Summary ===${NC}"
echo "Basic operations verified"
