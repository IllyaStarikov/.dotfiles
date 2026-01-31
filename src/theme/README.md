# Theme Switcher

Synchronized theme switching across all terminal applications with macOS appearance integration.

## Features

- **Unified switching** - Change all apps with one command
- **macOS integration** - Auto-syncs with system dark/light mode
- **Atomic operations** - Crash-proof with file locking
- **4 TokyoNight variants** - Day (light), Night, Moon, Storm (dark)

## Supported Applications

Alacritty, WezTerm, Kitty, tmux, Starship, Neovim, bat, delta

## Quick Start

```bash
theme           # Auto-detect from macOS
theme day       # Light theme
theme night     # Dark blue theme
theme moon      # Dark purple theme
theme storm     # Balanced dark (default)
```

## Files

```
switch-theme.sh         # Main switching script
validate-themes.sh      # Theme validator
themes/
├── tokyonight_day/    # Each theme has configs for:
├── tokyonight_night/  # - alacritty.toml
├── tokyonight_moon/   # - wezterm.lua
└── tokyonight_storm/  # - kitty.conf, tmux.conf, starship.toml
```

## Generated Configs

- `~/.config/alacritty/theme.toml`
- `~/.config/wezterm/theme.lua`
- `~/.config/kitty/theme.conf`
- `~/.config/tmux/theme.conf`
- `~/.config/starship/theme.toml`
- `~/.config/theme/current-theme.sh`

## Integration

### Shell

```bash
# Environment variables available after switching
source ~/.config/theme/current-theme.sh
# CURRENT_THEME="tokyonight_storm"
# THEME_TYPE="dark"
```

### Applications

```toml
# Alacritty: ~/.config/alacritty/alacritty.toml
import = ["~/.config/alacritty/theme.toml"]
```

```bash
# tmux: ~/.tmux.conf
source-file ~/.config/tmux/theme.conf
```

```lua
-- Neovim: reads MACOS_THEME environment
vim.g.tokyonight_style = os.getenv("MACOS_THEME") or "storm"
```

## Custom Themes

1. Create `themes/custom_theme/` directory
2. Add config files for each application
3. Validate: `./validate-themes.sh custom_theme`
4. Apply: `theme custom_theme`

## Performance

- **< 500ms** switching time
- Cached theme files
- Background tmux reloading
- Atomic file operations

## Troubleshooting

**Theme not applying**: Check `cat ~/.config/theme/current-theme.sh`

**Wrong colors**: Verify terminal supports truecolor with `echo $COLORTERM`

**Stuck switching**: Remove lock file `rm /tmp/.theme-switch-*`

**Debug mode**: `THEME_DEBUG=1 theme storm`

## Lessons Learned

- File locking prevents race conditions during concurrent switches
- tmux needs `source-file` not just reload for theme changes
- Atomic moves prevent partial theme application
- macOS appearance API can lag, polling needed
