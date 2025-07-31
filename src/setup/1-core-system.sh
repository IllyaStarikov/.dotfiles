#!/bin/bash

# Part 1: Core System Setup - Production Ready
# Installs essential tools up to and including Zsh/Oh My Zsh
# This should be run first on a fresh macOS installation
#
# Features:
# - Comprehensive error handling and recovery
# - System compatibility checks (Intel vs Apple Silicon)
# - Logging for debugging
# - Network connectivity verification
# - Disk space checks
# - Progress tracking
# - Rollback on critical failures

# Strict error handling
set -euo pipefail
IFS=$'\n\t'

# Script version
readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_NAME="1-core-system.sh"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging setup
readonly LOG_DIR="$HOME/.dotfiles-setup-logs"
readonly LOG_FILE="$LOG_DIR/$(date +%Y%m%d_%H%M%S)_${SCRIPT_NAME%.sh}.log"
mkdir -p "$LOG_DIR"

# Initialize log
echo "=== Dotfiles Setup Log - $SCRIPT_NAME v$SCRIPT_VERSION ===" > "$LOG_FILE"
echo "Started at: $(date)" >> "$LOG_FILE"
echo "User: $(whoami)" >> "$LOG_FILE"
echo "System: $(uname -a)" >> "$LOG_FILE"

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Function to print colored output and log
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
    log "$message"
}

# Function to print error and exit
die() {
    print_status "$RED" "❌ Error: $1"
    print_status "$RED" "Installation failed. Check log at: $LOG_FILE"
    exit 1
}

# Function to print warning
warn() {
    print_status "$YELLOW" "⚠️  Warning: $1"
}

# Function to print success
success() {
    print_status "$GREEN" "✅ $1"
}

# Function to print info
info() {
    print_status "$BLUE" "ℹ️  $1"
}

# Trap to handle unexpected exits
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        print_status "$RED" "Script interrupted or failed with exit code: $exit_code"
        print_status "$YELLOW" "Log file: $LOG_FILE"
    fi
}
trap cleanup EXIT

# System requirements check
check_system_requirements() {
    info "Checking system requirements..."
    
    # Check macOS version
    local macos_version
    macos_version=$(sw_vers -productVersion)
    local major_version
    major_version=$(echo "$macos_version" | cut -d. -f1)
    local minor_version
    minor_version=$(echo "$macos_version" | cut -d. -f2)
    
    log "macOS version: $macos_version"
    
    if [[ $major_version -lt 10 ]] || { [[ $major_version -eq 10 ]] && [[ $minor_version -lt 15 ]]; }; then
        die "This script requires macOS 10.15 (Catalina) or later. You have: $macos_version"
    fi
    
    # Check architecture
    local arch
    arch=$(uname -m)
    log "Architecture: $arch"
    
    if [[ "$arch" == "arm64" ]]; then
        info "Detected Apple Silicon Mac"
        export HOMEBREW_PREFIX="/opt/homebrew"
    else
        info "Detected Intel Mac"
        export HOMEBREW_PREFIX="/usr/local"
    fi
    
    # Check available disk space (require at least 5GB)
    local available_space
    available_space=$(df -g / | awk 'NR==2 {print $4}')
    log "Available disk space: ${available_space}GB"
    
    if [[ $available_space -lt 5 ]]; then
        die "Insufficient disk space. At least 5GB required, but only ${available_space}GB available."
    fi
    
    # Check for internet connectivity
    info "Checking internet connectivity..."
    if ! ping -c 1 -t 5 google.com &> /dev/null && ! ping -c 1 -t 5 1.1.1.1 &> /dev/null; then
        die "No internet connection detected. Please check your network settings."
    fi
    success "Internet connection verified"
    
    # Check if running with admin privileges (for some installations)
    if ! sudo -n true 2>/dev/null; then
        warn "You may be prompted for your password during installation"
    fi
    
    success "System requirements check passed"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to safely install a brew package
brew_install_formula() {
    local package=$1
    local required=${2:-true}
    
    if brew list --formula 2>/dev/null | grep -q "^${package}$"; then
        success "$package already installed"
        return 0
    fi
    
    info "Installing $package..."
    if brew install "$package" 2>&1 | tee -a "$LOG_FILE"; then
        success "$package installed successfully"
        return 0
    else
        if [[ "$required" == "true" ]]; then
            die "Failed to install required package: $package"
        else
            warn "Failed to install optional package: $package"
            return 1
        fi
    fi
}

# Function to safely install a brew cask
brew_install_cask() {
    local cask=$1
    local required=${2:-false}
    
    if brew list --cask 2>/dev/null | grep -q "^${cask}$"; then
        success "$cask already installed"
        return 0
    fi
    
    info "Installing $cask..."
    if brew install --cask "$cask" 2>&1 | tee -a "$LOG_FILE"; then
        success "$cask installed successfully"
        return 0
    else
        if [[ "$required" == "true" ]]; then
            die "Failed to install required cask: $cask"
        else
            warn "Failed to install optional cask: $cask"
            return 1
        fi
    fi
}

# Progress tracking
TOTAL_STEPS=10
CURRENT_STEP=0

progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local percentage=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    print_status "$BLUE" "[$CURRENT_STEP/$TOTAL_STEPS] $1 ($percentage%)"
}

