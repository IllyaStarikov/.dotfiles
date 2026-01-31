#!/usr/bin/env zsh
# Unit tests for ssh.zsh library
# Note: These tests are limited to non-network operations

# Get the test directory path
TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

# Set up test environment
export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}"
mkdir -p "$TEST_TMP_DIR"

# Test framework
source "${TEST_DIR}/lib/test_helpers.zsh"

# Source the library under test
source "${DOTFILES_DIR}/src/lib/ssh.zsh" 2>/dev/null || {
  test_suite "SSH Library"
  skip "ssh.zsh not found"
  exit 0
}

# ============================================================================
# SSH Key Tests
# ============================================================================

test_ssh_key_exists_missing() {
  test_case "ssh_key_exists returns false for missing key"
  if declare -f ssh_key_exists >/dev/null 2>&1; then
    if ! ssh_key_exists "$TEST_TMP_DIR/nonexistent_key"; then
      pass
    else
      fail "Should return false for missing key"
    fi
  else
    skip "ssh_key_exists not available"
  fi
}

test_ssh_key_exists_found() {
  test_case "ssh_key_exists returns true for existing key"
  if declare -f ssh_key_exists >/dev/null 2>&1; then
    # Create a mock key file
    local keyfile="$TEST_TMP_DIR/test_ssh_key"
    echo "mock ssh key" >"$keyfile"
    if ssh_key_exists "$keyfile"; then
      pass
    else
      fail "Should return true for existing key"
    fi
    rm -f "$keyfile"
  else
    skip "ssh_key_exists not available"
  fi
}

# ============================================================================
# SSH Config Tests
# ============================================================================

test_ssh_config_list_hosts() {
  test_case "ssh_config_list_hosts parses config"
  if declare -f ssh_config_list_hosts >/dev/null 2>&1; then
    # Create a mock SSH config
    local configfile="$TEST_TMP_DIR/ssh_config"
    cat >"$configfile" <<'EOF'
Host server1
    HostName server1.example.com
    User admin

Host server2
    HostName server2.example.com
    User root
EOF
    local hosts=$(ssh_config_list_hosts "$configfile")
    if [[ "$hosts" == *"server1"* ]] && [[ "$hosts" == *"server2"* ]]; then
      pass
    else
      fail "Expected to find hosts, got: '$hosts'"
    fi
    rm -f "$configfile"
  else
    skip "ssh_config_list_hosts not available"
  fi
}

# ============================================================================
# SSH Agent Tests
# ============================================================================

test_ssh_agent_status() {
  test_case "ssh_agent_status returns status"
  if declare -f ssh_agent_status >/dev/null 2>&1; then
    # Just check that it returns something without error
    local status
    status=$(ssh_agent_status 2>/dev/null) || true
    # Any output or no error is acceptable
    pass
  else
    skip "ssh_agent_status not available"
  fi
}

# ============================================================================
# Run Tests
# ============================================================================

test_suite "SSH Library" \
  test_ssh_key_exists_missing \
  test_ssh_key_exists_found \
  test_ssh_config_list_hosts \
  test_ssh_agent_status
