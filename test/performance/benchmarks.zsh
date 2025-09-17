#!/usr/bin/env zsh
# Performance Tests: Benchmarks and Performance Regression Tests
# TEST_SIZE: large

source "${TEST_DIR}/lib/framework.zsh"

# Performance thresholds (in milliseconds)
readonly NVIM_STARTUP_THRESHOLD=300
readonly ZSH_STARTUP_THRESHOLD=500
readonly THEME_SWITCH_THRESHOLD=500
readonly PLUGIN_LOAD_THRESHOLD=500
readonly MEMORY_LIMIT_MB=200

test_neovim_startup_time() {
  log "TRACE" "Benchmarking Neovim startup time"

  local startup_log=$(mktemp)
  local start_time=$(date +%s%N)

  nvim --startuptime "$startup_log" -c "qa!" 2>/dev/null

  local end_time=$(date +%s%N)
  local duration=$(((end_time - start_time) / 1000000))

  # Parse the actual startup time from Neovim's log
  local nvim_time=$(grep "NVIM STARTED" "$startup_log" | awk '{print $1}' | cut -d'.' -f1)

  log "INFO" "Neovim startup time: ${nvim_time}ms (threshold: ${NVIM_STARTUP_THRESHOLD}ms)"

  if [[ $nvim_time -gt $NVIM_STARTUP_THRESHOLD ]]; then
    log "ERROR" "Neovim startup exceeds threshold: ${nvim_time}ms > ${NVIM_STARTUP_THRESHOLD}ms"

    # Show slowest items
    log "DEBUG" "Slowest startup items:"
    tail -20 "$startup_log" | grep -E "^[0-9]+" | sort -rn | head -5

    rm -f "$startup_log"
    return 1
  fi

  rm -f "$startup_log"
  return 0
}

test_zsh_startup_time() {
  log "TRACE" "Benchmarking Zsh startup time"

  local total_time=0
  local iterations=5

  for i in {1..$iterations}; do
    local start_time=$(date +%s%N)
    zsh -i -c "exit" 2>/dev/null
    local end_time=$(date +%s%N)
    local duration=$(((end_time - start_time) / 1000000))
    total_time=$((total_time + duration))
  done

  local avg_time=$((total_time / iterations))

  log "INFO" "Zsh average startup time: ${avg_time}ms (threshold: ${ZSH_STARTUP_THRESHOLD}ms)"

  if [[ $avg_time -gt $ZSH_STARTUP_THRESHOLD ]]; then
    log "ERROR" "Zsh startup exceeds threshold: ${avg_time}ms > ${ZSH_STARTUP_THRESHOLD}ms"
    return 1
  fi

  return 0
}

test_theme_switch_performance() {
  log "TRACE" "Benchmarking theme switching performance"

  local theme_script="$DOTFILES_DIR/src/theme-switcher/switch-theme.sh"

  if [[ ! -x "$theme_script" ]]; then
    log "WARNING" "Theme switcher not found"
    return 77 # Skip
  fi

  local start_time=$(date +%s%N)
  "$theme_script" --dry-run dark 2>/dev/null
  local end_time=$(date +%s%N)
  local duration=$(((end_time - start_time) / 1000000))

  log "INFO" "Theme switch time: ${duration}ms (threshold: ${THEME_SWITCH_THRESHOLD}ms)"

  if [[ $duration -gt $THEME_SWITCH_THRESHOLD ]]; then
    log "ERROR" "Theme switch exceeds threshold: ${duration}ms > ${THEME_SWITCH_THRESHOLD}ms"
    return 1
  fi

  return 0
}

