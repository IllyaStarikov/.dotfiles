# Tmux & Tmuxinator Usage Guide

## Command/Shortcut Reference Table

### Core Controls
| Key | Action | Context | Description |
|-----|--------|---------|-------------|
| `C-a` | Prefix | Global | Command prefix (instead of default C-b) |
| `C-a C-a` | Send prefix | Global | Send literal C-a to application |
| `C-a r` | Reload config | Global | Reload ~/.tmux.conf with confirmation |
| `C-a ?` | List keys | Global | Show all keybindings |

### Pane Management
| Key | Action | Context | Description |
|-----|--------|---------|-------------|
| `C-a |` | Split vertical | Window | Create vertical pane split |
| `C-a -` | Split horizontal | Window | Create horizontal pane split |
| `C-a h/j/k/l` | Navigate panes | Window | Vim-style pane navigation |
| `C-h/j/k/l` | Smart navigation | Window | Vim/tmux aware navigation |
| `C-a H/J/K/L` | Resize pane (5) | Window | Resize by 5 units |
| `C-a C-h/j/k/l` | Resize pane (1) | Window | Fine-grained resize |
| `C-a m` | Maximize pane | Window | Toggle pane zoom |
| `C-a x` | Kill pane | Window | Close pane (no confirm) |
| `C-a Space` | Cycle layouts | Window | Cycle pane arrangements |

### Window Management
| Key | Action | Context | Description |
|-----|--------|---------|-------------|
| `C-a c` | New window | Session | Create window in current path |
| `C-a Tab` | Last window | Session | Toggle to previous window |
| `C-a C-p` | Previous window | Session | Navigate windows |
| `C-a C-n` | Next window | Session | Navigate windows |
| `C-a </>` | Swap window | Session | Move window left/right |
| `C-a ,` | Rename window | Session | Give window a name |
| `C-a X` | Kill window | Session | Close window (no confirm) |
| `C-a 0-9` | Select window | Session | Jump to window by number |

### Session Management
| Key | Action | Context | Description |
|-----|--------|---------|-------------|
| `C-a S` | Choose session | Global | Interactive session switcher |
| `C-a s` | New session | Global | Create new session |
| `C-a d` | Detach | Session | Detach from current session |
| `C-a $` | Rename session | Session | Give session a name |
| `C-a (/)` | Switch session | Global | Previous/next session |

### Copy Mode (vi-style)
| Key | Action | Context | Description |
|-----|--------|---------|-------------|
| `C-a [` | Enter copy mode | Window | Start selection mode |
| `v` | Begin selection | Copy mode | Start visual selection |
| `V` | Line selection | Copy mode | Select entire lines |
| `C-v` | Rectangle selection | Copy mode | Column selection |
| `y` | Copy selection | Copy mode | Copy to system clipboard |
| `Enter` | Copy & exit | Copy mode | Copy and leave mode |
| `C-a ]` | Paste | Window | Paste from clipboard |
| `/` | Search forward | Copy mode | Find text |
| `?` | Search backward | Copy mode | Reverse find |

### Utility Functions
| Key | Action | Context | Description |
|-----|--------|---------|-------------|
| `C-a y` | Sync panes | Window | Toggle typing in all panes |
| `C-a C-k` | Clear history | Pane | Clear pane and history |
| `C-a i` | Display info | Window | Show pane information |
| `C-a t` | Show time | Window | Display clock |

### Quick Layouts
| Key | Action | Context | Description |
|-----|--------|---------|-------------|
| `C-a D` | Dev layout | Session | Create development workspace |
| `C-a M` | Monitor layout | Session | Create monitoring workspace |

### Mouse Operations
| Action | Description |
|--------|-------------|
| Click pane | Select pane |
| Drag border | Resize panes |
| Click window | Select window in status bar |
| Scroll | Scroll pane content |
| Right-click | Context menu (if supported) |

## Tmuxinator Commands

### Project Management
| Command | Action | Description |
|---------|--------|-------------|
| `tx` | Tmuxinator | Short alias for tmuxinator |
| `txs <project>` | Start project | Launch project session |
| `txl` | List projects | Show all projects |
| `txe <project>` | Edit project | Modify project config |
| `txn <name>` | New project | Create new project |
| `tx delete <project>` | Delete project | Remove project config |
| `tx doctor` | Check setup | Verify tmuxinator setup |
| `tx implode` | Remove all | Delete all projects |

### Tmux Native Commands
| Command | Action | Description |
|---------|--------|-------------|
| `tmux` | Start tmux | New unnamed session |
| `tmux new -s name` | Named session | Create named session |
| `tmux ls` | List sessions | Show all sessions |
| `tmux attach` | Attach session | Connect to most recent |
| `tmux attach -t name` | Attach specific | Connect to named session |
| `tmux kill-session -t name` | Kill session | Terminate session |
| `tmux kill-server` | Kill all | Stop tmux completely |

## Quick Reference

### Essential Features
- **Mouse support** enabled for clicking and scrolling
- **Vi-mode** copy/paste with system clipboard integration
- **256 colors** and true color support
- **Automatic renumbering** when closing windows
- **Session persistence** via tmux-resurrect/continuum
- **Smart pane switching** integrated with Neovim

