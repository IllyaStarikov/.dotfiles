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
            preset = "default", -- Use the default keymap preset
            
            -- Custom key mappings for enhanced workflow
            ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
            ["<C-e>"] = { "hide", "fallback" },
            ["<CR>"] = { "accept", "fallback" },
            
            -- Navigation
            ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
            ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
            
            -- Smart completion navigation
            ["<C-n>"] = { "select_next", "fallback" },
            ["<C-p>"] = { "select_prev", "fallback" },
            
            -- Documentation
            ["<C-d>"] = { "scroll_documentation_down", "fallback" },
            ["<C-u>"] = { "scroll_documentation_up", "fallback" },
        },
        
        -- Appearance configuration
        appearance = {
            -- Use Nerd Font icons if available
            use_nvim_cmp_as_default = false,
            nerd_font_variant = "mono",
            
            -- Color scheme integration
            theme = "default", -- Adapts to your colorscheme
            
            -- Menu appearance
            menu = {
                border = "rounded",
                winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection",
                
                -- Menu dimensions
                max_height = 15,
                min_width = 15,
                max_width = 60,
                
                -- Scrollbar
                scrollbar = true,
                
                -- Drawing options
                draw = {
                    -- Show completion item details
                    treesitter = { "lsp" },
                    
                    -- Columns to display
                    columns = {
                        { "kind_icon" },
                        { "label", "label_description", gap = 1 },
                        { "source_name" },
                    },
                    
                    -- Component configurations
                    components = {
                        kind_icon = {
                            ellipsis = false,
                            text = function(ctx)
                                -- Fallback to simple icons if mini.icons not available
                                local icons = {
                                    Text = "󰉿", Method = "󰆧", Function = "󰊕", Constructor = "",
                                    Field = "󰜢", Variable = "󰀫", Class = "󰠱", Interface = "",
                                    Module = "", Property = "󰜢", Unit = "󰑭", Value = "󰎠",
                                    Enum = "", Keyword = "󰌋", Snippet = "", Color = "󰏘",
                                    File = "󰈙", Reference = "󰈇", Folder = "󰉋", EnumMember = "",
                                    Constant = "󰏿", Struct = "󰙅", Event = "", Operator = "󰆕",
                                    TypeParameter = "",
                                }
                                return icons[ctx.kind] or ""
                            end,
                            highlight = function(ctx)
                                return "BlinkCmpKind" .. ctx.kind
                            end,
                        }
                    }
                }
            },
            
            -- Documentation window
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 200,
                update_delay_ms = 50,
                
                -- Documentation window appearance
                window = {
                    border = "rounded",
                    winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder",
                    max_width = 80,
                    max_height = 20,
                }
            }
        },
        
        -- Completion behavior
        completion = {
            -- Trigger configuration
            trigger = {
                -- Show completion automatically
                prefetch_on_insert = true,
                show_on_insert_on_trigger_character = true,
                
                -- Character triggers
                show_on_x_blocked_trigger_characters = { " ", "\n", "\t" },
                
                -- Context-aware triggering
                show_in_snippet = true,
            },
            
            -- Completion list behavior
            list = {
                -- Selection behavior
                selection = "preselect", -- preselect | manual | auto_insert
                
                -- Cycling behavior
                cycle = {
                    from_bottom = true,
                    from_top = true,
                }
            },
            
            -- Accept behavior
            accept = {
                -- Auto-bracket support
                create_undo_point = true,
                auto_brackets = {
                    enabled = true,
                    default_brackets = { "(", ")" },
                    override_brackets_for_filetypes = {},
                    force_allow_filetypes = {},
                    blocked_filetypes = {},
                    kind_resolution = {
                        enabled = true,
                        blocked_filetypes = { "rust" }, -- Let rust-analyzer handle this
                    },
                    semantic_token_resolution = {
                        enabled = true,
                        blocked_filetypes = {},
                    }
                }
            },
            
            -- Menu behavior
            menu = {
                enabled = true,
                min_width = 15,
                max_height = 10,
                
                -- Auto-show behavior
                auto_show = function(ctx)
                    return ctx.mode ~= "cmdline" or not vim.tbl_contains({ "/", "?" }, vim.fn.getcmdtype())
                end,
                
                -- Drawing configuration
                draw = {
                    gap = 1,
                    padding = 1,
                    treesitter = { "lsp" },
                }
            },
            
            -- Ghost text (inline suggestions)
            ghost_text = {
                enabled = vim.g.ai_cmp == true,
            }
        },
        
        -- Fuzzy matching configuration
        fuzzy = {
            -- Use the prebuilt binary for best performance
            use_typo_resistance = true,
            use_frecency = true,
            use_proximity = true,
            
            -- Scoring configuration
            sorts = { "label", "kind", "score" },
            
            -- Advanced matching options
            prebuilt_binaries = {
                download = true,
                force_version = nil, -- Use latest compatible version
                ignore_version_mismatch = false,
            }
        },
        
        -- Source configuration
        sources = {
            -- Default sources for all filetypes
            default = { "lsp", "path", "snippets", "buffer" },
            
            -- Filetype-specific sources
            per_filetype = {
                -- Enhanced sources for specific languages
                lua = { "lsp", "path", "snippets", "buffer", "lazydev" },
                python = { "lsp", "path", "snippets", "buffer" },
                rust = { "lsp", "path", "snippets", "buffer" },
                go = { "lsp", "path", "snippets", "buffer" },
                javascript = { "lsp", "path", "snippets", "buffer" },
                typescript = { "lsp", "path", "snippets", "buffer" },
                
                -- Disable completion for certain filetypes
                gitcommit = {},
                oil = {}, -- Oil file manager
                TelescopePrompt = {},
                
                -- Markdown gets enhanced sources
                markdown = { "lsp", "path", "snippets", "buffer" },
            },
            
            -- Command line sources
            cmdline = function()
                local type = vim.fn.getcmdtype()
                if type == "/" or type == "?" then
                    return { "buffer" }
                end
                if type == ":" then
                    return { "cmdline" }
                end
                return {}
            end,
            
            -- Source providers configuration
            providers = {
                lsp = {
                    name = "LSP",
                    module = "blink.cmp.sources.lsp",
                    
                    -- LSP-specific configuration
                    score_offset = 90, -- Prioritize LSP completions
                    
                    -- Filtering
                    keyword_length = 0,
                    
                    -- Trigger configuration
                    trigger_characters = { 
                        ".", ":", "(", '"', "'", "[", ",", "#", 
                        "*", "@", "|", "=", "-", "{", "/", "\\",
                        "+", "?", " ", "\t"
                    },
                },
                
                path = {
                    name = "Path",
                    module = "blink.cmp.sources.path",
                    score_offset = 3,
                    
                    -- Path completion options
                    opts = {
                        trailing_slash = false,
                        label_trailing_slash = true,
                        get_cwd = function(ctx)
                            return vim.fn.expand(("#%d:p:h"):format(ctx.bufnr))
                        end,
                        show_hidden_files_by_default = false,
                    }
                },
                
                snippets = {
                    name = "Snippets",
                    module = "blink.cmp.sources.snippets",
                    score_offset = 85, -- High priority for snippets
                    
                    -- Snippet configuration
                    opts = {
                        friendly_snippets = true,
                        search_paths = { vim.fn.stdpath("config") .. "/snippets" },
                        global_snippets = { "all" },
                        extended_filetypes = {},
                        ignored_filetypes = {},
                    }
                },
                
                buffer = {
                    name = "Buffer",
                    module = "blink.cmp.sources.buffer",
                    score_offset = 5, -- Lower priority than LSP/snippets
                    
                    -- Buffer completion options
                    opts = {
                        -- Get completions from all visible buffers
                        get_bufnrs = function()
                            local bufs = {}
                            for _, win in ipairs(vim.api.nvim_list_wins()) do
                                local buf = vim.api.nvim_win_get_buf(win)
                                if vim.bo[buf].buftype == "" then
                                    bufs[#bufs + 1] = buf
                                end
                            end
                            return bufs
                        end,
                    }
                },
            }
        },
        
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
        
        -- Signature help configuration
        signature = {
            enabled = true,
            trigger = {
                blocked_trigger_characters = {},
                blocked_retrigger_characters = {},
                show_on_insert_on_trigger_character = true,
            },
            window = {
                border = "rounded",
                winhighlight = "Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder",
            }
        }
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
    
    -- LuaSnip configuration
    luasnip.setup({
        -- Enable auto-triggered snippets
        enable_autosnippets = true,
        
        -- Remember last snippet position for quick jumps
        store_selection_keys = "<Tab>",
        
        -- Update events for real-time snippet updates  
        update_events = "TextChanged,TextChangedI",
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
    
    -- Ensure LSP servers get the right capabilities
    local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
    if lspconfig_ok then
        local capabilities = blink.get_lsp_capabilities()
        
        -- Update default capabilities for all LSP servers
        lspconfig.util.default_config = vim.tbl_deep_extend(
            "force",
            lspconfig.util.default_config,
            { capabilities = capabilities }
        )
    end
end

-- Enhanced autocommands for better integration
function M.setup_autocommands()
    local blink_group = vim.api.nvim_create_augroup("BlinkCmpEnhancements", { clear = true })
    
    -- Disable completion in certain contexts
    vim.api.nvim_create_autocmd("FileType", {
        group = blink_group,
        pattern = { "TelescopePrompt", "oil", "alpha", "dashboard" },
        callback = function()
            require("blink.cmp").setup_buffer({ enabled = false })
        end,
    })
    
    -- Enhanced completion for specific filetypes
    vim.api.nvim_create_autocmd("FileType", {
        group = blink_group,
        pattern = { "gitcommit", "markdown" },
        callback = function()
            -- Adjust completion behavior for text-based files
            require("blink.cmp").setup_buffer({
                sources = {
                    default = { "buffer", "snippets" },
                }
            })
        end,
    })
    
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

return M