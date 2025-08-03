#!/usr/bin/env bash
set -euo pipefail

# macOS-specific setup script
# This script is called from setup.sh after OS detection

# Import helper functions and variables from parent
source "$(dirname "$0")/setup-helpers.sh"

# Install Xcode Command Line Tools
install_xcode_tools() {
    info "Checking Xcode Command Line Tools..."
    if ! xcode-select -p &>/dev/null; then
        info "Installing Xcode Command Line Tools..."
        xcode-select --install
        echo "⏸️  Please complete Xcode installation in the popup, then press Enter to continue..."
        read -r
    else
        success "Xcode Command Line Tools already installed"
    fi
}

# Install Homebrew
install_homebrew() {
    info "Checking Homebrew..."
    if ! command -v brew &>/dev/null; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for this session
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        success "Homebrew already installed"
    fi
    
    # Update Homebrew
    brew update
}

# Install macOS packages via Homebrew
install_macos_packages() {
    info "Installing macOS packages..."
    
    # Core packages
    local packages=(
        # Shell and terminal
        zsh
        tmux
        alacritty
        
        # Development tools
        git
        neovim
        vim
        
        # Programming languages
        python@3.12
        ruby
        node
        go
        rust
        
        # Modern CLI tools
        fzf
        ripgrep
        fd
        bat
        eza
        htop
        bottom
        procs
        dust
        jq
        tree
        git-delta
        lazygit
        zoxide
        starship
        
        # Development utilities
        pyenv
        pyenv-virtualenv
        cmake
        pkg-config
        wget
        curl
        gh
        
        # System tools
        coreutils
        gnu-sed
        findutils
        gawk
        grep
        
        # Additional tools
        tmuxinator
        ranger
        colordiff
        imagemagick
        ffmpeg
    )
    
    for package in "${packages[@]}"; do
        if brew list --formula 2>/dev/null | grep -q "^${package}$"; then
            success "$package already installed"
        else
            info "Installing $package..."
            brew install "$package"
        fi
    done
    
    success "macOS packages installed"
}

# Install macOS casks (GUI applications)
install_macos_casks() {
    info "Installing macOS applications..."
    
    local casks=(
        # Fonts
        font-jetbrains-mono-nerd-font
        font-hack-nerd-font
        font-fira-code-nerd-font
        font-meslo-lg-nerd-font
        
        # Optional applications (non-critical)
        # docker
        # visual-studio-code
        # iterm2
    )
    
    for cask in "${casks[@]}"; do
        if brew list --cask 2>/dev/null | grep -q "^${cask}$"; then
            success "$cask already installed"
        else
            info "Installing $cask..."
            brew install --cask "$cask" || warning "Failed to install $cask (continuing...)"
        fi
    done
    
    success "macOS applications installed"
}

# Configure macOS-specific settings
configure_macos() {
    info "Configuring macOS settings..."
    
    # Enable key repeat for Vim
    defaults write -g ApplePressAndHoldEnabled -bool false
    
    # Fast key repeat
    defaults write -g KeyRepeat -int 2
    defaults write -g InitialKeyRepeat -int 15
    
    # Show hidden files in Finder
    defaults write com.apple.finder AppleShowAllFiles -bool true
    
    # Don't create .DS_Store files on network volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    
    # Enable subpixel font rendering on non-Apple LCDs
    defaults write NSGlobalDomain AppleFontSmoothing -int 2
    
    # Set Zsh as default shell if not already
    if [[ "$SHELL" != *"zsh"* ]]; then
        info "Setting Zsh as default shell..."
        chsh -s /bin/zsh
    fi
    
    success "macOS configuration complete"
}

# Main macOS setup
main() {
    info "Starting macOS setup..."
    
    # Install Xcode tools
    install_xcode_tools
    
    # Install Homebrew
    install_homebrew
    
    # Install packages
    install_macos_packages
    
    # Install casks
    install_macos_casks
    
    # Configure macOS
    configure_macos
    
    success "macOS setup complete!"
}

# Run main function
main "$@"