### Status Bar
- Shows session name, windows, and system info
- Top positioning for better visibility
- Activity indicators for background windows
- Current window highlighted
- Pane title shows current command

### Plugins Included
- **tpm**: Tmux Plugin Manager
- **tmux-sensible**: Better defaults
- **tmux-resurrect**: Save/restore sessions
- **tmux-continuum**: Auto-save sessions
- **tmux-yank**: Enhanced copy functionality
- **tmux-copycat**: Regex searches
- **tmux-open**: Open highlighted selection

## About

This tmux configuration provides a modern terminal multiplexer setup optimized for:

- **Development workflows** with smart layouts
- **Vim integration** for seamless navigation
- **macOS optimization** with proper clipboard support
- **Session persistence** across restarts
- **Visual feedback** with activity monitoring

## Additional Usage Info

### Session Persistence
Sessions are automatically saved every 15 minutes and restored on tmux start:
- Manual save: `C-a C-s`
- Manual restore: `C-a C-r`
- Sessions survive system restarts

### Pane Synchronization
Useful for running commands on multiple servers:
1. Split into multiple panes
2. SSH to different servers
3. Press `C-a y` to synchronize
4. Type commands that run everywhere
5. Press `C-a y` again to desynchronize

### Window Monitoring
- Windows with activity show indicators
- Bell/alert in window shows notification
- Monitor silence with `:setw monitor-silence 30`

### Advanced Copy Mode
In copy mode (`C-a [`):
- `g` - Go to top
- `G` - Go to bottom
- `w` - Jump by word
- `b` - Jump backward by word
- `f<char>` - Jump to character
- `F<char>` - Jump backward to character

## Further Command Explanations

### Tmuxinator Project Files
Project definitions are YAML files stored in `~/.tmuxinator/`:
```yaml
name: project-name
root: ~/path/to/project

windows:
  - editor:
      layout: main-vertical
      panes:
        - vim
        - guard
  - server: bundle exec rails s
  - logs: tail -f log/development.log
```

### Layout Presets
Tmux offers several built-in layouts:
- `even-horizontal` - Panes spread horizontally
- `even-vertical` - Panes spread vertically
- `main-horizontal` - Large pane on top
- `main-vertical` - Large pane on left
- `tiled` - Equal-sized grid

### Command Mode
Enter with `C-a :` for advanced commands:
- `:new-window -n name` - Create named window
- `:split-window -h -p 30` - Split with 30% width
- `:resize-pane -D 10` - Resize down 10 lines
- `:swap-pane -U` - Swap with pane above
- `:break-pane` - Convert pane to window
- `:join-pane -t 2` - Join pane to window 2

## Theory & Background

### Multiplexer Concept
Tmux creates persistent terminal sessions that:
- Survive SSH disconnections
- Allow multiple windows/panes
- Enable session sharing
- Provide scriptable environments

### Client-Server Architecture
- **Server**: Manages all sessions
- **Client**: Connects to view/control sessions
- Multiple clients can connect to one session
- Sessions persist when all clients detach

### Pane vs Window vs Session
- **Pane**: Single terminal view
- **Window**: Collection of panes
- **Session**: Collection of windows
- Think: Session = Project, Window = Task, Pane = Tool

## Good to Know / Lore / History

### Evolution from Screen
Tmux was created as a modern alternative to GNU Screen:
- Better scripting support
- Cleaner codebase
- More intuitive commands
- Active development

### Prefix Key Choice
`C-a` chosen over default `C-b` because:
- More ergonomic reach
- GNU Screen compatibility
- Less finger strain
- Conflicts less with shell shortcuts

### Integration Features

1. **Neovim Integration**: Smart pane switching knows when you're in Vim
2. **Clipboard Integration**: Works with macOS pbcopy/pbpaste
3. **Theme Coordination**: Loads theme from ~/.config/tmux/theme.conf
4. **Shell Integration**: Preserves working directory in new panes/windows

### Performance Tips

1. **Limit scrollback**: Large history slows performance
2. **Disable aggressive-resize**: If using multiple displays
3. **Reduce status-interval**: If on battery power
4. **Use named sessions**: Easier to manage and script

### Hidden Features

1. **Break/Join Panes**: `break-pane` and `join-pane` commands
2. **Pipe Pane**: `pipe-pane` to save output to file
3. **Respawn Pane**: `respawn-pane` to restart dead process
4. **Link Window**: Share windows between sessions
5. **Set Hooks**: Run commands on events

### Pro Tips

1. **Use Tmuxinator** for reproducible development environments
2. **Name everything** - sessions, windows, and panes
3. **Learn layouts** - `C-a Space` cycles through them
4. **Use marks** - `C-a m` to mark, `C-a '` to jump
5. **Zoom liberally** - `C-a m` for focused work
6. **Script sessions** - `tmux send-keys` for automation
7. **Monitor long tasks** - Activity/silence monitoring
8. **Share sessions** - Great for pair programming