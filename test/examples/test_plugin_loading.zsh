#!/bin/zsh
# Example: Comprehensive plugin loading tests

# Source test framework
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/test_helpers.zsh"

echo "━━━ Plugin Loading Tests ━━━"

# Test 1: All plugins from config actually load
test_case "All configured plugins load successfully"
output=$(nvim --headless -u "$DOTFILES_DIR/src/neovim/init.lua" \
    -c "lua vim.defer_fn(function()
        local lazy = require('lazy')
        local failed = {}
        local loaded = 0
        
        for _, plugin in ipairs(lazy.plugins()) do
            if plugin.enabled ~= false then
                if require('lazy.core.loader').is_loaded(plugin.name) then
                    loaded = loaded + 1
                else
                    table.insert(failed, plugin.name)
                end
            end
        end
        
        print('loaded:', loaded)
        if #failed > 0 then
            print('failed:', table.concat(failed, ', '))
        end
        vim.cmd('qa!')
    end, 3000)" 2>&1)

if [[ "$output" == *"failed:"* ]]; then
    fail "Some plugins failed to load: $output"
else
    pass
fi

# Test 2: Critical plugin functionality
test_case "Telescope commands are available"
commands=(
    "Telescope"
    "Telescope find_files"
    "Telescope live_grep"
    "Telescope buffers"
)

for cmd in "${commands[@]}"; do
    result=$(nvim --headless -u "$DOTFILES_DIR/src/neovim/init.lua" \
        -c "lua vim.defer_fn(function()
            print(vim.fn.exists(':$cmd') > 0 and 'exists' or 'missing')
            vim.cmd('qa!')
        end, 2000)" 2>&1)
    
    if [[ "$result" != *"exists"* ]]; then
        fail "Command '$cmd' not available"
        break
    fi
done
[[ "$result" == *"exists"* ]] && pass

# Test 3: Blink.cmp is functional
test_case "Blink.cmp completion engine works"
cat > "$TEST_TMP_DIR/completion_test.lua" << 'EOF'
local M = {}

function M.test()
    vim.
end

return M
EOF

output=$(nvim --headless "$TEST_TMP_DIR/completion_test.lua" \
    -c "lua vim.defer_fn(function()
        -- Move to the incomplete line
        vim.cmd('normal! 4G$')
        vim.cmd('startinsert')
        
        -- Wait for completion to trigger
        vim.defer_fn(function()
            local blink = require('blink.cmp')
            if blink.is_visible() then
                local items = blink.get_entries()
                print('completion-items:', #items)
            else
                print('no-completion')
            end
            vim.cmd('qa!')
        end, 1000)
    end, 1000)" 2>&1)

if [[ "$output" == *"completion-items:"* ]]; then
    pass
else
    fail "Completion not working"
fi

# Test 4: Snacks.nvim features
test_case "Snacks.nvim dashboard and picker work"
output=$(nvim --headless -u "$DOTFILES_DIR/src/neovim/init.lua" \
    -c "lua vim.defer_fn(function()
        local ok1, snacks = pcall(require, 'snacks')
        if not ok1 then
            print('snacks-failed')
            vim.cmd('qa!')
            return
        end
        
        -- Test dashboard
        local ok2 = pcall(function() snacks.dashboard.open() end)
        
        -- Test picker
        local ok3 = pcall(function() snacks.picker.files() end)
        
        print(ok2 and ok3 and 'snacks-ok' or 'snacks-error')
        vim.cmd('qa!')
    end, 2000)" 2>&1)

[[ "$output" == *"snacks-ok"* ]] && pass || fail "Snacks.nvim not functional"

# Test 5: LSP servers configured in mason
test_case "Mason LSP servers are available"
lsp_servers=(
    "pyright"
    "clangd"
    "lua_ls"
    "marksman"
)

output=$(nvim --headless -u "$DOTFILES_DIR/src/neovim/init.lua" \
    -c "lua vim.defer_fn(function()
        local mason_registry = require('mason-registry')
        local missing = {}
        
        for _, server in ipairs({'${(j:', ')lsp_servers}'}) do
            if not mason_registry.is_installed(server) then
                table.insert(missing, server)
            end
        end
        
        if #missing > 0 then
            print('missing:', table.concat(missing, ', '))
        else
            print('all-installed')
        end
        vim.cmd('qa!')
    end, 2000)" 2>&1)

[[ "$output" == *"all-installed"* ]] && pass || skip "LSP servers need installation"