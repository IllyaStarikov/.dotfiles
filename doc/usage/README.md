# Usage Reference

> **Quick reference documentation for daily development**

## Purpose

This section provides:

- **Command references** - Quick lookup for aliases and shortcuts
- **Keybinding maps** - Complete keyboard shortcuts across all tools
- **Workflow guides** - Step-by-step procedures for common tasks

For configuration details and customization, see [Guides](../guides/README.md).

## Quick Start

**[📋 Quick Reference Card](reference.md)** One-page essential commands

## Quick Command Reference

```bash
# NAVIGATION           # FILE OPERATIONS      # GIT WORKFLOW
z project             ll                     gs
cd -                  la                     gaa
zi                    lt                     gcmsg "message"
..                    ff                     gp

# SEARCH               # SYSTEM               # DEVELOPMENT
rg "pattern"          htop                   v file.py
fd name               duf                    tmux a
fzf                   theme                  lazygit
```

## Essential Keybindings

```vim
# NEOVIM               # TMUX                 # SHELL
<leader>ff Find file   C-a c  New window     C-r  History search
<leader>fg Grep text   C-a |  Split vert     C-t  File picker
gd  Go to definition   C-a n  Next window    ESC  Vi mode
K   Show hover docs    C-a [  Copy mode      TAB  Completion
```

## Reference Sections

### [Commands](commands/)

Quick lookup for all command aliases:

- **[Git Commands](commands/git.md)** - Version control aliases
- **[Shell Commands](commands/shell.md)** - Zsh aliases and functions
- **[Modern CLI](commands/modern-cli.md)** - Tool replacements

### [Keybindings](keybindings/)

Complete keyboard reference:

- **[Neovim](keybindings/neovim.md)** - Editor shortcuts
- **[tmux](keybindings/tmux.md)** - Multiplexer keys
- **[Shell](keybindings/shell.md)** - Terminal shortcuts

### [Workflows](workflows/)

Step-by-step guides:

- **[Daily Development](workflows/daily.md)** - Morning to evening workflow
- **[Feature Development](workflows/features.md)** - Branch to deployment
- **[Code Review](workflows/review.md)** - PR and review process
- **[Debugging](workflows/debugging.md)** - Troubleshooting guide

### [Tool References](tools/)

Individual tool guides:

- **[Neovim](tools/neovim.md)** - Editor reference
- **[tmux](tools/tmux.md)** - Multiplexer reference
- **[Git](tools/git.md)** - Version control reference
- **[Alacritty](tools/alacritty.md)** - Terminal reference

## Common Tasks

### Find Files
```bash
ff                    # Interactive file finder
fd -e py | fzf        # Find Python files
<leader>ff            # In Neovim
```

### Search Text
```bash
rg "TODO"             # Search for TODOs
rg -t py "class"      # Search Python files
<leader>fg            # In Neovim
```

### Git Operations
```bash
gaa && gcmsg "fix: bug" && gp  # Quick commit
lazygit               # Visual Git UI
<leader>gg            # In Neovim
```

### AI Assistance
```vim
<leader>cc            # Open AI chat
<leader>ca            # Show AI actions
Select text + <leader>co  # Optimize code
```

## Navigation Tips

1. **Need a command?** Check [Commands](commands/)
2. **Forgot a shortcut?** See [Keybindings](keybindings/)
3. **Starting a task?** Follow [Workflows](workflows/)
4. **Tool-specific?** Browse [Tool References](tools/)

## Performance Tips

### Fast Navigation
Use `z` instead of `cd` - learns your habits
Use `zi` for interactive directory jumping
Use `ff` for fuzzy file finding
Use `<C-r>` for command history search

### Efficient Editing
`gaa && gcmsg "message" && gp` for quick commits
`<leader>f` to format code instantly
`<leader>ca` for AI-powered suggestions
Use snippets for boilerplate code

### Tool Selection
`rg` over `grep` - 10-100x faster
`fd` over `find` - more intuitive
`eza` over `ls` - git integration
`bat` over `cat` - syntax highlighting

## Getting Help

### In-Tool Help

- **Neovim** - `:help keyword` or `K` on function
- **tmux** - `C-a ?` for keybindings
- **Shell** - `man command` or `tldr command`
- **Git** - `git help command`

### Diagnostics

- **Neovim** - `:checkhealth`
- **Shell** - `which command`
- **System** - `brew doctor`

## Configuration Files

| Tool | Config Location | Edit Command |
|------|-----------------|--------------|
| Zsh | `~/.zshrc` | `zshconfig` |
| Neovim | `~/.config/nvim/` | `vimconfig` |
| tmux | `~/.tmux.conf` | `tmuxconfig` |
| Git | `~/.gitconfig` | `gitconfig` |
| Alacritty | `~/.config/alacritty/` | `v ~/.config/alacritty/alacritty.toml` |

## Troubleshooting

See [Setup Troubleshooting](../setup/troubleshooting.md) for solutions to common issues.

## Learning Resources

### Recommended Path
1. Start with [Daily Workflow](workflows/daily.md)
2. Learn [Essential Keybindings](keybindings/README.md)
3. Master [Git Commands](commands/git.md)
4. Explore [Tool References](tools/)

---

<p align="center">
  <a href="../README.md">← Back to Documentation</a> •
  <a href="../setup/README.md">Setup Guide →</a>
</p>