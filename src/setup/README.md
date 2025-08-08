# Setup Scripts

Clean, unified setup structure for dotfiles installation.

## Quick Start

```bash
# Full installation (recommended for new systems)
cd ~/.dotfiles/src/setup
./setup.sh full

# Or just create symlinks
./symlinks.sh
```

## Scripts

### `setup.sh` - Main Installation Script

Single entry point for complete development environment setup.

**Usage:**
```bash
./setup.sh [mode]
```

**Modes:**
- `full` (default) - Complete installation with all packages, tools, and configurations
- `core` - Essential packages and symlinks only  
- `symlinks` - Create dotfile symlinks only

**Features:**
- Automatic OS detection (macOS/Linux)
- Architecture detection (Intel/Apple Silicon)
- Package manager detection on Linux
- Comprehensive logging to `~/.dotfiles-setup-*.log`
- Safe, idempotent operations

### `symlinks.sh` - Symlink Creator

Creates all necessary symlinks from dotfiles to home directory.

**Usage:**
```bash
./symlinks.sh
```

**Features:**
- Automatic backup of existing files
- Safe symlink creation
- Skip already correct symlinks
- Summary report

### `install-git-hooks` - Git Hook Installer

Installs repository git hooks.

### `setup-git-signing` - GPG Signing Setup

Configures GPG signing for git commits.

## Installation Details

### Full Installation Includes:

**Core Tools:**
- Homebrew (macOS) or native package manager (Linux)
- Git, Neovim, tmux, Alacritty
- Starship prompt, ripgrep, fd, bat, eza
- Zsh with Zinit plugin manager

**Development:**
- Python (via pyenv on macOS)
- Node.js (via nvm)
- Rust (via rustup)
- Go, CMake, LLVM

**Language Servers:**
- lua-language-server
- typescript-language-server
- rust-analyzer
- gopls
- pyright

**macOS Extras:**
- JetBrains Mono Nerd Font
- WezTerm terminal
- Raycast launcher
- Optimized keyboard settings

### Core Installation Includes:

- Essential packages only
- Zsh and Zinit setup
- All dotfile symlinks
- Basic development tools

### Symlinks Only:

- Creates all configuration symlinks
- No package installation
- Safe for existing setups

## System Requirements

- **macOS:** 10.15+ (Catalina or later)
- **Linux:** Ubuntu/Debian, Fedora/RHEL, or Arch
- **Privileges:** Admin access for some operations
- **Network:** Required for package downloads

## Safety Features

- **Idempotent:** Safe to run multiple times
- **Automatic backups:** Existing files backed up to `~/.dotfiles.backups/`
- **Error handling:** Continues on non-critical failures
- **Logging:** Detailed logs for troubleshooting

## Troubleshooting

**After installation:**
```bash
# Reload shell configuration
source ~/.zshrc

# Or restart terminal
exec zsh
```

**Check installation log:**
```bash
# View the latest log file
ls -la ~/.dotfiles-setup-*.log
```

**Manual package installation:**
```bash
# If a package fails, install manually
brew install [package]  # macOS
sudo apt install [package]  # Ubuntu/Debian
```

## Customization

Edit `setup.sh` to modify package lists in the arrays:
- `core_packages` - Essential tools
- `dev_packages` - Development tools
- `lsp_packages` - Language servers

## Next Steps

After installation:
1. Restart your terminal
2. Run `nvim` to finish plugin installation
3. Run `tmux` and press `Prefix + I` to install plugins
4. Check the log file for any warnings