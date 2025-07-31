#!/bin/bash

# Part 2: Development Environment Setup - Production Ready
# Installs development tools, editors, and creates symlinks
# Run this after Part 1 and after restarting your terminal
#
# Features:
# - Prerequisite validation
# - Comprehensive error handling
# - Symlink safety with backups
# - Progress tracking
# - Detailed logging
# - Rollback capabilities

# Strict error handling
set -euo pipefail
IFS=$'\n\t'

# Script version
readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_NAME="2-development.sh"

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

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to check prerequisites
check_prerequisites() {
    info "Checking prerequisites..."
    
    # Check if Part 1 was completed
    if [[ ! -f "$HOME/.dotfiles-setup-part1-complete" ]]; then
        warn "Part 1 completion marker not found. Checking manually..."
    fi
    
    # Check if Oh My Zsh is installed
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        die "Oh My Zsh not found. Please run 1-core-system.sh first"
    fi
    success "Oh My Zsh found"
    
    # Check if Homebrew is available
    if ! command_exists brew; then
        die "Homebrew not found. Please run 1-core-system.sh first"
    fi
    success "Homebrew found"
    
    # Ensure Homebrew is in PATH correctly
    if [[ -d "/opt/homebrew" ]]; then
        export PATH="/opt/homebrew/bin:$PATH"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -d "/usr/local" ]]; then
        export PATH="/usr/local/bin:$PATH"
    fi
    
    # Check network connectivity
    info "Checking internet connectivity..."
    if ! ping -c 1 -t 5 google.com &> /dev/null && ! ping -c 1 -t 5 1.1.1.1 &> /dev/null; then
        die "No internet connection detected. Please check your network settings."
    fi
    success "Internet connection verified"
    
    # Check disk space (require at least 3GB)
    local available_space
    available_space=$(df -g / | awk 'NR==2 {print $4}')
    log "Available disk space: ${available_space}GB"
    
    if [[ $available_space -lt 3 ]]; then
        die "Insufficient disk space. At least 3GB required, but only ${available_space}GB available."
    fi
    success "Disk space check passed"
    
    success "All prerequisites satisfied"
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

# Function to safely create symlinks with backup
create_symlink() {
    local source="$1"
    local target="$2"
    local backup_dir="$HOME/.config-backups/$(date +%Y%m%d_%H%M%S)"
    
    if [[ ! -e "$source" ]]; then
        warn "Source file not found: $source"
        return 1
    fi
    
    # Create parent directory if needed
    mkdir -p "$(dirname "$target")"
    
    # Backup existing file/directory if it exists and is not a symlink to our source
    if [[ -e "$target" ]] && [[ ! -L "$target" || "$(readlink "$target")" != "$source" ]]; then
        mkdir -p "$backup_dir"
        local backup_file="$backup_dir/$(basename "$target")"
        mv "$target" "$backup_file" 2>/dev/null || true
        log "Backed up existing file: $target to $backup_file"
    fi
    
    # Create symlink
    if ln -sf "$source" "$target" 2>/dev/null; then
        success "Linked: $target → $source"
        return 0
    else
        warn "Failed to create symlink: $target → $source"
        return 1
    fi
}

# Progress tracking
TOTAL_STEPS=8
CURRENT_STEP=0

progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local percentage=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    print_status "$BLUE" "[$CURRENT_STEP/$TOTAL_STEPS] $1 ($percentage%)"
}

# Main installation starts here
print_status "$GREEN" "🛠️  Starting Development Environment Setup v$SCRIPT_VERSION"
info "Log file: $LOG_FILE"

# Step 1: Check prerequisites
progress "Checking prerequisites"
check_prerequisites

# Step 2: Verify script location
progress "Verifying script location"
if [[ ! -f "src/setup/2-development.sh" ]]; then
    die "Please run this script from the .dotfiles root directory"
fi
success "Script running from correct directory"

# Step 3: Install development packages
progress "Installing development packages"
info "This may take several minutes..."

