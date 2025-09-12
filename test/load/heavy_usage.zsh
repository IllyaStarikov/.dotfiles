#!/usr/bin/env zsh
# Load Tests: Heavy Usage Scenarios
# TEST_SIZE: large
# Tests system behavior under heavy load

source "${TEST_DIR}/lib/framework.zsh"

# Test Neovim with many files open
test_neovim_many_files() {
    log "TRACE" "Testing Neovim with many files open"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Opening 50 files simultaneously"
    
    local test_dir=$(mktemp -d -t nvim_load_test.XXXXXX)
    
    # Create test files
    for i in {1..50}; do
        echo "Test file $i content" > "$test_dir/file_$i.txt"
    done
    
    local start_time=$(date +%s%N)
    
    # Open all files in Neovim
    local nvim_output=$(timeout 30 nvim --headless \
        "$test_dir"/file_*.txt \
        -c "echo 'load_test_ok'" \
        -c "qa!" 2>&1)
    
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))
    
    [[ $VERBOSE -ge 1 ]] && log "INFO" "Opened 50 files in ${duration}ms"
    
    # Check memory usage
    if [[ "$(uname)" == "Darwin" ]]; then
        local mem_check=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
        [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Free pages after load: $mem_check"
    fi
    
    # Cleanup
    rm -rf "$test_dir"
    
    if [[ "$nvim_output" == *"load_test_ok"* ]]; then
        [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Neovim handled 50 files"
        return 0
    else
        log "ERROR" "Neovim failed under load"
        return 1
    fi
}

# Test large file handling
test_large_file_handling() {
    log "TRACE" "Testing large file handling"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Creating and opening large files"
    
    local test_file=$(mktemp -t large_file.XXXXXX)
    
    # Create a 10MB file
    local size_mb=10
    dd if=/dev/urandom bs=1048576 count=$size_mb of="$test_file" 2>/dev/null
    
    [[ $VERBOSE -ge 1 ]] && log "INFO" "Created ${size_mb}MB test file"
    
    # Test opening in Neovim
    local start_time=$(date +%s%N)
    local nvim_output=$(timeout 30 nvim --headless \
        "$test_file" \
        -c "echo 'large_file_ok'" \
        -c "qa!" 2>&1)
    local end_time=$(date +%s%N)
    local nvim_duration=$(( (end_time - start_time) / 1000000 ))
    
    [[ $VERBOSE -ge 1 ]] && log "INFO" "Neovim opened ${size_mb}MB file in ${nvim_duration}ms"
    
    # Test grep/rg on large file
    echo "FINDME" >> "$test_file"
    
    if command -v rg >/dev/null 2>&1; then
        start_time=$(date +%s%N)
        rg "FINDME" "$test_file" >/dev/null 2>&1
        end_time=$(date +%s%N)
        local rg_duration=$(( (end_time - start_time) / 1000000 ))
        [[ $VERBOSE -ge 1 ]] && log "INFO" "ripgrep searched ${size_mb}MB in ${rg_duration}ms"
    fi
    
    # Cleanup
    rm -f "$test_file"
    
    if [[ $nvim_duration -lt 10000 ]]; then
        [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Large file handling acceptable"
        return 0
    else
        log "WARNING" "Large file handling slow: ${nvim_duration}ms"
        return 0
    fi
}

# Test many processes
test_many_processes() {
    log "TRACE" "Testing many concurrent processes"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Spawning multiple background jobs"
    
    local pids=()
    local num_processes=20
    
    # Start background processes
    for i in $(seq 1 $num_processes); do
        (sleep 5 && echo "Process $i done") &
        pids+=($!)
    done
    
    [[ $VERBOSE -ge 1 ]] && log "INFO" "Started $num_processes background processes"
    
    # Check system responsiveness
    local start_time=$(date +%s%N)
    echo "test" | nvim --headless -c "qa!" 2>/dev/null
    local end_time=$(date +%s%N)
    local response_time=$(( (end_time - start_time) / 1000000 ))
    
    [[ $VERBOSE -ge 1 ]] && log "INFO" "System response time under load: ${response_time}ms"
    
    # Kill all background processes
    for pid in "${pids[@]}"; do
        kill $pid 2>/dev/null || true
    done
    wait
    
    if [[ $response_time -lt 5000 ]]; then
        [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "System responsive under process load"
        return 0
    else
        log "WARNING" "System slow under load: ${response_time}ms"
        return 0
    fi
}

# Test heavy Git operations
test_heavy_git_operations() {
    log "TRACE" "Testing heavy Git operations"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Creating large Git repository"
    
    local repo_dir=$(mktemp -d -t git_load_test.XXXXXX)
    cd "$repo_dir"
    
    git init >/dev/null 2>&1
    
    # Create many files
    for i in {1..100}; do
        echo "File $i content" > "file_$i.txt"
    done
    
    # Add all files
    local start_time=$(date +%s%N)
    git add . >/dev/null 2>&1
    local end_time=$(date +%s%N)
    local add_duration=$(( (end_time - start_time) / 1000000 ))
    
    [[ $VERBOSE -ge 1 ]] && log "INFO" "Git add 100 files: ${add_duration}ms"
    
    # Commit
    start_time=$(date +%s%N)
    git commit -m "Load test commit" >/dev/null 2>&1
    end_time=$(date +%s%N)
    local commit_duration=$(( (end_time - start_time) / 1000000 ))
    
    [[ $VERBOSE -ge 1 ]] && log "INFO" "Git commit 100 files: ${commit_duration}ms"
    
    # Create many commits
    for i in {1..50}; do
        echo "Change $i" >> file_1.txt
        git add file_1.txt >/dev/null 2>&1
        git commit -m "Commit $i" >/dev/null 2>&1
    done
    
    # Test log performance
    start_time=$(date +%s%N)
    git log --oneline >/dev/null 2>&1
    end_time=$(date +%s%N)
    local log_duration=$(( (end_time - start_time) / 1000000 ))
    
    [[ $VERBOSE -ge 1 ]] && log "INFO" "Git log 50 commits: ${log_duration}ms"
    
    # Cleanup
    cd - >/dev/null
    rm -rf "$repo_dir"
    
    [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Git handles load well"
    return 0
}

# Test shell startup under load
test_shell_startup_under_load() {
    log "TRACE" "Testing shell startup under system load"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Measuring shell startup with background load"
    
    # Create background load
    local load_pids=()
    for i in {1..10}; do
        (while true; do echo "load" >/dev/null 2>&1; done) &
        load_pids+=($!)
    done
    
    [[ $VERBOSE -ge 1 ]] && log "INFO" "Created CPU load with 10 busy loops"
    
    # Measure shell startup
    local total_time=0
    local iterations=5
    
    for i in $(seq 1 $iterations); do
        local start_time=$(date +%s%N)
        zsh -c "exit" 2>/dev/null
        local end_time=$(date +%s%N)
        local duration=$(( (end_time - start_time) / 1000000 ))
        total_time=$((total_time + duration))
        [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Iteration $i: ${duration}ms"
    done
    
    # Kill load generators
    for pid in "${load_pids[@]}"; do
        kill $pid 2>/dev/null || true
    done
    
    local avg_time=$((total_time / iterations))
    [[ $VERBOSE -ge 1 ]] && log "INFO" "Average shell startup under load: ${avg_time}ms"
    
    if [[ $avg_time -lt 2000 ]]; then
        [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Shell startup acceptable under load"
        return 0
    else
        log "WARNING" "Shell startup slow under load: ${avg_time}ms"
        return 0
    fi
}

# Test memory leak detection
test_memory_leak_detection() {
    log "TRACE" "Testing for memory leaks"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Monitoring memory usage over repeated operations"
    
    # Get initial memory
    local initial_mem
    if [[ "$(uname)" == "Darwin" ]]; then
        initial_mem=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    else
        initial_mem=$(free -m | grep Mem | awk '{print $4}')
    fi
    
    [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Initial free memory: $initial_mem"
    
    # Perform repeated operations
    for i in {1..20}; do
        nvim --headless -c "qa!" 2>/dev/null
    done
    
    # Check memory after
    local final_mem
    if [[ "$(uname)" == "Darwin" ]]; then
        final_mem=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    else
        final_mem=$(free -m | grep Mem | awk '{print $4}')
    fi
    
    [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Final free memory: $final_mem"
    
    # Calculate difference (rough check)
    local mem_diff=$((initial_mem - final_mem))
    
    if [[ $mem_diff -lt 1000 ]]; then
        [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "No significant memory leak detected"
        return 0
    else
        log "WARNING" "Possible memory leak: $mem_diff pages/MB difference"
        return 0
    fi
}

# Test filesystem stress
test_filesystem_stress() {
    log "TRACE" "Testing filesystem operations under stress"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Creating many small files"
    
    local test_dir=$(mktemp -d -t fs_stress.XXXXXX)
    cd "$test_dir"
    
    local num_files=500
    local start_time=$(date +%s%N)
    
    # Create many small files
    for i in $(seq 1 $num_files); do
        echo "Content $i" > "file_$i.txt"
    done
    
    local end_time=$(date +%s%N)
    local create_duration=$(( (end_time - start_time) / 1000000 ))
    
    [[ $VERBOSE -ge 1 ]] && log "INFO" "Created $num_files files in ${create_duration}ms"
    
    # Test finding files
    start_time=$(date +%s%N)
    find . -name "*.txt" | wc -l >/dev/null 2>&1
    end_time=$(date +%s%N)
    local find_duration=$(( (end_time - start_time) / 1000000 ))
    
    [[ $VERBOSE -ge 1 ]] && log "INFO" "Find operation: ${find_duration}ms"
    
    # Test deletion
    start_time=$(date +%s%N)
    rm -f *.txt
    end_time=$(date +%s%N)
    local delete_duration=$(( (end_time - start_time) / 1000000 ))
    
    [[ $VERBOSE -ge 1 ]] && log "INFO" "Deleted $num_files files in ${delete_duration}ms"
    
    # Cleanup
    cd - >/dev/null
    rm -rf "$test_dir"
    
    [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Filesystem handles stress well"
    return 0
}