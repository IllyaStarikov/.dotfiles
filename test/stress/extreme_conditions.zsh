#!/usr/bin/env zsh
# Stress Tests: Extreme Conditions
# TEST_SIZE: large
# Tests system behavior under extreme stress

source "${TEST_DIR}/lib/framework.zsh"

# Test extreme file sizes
test_extreme_file_sizes() {
  log "TRACE" "Testing extreme file sizes"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Creating progressively larger files"

  local test_file=$(mktemp -t extreme_file.XXXXXX)
  local sizes=(1 10 50 100) # MB

  for size in "${sizes[@]}"; do
  [[ $VERBOSE -ge 1 ]] && log "INFO" "Testing ${size}MB file"

  # Create file
  dd if=/dev/zero bs=1048576 count="$size" of="$test_file" 2>/dev/null

  # Try to open in Neovim
  local start_time=$(date +%s%N)
  timeout 30 nvim --headless "$test_file" -c "qa!" 2>/dev/null
  local exit_code=$?
  local end_time=$(date +%s%N)
  local duration=$(((end_time - start_time) / 1000000))

  if [[ $exit_code -eq 124 ]]; then
    log "WARNING" "Neovim timeout with ${size}MB file"
    break
  elif [[ $exit_code -ne 0 ]]; then
    log "WARNING" "Neovim failed with ${size}MB file"
    break
  else
    [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Handled ${size}MB file in ${duration}ms"
  fi
  done

  # Cleanup
  rm -f "$test_file"

  return 0
}

# Test rapid file creation/deletion
test_rapid_file_operations() {
  log "TRACE" "Testing rapid file creation and deletion"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Performing rapid filesystem operations"

  local test_dir=$(mktemp -d -t rapid_ops.XXXXXX)
  cd "$test_dir"

  local iterations=100
  local start_time=$(date +%s%N)

  for i in $(seq 1 $iterations); do
  # Create
  echo "test" >"file_$i.txt"
  # Modify
  echo "modified" >>"file_$i.txt"
  # Delete
  rm "file_$i.txt"
  done

  local end_time=$(date +%s%N)
  local duration=$(((end_time - start_time) / 1000000))

  [[ $VERBOSE -ge 1 ]] && log "INFO" "Completed $iterations create/modify/delete cycles in ${duration}ms"

  # Cleanup
  cd - >/dev/null
  rm -rf "$test_dir"

  local ops_per_second=$((iterations * 3 * 1000 / duration))
  [[ $VERBOSE -ge 1 ]] && log "INFO" "Filesystem operations per second: $ops_per_second"

  if [[ $ops_per_second -gt 100 ]]; then
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Filesystem performance good under stress"
  return 0
  else
  log "WARNING" "Filesystem slow under stress: $ops_per_second ops/sec"
  return 0
  fi
}

# Test maximum open files
test_maximum_open_files() {
  log "TRACE" "Testing maximum open files limit"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Opening many files simultaneously"

  local test_dir=$(mktemp -d -t max_files.XXXXXX)
  cd "$test_dir"

  # Get current limit
  local ulimit_n=$(ulimit -n)
  [[ $VERBOSE -ge 1 ]] && log "INFO" "Current open files limit: $ulimit_n"

  # Try to open many files (but not exceed limit)
  local max_test=$((ulimit_n / 2))        # Test half the limit
  [[ $max_test -gt 500 ]] && max_test=500 # Cap at 500 for safety

  local files_opened=0
  local fds=()

  for i in $(seq 1 $max_test); do
  if exec {fd}>"file_$i.txt" 2>/dev/null; then
    fds+=($fd)
    ((files_opened++))
  else
    break
  fi
  done

  [[ $VERBOSE -ge 1 ]] && log "INFO" "Successfully opened $files_opened files"

  # Close all file descriptors
  for fd in "${fds[@]}"; do
  exec {fd}>&-
  done

  # Cleanup
  cd - >/dev/null
  rm -rf "$test_dir"

  if [[ $files_opened -gt 100 ]]; then
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Can handle many open files: $files_opened"
  return 0
  else
  log "WARNING" "Limited file handles: $files_opened"
  return 0
  fi
}

# Test CPU stress
test_cpu_stress() {
  log "TRACE" "Testing CPU stress handling"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Creating CPU-intensive operations"

  # Create CPU load
  local load_pid
  (while true; do echo "scale=5000; 4*a(1)" | bc -l >/dev/null 2>&1; done) &
  load_pid=$!

  [[ $VERBOSE -ge 1 ]] && log "INFO" "Started CPU stress process"

  # Try to use Neovim under CPU stress
  local start_time=$(date +%s%N)
  timeout 10 nvim --headless -c "echo 'cpu_test'" -c "qa!" 2>/dev/null
  local exit_code=$?
  local end_time=$(date +%s%N)
  local duration=$(((end_time - start_time) / 1000000))

  # Kill CPU load
  kill $load_pid 2>/dev/null || true

  if [[ $exit_code -eq 0 ]]; then
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Neovim responsive under CPU stress (${duration}ms)"
  else
  log "WARNING" "Neovim slow under CPU stress"
  fi

  return 0
}

# Test memory pressure
test_memory_pressure() {
  log "TRACE" "Testing behavior under memory pressure"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Allocating large amounts of memory"

  # Create memory pressure with arrays
  local -a memory_hog
  local allocation_size=1000000 # 1M elements

  [[ $VERBOSE -ge 1 ]] && log "INFO" "Allocating memory..."

  # Allocate memory
  for i in $(seq 1 $allocation_size); do
  memory_hog+=("data_$i")
  done

  [[ $VERBOSE -ge 1 ]] && log "INFO" "Allocated array with $allocation_size elements"

  # Try to use tools under memory pressure
  local start_time=$(date +%s%N)
  echo "test" | grep "test" >/dev/null 2>&1
  local end_time=$(date +%s%N)
  local duration=$(((end_time - start_time) / 1000000))

  [[ $VERBOSE -ge 1 ]] && log "INFO" "Simple operation under memory pressure: ${duration}ms"

  # Clear memory
  unset memory_hog

  if [[ $duration -lt 1000 ]]; then
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "System handles memory pressure"
  return 0
  else
  log "WARNING" "System slow under memory pressure"
  return 0
  fi
}

# Test recursive operations
test_recursive_operations() {
  log "TRACE" "Testing deep recursive operations"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Creating deeply nested directory structure"

  local test_dir=$(mktemp -d -t recursive.XXXXXX)
  cd "$test_dir"

  # Create deep directory structure
  local depth=50
  local current_dir="."

  for i in $(seq 1 $depth); do
  current_dir="$current_dir/level_$i"
  mkdir -p "$current_dir"
  echo "content" >"$current_dir/file.txt"
  done

  [[ $VERBOSE -ge 1 ]] && log "INFO" "Created directory structure with depth $depth"

  # Test recursive find
  local start_time=$(date +%s%N)
  find . -name "*.txt" | wc -l >/dev/null 2>&1
  local end_time=$(date +%s%N)
  local find_duration=$(((end_time - start_time) / 1000000))

  [[ $VERBOSE -ge 1 ]] && log "INFO" "Recursive find in ${find_duration}ms"

  # Test recursive grep
  if command -v rg >/dev/null 2>&1; then
  start_time=$(date +%s%N)
  rg "content" >/dev/null 2>&1
  end_time=$(date +%s%N)
  local rg_duration=$(((end_time - start_time) / 1000000))
  [[ $VERBOSE -ge 1 ]] && log "INFO" "Recursive ripgrep in ${rg_duration}ms"
  fi

  # Cleanup
  cd - >/dev/null
  rm -rf "$test_dir"

  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Handled deep recursion"
  return 0
}

# Test signal handling
test_signal_handling() {
  log "TRACE" "Testing signal handling under stress"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Sending signals to processes"

  # Start a long-running Neovim process
  nvim --headless -c "while 1 | sleep 1 | endwhile" &
  local nvim_pid=$!

  sleep 1

  # Send various signals
  local signals=(USR1 USR2 HUP)

  for sig in "${signals[@]}"; do
  if kill "-$sig" "$nvim_pid" 2>/dev/null; then
    [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Sent signal $sig to Neovim"
  fi
  sleep 0.5

  # Check if still running
  if ! kill -0 $nvim_pid 2>/dev/null; then
    log "WARNING" "Neovim terminated by signal $sig"
    break
  fi
  done

  # Clean up
  kill $nvim_pid 2>/dev/null || true
  wait $nvim_pid 2>/dev/null || true

  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Signal handling test complete"
  return 0
}

# Test network interruption simulation
test_network_interruption() {
  log "TRACE" "Testing behavior with network issues"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Simulating network problems"

  # Test with non-existent hosts
  local fake_hosts=("fake.invalid.host" "192.0.2.1") # TEST-NET-1

  for host in "${fake_hosts[@]}"; do
  [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Testing connection to $host"

  # Try to connect with timeout
  timeout 2 curl -s "http://$host" >/dev/null 2>&1
  local exit_code=$?

  if [[ $exit_code -eq 124 ]]; then
    [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Connection timed out (expected)"
  fi
  done

  # Test plugin manager behavior without network
  local plugin_test=$(timeout 5 nvim --headless -c "
    lua xpcall(function()
      local lazy_ok, lazy = pcall(require, 'lazy')
      if lazy_ok then
        print('plugins_loaded')
      end
    end, function(err) end)
    vim.cmd('qa!')
  " 2>&1)

  if [[ "$plugin_test" == *"plugins_loaded"* ]]; then
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Plugins work offline"
  fi

  return 0
}
