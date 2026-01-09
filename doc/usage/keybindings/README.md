# Keybindings Reference

> **Complete keybinding reference across all tools**

## Quick Navigation

- **[Neovim](neovim.md)** - Editor keybindings
- **[tmux](tmux.md)** - Terminal multiplexer
- **[Shell](shell.md)** - Zsh vi-mode and shortcuts

## Universal Principles

### Vi-Style Navigation

Everywhere possible, we use vi-style keys:

| Key | Movement | Used In             |
| --- | -------- | ------------------- |
| `h` | Left     | Neovim, tmux, shell |
| `j` | Down     | Neovim, tmux, shell |
| `k` | Up       | Neovim, tmux, shell |
| `l` | Right    | Neovim, tmux, shell |

### Leader Keys

| Tool   | Leader   | Usage               |
| ------ | -------- | ------------------- |
| Neovim | `Space`  | All custom commands |
| tmux   | `Ctrl-a` | All tmux commands   |

### Consistency Patterns

1. **Window Management**
   - `<leader>w` prefix in Neovim
   - `Ctrl-a` prefix in tmux
   - Seamless navigation with vim-tmux-navigator

2. **Search Operations**
   - `/` for forward search everywhere
   - `?` for backward search
   - `n`/`N` for next/previous

3. **Copy/Paste**
   - Visual selection with `v`
   - Yank with `y`
   - System clipboard integration

## Quick Reference Card

### Essential Navigation

```
TOOL      COMMAND            ACTION
────────────────────────────────────────
Neovim    <leader>ff         Find files
          <leader>fg         Grep text
          <leader>fb         Browse buffers
          gd                 Go to definition

tmux      Ctrl-a c           New window
          Ctrl-a n/p         Next/prev window
          Ctrl-a |           Vertical split
          Ctrl-a -           Horizontal split

Shell     Ctrl-r             Search history
          Ctrl-t             Insert file path
          Alt-c              Jump directory
          ESC                Vi mode
```

### Productivity Shortcuts

```
CONTEXT   KEYS               ACTION
────────────────────────────────────────
AI        <leader>ac         AI chat
          <leader>aa         AI actions palette
          <leader>ae         Explain code (visual)

Code      <leader>ca         Code action
          <leader>cR         Rename symbol
          <leader>cr         Run file

Windows   Ctrl-h/j/k/l       Navigate panes
          <leader>bd         Delete buffer
          <leader>w-         Split horizontal
          <leader>w|         Split vertical

Open      <leader>oe         File explorer
          <leader>ot         Terminal
          <leader>gg         LazyGit
```

## Learning Path

1. **Week 1**: Master basic navigation (`hjkl` everywhere)
2. **Week 2**: Learn leader key commands
3. **Week 3**: Add visual mode operations
4. **Week 4**: Advanced combinations and macros

---

<p align="center">
  <a href="../README.md">← Back to Usage</a>
</p>
