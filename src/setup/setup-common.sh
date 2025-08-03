#!/usr/bin/env bash
set -euo pipefail

# Common setup script for both macOS and Linux
# This script is called from setup.sh after OS-specific setup

# Import helper functions and variables from parent
source "$(dirname "$0")/setup-helpers.sh"

# Install Zinit (Zsh plugin manager)
install_zinit() {
    info "Installing Zinit..."
    ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
    if [[ ! -d "$ZINIT_HOME" ]]; then
        mkdir -p "$(dirname $ZINIT_HOME)"
        git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
        success "Zinit installed"
    else
        success "Zinit already installed"
    fi
}

# Install tmux plugin manager
install_tpm() {
    info "Installing tmux plugin manager..."
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        success "TPM installed"
    else
        success "TPM already installed"
    fi
}

# Create symlinks for dotfiles
create_symlinks() {
    info "Creating configuration symlinks..."
    
    # Create necessary directories
    mkdir -p ~/.config/{nvim,alacritty,tmux,tmuxinator,fontconfig}
    mkdir -p ~/.local/share/nvim/site/autoload
    mkdir -p ~/.cache/nvim
    
    # Define symlinks
    declare -A symlinks=(
        # Neovim
        ["$DOTFILES_DIR/src/init.lua"]="$HOME/.config/nvim/init.lua"
        ["$DOTFILES_DIR/src/lua"]="$HOME/.config/nvim/lua"
        ["$DOTFILES_DIR/src/lazy-lock.json"]="$HOME/.config/nvim/lazy-lock.json"
        
        # Shell
        ["$DOTFILES_DIR/src/zshrc"]="$HOME/.zshrc"
        ["$DOTFILES_DIR/src/zshenv"]="$HOME/.zshenv"
        ["$DOTFILES_DIR/src/zsh"]="$HOME/.config/zsh"
        
        # Terminal
        ["$DOTFILES_DIR/src/alacritty.toml"]="$HOME/.config/alacritty/alacritty.toml"
        
        # Git
        ["$DOTFILES_DIR/src/gitconfig"]="$HOME/.gitconfig"
        ["$DOTFILES_DIR/src/gitignore"]="$HOME/.gitignore"
        
        # tmux
        ["$DOTFILES_DIR/src/tmux.conf"]="$HOME/.tmux.conf"
        
        # Scripts
        ["$DOTFILES_DIR/src/scripts"]="$HOME/.scripts"
        
        # LaTeX
        ["$DOTFILES_DIR/src/latexmkrc"]="$HOME/.latexmkrc"
        
        # Clangd
        ["$DOTFILES_DIR/src/clangd_config.yaml"]="$HOME/.config/clangd/config.yaml"
    )
    
    # Create symlinks
    for source in "${!symlinks[@]}"; do
        target="${symlinks[$source]}"
        
        # Skip if source doesn't exist
        if [[ ! -e "$source" ]]; then
            warning "Source not found: $source"
            continue
        fi
        
        # Create parent directory if needed
        mkdir -p "$(dirname "$target")"
        
        # Backup existing file if it's not a symlink to our source
        if [[ -e "$target" ]] && [[ ! -L "$target" || "$(readlink "$target")" != "$source" ]]; then
            backup_dir="$HOME/.config-backups/$(date +%Y%m%d_%H%M%S)"
            mkdir -p "$backup_dir"
            mv "$target" "$backup_dir/$(basename "$target")"
            info "Backed up existing file: $target"
        fi
        
        # Create symlink
        ln -sf "$source" "$target"
        success "Linked: $target → $source"
    done
    
    # Handle tmuxinator configs
    if [[ -d "$DOTFILES_DIR/.dotfiles.private/src/tmuxinator" ]]; then
        ln -sf "$DOTFILES_DIR/.dotfiles.private/src/tmuxinator" "$HOME/.tmuxinator"
        ln -sf "$DOTFILES_DIR/.dotfiles.private/src/tmuxinator" "$HOME/.config/tmuxinator"
    elif [[ -d "$DOTFILES_DIR/src/tmuxinator" ]]; then
        ln -sf "$DOTFILES_DIR/src/tmuxinator" "$HOME/.tmuxinator"
        ln -sf "$DOTFILES_DIR/src/tmuxinator" "$HOME/.config/tmuxinator"
    fi
    
    # Link spell files
    if [[ -d "$DOTFILES_DIR/src/spell" ]]; then
        mkdir -p "$HOME/.config/nvim/spell"
        for spell_file in "$DOTFILES_DIR/src/spell/"*; do
            if [[ -f "$spell_file" ]]; then
                ln -sf "$spell_file" "$HOME/.config/nvim/spell/$(basename "$spell_file")"
            fi
        done
    fi
    
    success "Symlinks created"
}

