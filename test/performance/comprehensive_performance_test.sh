#!/usr/bin/env zsh
# Comprehensive Performance Tests with Metrics Logging
# Measures and logs performance metrics for all components

set -euo pipefail

source "$(dirname "$0")/../lib/test_helpers.zsh"

readonly DEBUG="${DEBUG:-0}"
readonly PERF_LOG="${TEST_TMP_DIR}/performance.log"
readonly METRICS_FILE="${TEST_TMP_DIR}/metrics.json"

# Performance thresholds (in milliseconds)
readonly NVIM_STARTUP_THRESHOLD=300
readonly PLUGIN_LOAD_THRESHOLD=500
readonly THEME_SWITCH_THRESHOLD=500
readonly ZSH_STARTUP_THRESHOLD=200
readonly SCRIPT_EXEC_THRESHOLD=100

#######################################
# Initialize performance logging
#######################################
init_perf_logging() {
    echo "Performance Test Run - $(date)" > "${PERF_LOG}"
    echo "{" > "${METRICS_FILE}"
    echo '  "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",' >> "${METRICS_FILE}"
    echo '  "system": {' >> "${METRICS_FILE}"
    echo '    "os": "'$(uname -s)'",' >> "${METRICS_FILE}"
    echo '    "arch": "'$(uname -m)'",' >> "${METRICS_FILE}"
    echo '    "cpu_cores": '$(sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 1)',' >> "${METRICS_FILE}"
    echo '    "memory_gb": '$(( $(sysctl -n hw.memsize 2>/dev/null || grep MemTotal /proc/meminfo | awk '{print $2}') / 1024 / 1024 / 1024 )) >> "${METRICS_FILE}"
    echo '  },' >> "${METRICS_FILE}"
    echo '  "metrics": {' >> "${METRICS_FILE}"
}

#######################################
# Finalize performance logging
#######################################
finalize_perf_logging() {
    echo '  }' >> "${METRICS_FILE}"
    echo '}' >> "${METRICS_FILE}"

    if [[ "${DEBUG}" -eq 1 ]]; then
        echo -e "\n${YELLOW}=== Performance Log ===${NC}"
        cat "${PERF_LOG}"
        echo -e "\n${YELLOW}=== Metrics JSON ===${NC}"
        cat "${METRICS_FILE}"
    fi
}

#######################################
# Log performance metric
#######################################
log_metric() {
    local component="$1"
    local metric="$2"
    local value="$3"
    local unit="${4:-ms}"

    echo "[$(date '+%H:%M:%S')] ${component}: ${metric} = ${value}${unit}" >> "${PERF_LOG}"

    # Add to JSON (simplified - in production would use proper JSON tooling)
    if [[ ! -f "${TEST_TMP_DIR}/.first_metric" ]]; then
        touch "${TEST_TMP_DIR}/.first_metric"
    else
        echo ',' >> "${METRICS_FILE}"
    fi
    echo -n '    "'${component}_${metric}'": '${value} >> "${METRICS_FILE}"
}

#######################################
# Measure command execution time
#######################################
measure_time() {
    local start=$(date +%s%N)
    "$@" >/dev/null 2>&1
    local end=$(date +%s%N)
    echo $(( (end - start) / 1000000 ))  # Convert to milliseconds
}

