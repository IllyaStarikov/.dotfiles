#!/bin/bash
# Ultra-safe theme switching that prevents all crashes
# This script ensures no terminals crash during theme changes

set -euo pipefail

THEME="${1:-auto}"
DELAY="${THEME_SWITCH_DELAY:-1}"  # Configurable delay

echo "🎨 Safe theme switch to: $THEME"

# 1. First, switch the theme files WITHOUT touching Alacritty
echo "📝 Updating theme files..."
~/.dotfiles/src/theme-switcher/switch-theme.sh "$THEME"

# 2. Small delay to ensure files are written
sleep "$DELAY"

# 3. Reload tmux for ALL sessions
echo "🔄 Updating tmux theme..."
if command -v tmux &>/dev/null; then
    # Get list of all tmux sessions
    tmux_sessions=$(tmux list-sessions -F '#S' 2>/dev/null || true)
    
    if [[ -n "$tmux_sessions" ]]; then
        # Reload config in all sessions
        while IFS= read -r session; do
            tmux source-file ~/.tmux.conf \; \
                 refresh-client -t "$session" -S 2>/dev/null || true
        done <<< "$tmux_sessions"
        echo "✅ Updated all tmux sessions"
    else
        echo "ℹ️  No tmux sessions found"
    fi
fi

# 4. Reload environment variables in current shell
if [[ -f "$HOME/.config/theme-switcher/current-theme.sh" ]]; then
    source "$HOME/.config/theme-switcher/current-theme.sh"
    echo "✅ Environment variables updated"
fi

echo ""
echo "✅ Theme switched successfully!"
echo ""
echo "⚠️  IMPORTANT: Alacritty requires manual restart to apply theme"
echo ""
echo "Options:"
echo "  1. Close and reopen Alacritty manually"
echo "  2. Run: reload-alacritty (will close current window)"
echo "  3. Open new Alacritty window to see new theme"
echo ""
echo "💡 TIP: Keep one terminal open with old theme while testing"