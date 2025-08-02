# tmux Keybindings Reference

> **Complete keyboard shortcuts for terminal multiplexing**

## Prefix Key

**All tmux commands start with the prefix key: `C-a` (Ctrl+a)**

This is customized from the default `C-b` for easier reach.

## Session Management

| Key | Action | Description |
|-----|--------|-------------|
| `C-a s` | List sessions | Interactive session switcher |
| `C-a $` | Rename session | Change current session name |
| `C-a d` | Detach session | Leave tmux, keep running |
| `C-a D` | Detach other clients | Disconnect other users |
| `C-a (` | Previous session | Switch to previous |
| `C-a )` | Next session | Switch to next |

## Window Management

| Key | Action | Description |
|-----|--------|-------------|
| `C-a c` | Create window | New window |
| `C-a &` | Kill window | Close window (confirm) |
| `C-a ,` | Rename window | Change window name |
| `C-a n` | Next window | Go to next window |
| `C-a p` | Previous window | Go to previous window |
| `C-a l` | Last window | Toggle last active |
| `C-a 0-9` | Select window | Jump to window number |
| `C-a w` | List windows | Interactive window list |
| `C-a f` | Find window | Search windows |

## Pane Management

### Creating Panes

| Key | Action | Description |
|-----|--------|-------------|
| `C-a \|` | Split vertical | Create vertical split |
| `C-a -` | Split horizontal | Create horizontal split |
| `C-a %` | Split vertical (alt) | Default vertical split |
| `C-a "` | Split horizontal (alt) | Default horizontal split |

### Navigating Panes

| Key | Action | Description |
|-----|--------|-------------|
| `C-a h` | Move left | Navigate to left pane |
| `C-a j` | Move down | Navigate to down pane |
| `C-a k` | Move up | Navigate to up pane |
| `C-a l` | Move right | Navigate to right pane |
| `C-a ;` | Last pane | Toggle last active pane |
| `C-a o` | Next pane | Cycle through panes |
| `C-a q` | Show pane numbers | Display pane indices |

### Vim-tmux Navigation

**Smart pane switching with vim-tmux-navigator:**

