# Daily Development Workflow

## Morning Startup

```bash
# 1. Launch Terminal
# Alacritty opens instantly with your theme

# 2. Resume Yesterday's Work
tmux a              # Attach to existing session
# or
tmuxinator start project  # Start predefined layout

# 3. Update Everything
update              # Updates brew, npm, pip, gems, rust

# 4. Check Status
gs                  # Git status
todo                # Review tasks (if using todo app)
```

## Project Navigation

### Quick Directory Access
```bash
# Smart jumping with z plugin
z proj              # Jump to ~/projects/something
z dot               # Jump to ~/.dotfiles  
z -l                # List frecent directories
z web front         # Match multiple keywords

# Quick navigation aliases
cd -                # Previous directory
..                  # Up one level
...                 # Up two levels
....                # Up three levels
.4                  # Up four levels

# Common shortcuts
home                # cd ~
desktop             # cd ~/Desktop
projects            # cd ~/Projects
dotfiles            # cd ~/.dotfiles
```

### File Operations
```bash
ll                # List with details + icons
lt                # Tree view
la                # Show hidden files
fd README         # Find files named README
fd -e md          # Find all markdown files
```

## Code Search & Navigation

### Finding Things Fast
```bash
# In Shell
rg "TODO"         # Search all files for TODO
rg -t py "class"  # Search Python files for "class"
fd -e js | fzf    # Fuzzy find JavaScript files

# In Neovim
<leader>ff        # Fuzzy find files
<leader>fg        # Grep across project
<leader>fb        # Browse buffers
<leader>fs        # Search symbols
gd                # Go to definition
gr                # Find references
```

## Code Editing Workflow

### Starting Work
```bash
v .               # Open Neovim in project
v file.py         # Edit specific file
```

### AI-Assisted Development
```vim
<leader>cc        # Open AI chat
<leader>ca        # Show AI actions menu
# Select code, then:
<leader>ce        # Explain code
<leader>co        # Optimize selection
<leader>ct        # Generate tests
<leader>cf        # Fix bugs
```

### Navigation & Editing
```vim
# Movement
w/b               # Word forward/back
0/$               # Line start/end
gg/G              # File start/end
{/}               # Paragraph up/down
%                 # Matching bracket

# Editing
ciw               # Change inner word
da{               # Delete around braces
yi"               # Yank inside quotes
vap               # Select paragraph

# Markdown Preview
<leader>mp        # Toggle rich preview/ligatures
# Auto-disables in insert mode for editing
```

### Multi-File Operations
```vim
<leader>ff        # Find file
<leader>b         # Switch buffer
:wa               # Save all
:qa               # Close all
<C-w>s            # Split horizontal
<C-w>v            # Split vertical
```

## Git Workflow

### Feature Development
```bash
# 1. Start Feature
gco -b feature/awesome    # Create branch
# or
gco main && gl           # Update main first
gco -b feature/awesome

# 2. Work & Commit
gaa                      # Add all changes
gcmsg "feat: add thing"  # Commit with message
# or semantic commits:
git feat "add awesome"   # Creates "feat: add awesome"
git fix "null pointer"   # Creates "fix: null pointer"

# 3. Push & Create PR
gpsup                    # Push and set upstream
gh pr create             # Create pull request
```

### Quick Fixes
```bash
# Amend last commit
ga forgotten-file.txt
gc! -n                   # Amend, no edit

# Undo last commit (keep changes)
grh HEAD~1

# Stash work
gsta                     # Stash changes
gco other-branch         # Switch branches
gstp                     # Pop stash back
```

### Review & Sync
```bash
# Update branch
gfa                      # Fetch all
grb origin/main          # Rebase on main

# Review changes
gd                       # Diff working
gds                      # Diff staged
glog                     # Visual history
```

## Terminal Multiplexing

### Session Management
```bash
tmux new -s work         # New named session
tmux ls                  # List sessions
tmux a -t work          # Attach to "work"
C-a d                   # Detach
```

### Window & Pane Control
```bash
C-a c                   # New window
C-a n/p                 # Next/previous window
C-a 1-9                 # Jump to window

C-a |                   # Vertical split
C-a -                   # Horizontal split
C-a h/j/k/l            # Navigate panes
C-a z                   # Zoom pane
```

### Copy Mode
```bash
C-a [                   # Enter copy mode
# Navigate with vim keys
v                       # Start selection
y                       # Copy selection
C-a ]                   # Paste
```

## Development Tasks

### Running Tests
```bash
# In shell
npm test                # Run tests
npm run test:watch      # Watch mode

# In Neovim
<leader>tn              # Test nearest
<leader>tf              # Test file
<leader>ts              # Test suite
```

### Debugging
```vim
<leader>db              # Toggle breakpoint
<leader>dc              # Continue
<leader>di              # Step into
<leader>do              # Step over
<leader>dr              # Open REPL
```

### Code Quality
```bash
# Linting
npm run lint            # Run linter
npm run lint:fix        # Auto-fix

# In Neovim
<leader>lf              # Format file
<leader>la              # Code actions
<leader>lr              # Rename symbol
```

## Environment Management

### Theme Switching
```bash
theme                   # Auto-detect system
dark                    # Force dark mode
light                   # Force light mode
```

### Python Environments
```bash
pyenv versions          # List versions
pyenv local 3.11        # Set project version
python -m venv .venv    # Create virtual env
source .venv/bin/activate # Activate
```

