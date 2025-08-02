#!/usr/bin/env bash
set -euo pipefail

# Cross-platform setup script for dotfiles
# Supports macOS and Linux (Ubuntu/Debian, Fedora/RHEL, Arch)

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Helper functions
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        info "Detected macOS"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        info "Detected Linux"
        
        # Detect Linux distribution
        if [[ -f /etc/os-release ]]; then
            . /etc/os-release
            DISTRO=$ID
            DISTRO_VERSION=$VERSION_ID
            info "Distribution: $DISTRO $DISTRO_VERSION"
        else
            error "Cannot detect Linux distribution"
            exit 1
        fi
        
        # Detect package manager
        if command -v apt-get &> /dev/null; then
            PKG_MANAGER="apt"
            PKG_INSTALL="sudo apt-get install -y"
            PKG_UPDATE="sudo apt-get update && sudo apt-get upgrade -y"
        elif command -v dnf &> /dev/null; then
            PKG_MANAGER="dnf"
            PKG_INSTALL="sudo dnf install -y"
            PKG_UPDATE="sudo dnf upgrade -y"
        elif command -v yum &> /dev/null; then
            PKG_MANAGER="yum"
            PKG_INSTALL="sudo yum install -y"
            PKG_UPDATE="sudo yum upgrade -y"
        elif command -v pacman &> /dev/null; then
            PKG_MANAGER="pacman"
            PKG_INSTALL="sudo pacman -S --noconfirm"
            PKG_UPDATE="sudo pacman -Syu --noconfirm"
        elif command -v zypper &> /dev/null; then
            PKG_MANAGER="zypper"
            PKG_INSTALL="sudo zypper install -y"
            PKG_UPDATE="sudo zypper update -y"
        else
            error "No supported package manager found"
            exit 1
        fi
        info "Package manager: $PKG_MANAGER"
    else
        error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
}

# Export detected values for use in other scripts
export OS
export DISTRO
export PKG_MANAGER
export PKG_INSTALL
export PKG_UPDATE

# Main setup flow
main() {
    echo "🚀 Cross-Platform Dotfiles Setup"
    echo "================================"
    
    # Detect operating system
    detect_os
    
    # Get the directory of this script
    SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    export DOTFILES_DIR="$(dirname "$(dirname "$SETUP_DIR")")"
    
    info "Dotfiles directory: $DOTFILES_DIR"
    
    # Run appropriate setup based on OS
    if [[ "$OS" == "macos" ]]; then
        info "Running macOS setup..."
        bash "$SETUP_DIR/setup-macos.sh"
    elif [[ "$OS" == "linux" ]]; then
        info "Running Linux setup..."
        bash "$SETUP_DIR/setup-linux.sh"
    fi
    
    # Run common setup that works on both platforms
    info "Running common setup..."
    bash "$SETUP_DIR/setup-common.sh"
    
    success "Setup complete!"
    echo ""
    echo "🎯 Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Open Neovim and run :Lazy to install plugins"
    echo "  3. Run 'theme' to set up your preferred theme"
    echo "  4. Open tmux and press prefix + I to install plugins"
}

# Run main function
main "$@"