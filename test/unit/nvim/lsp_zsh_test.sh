#!/bin/zsh
# Test: LSP configuration

test_case "LSP configuration exists"
if [[ -f "$DOTFILES_DIR/src/vim/config/lsp/servers.lua" ]] || \
   [[ -f "$DOTFILES_DIR/src/vim/config/lsp/init.lua" ]]; then
    pass
else
    fail "No LSP configuration found"
fi

test_case "LSP servers are configured"
expected_servers=(
    "pyright"
    "lua_ls"
    "clangd"
    "rust_analyzer"
)

config_file="$DOTFILES_DIR/src/vim/config/lsp/servers.lua"
if [[ -f "$config_file" ]]; then
    found=0
    for server in "${expected_servers[@]}"; do
        if grep -q "$server" "$config_file"; then
            ((found++))
        fi
    done
    
    if [[ $found -ge 3 ]]; then
        pass
    else
        fail "Only $found/${#expected_servers[@]} LSP servers configured"
    fi
else
    skip "LSP config file not found"
fi

test_case "Mason LSP installer is configured"
if grep -q "mason" "$DOTFILES_DIR/src/vim/config/plugins.lua" 2>/dev/null || \
   grep -q "mason-lspconfig" "$DOTFILES_DIR/src/vim/config/lsp/"*.lua 2>/dev/null; then
    pass
else
    fail "Mason LSP installer not configured"
fi