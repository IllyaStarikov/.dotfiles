# 🛠️ Setup & Installation

Complete automated installation system for dotfiles across macOS and Linux platforms. One command sets up your entire development environment.

## 🚀 Quick Start

### Full Installation (Recommended)
```bash
cd ~/.dotfiles
./src/setup/setup.sh
```

### Core Installation Only
```bash
./src/setup/setup.sh --core
```

### Just Create Symlinks
```bash
./src/setup/symlinks.sh
```

## 📋 Installation Modes

| Mode | Command | Description | Time | Use Case |
|------|---------|-------------|------|----------|
| **Full** | `./setup.sh` | Complete dev environment | 15-30 min | New machines, fresh installs |
| **Core** | `./setup.sh --core` | Essential tools only | 5-10 min | Minimal setups, servers |
| **Symlinks** | `./setup.sh --symlinks` | Dotfile links only | 30 sec | Config updates only |

## 🔧 Main Scripts

### setup.sh - Master Installation Script

The unified entry point for complete system configuration.

**Features:**
- 🔍 **Auto-detection**: OS, architecture, package managers
- 📦 **Package Management**: Homebrew (macOS), apt/dnf/pacman (Linux)  
- 🔗 **Symlink Creation**: All dotfiles automatically linked
- 📊 **Progress Tracking**: Real-time installation status
- 🛡️ **Safety First**: Backups, error handling, rollback support
- 📝 **Comprehensive Logging**: Detailed logs for troubleshooting

**Command Line Options:**
```bash
./setup.sh [MODE] [OPTIONS]

# Installation Modes
./setup.sh              # Full installation (interactive)
./setup.sh --core       # Essential packages only
./setup.sh --symlinks   # Create symlinks only

# Advanced Options  
./setup.sh --skip-brew      # Skip Homebrew packages (work machines)
./setup.sh --force-brew     # Force brew install (override work detection)
./setup.sh --verbose        # Detailed output for debugging
./setup.sh --help          # Show all options
```

**Platform Support:**
- **macOS**: Intel & Apple Silicon (10.15+)
- **Ubuntu/Debian**: 18.04+ (apt package manager)
- **Fedora/RHEL**: 7+ (dnf/yum package manager)  
- **Arch Linux**: Latest (pacman package manager)

### symlinks.sh - Dotfile Symlink Manager

Intelligent symlink creation with backup and safety features.

**Features:**
- 🔗 **Smart Linking**: Detects existing symlinks, avoids duplicates
- 💾 **Automatic Backups**: Existing files moved to `~/.dotfiles-backup/`
- 🎯 **Selective Linking**: Skip already correct symlinks
- 📊 **Status Reporting**: Summary of created, skipped, and backed up files
- 🔍 **Validation**: Verifies symlink targets exist and are correct

**Symlink Mapping:**
```bash
# Core configurations
~/.dotfiles/src/zsh/zshrc → ~/.zshrc
~/.dotfiles/src/git/gitconfig → ~/.gitconfig  
~/.dotfiles/src/neovim → ~/.config/nvim

# Terminal configurations
~/.dotfiles/src/kitty → ~/.config/kitty
~/.dotfiles/src/wezterm → ~/.config/wezterm

# Language configurations  
~/.dotfiles/src/language/pyproject.toml → ~/.pyproject.toml
~/.dotfiles/src/language/ruff.toml → ~/.ruff.toml
```

## 📦 Package Installation

### Full Installation Packages

**Core System Tools:**
```bash
# Essential utilities
git, neovim, tmux, zsh
starship, ripgrep, fd, bat, eza
jq, curl, wget, htop, tree

# Development tools  
git-delta, lazygit, gh (GitHub CLI)
fzf, direnv, asdf (version manager)
```

**Programming Languages:**
```bash
# Python ecosystem
python3, pip, pipx
pyenv (macOS), python3-venv (Linux)

# Node.js ecosystem  
node, npm, yarn
nvm (version manager)

# Rust ecosystem
rustc, cargo, rustup
rust-analyzer, cargo-nextest

# Other languages
go, gopls (Go LSP)
cmake, ninja-build
llvm, clang
```

**Language Servers & Dev Tools:**
```bash
# LSP servers
lua-language-server
typescript-language-server  
pyright, ruff-lsp
rust-analyzer
gopls, delve (Go debugger)

# Formatters & linters
stylua (Lua), prettier (JS/TS)
black, isort (Python)
rustfmt, clippy (Rust)
shfmt, shellcheck (Shell)
```

