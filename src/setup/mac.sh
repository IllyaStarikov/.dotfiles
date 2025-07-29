#!/bin/bash
set -euo pipefail

echo "🚀 macOS Development Environment Setup"
echo "======================================"

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "❌ This script is designed for macOS only"
    exit 1
fi

# Install Xcode Command Line Tools first
echo "📦 Installing Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
    xcode-select --install
    echo "⏸️  Please complete Xcode installation in the popup, then press Enter to continue..."
    read -r
fi

# Install Homebrew
echo "🍺 Installing Homebrew..."
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for this session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# Update Homebrew
echo "📦 Updating Homebrew..."
brew update

# Clone dotfiles if not already present
if [[ ! -d "$HOME/.dotfiles" ]]; then
    echo "📂 Cloning dotfiles..."
    git clone https://github.com/IllyaStarikov/.dotfiles.git ~/.dotfiles
else
    echo "✅ Dotfiles already present"
fi

# Install essential packages first
echo "📦 Installing essential packages..."
brew install git neovim tmux

# Install development tools
echo "🛠️  Installing development tools..."
brew install \
    pyenv \
    ranger \
    fzf \
    tmuxinator \
    eza \
    bat \
    ripgrep \
    fd \
    htop \
    procs \
    git-delta \
    zoxide \
    zsh-syntax-highlighting \
    zsh-autosuggestions \
    jq \
    tree \
    wget \
    curl \
    gh

# Install programming language tools
echo "🛠️  Installing programming language tools..."
brew install \
    llvm \
    cmake \
    ninja \
    rust \
    go \
    node

# Install LSP servers
echo "📡 Installing Language Servers..."
brew install \
    pyright \
    lua-language-server \
    marksman \
    yaml-language-server \
    typescript-language-server

# Install additional Python tools
echo "🐍 Installing Python LSP dependencies..."
python3 -m pip install --upgrade pip setuptools wheel
python3 -m pip install \
    neovim \
    ipython \
    pynvim \
    python-lsp-server \
    pylsp-mypy \
    python-lsp-black \
    python-lsp-ruff \
    debugpy

# Install fonts
echo "🔤 Installing fonts..."
brew tap homebrew/cask-fonts
brew install --cask font-fira-code-nerd-font
brew install --cask font-symbols-only-nerd-font
brew install --cask font-meslo-lg-nerd-font

# Backup existing configs
echo "💾 Backing up existing configurations..."
[[ -f "$HOME/.zshrc" ]] && mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
[[ -f "$HOME/.vimrc" ]] && mv "$HOME/.vimrc" "$HOME/.vimrc.backup.$(date +%Y%m%d_%H%M%S)"

# Create necessary directories
echo "📁 Creating configuration directories..."
mkdir -p "$HOME/.config/nvim"
mkdir -p "$HOME/.config/alacritty"
mkdir -p "$HOME/.config/tmux"

# Run aliases setup
echo "🔗 Setting up symlinks..."
if [[ -f "$HOME/.dotfiles/src/setup/aliases.sh" ]]; then
    bash "$HOME/.dotfiles/src/setup/aliases.sh"
fi

# Install Oh My Zsh (this might change the shell)
echo "🐚 Installing Oh My Zsh..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    RUNZSH=no sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install Spaceship theme
echo "🚀 Installing Spaceship theme..."
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship-prompt" ]]; then
    git clone https://github.com/denysdovhan/spaceship-prompt.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship-prompt" --depth=1
    ln -sf "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship-prompt/spaceship.zsh-theme" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship.zsh-theme"
fi

# Python setup
echo "🐍 Setting up Python environment..."
if command -v pyenv &>/dev/null; then
    # Install latest Python 3
    LATEST_PYTHON=$(pyenv install --list | grep -E "^\s*3\.[0-9]+\.[0-9]+$" | tail -1 | xargs)
    if [[ -n "$LATEST_PYTHON" ]]; then
        pyenv install -s "$LATEST_PYTHON"
        pyenv global "$LATEST_PYTHON"
    fi
fi

# Install tmux plugin manager
echo "📦 Installing tmux plugin manager..."
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Install Neovim providers
echo "💎 Installing Neovim providers..."
gem install neovim 2>/dev/null || true
npm install -g neovim 2>/dev/null || true

# Setup Rust (for blink.cmp and other tools)
echo "🦀 Setting up Rust..."
if ! command -v cargo &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# Change default shell to zsh if needed
if [[ "$SHELL" != *"zsh"* ]]; then
    echo "🐚 Changing default shell to zsh..."
    chsh -s /bin/zsh
fi

# Setup git configuration
echo "⚙️  Setting up Git configuration..."
git config --global core.excludesfile '~/.gitignore'

# Final instructions
echo ""
echo "✅ Setup complete!"
echo ""
echo "🎯 Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Open Neovim and run :Lazy to install plugins"
echo "  3. Run 'theme' to set up your preferred theme"
echo ""
echo "📚 Optional tools to consider:"
echo "  - brew install --cask alacritty  # GPU-accelerated terminal"
echo "  - brew install starship           # Alternative to spaceship prompt"
echo ""