# Install Python packages
install_python_packages() {
    info "Installing Python packages..."
    
    # Ensure pip is updated
    python3 -m pip install --upgrade pip setuptools wheel
    
    # Install essential Python packages
    local packages=(
        neovim
        pynvim
        ipython
        black
        ruff
        pylint
        mypy
        debugpy
    )
    
    for package in "${packages[@]}"; do
        python3 -m pip install --user "$package" || warning "Failed to install $package"
    done
    
    success "Python packages installed"
}

# Install Node packages
install_node_packages() {
    info "Installing Node packages..."
    
    # Install global Node packages
    local packages=(
        neovim
        typescript
        typescript-language-server
        vscode-langservers-extracted
        yaml-language-server
        @tailwindcss/language-server
        prettier
        eslint
    )
    
    for package in "${packages[@]}"; do
        npm install -g "$package" || warning "Failed to install $package"
    done
    
    success "Node packages installed"
}

# Install Rust packages
install_rust_packages() {
    info "Installing Rust packages..."
    
    # Ensure cargo is in PATH
    if [[ -f "$HOME/.cargo/env" ]]; then
        source "$HOME/.cargo/env"
    fi
    
    # Only install if cargo is available
    if command -v cargo &> /dev/null; then
        # These might already be installed by OS-specific scripts
        local packages=(
            # Tools that might not be in package managers
            stylua
            selene
        )
        
        for package in "${packages[@]}"; do
            if ! command -v "$package" &> /dev/null; then
                cargo install "$package" || warning "Failed to install $package"
            fi
        done
    else
        warning "Cargo not found, skipping Rust packages"
    fi
    
    success "Rust packages installed"
}

# Setup Neovim
setup_neovim() {
    info "Setting up Neovim..."
    
    # Install vim-plug (backup option)
    if [[ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]]; then
        curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
    
    # Note: Lazy.nvim will be installed automatically on first Neovim launch
    
    success "Neovim setup complete"
}

# Configure Git
configure_git() {
    info "Configuring Git..."
    
    # Set global gitignore
    git config --global core.excludesfile '~/.gitignore'
    
    # Set default branch name
    git config --global init.defaultBranch main
    
    # Enable colors
    git config --global color.ui auto
    
    # Set up useful aliases
    git config --global alias.st status
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.unstage 'reset HEAD --'
    git config --global alias.last 'log -1 HEAD'
    
    success "Git configured"
}

# Main common setup
main() {
    info "Starting common setup..."
    
    # Install Zinit
    install_zinit
    
    # Install TPM
    install_tpm
    
    # Create symlinks
    create_symlinks
    
    # Install language-specific packages
    install_python_packages
    install_node_packages
    install_rust_packages
    
    # Setup Neovim
    setup_neovim
    
    # Configure Git
    configure_git
    
    # Create update script symlink
    if [[ -f "$DOTFILES_DIR/src/scripts/update" ]]; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$DOTFILES_DIR/src/scripts/update" "$HOME/.local/bin/update-system"
        info "Update script available as 'update-system'"
    fi
    
    success "Common setup complete!"
}

# Run main function
main "$@"