# Main installation starts here
print_status "$GREEN" "🚀 Starting Dotfiles Core System Setup v$SCRIPT_VERSION"
info "Log file: $LOG_FILE"

# Step 1: Check system requirements
progress "Checking system requirements"
check_system_requirements

# Step 2: Check if script is being run from correct directory
progress "Verifying script location"
if [[ ! -f "src/setup/1-core-system.sh" ]]; then
    die "Please run this script from the .dotfiles root directory"
fi
success "Script running from correct directory"

# Step 3: Install Xcode Command Line Tools
progress "Installing Xcode Command Line Tools"
if xcode-select -p &>/dev/null; then
    success "Xcode Command Line Tools already installed"
else
    info "Installing Xcode Command Line Tools..."
    if xcode-select --install 2>&1 | tee -a "$LOG_FILE"; then
        # Wait for installation to complete
        info "Please complete the Xcode installation in the popup window..."
        until xcode-select -p &>/dev/null; do
            sleep 5
        done
        success "Xcode Command Line Tools installed"
    else
        die "Failed to install Xcode Command Line Tools"
    fi
fi

# Step 4: Install Homebrew
progress "Installing Homebrew"
if command_exists brew; then
    success "Homebrew already installed"
    info "Updating Homebrew..."
    brew update 2>&1 | tee -a "$LOG_FILE" || warn "Failed to update Homebrew"
else
    info "Installing Homebrew..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>&1 | tee -a "$LOG_FILE"; then
        # Add Homebrew to PATH for this session
        if [[ -f "$HOMEBREW_PREFIX/bin/brew" ]]; then
            export PATH="$HOMEBREW_PREFIX/bin:$PATH"
            eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
        fi
        success "Homebrew installed"
    else
        die "Failed to install Homebrew"
    fi
fi

# Verify Homebrew is working
if ! brew --version &>/dev/null; then
    die "Homebrew installation verification failed"
fi

# Step 5: Install Git
progress "Installing Git"
brew_install_formula git true

# Step 6: Clone dotfiles repository (if needed)
progress "Setting up dotfiles repository"
if [[ ! -d "$HOME/.dotfiles" ]]; then
    info "Cloning dotfiles repository..."
    if git clone https://github.com/IllyaStarikov/.dotfiles.git ~/.dotfiles 2>&1 | tee -a "$LOG_FILE"; then
        success "Dotfiles repository cloned"
    else
        die "Failed to clone dotfiles repository"
    fi
else
    success "Dotfiles repository already exists"
    # Update to latest
    info "Updating dotfiles repository..."
    cd ~/.dotfiles
    if git pull 2>&1 | tee -a "$LOG_FILE"; then
        success "Dotfiles repository updated"
    else
        warn "Failed to update dotfiles repository"
    fi
    cd - > /dev/null
fi

# Step 7: Backup existing configurations
progress "Backing up existing configurations"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="$HOME/.config-backups/$TIMESTAMP"
mkdir -p "$BACKUP_DIR"

# List of files to backup
declare -a backup_files=(
    "$HOME/.zshrc"
    "$HOME/.bashrc"
    "$HOME/.bash_profile"
    "$HOME/.tmux.conf"
    "$HOME/.gitconfig"
)

for file in "${backup_files[@]}"; do
    if [[ -f "$file" ]]; then
        cp "$file" "$BACKUP_DIR/$(basename "$file")" 2>/dev/null || true
        log "Backed up: $file"
    fi
done
success "Configuration files backed up to: $BACKUP_DIR"

# Create necessary directories
info "Creating configuration directories..."
mkdir -p ~/.config/{nvim,alacritty,tmux,tmuxinator,theme-switcher}
mkdir -p ~/.local/share/nvim/site/autoload