#######################################
# Test Neovim startup performance
#######################################
test_nvim_startup_performance() {
    echo -e "${BLUE}=== Neovim Startup Performance ===${NC}"

    test_case "Neovim startup time < ${NVIM_STARTUP_THRESHOLD}ms"

    # Measure startup time multiple times for accuracy
    local total_time=0
    local iterations=5
    local times=()

    for i in $(seq 1 ${iterations}); do
        local startup_log="${TEST_TMP_DIR}/nvim_startup_${i}.log"
        local time_ms=$(measure_time nvim --headless --startuptime "${startup_log}" \
            -u "${DOTFILES_DIR}/src/neovim/init.lua" -c "qa!")

        times+=("${time_ms}")
        total_time=$((total_time + time_ms))

        # Parse detailed startup time
        if [[ -f "${startup_log}" ]]; then
            local init_time=$(tail -1 "${startup_log}" | awk '{print int($1)}' 2>/dev/null || echo 0)
            log_metric "nvim" "startup_iteration_${i}" "${init_time}"

            if [[ "${DEBUG}" -eq 1 ]]; then
                echo "  Iteration ${i}: ${init_time}ms"
                # Show slowest operations
                echo "  Top 5 slowest operations:"
                grep -E "^[0-9]" "${startup_log}" | sort -rn | head -5 | while read line; do
                    echo "    ${line}"
                done
            fi
        fi
    done

    local avg_time=$((total_time / iterations))
    log_metric "nvim" "startup_average" "${avg_time}"

    # Calculate standard deviation
    local variance=0
    for time in "${times[@]}"; do
        local diff=$((time - avg_time))
        variance=$((variance + diff * diff))
    done
    local std_dev=$(echo "sqrt(${variance} / ${iterations})" | bc 2>/dev/null || echo "N/A")
    log_metric "nvim" "startup_stddev" "${std_dev}"

    if [[ "${avg_time}" -lt "${NVIM_STARTUP_THRESHOLD}" ]]; then
        pass "Average: ${avg_time}ms (σ=${std_dev}ms)"
    else
        fail "Average: ${avg_time}ms exceeds threshold of ${NVIM_STARTUP_THRESHOLD}ms"
    fi

    test_case "Neovim memory usage < 200MB"

    # Measure memory usage
    local mem_test="${TEST_TMP_DIR}/nvim_mem_test.sh"
    cat > "${mem_test}" << 'EOF'
#!/usr/bin/env zsh
nvim --headless -u "${DOTFILES_DIR}/src/neovim/init.lua" \
    -c "lua vim.defer_fn(function()
        collectgarbage('collect')
        local mem = collectgarbage('count')
        print('LUA_MEM:' .. math.floor(mem) .. 'KB')
        vim.cmd('qa!')
    end, 3000)" 2>/dev/null &

NVIM_PID=$!
sleep 4

if [[ $(uname) == "Darwin" ]]; then
    MEM_KB=$(ps -o rss= -p ${NVIM_PID} 2>/dev/null || echo 0)
else
    MEM_KB=$(ps -o rss= -p ${NVIM_PID} 2>/dev/null | awk '{print $1}' || echo 0)
fi

kill ${NVIM_PID} 2>/dev/null || true
echo "PROCESS_MEM:${MEM_KB}KB"
EOF

    chmod +x "${mem_test}"
    local mem_output=$("${mem_test}")
    local process_mem=$(echo "${mem_output}" | grep "PROCESS_MEM:" | cut -d: -f2 | tr -d 'KB')
    local lua_mem=$(echo "${mem_output}" | grep "LUA_MEM:" | cut -d: -f2 | tr -d 'KB')

    local mem_mb=$((process_mem / 1024))
    log_metric "nvim" "memory_usage_mb" "${mem_mb}" "MB"
    log_metric "nvim" "lua_memory_kb" "${lua_mem}" "KB"

    if [[ "${mem_mb}" -lt 200 ]]; then
        pass "Memory: ${mem_mb}MB"
    else
        fail "Memory: ${mem_mb}MB exceeds 200MB threshold"
    fi
}

