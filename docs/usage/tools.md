# Modern CLI Tools

## Daily Commands

```bash
FILE OPS              TEXT SEARCH           SYSTEM
ll       List all     rg pattern  Grep      btop     Monitor
lt       Tree         fd name     Find      duf      Disk usage
z dir    Jump         fzf         Fuzzy     procs    Processes
bat      View file    ag pattern  Alt grep  bandwhich Network

REPLACEMENTS          GIT TOOLS             NETWORK
cat → bat            gh pr create           http GET url
ls  → eza            delta (git diff)       gping host
cd  → z              lazygit                curl → httpie
find → fd            tig                    speedtest-cli
grep → rg            gh issue list          ncdu (disk)
```

## Modern CLI Replacements

### eza - Modern ls

```bash
# Basic usage
l        # Simple list
ll       # Long format with details
la       # All files including hidden
lt       # Tree view
lla      # All files, detailed
llt      # Tree with hidden files

# Advanced
ll --git              # Show git status
lt -L 3              # Tree depth 3
ll -s modified       # Sort by modified time
ll --icons           # With file icons
ll --no-permissions  # Hide permissions
```

### bat - Cat with wings

```bash
# Basic usage (aliased to cat)
cat file.py          # Syntax highlighted
cat -n file.py       # With line numbers
cat -p file.py       # Plain, no decorations

# Advanced
bat --diff file.py   # Show as diff
bat -r 10:20 file.py # Show lines 10-20
bat -A file.py       # Show non-printable chars
bat --theme list     # List themes
```

### fd - User-friendly find

```bash
# Find by name
fd pattern           # Find files/dirs matching pattern
fd -e py            # Find Python files
fd -e md -e txt     # Multiple extensions
fd -t f pattern     # Files only
fd -t d pattern     # Directories only

# Advanced
fd -H pattern       # Include hidden files
fd -I pattern       # Include ignored files
fd -d 2 pattern     # Max depth 2
fd -x echo {}       # Execute command
fd -E '*.log'       # Exclude pattern
```

### ripgrep - Fast grep

```bash
# Basic search
rg pattern          # Search in current directory
rg -i pattern       # Case insensitive
rg -w pattern       # Whole words only
rg -n pattern       # Show line numbers
rg -c pattern       # Count matches

# Advanced
rg -t py "class"    # Search Python files only
rg -C 3 pattern     # 3 lines context
rg -l pattern       # Files with matches only
rg --hidden pattern # Search hidden files
rg -z pattern       # Search in compressed files
```

### fzf - Fuzzy finder

```bash
# Interactive use
fzf                 # Fuzzy find files
Ctrl+R              # Fuzzy search history
Ctrl+T              # Insert file path
Alt+C               # cd to directory

# Piped usage
vim $(fzf)          # Open fuzzy found file
kill -9 $(ps aux | fzf | awk '{print $2}')
git branch | fzf | xargs git checkout
```

### zoxide - Smarter cd

```bash
# Jump to directories
z proj              # Jump to ~/projects/something
z dow               # Jump to ~/Downloads
zi                  # Interactive selection

# Management
z -                 # Previous directory
zoxide query proj   # Show matching paths
zoxide remove path  # Remove from database
```

## Development Tools

### GitHub CLI (gh)

```bash
# Pull Requests
gh pr create        # Create PR interactively
gh pr list          # List PRs
gh pr view 123      # View PR #123
gh pr checkout 123  # Checkout PR locally
gh pr merge         # Merge PR

# Issues
gh issue create     # Create issue
gh issue list       # List issues
gh issue view 45    # View issue

# Repos
gh repo clone user/repo
gh repo fork
gh repo view --web  # Open in browser
```

### HTTPie

```bash
# Simple requests
http GET httpbin.org/get
http POST httpbin.org/post name=John age=30
http PUT httpbin.org/put file=@data.json

# Headers and auth
http GET api.github.com Authorization:"Bearer TOKEN"
http --auth user:pass GET example.com

# Download
http --download example.com/file.zip
```

### jq - JSON processor

```bash
# Pretty print
curl api.example.com | jq '.'

# Extract fields
echo '{"name":"John","age":30}' | jq '.name'

# Filter arrays
jq '.users[] | select(.age > 25)' data.json

# Transform
jq '{name: .full_name, years: .age}' data.json
```

### delta - Better git diff

```bash
# Automatic with git
git diff            # Uses delta if configured
git show            # Pretty commit view
git blame           # Enhanced blame

# Standalone
delta file1 file2   # Compare files
diff -u file1 file2 | delta
```

## System Monitoring

### htop - Interactive process viewer

```bash
htop                 # Launch monitor (aliased from 'top')

# Keys:
# q/F10  - Quit
# /      - Search process
# F5     - Tree view  
# P      - Sort by CPU%
# M      - Sort by MEM%
# k/F9   - Kill process
# Space  - Tag process
# F2     - Setup/configure
# F6     - Sort by column

# Note: Consider installing btop for more features:
# brew install btop
```

### duf - Disk usage

```bash
duf                 # Show all filesystems
duf /home          # Specific path
duf --only local   # Local filesystems only
duf --json         # JSON output
duf --theme dark   # Dark theme
```

### procs - Modern ps

```bash
procs               # List all processes
procs firefox       # Search for firefox
procs --tree        # Tree view
procs --watch       # Live updates
procs --sortd cpu   # Sort by CPU desc
```

### Network Monitoring Tools

