--
-- config/blink.lua
-- Modern high-performance completion configuration
-- Replaces nvim-cmp with blink.cmp for better performance and features
--

local M = {}

function M.setup()
    -- Ensure blink.cmp is available
    local blink_ok, blink = pcall(require, "blink.cmp")
    if not blink_ok then
        vim.notify("blink.cmp not available", vim.log.levels.ERROR)
        return
    end
    
    blink.setup({
        -- Key mappings configuration
        keymap = { 
            preset = "default",
            ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
            ["<C-e>"] = { "hide" },
            ["<CR>"] = { "accept", "fallback" },
            ["<Tab>"] = { "select_next", "fallback" },
            ["<S-Tab>"] = { "select_prev", "fallback" },
            ["<C-p>"] = { "select_prev", "fallback" },
            ["<C-n>"] = { "select_next", "fallback" },
            ["<C-b>"] = { "scroll_documentation_up", "fallback" },
            ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        },
        
        -- Fuzzy matching configuration (use pure Lua implementation)
        fuzzy = {
            -- Always use the Lua implementation to avoid Rust nightly requirement
            implementation = 'lua',
            prebuilt_binaries = {
                download = false, -- No need to download when using Lua
            }
        },
        
        
        -- Basic completion configuration
        completion = {
            menu = {
                border = "rounded",
                draw = {
                    -- Faster rendering
                    columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
                },
            },
            documentation = {
                auto_show = false,  -- Don't auto-show docs (major performance improvement)
                auto_show_delay_ms = 0,
            },
            -- Trigger configuration
            trigger = {
                show_in_snippet = true,
                show_on_keyword = true,
                show_on_trigger_character = true,
                show_on_insert_on_trigger_character = true,
            },
            accept = {
                auto_brackets = {
                    enabled = true,
                },
            },
        },
        
        -- Source configuration - simplified to avoid validation errors
        sources = {
            default = { "lsp", "path", "buffer", "snippets" },
        },
        
        -- Disable completion in certain filetypes
        enabled = function()
            local disabled_filetypes = { "TelescopePrompt", "oil", "alpha", "dashboard" }
            return not vim.tbl_contains(disabled_filetypes, vim.bo.filetype)
        end,
        
        -- Snippet configuration
        snippets = {
            expand = function(snippet)
                require("luasnip").lsp_expand(snippet)
            end,
            active = function(filter)
                if filter and filter.direction then
                    return require("luasnip").jumpable(filter.direction)
                end
                return require("luasnip").in_snippet()
            end,
            jump = function(direction)
                require("luasnip").jump(direction)
            end,
        },
    })
    
    -- Setup LuaSnip for snippet support
    M.setup_luasnip()
    
    -- Setup highlight groups for better integration
    M.setup_highlights()
    
    -- Setup LSP integration
    M.setup_lsp_integration()
    
    -- Setup autocommands for enhanced functionality
    M.setup_autocommands()
end

-- Setup LuaSnip for snippet support
function M.setup_luasnip()
    local luasnip_ok, luasnip = pcall(require, "luasnip")
    if not luasnip_ok then
        vim.notify("LuaSnip not available - snippets will not work", vim.log.levels.WARN)
        return
    end
    
    -- Load friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load()
    
    -- Load custom snippets from our snippets directory
    require("luasnip.loaders.from_lua").load({
        paths = vim.fn.stdpath("config") .. "/lua/snippets/"
    })
    
    -- LuaSnip configuration
    luasnip.setup({
        -- Enable auto-triggered snippets
        enable_autosnippets = true,
        
        -- Remember last snippet position for quick jumps
        store_selection_keys = "<Tab>",
        
        -- Update events for real-time snippet updates  
        update_events = "TextChanged,TextChangedI",
        
        -- Enable history for better snippet navigation
        history = true,
    })
end

