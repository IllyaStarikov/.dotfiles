# Automatic Theme System

> **Seamless light/dark mode synchronization across your entire development environment**

[Source Code](../../../src/theme-switcher/)

## Overview

The theme system automatically synchronizes your development environment with macOS appearance settings. When you switch between light and dark mode, all tools update instantly:

- **Alacritty** - Terminal colors and background
- **tmux** - Status bar and window styling  
- **Starship** - Prompt colors and symbols
- **Neovim** - Editor colorscheme (TokyoNight variants)

## How It Works

### Automatic Detection

The system uses a LaunchAgent that monitors macOS appearance changes:

```bash
# Check current macOS appearance
defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light"
```

### Theme Mapping

| macOS Mode | Terminal Theme | Neovim Theme |
|------------|---------------|--------------|
| Light | `tokyonight_day` | `tokyonight-day` |
| Dark | `tokyonight_night` | `tokyonight-night` |

### File Updates

When switching themes, the system atomically updates:

- `~/.config/alacritty/theme.toml` - Alacritty colors
- `~/.config/tmux/theme.conf` - tmux status bar styling
- `~/.config/starship.toml` - Starship prompt colors

## Manual Theme Control

### Command Line Interface

```bash
# Auto-detect and apply system theme
theme

# Force specific theme
theme light
theme dark

# Use custom theme variant
theme tokyonight_storm
theme tokyonight_moon
```

### Available Themes

**Light Variants:**
- `tokyonight_day` - Bright, high contrast

**Dark Variants:**
- `tokyonight_night` - Deep blue darkness
- `tokyonight_storm` - Softer dark variant (default)
- `tokyonight_moon` - Purple-tinted darkness

### In Neovim

```vim
" Check current theme
:colorscheme

" Manual theme switching (overrides auto-sync)
:colorscheme tokyonight-day
:colorscheme tokyonight-night
:colorscheme tokyonight-storm
:colorscheme tokyonight-moon
```

## Configuration

### Theme Preferences

Set your preferred themes in shell configuration:

```bash
# In ~/.dotfiles.private/exports.zsh
export THEME_LIGHT="tokyonight_day"
export THEME_DARK="tokyonight_storm"  # Custom dark variant
```

### Timing Controls

```bash
# Check interval (how often to check macOS appearance)
export THEME_CHECK_INTERVAL=3  # seconds

# Debounce period (prevent rapid switching)
export THEME_DEBOUNCE=5  # seconds
```

### Custom Themes

Create your own theme variants:

```bash
# 1. Create theme directory
mkdir ~/.dotfiles/src/theme-switcher/themes/my_custom_theme

# 2. Add theme files
# alacritty.toml - Terminal colors
# tmux.conf - tmux styling  
# starship.toml - Prompt colors

# 3. Use your theme
theme my_custom_theme
```

## Installation Status

### Check if Running

```bash
# Check LaunchAgent status
launchctl list | grep theme-watcher

# Check process
ps aux | grep theme-watcher
```

### Manual Installation

```bash
# Install LaunchAgent (auto-start on login)
cd ~/.dotfiles/src/theme-switcher
./install-auto-theme.sh

# Verify installation
launchctl list io.starikov.theme-watcher
```

### Manual Start/Stop

```bash
# Start theme watcher
launchctl load ~/Library/LaunchAgents/io.starikov.theme-watcher.plist

# Stop theme watcher  
launchctl unload ~/Library/LaunchAgents/io.starikov.theme-watcher.plist
```

## Troubleshooting

### Theme Not Switching

**Check watcher status:**
```bash
launchctl list io.starikov.theme-watcher
# Should show PID if running
```

**View logs:**
```bash
tail -f ~/.cache/theme-switcher/theme-watcher.log
```

**Restart watcher:**
```bash
launchctl unload ~/Library/LaunchAgents/io.starikov.theme-watcher.plist
launchctl load ~/Library/LaunchAgents/io.starikov.theme-watcher.plist
```

### Manual Override

**Force theme update:**
```bash
~/.dotfiles/src/theme-switcher/switch-theme.sh auto
```

**Reset to system default:**
```bash
rm ~/.config/theme-switcher/current-theme
theme
```

### Colors Not Updating

**Restart applications:**
```bash
# Reload tmux config
tmux source-file ~/.tmux.conf

# Restart Alacritty
# Close and reopen terminal

# Reload Neovim theme
# In Neovim: :source ~/.config/nvim/init.lua
```

### Logs and Debugging

**View detailed logs:**
```bash
# Theme watcher logs
tail -f ~/.cache/theme-switcher/theme-watcher.log

# Manual switching logs
~/.dotfiles/src/theme-switcher/switch-theme.sh auto 2>&1
```

**Reset all state:**
```bash
rm -rf ~/.cache/theme-switcher
rm -rf ~/.config/theme-switcher
theme  # Reinitialize
```

## Advanced Usage

### Custom Theme Integration

**Add support for new applications:**

1. Create theme files in `themes/[theme-name]/`
2. Update `switch-theme.sh` to copy your files
3. Add application restart logic

**Example for adding VSCode theme:**
```bash
# In themes/tokyonight_night/vscode.json
{
  "workbench.colorTheme": "Tokyo Night"
}

# In switch-theme.sh, add:
if [[ -f "$theme_dir/vscode.json" ]]; then
    cp "$theme_dir/vscode.json" "$HOME/.config/Code/User/settings.json"
fi
```

### Work-Specific Themes

**Override themes for work environments:**
```bash
# In ~/.dotfiles.private/work/theme.zsh
if [[ "$PWD" == *"/work/"* ]]; then
    export THEME_LIGHT="tokyonight_day"
    export THEME_DARK="tokyonight_storm"
fi
```

### Conditional Theme Logic

**Time-based theme switching:**
```bash
# In ~/.dotfiles.private/functions.zsh
work_theme() {
    local hour=$(date +%H)
    if [[ $hour -lt 9 || $hour -gt 18 ]]; then
        theme dark
    else
        theme light
    fi
}
```

## File Structure

```
src/theme-switcher/
├── switch-theme.sh           # Main theme switching logic
├── auto-theme-watcher.sh     # Automatic monitoring daemon
├── install-auto-theme.sh     # LaunchAgent installer
├── io.starikov.theme-watcher.plist  # LaunchAgent config
├── validate-themes.sh        # Theme validation utility
└── themes/                   # Theme definitions
    ├── tokyonight_day/
    │   ├── alacritty.toml
    │   ├── tmux.conf
    │   └── starship.toml
    ├── tokyonight_night/
    │   ├── alacritty.toml
    │   ├── tmux.conf
    │   └── starship.toml
    └── [other-themes]/
```

## Performance Notes

- **Lightweight monitoring** - Checks every 3 seconds, minimal CPU usage
- **Atomic updates** - File operations are crash-safe
- **Debounced switching** - Prevents rapid theme changes
- **Automatic cleanup** - Log rotation prevents disk usage issues

---

> **Pro Tip**: The theme system works best when you let it handle everything automatically. Set your preferred light/dark themes once and enjoy seamless switching as you work throughout the day!