```bash
# Built-in tools
netstat -an          # Network connections
lsof -i :3000        # Who's using port 3000
listening            # Alias: lsof -i -P | grep LISTEN
ports                # Alias: netstat -tulanp

# Speed testing
speedtest            # Internet speed test (alias)
# Uses: speedtest-cli if installed

# Network info
myip                 # Shows internal + external IP
ip                   # External IP (curl icanhazip.com)
localip              # Internal IP address
ips                  # All network interfaces

# For bandwidth monitoring:
# brew install bandwhich
# sudo bandwhich      # Real-time bandwidth usage
```

## Theme Management

### Theme Switcher

```bash
theme               # Auto-detect system theme
dark                # Force dark mode
light               # Force light mode

```

## Package Management

### Homebrew

```bash
# Package management
brew install tool   # Install package
brew uninstall tool # Remove package
brew upgrade        # Upgrade all
brew upgrade tool   # Upgrade specific
brew outdated       # List outdated

# Maintenance
brew update         # Update formulae
brew cleanup        # Remove old versions
brew doctor         # Check health
brew autoremove     # Remove unused deps

# Search and info
brew search term    # Search packages
brew info package   # Package details
brew list           # Installed packages
brew leaves         # Top-level only
brew deps package   # Dependencies
```

### Python - pyenv

```bash
# Version management
pyenv install 3.11.0     # Install Python
pyenv versions           # List installed
pyenv global 3.11.0      # Set default
pyenv local 3.10.0       # Set for project
pyenv shell 3.9.0        # Set for session

# Virtual environments
python -m venv .venv     # Create venv
source .venv/bin/activate # Activate
pip install -r requirements.txt
```

### Node.js - nvm

```bash
# Version management
nvm install --lts        # Install latest LTS
nvm install 18           # Install v18
nvm use 16              # Use v16
nvm list                # List installed
nvm alias default 18    # Set default

# Per-project
echo "18" > .nvmrc     # Project version
nvm use                 # Use .nvmrc version
```

## System Maintenance

### Update Everything Script

```bash
update              # Update everything!
```

### Cleanup Commands
```bash
cleanup             # Remove .DS_Store files
brew cleanup        # Remove old brew versions
npm cache clean     # Clear npm cache
pip cache purge     # Clear pip cache
docker system prune # Clean Docker
```

## Power Combos

### Search and Edit
```bash
# Find and edit files  
v $(fd -e py | fzf)              # Edit Python file
v $(rg -l "TODO" | fzf)          # Edit file with TODO
ff                               # Custom function: fd + fzf + preview

# Batch operations
fd -e js -x prettier --write {}  # Format all JS files
fd -e py -x black {}             # Format Python files
rg -l "old" | xargs sed -i '' 's/old/new/g'  # Replace text

# Quick searches
todos | fzf | cut -d: -f1 | xargs nvim  # Edit TODOs
```

### Git Workflows
```bash
# Interactive branch management
git branch | fzf | xargs git checkout

# Search commits
git log --oneline | fzf --preview 'git show {1}'

# Clean branches
git branch --merged | grep -v main | xargs git branch -d
```

### Process Management
```bash
# Kill process interactively
kill -9 $(procs | fzf | awk '{print $1}')

# Monitor specific process
procs --watch --tree firefox

# Port management
lsof -i :3000 | grep LISTEN
```

## Performance Tips

### Tool Selection

- rg for text search
- fd for file finding
- eza for directory listing
- bat for file viewing
- fzf for interactive selection

### Speed Tricks
```bash
# Parallel operations
fd -e py -x pylint {} \;        # Sequential
fd -e py -x pylint {} +          # Parallel

# Caching
export FZF_DEFAULT_COMMAND='fd --type f'
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
```

## Troubleshooting

### Common Issues

| Problem | Solution |
|---------|----------|
| Command not found | `brew install <tool>` |
| Slow performance | Check if using system version |
| No colors | Export `TERM=xterm-256color` |
| Icons missing | Install Nerd Font |
| Permission denied | Some tools need sudo (bandwhich) |

### Debug Commands
```bash
which tool          # Check tool location
tool --version      # Check version
brew list tool      # Check if installed via brew
echo $PATH          # Check PATH order
```

## Quick Reference

### Essential Aliases (from your config)
```bash
# File operations
ls='eza --group-directories-first'
ll='eza -l --group-directories-first --time-style=relative --git'
la='eza -la --group-directories-first --time-style=relative --git'
lt='eza --tree --level=2'
tree='eza --tree'
cat='bat --style=header,grid,numbers'
c='bat --style=header,grid,numbers'

# Navigation
z='zshz 2>&1'  # Z plugin alias

# Search
grep='rg'       # Ripgrep
find-file='fd'  # fd alias
search='rg -i --pretty --context=3'  # Smart search

# System
top='htop'
ps='procs'
df='df -H'
du='du -ch'
```

### Must-Have Tools

#### Currently Installed

1. eza - Modern ls with git integration
2. fd - Fast and user-friendly find
3. ripgrep - Blazingly fast grep
4. fzf - Fuzzy finder for everything
5. jq - JSON processor
6. gh - GitHub CLI (via Homebrew)
7. htop - Interactive process viewer
8. pyright - Python language server
9. colordiff - Colorized diff
10. procs - Modern ps replacement

#### Recommended Additions
```bash
# Essential upgrades
brew install bat          # Better cat with syntax highlighting
brew install git-delta    # Beautiful git diffs
brew install btop         # Gorgeous system monitor
brew install lazygit      # Terminal UI for git

# Productivity boosters  
brew install zoxide       # Smarter cd command
brew install duf          # Better df
brew install httpie      # Human-friendly HTTP client
brew install gping        # Ping with graph

# Development tools
brew install tig          # Text-mode git interface
brew install tldr         # Simplified man pages
```

