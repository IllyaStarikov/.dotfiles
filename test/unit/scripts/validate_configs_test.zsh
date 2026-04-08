#!/usr/bin/env zsh
# Unit tests for src/scripts/validate-configs

TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}"
mkdir -p "$TEST_TMP_DIR"

source "${TEST_DIR}/lib/test_helpers.zsh"

readonly VALIDATE_CONFIGS="${DOTFILES_DIR}/src/scripts/validate-configs"

# ============================================================================
# Existence and CLI surface
# ============================================================================

test_validate_configs_exists() {
  test_case "validate-configs script exists"
  assert_file_exists "$VALIDATE_CONFIGS" && pass
}

test_validate_configs_executable() {
  test_case "validate-configs is executable"
  assert_executable "$VALIDATE_CONFIGS" && pass
}

test_validate_configs_uses_zsh() {
  test_case "validate-configs has zsh shebang"
  local first_line
  first_line=$(head -1 "$VALIDATE_CONFIGS")
  if [[ "$first_line" == *zsh* ]]; then
    pass
  else
    fail "Expected zsh shebang, got: $first_line"
  fi
}

test_validate_configs_syntax() {
  test_case "validate-configs has valid zsh syntax"
  if zsh -n "$VALIDATE_CONFIGS" 2>/dev/null; then
    pass
  else
    fail "validate-configs has syntax errors"
  fi
}

# ============================================================================
# Behavior: runs and produces output
# ============================================================================

test_validate_configs_runs() {
  test_case "validate-configs runs without crashing"
  local out
  # The script may exit non-zero if any config is out of compliance.
  # We only care that it produces output and doesn't crash with an
  # unexpected error like 'command not found' or syntax errors.
  out=$("$VALIDATE_CONFIGS" 2>&1) || true
  if [[ -n "$out" ]]; then
    pass
  else
    fail "validate-configs produced no output"
  fi
}

test_validate_configs_mentions_standards() {
  test_case "validate-configs references standards.json"
  local out
  out=$("$VALIDATE_CONFIGS" 2>&1) || true
  if [[ "$out" == *standards.json* ]]; then
    pass
  else
    fail "Expected output to mention standards.json: $out"
  fi
}

test_validate_configs_checks_alacritty() {
  test_case "validate-configs checks Alacritty config"
  local out
  out=$("$VALIDATE_CONFIGS" 2>&1) || true
  if [[ "$out" == *Alacritty* ]] || [[ "$out" == *alacritty* ]]; then
    pass
  else
    fail "Expected output to mention Alacritty: $out"
  fi
}

test_validate_configs_checks_neovim() {
  test_case "validate-configs checks Neovim config"
  local out
  out=$("$VALIDATE_CONFIGS" 2>&1) || true
  if [[ "$out" == *Neovim* ]] || [[ "$out" == *neovim* ]] || [[ "$out" == *nvim* ]]; then
    pass
  else
    fail "Expected output to mention Neovim: $out"
  fi
}

test_validate_configs_checks_formatters() {
  test_case "validate-configs checks language formatters"
  local out
  out=$("$VALIDATE_CONFIGS" 2>&1) || true
  if [[ "$out" == *Ruff* ]] || [[ "$out" == *ruff* ]] \
    || [[ "$out" == *StyLua* ]] || [[ "$out" == *stylua* ]]; then
    pass
  else
    fail "Expected output to mention a formatter: $out"
  fi
}

test_validate_configs_summary_section() {
  test_case "validate-configs prints a check summary"
  local out
  out=$("$VALIDATE_CONFIGS" 2>&1) || true
  if [[ "$out" == *Passed* ]] || [[ "$out" == *Total* ]] || [[ "$out" == *Failed* ]]; then
    pass
  else
    fail "Expected a summary in output: $out"
  fi
}

# ============================================================================
# Run tests
# ============================================================================

test_suite "validate-configs script" \
  test_validate_configs_exists \
  test_validate_configs_executable \
  test_validate_configs_uses_zsh \
  test_validate_configs_syntax \
  test_validate_configs_runs \
  test_validate_configs_mentions_standards \
  test_validate_configs_checks_alacritty \
  test_validate_configs_checks_neovim \
  test_validate_configs_checks_formatters \
  test_validate_configs_summary_section