**macOS Specific:**
```bash
# GUI Applications (via Homebrew Cask)
alacritty, wezterm      # Terminal emulators
raycast                 # Launcher/productivity
font-jetbrains-mono-nerd-font  # Programming font

# macOS CLI tools
mas (Mac App Store CLI)
trash (safe file deletion)
pbcopy, pbpaste (clipboard)
```

**Linux Specific:**
```bash
# Desktop environment tools
xclip, xsel (clipboard)
build-essential (compilation tools)
software-properties-common
apt-transport-https (Ubuntu/Debian)
```

### Core Installation Packages

Minimal set for basic development:
```bash
# Absolutely essential
git, neovim, tmux, zsh, starship
ripgrep, fd, bat, curl
python3, node, go
```

## 🔧 Advanced Configuration

### Work Environment Detection

The setup script automatically detects work environments and adjusts behavior:

```bash
# Work machine detection (based on hostname/domain)
if [[ "$(hostname)" =~ google|corp|work ]]; then
    # Skip GUI applications
    # Use work-specific package sources
    # Enable work-specific configurations
fi
```

### Custom Package Lists

Edit `setup.sh` to modify package installations:

```bash
# Core packages (always installed)
readonly CORE_PACKAGES=(
    "git" "neovim" "tmux" "zsh"
    "starship" "ripgrep" "fd" "bat"
)

# Development packages (full mode only)  
readonly DEV_PACKAGES=(
    "python3" "node" "go" "rust"
    "docker" "kubernetes-cli"
)

# Language servers (development mode)
readonly LSP_PACKAGES=(
    "lua-language-server"
    "typescript-language-server"
    "pyright" "rust-analyzer"
)
```

### Environment Variables

Control installation behavior via environment variables:

```bash
# Debug mode
VERBOSE=true ./setup.sh

# Skip interactive prompts
AUTO_INSTALL=true ./setup.sh

# Custom log location
LOG_FILE="/tmp/dotfiles-setup.log" ./setup.sh

# Work machine override
FORCE_BREW=true ./setup.sh
```

## 📊 Installation Process

### Phase 1: System Preparation
1. **OS Detection**: Identify platform and architecture  
2. **Package Manager**: Install/update Homebrew (macOS) or native (Linux)
3. **Permissions**: Check sudo access for system packages
4. **Backup**: Create backup directory for existing files

### Phase 2: Core Installation  
1. **Essential Packages**: Install git, zsh, neovim, tmux
2. **Shell Setup**: Install Zinit plugin manager
3. **Symlinks**: Create all dotfile symlinks
4. **Fonts**: Install programming fonts (GUI systems)

### Phase 3: Development Tools (Full Mode)
1. **Languages**: Python, Node.js, Rust, Go  
2. **Version Managers**: pyenv, nvm, rustup
3. **LSP Servers**: Language servers for development
4. **Additional Tools**: Docker, Kubernetes, cloud CLIs

### Phase 4: Configuration
1. **Shell Integration**: Source new configurations
2. **Plugin Installation**: Initialize package managers
3. **Validation**: Test core functionality
4. **Summary**: Report installation status

## 🛡️ Safety & Recovery

### Automatic Backups

Existing files are safely backed up before replacement:

```bash
# Backup location
~/.dotfiles-backup/
├── 20240101_120000/          # Timestamped backup
│   ├── .zshrc               # Original files
│   ├── .gitconfig
│   └── .config/
│       └── nvim/
```

### Rollback Process

```bash
# Restore from backup
cd ~/.dotfiles-backup/$(ls -1 | tail -1)  # Latest backup
cp -r * ~/ # Restore files

# Remove symlinks
find ~ -type l -lname "*/.dotfiles/*" -delete
```

### Error Handling

The setup script continues on non-critical errors:

```bash
# Example error handling
if ! install_package "optional-tool"; then
    log_warning "Failed to install optional-tool, continuing..."
else
    log_success "Installed optional-tool"
fi
```

## 📝 Logging & Debugging

### Log Files

Detailed logs created for every installation:

```bash
# Log file naming
~/.dotfiles-setup-YYYYMMDD_HHMMSS.log

# View latest log
ls -la ~/.dotfiles-setup-*.log | tail -1
tail -f ~/.dotfiles-setup-*.log  # Follow in real-time
```

### Log Content

