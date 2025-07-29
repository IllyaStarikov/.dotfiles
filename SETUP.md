# Production-Ready Dotfiles Setup Guide

## Prerequisites

- macOS (Intel or Apple Silicon)
- Internet connection
- Admin privileges

## Quick Install

```bash
# Clone the repository
git clone https://github.com/IllyaStarikov/.dotfiles.git ~/.dotfiles

# Run the setup script
cd ~/.dotfiles
./src/setup/mac.sh

# Create all symlinks
./src/setup/aliases.sh

# Restart your terminal
```

## What Gets Installed

### Core Tools
- **Homebrew** - Package manager for macOS
- **Git** - Version control
- **Neovim** - Modern text editor
- **tmux** - Terminal multiplexer
- **Alacritty** - GPU-accelerated terminal (optional)

### Programming Languages & Tools
- **Python** (via pyenv) - Latest stable version
- **Node.js** - JavaScript runtime
- **Rust** - For high-performance tools
- **Go** - Go programming language
- **LLVM** - C/C++ compiler infrastructure

### Language Servers (Auto-installed)
- **pyright** - Python
- **clangd** - C/C++ (via LLVM)
- **lua_ls** - Lua
- **tsserver** - TypeScript/JavaScript
- **rust_analyzer** - Rust
- **gopls** - Go
- **marksman** - Markdown
- **texlab** - LaTeX

### Shell Environment
- **Zsh** - Default shell
- **Oh My Zsh** - Zsh framework
- **Spaceship** - Zsh theme
- **fzf** - Fuzzy finder
- **ripgrep** - Fast search
- **bat** - Better cat
- **eza** - Better ls
- **zoxide** - Smarter cd

### Fonts
- Fira Code Nerd Font
- MesloLG Nerd Font
- Symbols Only Nerd Font

## Post-Installation Steps

### 1. Restart Terminal
Close and reopen your terminal or run:
```bash
source ~/.zshrc
```

### 2. Install Neovim Plugins
Open Neovim and wait for plugins to install:
```bash
nvim
# Plugins will auto-install on first launch
# Run :checkhealth to verify setup
```

### 3. Install tmux Plugins
Start tmux and install plugins:
```bash
tmux
# Press Ctrl-a + I to install plugins
```

### 4. Configure Git (Optional)
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 5. Set Theme
The theme automatically follows macOS appearance. To manually switch:
```bash
theme
```

## Verifying Installation

### Check LSP Status
In Neovim, open a Python/C++/JavaScript file and run:
```vim
:LspInfo
```

### Test Completions
1. Open a Python file: `nvim test.py`
2. Type: `import os` then `os.`
3. Completions should appear instantly

### Check Health
```vim
:checkhealth
```

## Troubleshooting

### LSP Not Working
```bash
# In Neovim
:Mason
# Install/update servers manually
```

### C++ Completions Not Working
Ensure LLVM clangd is in PATH:
```bash
which clangd
# Should show: /opt/homebrew/opt/llvm/bin/clangd
```

### Python LSP Issues
```bash
# Verify Python installation
pyenv versions
python3 -m pip install --upgrade pyright
```

### tmux Issues
```bash
# Reload config
tmux source-file ~/.tmux.conf

# Kill all sessions and restart
tmux kill-server
```

## Key Bindings Reference

### Neovim
- **Leader**: `Space`
- **Find files**: `<leader>ff`
- **Live grep**: `<leader>fg`
- **LSP hover**: `K`
- **Go to definition**: `gd`
- **AI chat**: `<leader>cc`

### tmux
- **Prefix**: `Ctrl-a`
- **New window**: `Ctrl-a c`
- **Split vertical**: `Ctrl-a |`
- **Split horizontal**: `Ctrl-a -`
- **Navigate panes**: `Ctrl-a h/j/k/l`

## Maintenance

### Update Everything
```bash
update
```

This updates:
- Homebrew packages
- Neovim plugins
- tmux plugins
- Oh My Zsh
- pip packages

### Clean Caches
```bash
cleanup
```

## Customization

### Private Configuration
Create `~/.dotfiles.private/` for personal configs that won't be committed.

### Work-specific Settings
Set environment variable:
```bash
export VIMRC_TYPE=work
```

Then create `~/.vimrc.work` for work-specific overrides.

## Performance Tips

1. **Lazy Loading**: Plugins load on-demand for fast startup
2. **Compiled Plugins**: Treesitter and others compile for speed
3. **Rust Tools**: blink.cmp uses Rust for sub-millisecond completions
4. **Cache Usage**: Many tools cache for faster subsequent runs

## Security Notes

- No API keys are stored in the repository
- Private files are gitignored
- Work configs are kept separate
- All external scripts are verified

## Support

- Issues: https://github.com/IllyaStarikov/.dotfiles/issues
- Documentation: See CLAUDE.md for detailed configuration info