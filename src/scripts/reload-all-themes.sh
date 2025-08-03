#!/bin/bash
# Reload all theme-related configurations across all applications
# This ensures everything is in sync with the current theme

set -euo pipefail

echo "🔄 Reloading all theme configurations..."

# 1. Source current theme to get environment variables
if [[ -f "$HOME/.config/theme-switcher/current-theme.sh" ]]; then
    source "$HOME/.config/theme-switcher/current-theme.sh"
    echo "✅ Theme: $MACOS_THEME ($MACOS_VARIANT mode)"
else
    echo "❌ No theme configuration found"
    exit 1
fi

# 2. Reload tmux for ALL sessions and windows
if command -v tmux &>/dev/null; then
    echo "🔄 Reloading tmux..."
    
    # Get list of all tmux sessions
    tmux_sessions=$(tmux list-sessions -F '#S' 2>/dev/null || true)
    
    if [[ -n "$tmux_sessions" ]]; then
        # Source config and refresh each session
        while IFS= read -r session; do
            echo "  → Updating session: $session"
            # Source the main config
            tmux source-file ~/.tmux.conf 2>/dev/null || true
            # Force refresh all clients in this session
            tmux refresh-client -t "$session" -S 2>/dev/null || true
            # Also refresh status line
            tmux refresh-client -t "$session" -s 2>/dev/null || true
        done <<< "$tmux_sessions"
        echo "✅ All tmux sessions updated"
    else
        echo "ℹ️  No tmux sessions running"
    fi
fi

# 3. Update Neovim instances (if any)
if pgrep -x nvim &>/dev/null; then
    echo "ℹ️  Neovim instances detected - they will update on next file open"
fi

# 4. Starship prompt
if command -v starship &>/dev/null; then
    echo "🔄 Reloading Starship prompt..."
    # Starship will reload on next prompt
    echo "✅ Starship will update on next prompt"
fi

# 5. Show current status
echo ""
echo "📊 Current theme status:"
echo "  Theme:   $MACOS_THEME"
echo "  Variant: $MACOS_VARIANT"
echo ""

# 6. Alacritty reminder
if pgrep -x alacritty &>/dev/null; then
    echo "⚠️  Alacritty detected - manual restart required:"
    echo "    Option 1: Close and reopen Alacritty"
    echo "    Option 2: Run 'reload-alacritty'"
    echo "    Option 3: Press Cmd+Q and restart"
fi

echo ""
echo "✅ Theme reload complete!"