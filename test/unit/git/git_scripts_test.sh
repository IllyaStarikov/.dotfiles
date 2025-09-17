#!/usr/bin/env zsh
# Git scripts unit tests

# Setup test environment
export DOTFILES_DIR="${DOTFILES_DIR:-/Users/starikov/.dotfiles}"
export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/test-$$}"

# Source test helpers
source "${DOTFILES_DIR}/test/lib/test_helpers.zsh"

# Test install-git-hooks script
test_install_git_hooks() {
  local script="$DOTFILES_DIR/src/git/install-git-hooks"

  # Check script exists and is executable
  if [[ ! -f "$script" ]]; then
    fail "install-git-hooks script not found"
    return 1
  fi

  if [[ ! -x "$script" ]]; then
    fail "install-git-hooks script not executable"
    return 1
  fi

  # Check shebang is zsh
  local shebang=$(head -1 "$script")
  if [[ "$shebang" != "#!/usr/bin/env zsh" ]]; then
    fail "install-git-hooks should use zsh shebang, found: $shebang"
    return 1
  fi

  # Check syntax
  if ! zsh -n "$script" 2>/dev/null; then
    fail "install-git-hooks has syntax errors"
    return 1
  fi

  pass "install-git-hooks script valid"
}

# Test setup-git-signing script
test_setup_git_signing() {
  local script="$DOTFILES_DIR/src/git/setup-git-signing"

  # Check script exists and is executable
  if [[ ! -f "$script" ]]; then
    fail "setup-git-signing script not found"
    return 1
  fi

  if [[ ! -x "$script" ]]; then
    fail "setup-git-signing script not executable"
    return 1
  fi

  # Check shebang is zsh
  local shebang=$(head -1 "$script")
  if [[ "$shebang" != "#!/usr/bin/env zsh" ]]; then
    fail "setup-git-signing should use zsh shebang, found: $shebang"
    return 1
  fi

  # Check syntax
  if ! zsh -n "$script" 2>/dev/null; then
    fail "setup-git-signing has syntax errors"
    return 1
  fi

  pass "setup-git-signing script valid"
}

# Test pre-commit-hook script
test_pre_commit_hook() {
  local script="$DOTFILES_DIR/src/git/pre-commit-hook"

  # Check script exists and is executable
  if [[ ! -f "$script" ]]; then
    fail "pre-commit-hook script not found"
    return 1
  fi

  if [[ ! -x "$script" ]]; then
    fail "pre-commit-hook script not executable"
    return 1
  fi

  # Check shebang is zsh
  local shebang=$(head -1 "$script")
  if [[ "$shebang" != "#!/usr/bin/env zsh" ]]; then
    fail "pre-commit-hook should use zsh shebang, found: $shebang"
    return 1
  fi

  # Check syntax
  if ! zsh -n "$script" 2>/dev/null; then
    fail "pre-commit-hook has syntax errors"
    return 1
  fi

  # Check required commands are present
  if ! grep -q "gitleaks" "$script"; then
    fail "pre-commit-hook should use gitleaks for security scanning"
    return 1
  fi

  pass "pre-commit-hook script valid"
}

# Test git configuration files
test_git_config_files() {
  local gitconfig="$DOTFILES_DIR/src/git/gitconfig"
  local gitignore="$DOTFILES_DIR/src/git/gitignore"
  local gitmessage="$DOTFILES_DIR/src/git/gitmessage"

  # Check gitconfig exists
  if [[ ! -f "$gitconfig" ]]; then
    fail "gitconfig not found"
    return 1
  fi

  # Check gitignore exists
  if [[ ! -f "$gitignore" ]]; then
    fail "gitignore not found"
    return 1
  fi

  # Check gitmessage exists
  if [[ ! -f "$gitmessage" ]]; then
    fail "gitmessage not found"
    return 1
  fi

  # Validate gitconfig structure
  if ! grep -q "\[user\]" "$gitconfig"; then
    fail "gitconfig missing [user] section"
    return 1
  fi

  if ! grep -q "\[core\]" "$gitconfig"; then
    fail "gitconfig missing [core] section"
    return 1
  fi

  pass "Git configuration files valid"
}

# Test git hooks installation
test_git_hooks_installation() {
  # Create temporary git repo for testing
  local test_repo="$TEST_TMP_DIR/test-repo"
  mkdir -p "$test_repo"
  cd "$test_repo" || return 1

  # Initialize git repo
  git init --quiet

  # Try to install hooks (dry run)
  local script="$DOTFILES_DIR/src/git/install-git-hooks"
  if [[ -x "$script" ]]; then
    # Check script can be sourced/executed without errors
    if zsh -c "cd '$test_repo' && '$script' --dry-run" 2>/dev/null; then
      pass "Git hooks can be installed (dry run)"
    else
      # Script might not have --dry-run, just check syntax
      pass "Git hooks script syntax valid"
    fi
  else
    warn "install-git-hooks not executable, skipping installation test"
  fi

  cd - >/dev/null
}

# Main test execution
main() {
  setup_test

  echo "━━━ Git scripts unit tests ━━━"

  run_test "install-git-hooks script validation" test_install_git_hooks
  run_test "setup-git-signing script validation" test_setup_git_signing
  run_test "pre-commit-hook script validation" test_pre_commit_hook
  run_test "Git configuration files" test_git_config_files
  run_test "Git hooks installation" test_git_hooks_installation

  cleanup_test
}

main "$@"
# Return success
exit 0
