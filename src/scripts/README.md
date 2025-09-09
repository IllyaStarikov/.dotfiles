# 🛠️ /src/scripts - Utility Scripts

> **Power tools for productivity** - Custom scripts that automate everything

A collection of battle-tested utility scripts that make daily development tasks effortless. From universal code formatting to intelligent theme switching, these tools embody the "automate everything" philosophy.

## 🎯 Script Overview

| Script | Purpose | Usage |
|--------|---------|-------|
| **[fixy](#fixy)** | Universal code formatter (20+ languages) | `fixy file.py` |
| **[theme](#theme)** | Unified theme switcher | `theme dark` |
| **[update-dotfiles](#update-dotfiles)** | Update entire system | `update` |
| **[tmux-utils](#tmux-utils)** | tmux status utilities | `tmux-utils battery` |
| **[scratchpad](#scratchpad)** | Quick temp file editor | `scratchpad` |
| **[extract](#extract)** | Universal archive extractor | `extract file.tar.gz` |
| **[fetch-quotes](#fetch-quotes)** | Inspirational quotes | `fetch-quotes` |
| **[fallback](#fallback)** | Command fallback handler | Internal use |
| **[install-ruby-lsp](#install-ruby-lsp)** | Ruby LSP installer | `install-ruby-lsp` |
| **[common.sh](#commonsh)** | Shared utilities library | Sourced by other scripts |

## 📁 Directory Structure

```
scripts/
├── 🔧 fixy              # Universal formatter (34KB, 631-line config)
├── 🎨 theme             # Theme switcher (8.8KB)
├── 🔄 update-dotfiles   # System updater (20KB)
├── 📊 tmux-utils        # Status bar tools (13KB)
├── 📝 scratchpad        # Temp file creator (1KB)
├── 📦 extract           # Archive extractor (913B)
├── 💬 fetch-quotes      # Quote fetcher (4KB)
├── 🔀 fallback          # Fallback handler (3.1KB)
├── 💎 install-ruby-lsp  # Ruby LSP setup (2KB)
├── 📚 common.sh         # Shared library (12KB)
└── ⚙️ .formatrc         # Format config (1.3KB)
```

## 🚀 Key Scripts

### fixy
**The Universal Code Formatter** - One command to format any file

```bash
# Basic usage
fixy file.py              # Auto-detect and format
fixy *.js                 # Format multiple files
fixy --all src/           # Format with normalizations
fixy --check file.rs      # Check without modifying
fixy --dry-run file.go    # Preview changes
```

**Features:**
- 🎯 **20+ languages** supported via priority system
- ⚡ **Parallel processing** with CPU core detection
- 🔧 **Smart fallbacks** - tries multiple formatters
- 📝 **Normalizations** - fixes quotes, whitespace, tabs
- 🎨 **Config-driven** via `/config/fixy.json`

**Supported Languages:**
Python, JavaScript, TypeScript, Go, Rust, C/C++, Java, Ruby, Lua, Shell, YAML, JSON, Markdown, HTML, CSS, SQL, Swift, Kotlin, Perl, and more!

### theme
**Intelligent Theme Switcher** - Synchronize themes across all applications

```bash
theme              # Auto-detect from macOS appearance
theme dark         # Force dark mode
theme light        # Force light mode
theme night        # TokyoNight Night variant
theme moon         # TokyoNight Moon variant
theme storm        # TokyoNight Storm variant
theme day          # TokyoNight Day variant
```

**Synchronizes:**
- Neovim colorscheme
- Alacritty terminal
- WezTerm terminal
- Kitty terminal
- tmux status bar
- Starship prompt
- bat syntax highlighter
- delta diff viewer

### update-dotfiles
**System-Wide Updater** - Keep everything current with one command

```bash
update             # Update everything
update --brew      # Only Homebrew packages
update --nvim      # Only Neovim plugins
update --zsh       # Only Zsh plugins
update --tmux      # Only tmux plugins
```

**Updates:**
- 📦 Homebrew packages and casks
- 🌙 Neovim plugins via lazy.nvim
- 🐚 Zsh plugins via Zinit
- 💻 tmux plugins via TPM
- 🐍 Python packages via pip
- 📝 Language servers
- 🔧 System tools

### tmux-utils
**tmux Status Bar Utilities** - System monitoring for tmux

```bash
tmux-utils battery     # Battery percentage and status
tmux-utils cpu         # CPU usage
tmux-utils memory      # Memory usage
tmux-utils network     # Network status
tmux-utils weather     # Weather info
```

**Features:**
- 🔋 Smart battery icons based on percentage
- 📊 Real-time CPU monitoring
- 💾 Memory usage with smart units
- 🌐 Network connectivity status
- 🌤️ Weather integration

### scratchpad
**Quick Temporary File Editor** - For when you need to jot something down

```bash
scratchpad             # Open temp file in Neovim
scratchpad --keep      # Don't delete after editing
scratchpad notes.md    # Use custom filename
```

**Features:**
- 📝 Opens in Neovim instantly
- 🗑️ Auto-cleanup (unless --keep)
- 📁 Organized in ~/tmp/scratch/
- 🕒 Timestamped filenames

### extract
**Universal Archive Extractor** - Extract anything with one command

```bash
extract file.tar.gz    # Extract any archive
extract file.zip       # Auto-detect format
extract file.7z        # Handles 20+ formats
```

**Supported Formats:**
`.tar.gz`, `.tar.bz2`, `.tar.xz`, `.zip`, `.rar`, `.7z`, `.gz`, `.bz2`, `.xz`, `.tar`, `.tgz`, `.tbz2`, `.Z`, `.deb`, `.rpm`, `.jar`, `.war`, `.ear`, `.sar`, `.iso`

### fetch-quotes
**Inspirational Quote Fetcher** - Start your day with motivation

```bash
fetch-quotes           # Random quote
fetch-quotes --tech    # Tech quotes
fetch-quotes --zen     # Zen quotes
```

**Sources:**
- Programming wisdom
- Zen koans
- Tech leader quotes
- Unix philosophy

### fallback
**Command Fallback Handler** - Gracefully handle missing commands

Used internally by other scripts to provide fallbacks when tools aren't installed.

```bash
# Internal usage example
fallback rg grep "pattern" files
# Uses ripgrep if available, falls back to grep
```

### install-ruby-lsp
**Ruby Language Server Installer** - Set up Ruby development

```bash
install-ruby-lsp       # Install solargraph and dependencies
install-ruby-lsp --force  # Reinstall even if present
```

### common.sh
**Shared Utilities Library** - Functions used across all scripts

**Provides:**
- 🎨 Color output functions
- 📝 Logging utilities
- ✅ Command checking
- 🔍 Platform detection
- 📊 Progress indicators
- ⚠️ Error handling

## 🔧 Configuration

### .formatrc
Format configuration file with language-specific settings:
```bash
# Python formatting
python_formatter="ruff"
python_args="format --line-length 88"

# JavaScript formatting
js_formatter="prettier"
js_args="--write"
```

### Integration with fixy.json
The main formatter configuration at `/config/fixy.json`:
- Priority-based formatter selection
- Language detection patterns
- Normalization rules
- Parallel processing settings

## 🚀 Usage Examples

### Daily Workflow
```bash
# Start your day
theme                  # Set theme based on time/preference
fetch-quotes           # Get inspired
update                 # Update everything

# During development
fixy --all src/        # Format all source files
scratchpad             # Quick notes
tmux-utils battery     # Check battery in tmux

# File management
extract download.tar.gz # Extract archive
```

### Automation
```bash
# Add to crontab for daily updates
0 9 * * * /usr/bin/zsh -c "source ~/.zshrc && update --quiet"

# Auto-format on git commit (via hook)
fixy --check $(git diff --cached --name-only)
```

## 🧪 Testing

Each script can be tested:
```bash
# Test individual script
./test/test unit/scripts/fixy
./test/test unit/scripts/theme

# Test all scripts
./test/test functional/scripts
```

## 🔒 Security

- **No credentials** stored in scripts
- **Safe extraction** - validates archives before extracting
- **Atomic operations** - theme switching uses lockfiles
- **Input validation** - all user input sanitized

## 📈 Performance

| Script | Typical Runtime | Notes |
|--------|----------------|-------|
| fixy | < 100ms per file | Parallel for multiple files |
| theme | < 500ms | Atomic switching |
| update | 1-5 minutes | Depends on pending updates |
| scratchpad | < 50ms | Instant open |
| extract | Varies | Depends on archive size |

## 🎯 Best Practices

1. **Use fixy for all formatting** - Consistent across languages
2. **Run update weekly** - Keep tools current
3. **Let theme auto-detect** - Follows system preference
4. **Check battery via tmux-utils** - Integrated in status bar

## 🔄 Adding New Scripts

1. Create script in `/src/scripts/`
2. Make executable: `chmod +x script-name`
3. Add to PATH via symlinks
4. Document in this README
5. Add tests in `/test/unit/scripts/`

## 💡 Tips & Tricks

```bash
# Format all Python files in project
find . -name "*.py" | xargs fixy

# Quick note-taking workflow
alias note='scratchpad --keep'

# Check all system stats
for util in battery cpu memory network; do
  echo "$util: $(tmux-utils $util)"
done

# Extract multiple archives
for archive in *.tar.gz; do
  extract "$archive"
done
```

## 🐛 Troubleshooting

### fixy not formatting
- Check formatter is installed: `which <formatter>`
- Verify language detection: `fixy --dry-run file`
- Check config: `cat /config/fixy.json`

### theme not switching
- Verify applications are running
- Check lockfile: `ls /tmp/theme-switch.lock`
- Manual override: `theme --force dark`

### update failing
- Check network connection
- Verify credentials for private repos
- Run with verbose: `update --verbose`

## 📚 See Also

- [Main Scripts Documentation](../../doc/scripts/)
- [Fixy Configuration](/config/fixy.json)
- [Theme System](../theme-switcher/README.md)
- [Shell Aliases](../zsh/aliases.zsh)

---

<div align="center">

**[⬆ Back to /src](../README.md)**

Each script is a tool in your productivity arsenal - use them wisely! 🚀

</div>