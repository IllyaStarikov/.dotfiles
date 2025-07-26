--
-- config/menu-highlights.lua
-- Custom highlight groups for enhanced Menu appearance
--

local M = {}

function M.setup()
    -- Define custom highlight groups for menu items
    local highlights = {
        -- Menu category highlights
        MenuKeyword = { fg = "#ff79c6", bold = true },      -- Files, Buffers
        MenuFunction = { fg = "#50fa7b", bold = true },     -- Code operations
        MenuType = { fg = "#8be9fd", bold = true },         -- Settings, Theme
        MenuSpecial = { fg = "#ffb86c", bold = true },      -- AI Assistant
        MenuConstant = { fg = "#f1fa8c", bold = true },     -- Git operations
        MenuString = { fg = "#6272a4", bold = true },       -- Terminal
        MenuPreProc = { fg = "#bd93f9", bold = true },      -- Settings
        MenuIdentifier = { fg = "#ff5555", bold = true },   -- Theme
        MenuDirectory = { fg = "#50fa7b", bold = true },    -- NvimTree
        MenuTerminal = { fg = "#44475a", bg = "#f8f8f2" },  -- Terminal context
        
        -- Menu UI elements
        MenuBorder = { fg = "#6272a4" },
        MenuTitle = { fg = "#f8f8f2", bold = true },
        MenuSelected = { bg = "#44475a", fg = "#f8f8f2" },
        MenuNormal = { bg = "#282a36", fg = "#f8f8f2" },
        
        -- Icon highlights
        MenuIcon = { fg = "#8be9fd" },
        MenuIconFiles = { fg = "#50fa7b" },
        MenuIconGit = { fg = "#f1fa8c" },
        MenuIconCode = { fg = "#bd93f9" },
        MenuIconAI = { fg = "#ffb86c" },
        MenuIconTerminal = { fg = "#6272a4" },
        MenuIconSettings = { fg = "#ff79c6" },
    }
    
    -- Apply highlights
    for name, config in pairs(highlights) do
        vim.api.nvim_set_hl(0, name, config)
    end
    
    -- Create autocmd to maintain highlights after colorscheme changes
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("MenuHighlights", { clear = true }),
        callback = function()
            -- Reapply custom highlights after colorscheme change
            for name, config in pairs(highlights) do
                vim.api.nvim_set_hl(0, name, config)
            end
        end,
    })
end

-- Theme-aware highlight adjustments
function M.setup_theme_aware_highlights()
    local function is_dark_theme()
        return vim.o.background == "dark"
    end
    
    local function adjust_highlights_for_theme()
        if is_dark_theme() then
            -- Dark theme adjustments
            vim.api.nvim_set_hl(0, "MenuNormal", { bg = "#282a36", fg = "#f8f8f2" })
            vim.api.nvim_set_hl(0, "MenuSelected", { bg = "#44475a", fg = "#f8f8f2" })
            vim.api.nvim_set_hl(0, "MenuBorder", { fg = "#6272a4" })
        else
            -- Light theme adjustments
            vim.api.nvim_set_hl(0, "MenuNormal", { bg = "#f8f8f2", fg = "#282a36" })
            vim.api.nvim_set_hl(0, "MenuSelected", { bg = "#e6e6e6", fg = "#282a36" })
            vim.api.nvim_set_hl(0, "MenuBorder", { fg = "#a0a0a0" })
        end
    end
    
    -- Apply theme-aware highlights initially
    adjust_highlights_for_theme()
    
    -- Update highlights when background changes
    vim.api.nvim_create_autocmd("OptionSet", {
        pattern = "background",
        callback = adjust_highlights_for_theme,
    })
end

-- Integration with existing theme system
function M.integrate_with_theme_switcher()
    -- Check if theme switcher exists
    local theme_switcher_ok, theme_switcher = pcall(require, "config.theme")
    if theme_switcher_ok and type(theme_switcher) == "table" and theme_switcher.on_theme_change then
        -- Register callback with theme switcher
        theme_switcher.on_theme_change(function(theme_name)
            M.setup_theme_aware_highlights()
        end)
    end
end

return M