#!/bin/bash
# Minimal theme switcher with Starship support

THEME="${1:-auto}"
CONFIG_DIR="$HOME/.config/theme-switcher"
ALACRITTY_DIR="$HOME/.config/alacritty"
TMUX_DIR="$HOME/.config/tmux"
STARSHIP_DIR="$HOME/.config"

# Default themes
LIGHT_THEME="tokyonight_day"
DARK_THEME="tokyonight_moon"

# Auto-detect macOS appearance
if [[ "$THEME" == "auto" || "$THEME" == "default" ]]; then
    if [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == "Dark" ]]; then
        THEME="$DARK_THEME"
        VARIANT="dark"
    else
        THEME="$LIGHT_THEME"
        VARIANT="light"
    fi
elif [[ "$THEME" == "light" ]]; then
    THEME="$LIGHT_THEME"
    VARIANT="light"
elif [[ "$THEME" == "dark" ]]; then
    THEME="$DARK_THEME"
    VARIANT="dark"
else
    # Detect variant from theme name
    [[ "$THEME" =~ (day|light)$ ]] && VARIANT="light" || VARIANT="dark"
fi

# Create directories
mkdir -p "$CONFIG_DIR" "$ALACRITTY_DIR" "$TMUX_DIR"

# Save current theme
cat > "$CONFIG_DIR/current-theme.sh" << EOF
export MACOS_THEME="$THEME"
export MACOS_VARIANT="$VARIANT"
EOF

# Apply theme configs
THEME_DIR="$(dirname "$0")/themes/$THEME"
[[ -f "$THEME_DIR/alacritty.toml" ]] && cp "$THEME_DIR/alacritty.toml" "$ALACRITTY_DIR/theme.toml"
[[ -f "$THEME_DIR/tmux.conf" ]] && cp "$THEME_DIR/tmux.conf" "$TMUX_DIR/theme.conf"
[[ -f "$THEME_DIR/starship.toml" ]] && cp "$THEME_DIR/starship.toml" "$STARSHIP_DIR/starship.toml"

# Reload tmux if running
if tmux info &>/dev/null; then
    tmux source-file ~/.tmux.conf 2>/dev/null || true
    tmux refresh-client -S
fi

echo "✅ Theme switched to $THEME ($VARIANT mode)"