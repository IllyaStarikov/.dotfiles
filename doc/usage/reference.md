# Quick Reference Card

> **Essential commands and shortcuts for daily use**

## Most Used Commands

### Navigation
```bash
z project        # Jump to project directory
cd -            # Previous directory  
..              # Up one level
ll              # List with details
lt              # Tree view
ff              # Find files interactively
```

### Git Workflow
```bash
gs              # Status
gaa             # Add all
gcmsg "fix: bug" # Commit
gp              # Push
gl              # Pull
gco -           # Previous branch
lazygit         # Visual UI
```

### Search & Edit
```bash
rg "TODO"       # Search in files
fd -e py        # Find Python files
v file.py       # Edit with Neovim
code .          # Open VS Code
```

### System
```bash
htop            # System monitor
duf             # Disk usage
theme           # Switch light/dark
update-dotfiles # Update everything
cleanup         # Clean caches
```

## Neovim Essentials

**Leader** = `Space`

### Files & Search
`<leader>ff` Find files
`<leader>fg` Grep text
`<leader>fb` Buffers
`<leader>fr` Recent

### Code Navigation  
`gd` Definition
`gr` References
`K` Documentation
`<leader>ca` Actions

### AI Assistant
`<leader>cc` Chat
`<leader>co` Optimize (visual)
`<leader>ce` Explain (visual)

### Git
`<leader>gg` LazyGit
`]c` Next change
`[c` Previous change

## tmux Commands

**Prefix** = `Ctrl-a`

### Sessions & Windows
`C-a s` List sessions
`C-a c` New window
`C-a n` Next window
`C-a ,` Rename

### Panes
`C-a |` Split vertical
`C-a -` Split horizontal
`C-h/j/k/l` Navigate
`C-a z` Zoom toggle

### Copy Mode
`C-a [` Enter
`v` Select
`y` Copy
`C-a ]` Paste

## Shell Shortcuts

### Command Line
`C-r` History search
`C-t` File picker
`ESC` Vi mode
`TAB` Complete

### Vi Mode (after ESC)
`h/l` Move left/right
`w/b` Word forward/back
`dd` Delete line
`u` Undo

## One-Liners

### Quick Tasks
```bash
# Find and edit TODO
v $(rg -l TODO | fzf)

# Update and clean
update-dotfiles && cleanup

# Git sync
gco main && gl && gco -

# New feature branch
gcb feature/name

# Search and replace
fd -e py -x sd 'old' 'new'
```

### System Info
```bash
# What's using port 3000?
lsof -i :3000

# Disk usage by directory
dust -d 1

# Network connections
netstat -an | grep LISTEN
```

## Emergency

### Recovery
```bash
# Undo last commit
git undo

# Kill process on port
killport 3000

# Reset shell
exec zsh

# Fix permissions  
sudo chown -R $(whoami) .

# Restore Neovim
rm -rf ~/.local/share/nvim
nvim +Lazy
```

### Debug
```bash
# Check health
nvim +checkhealth
brew doctor
which -a command

# Logs
tail -f log.txt
journalctl -f

# Profile performance
time command
htop
```

---

Print with: `bat doc/usage/reference.md`