### Node Versions
```bash
nvm list                # List versions
nvm use 18              # Use Node 18
nvm install --lts       # Install latest LTS
```

## Monitoring & Analysis

### System Resources
```bash
btop                    # Beautiful process monitor
duf                     # Disk usage
procs pattern           # Find processes
bandwhich               # Network monitor
```

### Git Analytics
```bash
git who                 # Contributors
git standup             # Yesterday's commits
tig                     # Interactive git browser
```

### Log Analysis
```bash
tail -f app.log         # Follow logs
tail -f app.log | grep ERROR  # Filter errors
bat app.log             # View with syntax
```

## 🚄 Speed Shortcuts

### Ultra-Fast Commands
```bash
# Navigation
z proj                  # Jump to ~/projects/project
bd                      # Back to previous dir
1                       # cd ~/1-projects
2                       # cd ~/2-personal

# Git
gaa && gcmsg "fix" && gp  # Add, commit, push
grhh                    # Reset everything
gsta && gco main       # Stash and switch

# Files
v `fzf`                 # Open fuzzy-found file
rg TODO | v             # Open all TODOs
```

### Shell History & Expansion
```bash
Ctrl+R                  # Fuzzy history search (fzf)
↑/↓                     # Substring search in history
!!                      # Last command
sudo !!                 # Last command with sudo
!$                      # Last argument
!^                      # First argument
!*                      # All arguments
!git                    # Last git command
!-2                     # Command from 2 ago

# Z plugin history
z -l                    # List frecent directories
z -r proj               # Match by rank only
z -t proj               # Match by time only
```

## End of Day

### Clean Up
```bash
# Close Neovim sessions
:wa                     # Write all buffers
:SessionSave            # Save session
:qa                     # Quit all

# Git housekeeping
gs                      # Check status
gsta                    # Stash if needed
gco main               # Return to main

# System
brew cleanup            # Clean old versions
docker system prune     # Clean Docker
```

### Shutdown
```bash
C-a d                   # Detach tmux (persists)
# or
tmux kill-session       # Completely close
exit                    # Close terminal
```

## Pro Tips

### Command Combinations
```bash
# Find and edit
v $(fd -e py | fzf)     # Edit Python file

# Search and replace
rg -l "old" | xargs sd "old" "new"

# Git cleanup
gfa && git cleanup     # Fetch and delete merged

# Quick server
python -m http.server  # Instant web server
```

### Time Savers
1. **Use `z`** - Jump to any directory instantly
2. **Use `ff`** - Interactive file finder with preview
3. **Use `grep`** - Aliased to ripgrep for speed
4. **Use `C-r`** - Fuzzy search command history
5. **Use `<C-t>`** - Context menu in Neovim
6. **Use `gaa && gcm`** - Quick commit workflow
7. **Use semantic commits** - `git feat`, `git fix`
8. **Use `todos`** - Find all TODO/FIXME instantly

### Emergency Commands
```bash
# Git mistakes
grhh                     # Nuclear reset (lose all)
git uncommit             # Keep changes, undo commit
gundo                    # Alias for soft reset
git reflog               # Find lost commits

# Process issues
killall processname      # Kill by name
lsof -i :3000           # What's using port 3000
kill -9 $(lsof -t -i:3000)  # Kill it
listening                # All LISTEN ports

# Disk space
df -H                    # Check disk usage
du -ch | sort -hr        # Find large directories
brew cleanup             # Clear Homebrew cache
cleanup                  # Remove .DS_Store files

# Neovim issues
:checkhealth             # Diagnose problems
:Lazy clean && :Lazy sync  # Reset plugins
```

## Quick Reference Card

```
FILE NAV            GIT                TMUX              NEOVIM
z dir    Jump       gs      Status     C-a c   New win   :w      Save
ll       List+git   gaa     Add all    C-a |   V-split   :q      Quit
fd name  Find       gcm     Commit     C-a d   Detach    <C-t>   Menu
ff       Fuzzy      gp      Push       C-a [   Copy      gd      Go def
..       Up dir     gpl     Pull       C-a z   Zoom      <l>ff   Files

SEARCH              SYSTEM             AI/ASSIST         POWER
grep     Ripgrep    htop    Monitor    <l>cc   Chat      !!      Last cmd
todos    Find TODO  df -H   Disk       <l>ca   Actions   !$      Last arg
search   Smart rg   myip    IP addr    <l>co   Optimize  C-r     History
fixmes   Find FIX   update  Brew up    <l>ce   Explain   z -l    Z list
```

## Integrated Development Workflow

### Complete Feature Implementation
```bash
# 1. Start with tmuxinator template
tmuxinator start project ~/work/myapp

# 2. In Window 1 (Editor) - Neovim with AI
v .                      # Open project
<C-t>                    # Context menu for navigation
<leader>cc               # AI chat for design help
<leader>ff               # Find files
<leader>fg               # Search codebase

# 3. In Window 2 (Server) - Development server
npm run dev              # Or your server command
# Logs appear here

# 4. In Window 3 (Git) - Version control
lazygit                  # Visual git interface
# or traditional:
gs                       # Status
gaa && gcm "message"     # Commit

# 5. Quick iterations
# Edit in Neovim → Save → See changes in browser
# Use <leader>lf to format on save
# Use <leader>ca for AI assistance
```