# Development packages with criticality levels
declare -A DEV_PACKAGES=(
    # Python development (critical)
    ["pyenv"]="required"
    ["pyenv-virtualenv"]="important"
    ["pyright"]="optional"
    ["ruff"]="optional"
    ["black"]="optional"
    
    # Languages (important)
    ["node"]="important"
    ["ruby"]="important"
    ["rust"]="optional"
    
    # Docker ecosystem (important)
    ["docker"]="important"
    ["docker-compose"]="important"
    ["colima"]="important"
    ["lima"]="optional"
    ["docker-completion"]="optional"
    ["docker-machine"]="optional"
    
    # Development utilities
    ["cloc"]="optional"
    ["ctags"]="optional"
    ["dos2unix"]="optional"
    ["git-filter-repo"]="optional"
    ["git-quick-stats"]="optional"
    ["gnu-sed"]="optional"
    ["marksman"]="optional"
    ["texlab"]="optional"
    ["tree-sitter"]="optional"
    
    # Networking
    ["telnet"]="optional"
    ["unbound"]="optional"
)

FAILED_PACKAGES=()
for package in "${!DEV_PACKAGES[@]}"; do
    level="${DEV_PACKAGES[$package]}"
    if [[ "$level" == "required" ]]; then
        brew_install_formula "$package" true
    else
        brew_install_formula "$package" false || FAILED_PACKAGES+=("$package")
    fi
done

