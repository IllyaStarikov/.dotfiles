#!/bin/zsh
# Test: Git configuration

test_case "gitconfig exists"
if [[ -f "$DOTFILES_DIR/src/gitconfig" ]]; then
    pass
else
    fail "gitconfig not found"
fi

test_case "User name and email are configured"
if [[ -f "$DOTFILES_DIR/src/gitconfig" ]]; then
    has_name=$(grep -q "name =" "$DOTFILES_DIR/src/gitconfig" && echo 1 || echo 0)
    has_email=$(grep -q "email =" "$DOTFILES_DIR/src/gitconfig" && echo 1 || echo 0)
    
    if [[ $has_name -eq 1 ]] && [[ $has_email -eq 1 ]]; then
        pass
    else
        fail "Missing user configuration"
    fi
else
    skip "gitconfig not found"
fi

test_case "Common git aliases exist"
if [[ -f "$DOTFILES_DIR/src/gitconfig" ]]; then
    aliases=(
        "st"
        "co"
        "br"
    )
    
    found=0
    for alias in "${aliases[@]}"; do
        if grep -q "$alias =" "$DOTFILES_DIR/src/gitconfig"; then
            ((found++))
        fi
    done
    
    if [[ $found -ge 2 ]]; then
        pass
    else
        fail "Only $found/${#aliases[@]} git aliases found"
    fi
else
    skip "gitconfig not found"
fi