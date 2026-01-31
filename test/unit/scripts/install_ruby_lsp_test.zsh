#!/usr/bin/env zsh
# Test suite for install-ruby-lsp script
# Tests Ruby LSP installation behavior

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

describe "install-ruby-lsp script behavioral tests"

setup_test
INSTALL_RUBY_LSP="$DOTFILES_DIR/src/scripts/install-ruby-lsp"

it "should check Ruby version" && {
  # Verify the script checks Ruby version
  if grep -q "RUBY_VERSION=.*ruby -v" "$INSTALL_RUBY_LSP"; then
    pass
  else
    fail "Doesn't check Ruby version"
  fi
}

it "should warn about Ruby versions below 3.0" && {
  # Check for version compatibility warning
  if grep -q "Ruby 3.0+ is recommended" "$INSTALL_RUBY_LSP" \
    && grep -q "if.*echo.*RUBY_VERSION.*cut.*-lt 3" "$INSTALL_RUBY_LSP"; then
    pass
  else
    fail "Missing Ruby version compatibility check"
  fi
}

it "should prompt for confirmation on old Ruby versions" && {
  # Verify interactive prompt exists
  if grep -q "Continue anyway?" "$INSTALL_RUBY_LSP" \
    && grep -q "read -r -k 1 REPLY" "$INSTALL_RUBY_LSP"; then
    pass
  else
    fail "Missing confirmation prompt for old Ruby versions"
  fi
}

it "should install multiple Ruby LSP tools" && {
  # Check that it installs both solargraph and rubocop
  if grep -q "gem install solargraph" "$INSTALL_RUBY_LSP" \
    && grep -q "gem install rubocop" "$INSTALL_RUBY_LSP"; then
    pass
  else
    fail "Doesn't install all required Ruby LSP tools"
  fi
}

it "should provide fallback installation instructions" && {
  # Check for user-install fallback
  if grep -q "gem install.*--user-install" "$INSTALL_RUBY_LSP"; then
    pass
  else
    fail "Missing fallback installation instructions"
  fi
}

it "should use proper error handling" && {
  # Check for set -euo pipefail
  if grep -q "^set -euo pipefail" "$INSTALL_RUBY_LSP"; then
    pass
  else
    fail "Missing proper error handling"
  fi
}

cleanup_test

# Return success
exit 0
