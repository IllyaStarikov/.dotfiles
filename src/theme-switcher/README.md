# Theme Switcher

Theme synchronization for terminal applications. Keeps Alacritty, tmux, and Starship themes in sync.

## Features

- **Manual theme switching** with simple command
- **Multi-application support**: Alacritty, tmux, Starship  
- **Atomic file operations** for crash-proof switching
- **Theme validation** script included
- **Secure operation** with proper file permissions

## Usage

### Manual Theme Switching

```bash
# Switch to light theme
theme light

# Switch to dark theme  
theme dark

# Use specific theme
theme tokyonight_storm

# Theme shortcuts
theme day    # tokyonight_day (light)
theme night  # tokyonight_night (dark)
theme moon   # tokyonight_moon (dark)
theme storm  # tokyonight_storm (dark, default)

# List available themes
theme --list

# Show help
theme --help
```

### Environment Variables

Configure default themes through environment variables:

```bash
# Custom default theme names
export THEME_LIGHT=tokyonight_day
export THEME_DARK=tokyonight_storm
```

## File Locations

- **Config**: `~/.config/theme-switcher/current-theme.sh`
- **Cache**: `~/.cache/theme-switcher/`
- **Logs**: `~/.cache/theme-switcher/theme-switch.log`
- **Themes**: `./themes/`

## Theme Structure

Themes are organized in the `themes/` directory:

```
themes/
├── tokyonight_day/
│   ├── alacritty.toml
│   ├── tmux.conf
│   └── starship.toml
├── tokyonight_moon/
│   ├── alacritty.toml
│   ├── tmux.conf
│   └── starship.toml
├── tokyonight_night/
│   ├── alacritty.toml
│   └── tmux.conf
└── tokyonight_storm/
    ├── alacritty.toml
    └── tmux.conf
```

## Validation

Check theme integrity:

```bash
./validate-themes.sh
```

## Troubleshooting

### View logs

```bash
tail -f ~/.cache/theme-switcher/theme-switch.log
```

### Reset state

```bash
rm -rf ~/.cache/theme-switcher
rm -rf ~/.config/theme-switcher
```

### Check current theme

```bash
cat ~/.config/theme-switcher/current-theme.sh
```

## Security

- All cache files are created with mode 600 (user-only access)
- Cache directory is created with mode 700
- Lock files prevent concurrent theme switches

## License

Part of the dotfiles repository - see main repository for license details.