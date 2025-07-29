# Zsh Commands

## Daily Commands

```bash
NAVIGATION              FILE OPS               GIT ESSENTIALS
z proj    Jump to dir   ll       List detail   gs       Status
cd -      Previous      la       List all      gaa      Add all
..        Up one        lt       Tree view     gcmsg    Commit
...       Up two        mkd      mkdir + cd    gp       Push
1         ~/1-projects  f        Quick find    gl       Pull

SYSTEM                  PRODUCTIVITY           SEARCH
update    Update all    c        Clear screen  rg       Ripgrep
reload    Reload shell  q        Exit          fd       Find files
ports     Show ports    extract  Any archive   fzf      Fuzzy find
myip      IP address    v        Neovim        ag       Silver search
cleanup   Clean DS      h        History       grep     Colored grep
```

## Oh My Zsh Configuration

### Loaded Plugins

| Plugin | Features | Key Commands |
|--------|----------|--------------|
| git | 150+ git aliases | `gs`, `gco`, `gaa`, `gcm` |
| z | Frecency navigation | `z project`, `z -`, `z downloads` |
| vi-mode | Vim bindings in shell | `ESC` for normal mode, `i` insert |
| history-substring-search | Smart history | `↑`/`↓` for substring search |
| extract | Universal extraction | `extract file.zip/tar/7z/rar` |
| brew | Homebrew completions | Tab completion for brew commands |
| python | Python helpers | Virtual env detection |
| node | Node.js utilities | NVM lazy loading |
| docker | Docker completions | Full docker/compose completion |
| colored-man-pages | Colored manuals | Automatic coloring |
| command-not-found | Package suggestions | Auto-suggest missing commands |
| macos | macOS utilities | `ofd` open Finder, `pfd` print path |

### Spaceship Prompt

```
╭─ user@host ~/.dotfiles on  main [!?] via 🐍 v3.11 🦀 v1.70 ⬢ v18.0 took 2s
╰─λ
```

## Smart Navigation

### Z Plugin Directory Jumping

```bash
z proj              # Jump to most frecent ~/*/project*
z down              # Jump to ~/Downloads
z dot               # Jump to ~/.dotfiles
z -l                # List frecent directories
```

### Quick Directory Access
```bash
# Numbered directories (custom aliases)
1    # cd ~/1-projects
2    # cd ~/2-work  
3    # cd ~/3-personal
4    # cd ~/4-archive
5    # cd ~/5-temp

# Common locations
dl   # cd ~/Downloads
dt   # cd ~/Desktop
doc  # cd ~/Documents

# Relative navigation  
-    # Previous directory (cd -)
..   # Parent directory
...  # Up 2 levels
.... # Up 3 levels
```

## File Operations

### Modern ls Replacement (eza)
```bash
l     # Simple list
ll    # Long format with git status
la    # All files including hidden
lt    # Tree view
lla   # All files, long format
llt   # Tree with all files

# Examples:
ll --git-ignore    # Respect .gitignore
lt -L 2           # Tree depth 2
ll -s size        # Sort by size
```

### Enhanced Commands
```bash
# bat (better cat)
cat file.txt      # Aliased to bat with syntax highlighting
less file.txt     # Also uses bat as pager

# Quick operations
mkd folder        # Create and enter directory
trash file        # Safe delete (aliased to rm)
cp -r             # Always recursive (aliased)
df                # Human readable disk usage
du                # Human readable directory sizes
```

## Git Workflow

### Essential Git Aliases

| Alias | Command | Alias | Command |
|-------|---------|---------|---------|
| `g` | git | `gs` | git status |
| `gaa` | git add --all | `ga` | git add |
| `gcm` | git commit -m | `gc` | git commit |
| `gp` | git push | `gpl` | git pull |
| `gco` | git checkout | `gcb` | git checkout -b |
| `gd` | git diff | `gdc` | git diff --cached |
| `gl` | Beautiful git log | `glo` | Oneline graph all |
| `gb` | git branch | `gba` | git branch -a |
| `gm` | git merge | `gr` | git rebase |
| `gf` | git fetch | `gca` | git commit --amend |

