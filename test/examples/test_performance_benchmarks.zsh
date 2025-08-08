#!/bin/zsh
# Example: Performance benchmarks with detailed metrics

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/test_helpers.zsh"

echo "━━━ Performance Benchmarks ━━━"

# Test 1: Detailed startup time analysis
test_case "Neovim startup time breakdown"
# Run multiple times for accuracy
declare -a startup_times
for i in {1..5}; do
    output=$(nvim --headless --startuptime "$TEST_TMP_DIR/startup_$i.log" -c "qa!" 2>&1)
    
    # Parse the total time from the log
    if [[ -f "$TEST_TMP_DIR/startup_$i.log" ]]; then
        total_time=$(tail -1 "$TEST_TMP_DIR/startup_$i.log" | awk '{print $1}')
        startup_times+=($total_time)
    fi
done

# Calculate average
if [[ ${#startup_times[@]} -gt 0 ]]; then
    total=0
    for time in "${startup_times[@]}"; do
        total=$(echo "$total + $time" | bc)
    done
    avg=$(echo "scale=2; $total / ${#startup_times[@]}" | bc)
    
    echo "  Average startup: ${avg}ms"
    echo "  Individual runs: ${startup_times[*]}"
    
    # Check against threshold
    if (( $(echo "$avg < 300" | bc -l) )); then
        pass
    else
        # Analyze what's slow
        echo "  Analyzing slow components..."
        grep -E "^[0-9]+\.[0-9]+\s+[0-9]+\.[0-9]+:\s+.*/(lazy|plugin)" "$TEST_TMP_DIR/startup_5.log" | 
            sort -nr | head -5 | while read line; do
                echo "    $line"
            done
        fail "Startup too slow: ${avg}ms"
    fi
else
    fail "Could not measure startup time"
fi

# Test 2: Plugin loading performance
test_case "Plugin loading times"
output=$(nvim --headless -u "$DOTFILES_DIR/src/lua/init.lua" \
    -c "lua vim.defer_fn(function()
        local stats = require('lazy').stats()
        print('total-time:', stats.times.LazyDone)
        print('plugin-count:', stats.count)
        print('loaded-count:', stats.loaded)
        
        -- Find slowest plugins
        local times = {}
        for _, plugin in pairs(require('lazy.core.config').plugins) do
            if plugin._.loaded and plugin._.loaded.time then
                table.insert(times, {
                    name = plugin.name,
                    time = plugin._.loaded.time
                })
            end
        end
        
        table.sort(times, function(a, b) return a.time > b.time end)
        
        print('slowest-plugins:')
        for i = 1, math.min(5, #times) do
            print(string.format('  %s: %.2fms', times[i].name, times[i].time))
        end
        
        vim.cmd('qa!')
    end, 3000)" 2>&1)

# Parse and check
if [[ "$output" == *"total-time:"* ]]; then
    total_time=$(echo "$output" | grep "total-time:" | awk '{print $2}')
    echo "  Total plugin load time: ${total_time}ms"
    echo "$output" | grep -A 5 "slowest-plugins:" | tail -5
    
    if [[ "$total_time" -lt 500 ]]; then
        pass
    else
        fail "Plugin loading too slow: ${total_time}ms"
    fi
else
    fail "Could not measure plugin loading"
fi

# Test 3: LSP responsiveness
test_case "LSP response times"
cat > "$TEST_TMP_DIR/perf_test.py" << 'EOF'
import os
import sys

class TestClass:
    def __init__(self):
        self.value = 42
    
    def method(self):
        return self.
EOF

output=$(nvim --headless "$TEST_TMP_DIR/perf_test.py" \
    -c "lua vim.defer_fn(function()
        -- Wait for LSP
        vim.wait(3000, function() return #vim.lsp.get_clients() > 0 end)
        
        -- Measure completion time
        vim.cmd('normal! 9G$')
        vim.cmd('startinsert')
        
        local start = vim.loop.hrtime()
        
        -- Request completion
        vim.lsp.buf.completion()
        
        -- Wait for results
        vim.wait(1000, function()
            return require('blink.cmp').is_visible()
        end)
        
        local elapsed = (vim.loop.hrtime() - start) / 1000000  -- Convert to ms
        
        print('completion-time:', elapsed)
        vim.cmd('qa!')
    end, 1000)" 2>&1)

if [[ "$output" == *"completion-time:"* ]]; then
    comp_time=$(echo "$output" | grep "completion-time:" | awk '{print $2}')
    echo "  Completion response: ${comp_time}ms"
    
    if (( $(echo "$comp_time < 200" | bc -l) )); then
        pass
    else
        fail "Completion too slow: ${comp_time}ms"
    fi
else
    skip "Could not measure completion time"
fi

# Test 4: Memory usage
test_case "Memory usage stays reasonable"
# Start Neovim and let it fully load
nvim --headless -u "$DOTFILES_DIR/src/lua/init.lua" \
    -c "lua vim.defer_fn(function()
        -- Force garbage collection
        collectgarbage('collect')
        collectgarbage('collect')
        
        -- Get memory usage
        local mem = collectgarbage('count')
        print('lua-memory:', mem)
        
        -- Get process memory if possible
        local handle = io.popen('ps -o rss= -p ' .. vim.fn.getpid())
        if handle then
            local rss = handle:read('*a'):gsub('%s+', '')
            handle:close()
            print('process-memory:', rss)
        end
        
        vim.cmd('qa!')
    end, 3000)" 2>&1 > "$TEST_TMP_DIR/memory.log"

if [[ -f "$TEST_TMP_DIR/memory.log" ]]; then
    lua_mem=$(grep "lua-memory:" "$TEST_TMP_DIR/memory.log" | awk '{print $2}')
    proc_mem=$(grep "process-memory:" "$TEST_TMP_DIR/memory.log" | awk '{print $2}')
    
    if [[ -n "$lua_mem" ]]; then
        echo "  Lua memory: ${lua_mem}KB"
    fi
    if [[ -n "$proc_mem" ]]; then
        echo "  Process RSS: ${proc_mem}KB"
        # Check if under 200MB
        if [[ "$proc_mem" -lt 200000 ]]; then
            pass
        else
            fail "Memory usage too high: ${proc_mem}KB"
        fi
    else
        skip "Could not measure process memory"
    fi
else
    fail "Memory measurement failed"
fi

# Test 5: Theme switching performance
test_case "Theme switching completes quickly"
# Measure multiple switches
declare -a switch_times
for i in {1..3}; do
    time_ms=$(measure_time_ms "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh")
    switch_times+=($time_ms)
    sleep 0.5  # Brief pause between switches
done

# Calculate average
total=0
for time in "${switch_times[@]}"; do
    total=$((total + time))
done
avg=$((total / ${#switch_times[@]}))

echo "  Average switch time: ${avg}ms"
echo "  Individual runs: ${switch_times[*]}"

if [[ $avg -lt 500 ]]; then
    pass
else
    fail "Theme switching too slow: ${avg}ms"
fi