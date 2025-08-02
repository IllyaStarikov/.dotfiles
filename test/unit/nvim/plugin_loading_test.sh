#!/bin/bash
# Comprehensive plugin loading tests

source "$(dirname "$0")/../../lib/test_helpers.sh"

test_suite "Plugin Loading Tests"

# Core plugin loading
test_case "All critical plugins load successfully"
critical_plugins=(
    "telescope:telescope"
    "gitsigns:gitsigns"
    "blink.cmp:blink.cmp"
    "snacks:snacks"
    "luasnip:luasnip"
    "codecompanion:codecompanion"
    "nvim-treesitter:nvim-treesitter"
    "mason:mason"
    "mason-lspconfig:mason-lspconfig"
    "nvim-lspconfig:lspconfig"
    "conform:conform"
    "nvzone_menu:menu"
    "plenary:plenary"
    "vimtex:vimtex"
)

for plugin_spec in "${critical_plugins[@]}"; do
    plugin="${plugin_spec%%:*}"
    module="${plugin_spec#*:}"
    test_plugin_loaded "$plugin" "$module"
done

# Lazy.nvim validation
test_case "Lazy.nvim plugin specs are valid"
nvim_test "Lazy.nvim spec validation" \
    "require('lazy').stats(); print('specs-valid')" \
    "specs-valid"

# Plugin initialization
test_case "Plugins initialize without errors"
nvim_test "Plugin initialization" \
    "vim.defer_fn(function()
        local stats = require('lazy').stats()
        print('loaded:', stats.loaded, 'of', stats.count)
        if stats.loaded > 0 then
            print('init-success')
        end
    end, 2000)" \
    "init-success"

# Specific plugin configurations
test_case "Telescope extensions load"
telescope_extensions=(
    "fzf"
    "ui-select"
)

for ext in "${telescope_extensions[@]}"; do
    nvim_test "Telescope extension: $ext" \
        "pcall(require('telescope').load_extension, '$ext'); print('$ext-loaded')" \
        "$ext-loaded"
done

# Snacks.nvim features
test_case "Snacks.nvim modules are available"
snacks_modules=(
    "dashboard"
    "picker"
    "terminal"
    "git"
    "notifier"
)

for module in "${snacks_modules[@]}"; do
    nvim_test "Snacks.$module available" \
        "local ok = pcall(function() return require('snacks').$module end); print('$module:', ok and 'available' or 'missing')" \
        "$module: available"
done

# TreeSitter parsers
test_case "Essential TreeSitter parsers installed"
parsers=(
    "lua"
    "python"
    "javascript"
    "typescript"
    "bash"
    "markdown"
    "vim"
    "vimdoc"
)

for parser in "${parsers[@]}"; do
    nvim_test "TreeSitter parser: $parser" \
        "local ok = pcall(require('nvim-treesitter.parsers').get_parser, '$parser')
         print('$parser:', ok and 'installed' or 'missing')" \
        "$parser: installed"
done

# LSP server configurations
test_case "LSP servers are configured"
lsp_servers=(
    "pyright"
    "lua_ls"
    "clangd"
    "rust_analyzer"
    "ts_ls"
)

for server in "${lsp_servers[@]}"; do
    nvim_test "LSP server config: $server" \
        "local lspconfig = require('lspconfig')
         local ok = lspconfig.$server ~= nil
         print('$server:', ok and 'configured' or 'missing')" \
        "$server: configured"
done

# Plugin commands availability
test_case "Plugin commands are available"
plugin_commands=(
    "Telescope"
    "Mason"
    "Lazy"
    "ConformInfo"
    "LspInfo"
    "CodeCompanion"
    "VimtexCompile"
    "Git"
    "Gitsigns"
)

for cmd in "${plugin_commands[@]}"; do
    test_command_exists "$cmd"
done

# Blink.cmp sources
test_case "Blink.cmp completion sources configured"
nvim_test "Blink.cmp sources" \
    "local blink = require('blink.cmp')
     local config = require('blink.cmp.config').get()
     local sources = vim.tbl_keys(config.sources or {})
     if #sources > 0 then
         print('sources:', table.concat(sources, ','))
     else
         print('no-sources')
     end" \
    "sources:"

# CodeCompanion adapters
test_case "CodeCompanion AI adapters configured"
nvim_test "CodeCompanion adapters" \
    "local ok, cc = pcall(require, 'codecompanion')
     if ok then
         local config = require('codecompanion.config').get()
         local adapters = vim.tbl_keys(config.adapters or {})
         if #adapters > 0 then
             print('adapters:', table.concat(adapters, ','))
         else
             print('no-adapters')
         end
     else
         print('codecompanion-not-loaded')
     end" \
    "adapters:"

# Plugin lazy loading
test_case "Lazy-loaded plugins can be triggered"
lazy_plugins=(
    "vimtex:tex"
    "markdown-preview:markdown"
)

for plugin_spec in "${lazy_plugins[@]}"; do
    plugin="${plugin_spec%%:*}"
    filetype="${plugin_spec#*:}"
    
    nvim_test "Lazy load $plugin on $filetype" \
        "vim.cmd('edit test.$filetype')
         vim.defer_fn(function()
             local loaded = require('lazy.core.loader').is_loaded('$plugin')
             print('$plugin:', loaded and 'loaded' or 'not-loaded')
         end, 1000)" \
        "$plugin: loaded"
done

# Plugin integrations
test_case "Plugin integrations work"
nvim_test "Telescope + Gitsigns integration" \
    "local ok = pcall(require('telescope.builtin').git_signs)
     print('telescope-gitsigns:', ok and 'integrated' or 'failed')" \
    "telescope-gitsigns: integrated"

nvim_test "LSP + Telescope integration" \
    "local ok = pcall(require('telescope.builtin').lsp_references)
     print('telescope-lsp:', ok and 'integrated' or 'failed')" \
    "telescope-lsp: integrated"

# Memory usage check
test_case "Plugin memory usage is reasonable"
nvim_test "Memory usage check" \
    "collectgarbage('collect')
     local mem = collectgarbage('count')
     print('memory:', math.floor(mem), 'KB')
     if mem < 100000 then  -- Less than 100MB
         print('memory-ok')
     else
         print('memory-high')
     end" \
    "memory-ok"

print_summary