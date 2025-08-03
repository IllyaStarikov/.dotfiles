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

# 3. Update tmux if in session (this is usually safe)
if [[ -n "${TMUX:-}" ]]; then
    echo "🔄 Updating tmux theme..."
    tmux source-file ~/.tmux.conf 2>/dev/null || true
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