### Advanced Git
```bash
# Stashing
gsta              # git stash
gstp              # git stash pop
gstl              # git stash list
gstd              # git stash drop

# Rebasing
grbi              # git rebase -i
grbc              # git rebase --continue
grba              # git rebase --abort

# Reset/Recovery
grhh              # git reset --hard HEAD
grhh~1            # git reset --hard HEAD~1
gclean            # git clean -fd

# GitHub
gpsup             # git push --set-upstream origin HEAD
gfa               # git fetch --all --prune
```

### Semantic Commit Helpers
```bash
git feat "message"     # Creates: feat: message
git fix "message"      # Creates: fix: message
git docs "message"     # Creates: docs: message
git style "message"    # Creates: style: message
git refactor "msg"     # Creates: refactor: msg
git test "message"     # Creates: test: message
git chore "message"    # Creates: chore: message
```

## Power Search

### Ripgrep Integration
```bash
rg "pattern"           # Search in current directory
rg -i "pattern"        # Case insensitive
rg -t py "class"       # Search only Python files
rg -C 3 "error"        # Show 3 lines context
rg --hidden "config"   # Include hidden files
```

### fd (find replacement)
```bash
fd name               # Find files/dirs named "name"
fd -e py             # Find all Python files
fd -H config         # Include hidden files
fd -t d node         # Find directories only
fd -x chmod +x       # Execute command on results
```

### fzf Integration
```bash
Ctrl+R               # Fuzzy search command history
Ctrl+T               # Fuzzy find files
Alt+C                # Fuzzy change directory
**<Tab>              # Trigger fzf completion

# Custom fzf commands
fkill                # Fuzzy kill processes
fbr                  # Fuzzy git branch checkout
fshow                # Fuzzy git show commits
```

## Custom Functions

### Productivity Boosters
```bash
# Create directory and cd into it
mkcd my-project      # mkdir -p my-project && cd my-project
mkdir_cd folder      # Full function name

# Extract any archive (via plugin)
extract file.zip     # Works with .zip .tar .gz .bz2 .rar .7z etc

# File finding with preview
ff                   # fd + fzf + bat preview

# Smart search
search "pattern"    # ripgrep with FZF interface
grep_smart "term"   # Full function name

# Quick navigation
project name         # cd to ~/Projects/name or ~/projects/name
```

### System Utilities

```bash
# Network
myip                 # Internal + external IP
ip                   # External IP
localip              # Internal IP
ips                  # All network IPs
speedtest            # Internet speed test

# Port monitoring
ports                # netstat -tulanp
listening            # lsof -i -P | grep LISTEN

# Cleanup
cleanup              # Remove .DS_Store files
emptytrash           # Empty trash
reset                # Reload + clear
reload               # Reload zshrc

# Updates
update               # Brew update
updateall            # All package managers
```

## Environment Management

### Path Management

```bash
# Custom paths added:
$PYENV_ROOT/bin
/opt/homebrew/bin
/opt/homebrew/sbin
$HOME/.local/bin
$HOME/.scripts
$GOPATH/bin
~/.cargo/bin
```

### Version Managers

```bash
# pyenv (Python)
pyenv versions       # List installed
pyenv local 3.11     # Set for project
pyenv global 3.11    # Set system default
pyenv install -l     # List available versions

# nvm (Node.js) - Lazy loaded
nvm                  # First use loads NVM
node/npm/npx         # Also trigger NVM load
nvm list            # List installed
nvm use 18          # Use Node v18
nvm install --lts   # Install latest LTS

# Rust
rustup update       # Update toolchain
cargo --version     # Check version
```

## Vi Mode

### Enabled Vi Bindings
```bash
ESC         # Enter normal mode (KEYTIMEOUT=1 for fast switch)
i           # Insert mode
v           # Visual mode (in normal)
/           # Search forward
?           # Search backward
n/N         # Next/previous match
dd          # Delete line
yy          # Yank line
p           # Paste
u           # Undo

# History search in vi mode
k           # Previous command (normal mode)
j           # Next command (normal mode)
```

### Mode Indicators
- **INSERT**: `[λ]` lambda symbol
- **NORMAL**: `[µ]` mu symbol  
- Visual feedback via Spaceship prompt


## Pro Tips

### Shell Magic
```bash
# Last command substitution
!!          # Repeat last command
sudo !!     # Repeat with sudo
!$          # Last argument of previous command
!^          # First argument of previous command
!*          # All arguments of previous command
!-2         # Command from 2 commands ago

# Directory stack (AUTO_PUSHD enabled)
cd -        # Previous directory
dirs -v     # Show directory stack
~2          # Go to stack position 2
pushd path  # Push and change directory
popd        # Pop and change directory

# Smart correction (CORRECT_ALL enabled)
# Zsh will suggest corrections for typos!
```

