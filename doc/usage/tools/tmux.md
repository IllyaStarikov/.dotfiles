# tmux Reference

> **Terminal multiplexer for session management**

## Quick Start

```bash
# Start new session
tmux
tmux new -s project

# Attach to session
tmux attach
tmux a -t project

# List sessions
tmux ls

# Kill session
tmux kill-session -t project
```

## Core Concepts

### Hierarchy

```
Server
└── Session (workspace)
    └── Window (tab)
        └── Pane (split)
```

### Prefix Key

**All commands start with `C-a` (Ctrl+a)**

Changed from default `C-b` for ergonomics.

## Session Management

| Command                     | Action              |
| --------------------------- | ------------------- |
| `tmux new -s name`          | New named session   |
| `tmux a -t name`            | Attach to session   |
| `tmux ls`                   | List sessions       |
| `tmux kill-session -t name` | Kill session        |
| `C-a d`                     | Detach from session |
| `C-a s`                     | Session switcher    |
| `C-a $`                     | Rename session      |

## Window Management

| Key       | Action           |
| --------- | ---------------- |
| `C-a c`   | Create window    |
| `C-a ,`   | Rename window    |
| `C-a n`   | Next window      |
| `C-a p`   | Previous window  |
| `C-a l`   | Last window      |
| `C-a 0-9` | Go to window 0-9 |
| `C-a w`   | Window list      |
| `C-a &`   | Kill window      |

## Pane Management

### Creating Panes

| Key     | Action                     |
| ------- | -------------------------- | -------------- |
| `C-a    | `                          | Split vertical |
| `C-a -` | Split horizontal           |
| `C-a %` | Split vertical (default)   |
| `C-a "` | Split horizontal (default) |

### Navigation

| Key           | Action                      |
| ------------- | --------------------------- |
| `C-a h/j/k/l` | Move to pane                |
| `C-h/j/k/l`   | Smart navigation (with vim) |
| `C-a o`       | Cycle panes                 |
| `C-a ;`       | Last pane                   |
| `C-a q`       | Show pane numbers           |

### Resizing

| Key             | Action      |
| --------------- | ----------- |
| `C-a H/J/K/L`   | Resize by 1 |
| `C-a M-h/j/k/l` | Resize by 5 |

### Layout

| Key         | Action          |
| ----------- | --------------- |
| `C-a Space` | Cycle layouts   |
| `C-a M-1`   | Even horizontal |
| `C-a M-2`   | Even vertical   |
| `C-a M-3`   | Main horizontal |
| `C-a M-4`   | Main vertical   |
| `C-a M-5`   | Tiled           |

## Copy Mode

### Entering

| Key        | Action              |
| ---------- | ------------------- |
| `C-a [`    | Enter copy mode     |
| `C-a PgUp` | Enter and scroll up |

### Navigation (vi-style)

| Key       | Action               |
| --------- | -------------------- |
| `h/j/k/l` | Move cursor          |
| `w/b`     | Word forward/back    |
| `0/$`     | Line start/end       |
| `g/G`     | Top/bottom           |
| `C-u/C-d` | Page up/down         |
| `/`       | Search forward       |
| `?`       | Search backward      |
| `n/N`     | Next/Previous result |

### Selection

| Key      | Action          |
| -------- | --------------- |
| `v`      | Start selection |
| `V`      | Line selection  |
| `C-v`    | Block selection |
| `y`      | Copy selection  |
| `Enter`  | Copy and exit   |
| `Escape` | Clear selection |
| `q`      | Exit copy mode  |

## Configuration

### Location

```bash
~/.tmux.conf              # Main config
~/.config/tmux/           # Additional configs
  ├── theme.conf         # Dynamic theme
  └── plugins/           # TPM plugins
```

### Key Settings

```bash
# Prefix key
set -g prefix C-a

# Vi mode
setw -g mode-keys vi

# Mouse support
set -g mouse on

# Start windows at 1
set -g base-index 1

# Faster escape
set -sg escape-time 0
```

## Plugins (TPM)

### Installation

```bash
# Clone TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# In tmux, install plugins
C-a I
```

### Key Plugins

| Plugin             | Purpose         | Keys             |
| ------------------ | --------------- | ---------------- |
| tmux-sensible      | Better defaults | Auto             |
| tmux-resurrect     | Save/restore    | `C-a C-s/C-r`    |
| tmux-continuum     | Auto-save       | Auto             |
| tmux-yank          | Better copy     | `y` in copy mode |
| vim-tmux-navigator | Vim integration | `C-h/j/k/l`      |