| Key | Action | Works In |
|-----|--------|----------|
| `C-h` | Navigate left | tmux & Neovim |
| `C-j` | Navigate down | tmux & Neovim |
| `C-k` | Navigate up | tmux & Neovim |
| `C-l` | Navigate right | tmux & Neovim |
| `C-\` | Previous split | tmux & Neovim |

### Resizing Panes

| Key | Action | Description |
|-----|--------|-------------|
| `C-a H` | Resize left | Decrease width |
| `C-a J` | Resize down | Increase height |
| `C-a K` | Resize up | Decrease height |
| `C-a L` | Resize right | Increase width |
| `C-a M-h` | Resize left 5 | Large decrease width |
| `C-a M-j` | Resize down 5 | Large increase height |
| `C-a M-k` | Resize up 5 | Large decrease height |
| `C-a M-l` | Resize right 5 | Large increase width |

### Pane Operations

| Key | Action | Description |
|-----|--------|-------------|
| `C-a x` | Kill pane | Close current pane |
| `C-a !` | Break pane | Move pane to new window |
| `C-a z` | Zoom pane | Toggle fullscreen |
| `C-a Space` | Cycle layouts | Change pane arrangement |
| `C-a {` | Swap pane left | Move pane left |
| `C-a }` | Swap pane right | Move pane right |

## Copy Mode

### Entering Copy Mode

| Key | Action | Description |
|-----|--------|-------------|
| `C-a [` | Enter copy mode | Start selection |
| `C-a PgUp` | Enter + scroll up | Quick scroll |

### Copy Mode Navigation (vi-style)

| Key | Action | Description |
|-----|--------|-------------|
| `h/j/k/l` | Move cursor | Vi movement |
| `w/b` | Word forward/back | Word movement |
| `f/F` | Find char | Jump to character |
| `0/$` | Line start/end | Line navigation |
| `g/G` | Top/bottom | Document navigation |
| `C-u/C-d` | Page up/down | Page scrolling |
| `/` | Search forward | Find text |
| `?` | Search backward | Reverse find |
| `n/N` | Next/prev match | Search navigation |

### Selection and Copy

| Key | Action | Description |
|-----|--------|-------------|
| `v` | Start selection | Visual mode |
| `V` | Line selection | Visual line mode |
| `C-v` | Block selection | Visual block mode |
| `y` | Copy selection | Yank to clipboard |
| `Enter` | Copy and exit | Quick copy |
| `Escape` | Clear selection | Cancel |
| `q` | Exit copy mode | Return to normal |

## Other Commands

### Utility

| Key | Action | Description |
|-----|--------|-------------|
| `C-a ?` | List keys | Show all keybindings |
| `C-a :` | Command prompt | Enter tmux command |
| `C-a t` | Show time | Display clock |
| `C-a i` | Display info | Show pane info |
| `C-a ~` | Show messages | View tmux messages |

### Configuration

| Key | Action | Description |
|-----|--------|-------------|
| `C-a r` | Reload config | Source ~/.tmux.conf |
| `C-a R` | Refresh client | Redraw terminal |

## Mouse Support

Mouse is enabled with these features:

| Action | Description |
|--------|-------------|
| Click pane | Select pane |
| Click window | Select window in status bar |
| Drag pane border | Resize panes |
| Scroll | Scroll in copy mode |
| Select text | Automatic copy mode |

## Plugin Commands

### tmux-resurrect

| Key | Action | Description |
|-----|--------|-------------|
| `C-a C-s` | Save session | Save layout/programs |
| `C-a C-r` | Restore session | Restore saved state |

### tmux-yank

| Key | Action | Description |
|-----|--------|-------------|
| `y` | Copy to clipboard | In copy mode |
| `Y` | Copy line | Put line in clipboard |

### tmux-open

| Key | Action | Description |
|-----|--------|-------------|
| `o` | Open selection | Open URL/file |
| `C-o` | Open in editor | Edit file |

## Custom Workflows

### Quick Split and Navigate

```bash
# Create vertical split and move
C-a |
C-l

# Create horizontal split and move  
C-a -
C-j
```

### Window Management

```bash
# Create named window
C-a c
C-a , mywindow <Enter>

# Quick window switch
C-a 1  # Jump to window 1
C-a p  # Previous window
C-a n  # Next window
```

### Copy and Paste

```bash
# Copy workflow
C-a [          # Enter copy mode
/search_term   # Find text
v              # Start selection
w w            # Extend selection
y              # Copy to clipboard

# Paste
Cmd+V          # System paste
```

### Session Management

```bash
# Save work session
C-a C-s        # tmux-resurrect save

# Next day
tmux
C-a C-r        # tmux-resurrect restore
```

## Tips and Tricks

### Quick Commands

1. **Zoom for focus**: `C-a z` to maximize current pane
2. **Quick split**: `C-a |` for vertical, `C-a -` for horizontal
3. **Smart navigation**: Use `C-h/j/k/l` to move between tmux and vim seamlessly
4. **Copy without mode**: Just select with mouse to copy

### Productivity Boosters

1. **Named sessions**: `tmux new -s project-name`
2. **Attach to running**: `tmux a` or `tmux attach`
3. **List everything**: `tmux ls` for sessions
4. **Kill stuck session**: `tmux kill-session -t name`

### Integration

1. **With Alacritty**: tmux starts automatically on new window
2. **With shell**: `tks` alias kills all sessions
3. **With clipboard**: Automatic system clipboard integration
4. **With vim**: Seamless navigation via vim-tmux-navigator

---

<p align="center">
  <a href="README.md">← Back to Keybindings</a>
</p>