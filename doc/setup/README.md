# Setup Guide

> **New!** This setup now supports both macOS and Linux. The installer automatically detects your operating system.

## Quick Install

```bash
# One-liner installation (works on macOS and Linux)
git clone https://github.com/IllyaStarikov/.dotfiles.git ~/.dotfiles && cd ~/.dotfiles && ./src/setup/setup.sh
```

## Prerequisites

### macOS
- **Version**: Intel or Apple Silicon (10.15 Catalina or later)
- **Admin privileges**: Required for Homebrew
- **Internet**: ~2GB download for packages
- **Git**: Installed automatically if missing

### Linux
- **Distributions**: Ubuntu 20.04+, Fedora 35+, Arch, openSUSE
- **Admin privileges**: Required for system packages
- **Internet**: ~1.5GB download for packages
- **Git**: Required (install with package manager)

## Installation Process

### Option 1: Automatic Installation (Recommended)

```bash
# Clone and run setup in one command
git clone https://github.com/IllyaStarikov/.dotfiles.git ~/.dotfiles && cd ~/.dotfiles && ./src/setup/setup.sh
```

The setup script will:

**On macOS:**
1. Install Xcode Command Line Tools
2. Install Homebrew package manager
3. Install ~50 packages including modern CLI tools
4. Install Zinit plugin manager for Zsh
5. Install Nerd Fonts for icons and ligatures
6. Create symlinks for all configurations
7. Configure shell, editor, and terminal

**On Linux:**
1. Detect your distribution and package manager
2. Install development tools and dependencies
3. Install modern CLI tools (fd, ripgrep, etc.)
4. Install Zinit plugin manager for Zsh
5. Download and install Nerd Fonts
6. Create symlinks for all configurations
7. Configure shell, editor, and terminal

### Option 2: Manual Installation

```bash
# 1. Clone the repository
git clone https://github.com/IllyaStarikov/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 2. Run the setup script (auto-detects OS)
./src/setup/setup.sh
# Note: Script is fully automated but may pause for confirmations

# 3. Create configuration symlinks
./src/setup/aliases.sh

# 4. Install Neovim plugins
nvim --headless +"Lazy! sync" +qa

# 5. Restart your shell
exec zsh
```

## Post-Installation Setup

### 1. Neovim Configuration

```bash
# Launch Neovim - plugins will auto-install on first run
nvim

# After installation completes, verify everything is working
:checkhealth

# Install LSP servers for your languages
:Mason
# Press 'i' to install servers like pyright, lua-language-server, etc.
```

### 2. tmux Plugin Installation

```bash
# Start tmux
tmux

# Install TPM plugins
# Press: Ctrl-a + I (capital I)
# Wait for "Press ENTER to continue" message
```

### 3. Theme Configuration

```bash
# Auto-detect system appearance (light/dark)
theme

# Or manually set theme
theme dark   # Force dark mode
theme light  # Force light mode
```

### 4. Git Configuration

```bash
# Set your identity
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Optional: Set up GPG signing
git config --global commit.gpgsign true
git config --global user.signingkey YOUR_GPG_KEY_ID
```

### 5. Shell Configuration

```bash
# Source the new configuration
source ~/.zshrc

# Verify zinit is working
zinit update
```

## What's Included

### Core Development Environment