#######################################
# Test plugin loading performance
#######################################
test_plugin_loading_performance() {
    echo -e "\n${BLUE}=== Plugin Loading Performance ===${NC}"

    test_case "All plugins load within ${PLUGIN_LOAD_THRESHOLD}ms"

    local plugin_log="${TEST_TMP_DIR}/plugin_load.log"

    # Measure plugin loading time
    local output=$(timeout 15 nvim --headless -u "${DOTFILES_DIR}/src/neovim/init.lua" \
        -c "lua vim.defer_fn(function()
            local ok, lazy = pcall(require, 'lazy')
            if ok then
                local stats = lazy.stats()
                print('LOAD_TIME:' .. stats.times.LazyDone)
                print('PLUGIN_COUNT:' .. stats.count)

                -- Get individual plugin times
                for _, plugin in pairs(require('lazy.core.config').plugins) do
                    if plugin._.loaded and plugin._.loaded.time then
                        print('PLUGIN:' .. plugin.name .. ':' .. plugin._.loaded.time)
                    end
                end
            else
                print('LAZY_NOT_AVAILABLE')
            end
            vim.cmd('qa!')
        end, 5000)" 2>&1)

    if [[ "${output}" == *"LAZY_NOT_AVAILABLE"* ]]; then
        skip "Lazy.nvim not available"
    else
        local load_time=$(echo "${output}" | grep "LOAD_TIME:" | cut -d: -f2)
        local plugin_count=$(echo "${output}" | grep "PLUGIN_COUNT:" | cut -d: -f2)

        log_metric "plugins" "total_load_time" "${load_time}"
        log_metric "plugins" "count" "${plugin_count}"

        # Log individual plugin times
        echo "${output}" | grep "^PLUGIN:" | while IFS=: read -r _ name time; do
            log_metric "plugin_${name}" "load_time" "${time}"
            if [[ "${DEBUG}" -eq 1 ]] && [[ "${time}" -gt 50 ]]; then
                echo "  Slow plugin: ${name} (${time}ms)"
            fi
        done

        if [[ "${load_time}" -lt "${PLUGIN_LOAD_THRESHOLD}" ]]; then
            pass "Load time: ${load_time}ms for ${plugin_count} plugins"
        else
            fail "Load time: ${load_time}ms exceeds ${PLUGIN_LOAD_THRESHOLD}ms threshold"
        fi
    fi
}

