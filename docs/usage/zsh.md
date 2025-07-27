# Zsh with Oh My Zsh Usage Guide

## Command/Shortcut Reference Table

### Directory Navigation
| Command | Action | Description |
|---------|--------|-------------|
| `cd` | Change directory | Auto-cd enabled - just type directory name |
| `..` | Parent directory | Go up one level |
| `...` | Two levels up | Go up two levels |
| `....` | Three levels up | Go up three levels |
| `.....` | Four levels up | Go up four levels |
| `cd-` | Previous directory | Toggle between last two directories |
| `z <pattern>` | Smart jump | Jump to frecent directory matching pattern |
| `home` | Home directory | Quick jump to ~ |
| `desktop` | Desktop folder | Jump to ~/Desktop |
| `downloads` | Downloads folder | Jump to ~/Downloads |
| `projects` | Projects folder | Jump to ~/Projects |
| `dotfiles` | Dotfiles folder | Jump to ~/.dotfiles |

### File Listing (eza-powered)
| Command | Action | Description |
|---------|--------|-------------|
| `ls` | List files | Enhanced with eza, groups directories first |
| `ll` | Long listing | Detailed view with git status, relative time |
| `la` | List all | Including hidden files |
| `lt` | Tree view | Show as tree (2 levels) |
| `lh` | Human readable | Show sizes in human format |
| `lS` | Sort by size | Largest files first |
| `l1/l2/l3` | Tree levels | Show tree with 1/2/3 levels |

### Git Shortcuts
| Command | Action | Description |
|---------|--------|-------------|
| `g` | Git | Short for git |
| `ga` | Git add | Stage changes |
| `gaa` | Git add all | Stage all changes |
| `gc` | Git commit | Commit staged changes |
| `gcm` | Git commit message | Commit with inline message |
| `gco` | Git checkout | Switch branches/restore files |
| `gcb` | Git checkout -b | Create and switch to new branch |
| `gd` | Git diff | Show unstaged changes |
| `gdc` | Git diff cached | Show staged changes |
| `gs` | Git status | Repository status |
| `gp` | Git push | Push to remote |
| `gpl` | Git pull | Pull from remote |
| `gl` | Git log pretty | Beautiful commit history |
| `gwip` | Work in progress | Quick WIP commit |
| `gunwip` | Undo WIP | Undo last WIP commit |
| `gfresh` | Cleanup branches | Delete merged branches |

### Search & Find
| Command | Action | Description |
|---------|--------|-------------|
| `grep` | Ripgrep | Aliased to rg for speed |
| `find-file` | Find files | Uses fd for fast file finding |
| `find-content` | Search content | Uses ripgrep |
| `search` | Pretty search | Ripgrep with context |
| `todos` | Find TODOs | Search for TODO/FIXME/NOTE |
| `pygrep` | Python search | Search only Python files |
| `jsgrep` | JavaScript search | Search only JS files |

### Editor & Config Shortcuts
| Command | Action | Description |
|---------|--------|-------------|
| `v` | Neovim | Quick editor access |
| `vim` | Neovim | Aliased to nvim |
| `zshconfig` | Edit zshrc | Open ~/.zshrc in editor |
| `zshreload` | Reload config | Source ~/.zshrc |
| `vimconfig` | Edit Neovim | Open init.lua |
| `tmuxconfig` | Edit tmux | Open tmux.conf |
| `gitconfig` | Edit git | Open gitconfig |
| `reload` | Reload shell | Source zshrc and clear |

### Tmux & Sessions
| Command | Action | Description |
|---------|--------|-------------|
| `tm` | Tmux | Short for tmux |
| `tma` | Attach session | Attach to existing |
| `tmn` | New session | Create new session |
| `tml` | List sessions | Show all sessions |
| `tx` | Tmuxinator | Session manager |
| `txs` | Start project | Start tmuxinator project |
| `txl` | List projects | Show tmuxinator projects |

### System Utilities
| Command | Action | Description |
|---------|--------|-------------|
| `update` | Update system | Brew update & upgrade |
| `updateall` | Update everything | System + npm + pip packages |
| `cleanup` | Clean files | Remove .DS_Store, .pyc files |
| `df` | Disk free | Human readable disk usage |
| `top` | Process monitor | Aliased to htop |
| `ps` | Process list | Aliased to procs |
| `ip` | External IP | Show public IP address |
| `localip` | Internal IP | Show local network IP |
| `speedtest` | Network speed | Test internet speed |
| `sysinfo` | System info | Display system details |
| `myip` | All IPs | Show internal and external IPs |

### Development Tools
| Command | Action | Description |
|---------|--------|-------------|
| `py` | Python 3 | Quick Python access |
| `serve` | HTTP server | Start local web server |
| `d` | Docker | Docker shortcut |
| `dc` | Docker Compose | Docker Compose shortcut |
| `k` | Kubectl | Kubernetes shortcut |
| `json` | JSON formatter | Pretty print JSON |
| `urlencode` | URL encode | Encode URLs |
| `urldecode` | URL decode | Decode URLs |

### Theme Management
| Command | Action | Description |
|---------|--------|-------------|
| `theme` | Switch theme | Toggle light/dark mode |
| `dark` | Dark mode | Force dark theme |
| `light` | Light mode | Force light theme |

### Archive & History Management
| Command | Action | Description |
|---------|--------|-------------|
| `h` | History | Show command history |
| `Ctrl+R` | Reverse search | Search command history |
| `↑/↓` | History search | Search with current prefix |

### Enhanced Features
| Command | Action | Description |
|---------|--------|-------------|
| `cat` | Better cat | Uses bat with syntax highlighting |
| `diff` | Color diff | Colored diff output |
| `tree` | Better tree | Uses eza tree view |
| `man` | Better man | Opens in Neovim |
| `weather` | Weather info | curl wttr.in |
| `moon` | Moon phase | Current moon phase |

