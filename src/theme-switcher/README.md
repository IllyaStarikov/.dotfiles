# 🎨 Theme Switcher

Intelligent theme synchronization system that keeps all terminal applications visually consistent. Automatically detects macOS appearance changes and provides manual theme switching with atomic operations.

## ✨ Features

### 🎯 Unified Theme Management
- **Single Command**: Switch all applications at once
- **Atomic Operations**: Crash-proof switching with proper locking
- **Auto-detection**: Syncs with macOS dark/light mode automatically
- **Session Preservation**: tmux sessions reload themes without disruption

### 🌈 Supported Applications
- **Alacritty**: Terminal emulator theming
- **WezTerm**: Modern terminal configuration
- **Kitty**: GPU-accelerated terminal theming
- **tmux**: Status bar and window styling
- **Starship**: Cross-shell prompt theming
- **Neovim**: Editor theme synchronization (via environment)

### 🎨 TokyoNight Theme Variants
- **Day**: Light theme for daytime coding
- **Night**: Classic dark blue theme
- **Moon**: Darker variant with purple tints  
- **Storm**: Balanced dark theme (default)

## 🚀 Quick Start

### Automatic (macOS Integration)
```bash
# Theme automatically changes with macOS appearance
# No action needed - runs on system appearance change
```

### Manual Theme Switching
```bash
# Quick shortcuts
theme day       # Light theme (tokyonight_day)
theme night     # Dark blue theme (tokyonight_night)
theme moon      # Dark purple theme (tokyonight_moon)
theme storm     # Balanced dark theme (tokyonight_storm)

# Automatic detection
theme           # Auto-detect from macOS appearance

# Generic names
theme light     # Use default light theme (day)
theme dark      # Use default dark theme (storm)
```

## 📁 Directory Structure

```
src/theme-switcher/
├── switch-theme.sh             # Main theme switching script
├── validate-themes.sh          # Theme integrity checker
├── themes/                     # Theme definitions
│   ├── tokyonight_day/         # Light theme variant
│   │   ├── alacritty.toml     # Alacritty colors
│   │   ├── wezterm.lua        # WezTerm theme
│   │   ├── kitty.conf         # Kitty colors
│   │   ├── tmux.conf          # tmux status styling
│   │   └── starship.toml      # Starship prompt colors
│   ├── tokyonight_night/       # Classic dark theme
│   ├── tokyonight_moon/        # Dark purple variant
│   └── tokyonight_storm/       # Balanced dark (default)
└── README.md                   # This documentation
```

## 🔧 Core Scripts

### switch-theme.sh - Main Theme Engine

The heart of the theme system that handles all switching operations.

**Features:**
- 🔍 **Auto-detection**: Reads macOS appearance preference
- ⚡ **Atomic switching**: All applications change simultaneously  
- 🔒 **Crash protection**: File locking prevents corruption
- 📝 **Comprehensive logging**: Detailed operation logs
- 🔄 **Session reload**: tmux sessions update without restart

**Usage:**
```bash
# Basic theme switching
./switch-theme.sh day           # Light theme
./switch-theme.sh storm         # Dark theme
./switch-theme.sh               # Auto-detect

# Full theme names
./switch-theme.sh tokyonight_day
./switch-theme.sh tokyonight_storm

# Options
./switch-theme.sh --help        # Show help
./switch-theme.sh --list        # List themes
```

**Generated Configuration Files:**
- `~/.config/alacritty/theme.toml` - Alacritty color scheme
- `~/.config/wezterm/theme.lua` - WezTerm theme configuration
- `~/.config/kitty/theme.conf` - Kitty terminal colors
- `~/.config/tmux/theme.conf` - tmux status bar styling
- `~/.config/starship/theme.toml` - Starship prompt colors
- `~/.config/theme-switcher/current-theme.sh` - Environment variables

### validate-themes.sh - Theme Validator

Ensures theme integrity and consistency across all applications.

**Features:**
- ✅ **File validation**: Checks all theme files exist
- 🎨 **Color verification**: Validates color format consistency
- 📊 **Completeness check**: Ensures all applications covered
- 🐛 **Error reporting**: Detailed validation feedback

**Usage:**
```bash
./validate-themes.sh           # Validate all themes
./validate-themes.sh day       # Validate specific theme
```

## 🎨 Theme Configuration

### Theme Definition Structure

