#!/usr/bin/env zsh
# Behavioral tests for tmux-auto.
#
# The previous incarnation of this file was almost entirely
# `grep -c '<pattern>' "$SCRIPT_PATH"` — refactor-fragile and prove-nothing
# checks that pass any time the literal text is present, regardless of
# whether the script actually behaves correctly. This rewrite invokes
# the script in controlled fixtures with a mocked `tmux` binary and
# asserts on observable behavior (exit code, captured tmux args).

source "$(dirname "$0")/../../lib/test_helpers.zsh"

SCRIPT_PATH="$DOTFILES_DIR/src/scripts/tmux-auto"

# Shared mock: replaces `tmux` on PATH with a script that records its
# argv into $MOCK_LOG and returns 0 for has-session (so the script
# always takes the "attach" branch and we capture the attach target).
setup_tmux_mock() {
  MOCK_DIR=$(mktemp -d -t tmux-auto-mock.XXXXXX)
  MOCK_LOG="$MOCK_DIR/calls.log"
  cat >"$MOCK_DIR/tmux" <<'MOCK'
#!/usr/bin/env bash
echo "tmux $*" >> "${MOCK_LOG:?}"
case "${1:-}" in
  has-session) exit 0 ;;
  *)           exit 0 ;;
esac
MOCK
  chmod +x "$MOCK_DIR/tmux"
  ORIGINAL_PATH="$PATH"
  export PATH="$MOCK_DIR:$PATH"
}

teardown_tmux_mock() {
  export PATH="$ORIGINAL_PATH"
  rm -rf "$MOCK_DIR"
}

# ---- Structural sanity (cheap, fast) --------------------------------------

test_script_exists() {
  assert_file_exists "$SCRIPT_PATH" "tmux-auto script should exist"
  assert_executable "$SCRIPT_PATH" "tmux-auto script should be executable"
}

test_has_shebang() {
  local first_line
  first_line=$(head -1 "$SCRIPT_PATH")
  assert_equals "#!/usr/bin/env zsh" "$first_line" "Should have zsh shebang"
}

# ---- Behavioral tests -----------------------------------------------------

# Too many positional args → usage error, exit 2.
test_rejects_extra_args() {
  setup_tmux_mock
  local output rc
  output=$("$SCRIPT_PATH" one two 2>&1)
  rc=$?
  teardown_tmux_mock
  assert_equals 2 "$rc" "Should exit 2 on too many args, got $rc"
  assert_contains "$output" "too many arguments" "Should print usage error"
}

# Session name derives from current dir's basename when not in a git repo.
test_session_name_from_dir() {
  setup_tmux_mock
  local work
  work=$(mktemp -d -t tmux-auto-work.XXXXXX)/myproject
  mkdir -p "$work"
  (cd "$work" && "$SCRIPT_PATH" >/dev/null 2>&1)
  teardown_tmux_mock
  # tmux mock recorded calls; first call should be `tmux has-session -t myproject`.
  if grep -q "has-session -t myproject" "$MOCK_LOG"; then
    pass "Derived session name 'myproject' from cwd basename"
  else
    fail "Expected has-session for 'myproject'; mock log: $(cat "$MOCK_LOG")"
  fi
  rm -rf "${work%/myproject}"
}

# Session name sanitizes dots and colons.
test_session_name_sanitization() {
  setup_tmux_mock
  local work
  work=$(mktemp -d -t tmux-auto-work.XXXXXX)
  local dotted="$work/.foo.bar"
  mkdir -p "$dotted"
  (cd "$dotted" && "$SCRIPT_PATH" >/dev/null 2>&1)
  teardown_tmux_mock
  # `.foo.bar` → strip leading dot → `foo.bar` → replace dots with `_` → `foo_bar`.
  if grep -q "has-session -t foo_bar" "$MOCK_LOG"; then
    pass "Sanitized .foo.bar → foo_bar"
  else
    fail "Expected has-session for 'foo_bar'; mock log: $(cat "$MOCK_LOG")"
  fi
  rm -rf "$work"
}

# Single path arg → cd into it before deriving the session name.
test_accepts_path_argument() {
  setup_tmux_mock
  local work
  work=$(mktemp -d -t tmux-auto-work.XXXXXX)/widget
  mkdir -p "$work"
  "$SCRIPT_PATH" "$work" >/dev/null 2>&1
  teardown_tmux_mock
  if grep -q "has-session -t widget" "$MOCK_LOG"; then
    pass "cd'd into path argument before deriving session name"
  else
    fail "Expected has-session for 'widget'; mock log: $(cat "$MOCK_LOG")"
  fi
  rm -rf "${work%/widget}"
}

# Run all tests
run_tests
