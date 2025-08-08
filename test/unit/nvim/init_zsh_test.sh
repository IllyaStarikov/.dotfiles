#!/bin/zsh
# Test: Neovim init.lua configuration

test_case "init.lua exists and is valid"
if [[ -f "$DOTFILES_DIR/src/vim/init.lua" ]]; then
    # Check if it's valid Lua
    output=$(nvim --headless -c "luafile $DOTFILES_DIR/src/vim/init.lua" -c "qa" 2>&1)
    if [[ -z "$output" ]] || [[ "$output" != *"Error"* ]]; then
        pass
    else
        fail "init.lua has errors: $output"
    fi
else
    fail "init.lua not found"
fi

test_case "Neovim starts without errors"
output=$(nvim --headless -c "qa" 2>&1)
if [[ -z "$output" ]] || [[ "$output" != *"Error"* ]]; then
    pass
else
    fail "Neovim startup errors: $output"
fi

test_case "Required Neovim version"
version=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+')
major=$(echo $version | cut -d. -f1)
minor=$(echo $version | cut -d. -f2)

if [[ $major -gt 0 ]] || [[ $major -eq 0 && $minor -ge 9 ]]; then
    pass
else
    fail "Neovim version too old: $version (need 0.9+)"
fi