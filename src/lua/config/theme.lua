--
-- config/theme.lua
-- Dynamic theme system with macOS integration
--
-- Features:
-- • Automatic theme switching based on macOS Dark/Light mode
-- • Support for multiple colorschemes (Dracula, Iceberg, GitHub themes)
-- • Intelligent comment color adaptation for readability
-- • Real-time theme reloading when system appearance changes
-- • Fallback handling for missing theme configurations
--

-- =============================================================================
-- THEME CONFIGURATION FUNCTION
-- =============================================================================

--- Main theme setup function that reads macOS appearance and applies appropriate themes
--- @return nil
local function setup_theme()
  local config_file = vim.fn.expand("~/.config/theme-switcher/current-theme.sh")
  
  if vim.fn.filereadable(config_file) == 1 then
    -- Source the theme config and get environment variables
    local theme_cmd = "source " .. config_file .. " && echo $MACOS_THEME"
    local variant_cmd = "source " .. config_file .. " && echo $MACOS_VARIANT"
    local background_cmd = "source " .. config_file .. " && echo $MACOS_BACKGROUND"
    
    local theme = vim.fn.system(theme_cmd):gsub('\n', '')
    local variant = vim.fn.system(variant_cmd):gsub('\n', '')
    local background = vim.fn.system(background_cmd):gsub('\n', '')
    
    -- Set background
    if background == "dark" then
      vim.opt.background = "dark"
    else
      vim.opt.background = "light"
    end
    
    -- Apply colorscheme and airline theme based on current theme
    if theme == "dracula" then
      vim.cmd("colorscheme dracula")
      vim.opt.background = "dark"
      vim.g.airline_theme = 'dracula'
    elseif theme == "iceberg_light" then
      vim.cmd("colorscheme iceberg")
      vim.g.airline_theme = 'iceberg'
      vim.opt.background = "light"
    elseif theme == "iceberg_dark" then
      vim.cmd("colorscheme iceberg")
      vim.g.airline_theme = 'iceberg'
      vim.opt.background = "dark"
    elseif theme == "tron" then
      if variant == "dark" then
        vim.cmd("colorscheme iceberg")
        vim.g.airline_theme = 'iceberg'
      else
        vim.cmd("colorscheme iceberg")
        vim.g.airline_theme = 'iceberg'
      end
    elseif theme == "github_light" then
      vim.cmd("colorscheme github_light")
      vim.g.airline_theme = 'sol'
    elseif theme == "github_light_default" then
      vim.cmd("colorscheme github_light_default")
      vim.g.airline_theme = 'sol'
    elseif theme == "github_light_high_contrast" then
      vim.cmd("colorscheme github_light_high_contrast")
      vim.g.airline_theme = 'sol'
    elseif theme == "github_light_colorblind" then
      vim.cmd("colorscheme github_light_colorblind")
      vim.g.airline_theme = 'sol'
    elseif theme == "github_light_tritanopia" then
      vim.cmd("colorscheme github_light_tritanopia")
      vim.g.airline_theme = 'sol'
    elseif theme == "github_dark" then
      vim.cmd("colorscheme github_dark_default")
      vim.g.airline_theme = 'base16_grayscale'
    elseif theme == "github_dark_default" then
      vim.cmd("colorscheme github_dark_default")
      vim.g.airline_theme = 'base16_grayscale'
    elseif theme == "github_dark_dimmed" then
      vim.cmd("colorscheme github_dark_dimmed")
      vim.g.airline_theme = 'base16_grayscale'
    elseif theme == "github_dark_high_contrast" then
      vim.cmd("colorscheme github_dark_high_contrast")
      vim.g.airline_theme = 'base16_grayscale'
    elseif theme == "github_dark_colorblind" then
      vim.cmd("colorscheme github_dark_colorblind")
      vim.g.airline_theme = 'base16_grayscale'
    elseif theme == "github_dark_tritanopia" then
      vim.cmd("colorscheme github_dark_tritanopia")
      vim.g.airline_theme = 'base16_grayscale'
    else
      -- Default fallback
      vim.cmd("colorscheme iceberg")
      vim.g.airline_theme = 'iceberg'
    end
  else
    -- Default to dark theme if config file doesn't exist
    vim.opt.background = "dark"
    vim.cmd("colorscheme dracula")
  end
  
  -- Apply intelligent syntax highlighting optimizations
  vim.schedule(function()
    local current_bg = vim.opt.background:get()
    
    -- Smart comment colors based on background
    if current_bg == "dark" then
      -- Dark background: lighter, more visible comment colors
      vim.cmd("highlight Comment guifg=#6272A4 ctermfg=61 cterm=italic gui=italic")
      vim.cmd("highlight CommentDoc guifg=#7289DA ctermfg=68 cterm=italic gui=italic")
    else
      -- Light background: darker, high-contrast comment colors  
      vim.cmd("highlight Comment guifg=#5C6370 ctermfg=59 cterm=italic gui=italic")
      vim.cmd("highlight CommentDoc guifg=#4078C0 ctermfg=32 cterm=italic gui=italic")
    end
    
    -- Light theme syntax optimizations for better readability
    if current_bg == "light" then
      vim.cmd("highlight String guifg=#032F62 ctermfg=28")     -- Dark blue strings
      vim.cmd("highlight Number guifg=#0451A5 ctermfg=26")     -- Blue numbers
      vim.cmd("highlight Constant guifg=#0451A5 ctermfg=26")   -- Blue constants
      vim.cmd("highlight PreProc guifg=#AF00DB ctermfg=129")   -- Purple preprocessor
      vim.cmd("highlight Type guifg=#0451A5 ctermfg=26")       -- Blue types
      vim.cmd("highlight Special guifg=#FF6600 ctermfg=202")   -- Orange special chars
    end
    
    -- Refresh airline to apply theme changes
    if vim.fn.exists(":AirlineRefresh") == 2 then
      vim.cmd("AirlineRefresh")
    end
  end)
end

-- =============================================================================
-- INITIALIZATION AND AUTO-RELOAD
-- =============================================================================

-- Apply theme configuration on startup
setup_theme()

-- Auto-reload theme when the config file changes
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = vim.fn.expand("~/.config/theme-switcher/current-theme.sh"),
  callback = setup_theme,
  group = vim.api.nvim_create_augroup("ThemeReload", { clear = true })
})

-- =============================================================================
-- USER COMMANDS
-- =============================================================================

-- Convenient commands for manual theme management
vim.api.nvim_create_user_command("ReloadTheme", setup_theme, {
  desc = "Reload the current theme and fix comment colors"
})

vim.api.nvim_create_user_command("FixComments", function()
  local current_bg = vim.opt.background:get()
  
  if current_bg == "dark" then
    vim.cmd("highlight Comment guifg=#6272A4 ctermfg=61 cterm=italic gui=italic")
    vim.cmd("highlight CommentDoc guifg=#7289DA ctermfg=68 cterm=italic gui=italic")
    print("Applied dark theme comment colors")
  else
    vim.cmd("highlight Comment guifg=#5C6370 ctermfg=59 cterm=italic gui=italic")
    vim.cmd("highlight CommentDoc guifg=#4078C0 ctermfg=32 cterm=italic gui=italic")
    print("Applied light theme comment colors")
  end
end, {
  desc = "Fix comment colors for current background"
})