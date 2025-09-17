# Migration Guide

> **Transitioning from other development environments**

## Coming from Default macOS Terminal

### What's Different

**Terminal** `Terminal.app` → [Alacritty](https://alacritty.org/)
GPU-accelerated, TOML configuration, better performance

**Shell** `bash` → [Zsh](https://www.zsh.org/) with [Zinit](https://github.com/zdharma-continuum/zinit)
Better completion, fast plugin loading, turbo mode

**Editor** `nano/vi` → [Neovim](https://neovim.io/)
Modern Lua config, LSP support, plugins

### Key Adjustments

1. **Copy/Paste** Still `Cmd+C/V` in Alacritty
2. **New tabs** `Cmd+N` for new window (not tabs)
3. **Settings** Edit config files, not preferences GUI

## Coming from iTerm2

### Feature Mapping

| iTerm2 Feature    | Our Equivalent              |
| ----------------- | --------------------------- |
| Profiles          | Alacritty + theme switcher  |
| Split panes       | tmux (`C-a \|` and `C-a -`) |
| Hotkey window     | tmux sessions               |
| Shell integration | Starship prompt             |
| Triggers          | Shell functions/aliases     |

### Migration Steps

```bash
# Export iTerm2 colors (if custom)
# Then adapt to Alacritty TOML format

# Move shell configs
cat ~/.bash_profile >> ~/.zshrc.local
```

## Coming from VS Code

### Equivalent Features

**File explorer** `<leader>e` or `<leader>ff`
**Command palette** `<leader>fc` or `:`
**Terminal** `<leader>tt` (floating)
**Git integration** `<leader>gg` (LazyGit)
**Extensions** Lazy.nvim plugins

### Muscle Memory Transitions

| VS Code       | Neovim       |
| ------------- | ------------ |
| `Cmd+P`       | `<leader>ff` |
| `Cmd+Shift+P` | `<leader>fc` |
| `F12`         | `gd`         |
| `Shift+F12`   | `gr`         |
| `Cmd+/`       | `<leader>/`  |
| `Ctrl+\``     | `<leader>tt` |

### Installing VS Code Features

```lua
-- Add to lua/config/plugins.lua for VS Code-like features:
-- File tree: neo-tree.nvim (already included)
-- Minimap: minimap.vim
-- Breadcrumbs: barbecue.nvim
-- Inline hints: lsp-inlayhints.nvim
```

## Coming from Vim/MacVim

### What's Upgraded

**Config** `.vimrc` → `~/.config/nvim/init.lua`
**Plugins** Vundle/Pathogen → Lazy.nvim
**Completion** YouCompleteMe → Built-in LSP + Blink.cmp
**Fuzzy find** CtrlP → Telescope

### Config Migration

```bash
# Your .vimrc settings mostly work
# But consider converting to Lua:

# Vimscript
set number
set relativenumber

# Lua equivalent
vim.opt.number = true
vim.opt.relativenumber = true
```

### Plugin Equivalents

| Vim Plugin | Neovim Equivalent   |
| ---------- | ------------------- |
| NERDTree   | neo-tree.nvim       |
| CtrlP      | telescope.nvim      |
| Airline    | lualine.nvim        |
| Fugitive   | fugitive + gitsigns |
| CoC.nvim   | Native LSP + Blink  |

## Coming from Emacs

### Conceptual Mapping

**Packages** MELPA → Lazy.nvim
**Config** `.emacs.d/init.el` → `.config/nvim/init.lua`
**Org mode** → VimWiki or Neorg
**Magit** → LazyGit or Fugitive
**Which-key** → which-key.nvim

### Evil Mode Users

Most keybindings will feel familiar. Additional options:

```lua
-- Add Emacs-style keybindings where needed
vim.keymap.set('i', '<C-a>', '<Home>')
vim.keymap.set('i', '<C-e>', '<End>')
vim.keymap.set('i', '<C-k>', '<C-o>D')
```

## Common Workflows

### Project Management

**Old way** Open folder in IDE
**New way**

```bash
z project       # Jump to project
tmux new -s project  # Named session
v .             # Open Neovim
```

### File Search

**Old way** Cmd+P or Ctrl+P
**New way** `<leader>ff` or `ff` in shell

### Multi-file Editing

**Old way** Tabs
**New way** Buffers + splits

```vim
<leader>fb      # Buffer list
:vsp file       # Vertical split
<C-w>w          # Switch splits
```

### Debugging

**Old way** IDE debugger
**New way**
DAP (Debug Adapter Protocol) in Neovim
Or terminal debugging:

```bash
# Python
python -m pdb script.py

# Node.js
node --inspect-brk app.js

# In Neovim
<leader>db      # Toggle breakpoint
<leader>dc      # Continue
```

## Performance Tips

### Startup Speed

Our setup prioritizes fast startup:
Neovim: <50ms
Shell: <200ms
tmux: instant

Compare with:
VS Code: 2-5 seconds
IntelliJ: 10-30 seconds

### Resource Usage

Typical usage:
RAM: ~200MB total
CPU: <5% idle
GPU: Accelerated rendering

## Getting Help

### Built-in Documentation

`:help` in Neovim
`man command` in shell
`<leader>fh` search help

### Community Resources

[r/neovim](https://reddit.com/r/neovim)
[Neovim Discourse](https://neovim.discourse.group/)
[Our GitHub Issues](https://github.com/IllyaStarikov/.dotfiles/issues)

## Rollback Plan

If you need to switch back:

```bash
# Backup current setup
mv ~/.config ~/.config.dotfiles

# Restore previous
mv ~/.config.backup ~/.config

# Or run specific app
/usr/bin/vim  # System vim
```

---

Remember: Give it 2 weeks. The productivity gains are worth the initial learning curve.