Each theme contains configuration files for all supported applications:

```bash
themes/tokyonight_day/
├── alacritty.toml     # Terminal colors and styling
├── wezterm.lua        # WezTerm theme configuration  
├── kitty.conf         # Kitty color scheme
├── tmux.conf          # Status bar colors and style
└── starship.toml      # Prompt colors and symbols
```

### Color Palette System

All themes use consistent color naming:

```toml
# Example color definitions (alacritty.toml)
[colors.primary]
background = "#1a1b26"    # Main background
foreground = "#c0caf5"    # Main text color

[colors.normal]
black   = "#15161e"       # Terminal black
red     = "#f7768e"       # Error/danger
green   = "#9ece6a"       # Success/git add
yellow  = "#e0af68"       # Warning/modified
blue    = "#7aa2f7"       # Info/directory
magenta = "#bb9af7"       # Special/keyword
cyan    = "#7dcfff"       # String/comment
white   = "#a9b1d6"       # Normal text
```

### Theme Customization

**Adding New Themes:**
1. Create new directory in `themes/`
2. Add configuration files for all applications
3. Follow existing color scheme patterns
4. Run validation script

**Modifying Existing Themes:**
```bash
# Edit theme files directly
nvim themes/tokyonight_storm/alacritty.toml

# Validate changes
./validate-themes.sh tokyonight_storm

# Apply changes
theme storm
```

## 🔄 Integration Points

### macOS Appearance Detection

Automatic theme switching based on system appearance:

```bash
# Check current macOS appearance
defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light"

# Auto-switch on appearance change (handled by OS)
theme  # Detects and applies appropriate theme
```

### Shell Integration

Theme state is available to shell and applications:

```bash
# Current theme environment (generated automatically)
~/.config/theme-switcher/current-theme.sh

# Contains variables like:
export CURRENT_THEME="tokyonight_storm"
export THEME_TYPE="dark"
export MACOS_THEME="storm"
```

### Application-Specific Integration

**Alacritty:**
```toml
# ~/.config/alacritty/alacritty.toml
import = ["~/.config/alacritty/theme.toml"]
```

**tmux:**
```bash
# ~/.tmux.conf  
source-file ~/.config/tmux/theme.conf
```

**Starship:**
```toml
# ~/.config/starship.toml
format = "[$all]()"
add_newline = true

# Theme-specific prompt loaded automatically
```

**Neovim:**
```lua
-- Reads MACOS_THEME environment variable
vim.g.tokyonight_style = os.getenv("MACOS_THEME") or "storm"
```

### Workflow Integration

**Git Hooks Integration:**
```bash
# Pre-commit hook can validate themes
#!/bin/bash
if [[ -f "src/theme-switcher/validate-themes.sh" ]]; then
    ./src/theme-switcher/validate-themes.sh
fi
```

**CI/CD Integration:**
```yaml
# GitHub Actions workflow
- name: Validate Themes
  run: ./src/theme-switcher/validate-themes.sh
```

## ⚡ Performance & Safety

### Atomic Operations

Theme switching uses atomic file operations to prevent corruption:

```bash
# Process:
1. Create temporary files with new theme
2. Acquire file lock
3. Atomically move files to final locations  
4. Reload applications
5. Release lock
```

### Performance Optimizations

- **Caching**: Theme files cached to avoid repeated I/O
- **Background reloading**: tmux sessions reload in background
- **Minimal file writes**: Only write files that actually changed
- **Lock optimization**: Fine-grained locking for specific operations

### Safety Features

- 🔒 **File locking**: Prevents concurrent theme switches
- 💾 **Backup creation**: Original files backed up before changes
- ✅ **Validation**: Theme files validated before application
- 🔄 **Rollback support**: Can revert to previous theme on failure

## 📊 Usage Examples

### Development Workflow

```bash
# Morning routine (switch to light theme)
theme day

# Focus mode (minimal dark theme)  
theme moon

# Evening coding (balanced dark theme)
theme storm

# Presentation mode (high contrast)
theme night
```

### Automated Switching

```bash
# Add to shell profile for time-based switching
if [[ $(date +%H) -gt 18 || $(date +%H) -lt 7 ]]; then
    theme storm    # Dark theme for evening/night
else
    theme day      # Light theme for daytime
fi
```

### Application-Specific Testing