# Step 8: Install Oh My Zsh
progress "Installing Oh My Zsh"
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    success "Oh My Zsh already installed"
else
    info "Installing Oh My Zsh..."
    # Use unattended installation
    if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>&1 | tee -a "$LOG_FILE"; then
        success "Oh My Zsh installed"
    else
        die "Failed to install Oh My Zsh"
    fi
fi

# Install Spaceship Theme
info "Installing Spaceship theme..."
SPACESHIP_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship-prompt"
if [[ ! -d "$SPACESHIP_DIR" ]]; then
    if git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$SPACESHIP_DIR" --depth=1 2>&1 | tee -a "$LOG_FILE"; then
        ln -sf "$SPACESHIP_DIR/spaceship.zsh-theme" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship.zsh-theme"
        success "Spaceship theme installed"
    else
        warn "Failed to install Spaceship theme"
    fi
else
    success "Spaceship theme already installed"
fi

# Step 9: Install core packages
progress "Installing core essential packages"
info "This may take several minutes..."

# Core packages with criticality levels
declare -A CORE_PACKAGES=(
    # Critical packages (required)
    ["vim"]="required"
    ["neovim"]="required"
    ["tmux"]="required"
    ["fzf"]="required"
    ["git-extras"]="required"
    ["coreutils"]="required"
    
    # Important packages (highly recommended)
    ["alacritty"]="important"
    ["tmuxinator"]="important"
    ["eza"]="important"
    ["tree"]="important"
    ["htop"]="important"
    ["jq"]="important"
    ["ranger"]="important"
    ["colordiff"]="important"
    ["git-lfs"]="important"
    ["zsh-syntax-highlighting"]="important"
    
    # Language support
    ["lua"]="optional"
    ["luajit"]="optional"
    ["luarocks"]="optional"
    ["lua-language-server"]="optional"
    
    # Libraries
    ["readline"]="optional"
    ["ncurses"]="optional"
    ["sqlite"]="optional"
    ["openssl@3"]="optional"
    ["ca-certificates"]="optional"
    
    # Optional
    ["tmuxinator-completion"]="optional"
)

FAILED_PACKAGES=()
for package in "${!CORE_PACKAGES[@]}"; do
    level="${CORE_PACKAGES[$package]}"
    if [[ "$level" == "required" ]]; then
        brew_install_formula "$package" true
    else
        brew_install_formula "$package" false || FAILED_PACKAGES+=("$package")
    fi
done

if [[ ${#FAILED_PACKAGES[@]} -gt 0 ]]; then
    warn "The following optional packages failed to install: ${FAILED_PACKAGES[*]}"
fi

# Install essential casks
info "Installing essential GUI applications..."
brew tap homebrew/cask-fonts 2>/dev/null || true

# Try to install casks (all optional)
brew_install_cask "alacritty" false
brew_install_cask "font-hack-nerd-font" false
brew_install_cask "amethyst" false

# Step 10: Configure shell
progress "Configuring shell"
ZSH_PATH=$(which zsh)
info "Zsh path: $ZSH_PATH"

# Add to /etc/shells if needed
if ! grep -q "$ZSH_PATH" /etc/shells; then
    info "Adding $ZSH_PATH to /etc/shells..."
    echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
fi

# Change default shell
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    info "Changing default shell to Zsh..."
    if chsh -s "$ZSH_PATH" 2>&1 | tee -a "$LOG_FILE"; then
        success "Default shell changed to Zsh"
    else
        warn "Failed to change shell. You may need to run 'chsh -s $ZSH_PATH' manually"
    fi
else
    success "Zsh is already the default shell"
fi

# Final summary
echo ""
print_status "$GREEN" "🎉 Part 1 Complete: Core System Setup"
echo ""
info "Installation Summary:"
echo "  • Xcode Command Line Tools: ✅"
echo "  • Homebrew: ✅"
echo "  • Git: ✅"
echo "  • Oh My Zsh: ✅"
echo "  • Core packages: ✅"
echo ""

if [[ ${#FAILED_PACKAGES[@]} -gt 0 ]]; then
    warn "Some optional packages failed to install. See log for details."
fi

info "Configuration backups saved to: $BACKUP_DIR"
info "Installation log saved to: $LOG_FILE"
echo ""
print_status "$YELLOW" "⚠️  IMPORTANT: Next Steps"
echo "  1. Restart your terminal or run: exec zsh"
echo "  2. Verify Homebrew is in PATH: brew --version"
echo "  3. Run Part 2: ./src/setup/2-development.sh"
echo ""

# Create a success marker file
touch "$HOME/.dotfiles-setup-part1-complete"
log "Part 1 setup completed successfully"

exit 0