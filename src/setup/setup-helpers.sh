#!/usr/bin/env bash

# Helper functions for setup scripts
# This file is sourced by other setup scripts

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly NC='\033[0m' # No Color

# Logging functions
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
debug() { [[ "${DEBUG:-0}" == "1" ]] && echo -e "${PURPLE}🔍 $1${NC}"; }

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Get OS type
get_os() {
    case "$OSTYPE" in
        darwin*) echo "macos" ;;
        linux*) echo "linux" ;;
        *) echo "unknown" ;;
    esac
}

# Get Linux distribution
get_linux_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    elif [[ -f /etc/redhat-release ]]; then
        echo "rhel"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    else
        echo "unknown"
    fi
}

# Check if running on WSL
is_wsl() {
    if grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Safe backup function
backup_file() {
    local file="$1"
    if [[ -e "$file" ]]; then
        local backup_dir="$HOME/.config-backups/$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$backup_dir"
        cp -r "$file" "$backup_dir/"
        info "Backed up $file to $backup_dir"
    fi
}

# Download file with progress
download_file() {
    local url="$1"
    local output="$2"
    
    if command_exists wget; then
        wget --progress=bar:force -O "$output" "$url"
    elif command_exists curl; then
        curl -# -L -o "$output" "$url"
    else
        error "Neither wget nor curl found"
        return 1
    fi
}

# Verify checksum
verify_checksum() {
    local file="$1"
    local expected_sum="$2"
    local sum_type="${3:-sha256}"
    
    local actual_sum
    case "$sum_type" in
        sha256)
            if command_exists sha256sum; then
                actual_sum=$(sha256sum "$file" | cut -d' ' -f1)
            elif command_exists shasum; then
                actual_sum=$(shasum -a 256 "$file" | cut -d' ' -f1)
            else
                warning "No SHA256 tool found, skipping verification"
                return 0
            fi
            ;;
        *)
            error "Unsupported checksum type: $sum_type"
            return 1
            ;;
    esac
    
    if [[ "$actual_sum" == "$expected_sum" ]]; then
        success "Checksum verified"
        return 0
    else
        error "Checksum mismatch!"
        error "Expected: $expected_sum"
        error "Actual: $actual_sum"
        return 1
    fi
}

# Get number of CPU cores
get_cpu_count() {
    if command_exists nproc; then
        nproc
    elif command_exists sysctl; then
        sysctl -n hw.ncpu
    else
        echo 1
    fi
}

# Check minimum system requirements
check_system_requirements() {
    # Check available memory
    local mem_kb
    if [[ -f /proc/meminfo ]]; then
        mem_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    elif command_exists sysctl; then
        mem_kb=$(($(sysctl -n hw.memsize) / 1024))
    else
        warning "Cannot determine system memory"
        return 0
    fi
    
    local mem_gb=$((mem_kb / 1024 / 1024))
    if [[ $mem_gb -lt 2 ]]; then
        warning "System has less than 2GB RAM. Some operations may be slow."
    fi
    
    # Check available disk space
    local available_space
    available_space=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | sed 's/G//')
    if [[ $available_space -lt 5 ]]; then
        warning "Less than 5GB free disk space. Installation may fail."
    fi
    
    return 0
}

# Platform-specific clipboard command
get_clipboard_cmd() {
    local os=$(get_os)
    case "$os" in
        macos)
            echo "pbcopy"
            ;;
        linux)
            if command_exists xclip; then
                echo "xclip -selection clipboard"
            elif command_exists xsel; then
                echo "xsel --clipboard --input"
            elif is_wsl && command_exists clip.exe; then
                echo "clip.exe"
            else
                echo "cat" # Fallback to cat if no clipboard tool
            fi
            ;;
        *)
            echo "cat"
            ;;
    esac
}

# Export functions for use in other scripts
export -f info success warning error debug
export -f command_exists get_os get_linux_distro is_wsl
export -f backup_file download_file verify_checksum
export -f get_cpu_count check_system_requirements get_clipboard_cmd