#!/bin/bash
# Safely reload Alacritty by restarting all instances
# This prevents crashes from live config reloading

set -euo pipefail

echo "🔄 Reloading Alacritty..."

# Get all Alacritty process IDs
PIDS=$(pgrep -x alacritty 2>/dev/null || true)

if [[ -z "$PIDS" ]]; then
    echo "❌ No Alacritty instances found"
    exit 0
fi

# Count instances
COUNT=$(echo "$PIDS" | wc -l | tr -d ' ')
echo "📊 Found $COUNT Alacritty instance(s)"

# Ask for confirmation if multiple instances
if [[ $COUNT -gt 1 ]]; then
    read -p "⚠️  Multiple Alacritty instances found. Restart all? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Cancelled"
        exit 0
    fi
fi

# Kill all Alacritty instances gracefully
echo "🛑 Stopping Alacritty..."
kill -TERM $PIDS 2>/dev/null || true

# Wait a moment
sleep 0.5

# Restart Alacritty
echo "🚀 Starting Alacritty..."
open -a Alacritty 2>/dev/null || alacritty &

echo "✅ Alacritty reloaded with new theme"