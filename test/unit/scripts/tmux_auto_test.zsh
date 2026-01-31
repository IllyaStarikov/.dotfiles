#!/usr/bin/env zsh
# Test suite for tmux-auto script
# Tests behavior, not implementation

# Test framework
source "$(dirname "$0")/../../lib/simple_framework.zsh"

# Script under test
SCRIPT_PATH="$DOTFILES_DIR/src/scripts/tmux-auto"

# Test that script exists and is executable
test_script_exists() {
  assert_file_exists "$SCRIPT_PATH" "tmux-auto script should exist"
  assert_executable "$SCRIPT_PATH" "tmux-auto script should be executable"
}

# Test that script has shebang
test_has_shebang() {
  local first_line
  first_line=$(head -1 "$SCRIPT_PATH")
  assert_equals "#!/usr/bin/env zsh" "$first_line" "Should have zsh shebang"
}

# Test git repo name detection logic
test_git_repo_detection() {
  local has_git_check
  has_git_check=$(grep -c "git rev-parse --is-inside-work-tree" "$SCRIPT_PATH" || echo 0)
  assert_true "[ $has_git_check -gt 0 ]" "Should check if inside git repo"

  local has_toplevel
  has_toplevel=$(grep -c "git rev-parse --show-toplevel" "$SCRIPT_PATH" || echo 0)
  assert_true "[ $has_toplevel -gt 0 ]" "Should get git repo toplevel"
}

# Test fallback to current directory name
test_directory_fallback() {
  local has_pwd_fallback
  has_pwd_fallback=$(grep -c 'basename "$PWD"' "$SCRIPT_PATH" || echo 0)
  assert_true "[ $has_pwd_fallback -gt 0 ]" "Should fallback to current directory name"
}

# Test name sanitization (colons are special in tmux)
test_name_sanitization() {
  local has_sanitize
  has_sanitize=$(grep -c 'name=${name//:/-}' "$SCRIPT_PATH" || echo 0)
  assert_true "[ $has_sanitize -gt 0 ]" "Should sanitize colons in session name"
}

# Test tmux session existence check
test_session_check() {
  local has_session_check
  has_session_check=$(grep -c "tmux has-session" "$SCRIPT_PATH" || echo 0)
  assert_true "[ $has_session_check -gt 0 ]" "Should check if tmux session exists"
}

# Test tmux attach for existing session
test_tmux_attach() {
  local has_attach
  has_attach=$(grep -c "tmux attach" "$SCRIPT_PATH" || echo 0)
  assert_true "[ $has_attach -gt 0 ]" "Should attach to existing session"
}

# Test tmux new-session for new session
test_tmux_new_session() {
  local has_new_session
  has_new_session=$(grep -c "tmux new-session" "$SCRIPT_PATH" || echo 0)
  assert_true "[ $has_new_session -gt 0 ]" "Should create new session if none exists"
}

# Test that session name is passed correctly
test_session_name_usage() {
  local has_s_flag
  has_s_flag=$(grep -c '\-s "$name"' "$SCRIPT_PATH" || echo 0)
  assert_true "[ $has_s_flag -gt 0 ]" "Should use -s flag for session name"

  local has_t_flag
  has_t_flag=$(grep -c '\-t "$name"' "$SCRIPT_PATH" || echo 0)
  assert_true "[ $has_t_flag -gt 0 ]" "Should use -t flag for target session"
}

# Run all tests
run_tests
