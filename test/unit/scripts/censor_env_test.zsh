#!/usr/bin/env zsh
# Unit tests for src/scripts/censor-env

TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}"
mkdir -p "$TEST_TMP_DIR"

source "${TEST_DIR}/lib/test_helpers.zsh"

readonly CENSOR_ENV="${DOTFILES_DIR}/src/scripts/censor-env"

# ============================================================================
# Existence and CLI surface
# ============================================================================

test_censor_env_exists() {
  test_case "censor-env script exists"
  assert_file_exists "$CENSOR_ENV" && pass
}

test_censor_env_executable() {
  test_case "censor-env is executable"
  assert_executable "$CENSOR_ENV" && pass
}

test_censor_env_help_flag() {
  test_case "censor-env --help prints usage"
  local out
  out=$("$CENSOR_ENV" --help 2>&1) || true
  if [[ "$out" == *"Usage"* ]]; then
    pass
  else
    fail "Expected 'Usage' in --help output: $out"
  fi
}

test_censor_env_h_flag() {
  test_case "censor-env -h prints usage"
  local out
  out=$("$CENSOR_ENV" -h 2>&1) || true
  if [[ "$out" == *"Usage"* ]]; then
    pass
  else
    fail "Expected 'Usage' in -h output: $out"
  fi
}

# ============================================================================
# Censoring behavior
# ============================================================================

# Run censor-env with a controlled environment so we can assert what it
# does and does not redact. Each test sets specific env vars and checks
# the resulting output.

test_censors_api_key() {
  test_case "censor-env redacts API_KEY"
  local out
  out=$(env -i HOME=/tmp PATH=/usr/bin:/bin:/usr/local/bin API_KEY=verysecret123 "$CENSOR_ENV" 2>&1) || true
  if [[ "$out" == *"API_KEY=<REDACTED>"* ]] && [[ "$out" != *"verysecret123"* ]]; then
    pass
  else
    fail "API_KEY should be redacted; output: $out"
  fi
}

test_censors_token() {
  test_case "censor-env redacts TOKEN values"
  local out
  out=$(env -i HOME=/tmp PATH=/usr/bin:/bin:/usr/local/bin GITHUB_TOKEN=ghp_supersecret456 "$CENSOR_ENV" 2>&1) || true
  if [[ "$out" != *"ghp_supersecret456"* ]]; then
    pass
  else
    fail "TOKEN should be redacted; output: $out"
  fi
}

test_censors_password() {
  test_case "censor-env redacts PASSWORD values"
  local out
  out=$(env -i HOME=/tmp PATH=/usr/bin:/bin:/usr/local/bin DB_PASSWORD=hunter2 "$CENSOR_ENV" 2>&1) || true
  if [[ "$out" != *"hunter2"* ]]; then
    pass
  else
    fail "PASSWORD should be redacted; output: $out"
  fi
}

test_censors_secret() {
  test_case "censor-env redacts SECRET values"
  local out
  out=$(env -i HOME=/tmp PATH=/usr/bin:/bin:/usr/local/bin AWS_SECRET=topsecret789 "$CENSOR_ENV" 2>&1) || true
  if [[ "$out" != *"topsecret789"* ]]; then
    pass
  else
    fail "SECRET should be redacted; output: $out"
  fi
}

test_censors_long_token_pattern() {
  test_case "censor-env redacts long alphanumeric tokens"
  # 50-character token-like string
  local long_token="abcdefghij1234567890ABCDEFGHIJabcdefghij1234567890"
  local out
  out=$(env -i HOME=/tmp PATH=/usr/bin:/bin:/usr/local/bin RANDOM_VAR="$long_token" "$CENSOR_ENV" 2>&1) || true
  if [[ "$out" != *"$long_token"* ]]; then
    pass
  else
    fail "Long token should be redacted; output: $out"
  fi
}

test_censors_user_path() {
  test_case "censor-env redacts /Users/<name>/ paths"
  local out
  out=$(env -i HOME=/Users/testuser PATH=/usr/bin "$CENSOR_ENV" 2>&1) || true
  if [[ "$out" != */Users/testuser/* ]] && [[ "$out" != *"=/Users/testuser"* ]]; then
    pass
  else
    fail "User path should be redacted; output: $out"
  fi
}

test_censors_email_addresses() {
  test_case "censor-env redacts email addresses"
  local out
  out=$(env -i HOME=/tmp PATH=/usr/bin:/bin:/usr/local/bin EMAIL=user@example.com "$CENSOR_ENV" 2>&1) || true
  if [[ "$out" != *"user@example.com"* ]]; then
    pass
  else
    fail "Email should be redacted; output: $out"
  fi
}

test_censors_ip_addresses() {
  test_case "censor-env redacts IP addresses"
  local out
  out=$(env -i HOME=/tmp PATH=/usr/bin:/bin:/usr/local/bin SERVER_IP=192.168.1.42 "$CENSOR_ENV" 2>&1) || true
  if [[ "$out" != *"192.168.1.42"* ]]; then
    pass
  else
    fail "IP should be redacted; output: $out"
  fi
}

test_passes_through_normal_var() {
  test_case "censor-env preserves normal env vars"
  local out
  out=$(env -i HOME=/tmp PATH=/usr/bin:/bin:/usr/local/bin MY_PROJECT=hello-world "$CENSOR_ENV" 2>&1) || true
  if [[ "$out" == *"MY_PROJECT=hello-world"* ]]; then
    pass
  else
    fail "Normal var should be preserved; output: $out"
  fi
}

# ============================================================================
# Run tests
# ============================================================================

test_suite "censor-env script" \
  test_censor_env_exists \
  test_censor_env_executable \
  test_censor_env_help_flag \
  test_censor_env_h_flag \
  test_censors_api_key \
  test_censors_token \
  test_censors_password \
  test_censors_secret \
  test_censors_long_token_pattern \
  test_censors_user_path \
  test_censors_email_addresses \
  test_censors_ip_addresses \
  test_passes_through_normal_var