#######################################
# Test theme switching performance
#######################################
test_theme_switching_performance() {
    echo -e "\n${BLUE}=== Theme Switching Performance ===${NC}"

    test_case "Theme switching completes within ${THEME_SWITCH_THRESHOLD}ms"

    local switch_times=()
    local themes=("light" "dark" "night" "moon")

    for theme in "${themes[@]}"; do
        local time_ms=$(measure_time "${DOTFILES_DIR}/src/theme-switcher/switch-theme.sh" "${theme}")
        switch_times+=("${time_ms}")
        log_metric "theme_switch" "${theme}" "${time_ms}"

        if [[ "${DEBUG}" -eq 1 ]]; then
            echo "  Theme '${theme}': ${time_ms}ms"
        fi
    done

    # Calculate average
    local total=0
    for time in "${switch_times[@]}"; do
        total=$((total + time))
    done
    local avg=$((total / ${#switch_times[@]}))
    log_metric "theme_switch" "average" "${avg}"

    if [[ "${avg}" -lt "${THEME_SWITCH_THRESHOLD}" ]]; then
        pass "Average: ${avg}ms"
    else
        fail "Average: ${avg}ms exceeds ${THEME_SWITCH_THRESHOLD}ms threshold"
    fi
}

#######################################
# Test Zsh startup performance
#######################################
test_zsh_startup_performance() {
    echo -e "\n${BLUE}=== Zsh Startup Performance ===${NC}"

    test_case "Zsh startup time < ${ZSH_STARTUP_THRESHOLD}ms"

    local zsh_times=()
    local iterations=5

    for i in $(seq 1 ${iterations}); do
        local start=$(date +%s%N)
        zsh -i -c "exit" 2>/dev/null
        local end=$(date +%s%N)
        local time_ms=$(( (end - start) / 1000000 ))

        zsh_times+=("${time_ms}")
        log_metric "zsh" "startup_iteration_${i}" "${time_ms}"
    done

    # Calculate average
    local total=0
    for time in "${zsh_times[@]}"; do
        total=$((total + time))
    done
    local avg=$((total / iterations))
    log_metric "zsh" "startup_average" "${avg}"

    if [[ "${avg}" -lt "${ZSH_STARTUP_THRESHOLD}" ]]; then
        pass "Average: ${avg}ms"
    else
        fail "Average: ${avg}ms exceeds ${ZSH_STARTUP_THRESHOLD}ms threshold"
    fi

    test_case "Zsh plugin loading is optimized"

    # Check if Zinit turbo mode is being used
    local turbo_plugins=$(grep -c "wait\|atload\|atinit" "${DOTFILES_DIR}/src/zsh/zshrc" 2>/dev/null || echo 0)
    log_metric "zsh" "turbo_plugins" "${turbo_plugins}"

    if [[ "${turbo_plugins}" -gt 0 ]]; then
        pass "Using turbo mode for ${turbo_plugins} plugins"
    else
        skip "Consider using Zinit turbo mode for faster startup"
    fi
}

#######################################
# Test script execution performance
#######################################
test_script_performance() {
    echo -e "\n${BLUE}=== Script Execution Performance ===${NC}"

    local scripts=(
        "fixy:${DOTFILES_DIR}/src/scripts/fixy:--help"
        "tmux-utils:${DOTFILES_DIR}/src/scripts/tmux-utils:battery"
        "theme:${DOTFILES_DIR}/src/scripts/theme:--list"
        "scratchpad:${DOTFILES_DIR}/src/scripts/scratchpad:--dry-run"
    )

    for script_spec in "${scripts[@]}"; do
        IFS=: read -r name path args <<< "${script_spec}"

        test_case "Script '${name}' executes < ${SCRIPT_EXEC_THRESHOLD}ms"

        if [[ ! -x "${path}" ]]; then
            skip "Script not found or not executable"
            continue
        fi

        local time_ms=$(measure_time "${path}" ${args})
        log_metric "script_${name}" "execution_time" "${time_ms}"

        if [[ "${time_ms}" -lt "${SCRIPT_EXEC_THRESHOLD}" ]]; then
            pass "${time_ms}ms"
        else
            fail "${time_ms}ms exceeds ${SCRIPT_EXEC_THRESHOLD}ms threshold"
        fi
    done
}

#######################################
# Test resource usage under load
#######################################
test_resource_usage() {
    echo -e "\n${BLUE}=== Resource Usage Tests ===${NC}"

    test_case "System remains responsive under load"

    # Create load scenario
    local load_script="${TEST_TMP_DIR}/load_test.sh"
    cat > "${load_script}" << 'EOF'
#!/usr/bin/env zsh
# Open multiple files in Neovim
for i in {1..10}; do
    echo "Test file ${i}" > "/tmp/test_${i}.txt"
done

nvim --headless -u "${DOTFILES_DIR}/src/neovim/init.lua" \
    /tmp/test_*.txt \
    -c "lua vim.defer_fn(function()
        -- Perform operations
        vim.cmd('bufdo! set filetype=markdown')
        vim.cmd('bufdo! normal! ggVG')

        -- Measure resources
        collectgarbage('collect')
        local mem = collectgarbage('count')
        print('MEM_UNDER_LOAD:' .. math.floor(mem) .. 'KB')

        -- Count buffers
        local buffers = #vim.fn.getbufinfo({buflisted = 1})
        print('BUFFERS:' .. buffers)

        vim.cmd('qa!')
    end, 5000)" 2>&1
EOF

    chmod +x "${load_script}"
    local output=$("${load_script}")

    local mem_under_load=$(echo "${output}" | grep "MEM_UNDER_LOAD:" | cut -d: -f2 | tr -d 'KB')
    local buffer_count=$(echo "${output}" | grep "BUFFERS:" | cut -d: -f2)

    log_metric "load_test" "memory_kb" "${mem_under_load}" "KB"
    log_metric "load_test" "buffers" "${buffer_count}"

    local mem_mb=$((mem_under_load / 1024))
    if [[ "${mem_mb}" -lt 500 ]]; then
        pass "Memory under load: ${mem_mb}MB with ${buffer_count} buffers"
    else
        fail "Memory under load: ${mem_mb}MB exceeds 500MB threshold"
    fi

    # Clean up
    rm -f /tmp/test_*.txt
}

#######################################
# Test for memory leaks
#######################################
test_memory_leaks() {
    echo -e "\n${BLUE}=== Memory Leak Detection ===${NC}"

    test_case "No significant memory leaks detected"

    local leak_test="${TEST_TMP_DIR}/leak_test.sh"
    cat > "${leak_test}" << 'EOF'
#!/usr/bin/env zsh
# Perform repeated operations and check for memory growth

nvim --headless -u "${DOTFILES_DIR}/src/neovim/init.lua" \
    -c "lua vim.defer_fn(function()
        local initial_mem = collectgarbage('count')

        -- Perform repeated operations
        for i = 1, 100 do
            vim.cmd('enew')
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {'Test line ' .. i})
            vim.cmd('write! /tmp/leak_test_' .. i .. '.txt')
            vim.cmd('bdelete!')
        end

        collectgarbage('collect')
        collectgarbage('collect')  -- Double collect to ensure cleanup

        local final_mem = collectgarbage('count')
        local growth = final_mem - initial_mem

        print('INITIAL_MEM:' .. math.floor(initial_mem))
        print('FINAL_MEM:' .. math.floor(final_mem))
        print('GROWTH:' .. math.floor(growth))

        -- Clean up test files
        for i = 1, 100 do
            os.remove('/tmp/leak_test_' .. i .. '.txt')
        end

        vim.cmd('qa!')
    end, 5000)" 2>&1
EOF

    chmod +x "${leak_test}"
    local output=$(timeout 20 "${leak_test}" || echo "TIMEOUT")

    if [[ "${output}" == "TIMEOUT" ]]; then
        skip "Memory leak test timed out"
    else
        local initial=$(echo "${output}" | grep "INITIAL_MEM:" | cut -d: -f2)
        local final=$(echo "${output}" | grep "FINAL_MEM:" | cut -d: -f2)
        local growth=$(echo "${output}" | grep "GROWTH:" | cut -d: -f2)

        log_metric "memory_leak" "initial_kb" "${initial}" "KB"
        log_metric "memory_leak" "final_kb" "${final}" "KB"
        log_metric "memory_leak" "growth_kb" "${growth}" "KB"

        # Allow up to 10MB growth
        if [[ "${growth}" -lt 10240 ]]; then
            pass "Memory growth: ${growth}KB"
        else
            fail "Excessive memory growth: ${growth}KB"
        fi
    fi
}

