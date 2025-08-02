# Tool References

> **Detailed documentation for individual development tools**

## Overview

This section provides comprehensive reference documentation for each major tool in our development environment. Each guide includes configuration, commands, shortcuts, and integration details.

## Available Tools

### [Neovim](neovim.md)
Modern text editor:
- Modal editing system
- Plugin ecosystem
- LSP integration
- AI assistance

### [tmux](tmux.md)
Terminal multiplexer:
- Session management
- Window and pane control
- Copy mode
- Plugin system

### [Git](git.md)
Version control:
- Extensive aliases
- Workflow commands
- GitHub integration
- Advanced features

### [Alacritty](alacritty.md)
GPU-accelerated terminal:
- Performance settings
- Theme integration
- Keyboard shortcuts
- Mouse configuration

## Quick Tool Comparison

### Text Editing

| Feature | Neovim | VS Code | Vim |
|---------|---------|---------|-----|
| Startup speed | ⚡ Fast | 🐌 Slow | ⚡ Fast |
| Plugin system | lazy.nvim | Marketplace | Vimscript |
| LSP support | Native | Native | Plugin |
| AI integration | CodeCompanion | Copilot | Limited |

### Terminal Tools

| Feature | Alacritty | iTerm2 | Terminal.app |
|---------|-----------|---------|--------------|
| GPU accelerated | ✓ | ✗ | ✗ |
| Config format | TOML | GUI | GUI |
| Cross-platform | ✓ | ✗ | ✗ |
| Resource usage | Low | High | Medium |

### Multiplexing

| Feature | tmux | Screen | Native tabs |
|---------|------|--------|-------------|
| Persistent sessions | ✓ | ✓ | ✗ |
| Split panes | ✓ | Limited | ✗ |
| Scriptable | ✓ | ✓ | ✗ |
| Remote work | ✓ | ✓ | ✗ |

## Tool Integration

### Editor + Terminal

```bash
# Seamless navigation
C-h/j/k/l    # Works in both Neovim and tmux

# Quick edit
v file.txt   # Opens in Neovim
```

### Git + Editor

```vim
:Git         # Fugitive in Neovim
<leader>gg   # LazyGit integration
gs           # Git status in shell
```

### Theme Synchronization

All tools respect the system theme:
- Alacritty loads dynamic theme
- Neovim detects via environment
- tmux updates on theme switch

## Learning Resources

### Getting Started

1. **Neovim**: Start with `:Tutor`
2. **tmux**: Try `man tmux`
3. **Git**: Use `git help tutorial`
4. **Alacritty**: Check `alacritty --help`

### Advanced Usage

- **Neovim**: `:help usr_toc`
- **tmux**: Prefix + `?` for keybindings
- **Git**: `git help workflows`
- **Alacritty**: Configuration examples

## Tool Selection Philosophy

Our tool choices prioritize:

1. **Performance** - Fast startup and operation
2. **Extensibility** - Rich plugin ecosystems
3. **Integration** - Tools work together
4. **Efficiency** - Keyboard-driven workflows

## Customization

Each tool can be customized:

| Tool | Config Location | Format |
|------|-----------------|---------|
| Neovim | `~/.config/nvim/` | Lua |
| tmux | `~/.tmux.conf` | Shell |
| Git | `~/.gitconfig` | INI |
| Alacritty | `~/.config/alacritty/` | TOML |

## Quick Commands

```bash
# Edit configurations
vimconfig     # Neovim config
tmuxconfig    # tmux config
gitconfig     # Git config

# Reload configurations
:source %     # In Neovim
C-a r         # In tmux
source ~/.zshrc  # Shell
```

---

<p align="center">
  <a href="../README.md">← Back to Usage</a>
</p>