## Quick Reference

### Oh My Zsh Plugins Enabled
- **vi-mode**: Vim keybindings in command line
- **git**: Git aliases and functions
- **z**: Smart directory jumping
- **history-substring-search**: Better history search
- **colored-man-pages**: Colorized manual pages
- **command-not-found**: Package suggestions
- **extract**: Universal archive extraction

### Shell Options
- **AUTO_CD**: Change directory without typing cd
- **CORRECT_ALL**: Command and argument correction
- **GLOB_DOTS**: Include dotfiles in globs
- **HIST_IGNORE_ALL_DUPS**: No duplicate history entries
- **SHARE_HISTORY**: Share history between sessions

### Keybindings
- `Ctrl+A`: Beginning of line
- `Ctrl+E`: End of line
- `Ctrl+K`: Kill to end of line
- `Ctrl+U`: Kill to beginning of line
- `Ctrl+W`: Delete word backwards
- `Ctrl+R`: Reverse history search
- `Alt+←/→`: Move by word
- `Esc`: Enter vi command mode

## About

This Zsh configuration provides a modern, productive shell environment with:

- **Oh My Zsh** framework for plugin management
- **Spaceship** prompt with git integration
- **Vi-mode** for efficient command line editing
- **Smart completions** with case-insensitive matching
- **Modern tools** replacing traditional Unix utilities
- **Theme integration** with the dotfiles ecosystem

## Additional Usage Info

### Directory Stack
The configuration enables automatic directory stack management:
- Every `cd` pushes to the directory stack
- Use `dirs -v` to view the stack
- Use `~N` to jump to Nth directory in stack
- Example: `~2` jumps to the 2nd directory in stack

### Z Directory Jumping
The `z` command learns from your navigation:
- `z proj` might jump to `~/Projects/my-project`
- `z down` might jump to `~/Downloads`
- Uses frecency (frequency + recency) algorithm

### Git Plugin Features
Oh My Zsh's git plugin provides hundreds of aliases:
- `gst` = `git status`
- `gco` = `git checkout`
- `gcmsg` = `git commit -m`
- Run `alias | grep git` to see all

### Completion System
Advanced tab completion features:
- Case-insensitive matching
- Partial word completion
- Menu selection with arrow keys
- Grouped results by type
- Cached results for speed

## Further Command Explanations

### Vi-Mode Operations
In vi-mode (after pressing Esc):
- `k`/`j`: Navigate history
- `w`/`b`: Move by word
- `0`/`$`: Start/end of line
- `i`/`a`: Enter insert mode
- `v`: Visual selection mode
- `/`: Search in command

### History Management
- **50,000 commands** stored in history
- **Shared history** across all sessions
- **Substring search** with arrow keys
- **No duplicates** automatically removed
- **Timestamps** stored with each command

### Performance Features
- **Lazy loading** for NVM (Node Version Manager)
- **Cached completions** for faster response
- **Optimized PATH** with deduplication
- **Smart plugin loading** order
- **Homebrew** optimized for Apple Silicon

### Custom Functions
Built-in helper functions:
- `mkcd`: Create directory and cd into it
- `ff`: Find files with fzf preview
- `grep_smart`: Intelligent grep with ripgrep
- `git_clean_branches`: Remove merged branches
- `project`: Quick jump to project directories
- `serve`: Start Python HTTP server

## Theory & Background

### Shell Philosophy
This configuration balances power and usability:
- **Power user features** without complexity
- **Modern tools** replacing outdated utilities
- **Consistent keybindings** across all tools
- **Performance** without sacrificing features

### Tool Choices
- **eza over ls**: Modern, fast, git-aware
- **ripgrep over grep**: 10x faster, better defaults
- **fd over find**: Intuitive syntax, respects .gitignore
- **bat over cat**: Syntax highlighting, git integration
- **htop over top**: Interactive, colorful, informative

### Spaceship Prompt
Displays contextual information:
- Current directory (truncated)
- Git branch and status
- Python/Node version (when relevant)
- Command execution time
- Vi-mode indicator
- Exit code on failure

## Good to Know / Lore / History

### Evolution
This configuration evolved from:
1. Basic bash setup (pre-2010)
2. Initial Zsh adoption (2012)
3. Oh My Zsh integration (2014)
4. Modern tool adoption (2020+)
5. Full Lua/performance optimization (2025)

### Performance Optimizations
- Removed heavy prompt themes
- Lazy-loaded language managers
- Cached completion results
- Minimal plugin set
- Optimized for Apple Silicon

### Hidden Features

1. **Smart Correction**: Typos are automatically suggested for correction
2. **Directory Shortcuts**: `~name` expands to full paths
3. **Glob Qualifiers**: `*(.)` for files only, `*(/)` for directories
4. **Parameter Expansion**: `!!:$` gets last argument of previous command
5. **Arithmetic**: `$((2+2))` evaluates math expressions

### Integration Points
- Sources theme configuration from `~/.config/theme-switcher/`
- Integrates with Neovim as `EDITOR` and `MANPAGER`
- Works with tmux for session management
- Coordinates with Alacritty for true color support

### Pro Tips

1. **Use `z` aggressively** - it learns and gets better
2. **Tab completion everything** - commands, files, git branches
3. **History substring search** - type partial command and press ↑
4. **Vi-mode for editing** - complex edits are easier in command mode
5. **Aliases are stackable** - `g` + `st` = `gst` = `git status`
6. **Background jobs** - Use `&` and `jobs`/`fg`/`bg` commands
7. **Process substitution** - `diff <(ls dir1) <(ls dir2)`
8. **Extended globs** - `**/*.js` finds all JavaScript files recursively