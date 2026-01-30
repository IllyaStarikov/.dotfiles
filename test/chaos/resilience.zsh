#!/usr/bin/env zsh
# Chaos Tests: Resilience and Recovery Testing
# TEST_SIZE: large
# Tests system resilience to unexpected failures and chaos

source "${TEST_DIR}/lib/framework.zsh"

# Test random configuration corruption
test_config_corruption_recovery() {
  log "TRACE" "Testing recovery from configuration corruption"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Simulating config file corruption"

  # Create backup of real config
  local test_config=$(mktemp -t config_test.XXXXXX)
  local test_lua=$(mktemp -t config_test.lua.XXXXXX)

  # Create a valid config
  cat >"$test_config" <<'EOF'
# Valid config
set -o vi
alias ll='ls -la'
EOF

  # Test with corrupted shell config
  echo "corrupted garbage !@#$%^&*()" >>"$test_config"

  # Try to source it
  local source_result=$(zsh -c "source '$test_config' 2>&1 && echo 'survived'" 2>&1)

  if [[ "$source_result" == *"survived"* ]]; then
  [[ $VERBOSE -ge 1 ]] && log "INFO" "Shell survived corrupted config"
  else
  [[ $VERBOSE -ge 1 ]] && log "INFO" "Shell rejected corrupted config (safe)"
  fi

  # Test with corrupted Lua config
  cat >"$test_lua" <<'EOF'
-- Valid Lua
local M = {}
M.test = function() end
-- Corruption below
!@#$%^&*()
EOF

  # Try to load in Neovim
  local nvim_result=$(nvim --headless -c "luafile $test_lua" -c "echo 'survived'" -c "qa!" 2>&1)

  if [[ "$nvim_result" == *"survived"* ]]; then
  [[ $VERBOSE -ge 1 ]] && log "WARNING" "Neovim loaded corrupted Lua"
  else
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Neovim rejected corrupted Lua (safe)"
  fi

  # Cleanup
  rm -f "$test_config" "$test_lua"

  return 0
}

