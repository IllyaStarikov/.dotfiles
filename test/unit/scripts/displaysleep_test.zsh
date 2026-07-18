#!/usr/bin/env zsh
# Test suite for the displaysleep script
# Tests only side-effect-free paths. NEVER invoke displaysleep with no args:
# a bare run starts the loop and actually sleeps the display.

# Test framework
source "$(dirname "$0")/../../lib/test_helpers.zsh"

# Script under test
SCRIPT="${DOTFILES_DIR}/src/scripts/displaysleep"

# Hard wall-clock cap for any invocation, so a regression that makes an error
# path hang can never stall the whole suite. The exercised paths (--help,
# unknown flag, bad value) all exit immediately well before the cap.
if command -v gtimeout >/dev/null 2>&1; then
  _CAP=(gtimeout --kill-after=1 3)
elif command -v timeout >/dev/null 2>&1; then
  _CAP=(timeout --kill-after=1 3)
else
  _CAP=()
fi

# Run under the cap, capturing combined output via a temp file (never command
# substitution on a pipe, which can block on leaked children).
_run() {
  local out="${TEST_TMP_DIR}/_displaysleep_out.$$"
  "${_CAP[@]}" "$@" >"${out}" 2>&1 </dev/null
  cat "${out}" 2>/dev/null
  rm -f "${out}"
}

describe "displaysleep"

test_exists_executable() {
  test_case "displaysleep: exists and is executable"
  if [[ -f "${SCRIPT}" && -x "${SCRIPT}" ]]; then
    pass "Present and executable"
  else
    fail "Missing or not executable: ${SCRIPT}"
  fi
}

test_syntax() {
  test_case "displaysleep: passes zsh -n syntax check"
  if zsh -n "${SCRIPT}" 2>/dev/null; then
    pass "Valid syntax"
  else
    fail "Syntax error"
  fi
}

test_help() {
  test_case "displaysleep: --help shows usage"
  local output
  output=$(_run "${SCRIPT}" --help || true)
  if [[ "${output}" == *"displaysleep"* || "${output}" == *"Usage"* ]]; then
    pass "Help displayed"
  else
    fail "No help output"
  fi
}

test_unknown_flag() {
  test_case "displaysleep: rejects unknown options"
  local output
  output=$(_run "${SCRIPT}" --definitely-not-a-flag || true)
  if [[ "${output}" == *"Unknown"* ]]; then
    pass "Unknown option rejected"
  else
    fail "No error for unknown option"
  fi
}

test_invalid_numeric() {
  test_case "displaysleep: rejects non-numeric timeout"
  local output
  output=$(_run "${SCRIPT}" --timeout abc || true)
  if [[ "${output}" == *"Invalid"* ]]; then
    pass "Non-numeric value rejected"
  else
    fail "No error for non-numeric --timeout"
  fi
}

test_sources_common() {
  test_case "displaysleep: sources common.sh"
  if grep -q "source.*common.sh" "${SCRIPT}"; then
    pass "Sources shared library"
  else
    fail "Does not source common.sh"
  fi
}

# Explicitly run each test (run_tests only prints the summary; it does not
# discover test_* functions).
test_exists_executable
test_syntax
test_help
test_unknown_flag
test_invalid_numeric
test_sources_common

run_tests
