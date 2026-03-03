# Automatic Theme System

> **Seamless light/dark mode synchronization across your entire development environment**

[Source Code](../../../src/theme/)

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

| macOS Mode | Terminal Theme     | Neovim Theme       |
| ---------- | ------------------ | ------------------ |
| Light      | `tokyonight_day`   | `tokyonight-day`   |
| Dark       | `tokyonight_night` | `tokyonight-night` |

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
mkdir ~/.dotfiles/src/theme/my_custom_theme

# 2. Add theme variant files following existing theme structure

# 3. Regenerate configs
~/.dotfiles/src/theme/regenerate-all.sh

# 4. Use your theme
theme my_custom_theme
```

## Installation Status

### Verify Theme Scripts

```bash
# Check theme scripts exist
ls ~/.dotfiles/src/theme/*.sh

# Validate theme configurations
~/.dotfiles/src/theme/validate-themes.sh
```

### Manual Theme Switch

```bash
# Run theme switcher directly
~/.dotfiles/src/theme/switch-theme.sh

# Or use the theme alias
theme         # Auto-detect from macOS
theme day     # Light theme
theme night   # Dark theme
```

## Troubleshooting

### Theme Not Switching

**Run manually to check for errors:**

```bash
~/.dotfiles/src/theme/switch-theme.sh auto 2>&1
```

**Check lockfile (if switching seems stuck):**

```bash
ls -la /tmp/theme-switch.lock
```

### Manual Override

**Force theme update:**

```bash
~/.dotfiles/src/theme/switch-theme.sh auto
```

**Reset to system default:**

```bash
rm ~/.config/theme/current-theme
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
# Manual switching logs
~/.dotfiles/src/theme/switch-theme.sh auto 2>&1
```

**Reset all state:**

```bash
rm -rf ~/.cache/theme
rm -rf ~/.config/theme
theme  # Reinitialize
```

## Advanced Usage

### Custom Theme Integration

**Add support for new applications:**

1. Create theme files in `src/theme/[theme-name]/` and `src/theme/templates/`
2. Update `switch-theme.sh` to copy your files
3. Add application restart logic

**Example for adding VSCode theme:**

```bash
# In src/theme/tokyonight_night/vscode.json
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
src/theme/
├── switch-theme.sh           # Main theme switching logic
├── generate-theme.sh         # Theme configuration generator
├── validate-themes.sh        # Theme validation utility
├── regenerate-all.sh         # Regenerate all theme configs
├── templates/                # Theme templates (Alacritty, etc.)
├── tokyonight/               # TokyoNight theme variants
├── catppuccin/               # Catppuccin theme variants
├── dracula/                  # Dracula theme
├── nord/                     # Nord theme
└── [other-themes]/           # Additional theme directories
```

## Performance Notes

- **Lightweight monitoring** - Checks every 3 seconds, minimal CPU usage
- **Atomic updates** - File operations are crash-safe
- **Debounced switching** - Prevents rapid theme changes
- **Automatic cleanup** - Log rotation prevents disk usage issues

---

> **Pro Tip**: The theme system works best when you let it handle everything automatically. Set your preferred light/dark themes once and enjoy seamless switching as you work throughout the day!
