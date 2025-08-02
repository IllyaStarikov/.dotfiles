# Setup Guide

## Quick Install

```bash
# One-liner
git clone https://github.com/IllyaStarikov/.dotfiles.git ~/.dotfiles && cd ~/.dotfiles && ./src/setup/mac.sh
```

## Prerequisites

- macOS (Intel or Apple Silicon)
- Admin privileges
- Internet connection

## Manual Installation

```bash
# Clone repository
git clone https://github.com/IllyaStarikov/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Run setup script
./src/setup/mac.sh

# Create symlinks
./src/setup/aliases.sh

# Restart shell
exec zsh
```

## Post-Installation

```bash
# Neovim plugins (auto-installs on first launch)
nvim
# Verify with :checkhealth

# tmux plugins
tmux
# Press Ctrl-a + I

# Theme setup
theme  # Auto-detect light/dark

# Git config (optional)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## What's Included

### Core Tools
- Homebrew (package manager)
- Neovim (editor) + LSP servers for 8+ languages
- tmux (terminal multiplexer)
- Alacritty (GPU-accelerated terminal)
- Zsh + Zinit (modern plugin manager)
- Starship (blazing-fast prompt)

### Modern CLI Tools
- `fzf` - fuzzy finder
- `ripgrep` - fast search
- `bat` - better cat
- `eza` - better ls
- `zoxide` - smarter cd
- `fd` - better find
- `delta` - better diff

### Languages
- Python (via pyenv)
- Node.js (via nvm)
- Rust
- Go
- LLVM/clangd

### Fonts
- JetBrainsMono Nerd Font
- FiraCode Nerd Font
- Symbols Only Nerd Font

## Maintenance

```bash
# Update everything
update

# Clean cache
cleanup

# Update dotfiles
cd ~/.dotfiles && git pull && ./src/setup/aliases.sh
```

## Customization

### Private Dotfiles
Create `~/.dotfiles.private/` for configs that won't be committed.

### Work Overrides
See work configuration in CLAUDE.md for setting up work-specific configs.

## Troubleshooting

**Script stops at Oh My Zsh**: Normal, just run again  
**Permission errors**: Need admin privileges  
**Theme issues**: Run `theme default`  

### LSP Not Working
```vim
:Mason
" Install servers manually if needed
```

### Python Completions
```bash
pyenv versions
python3 -m pip install --upgrade pyright
```

### C++ Completions
```bash
which clangd
# Should show: /opt/homebrew/opt/llvm/bin/clangd
```

### Tmux Issues
```bash
tmux kill-server
tmux
```

## Key Bindings

### Neovim
- Leader: `Space`
- Find files: `<Space>ff`
- Live grep: `<Space>fg`
- LSP hover: `K`
- Go to definition: `gd`

### tmux
- Prefix: `Ctrl-a`
- New window: `Ctrl-a c`
- Split vertical: `Ctrl-a |`
- Split horizontal: `Ctrl-a -`
- Navigate: `Ctrl-a h/j/k/l`