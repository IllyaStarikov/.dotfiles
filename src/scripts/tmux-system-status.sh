#!/bin/bash

# Function to get CPU usage percentage on macOS
get_cpu_usage() {
    # Cache file to store CPU stats between calls
    cache_file="/tmp/.tmux_cpu_cache"
    current_time=$(date +%s)
    
    # Check if cache exists and is less than 10 seconds old
    if [ -f "$cache_file" ]; then
        cache_time=$(stat -f %m "$cache_file" 2>/dev/null || echo 0)
        age=$((current_time - cache_time))
        
        if [ "$age" -lt 10 ]; then
            # Use cached value
            cat "$cache_file"
            return
        fi
    fi
    
    # Use ps to calculate CPU usage (faster than iostat)
    # This sums up CPU usage of all processes
    cpu_sum=$(ps aux | awk 'NR>1 {sum+=$3} END {print sum}')
    
    # Get number of CPU cores
    cpu_cores=$(sysctl -n hw.ncpu)
    
    # Calculate average CPU usage per core
    cpu_percent=$(echo "scale=0; $cpu_sum / $cpu_cores" | bc | cut -d. -f1)
    
    # Ensure it's not negative
    if [ "$cpu_percent" -lt 0 ]; then
        cpu_percent=0
    fi
    
    # Save to cache
    echo "$cpu_percent" > "$cache_file"
    echo "$cpu_percent"
}

# Function to get memory usage on macOS
get_memory_usage() {
    # Cache file to store memory stats between calls
    cache_file="/tmp/.tmux_mem_cache"
    current_time=$(date +%s)
    
    # Check if cache exists and is less than 5 seconds old
    if [ -f "$cache_file" ]; then
        cache_time=$(stat -f %m "$cache_file" 2>/dev/null || echo 0)
        age=$((current_time - cache_time))
        
        if [ "$age" -lt 5 ]; then
            # Use cached value
            cat "$cache_file"
            return
        fi
    fi
    
    # Get memory stats using vm_stat (native macOS command)
    vm_stat=$(vm_stat)
    
    # Extract values with default values to handle missing fields
    pages_free=$(echo "$vm_stat" | grep "Pages free" | awk '{print $3}' | tr -d '.' || echo "0")
    pages_active=$(echo "$vm_stat" | grep "Pages active" | awk '{print $3}' | tr -d '.' || echo "0")
    pages_inactive=$(echo "$vm_stat" | grep "Pages inactive" | awk '{print $3}' | tr -d '.' || echo "0")
    pages_speculative=$(echo "$vm_stat" | grep "Pages speculative" | awk '{print $3}' | tr -d '.' || echo "0")
    pages_wired=$(echo "$vm_stat" | grep "Pages wired down" | awk '{print $4}' | tr -d '.' || echo "0")
    pages_compressed=$(echo "$vm_stat" | grep "Pages occupied by compressor" | awk '{print $5}' | tr -d '.' || echo "0")
    
    # Calculate used pages (active + wired + compressed)
    pages_used=$((pages_active + pages_wired + pages_compressed))
    
    # Calculate total pages
    pages_total=$((pages_free + pages_active + pages_inactive + pages_speculative + pages_wired + pages_compressed))
    
    # Convert to GB (page size is 16384 bytes on modern macOS)
    memory_used_gb=$(echo "scale=0; $pages_used * 16384 / 1024 / 1024 / 1024" | bc)
    memory_total_gb=$(echo "scale=0; $pages_total * 16384 / 1024 / 1024 / 1024" | bc)
    
    # Calculate percentage
    memory_percent=$(echo "scale=0; $pages_used * 100 / $pages_total" | bc)
    
    # Save to cache
    echo "$memory_percent $memory_used_gb" > "$cache_file"
    echo "$memory_percent $memory_used_gb"
}

# Function to get battery status on macOS
get_battery_status() {
    # Cache file to store battery stats
    cache_file="/tmp/.tmux_battery_cache"
    current_time=$(date +%s)
    
    # Check if cache exists and is less than 30 seconds old (battery doesn't change fast)
    if [ -f "$cache_file" ]; then
        cache_time=$(stat -f %m "$cache_file" 2>/dev/null || echo 0)
        age=$((current_time - cache_time))
        
        if [ "$age" -lt 30 ]; then
            # Use cached value
            cat "$cache_file"
            return
        fi
    fi
    
    # Get battery info using pmset
    battery_info=$(pmset -g batt | grep -E "[0-9]+%")
    
    if [ -z "$battery_info" ]; then
        echo "No battery"
        return
    fi
    
    # Extract percentage
    battery_percent=$(echo "$battery_info" | grep -o "[0-9]\+%" | tr -d '%')
    
    # Choose battery icon based on percentage
    if [ "$battery_percent" -ge 80 ]; then
        icon="🔋"
    elif [ "$battery_percent" -ge 60 ]; then
        icon="🔋"
    elif [ "$battery_percent" -ge 40 ]; then
        icon="🔋"
    elif [ "$battery_percent" -ge 20 ]; then
        icon="🪫"
    else
        icon="🪫"
    fi
    
    # Generate bars for battery
    bars=$(generate_bars "$battery_percent" "battery")
    
    # Get color for battery text (inverse logic)
    if [ "$battery_percent" -ge 75 ]; then
        text_color="#[fg=green]"
    elif [ "$battery_percent" -ge 50 ]; then
        text_color="#[fg=yellow]"
    else
        text_color="#[fg=red]"
    fi
    
    # Format output
    battery_output="${icon} ${bars} ${text_color}${battery_percent}%#[default]"
    
    # Save to cache
    echo "$battery_output" > "$cache_file"
    echo "$battery_output"
}