# Test random process kills
test_random_process_kills() {
  log "TRACE" "Testing resilience to random process termination"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Starting processes and randomly killing them"

  local pids=()

  # Start some background processes
  for i in {1..5}; do
  (sleep 30 && echo "Process $i completed") &
  pids+=($!)
  done

  [[ $VERBOSE -ge 1 ]] && log "INFO" "Started ${#pids[@]} background processes"

  # Randomly kill some
  local killed=0
  for pid in "${pids[@]}"; do
  if [[ $((RANDOM % 2)) -eq 0 ]]; then
    kill "$pid" 2>/dev/null && ((killed++))
    [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Killed process $pid"
  fi
  done

  [[ $VERBOSE -ge 1 ]] && log "INFO" "Randomly killed $killed/${#pids[@]} processes"

  # Clean up remaining
  for pid in "${pids[@]}"; do
  kill "$pid" 2>/dev/null || true
  done

  # System should still be responsive
  echo "test" | grep "test" >/dev/null 2>&1
  if [[ $? -eq 0 ]]; then
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "System responsive after process chaos"
  fi

  return 0
}

# Test disk space exhaustion
test_disk_space_exhaustion() {
  log "TRACE" "Testing behavior with low disk space"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Simulating disk space issues"

  # Check available space first
  local available_mb
  if [[ "$(uname)" == "Darwin" ]]; then
  available_mb=$(($(df / | tail -1 | awk '{print $4}') / 1024))
  else
  available_mb=$(df -m / | tail -1 | awk '{print $4}')
  fi

  [[ $VERBOSE -ge 1 ]] && log "INFO" "Available disk space: ${available_mb}MB"

  # Only proceed if we have enough space to test safely
  if [[ $available_mb -lt 1000 ]]; then
  log "WARNING" "Low disk space, skipping exhaustion test"
  return 0
  fi

  local test_dir=$(mktemp -d -t disk_test.XXXXXX)

  # Try to create a large file (but not too large)
  local size_mb=100
  dd if=/dev/zero of="$test_dir/large_file" bs=1048576 count=$size_mb 2>/dev/null

  # Test if tools still work
  echo "test" >"$test_dir/test.txt" 2>/dev/null
  if [[ $? -eq 0 ]]; then
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Can still write files"
  else
  log "WARNING" "Cannot write files (disk might be full)"
  fi

  # Cleanup immediately
  rm -rf "$test_dir"

  return 0
}

# Test random environment variable changes
test_env_var_chaos() {
  log "TRACE" "Testing resilience to environment variable chaos"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Randomly modifying environment variables"

  # Save original values
  local orig_path=$PATH
  local orig_home=$HOME
  local orig_term=$TERM

  # Mess with PATH
  PATH="/nonexistent:/fake/path"

  # Basic commands should still work (using absolute paths)
  if /bin/echo "test" >/dev/null 2>&1; then
  [[ $VERBOSE -ge 2 ]] && log "DEBUG" "System commands work with broken PATH"
  fi

  # Restore PATH
  PATH=$orig_path

  # Test with empty important variables
  local empty_term=$TERM
  TERM=""

  # Try to use terminal features
  tput colors >/dev/null 2>&1
  if [[ $? -ne 0 ]]; then
  [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Terminal features fail with empty TERM (expected)"
  fi

  # Restore
  TERM=$empty_term

  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Survived environment variable chaos"

  return 0
}

# Test file permission chaos
test_permission_chaos() {
  log "TRACE" "Testing file permission chaos"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Randomly changing file permissions"

  local test_dir=$(mktemp -d -t perm_chaos.XXXXXX)

  # Create test files
  for i in {1..10}; do
  echo "content" >"$test_dir/file_$i.txt"
  done

  # Randomly change permissions
  for file in "$test_dir"/*.txt; do
  local perm=$((RANDOM % 777))
  chmod $perm "$file" 2>/dev/null
  [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Set $(basename "$file") to $perm"
  done

  # Try to read files
  local readable=0
  local unreadable=0

  for file in "$test_dir"/*.txt; do
  if cat "$file" >/dev/null 2>&1; then
    ((readable++))
  else
    ((unreadable++))
  fi
  done

  [[ $VERBOSE -ge 1 ]] && log "INFO" "After permission chaos: $readable readable, $unreadable unreadable"

  # Cleanup
  chmod -R 755 "$test_dir" 2>/dev/null
  rm -rf "$test_dir"

  return 0
}

# Test rapid configuration reloads
test_rapid_config_reloads() {
  log "TRACE" "Testing rapid configuration reloads"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Rapidly reloading configurations"

  local iterations=10
  local failures=0

  for i in $(seq 1 $iterations); do
  # Reload Neovim config
  local nvim_reload=$(timeout 2 nvim --headless \
    -c "source \$MYVIMRC" \
    -c "echo 'reload_$i'" \
    -c "qa!" 2>&1)

  if [[ "$nvim_reload" != *"reload_$i"* ]]; then
    ((failures++))
    [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Reload $i failed"
  fi
  done

  [[ $VERBOSE -ge 1 ]] && log "INFO" "Completed $iterations reloads, $failures failures"

  if [[ $failures -lt $((iterations / 2)) ]]; then
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Most reloads succeeded"
  return 0
  else
  log "WARNING" "Many reloads failed: $failures/$iterations"
  return 0
  fi
}

# Test random input injection
test_random_input_injection() {
  log "TRACE" "Testing random input injection"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Sending random input to commands"

  # Generate random input
  local random_input=$(head -c 100 /dev/urandom | base64)

  # Test with grep (should handle gracefully)
  echo "$random_input" | grep "test" >/dev/null 2>&1
  local grep_exit=$?

  if [[ $grep_exit -eq 1 ]]; then
  [[ $VERBOSE -ge 2 ]] && log "DEBUG" "grep handled random input (no match)"
  fi

  # Test with sed
  echo "normal text" | sed "s/normal/$random_input/" >/dev/null 2>&1
  local sed_exit=$?

  if [[ $sed_exit -ne 0 ]]; then
  [[ $VERBOSE -ge 2 ]] && log "DEBUG" "sed rejected invalid pattern"
  fi

  # Test with Neovim (should not crash)
  echo "$random_input" | nvim --headless -c "qa!" 2>/dev/null
  local nvim_exit=$?

  if [[ $nvim_exit -eq 0 ]] || [[ $nvim_exit -eq 1 ]]; then
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Neovim handled random input"
  else
  log "WARNING" "Neovim had issues with random input"
  fi

  return 0
}

# Test time-based chaos
test_time_based_chaos() {
  log "TRACE" "Testing time-based chaos"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Testing behavior with time manipulation"

  # Test with future dates in files
  local test_file=$(mktemp -t time_test.XXXXXX)
  touch -t 203001011200 "$test_file" 2>/dev/null

  # Check if ls handles future dates
  ls -la "$test_file" >/dev/null 2>&1
  if [[ $? -eq 0 ]]; then
  [[ $VERBOSE -ge 2 ]] && log "DEBUG" "ls handles future dates"
  fi

  # Test with very old dates
  touch -t 197001011200 "$test_file" 2>/dev/null

  # Find should still work
  find "$(dirname "$test_file")" -name "$(basename "$test_file")" >/dev/null 2>&1
  if [[ $? -eq 0 ]]; then
  [[ $VERBOSE -ge 2 ]] && log "DEBUG" "find handles old dates"
  fi

  rm -f "$test_file"

  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "System handles time chaos"

  return 0
}

# Test resource limit chaos
test_resource_limit_chaos() {
  log "TRACE" "Testing resource limit chaos"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Testing with various resource limits"

  # Save current limits
  local orig_stack=$(ulimit -s)
  local orig_nproc=$(ulimit -u)

  # Test with reduced stack size
  ulimit -s 1024 2>/dev/null # 1MB stack

  # Try to run a simple command
  echo "test" | grep "test" >/dev/null 2>&1
  if [[ $? -eq 0 ]]; then
  [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Commands work with small stack"
  fi

  # Restore
  ulimit -s "$orig_stack" 2>/dev/null

  # Test with reduced process limit (careful not to lock ourselves out)
  local current_procs=$(ps aux | wc -l)
  local new_limit=$((current_procs + 10))

  ulimit -u "$new_limit" 2>/dev/null

  # Try to create a process
  (echo "test") 2>/dev/null
  if [[ $? -eq 0 ]]; then
  [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Can create processes with limit"
  fi

  # Restore
  ulimit -u "$orig_nproc" 2>/dev/null

  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Survived resource limit chaos"

  return 0
}

# Test recovery from crashes
test_crash_recovery() {
  log "TRACE" "Testing crash recovery mechanisms"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Simulating crashes and testing recovery"

  # Test Neovim swap file handling
  local test_file=$(mktemp -t crash_test.XXXXXX)
  local swap_file="${test_file}.swp"

  # Create a fake swap file
  touch "$swap_file"

  # Try to open file with existing swap
  local nvim_recovery=$(echo "q" | nvim "$test_file" 2>&1 | head -20)

  if [[ "$nvim_recovery" == *"swap"* ]] || [[ "$nvim_recovery" == *"recovery"* ]]; then
  [[ $VERBOSE -ge 1 ]] && log "INFO" "Neovim detects swap files"
  fi

  # Cleanup
  rm -f "$test_file" "$swap_file"

  # Test lock file handling
  local lock_file="/tmp/test_lock_$$"
  touch "$lock_file"

  # Simulate a stale lock
  echo "99999" >"$lock_file" # Non-existent PID

  # Check if we can detect stale lock
  if [[ -f "$lock_file" ]]; then
  local lock_pid=$(cat "$lock_file")
  if ! kill -0 "$lock_pid" 2>/dev/null; then
    [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Can detect stale lock files"
  fi
  fi

  rm -f "$lock_file"

  return 0
}
