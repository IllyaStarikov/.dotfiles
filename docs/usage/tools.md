# Tools & Scripts Usage Guide

## Command Reference Table

### System Update Script
| Command | Action | Description |
|---------|--------|-------------|
| `update` | System update | Comprehensive system update (alias) |
| `~/src/scripts/update` | Full path | Direct script execution |
| `updateall` | Update everything | System + all package managers |

### Theme Switcher
| Command | Action | Description |
|---------|--------|-------------|
| `theme` | Auto switch | Detect and apply system theme |
| `theme dark` | Force dark | Apply dark theme |
| `theme light` | Force light | Apply light theme |
| `dark` | Dark mode | Shortcut for theme dark |
| `light` | Light mode | Shortcut for theme light |

### Modern CLI Tools
| Tool | Replaces | Description |
|------|----------|-------------|
| `eza` | `ls` | Modern file listing with git integration |
| `bat` | `cat` | Syntax highlighting and git integration |
| `fd` | `find` | Fast, user-friendly file finding |
| `rg` | `grep` | Ripgrep - ultra-fast text search |
| `htop` | `top` | Interactive process viewer |
| `procs` | `ps` | Modern process viewer |
| `delta` | `diff` | Better git diffs (optional) |

### Development Servers
| Command | Action | Description |
|---------|--------|-------------|
| `serve` | HTTP server on 8000 | Python simple HTTP server |
| `serve 3000` | Custom port | Specify different port |
| `serve8000` | Port 8000 | Alias shortcut |
| `serve3000` | Port 3000 | Alias shortcut |

### Package Management
| Command | Action | Description |
|---------|--------|-------------|
| `brew` | Homebrew (ARM) | Apple Silicon optimized |
| `ibrew` | Intel Homebrew | x86_64 compatibility |
| `mas` | App Store CLI | Mac App Store updates |

### Text Processing
| Command | Action | Description |
|---------|--------|-------------|
| `json` | JSON formatter | Pretty print JSON |
| `urlencode` | URL encode | Encode special characters |
| `urldecode` | URL decode | Decode URLs |
| `b64encode` | Base64 encode | Encode to base64 |
| `b64decode` | Base64 decode | Decode from base64 |

### Network Utilities
| Command | Action | Description |
|---------|--------|-------------|
| `ip` | External IP | Show public IP |
| `localip` | Internal IP | Show local network IP |
| `myip` | All IPs | Show both IPs |
| `speedtest` | Speed test | Test internet speed |
| `ports` | Show ports | Active network ports |
| `listening` | Listening ports | Ports accepting connections |

### System Information
| Command | Action | Description |
|---------|--------|-------------|
| `sysinfo` | System details | OS, architecture, uptime |
| `df` | Disk usage | Human readable format |
| `free` | Memory usage | VM statistics |
| `cpu` | CPU usage | Processes by CPU |
| `mem` | Memory usage | Processes by memory |

### File Operations
| Command | Action | Description |
|---------|--------|-------------|
| `cleanup` | Clean junk | Remove .DS_Store, .pyc |
| `emptytrash` | Empty trash | Clear all trash folders |
| `mkcd` | Make & enter | Create directory and cd |
| `extract` | Extract archive | Universal extraction |
| `biggest` | Large files | Find biggest files |

### Fun Utilities
| Command | Action | Description |
|---------|--------|-------------|
| `weather` | Weather info | Current weather |
| `moon` | Moon phase | Current moon phase |
| `crypto` | Crypto rates | Cryptocurrency prices |
| `chuck` | Chuck Norris | Random joke |

## System Update Script Details

### What It Updates
1. **macOS System** - Checks for OS updates
2. **Mac App Store** - Updates store apps (if mas installed)
3. **Homebrew** - Formulae and casks
4. **Neovim Plugins** - Via lazy.nvim
5. **Oh My Zsh** - Framework updates
6. **Node.js Packages** - Global npm/yarn/pnpm
7. **Python Packages** - pip3 packages
8. **Ruby Gems** - User gems only
9. **Rust Tools** - Cargo packages
10. **TeX Live** - LaTeX packages (manual)

### Update Script Features
- Handles deprecated Homebrew packages
- Continues on individual failures
- Provides status for each component
- Safe defaults (no system modifications)
- Intelligent error handling

## Theme Switcher Details

### What It Switches
1. **Alacritty** terminal colors
2. **tmux** status bar theme
3. **Environment variable** MACOS_THEME
4. **Neovim** colorscheme (via auto-detection)

### Theme Files
- Config: `~/.config/theme-switcher/current-theme.sh`
- Alacritty: `~/.config/alacritty/theme.toml`
- tmux: `~/.config/tmux/theme.conf`

### Supported Themes
- **Dark**: Dracula theme
- **Light**: Solarized Light theme
- Auto-detects macOS appearance

## Modern Tool Replacements

### eza (Enhanced ls)
**Features**:
- Git status integration
- Tree view support
- Icons (when fonts support)
- Better colors and formatting
- Human-readable sizes