## Workflows

### Development Setup

```bash
# Create project session
tmux new -s myproject

# Split for editor and terminal
C-a |        # Vertical split
C-l          # Move right
C-a -        # Horizontal split

# Name windows
C-a c        # New window
C-a ,        # Rename to "server"
C-a c        # New window
C-a ,        # Rename to "logs"
```

### Session Persistence

```bash
# Save session manually
C-a C-s      # tmux-resurrect save

# Restore after reboot
tmux
C-a C-r      # tmux-resurrect restore
```

### Remote Work

```bash
# SSH and create session
ssh server
tmux new -s work

# Detach
C-a d

# Later, reattach
ssh server
tmux attach -t work
```

## Advanced Features

### Command Mode

```bash
C-a :        # Enter command mode

# Common commands
:new-window -n logs
:split-window -h
:resize-pane -R 10
:kill-pane
:source-file ~/.tmux.conf
```

### Scripting

```bash
# Send commands
tmux send-keys -t session:window.pane "npm start" Enter

# Create complex layout
tmux new-session -d -s dev
tmux send-keys "vim" Enter
tmux split-window -h
tmux send-keys "npm run dev" Enter
tmux attach -t dev
```

### Hooks

```bash
# In .tmux.conf
set-hook -g after-new-session 'run-shell "echo New session created"'
set-hook -g pane-focus-in 'run-shell "echo Pane focused"'
```

## Integration

### With Shell

```bash
# Aliases in .zshrc
alias ta='tmux attach'
alias tls='tmux ls'
alias tks='tmux kill-server'
alias tkss='tmux kill-session -t'
```

### With Vim

```vim
" Seamless navigation
" C-h/j/k/l works in both
let g:tmux_navigator_no_mappings = 1
nnoremap <C-h> :TmuxNavigateLeft<cr>
nnoremap <C-j> :TmuxNavigateDown<cr>
nnoremap <C-k> :TmuxNavigateUp<cr>
nnoremap <C-l> :TmuxNavigateRight<cr>
```

### With Git

```bash
# In tmux window
C-a c              # New window
C-a , lazygit      # Rename
lazygit            # Run lazygit
```

## Tips and Tricks

### Quick Commands

1. **Zoom pane**: `C-a z` for focus
2. **Sync panes**: `C-a :setw synchronize-panes`
3. **Monitor activity**: `C-a :setw monitor-activity on`
4. **Break pane**: `C-a !` to new window

### Productivity

1. **Named sessions**: Always use descriptive names
2. **Window names**: Name by purpose (editor, server, logs)
3. **Save layouts**: Use resurrect for complex setups
4. **tmuxinator**: Define project layouts

### Display

1. **Clock**: `C-a t`
2. **Pane info**: `C-a i`
3. **Choose tree**: `C-a w` for visual browser

## Troubleshooting

### Common Issues

| Issue                | Solution                             |
| -------------------- | ------------------------------------ |
| Colors wrong         | `export TERM=screen-256color`        |
| Can't create session | `tmux kill-server`                   |
| Slow in vim          | `set -sg escape-time 0`              |
| Copy not working     | Install `reattach-to-user-namespace` |

### Debug Commands

```bash
# Check server
tmux info

# List all settings
tmux show -g

# Check key bindings
tmux list-keys

# Reload config
tmux source ~/.tmux.conf
```

## Status Line

### Default Info

- Left: Session name
- Center: Window list
- Right: Date and time

### Customization

```bash
# Simple
set -g status-left '#S '
set -g status-right '%H:%M '

# With plugins
set -g @plugin 'tmux-plugins/tmux-cpu'
set -g status-right 'CPU: #{cpu_percentage} | %H:%M '
```

## Quick Reference Card

```bash
# Essential
C-a c      New window     C-a |     V-split
C-a n/p    Next/Prev      C-a -     H-split
C-a d      Detach         C-a z     Zoom
C-a [      Copy mode      C-a x     Kill pane

# Navigation
C-h/j/k/l  Move panes     C-a 0-9   Go to window
C-a o      Cycle panes    C-a w     Window list
C-a ;      Last pane      C-a s     Session list

# Advanced
C-a C-s    Save session   C-a :     Command
C-a C-r    Restore        C-a ?     List keys
```

---

<p align="center">
  <a href="../README.md">← Back to Tools</a>
</p>
