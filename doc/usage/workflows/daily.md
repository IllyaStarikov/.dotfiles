# Daily Development Workflow

> **From startup to shutdown - optimized daily patterns**

## Morning Startup

### 1. Launch Environment

```bash
# Open Alacritty (GPU-accelerated terminal)
# Theme automatically matches system appearance
```

### 2. Resume Work Session

```bash
# Check for existing sessions
tmux ls

# Attach to yesterday's session
tmux a

# Or start fresh with layout
tmuxinator start main
```

### 3. System Updates

```bash
# Update all tools and packages
update-dotfiles

# This updates:
# - Homebrew packages
# - Node.js packages
# - Python packages
# - Ruby gems
# - Rust toolchain
# - Neovim plugins
```

### 4. Project Navigation

```bash
# Jump to project
z myproject

# Check git status
gs

# Or use visual git
lazygit
```

## Development Workflow

### Starting a Feature

```bash
# 1. Ensure main is up to date
gco main && gl

# 2. Create feature branch
gcb feature/new-widget
# or semantic
git feat new-widget

# 3. Open editor
v .
```

### Coding Session

#### In Neovim

```vim
" Find files quickly
<leader>ff

" Search codebase
<leader>fg

" Get AI assistance
<leader>cc

" Navigate code
gd              " Go to definition
K               " Show documentation
<leader>ca      " AI actions menu
```

#### Testing Changes

```bash
# Run tests
npm test

# Or in Neovim
<leader>tn      " Test nearest
<leader>tf      " Test file
```

### Committing Work

```bash
# Review changes
gd              # git diff

# Stage changes
gaa             # Add all
# or selective
ga file.js      # Add specific

# Commit with message
gcmsg "feat: add new widget"

# Or semantic commit
git feat "add new widget"
```

## Collaboration

### Pull Request Workflow

```bash
# Push to remote
gpsup

# Create PR
gh pr create

# Or web interface
gh pr create --web
```

### Code Review

```bash
# List PRs
gh pr list

# Checkout PR locally
gh pr checkout 123

# Review in editor
v .
<leader>gd      # View diffs
```

## Context Switching

### Between Projects

```bash
# Stash current work
gsta -m "WIP: feature"

# Switch project
z other-project

# Later, return and restore
z -
gstp
```

### Between Branches

```bash
# Quick switch
gco -          # Previous branch
gco main       # Main branch

# Interactive selection
fco            # Fuzzy branch selection
```

## End of Day

### Save Work State

```bash
# In Neovim
:wa            # Write all buffers
:SessionSave   # Save session

# Commit WIP if needed
gaa && gcmsg "WIP: end of day"
```

### Clean Up

```bash
# Close unnecessary buffers
:BufferLineCloseOthers

# Exit Neovim
:qa
```

### Preserve Session

```bash
# Detach tmux (keeps running)
C-a d

# Or save and exit
tmux kill-session
```

## Time-Saving Patterns

### Quick File Edits

```bash
# Find and edit
v $(fd -e py | fzf)

# Edit file with pattern
v $(rg -l "TODO")
```

### Bulk Operations

```bash
# Format all Python files
fd -e py -x black

# Update all TODOs
rg -l "TODO" | xargs sed -i '' 's/TODO/FIXME/g'
```

### Quick Searches

```bash
# Find all TODOs
todos

# Find in specific type
rg -t py "class.*Widget"

# Interactive search
rg "pattern" | fzf
```

## Productivity Tips

### Morning

1. **Update first** - Keep tools current
2. **Review yesterday** - Check git log/status
3. **Plan tasks** - Use TODO comments

### During Day

1. **Commit often** - Small, focused commits
2. **Use AI assist** - Don't struggle alone
3. **Take breaks** - Use pomodoro technique

### Evening

1. **Clean commits** - Squash/rebase if needed
2. **Document** - Update comments/docs
3. **Save state** - Session management

## Emergency Commands

### Git Recovery

```bash
# Undo last commit
git undo

# Reset to remote
groh

# Recover lost work
git reflog
```

### Process Issues

```bash
# Find and kill
fkill

# Kill port
killport 3000

# System monitor
btop
```

### Quick Fixes

```bash
# Reload shell
reload

# Fix permissions
sudo chown -R $(whoami) .

# Clear caches
rm -rf node_modules && npm i
```

---

<p align="center">
  <a href="../README.md">← Back to Workflows</a>
</p>