### Expansion Tricks
```bash
# Brace expansion
mkdir -p project/{src,test,docs}
touch file{1..10}.txt
cp file.{txt,bak}

# Parameter expansion
${VAR:-default}     # Use default if unset
${VAR:=default}     # Set and use default
${VAR:?error}       # Error if unset
${#VAR}             # Length of variable
```

### History Power
```bash
# Smart history search
Ctrl+R              # Fuzzy search with fzf
↑/↓ arrows         # Substring search (via plugin)
Ctrl+P/Ctrl+N       # Also substring search
history | grep cmd  # Traditional search
!523                # Execute command 523
!git:p              # Print last git command

# History settings (from config)
HISTSIZE=50000      # In-memory history
SAVEHIST=50000      # On-disk history  
HIST_STAMPS="mm/dd/yyyy"  # Timestamps

# Active history options:
- EXTENDED_HISTORY (timestamps)
- HIST_IGNORE_ALL_DUPS (no duplicates)
- HIST_IGNORE_SPACE (ignore space-prefixed)
- HIST_VERIFY (preview ! expansions)
```

## Configuration

### Key Files
- `~/.zshrc` - Main configuration
- `~/.dotfiles/src/zsh/aliases.zsh` - All aliases
- `~/.dotfiles/src/zsh/functions.zsh` - Custom functions
- `~/.oh-my-zsh/` - Oh My Zsh installation
- `~/.config/starship.toml` - Prompt config (if using Starship)

### Configuration & Customization
```bash
# Key files
~/.zshrc                              # Main config (symlinked)
~/.dotfiles/src/zsh/aliases.zsh      # All aliases (250+)
~/.dotfiles/src/zsh/functions.zsh    # Custom functions  
~/.oh-my-zsh/                         # Oh My Zsh directory
~/.config/theme-switcher/             # Theme settings

# Quick edits
v ~/.zshrc          # Edit main config
v ~/.dotfiles/src/zsh/aliases.zsh    # Edit aliases
reload              # Apply changes

# Theme management  
theme               # Run theme switcher
dark                # Force dark mode
light               # Force light mode
echo $MACOS_THEME   # Current theme
```

## Troubleshooting

### Common Issues

| Problem | Solution |
|---------|----------|
| Slow startup | Check `zsh -xvfd` for bottlenecks |
| Command not found | Run `rehash` or check PATH |
| Completion issues | Run `rm -rf ~/.zcompdump*` |
| Theme not loading | Ensure `oh-my-zsh` is installed |
| Git status slow | Check large repos, use `git config oh-my-zsh.hide-dirty 1` |

### Debug Commands
```bash
which command       # Find command location
type command        # Show command type/definition
env | grep PATH     # Check PATH variable
zsh --version       # Check zsh version
echo $0             # Confirm using zsh
```

### Recovery
```bash
# Reset to defaults
mv ~/.zshrc ~/.zshrc.bak
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

# Clean start
rm -rf ~/.zcompdump*
rm -rf ~/.zsh_sessions
exec zsh
```

## Advanced Features

### Completion System

- Menu selection
- Case-insensitive matching
- Fuzzy matching
- Colored completions
- Smart caching
- Process completions
- Git completions
- Docker completions

### Architecture-Specific

```bash
# Apple Silicon optimizations
brew       # Aliased to arch -arm64 brew
pyenv      # Aliased to arch -arm64 pyenv
ibrew      # Intel brew (arch -x86_64)
```

## Theme Integration

### Automatic Theme Switching

```bash
theme              # Auto-detect macOS appearance
dark               # Force dark mode  
light              # Force light mode
$MACOS_THEME       # Current theme variable
```

### Custom Functions Reference
```bash
# Productivity
mkcd/mkdir_cd      # Create and enter directory
ff                 # Fuzzy file finder
search/grep_smart  # Smart ripgrep with FZF
project            # Quick project navigation
serve              # Python HTTP server

# System info
sysinfo            # Full system details
myip               # Internal + external IP
git_clean_branches # Clean merged branches

# Development
pyenv init         # Python environment
nvm (lazy)         # Node version manager
cargo              # Rust toolchain
```

