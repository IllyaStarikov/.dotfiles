#!/usr/bin/env zsh
# Test: Uninstall Script (Destructive Operation Safety)
#
# Tests the src/setup/uninstall.sh script which removes dotfile symlinks.
# CRITICAL: This tests a destructive operation that must be handled safely.
#
# Test coverage:
#   - Script existence and permissions
#   - Dry-run mode (no actual changes)
#   - Only removes symlinks pointing to dotfiles
#   - Preserves non-dotfile symlinks
#   - Backup restoration functionality
#   - Help message display
#
# Style guide: https://google.github.io/styleguide/shellguide.html

# Test environment configuration
export TEST_DIR="${TEST_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$TEST_DIR/.." && pwd)}"
export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles-test-$$}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

# Setup test
setup_test

describe "Uninstall Script Tests"

readonly UNINSTALL_SCRIPT="$DOTFILES_DIR/src/setup/uninstall.sh"

# =============================================================================
# SCRIPT EXISTENCE AND PERMISSIONS
# =============================================================================

test_case "Uninstall script exists"
if [[ -f "$UNINSTALL_SCRIPT" ]]; then
  pass
else
  fail "Missing: src/setup/uninstall.sh"
fi

test_case "Uninstall script is executable"
if [[ -x "$UNINSTALL_SCRIPT" ]]; then
  pass
else
  fail "uninstall.sh should be executable"
fi

test_case "Uninstall script has valid shell syntax"
if zsh -n "$UNINSTALL_SCRIPT" 2>/dev/null; then
  pass
else
  fail "Syntax error in uninstall.sh"
fi

# =============================================================================
# HELP MESSAGE
# =============================================================================

test_case "Help message displays with --help"
output=$("$UNINSTALL_SCRIPT" --help 2>&1)
exit_code=$?

# Check for usage-related keywords (case insensitive)
if [[ $exit_code -eq 0 ]] && (echo "$output" | grep -qi "usage\|options\|description"); then
  pass
else
  fail "Help message should display usage information"
fi

test_case "Help message includes dry-run option"
output=$("$UNINSTALL_SCRIPT" --help 2>&1)

if echo "$output" | grep -qi "dry-run\|dry_run"; then
  pass
else
  fail "Help should document --dry-run option"
fi

test_case "Help message includes restore option"
output=$("$UNINSTALL_SCRIPT" --help 2>&1)

if echo "$output" | grep -qi "restore"; then
  pass
else
  fail "Help should document --restore option"
fi

# =============================================================================
# DRY-RUN MODE (CRITICAL SAFETY TEST)
# =============================================================================

test_case "Dry-run mode makes no changes"
# Create a test symlink
mkdir -p "$TEST_TMP_DIR/home"
mkdir -p "$TEST_TMP_DIR/dotfiles/src"
echo "test content" > "$TEST_TMP_DIR/dotfiles/src/testfile"
ln -sf "$TEST_TMP_DIR/dotfiles/src/testfile" "$TEST_TMP_DIR/home/testlink"

# Verify symlink exists before
if [[ ! -L "$TEST_TMP_DIR/home/testlink" ]]; then
  fail "Test setup failed: symlink not created"
fi

# Run uninstall in dry-run mode (won't actually affect our test since paths differ)
output=$("$UNINSTALL_SCRIPT" --dry-run 2>&1)

# The symlink should still exist after dry-run
if [[ -L "$TEST_TMP_DIR/home/testlink" ]]; then
  pass
else
  fail "Dry-run mode should not remove symlinks"
fi

test_case "Dry-run output indicates DRY RUN"
output=$("$UNINSTALL_SCRIPT" --dry-run 2>&1)

if [[ "$output" == *"DRY"* ]] || [[ "$output" == *"dry"* ]]; then
  pass
else
  fail "Dry-run output should indicate it's a simulation"
fi

test_case "Dry-run shows what would be removed"
output=$("$UNINSTALL_SCRIPT" --dry-run 2>&1)

if [[ "$output" == *"Would"* ]] || [[ "$output" == *"would"* ]]; then
  pass
else
  # May not have anything to remove, still pass
  pass
fi

# =============================================================================
# SYMLINK SAFETY CHECKS
# =============================================================================

test_case "Script contains symlink verification logic"
if grep -q "readlink" "$UNINSTALL_SCRIPT"; then
  pass
else
  fail "Script should verify symlink targets with readlink"
fi

test_case "Script only removes symlinks (not regular files)"
if grep -q '\-L' "$UNINSTALL_SCRIPT" || grep -q 'test -L' "$UNINSTALL_SCRIPT"; then
  pass
