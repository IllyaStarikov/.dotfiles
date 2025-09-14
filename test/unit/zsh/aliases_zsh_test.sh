#!/usr/bin/env zsh
# Test: Zsh aliases

test_case "Aliases file exists"
alias_file="$DOTFILES_DIR/src/zsh/aliases.zsh"
if [[ -f "$alias_file" ]]; then
    pass
else
    fail "aliases.zsh not found at $alias_file"
fi

test_case "Common aliases are defined"
if [[ -f "$alias_file" ]]; then
    common_aliases=(
        "ll"
        "la"
        "g"
        "vim"
    )
    
    found=0
    for alias_name in "${common_aliases[@]}"; do
        if grep -q "alias $alias_name=" "$alias_file" 2>/dev/null; then
            ((found++))
        fi
    done
    
    if [[ $found -ge 3 ]]; then
        pass
    else
        fail "Only $found/${#common_aliases[@]} common aliases found"
    fi
else
    skip "Aliases file not found"
fi

test_case "Git aliases are configured"
if [[ -f "$alias_file" ]] && grep -q "alias.*git\|alias g=" "$alias_file"; then
    pass
else
    fail "No git aliases found"
fi