# Theme Switcher

Synchronized theme switching across all terminal applications with macOS appearance integration.

## Features

- **Unified switching** - Change all apps with one command
- **macOS integration** - Auto-syncs with system dark/light mode
- **Atomic operations** - Crash-proof with file locking
- **57 theme variants** - 17 families including TokyoNight, GitHub, Catppuccin, Dracula, and more
- **Template-based generation** - All theme configs are generated from `colors.json` + templates

## Supported Applications

Alacritty, WezTerm, Kitty, tmux, Starship, Neovim, bat, delta

## Quick Start

```bash
theme                # Interactive picker with live preview
theme day            # Light theme
theme night          # Dark blue theme
theme moon           # Dark purple theme
theme storm          # Balanced dark (default)
theme --list         # List all available themes
theme --list github  # List variants of a family
theme -v storm       # Verbose output
```

## Files

```
switch-theme.sh         # Main switching script (zsh)
validate-themes.sh      # Theme validator
generate-theme.sh       # Generate configs from templates + colors.json
regenerate-all.sh       # Regenerate all 57 themes
templates/              # Template files for each app
  starship.toml         #   Uses {{directory_style}} for light/dark
  colors.sh             #   Exports FOREGROUND, BACKGROUND, CURSOR, COLOR_0-15
  tmux.conf, alacritty.toml, kitty.conf, wezterm.lua, neovim.lua
tokyonight/storm/       # Each theme directory has:
  colors.json           #   Source of truth for all colors
  alacritty.toml, wezterm.lua, kitty.conf, tmux.conf, starship.toml, colors.sh
```

## Generated Configs

Theme switching copies configs atomically (not symlinks) to:

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
# MACOS_THEME="storm"
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

## Flags

| Flag | Description |
|------|-------------|
| (no args) | Interactive picker with live preview |
| `--auto` | Auto-detect from macOS appearance |
| `--local [THEME]` | Session-only theming (terminal OSC + tmux session-local) |
| `--list [FAMILY]` | List themes, optionally filtered by family |
| `--pick` | Force interactive picker |
| `--shell THEME` | Print shell exports to stdout |
| `--tmux THEME` | Reload tmux theme only |
| `-v`, `--verbose` | Verbose output (composes with other flags) |
| `-h`, `--help` | Show help |

## Custom Themes

1. Create `family/variant/` directory with `colors.json`
2. Run `./generate-theme.sh family variant` to generate configs
3. Validate: `./validate-themes.sh`
4. Apply: `theme family_variant`

## Performance

- **< 500ms** switching time
- Atomic file operations (cp + mv)
- Direct `tmux source-file` for reload

## Troubleshooting

**Theme not applying**: Check `cat ~/.config/theme/current-theme.sh`

**Wrong colors**: Verify terminal supports truecolor with `echo $COLORTERM`

**Stuck switching**: Remove lock file `rm /tmp/.theme-switch-*`

**Debug mode**: `THEME_DEBUG=1 theme storm`