# Function to generate bar visualization with colors
generate_bars() {
    local percent=$1
    local type=$2  # "cpu_mem" or "battery"
    local bars=""
    
    # Unicode box drawing characters
    local empty="□"
    local filled="■"
    
    # Color codes
    local green="#[fg=green]"
    local yellow="#[fg=yellow]"
    local red="#[fg=red]"
    local reset="#[default]"
    
    # Calculate how many bars to fill
    local num_filled=0
    if [ "$percent" -le 24 ]; then
        num_filled=0
    elif [ "$percent" -le 49 ]; then
        num_filled=1
    elif [ "$percent" -le 74 ]; then
        num_filled=2
    elif [ "$percent" -le 90 ]; then
        num_filled=3
    else
        num_filled=4
    fi
    
    # Determine color based on type and fill level
    local color=""
    if [ "$type" = "battery" ]; then
        # Battery: green (3-4/4), yellow (2/4), red (0-1/4)
        if [ "$num_filled" -ge 3 ]; then
            color="$green"
        elif [ "$num_filled" -eq 2 ]; then
            color="$yellow"
        else
            color="$red"
        fi
    else
        # CPU/Memory: green (0-1/4), yellow (2-3/4), red (4/4)
        if [ "$num_filled" -le 1 ]; then
            color="$green"
        elif [ "$num_filled" -le 3 ]; then
            color="$yellow"
        else
            color="$red"
        fi
    fi
    
    # Build the bar string with colors
    bars="${color}"
    for i in 1 2 3 4; do
        if [ "$i" -le "$num_filled" ]; then
            bars="${bars}${filled}"
        else
            bars="${bars}${empty}"
        fi
    done
    bars="${bars}${reset}"
    
    echo "$bars"
}

# Main output
case "$1" in
    cpu)
        cpu_percent=$(get_cpu_usage)
        bars=$(generate_bars "$cpu_percent" "cpu_mem")
        # Get color for text
        if [ "$cpu_percent" -le 49 ]; then
            text_color="#[fg=green]"
        elif [ "$cpu_percent" -le 90 ]; then
            text_color="#[fg=yellow]"
        else
            text_color="#[fg=red]"
        fi
        # Brain emoji for CPU
        echo "🧠 $bars ${text_color}${cpu_percent}%#[default]"
        ;;
    memory)
        read mem_percent mem_gb <<< "$(get_memory_usage)"
        bars=$(generate_bars "$mem_percent" "cpu_mem")
        # Get color for text
        if [ "$mem_percent" -le 49 ]; then
            text_color="#[fg=green]"
        elif [ "$mem_percent" -le 90 ]; then
            text_color="#[fg=yellow]"
        else
            text_color="#[fg=red]"
        fi
        # Floppy disk emoji for memory (save icon)
        echo "💾 $bars ${text_color}${mem_gb}GB#[default]"
        ;;
    battery)
        battery_status=$(get_battery_status)
        echo "$battery_status"
        ;;
    *)
        # Default: show both CPU and memory
        cpu_percent=$(get_cpu_usage)
        cpu_bars=$(generate_bars "$cpu_percent" "cpu_mem")
        # Get CPU color
        if [ "$cpu_percent" -le 49 ]; then
            cpu_color="#[fg=green]"
        elif [ "$cpu_percent" -le 90 ]; then
            cpu_color="#[fg=yellow]"
        else
            cpu_color="#[fg=red]"
        fi
        
        read mem_percent mem_gb <<< "$(get_memory_usage)"
        mem_bars=$(generate_bars "$mem_percent" "cpu_mem")
        # Get memory color
        if [ "$mem_percent" -le 49 ]; then
            mem_color="#[fg=green]"
        elif [ "$mem_percent" -le 90 ]; then
            mem_color="#[fg=yellow]"
        else
            mem_color="#[fg=red]"
        fi
        
        echo "🧠 $cpu_bars ${cpu_color}${cpu_percent}%#[default] │ 💾 $mem_bars ${mem_color}${mem_gb}GB#[default]"
        ;;
esac