-- Custom highlight groups for blink.cmp
function M.setup_highlights()
    local highlights = {
        -- Menu highlights
        BlinkCmpMenu = { link = "Pmenu" },
        BlinkCmpMenuBorder = { link = "FloatBorder" },
        BlinkCmpMenuSelection = { link = "PmenuSel" },
        
        -- Documentation highlights  
        BlinkCmpDoc = { link = "NormalFloat" },
        BlinkCmpDocBorder = { link = "FloatBorder" },
        
        -- Signature help highlights
        BlinkCmpSignatureHelp = { link = "NormalFloat" },
        BlinkCmpSignatureHelpBorder = { link = "FloatBorder" },
        
        -- Kind highlights (completion item types)
        BlinkCmpKindText = { link = "CmpItemKindText" },
        BlinkCmpKindMethod = { link = "CmpItemKindMethod" },
        BlinkCmpKindFunction = { link = "CmpItemKindFunction" },
        BlinkCmpKindConstructor = { link = "CmpItemKindConstructor" },
        BlinkCmpKindField = { link = "CmpItemKindField" },
        BlinkCmpKindVariable = { link = "CmpItemKindVariable" },
        BlinkCmpKindClass = { link = "CmpItemKindClass" },
        BlinkCmpKindInterface = { link = "CmpItemKindInterface" },
        BlinkCmpKindModule = { link = "CmpItemKindModule" },
        BlinkCmpKindProperty = { link = "CmpItemKindProperty" },
        BlinkCmpKindUnit = { link = "CmpItemKindUnit" },
        BlinkCmpKindValue = { link = "CmpItemKindValue" },
        BlinkCmpKindEnum = { link = "CmpItemKindEnum" },
        BlinkCmpKindKeyword = { link = "CmpItemKindKeyword" },
        BlinkCmpKindSnippet = { link = "CmpItemKindSnippet" },
        BlinkCmpKindColor = { link = "CmpItemKindColor" },
        BlinkCmpKindFile = { link = "CmpItemKindFile" },
        BlinkCmpKindReference = { link = "CmpItemKindReference" },
        BlinkCmpKindFolder = { link = "CmpItemKindFolder" },
        BlinkCmpKindEnumMember = { link = "CmpItemKindEnumMember" },
        BlinkCmpKindConstant = { link = "CmpItemKindConstant" },
        BlinkCmpKindStruct = { link = "CmpItemKindStruct" },
        BlinkCmpKindEvent = { link = "CmpItemKindEvent" },
        BlinkCmpKindOperator = { link = "CmpItemKindOperator" },
        BlinkCmpKindTypeParameter = { link = "CmpItemKindTypeParameter" },
    }
    
    -- Apply highlights with fallbacks for better compatibility
    for name, config in pairs(highlights) do
        local success, _ = pcall(vim.api.nvim_set_hl, 0, name, config)
        if not success and config.link then
            -- Fallback to a basic highlight if the link target doesn't exist
            vim.api.nvim_set_hl(0, name, { fg = "#ffffff", bg = "#000000" })
        end
    end
end

-- Setup LSP integration
function M.setup_lsp_integration()
    -- Get LSP capabilities for blink.cmp
    local blink_ok, blink = pcall(require, "blink.cmp")
    if not blink_ok then
        return {}
    end
    
    -- Export capabilities for LSP servers to use
    M.get_lsp_capabilities = function()
        return blink.get_lsp_capabilities()
    end
end

-- Enhanced autocommands for better integration
function M.setup_autocommands()
    local blink_group = vim.api.nvim_create_augroup("BlinkCmpEnhancements", { clear = true })
    
    -- Completion is now disabled for specific filetypes in main setup via enabled() function
    
    -- Note: blink.cmp doesn't support per-buffer configuration like nvim-cmp
    -- Filetype-specific behavior is handled through the main sources configuration
    
    -- Update completion on theme change
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = blink_group,
        callback = function()
            vim.defer_fn(function()
                M.setup_highlights()
            end, 100)
        end,
    })
end

-- Utility function to check if blink.cmp is available
function M.is_available()
    return pcall(require, "blink.cmp")
end

-- Get completion status for statusline integration
function M.get_completion_status()
    local blink_ok, blink = pcall(require, "blink.cmp")
    if not blink_ok then
        return ""
    end
    
    -- You can extend this to show completion status
    return ""
end

-- Debug function to check blink status
function M.debug_status()
    local blink_ok, blink = pcall(require, "blink.cmp")
    print("Blink.cmp loaded:", blink_ok)
    
    if blink_ok then
        print("Blink capabilities:", vim.inspect(blink.get_lsp_capabilities() ~= nil))
    end
    
    -- Check if any sources are active
    print("\nChecking completion sources...")
    print("LSP clients:", #vim.lsp.get_active_clients())
end

-- Create debug command
vim.api.nvim_create_user_command("BlinkDebug", function()
    M.debug_status()
end, { desc = "Debug blink.cmp status" })

return M