# Tmux Commands

## Daily Commands

```bash
SESSION                 WINDOWS                PANES
tmux new -s name  New   C-a c      New win    C-a |     V-split
tmux a           Attach C-a n/p    Next/prev  C-a -     H-split
tmux ls          List   C-a 0-9    Jump to    C-a h/j/k/l  Navigate
C-a d            Detach C-a ,      Rename     C-a z     Zoom
C-a s            Switch C-a &      Kill       C-a x     Kill pane

COPY MODE              LAYOUTS                ADVANCED
C-a [     Enter copy   C-a M-1    Even H     C-a C-s   Save session
v         Visual       C-a M-2    Even V     C-a C-r   Restore
y         Yank         C-a M-3    Main H     C-a I     Install TPM
C-a ]     Paste        C-a M-4    Main V     C-a U     Update plugins
/         Search       C-a M-5    Tiled      C-a R     Reload config

NAVIGATION             RESIZE                 QUICK
C-a h/j/k/l  Panes    C-a H/J/K/L  Resize    C-a w     Windows list
C-a C-h/j/k/l Vim nav C-a </>      Resize H   C-a f     Find window
C-a Tab      Last pane C-a +/-     Resize V   C-a q     Pane numbers
C-a o        Next pane C-a =       Equal size C-a !     Break pane
```

## Session Management

### Tmuxinator Templates
```bash
# Available templates (all in ~/.dotfiles/src/tmuxinator/)
tmuxinator start project       # Development layout
tmuxinator start dotfiles_demo # Complete showcase
tmuxinator start ai           # AI development workspace

# Template management  
tmuxinator list               # Show all templates
tmuxinator new myproject      # Create new template
tmuxinator edit project       # Edit existing
tmuxinator delete project     # Remove template
tmuxinator doctor            # Check configuration
```

### Session Persistence

```bash
# Auto-save every 15 minutes
C-a C-s    # Manual save current session
C-a C-r    # Manual restore last session
# Sessions saved to: ~/.tmux/resurrect/
```

### Quick Session Commands
```bash
# Session operations
tmux new -s work          # New named session
tmux new -s work -d       # New detached session
tmux a -t work           # Attach to specific
tmux ls                  # List all sessions
tmux kill-session -t old # Delete session

# Inside tmux
C-a $     # Rename current session
C-a s     # Interactive session switcher
C-a (     # Previous session
C-a )     # Next session
```

## Key Bindings Reference

### Prefix: `C-a` (Ctrl+a)

### Window Management

| Binding | Action | Binding | Action |
|---------|--------|---------|--------|
| `C-a c` | Create window | `C-a &` | Kill window |
| `C-a n` | Next window | `C-a p` | Previous window |
| `C-a 0-9` | Jump to window N | `C-a l` | Last window |
| `C-a w` | List windows | `C-a ,` | Rename window |
| `C-a f` | Find window | `C-a .` | Move window |

### Pane Operations

| Binding | Action | Binding | Action |
|---------|--------|---------|--------|
| `C-a \|` | Split vertical | `C-a -` | Split horizontal |
| `C-a x` | Kill pane | `C-a q` | Show pane numbers |
| `C-a z` | Toggle zoom | `C-a !` | Break to window |
| `C-a Space` | Cycle layouts | `C-a {/}` | Swap panes |
| `C-a o` | Next pane | `C-a ;` | Last pane |

### Smart Navigation (Vim-aware)

| Binding | Action | Notes |
|---------|--------|-------|
| `C-a h` | Navigate left | Works in tmux |
| `C-a j` | Navigate down | Works in tmux |
| `C-a k` | Navigate up | Works in tmux |
| `C-a l` | Navigate right | Works in tmux |
| `C-h/j/k/l` | Smart navigate | Works across tmux & vim |

### Pane Resizing

| Binding | Action | Alternative |
|---------|--------|-------------|
| `C-a H` | Resize left | `C-a <` |
| `C-a J` | Resize down | `C-a -` |
| `C-a K` | Resize up | `C-a +` |
| `C-a L` | Resize right | `C-a >` |
| `C-a =` | Equal size | - |

## Copy Mode (Vi-style)

### Essential Copy Commands

| Binding | Action | Notes |
|---------|--------|-------|
| `C-a [` | Enter copy mode | Vi-mode navigation |
| `v` | Start selection | Visual mode |
| `V` | Line selection | Visual line |
| `C-v` | Block selection | Visual block |
| `y` | Copy selection | To system clipboard |
| `C-a ]` | Paste buffer | From tmux buffer |
| `q` | Exit copy mode | Or `Esc` |

### Copy Mode Navigation

| Binding | Action | Binding | Action |
|---------|--------|---------|--------|
| `h/j/k/l` | Move cursor | `w/b` | Word forward/back |
| `0/$` | Line start/end | `g/G` | Top/bottom |
| `{/}` | Paragraph | `C-u/C-d` | Half page up/down |
| `/` | Search forward | `?` | Search backward |
| `n/N` | Next/prev match | `f/F` | Find char |

## Status Bar & Theme

### Current Configuration

- Left: Session name `[session]`
- Center: Window list with indicators
- Right: `user@host | %Y-%m-%d %H:%M`

### Window Indicators
```
* Current window
- Last window
# Activity in window
! Bell in window
~ Silence alert
Z Zoomed pane active
M Marked pane
```

