#!/usr/bin/env zsh
# Unit tests for installer.zsh — the sha256-verified download+run helper.
# This is the most security-sensitive lib module (it executes downloaded
# scripts), and it previously had zero coverage. All tests are offline:
# the network fetch is mocked, fixtures live under TEST_TMP_DIR.

# Get the test directory path
TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

# Set up test environment
export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}"
mkdir -p "$TEST_TMP_DIR"

# Test framework
source "${TEST_DIR}/lib/test_helpers.zsh"

# Source the library under test
DOTFILES="$DOTFILES_DIR" source "${DOTFILES_DIR}/src/lib/installer.zsh"

# ============================================================================
# Test Fixtures
# ============================================================================

FIXTURES="$TEST_TMP_DIR/installer_test_$$"
mkdir -p "$FIXTURES"

# Sandbox the module's config lookup
INSTALLER_URLS_JSON="$FIXTURES/urls.json"

# A fake bootstrap script that proves execution by writing a marker file
MARKER="$FIXTURES/executed.marker"
GOOD_SCRIPT="$FIXTURES/good.sh"
print -r -- "touch '$MARKER'" > "$GOOD_SCRIPT"
GOOD_SHA="$(shasum -a 256 "$GOOD_SCRIPT" | awk '{print $1}')"

# A tampered variant (different content, therefore different sha)
EVIL_SCRIPT="$FIXTURES/evil.sh"
print -r -- "touch '$MARKER'; echo tampered" > "$EVIL_SCRIPT"

# urls.json: one fully pinned entry, one rolling-CDN (null sha) entry
cat > "$INSTALLER_URLS_JSON" <<EOF
{
  "installers": {
    "pinned": "https://example.invalid/pinned.sh",
    "pinned_sha256": "$GOOD_SHA",
    "rolling": "https://example.invalid/rolling.sh",
    "rolling_sha256": null
  }
}
EOF

# Mock the network: _installer_fetch copies whatever MOCK_FETCH_SRC points at.
# (The real fetch enforces --proto =https, so file:// fixtures can't be used.)
MOCK_FETCH_SRC="$GOOD_SCRIPT"
_installer_fetch() {
  cp "$MOCK_FETCH_SRC" "$2"
}

# ============================================================================
# Tests
# ============================================================================

test_verify_sha_match() {
  if _installer_verify_sha "$GOOD_SCRIPT" "$GOOD_SHA"; then
    pass
  else
    fail "matching sha256 should verify"
  fi
}

test_verify_sha_mismatch() {
  local out
  out=$(_installer_verify_sha "$GOOD_SCRIPT" "0000000000000000000000000000000000000000000000000000000000000000" 2>&1)
  if assert_failure $? && assert_contains "$out" "mismatch"; then
    pass
  fi
}

test_run_missing_url_fails() {
  local out
  out=$(installer_run does-not-exist sh 2>&1)
  if assert_failure $? && assert_contains "$out" "no URL configured"; then
    pass
  fi
}

test_run_verified_executes() {
  rm -f "$MARKER"
  MOCK_FETCH_SRC="$GOOD_SCRIPT"
  local out
  out=$(installer_run pinned zsh 2>&1)
  local rc=$?
  if assert_success $rc && assert_file_exists "$MARKER" \
    && assert_contains "$out" "sha256 verified"; then
    pass
  fi
}

test_run_tampered_download_aborts_before_execution() {
  rm -f "$MARKER"
  # sha in urls.json pins the GOOD script, but the "network" delivers EVIL
  MOCK_FETCH_SRC="$EVIL_SCRIPT"
  local out
  out=$(installer_run pinned zsh 2>&1)
  local rc=$?
  MOCK_FETCH_SRC="$GOOD_SCRIPT"
  if assert_failure $rc && assert_contains "$out" "mismatch"; then
    if [[ -f "$MARKER" ]]; then
      fail "tampered script was EXECUTED despite sha mismatch"
    else
      pass
    fi
  fi
}

test_run_null_sha_executes_with_warning() {
  rm -f "$MARKER"
  MOCK_FETCH_SRC="$GOOD_SCRIPT"
  local out
  out=$(installer_run rolling zsh 2>&1)
  local rc=$?
  if assert_success $rc && assert_file_exists "$MARKER" \
    && assert_contains "$out" "no configured sha256"; then
    pass
  fi
}

# ============================================================================
# Run Tests
# ============================================================================

test_suite "Installer Library" \
  test_verify_sha_match \
  test_verify_sha_mismatch \
  test_run_missing_url_fails \
  test_run_verified_executes \
  test_run_tampered_download_aborts_before_execution \
  test_run_null_sha_executes_with_warning
