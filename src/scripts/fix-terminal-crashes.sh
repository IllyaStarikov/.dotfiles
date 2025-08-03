#!/bin/bash
# Fix terminal crashes by disabling problematic features
# Run this to prevent crashes during theme switching

set -euo pipefail

echo "🔧 Fixing terminal crash issues..."

# 1. Fix Alacritty configuration
ALACRITTY_CONFIG="$HOME/.config/alacritty/alacritty.toml"
if [[ -f "$ALACRITTY_CONFIG" ]]; then
    echo "📝 Updating Alacritty configuration..."
    
    # Remove hardcoded theme variant
    sed -i '' 's/decorations_theme_variant = "Dark".*/# decorations_theme_variant = "Dark"  # Disabled to prevent crashes/' "$ALACRITTY_CONFIG" 2>/dev/null || true
    
    # Ensure live reload is disabled
    sed -i '' 's/live_config_reload = true/live_config_reload = false/' "$ALACRITTY_CONFIG" 2>/dev/null || true
    
    echo "✅ Alacritty configuration updated"
fi

# 2. Kill any existing theme watchers
echo "🛑 Stopping any existing theme watchers..."
pkill -f "theme-watcher" 2>/dev/null || true
pkill -f "theme-daemon" 2>/dev/null || true

# 3. Clear theme cache
CACHE_DIR="$HOME/.cache/theme-switcher"
if [[ -d "$CACHE_DIR" ]]; then
    echo "🗑️  Clearing theme cache..."
    rm -f "$CACHE_DIR"/*.lock 2>/dev/null || true
fi

# 4. Create a safe LaunchAgent for theme watching (optional)
LAUNCH_AGENT="$HOME/Library/LaunchAgents/com.dotfiles.theme-watcher.plist"
if [[ ! -f "$LAUNCH_AGENT" ]]; then
    echo "📋 Creating safe LaunchAgent..."
    mkdir -p "$HOME/Library/LaunchAgents"
    cat > "$LAUNCH_AGENT" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.dotfiles.theme-watcher</string>
    <key>Program</key>
    <string>/Users/starikov/.dotfiles/src/scripts/theme-watcher-safe.sh</string>
    <key>RunAtLoad</key>
    <false/>
    <key>KeepAlive</key>
    <false/>
    <key>StandardOutPath</key>
    <string>/tmp/theme-watcher.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/theme-watcher.error.log</string>
    <key>ThrottleInterval</key>
    <integer>5</integer>
</dict>
</plist>
EOF
    echo "✅ LaunchAgent created (not loaded)"
fi

echo ""
echo "🎉 Terminal crash prevention complete!"
echo ""
echo "📌 Important notes:"
echo "   - Alacritty live reload has been disabled"
echo "   - Theme variant decorations have been disabled"
echo "   - You'll need to restart Alacritty after theme changes"
echo ""
echo "🚀 To apply themes without crashes:"
echo "   1. Use: theme dark/light/auto"
echo "   2. Then: reload-alacritty"
echo ""
echo "🤖 For automatic theme switching (optional):"
echo "   launchctl load $LAUNCH_AGENT"
echo "   launchctl start com.dotfiles.theme-watcher"