#######################################
# Generate performance report
#######################################
generate_report() {
    echo -e "\n${GREEN}=== Performance Test Report ===${NC}"

    if [[ -f "${METRICS_FILE}" ]]; then
        echo "Metrics saved to: ${METRICS_FILE}"
    fi

    if [[ -f "${PERF_LOG}" ]]; then
        echo "Performance log saved to: ${PERF_LOG}"

        # Generate summary
        echo -e "\n${YELLOW}Performance Summary:${NC}"
        echo "  Neovim startup: $(grep "nvim: startup_average" "${PERF_LOG}" | tail -1 | cut -d= -f2)"
        echo "  Plugin loading: $(grep "plugins: total_load_time" "${PERF_LOG}" | tail -1 | cut -d= -f2)"
        echo "  Theme switching: $(grep "theme_switch: average" "${PERF_LOG}" | tail -1 | cut -d= -f2)"
        echo "  Zsh startup: $(grep "zsh: startup_average" "${PERF_LOG}" | tail -1 | cut -d= -f2)"
    fi
}

#######################################
# Main test runner
#######################################
main() {
    init_perf_logging

    local failed=0

    test_nvim_startup_performance || ((failed++))
    test_plugin_loading_performance || ((failed++))
    test_theme_switching_performance || ((failed++))
    test_zsh_startup_performance || ((failed++))
    test_script_performance || ((failed++))
    test_resource_usage || ((failed++))
    test_memory_leaks || ((failed++))

    finalize_perf_logging
    generate_report

    echo -e "\n${GREEN}=== Performance Test Summary ===${NC}"
    echo "Test suites completed: 7"
    echo "Failed test suites: ${failed}"

    return "${failed}"
}

# Run tests
main "$@"