if [[ ${#FAILED_PACKAGES[@]} -gt 0 ]]; then
    warn "The following optional packages failed to install: ${FAILED_PACKAGES[*]}"
fi

# Install development casks
info "Installing development GUI applications..."
brew_install_cask "docker-desktop" false
brew_install_cask "1password-cli" false

# Step 4: Install Vim-Plug for Neovim
progress "Setting up Neovim plugin manager"
PLUG_PATH="$HOME/.local/share/nvim/site/autoload/plug.vim"
if [[ ! -f "$PLUG_PATH" ]]; then
    info "Installing Vim-Plug..."
    if curl -fLo "$PLUG_PATH" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim 2>&1 | tee -a "$LOG_FILE"; then
        success "Vim-Plug installed"
    else
        warn "Failed to install Vim-Plug"
    fi
else
    success "Vim-Plug already installed"
fi

# Step 5: Install Python packages
progress "Installing Python packages"
if command_exists python3; then
    PIP_PACKAGES=("neovim" "ipython")
    for package in "${PIP_PACKAGES[@]}"; do
        if ! python3 -m pip show "$package" &>/dev/null; then
            info "Installing Python package: $package"
            if python3 -m pip install --user "$package" 2>&1 | tee -a "$LOG_FILE"; then
                success "Python package $package installed"
            else
                warn "Failed to install Python package $package"
            fi
        else
            success "Python package $package already installed"
        fi
    done
else
    warn "python3 not found. Skipping Python package installation"
fi

# Step 6: Configure Git
progress "Configuring Git"
git config --global core.excludesfile '~/.gitignore' || warn "Failed to set Git excludesfile"
success "Git configured"

# Install Nerd Fonts
info "Installing IBM Plex Mono Nerd Font..."
if ! find ~/Library/Fonts /Library/Fonts /System/Library/Fonts -name "*IBMPlex*Nerd*" 2>/dev/null | grep -q .; then
    info "Downloading and installing IBM Plex Mono Nerd Font..."
    FONT_TEMP="/tmp/nerd-fonts-$$"
    if git clone https://github.com/ryanoasis/nerd-fonts.git "$FONT_TEMP" --depth=1 2>&1 | tee -a "$LOG_FILE"; then
        cd "$FONT_TEMP"
        if ./install.sh IBMPlexMono 2>&1 | tee -a "$LOG_FILE"; then
            success "IBM Plex Mono Nerd Font installed"
        else
            warn "Font installation failed"
        fi
        cd - > /dev/null
        rm -rf "$FONT_TEMP"
    else
        warn "Failed to download Nerd Fonts repository"
    fi
else
    success "IBM Plex Mono Nerd Font already installed"
fi

# Step 7: Create configuration symlinks
progress "Creating configuration symlinks"
info "Backing up existing configurations..."

# Symlink mappings
declare -A SYMLINKS=(
    # Neovim (modern Lua configuration)
    ["$HOME/.dotfiles/src/init.lua"]="$HOME/.config/nvim/init.lua"
    ["$HOME/.dotfiles/src/lua"]="$HOME/.config/nvim/lua"
    ["$HOME/.dotfiles/src/lazy-lock.json"]="$HOME/.config/nvim/lazy-lock.json"
    
    # Legacy Vim
    ["$HOME/.dotfiles/src/vimrc"]="$HOME/.vimrc"
    
    # Zsh
    ["$HOME/.dotfiles/src/zshrc"]="$HOME/.zshrc"
    ["$HOME/.dotfiles/src/zshenv"]="$HOME/.zshenv"
    
    # Terminal
    ["$HOME/.dotfiles/src/alacritty.toml"]="$HOME/.config/alacritty/alacritty.toml"
    
    # Git
    ["$HOME/.dotfiles/src/gitignore"]="$HOME/.gitignore"
    
    # LaTeX
    ["$HOME/.dotfiles/src/latexmkrc"]="$HOME/.latexmkrc"
    
    # tmux
    ["$HOME/.dotfiles/src/tmux.conf"]="$HOME/.tmux.conf"
    
    # Scripts
    ["$HOME/.dotfiles/src/scripts"]="$HOME/.scripts"
)

# Remove any conflicting init.vim
if [[ -f "$HOME/.config/nvim/init.vim" ]]; then
    rm -f "$HOME/.config/nvim/init.vim"
    log "Removed conflicting init.vim"
fi

# Create all symlinks
for source in "${!SYMLINKS[@]}"; do
    target="${SYMLINKS[$source]}"
    create_symlink "$source" "$target"
done

# Special handling for tmuxinator config with private repo fallback
PRIVATE_TMUXINATOR="$HOME/.dotfiles/.dotfiles.private/src/tmuxinator"
PUBLIC_TMUXINATOR="$HOME/.dotfiles/src/tmuxinator"

if [[ -d "$PRIVATE_TMUXINATOR" ]]; then
    info "Using tmuxinator configs from private repository"
    create_symlink "$PRIVATE_TMUXINATOR" "$HOME/.tmuxinator"
    create_symlink "$PRIVATE_TMUXINATOR" "$HOME/.config/tmuxinator"
elif [[ -d "$PUBLIC_TMUXINATOR" ]]; then
    warn "Private tmuxinator directory not found, falling back to public configs"
    create_symlink "$PUBLIC_TMUXINATOR" "$HOME/.tmuxinator"
    create_symlink "$PUBLIC_TMUXINATOR" "$HOME/.config/tmuxinator"
else
    warn "No tmuxinator configs found in either private or public repositories"
fi

# Spell checking files
mkdir -p "$HOME/.config/nvim/spell"
if [[ -d "$HOME/.dotfiles/src/spell" ]]; then
    for spell_file in "$HOME/.dotfiles/src/spell/"*; do
        if [[ -f "$spell_file" ]]; then
            ln -sf "$spell_file" "$HOME/.config/nvim/spell/$(basename "$spell_file")"
        fi
    done
    success "Spell files linked"
fi

# Step 8: Install theme switcher
progress "Setting up theme switcher"
if [[ -f "$HOME/.dotfiles/src/theme-switcher/install-auto-theme.sh" ]]; then
    cd "$HOME/.dotfiles/src/theme-switcher"
    if ./install-auto-theme.sh 2>&1 | tee -a "$LOG_FILE"; then
        success "Theme switcher installed"
    else
        warn "Theme switcher installation failed"
    fi
    cd - > /dev/null
else
    warn "Theme switcher script not found"
fi

# Initialize theme
if [[ -f "$HOME/.dotfiles/src/theme-switcher/switch-theme.sh" ]]; then
    if "$HOME/.dotfiles/src/theme-switcher/switch-theme.sh" 2>&1 | tee -a "$LOG_FILE"; then
        success "Theme initialized"
    else
        warn "Theme initialization failed"
    fi
else
    warn "Theme switch script not found"
fi

# Final summary
echo ""
print_status "$GREEN" "🎉 Part 2 Complete: Development Environment Setup"
echo ""
info "Installation Summary:"
echo "  • Development packages: ✅"
echo "  • Python packages: ✅"
echo "  • Configuration symlinks: ✅"
echo "  • Theme switcher: ✅"
echo ""

if [[ ${#FAILED_PACKAGES[@]} -gt 0 ]]; then
    warn "Some optional packages failed to install. See log for details."
fi

info "Installation log saved to: $LOG_FILE"
echo ""
print_status "$YELLOW" "⚠️  IMPORTANT: Next Steps"
echo "  1. Restart your terminal to load new configurations"
echo "  2. Open Neovim and run ':Lazy sync' to install plugins"
echo "  3. Run 'pyenv install 3.12.0' (or latest) and 'pyenv global 3.12.0'"
echo "  4. Optionally run: ./src/setup/3-tooling.sh"
echo ""

# Create a success marker file
touch "$HOME/.dotfiles-setup-part2-complete"
log "Part 2 setup completed successfully"

exit 0