test_neovim_plugin_loading() {
  log "TRACE" "Testing Neovim plugin loading performance"

  local output=$(timeout 10 nvim --headless -c "
        lua vim.defer_fn(function()
            local lazy_ok, lazy = pcall(require, 'lazy')
            if lazy_ok then
                local stats = lazy.stats()
                print('loaded:' .. stats.loaded .. ' time:' .. stats.startuptime)
            else
                print('lazy-not-available')
            end
            vim.cmd('qa!')
        end, 2000)
    " 2>&1)

  if [[ "$output" == *"lazy-not-available"* ]]; then
    log "WARNING" "Lazy.nvim not available for plugin performance test"
    return 77 # Skip
  fi

  local load_time=$(echo "$output" | grep -o "time:[0-9]*" | cut -d':' -f2)

  if [[ -n "$load_time" ]]; then
    log "INFO" "Plugin load time: ${load_time}ms (threshold: ${PLUGIN_LOAD_THRESHOLD}ms)"

    if [[ $load_time -gt $PLUGIN_LOAD_THRESHOLD ]]; then
      log "ERROR" "Plugin loading exceeds threshold: ${load_time}ms > ${PLUGIN_LOAD_THRESHOLD}ms"
      return 1
    fi
  fi

  return 0
}

test_memory_usage() {
  log "TRACE" "Testing memory usage"

  # Start Neovim and measure memory
  local nvim_pid
  nvim --headless -c "lua vim.defer_fn(function() end, 5000)" &
  nvim_pid=$!

  sleep 2

  if [[ "$(uname)" == "Darwin" ]]; then
    local memory_kb=$(ps -o rss= -p $nvim_pid 2>/dev/null || echo 0)
    local memory_mb=$((memory_kb / 1024))
  else
    local memory_kb=$(ps -o rss= -p $nvim_pid 2>/dev/null || echo 0)
    local memory_mb=$((memory_kb / 1024))
  fi

  kill $nvim_pid 2>/dev/null || true
  wait $nvim_pid 2>/dev/null || true

  log "INFO" "Neovim memory usage: ${memory_mb}MB (limit: ${MEMORY_LIMIT_MB}MB)"

  if [[ $memory_mb -gt $MEMORY_LIMIT_MB ]]; then
    log "ERROR" "Memory usage exceeds limit: ${memory_mb}MB > ${MEMORY_LIMIT_MB}MB"
    return 1
  fi

  return 0
}

test_file_operation_performance() {
  log "TRACE" "Testing file operation performance"

  local test_file=$(mktemp)
  local large_content=$(head -c 1048576 /dev/urandom | base64) # 1MB of data

  # Test write performance
  local write_start=$(date +%s%N)
  echo "$large_content" >"$test_file"
  local write_end=$(date +%s%N)
  local write_time=$(((write_end - write_start) / 1000000))

  # Test read performance
  local read_start=$(date +%s%N)
  cat "$test_file" >/dev/null
  local read_end=$(date +%s%N)
  local read_time=$(((read_end - read_start) / 1000000))

  rm -f "$test_file"

  log "INFO" "File write time: ${write_time}ms, read time: ${read_time}ms"

  if [[ $write_time -gt 1000 ]] || [[ $read_time -gt 500 ]]; then
    log "WARNING" "File operations may be slow"
  fi

  return 0
}

test_concurrent_operations() {
  log "TRACE" "Testing concurrent operations performance"

  local pids=()
  local start_time=$(date +%s%N)

  # Start multiple Neovim instances
  for i in {1..5}; do
    nvim --headless -c "qa!" &
    pids+=($!)
  done

  # Wait for all to complete
  for pid in "${pids[@]}"; do
    wait $pid
  done

  local end_time=$(date +%s%N)
  local duration=$(((end_time - start_time) / 1000000))

  log "INFO" "Concurrent startup time for 5 instances: ${duration}ms"

  if [[ $duration -gt 2000 ]]; then
    log "WARNING" "Concurrent operations may be slow: ${duration}ms"
  fi

  return 0
}

test_command_completion_performance() {
  log "TRACE" "Testing command completion performance"

  # Test zsh completion performance
  local start_time=$(date +%s%N)
  zsh -c "
        source $DOTFILES_DIR/src/zsh/zshrc 2>/dev/null || true
        compinit 2>/dev/null || true
    " 2>/dev/null
  local end_time=$(date +%s%N)
  local duration=$(((end_time - start_time) / 1000000))

  log "INFO" "Completion initialization time: ${duration}ms"

  if [[ $duration -gt 1000 ]]; then
    log "WARNING" "Completion initialization may be slow: ${duration}ms"
  fi

  return 0
}

test_script_execution_performance() {
  log "TRACE" "Testing script execution performance"

  local scripts_to_test=(
    "$DOTFILES_DIR/src/scripts/fixy"
    "$DOTFILES_DIR/src/scripts/update-dotfiles"
  )

  for script in "${scripts_to_test[@]}"; do
    if [[ ! -x "$script" ]]; then
      continue
    fi

    local basename=$(basename "$script")
    local start_time=$(date +%s%N)
    "$script" --help 2>/dev/null || true
    local end_time=$(date +%s%N)
    local duration=$(((end_time - start_time) / 1000000))

    log "INFO" "$basename execution time: ${duration}ms"

    if [[ $duration -gt 500 ]]; then
      log "WARNING" "$basename may be slow to start: ${duration}ms"
    fi
  done

  return 0
}

test_regression_neovim_startup() {
  log "TRACE" "Checking for Neovim startup regression"

  local baseline_file="$TEST_SNAPSHOTS/nvim_startup_baseline.txt"
  local current_log=$(mktemp)

  nvim --startuptime "$current_log" -c "qa!" 2>/dev/null
  local current_time=$(grep "NVIM STARTED" "$current_log" | awk '{print $1}' | cut -d'.' -f1)

  if [[ -f "$baseline_file" ]]; then
    local baseline_time=$(cat "$baseline_file")
    local regression_threshold=$((baseline_time * 120 / 100)) # 20% regression allowed

    log "INFO" "Current: ${current_time}ms, Baseline: ${baseline_time}ms, Threshold: ${regression_threshold}ms"

    if [[ $current_time -gt $regression_threshold ]]; then
      log "ERROR" "Performance regression detected: ${current_time}ms > ${regression_threshold}ms"
      rm -f "$current_log"
      return 1
    fi
  else
    # Save baseline
    echo "$current_time" >"$baseline_file"
    log "INFO" "Baseline saved: ${current_time}ms"
  fi

  rm -f "$current_log"
  return 0
}