```bash
# Test theme in specific applications
theme storm
alacritty -e nvim    # Test in Alacritty + Neovim
wezterm              # Test in WezTerm
kitty               # Test in Kitty
```

## 🔧 Advanced Configuration

### Environment Variables

Control theme behavior via environment variables:

```bash
# Override default themes
export THEME_LIGHT="tokyonight_day"
export THEME_DARK="tokyonight_storm"

# Debug mode
export THEME_DEBUG=1

# Custom theme directory
export THEME_DIR="/custom/themes"

# Disable automatic detection
export THEME_AUTO_DETECT=false
```

### Custom Theme Creation

**1. Create Theme Directory:**
```bash
mkdir themes/custom_theme
```

**2. Create Configuration Files:**
```bash
# Copy from existing theme as template
cp themes/tokyonight_storm/* themes/custom_theme/

# Customize colors in each file
nvim themes/custom_theme/alacritty.toml
nvim themes/custom_theme/tmux.conf
# ... etc
```

**3. Validate and Test:**
```bash
./validate-themes.sh custom_theme
theme custom_theme
```

### Integration with Other Tools

**VS Code Integration:**
```json
{
  "workbench.colorTheme": "Tokyo Night Storm",
  "terminal.integrated.defaultProfile.osx": "zsh"
}
```

**Zellij Integration:**
```kdl
// ~/.config/zellij/config.kdl
theme "tokyo-night-storm"
```

## 📝 Logging & Debugging

### Log Files

Comprehensive logging for troubleshooting:

```bash
# Main log file
~/.cache/theme-switcher/theme-switch.log

# View recent activity
tail -f ~/.cache/theme-switcher/theme-switch.log

# Debug specific theme switch
THEME_DEBUG=1 theme storm
```

### Debug Mode

Enable detailed debugging output:

```bash
# Method 1: Environment variable
THEME_DEBUG=1 theme storm

# Method 2: Direct script execution
DEBUG=1 ./switch-theme.sh storm

# Method 3: Shell debugging
set -x
theme storm
set +x
```

### Common Issues

**Theme Not Applying:**
```bash
# Check current theme
cat ~/.config/theme-switcher/current-theme.sh

# Verify file permissions
ls -la ~/.config/*/theme.*

# Reload applications manually
tmux source ~/.tmux.conf
```

**Colors Appear Wrong:**
```bash
# Check terminal color support
echo $COLORTERM                    # Should be "truecolor"
tput colors                        # Should be 256 or higher

# Test color output
theme storm && echo -e "\033[31mRed\033[0m \033[32mGreen\033[0m"
```

**Performance Issues:**
```bash
# Check for file locks
ls -la /tmp/.theme-switch-*

# Clear cache
rm -rf ~/.cache/theme-switcher

# Restart theme system
theme storm
```

## 🧪 Testing & Validation

### Theme Validation

```bash
# Validate all themes
./validate-themes.sh

# Validate specific theme
./validate-themes.sh tokyonight_day

# Check theme completeness
./validate-themes.sh --check-completeness
```

### Visual Testing

```bash
# Test color output
theme storm
echo -e "\033[31m■\033[32m■\033[33m■\033[34m■\033[35m■\033[36m■\033[0m"

# Test in different applications
theme day
alacritty -e 'echo "Testing Alacritty"; sleep 2'
wezterm start -- echo "Testing WezTerm"
```

### Automated Testing

```bash
# Run theme system tests
~/.dotfiles/test/test functional/theme-switcher

# Quick validation
theme --list | grep -q tokyonight && echo "✅ Themes available"
```

## 🚀 Future Enhancements

### Planned Features
- **Additional Applications**: Support for more terminal applications
- **Custom Color Schemes**: Easy custom theme creation wizard
- **Time-based Switching**: Automatic switching based on time of day
- **Location-based Themes**: GPS-based theme switching
- **Theme Previews**: Live preview before applying

### Community Contributions
- Submit new themes via pull requests
- Report color inconsistencies across applications  
- Suggest new application integrations
- Improve validation and testing scripts

---

**Supported Apps**: Alacritty • WezTerm • Kitty • tmux • Starship • Neovim
**Theme Variants**: 4 TokyoNight variations (Day, Night, Moon, Storm)
**Switching Speed**: < 500ms for all applications

*Seamless theme synchronization across your entire terminal ecosystem.*