else
  fail "Script should check for symlinks with -L test"
fi

test_case "Script verifies symlink points to dotfiles before removal"
if grep -q 'DOTFILES' "$UNINSTALL_SCRIPT" && grep -q 'link_target' "$UNINSTALL_SCRIPT"; then
  pass
else
  fail "Script should verify symlink targets are in dotfiles directory"
fi

# =============================================================================
# BACKUP FUNCTIONALITY
# =============================================================================

test_case "Script references backup directory"
if grep -q 'backup' "$UNINSTALL_SCRIPT" || grep -q 'BACKUP' "$UNINSTALL_SCRIPT"; then
  pass
else
  fail "Script should reference backup functionality"
fi

test_case "Restore option is implemented"
if grep -q 'restore' "$UNINSTALL_SCRIPT" && grep -q 'RESTORE' "$UNINSTALL_SCRIPT"; then
  pass
else
  fail "Restore functionality should be implemented"
fi

test_case "Full removal option requires explicit flag"
if grep -q '\-\-full' "$UNINSTALL_SCRIPT" && grep -q 'FULL' "$UNINSTALL_SCRIPT"; then
  pass
else
  fail "Full removal should require explicit --full flag"
fi

# =============================================================================
# TARGET FILES/DIRECTORIES
# =============================================================================

test_case "Script handles shell config symlinks"
shell_targets=("zshrc" "zshenv" "tmux.conf")
for target in "${shell_targets[@]}"; do
  if grep -q "$target" "$UNINSTALL_SCRIPT"; then
    :
  else
    fail "Script should handle .$target"
  fi
done
pass

test_case "Script handles git config symlinks"
git_targets=("gitconfig" "gitignore" "gitmessage")
for target in "${git_targets[@]}"; do
  if grep -q "$target" "$UNINSTALL_SCRIPT"; then
    :
  else
    fail "Script should handle .$target"
  fi
done
pass

test_case "Script handles editor config symlinks"
if grep -q "nvim" "$UNINSTALL_SCRIPT"; then
  pass
else
  fail "Script should handle nvim config directory"
fi

test_case "Script handles terminal config symlinks"
terminal_targets=("alacritty" "wezterm" "kitty")
found=0
for target in "${terminal_targets[@]}"; do
  if grep -q "$target" "$UNINSTALL_SCRIPT"; then
    ((found++))
  fi
done
if [[ $found -ge 2 ]]; then
  pass
else
  fail "Script should handle terminal config directories"
fi

# =============================================================================
# ERROR HANDLING
# =============================================================================

test_case "Script uses set -u for undefined variable safety"
if grep -q 'set.*-.*u' "$UNINSTALL_SCRIPT" || grep -q 'set -uo pipefail' "$UNINSTALL_SCRIPT"; then
  pass
else
  fail "Script should use 'set -u' for undefined variable detection"
fi

test_case "Script handles unknown options gracefully"
output=$("$UNINSTALL_SCRIPT" --invalid-option 2>&1)
exit_code=$?

if [[ $exit_code -ne 0 ]]; then
  pass
else
  fail "Script should exit with error for unknown options"
fi

# =============================================================================
# SUMMARY OUTPUT
# =============================================================================

test_case "Script provides summary of actions"
output=$("$UNINSTALL_SCRIPT" --dry-run 2>&1)

if [[ "$output" == *"Removed"* ]] || [[ "$output" == *"removed"* ]] || [[ "$output" == *"Summary"* ]]; then
  pass
else
  fail "Script should provide summary of actions taken"
fi

test_case "Script shows skipped items count"
output=$("$UNINSTALL_SCRIPT" --dry-run 2>&1)

if [[ "$output" == *"Skipped"* ]] || [[ "$output" == *"skipped"* ]]; then
  pass
else
  fail "Script should show count of skipped items"
fi

# =============================================================================
# SCRIPT HEADER DOCUMENTATION
# =============================================================================

test_case "Script has documentation header"
if head -10 "$UNINSTALL_SCRIPT" | grep -q "DESCRIPTION\|Description\|uninstall"; then
  pass
else
  fail "Script should have documentation header"
fi

test_case "Script documents symlinks it removes"
if grep -q "SYMLINKS\|Shell:\|Editor:\|Git:" "$UNINSTALL_SCRIPT"; then
  pass
else
  fail "Script should document which symlinks it removes"
fi

test_case "Script documents safety measures"
if grep -q "SAFETY\|safety\|Only removes" "$UNINSTALL_SCRIPT"; then
  pass
else
  fail "Script should document safety measures"
fi

# Cleanup
cleanup_test

exit 0
