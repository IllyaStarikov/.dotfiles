# Command Reference

> **Quick lookup for all command aliases and functions**

## Overview

This section provides comprehensive command references for Git, shell, and modern CLI tools. Commands are organized by category with examples for quick reference.

## Available References

### [Git Commands](git.md)
Version control aliases:
- Basic workflow commands
- Advanced operations
- Semantic branch creation
- GitHub CLI integration

### [Shell Commands](shell.md)
Zsh aliases and functions:
- Navigation shortcuts
- File operations
- System utilities
- Custom functions

### [Modern CLI Tools](modern-cli.md)
Enhanced Unix commands:
- Better alternatives (ripgrep, fd, bat)
- Performance comparisons
- Integration examples
- Configuration tips

### [Tools Comparison](tools-comparison.md)
Detailed comparisons:
- Performance benchmarks
- Feature matrices
- Use case recommendations
- Migration tips

## Most Used Commands

### Daily Workflow

```bash
# Navigation
z project        # Jump to project
ll              # List with details
ff              # Find files

# Git
gs              # Status
gaa             # Add all
gcmsg "fix: bug" # Commit
gp              # Push

# Search
rg "TODO"       # Find in files
fd .py          # Find Python files
```

### Quick Operations

```bash
# File management
mkd new-dir     # Make and enter
trash file      # Safe delete
extract arc.zip # Extract archive

# System
htop            # Process monitor
duf             # Disk usage
theme           # Switch theme
```

## Command Categories

### Navigation & Files
- Directory jumping with `z`
- Modern `ls` alternatives
- File search and manipulation

### Development
- Git workflow aliases
- Editor shortcuts
- Build and test commands

### System & Network
- Process management
- Network utilities
- System information

### Text Processing
- Search with ripgrep
- File viewing with bat
- Text manipulation

## Alias Naming Conventions

Our aliases follow consistent patterns:

### Git Aliases
- `g*` - Git commands (gs, gaa, gco)
- `gc*` - Commit related (gcmsg, gca)
- `gb*` - Branch operations (gbd, gba)
- `gp*` - Push operations (gp, gpf)

### File Operations
- Single letters for common tools (l, ll, la)
- Descriptive names for functions (mkd, trash)

### System Commands
- Short memorable names
- Fallback to full names if no conflict

## Creating Custom Aliases

Add to `~/.zshrc`:

```bash
# Simple alias
alias mycommand='actual command'

# Function for complex operations
myfunction() {
  echo "Running custom function"
  # Your code here
}

# With arguments
greet() {
  echo "Hello, $1!"
}
```

## Performance Tips

### Use Modern Tools
- `rg` over `grep` (10-100x faster)
- `fd` over `find` (more intuitive)
- `eza` over `ls` (more features)

### Combine with fzf
```bash
# Interactive selection
v $(fd -e py | fzf)
git checkout $(gb | fzf)
cd $(fd -t d | fzf)
```

### Use Aliases
Save keystrokes with common operations:
- `gaa` vs `git add --all`
- `gcmsg` vs `git commit -m`
- `z proj` vs `cd ~/1-projects/my-project`

---

<p align="center">
  <a href="../README.md">← Back to Usage</a>
</p>