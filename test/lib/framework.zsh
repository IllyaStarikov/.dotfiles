#!/usr/bin/env zsh
#
# framework.zsh - Test framework shim
#
# DESCRIPTION:
#   Compatibility wrapper around test_helpers.zsh for tests that were
#   originally written against an older "framework.zsh" file. Provides:
#     - All assertions and pass/fail/skip functions from test_helpers.zsh
#     - log() function with TRACE/DEBUG/INFO/SUCCESS/WARN/ERROR levels
#     - TEST_SNAPSHOTS / TEST_WORKSPACE default paths
#
#   New tests should source test_helpers.zsh directly. This file exists
#   to keep older tests in test/smoke/, test/integration/,
#   test/performance/, test/e2e/, test/stress/, and test/security_test.zsh
#   working without rewriting them all at once.

# Source the canonical test helpers (provides assertions, pass/fail/skip,
# describe, test_case, test_suite, etc.).
source "${0:A:h}/test_helpers.zsh"

# Snapshot of functions already defined when framework.zsh is sourced.
# run_test_functions() uses this to filter out helper functions like
# test_case/test_command_exists when discovering "test_*" functions
# in the calling file.
typeset -gA __FRAMEWORK_PREEXISTING_FUNCS=()
typeset __framework_func
for __framework_func in ${(k)functions}; do
  __FRAMEWORK_PREEXISTING_FUNCS[$__framework_func]=1
done
unset __framework_func

# Default workspace and snapshot directories used by older tests.
: "${TEST_WORKSPACE:=${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}/workspace}"
: "${TEST_SNAPSHOTS:=${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}/snapshots}"
mkdir -p "$TEST_WORKSPACE" "$TEST_SNAPSHOTS" 2>/dev/null

# Logging compatibility shim. Older tests call log "TRACE"/"WARNING" which
# the runner's log() doesn't recognize; map them to DEBUG/WARN.
if ! (( $+functions[log] )); then
  log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%H:%M:%S')

    case "$level" in
      TRACE | DEBUG)
        [[ ${DEBUG:-0} -eq 1 ]] && echo "[DEBUG] ${timestamp} - $message" >&2
        ;;
      INFO)
        echo "[INFO] ${timestamp} - $message"
        ;;
      SUCCESS)
        echo "[SUCCESS] $message"
        ;;
      WARN | WARNING)
        echo "[WARN] ${timestamp} - $message" >&2
        ;;
      ERROR)
        echo "[ERROR] ${timestamp} - $message" >&2
        ;;
      *)
        echo "$message"
        ;;
    esac
  }
fi

# Run every test_* function defined AFTER framework.zsh was sourced.
# Older test files define test_* functions but rely on a runner to invoke
# them. Call this at the bottom of each such file. Functions defined by
# test_helpers.zsh (test_case, test_command_exists, ...) are skipped via
# __FRAMEWORK_PREEXISTING_FUNCS.
run_test_functions() {
  local func
  local -a test_funcs
  for func in ${(k)functions}; do
    [[ "$func" == test_* ]] || continue
    [[ -n "${__FRAMEWORK_PREEXISTING_FUNCS[$func]:-}" ]] && continue
    test_funcs+=("$func")
  done

  # Sort for deterministic order.
  test_funcs=(${(o)test_funcs})

  for func in "${test_funcs[@]}"; do
    test_case "$func"
    if "$func"; then
      pass
    fi
  done
}
