#!/bin/zsh
# Test: Zsh configuration

test_case "zshrc exists and is valid"
if [[ -f "$DOTFILES_DIR/src/zshrc" ]]; then
    if zsh -n "$DOTFILES_DIR/src/zshrc" 2>/dev/null; then
        pass
    else
        fail "zshrc has syntax errors"
    fi
else
    fail "zshrc not found"
fi

test_case "Essential environment variables are set"
source "$DOTFILES_DIR/src/zshrc" 2>/dev/null || true

essential_vars=(
    "EDITOR"
    "PATH"
)

missing=()
for var in "${essential_vars[@]}"; do
    if [[ -z "${(P)var}" ]]; then
        missing+=("$var")
    fi
done

if [[ ${#missing[@]} -eq 0 ]]; then
    pass
else
    fail "Missing variables: ${missing[*]}"
fi

test_case "Zsh prompt is configured"
if grep -q "PROMPT\|PS1\|starship\|spaceship\|powerlevel" "$DOTFILES_DIR/src/zshrc" 2>/dev/null; then
    pass
else
    fail "No prompt configuration found"
fi