**Terminal & Shell**
**[Alacritty](https://alacritty.org/)** GPU-accelerated terminal emulator with TOML configuration
**[Zsh](https://www.zsh.org/)** with **[Zinit](https://github.com/zdharma-continuum/zinit)** plugin manager for productivity
**[Starship](https://starship.rs/)** Minimal, blazing-fast shell prompt with Git integration
**[tmux](https://github.com/tmux/tmux)** Terminal multiplexer with **[TPM](https://github.com/tmux-plugins/tpm)** plugin manager

**Editor & IDE Features**
**[Neovim](https://neovim.io/)** (0.11+) Hyperextensible Vim-based editor with Lua configuration
**LSP servers** Pre-configured for Python (pyright), JavaScript/TypeScript, Lua, C/C++ (clangd), Go (gopls), Rust (rust-analyzer)
**[Mason.nvim](https://github.com/williamboman/mason.nvim)** Portable package manager for LSP servers, linters, and formatters
**[Lazy.nvim](https://github.com/folke/lazy.nvim)** Modern plugin manager with lazy loading for fast startup
**[Blink.cmp](https://github.com/Saghen/blink.cmp)** Ultra-fast completion engine with fuzzy matching
**[Snacks.nvim](https://github.com/folke/snacks.nvim)** Quality of life suite (dashboard, picker, terminal, git integration)

### Modern CLI Replacements

| Traditional | Modern Tool | Command | Benefits |
|-------------|-------------|---------|----------|
| `cat` | **[bat](https://github.com/sharkdp/bat)** | `bat` | Syntax highlighting, line numbers, Git integration |
| `ls` | **[eza](https://eza.rocks/)** | `eza` | Icons, tree view, Git status, better formatting |
| `find` | **[fd](https://github.com/sharkdp/fd)** | `fd` | Intuitive syntax, 5x faster, respects .gitignore |
| `grep` | **[ripgrep](https://github.com/BurntSushi/ripgrep)** | `rg` | 10-100x faster, respects .gitignore, better UX |
| `cd` | **[zsh-z](https://github.com/agkozak/zsh-z)** | `z` | Learns your habits, fuzzy matching |
| `diff` | **[delta](https://github.com/dandavison/delta)** | `delta` | Syntax highlighting, side-by-side view |
| `top` | **[htop](https://htop.dev/)** | `htop` | Interactive process viewer |
| `df` | **[duf](https://github.com/muesli/duf)** | `duf` | Better formatting, device filtering |
| `du` | **[dust](https://github.com/bootandy/dust)** | `dust` | Tree view of disk usage |

### Development Tools

**Version Managers**
**[pyenv](https://github.com/pyenv/pyenv)** Python version management with virtual environment support
**Node.js** Installed via Homebrew with latest LTS version
**[rustup](https://rustup.rs/)** Official Rust toolchain installer and version manager

**Languages & Compilers**
**Python 3.12+** with pip, ipython, and development tools
**Node.js LTS** via fnm with npm and common global packages
**Rust** Latest stable with cargo and common tools
**Go** Latest version with module support
**LLVM** Full toolchain with clangd for C/C++ development

**Productivity Tools**
**[fzf](https://github.com/junegunn/fzf)** Command-line fuzzy finder with shell integration
**[tmuxinator](https://github.com/tmuxinator/tmuxinator)** Manage complex tmux sessions
**[jq](https://jqlang.github.io/jq/)** & **[yq](https://github.com/mikefarah/yq)** JSON/YAML processors
**[tldr](https://tldr.sh/)** Community-driven man pages
**[gh](https://cli.github.com/)** GitHub CLI for PRs, issues, and releases
**[lazygit](https://github.com/jesseduffield/lazygit)** Terminal UI for git
**[glow](https://github.com/charmbracelet/glow)** Render markdown in terminal
**[xh](https://github.com/ducaale/xh)** Friendly HTTP client (faster HTTPie alternative)
**[sd](https://github.com/chmln/sd)** Intuitive find & replace (sed alternative)
**[procs](https://github.com/dalance/procs)** Modern process viewer with tree view
**[gping](https://github.com/orf/gping)** Ping with graph visualization
**[hyperfine](https://github.com/sharkdp/hyperfine)** Command-line benchmarking tool

### AI & Development Assistance
**[Ollama](https://ollama.ai/)** Run LLMs locally for privacy-first AI assistance
**[CodeCompanion.nvim](https://github.com/olimorris/codecompanion.nvim)** AI integration supporting Claude, GPT-4, and local models

### Fonts
**[JetBrainsMono Nerd Font](https://www.jetbrains.com/lp/mono/)** Primary coding font with ligatures
**[Hasklug Nerd Font](https://github.com/ryanoasis/nerd-fonts)** Hasklig with added icons
**[Symbols Only Nerd Font](https://github.com/ryanoasis/nerd-fonts)** Fallback for icons and powerline

## Maintenance

### Regular Updates

```bash
# Update everything with one command
update

# This intelligently updates:
# - Homebrew packages and casks
# - Zinit and plugins
# - Neovim plugins via Lazy.nvim
# - tmux plugins via TPM
# - Global npm, pip, cargo, and gem packages
# - macOS software updates (if mas installed)
```

### Cleanup Operations

```bash
# Clean system caches and old files
cleanup

# Individual cleanup commands:
brew cleanup -s          # Remove old Homebrew versions
npm cache clean --force  # Clear npm cache
pip cache purge         # Clear pip cache
rm -rf ~/.cache/nvim    # Reset Neovim cache
rm -rf ~/.zcompdump*    # Rebuild zsh completions
```

### Updating Dotfiles

```bash
# Pull latest changes and re-link
cd ~/.dotfiles
git pull
./src/setup/aliases.sh

# If there are conflicts with local changes
git stash
git pull
git stash pop
# Resolve any conflicts, then re-link
```

### Health Checks

```bash
# Comprehensive system check
nvim +checkhealth

# Verify core tools
for cmd in zsh nvim tmux alacritty git rg fd bat eza; do
  command -v $cmd >/dev/null && echo "✓ $cmd" || echo "✗ $cmd"
done

# Check symlinks
find ~ -maxdepth 1 -type l ! -exec test -e {} \; -print

# Check font installation
fc-list | grep -i "JetBrainsMono.*Nerd"
```

## Customization

### Private Configuration

The system automatically sources private configuration files that aren't tracked in git:

```bash
# Create private config directory
mkdir -p ~/.dotfiles.private

# Private files are auto-sourced in this order:
~/.dotfiles.private/exports.zsh    # Environment variables
~/.dotfiles.private/aliases.zsh    # Personal aliases
~/.dotfiles.private/functions.zsh  # Custom functions
~/.dotfiles.private/secrets.zsh    # API keys, tokens

# Example: Add work-specific aliases
echo 'alias work="cd ~/work-projects"' >> ~/.dotfiles.private/aliases.zsh
echo 'export WORK_API_KEY="secret"' >> ~/.dotfiles.private/secrets.zsh
```

### Work-Specific Overrides

```bash
# For work machines, create work-specific configs
mkdir -p ~/.dotfiles.private/work

# Override Git config for work
cat >> ~/.dotfiles.private/work/gitconfig << 'EOF'
[user]
    email = your.name@company.com
    signingkey = WORK_GPG_KEY
EOF

# Source work configs conditionally
if [[ -f ~/.dotfiles.private/work/config.zsh ]]; then
    source ~/.dotfiles.private/work/config.zsh
fi
```

### Theme Customization

```bash
# Add custom themes
cp your-theme.toml ~/.config/alacritty/themes/

# Modify theme switcher
vim ~/.dotfiles/src/theme-switcher/switch-theme.sh
```

## Additional Resources

**[Migration Guide](migration.md)** Coming from VS Code, Vim, or other environments
**[Troubleshooting Guide](troubleshooting.md)** Solutions to common issues  
**[Quick Reference](../usage/QUICK_REFERENCE.md)** Essential commands on one page

## Troubleshooting

### Common Installation Issues

**Installation Script Hangs**
**Issue** Script appears to hang during installation
**Solution** This may happen during font installation or package downloads. Wait for completion or restart:
```bash
# If process appears stuck, restart
killall -9 Terminal
# Open new terminal and resume
cd ~/.dotfiles && ./src/setup/mac.sh
```

**Permission Denied Errors**
**Issue** "Permission denied" during installation
**Solution** Refresh sudo credentials before running:
```bash
sudo -v  # Enter password once
./src/setup/mac.sh
```

**Homebrew Not Found After Installation**
**Issue** `brew: command not found` after installation
**Solution** Add Homebrew to PATH based on your architecture:

```bash
# Apple Silicon (M1/M2/M3)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Intel Macs
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/usr/local/bin/brew shellenv)"
```

### Editor Issues

**LSP Servers Not Working**
**Issue** Language features not working in Neovim
**Solution** Install and verify LSP servers:

```bash
# Open Neovim and install servers
nvim
:Mason
# Press 'i' on servers to install:
# - pyright (Python)
# - lua-language-server (Lua)
# - typescript-language-server (JS/TS)
# - clangd (C/C++)
# - rust-analyzer (Rust)
# - gopls (Go)

# Verify LSP is attached
:LspInfo
```

**Completion Not Working**
**Issue** No autocomplete suggestions in Neovim
**Solution** Verify Blink.cmp is loaded:

```bash
# Check plugin status
nvim
:Lazy
# Find "blink.cmp" - should show "● Loaded"

# If not loaded, reinstall
:Lazy sync

# Check completion sources
:lua print(vim.inspect(require('blink.cmp').get_sources()))
```

**Neovim Plugins Failed to Install**
```bash
# Clear plugin cache and reinstall
rm -rf ~/.local/share/nvim/lazy
rm -rf ~/.local/state/nvim/lazy
nvim  # Plugins will reinstall automatically
```

### Language-Specific Issues

**Python/Pyright Issues**
**Issue** Python LSP not working or import errors
**Solution** Ensure Python environment is configured:

```bash
# Install latest Python
pyenv install --list | grep -E '^  3\.12' | tail -1
pyenv install 3.12.7  # Or latest
pyenv global 3.12.7

# Install Python tools
python -m pip install --upgrade pip
python -m pip install pyright neovim pynvim

# For project-specific virtual environments
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

**C/C++ Completions Not Working**
**Issue** clangd not found or not working
**Solution** Install LLVM and configure PATH:

```bash
# Verify clangd location
which clangd || echo "clangd not in PATH"

# Reinstall LLVM
brew reinstall llvm

# Add to PATH (Apple Silicon)
echo 'export PATH="/opt/homebrew/opt/llvm/bin:$PATH"' >> ~/.zshrc

# Add to PATH (Intel)
echo 'export PATH="/usr/local/opt/llvm/bin:$PATH"' >> ~/.zshrc

# Reload shell
source ~/.zshrc
```

**Node.js/TypeScript Issues**
**Issue** JavaScript/TypeScript features not working
**Solution** Use fnm for Node.js management:

```bash
# Install latest LTS Node
fnm install --lts
fnm use lts-latest
fnm default lts-latest

# Install global packages
npm install -g typescript typescript-language-server @types/node

# For projects
npm install
npm install -D @types/node
```

### Terminal & Shell Issues

**Alacritty Won't Start**
**Issue** Terminal crashes or shows config errors
**Solution** Debug and reset configuration:

```bash
# Check for syntax errors
alacritty --print-events 2>&1 | head -20

# Common fix: Reset theme
rm ~/.config/alacritty/theme.toml
theme  # Regenerate theme

# Full reset
mv ~/.config/alacritty ~/.config/alacritty.bak
cd ~/.dotfiles && ./src/setup/aliases.sh
```

**tmux Key Bindings Not Working**
**Issue** Prefix key (Ctrl-a) not responding
**Solution** Reload configuration and plugins:

```bash
# Inside tmux: reload config
Ctrl-a + r

# Or from command line
tmux source-file ~/.tmux.conf

# Reinstall plugins
rm -rf ~/.tmux/plugins/
tmux new-session
# Press: Ctrl-a + I (capital I)
# Wait for "Press ENTER to continue"
```

**Theme Switching Issues**
```bash
# Reset to default theme
theme default

# If theme command not found
source ~/.zshrc

# Manual theme switch
~/.dotfiles/src/theme-switcher/switch-theme.sh
```

**Icons/Fonts Not Displaying**
**Issue** Seeing boxes or missing icons in terminal
**Solution** Install and configure Nerd Fonts:

```bash
# Install required fonts
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask font-symbols-only-nerd-font

# Verify installation
fc-list | grep -i "jetbrains.*nerd"

# Check Alacritty config
grep -A2 "\[font" ~/.config/alacritty/alacritty.toml
# Should show: family = "JetBrainsMono Nerd Font"

# For other terminals, set font to "JetBrainsMono Nerd Font"
```

### Performance Issues

**Slow Shell Startup**
**Issue** Terminal takes >1 second to start
**Solution** Profile and optimize shell startup:

```bash
# Benchmark startup time
time zsh -i -c exit

# Profile what's slow
zsh -xvfd 2>&1 | ts -i "%.s" > startup.log
tail -20 startup.log

# Common optimizations:
# 1. Check zinit plugin loading
# 2. Clear completion cache
rm -rf ~/.zcompdump* ~/.zsh_compdump*
# 3. Disable automatic updates
echo 'DISABLE_AUTO_UPDATE="true"' >> ~/.zshrc
```

**Neovim Slow to Start**
```bash
# Profile Neovim startup
nvim --startuptime startup.log

# Check which plugins are slow
:Lazy profile

# Disable unused plugins in ~/.config/nvim/lua/config/plugins.lua
```

### Recovery Procedures

**Complete Reset**
```bash
# Backup current configs
mv ~/.config ~/.config.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak

# Re-run setup
cd ~/.dotfiles
./src/setup/aliases.sh
exec zsh
```

**Partial Reset (Specific Tool)**
```bash
# Reset Neovim only
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim
./src/setup/aliases.sh

# Reset shell only  
rm -rf ~/.zshrc ~/.zinit ~/.local/share/zinit
./src/setup/mac.sh  # Re-run shell setup
```

## Essential Key Bindings

### Neovim

**Leader Key** `Space`

**File Operations**
`<Space>ff` Find files
`<Space>fg` Live grep (search in files)
`<Space>fr` Recent files
`<Space>fb` Browse buffers
`<Space>e` File explorer

**Code Navigation**
`gd` Go to definition
`gr` Find references
`K` Show hover documentation
`<Space>la` Code actions
`<Space>lr` Rename symbol

**AI Assistance**
`<Space>cc` Open AI chat
`<Space>ca` AI actions menu
`<Space>co` Optimize code (visual mode)

**Git Integration**
`<Space>gg` Open LazyGit
`<Space>gd` Git diff
`]c` / `[c` Next/previous hunk

### tmux

**Prefix** `Ctrl-a` (changed from default `Ctrl-b`)

**Session Management**
`Ctrl-a s` List sessions
`Ctrl-a $` Rename session
`Ctrl-a d` Detach from session

**Window Management**
`Ctrl-a c` Create new window
`Ctrl-a n` Next window
`Ctrl-a p` Previous window
`Ctrl-a [0-9]` Switch to window number
`Ctrl-a ,` Rename window

**Pane Management**
`Ctrl-a |` Split vertically
`Ctrl-a -` Split horizontally
`Ctrl-h/j/k/l` Navigate panes (works with Neovim)
`Ctrl-a H/J/K/L` Resize panes
`Ctrl-a z` Toggle zoom
`Ctrl-a x` Close pane

**Copy Mode**
`Ctrl-a [` Enter copy mode
`v` Start selection (vi mode)
`y` Copy to clipboard
`Ctrl-a ]` Paste

### Alacritty

`Cmd+N` New window
`Cmd+K` Clear screen
`Cmd+F` Search
`Cmd+Plus/Minus` Zoom in/out
`Ctrl+Shift+Space` Toggle vi mode