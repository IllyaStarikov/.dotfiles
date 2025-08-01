# Theme Switcher

Automatic theme synchronization for macOS appearance changes. Keeps Alacritty, tmux, and Starship themes in sync with the system's light/dark mode.

## Features

- **Automatic synchronization** with macOS appearance changes
- **Crash-proof design** with atomic file operations
- **Multi-application support**: Alacritty, tmux, Starship
- **Configurable timing** and behavior via environment variables
- **Secure operation** with proper file permissions
- **Automatic log rotation** to prevent disk space issues

## Installation

### Manual Start

```bash
# Switch theme manually
./switch-theme.sh [auto|light|dark|theme-name]

# Start the automatic watcher
./auto-theme-watcher.sh
```

### Install as LaunchAgent (Recommended)

```bash
# Install the launch agent
./install-auto-theme.sh

# Or manually:
cp io.starikov.theme-watcher.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/io.starikov.theme-watcher.plist
```

## Usage

### Manual Theme Switching

```bash
# Auto-detect based on macOS appearance
./switch-theme.sh

# Force light theme
./switch-theme.sh light

# Force dark theme
./switch-theme.sh dark

# Use specific theme
./switch-theme.sh tokyonight_storm
```

### Environment Variables

Configure behavior through environment variables:

```bash
# Check interval in seconds (default: 3)
export THEME_CHECK_INTERVAL=5

# Debounce period in seconds (default: 5)
export THEME_DEBOUNCE=10

# Maximum failures before exit (default: 3)
export THEME_MAX_FAILURES=5

# Custom theme names
export THEME_LIGHT=tokyonight_day
export THEME_DARK=tokyonight_moon
```

## File Locations

- **Config**: `~/.config/theme-switcher/`
- **Cache**: `~/.cache/theme-switcher/`
- **Logs**: `~/.cache/theme-switcher/*.log`
- **Themes**: `./themes/`

## Troubleshooting

### Check if watcher is running

```bash
ps aux | grep theme-watcher
```

### View logs

```bash
tail -f ~/.cache/theme-switcher/theme-watcher.log
```

### Reset state

```bash
rm -rf ~/.cache/theme-switcher
rm -rf ~/.config/theme-switcher
```

## Theme Structure

Themes are organized in the `themes/` directory:

```
themes/
├── tokyonight_day/
│   ├── alacritty/
│   │   └── theme.toml
│   ├── tmux.conf
│   └── starship.toml
└── tokyonight_moon/
    ├── alacritty/
    │   └── theme.toml
    ├── tmux.conf
    └── starship.toml
```

## Security

- All cache files are created with mode 600 (user-only access)
- Cache directory is created with mode 700
- PID files prevent multiple instances
- Lock files prevent concurrent theme switches

## Performance

- Efficient polling with configurable intervals
- Debouncing prevents rapid switching
- Automatic log rotation prevents disk space issues
- Minimal resource usage (~0.1% CPU)

## License

Part of the dotfiles repository - see main repository for license details.