### Theme Integration

- Follows system dark/light mode
- Dark: Dracula colors
- Light: Solarized colors
- Reloads on theme change

## Plugin Ecosystem

### Installed Plugins (TPM)

| Plugin | Purpose | Key Features |
|--------|---------|--------------|
| tmux-resurrect | Session persistence | Save/restore layouts |
| tmux-continuum | Auto-save | Every 15 min + boot restore |
| tmux-yank | System clipboard | Copy to system clipboard |
| tmux-prefix-highlight | Visual feedback | Shows prefix active |
| vim-tmux-navigator | Seamless navigation | C-h/j/k/l across tmux/vim |

### Plugin Management
```bash
# TPM commands
C-a I      # Install new plugins
C-a U      # Update all plugins
C-a Alt+u  # Uninstall removed plugins

# Manual plugin management
~/.tmux/plugins/tpm/bin/install_plugins
~/.tmux/plugins/tpm/bin/update_plugins all
~/.tmux/plugins/tpm/bin/clean_plugins
```

## Configuration

### Core Settings
```tmux
# Better defaults
set -g mouse on                    # Mouse support
set -g base-index 1               # Start at 1
set -g renumber-windows on        # Auto renumber
set -g history-limit 50000        # Large history
set -g display-time 4000          # Message time
set -sg escape-time 0             # No delay

# True color support
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",xterm-256color:Tc"
```

### Custom Shortcuts
```tmux
# Quick splits in current directory
bind '"' split-window -v -c "#{pane_current_path}"
bind % split-window -h -c "#{pane_current_path}"

# Reload config
bind R source-file ~/.tmux.conf \; display-message "Config reloaded!"

# Clear history
bind -n C-l send-keys C-l \; run 'sleep 0.1' \; clear-history
```

## Advanced Workflows

### Development Layout Template
```yaml
# ~/.dotfiles/src/tmuxinator/project.yaml
name: project
root: ~/projects/<%= @args[0] %>

windows:
  - editor:
      layout: main-vertical
      main-pane-width: 66%
      panes:
        - nvim .
        - # empty for commands
  - server:
      panes:
        - npm run dev
  - git:
      panes:
        - lazygit
  - logs:
      panes:
        - tail -f logs/*.log
```

### Dotfiles Demo Session

```bash
tmuxinator start dotfiles_demo
# Shows: overview, neovim, git, theme switching, monitoring
```

### AI Development Session

```bash
tmuxinator start ai
# Windows: editor, jupyter, logs, resources
```

## Performance Tips

### Speed Optimizations

1. Escape time: 0ms
2. History: 50,000 lines
3. Smart resizing
4. Aggressive resize

### Resource Management
```bash
# Check memory usage
tmux list-panes -a -F "#{pane_pid} #{pane_current_command}" | \
  xargs ps -o pid,vsz,rss,comm -p

# Clean up old sessions
tmux list-sessions | grep -v attached | cut -d: -f1 | \
  xargs -I {} tmux kill-session -t {}
```

## Pro Tips & Tricks

### Productivity Tips

1. Named sessions
2. Pane synchronization: `C-a :setw synchronize-panes`
3. Monitor activity: `C-a :setw monitor-activity on`
4. Quick pane swap: `C-a {` or `C-a }`
5. Zoom focus: `C-a z`

### Advanced Commands
```bash
# Send keys to pane
tmux send-keys -t session:window.pane "command" Enter

# Capture pane output
tmux capture-pane -t 1 -p > output.txt

# Run command in new window
tmux new-window -n logs 'tail -f /var/log/system.log'

# Join pane from another window
tmux join-pane -s 2.1 -t 1.0
```

### Integration Tips
```bash
# SSH with tmux
ssh server -t "tmux a || tmux"

# Git commit in popup
bind g display-popup -E "git commit"

# Quick calculator
bind = display-popup -E "bc -l"
```

## Troubleshooting

### Common Issues

| Problem | Solution |
|---------|----------|
| Colors broken | Set `TERM=screen-256color` in tmux |
| Can't create session | Check `tmux ls` for existing |
| Prefix not working | Ensure `C-a` not captured by terminal |
| Copy not working | Install `reattach-to-user-namespace` |
| Plugins not loading | Run `C-a I` to install |

### Debug Commands
```bash
tmux info                  # Server information
tmux show-options -g       # Global options
tmux show-window-options   # Window options
tmux list-keys            # All key bindings
```

### Recovery
```bash
# If tmux is frozen
tmux kill-server

# If session corrupted
rm -rf ~/.tmux/resurrect/last
tmux

# Force detach other clients
tmux a -d -t session
```

## Customization

### Status Bar Customization
```tmux
# Minimal status bar
set -g status-left '[#S] '
set -g status-right '%H:%M '

# Fancy with powerline
set -g status-left '#[bg=colour241]#[fg=colour248] #S '
set -g status-right '#[fg=colour248]#[bg=colour241] %H:%M '
```

### Color Schemes
```tmux
# Dracula inspired
set -g status-style 'bg=#44475a fg=#f8f8f2'
set -g window-status-current-style 'bg=#bd93f9 fg=#282a36'

# Solarized light
set -g status-style 'bg=#eee8d5 fg=#657b83'
set -g window-status-current-style 'bg=#93a1a1 fg=#fdf6e3'
```

