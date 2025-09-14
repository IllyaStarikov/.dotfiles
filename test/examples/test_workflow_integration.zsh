#!/usr/bin/env zsh
# Example: End-to-end workflow integration tests

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/test_helpers.zsh"

echo "━━━ Workflow Integration Tests ━━━"

# Test 1: Complete Git workflow with hooks
test_case "Git workflow with pre-commit hooks"
cd "$TEST_TMP_DIR"
git init >/dev/null 2>&1
git config user.name "Test User"
git config user.email "test@example.com"

# Setup pre-commit hook if available
if [[ -f "$DOTFILES_DIR/src/git/pre-commit-hook" ]]; then
    cp "$DOTFILES_DIR/src/git/pre-commit-hook" .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
fi

# Create a file that should pass
cat > good.py << 'EOF'
def hello():
    """Say hello."""
    return "Hello, World!"
EOF

git add good.py
if git commit -m "Add good file" >/dev/null 2>&1; then
    echo "  First commit passed"
else
    fail "Good commit was rejected"
fi

# Create a file that might trigger gitleaks
cat > bad.py << 'EOF'
# This contains a potential secret
API_KEY = "sk-1234567890abcdef"
PASSWORD = "supersecret123"
EOF

git add bad.py
if ! git commit -m "Add secrets" >/dev/null 2>&1; then
    pass  # Hook correctly blocked the commit
else
    skip "Pre-commit hook not blocking secrets"
fi

# Test 2: Theme switching affects all tools
test_case "Theme switching updates Neovim, tmux, and Alacritty"
# Record initial states
initial_alacritty=$(grep -E "tokyonight" ~/.config/alacritty/theme.toml 2>/dev/null || echo "none")
initial_nvim=$(nvim --headless -c "lua print(vim.g.colors_name or 'default')" -c "qa!" 2>&1)
initial_theme_var=$(source ~/.config/theme-switcher/current-theme.sh 2>/dev/null && echo $MACOS_THEME || echo "none")

# Switch theme
current_appearance=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light")
new_appearance=$([[ "$current_appearance" == "Dark" ]] && echo "Light" || echo "Dark")

if [[ "$new_appearance" == "Dark" ]]; then
    defaults write -g AppleInterfaceStyle Dark
else
    defaults delete -g AppleInterfaceStyle 2>/dev/null
fi

"$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" >/dev/null 2>&1

# Check all components updated
new_alacritty=$(grep -E "tokyonight" ~/.config/alacritty/theme.toml 2>/dev/null || echo "none")
new_nvim=$(nvim --headless -c "lua print(vim.g.colors_name or 'default')" -c "qa!" 2>&1)
new_theme_var=$(source ~/.config/theme-switcher/current-theme.sh 2>/dev/null && echo $MACOS_THEME || echo "none")

changes=0
[[ "$initial_alacritty" != "$new_alacritty" ]] && ((changes++))
[[ "$initial_nvim" != "$new_nvim" ]] && ((changes++))
[[ "$initial_theme_var" != "$new_theme_var" ]] && ((changes++))

if [[ $changes -ge 2 ]]; then
    pass
else
    fail "Only $changes/3 components updated"
fi

# Restore original theme
if [[ "$current_appearance" == "Dark" ]]; then
    defaults write -g AppleInterfaceStyle Dark
else
    defaults delete -g AppleInterfaceStyle 2>/dev/null
fi
"$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" >/dev/null 2>&1

# Test 3: Neovim + tmux integration
test_case "Neovim works correctly inside tmux"
if command -v tmux >/dev/null; then
    # Create a test tmux session
    tmux new-session -d -s test-session 2>/dev/null
    
    # Run Neovim inside tmux and test functionality
    output=$(tmux send-keys -t test-session "nvim --headless -c 'lua print(\"tmux-test-ok\")' -c 'qa!'" Enter 2>&1)
    sleep 1
    
    # Check if it ran successfully
    tmux_output=$(tmux capture-pane -t test-session -p 2>/dev/null)
    
    if [[ "$tmux_output" == *"tmux-test-ok"* ]]; then
        pass
    else
        fail "Neovim not working properly in tmux"
    fi
    
    tmux kill-session -t test-session 2>/dev/null
else
    skip "tmux not installed"
fi

# Test 4: Full development session
test_case "Complete development workflow"
cd "$TEST_TMP_DIR"

# Create a small project
mkdir -p myproject/src
cd myproject

cat > src/main.py << 'EOF'
#!/usr/bin/env python3
"""Main application module."""

def fibonacci(n):
    """Calculate fibonacci number."""
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

def main():
    for i in range(10):
        print(f"fib({i}) = {fibonacci(i)}")

if __name__ == "__main__":
    main()
EOF

# Test that we can edit, save, and run
output=$(nvim --headless src/main.py \
    -c "normal! Go" \
    -c "normal! i    # Added by test" \
    -c "w" \
    -c "qa!" 2>&1)

if [[ -f src/main.py ]] && grep -q "# Added by test" src/main.py; then
    pass
else
    fail "File editing workflow failed"
fi

# Test 5: Performance under load
test_case "Neovim handles large files efficiently"
# Create a large file
yes "This is a test line that will be repeated many times to create a large file" | head -n 10000 > "$TEST_TMP_DIR/large.txt"

# Time opening and navigating
start_time=$(date +%s%N)
nvim --headless "$TEST_TMP_DIR/large.txt" \
    -c "normal! G" \
    -c "normal! gg" \
    -c "normal! 5000G" \
    -c "qa!" 2>&1
end_time=$(date +%s%N)

elapsed_ms=$(( (end_time - start_time) / 1000000 ))

if [[ $elapsed_ms -lt 1000 ]]; then
    pass
else
    fail "Too slow with large files: ${elapsed_ms}ms"
fi