```bash
[2024-01-01 12:00:00] INFO: Starting dotfiles setup (full mode)
[2024-01-01 12:00:01] INFO: Detected macOS 14.0 (Apple Silicon)
[2024-01-01 12:00:02] INFO: Homebrew found at /opt/homebrew/bin/brew
[2024-01-01 12:00:03] SUCCESS: Installed neovim (1.2.3)
[2024-01-01 12:00:04] WARNING: Package xyz already installed, skipping
[2024-01-01 12:00:05] ERROR: Failed to install abc, continuing...
```

### Debug Mode

Enable verbose output for troubleshooting:

```bash
# Method 1: Environment variable
VERBOSE=true ./setup.sh

# Method 2: Command line flag  
./setup.sh --verbose

# Method 3: Debug shell
set -x  # Enable command tracing
./setup.sh
set +x  # Disable command tracing
```

## 🧪 Testing & Validation

### Post-Installation Checks

```bash
# Verify core tools
command -v git nvim tmux zsh starship

# Check shell configuration
echo $SHELL                    # Should be /bin/zsh
echo $ZSH                     # Should be ~/.zsh

# Test plugin managers
zinit --help                  # Zsh plugins
lazy.nvim (in Neovim)        # Neovim plugins

# Verify symlinks
ls -la ~/.zshrc              # Should point to dotfiles
ls -la ~/.config/nvim        # Should point to dotfiles
```

### Automated Testing

```bash
# Run installation tests
~/.dotfiles/test/test integration/setup

# Quick validation
./src/setup/setup.sh --symlinks  # Should run without errors
```

## 🔧 Troubleshooting

### Common Issues

**Permission Denied:**
```bash
# Fix script permissions
chmod +x ~/.dotfiles/src/setup/*.sh

# Check sudo access (if needed)
sudo -v
```

**Package Installation Failures:**
```bash
# Update package managers
brew update                   # macOS
sudo apt update              # Ubuntu/Debian
sudo dnf update              # Fedora

# Clear caches
brew cleanup                 # macOS
sudo apt autoremove          # Ubuntu/Debian
```

**Symlink Conflicts:**
```bash
# Check existing symlinks
find ~ -type l -lname "*/.dotfiles/*"

# Remove old symlinks
rm ~/.zshrc ~/.gitconfig     # etc.

# Recreate symlinks
./src/setup/symlinks.sh
```

**Shell Not Changing:**
```bash
# Check available shells
cat /etc/shells

# Change shell to zsh
chsh -s /bin/zsh            # May require password

# Restart terminal or run
exec zsh
```

### Platform-Specific Issues

**macOS:**
```bash
# Xcode command line tools
xcode-select --install

# Homebrew permissions
sudo chown -R $(whoami) /opt/homebrew/*
```

**Linux:**
```bash
# Missing build tools
sudo apt install build-essential  # Ubuntu/Debian
sudo dnf groupinstall "Development Tools"  # Fedora

# Package manager updates
sudo apt update && sudo apt upgrade
```

## 🎯 Next Steps

After successful installation:

1. **Restart Terminal**: New shell configuration requires restart
2. **Configure Neovim**: Run `nvim` to trigger plugin installation
3. **Setup tmux**: Run `tmux` and press `Prefix + I` for plugins
4. **Test AI Features**: Configure API keys for AI assistants
5. **Customize**: Modify configurations as needed

### Post-Setup Commands

```bash
# Reload configurations
source ~/.zshrc               # Shell configuration
tmux source ~/.tmux.conf     # tmux configuration

# Update everything
~/.dotfiles/src/scripts/update-dotfiles

# Run health checks
nvim +checkhealth +qall     # Neovim health
```

## 🚀 Future Enhancements

### Planned Features
- **Container Support**: Docker-based installation
- **Cloud Integration**: Automatic cloud tool setup  
- **Profile Management**: Different configurations per environment
- **GUI Installer**: Web-based installation interface
- **Rollback Improvements**: Automatic rollback on failures

### Contributing

To improve the setup system:

1. **Test on Multiple Platforms**: Verify cross-platform compatibility
2. **Add Package Support**: Extend package manager coverage
3. **Improve Error Handling**: Better recovery mechanisms
4. **Documentation**: Keep READMEs updated with changes

---

**Supported Platforms**: macOS (Intel/ARM) • Ubuntu/Debian • Fedora/RHEL • Arch Linux
**Installation Time**: 5-30 minutes depending on mode
**Safety Features**: Automatic backups • Error recovery • Comprehensive logging

*Zero-config development environment setup with enterprise-grade reliability.*