**Usage**:
```bash
eza --tree --level=2 --git --long
```

### bat (Better cat)
**Features**:
- Syntax highlighting
- Git integration
- Line numbers
- Paging support
- Theme support

**Usage**:
```bash
bat --style=full --theme=Dracula file.py
```

### fd (Find alternative)
**Features**:
- Intuitive syntax
- Respects .gitignore
- Parallel execution
- Smart case
- Regular expressions

**Usage**:
```bash
fd -e py -x pytest  # Run pytest on all Python files
```

### ripgrep (rg)
**Features**:
- Blazing fast
- Respects .gitignore
- Parallel search
- Compressed file support
- Binary detection

**Usage**:
```bash
rg -t py "TODO" --context=2
```

## Quick Reference

### Essential Aliases
- File browsing: `ll`, `la`, `lt`
- Quick edit configs: `zshconfig`, `vimconfig`, `tmuxconfig`
- System maintenance: `update`, `cleanup`, `reload`
- Development: `serve`, `json`, `todos`

### Environment Tools
- Python: `pyenv` for version management
- Node: `nvm` (lazy loaded)
- Ruby: System Ruby with user gems
- Rust: `rustup` and `cargo`

### Shell Functions
Available custom functions:
- `mkcd` - Make directory and enter
- `ff` - Find files with preview
- `grep_smart` - Intelligent grep
- `git_clean_branches` - Remove merged branches
- `project` - Jump to project directory
- `serve` - Quick HTTP server

## About

This tools collection provides:
- **Modern replacements** for Unix utilities
- **Automated updates** for entire system
- **Theme coordination** across applications
- **Developer utilities** for common tasks
- **Performance tools** for system monitoring

## Additional Usage Info

### Update Strategy
The update script follows a safe approach:
- Non-destructive updates only
- Skips on errors
- Manual intervention for system updates
- Preserves user configurations
- No sudo operations (except where noted)

### Theme System Architecture
Theme switching is centralized:
1. Script detects macOS appearance
2. Generates theme configurations
3. Reloads affected applications
4. Sets environment variables
5. Notifies completion

### Tool Selection Criteria
Modern tools were chosen for:
- **Performance** - Significantly faster
- **Features** - Git awareness, colors, etc.
- **Usability** - Better defaults
- **Maintenance** - Active development
- **Integration** - Works with ecosystem

## Theory & Background

### Unix Philosophy Evolution
Modern tools respect Unix philosophy while adding:
- Better error messages
- Sensible defaults
- Color output
- Parallel processing
- User-friendly syntax

### Performance Improvements
Why modern tools are faster:
- Written in Rust/Go (compiled)
- Parallel execution
- Smarter algorithms
- Ignore unnecessary files
- Memory efficiency

### Update Automation
Automated updates balance:
- Convenience vs. stability
- Speed vs. safety
- Automation vs. control
- Coverage vs. complexity

## Good to Know / Lore / History

### Tool Migration Timeline
- 2015: Switched from `ack` to `ag`
- 2017: Adopted `ripgrep` over `ag`
- 2019: Replaced `ls` with `exa` (now `eza`)
- 2020: `bat` replaced `cat`
- 2021: `fd` replaced `find`
- 2023: Full modern stack adoption

### Why These Tools?
Each tool was selected after extensive testing:
- Must be 3x+ faster than original
- Backward compatibility important
- Active community required
- Cross-platform support preferred

### Hidden Features

1. **eza**: Can show file permissions as octal
2. **bat**: Can be used as `MANPAGER`
3. **fd**: Supports arbitrary command execution
4. **rg**: Can search compressed files
5. **htop**: Has vim keybindings
6. **procs**: Shows Docker container names

### Integration Benefits

**Shell Prompt**:
- Shows git status via eza
- Indicates background jobs
- Displays command duration

**Editor Integration**:
- fd powers file finding
- rg powers code search
- bat provides preview

**Git Integration**:
- delta for better diffs
- eza shows git status
- bat shows git changes

### Performance Benchmarks

Typical improvements:
- `fd` vs `find`: 5-10x faster
- `rg` vs `grep`: 10-20x faster
- `eza` vs `ls`: 2-3x faster
- `bat` vs `cat`: Similar (adds features)

### Pro Tips

1. **Chain tools**: `fd -e md | xargs rg TODO`
2. **Use aliases**: Muscle memory stays same
3. **Learn flags**: Each tool has powerful options
4. **Preview everything**: `bat` for file preview
5. **Parallel execution**: Many tools support `-j`
6. **Respect gitignore**: Default for most tools
7. **Custom ignore**: `.fdignore`, `.rgignore`
8. **Export findings**: Tools support various formats

### Troubleshooting

Common issues:
- **Fonts**: Install Nerd Fonts for icons
- **Colors**: Check `TERM` variable
- **Performance**: Disable icons if slow
- **Updates fail**: Check network/permissions
- **Theme mismatch**: Run theme command again