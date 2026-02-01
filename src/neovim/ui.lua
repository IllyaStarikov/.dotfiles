--------------------------------------------------------------------------------
-- ui.lua - UI configuration (consolidated from ui/*.lua)
--
-- DESCRIPTION:
--   Combined UI settings including appearance, ligatures, and theme management.
--   Merged from separate modules for directory consolidation.
--
-- SECTIONS:
--   1. Appearance - Display settings, fonts, UI elements
--   2. Ligatures - JetBrainsMono ligature support
--   3. Theme - Dynamic theme system with macOS integration
--
-- FEATURES:
--   - Automatic theme switching based on macOS Dark/Light mode
--   - Support for Tokyo Night theme variants
--   - Intelligent comment color adaptation
--   - JetBrainsMono Nerd Font with ligatures
--------------------------------------------------------------------------------

local M = {}
local opt = vim.opt
local g = vim.g

-- =============================================================================
-- APPEARANCE SETTINGS
-- =============================================================================

-- Display settings
opt.linebreak = true -- wrap at word boundaries
opt.formatoptions:remove("t") -- Don't auto-wrap text

-- GUI font settings with ligature support
-- Canonical values defined in config/standards.json
if vim.fn.has("gui_running") == 1 or vim.g.neovide then
  opt.guifont = "JetBrainsMono Nerd Font:h18"
  -- Enable ligatures in Neovide
  if vim.g.neovide then
    vim.g.neovide_ligatures = true
  end
end

-- Unicode and encoding
opt.fileencoding = "utf-8"

-- Ensure terminal supports unicode
if vim.fn.has("multi_byte") == 1 then
  if vim.o.encoding ~= "utf-8" then
    vim.o.encoding = "utf-8"
  end
end

-- Tell Neovim we have a nerd font
g.have_nerd_font = true

-- UI elements
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes" -- always show to avoid text shifting
opt.cursorline = true
opt.colorcolumn = "" -- Using virt-column.nvim instead
opt.termguicolors = true
opt.pumheight = 10
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen" -- keep screen position on split
opt.equalalways = true -- always keep splits equal size

-- Text display
opt.showbreak = "↪ "

-- Whitespace visibility
opt.list = true
opt.listchars = {
  tab = "→ ",
  nbsp = "·",
  trail = "·",
  extends = "›",
  precedes = "‹",
  eol = "¬",
}

-- Bracket/parenthesis matching
opt.showmatch = true
opt.matchtime = 2 -- tenths of a second

-- Cursor behavior
opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"
  .. ",a:blinkwait700-blinkoff400-blinkon250"
  .. ",sm:block-blinkwait175-blinkoff150-blinkon175"

-- =============================================================================
-- LIGATURE SUPPORT
-- =============================================================================

local function setup_ligatures()
  -- Terminal Neovim doesn't support ligatures directly
  -- They are rendered by the terminal emulator (Alacritty, iTerm2, etc.)

  -- For GUI Neovim (Neovide, VimR, etc.)
  if vim.fn.has("gui_running") == 1 or vim.g.neovide then
    -- Ensure proper font with ligature support
    vim.opt.guifont = "JetBrainsMono Nerd Font:h18"

    -- Neovide-specific ligature settings
    if vim.g.neovide then
      vim.g.neovide_ligatures = true
    end

    -- MacVim/GVim ligature settings
    if vim.fn.has("gui_macvim") == 1 then
      vim.cmd([[set macligatures]])
    end
  end

  -- Ensure proper rendering settings
  vim.opt.conceallevel = 0 -- Don't conceal text (let ligatures show)
  vim.opt.ambiwidth = "single" -- Proper width calculation

  -- JetBrainsMono ligatures include:
  -- Arrows: -> => ==> --> <-- <== <= >= >> << >>> <<<
  -- Comparison: == === != !== <= >= <> /=
  -- Logic: && || !! ?? ?. ?:
  -- Comments: // /* */ /** <!-- -->
  -- Math: ++ -- ** // %%
  -- Functions: => |> <| :: ::: .. ...
  -- Special: ## ### #### __ ___ ~~ ~~~ ~= ~- -~ =~ !~
  -- Brackets: </ /> <> </>
  -- Assignment: := += -= *= /= %= &= |= ^= <<= >>= >>>= //= **=
  -- Other: www #{ #[ ]# :: ::: !! ?? ?. ?: <| |> <$> <*> <+> \\ \\\ ///

  -- Note: Actual rendering depends on terminal emulator support
  -- Alacritty, iTerm2, Kitty, and WezTerm all support ligatures
  -- Standard Terminal.app does NOT support ligatures
end

-- =============================================================================
-- THEME CONFIGURATION
-- =============================================================================

-- Cache for themes.json configuration
local theme_config_cache = nil

--- Load theme configuration from JSON
--- @return table|nil
local function load_theme_config()
  if theme_config_cache then
    return theme_config_cache
  end

  local config_path = vim.fn.expand("~/.dotfiles/config/themes.json")
  if vim.fn.filereadable(config_path) ~= 1 then
    return nil
  end

  local content = vim.fn.readfile(config_path)
  if not content or #content == 0 then
    return nil
  end

  local ok, config = pcall(vim.fn.json_decode, table.concat(content, "\n"))
  if ok and config then
    theme_config_cache = config
    return config
  end

  return nil
end

--- Get theme info from JSON config
--- @param theme_name string Theme name in family_variant format
--- @return table|nil
local function get_theme_info(theme_name)
  local config = load_theme_config()
  if not config then
    return nil
  end

  local family, variant = theme_name:match("^([a-z0-9]+)_(.+)$")
  if not family or not variant then
    return nil
  end

  local family_config = config.families and config.families[family]
  if not family_config or not family_config.variants then
    return nil
  end

  local variant_info = family_config.variants[variant]
  if variant_info then
    return {
      family = family,
      variant = variant,
      mode = variant_info.mode or "dark",
      colorscheme = variant_info.neovim_colorscheme,
      style = variant_info.neovim_style,
      plugin = family_config.neovim_plugin,
    }
  end

  return nil
end

--- Check if a local colorscheme exists
--- @param name string Colorscheme name (family_variant format)
--- @return boolean
local function local_colorscheme_exists(name)
  -- Check if colorscheme file exists in our colors directory
  local colors_dir = vim.fn.expand("~/.dotfiles/src/neovim/colors")
  local colorscheme_file = colors_dir .. "/" .. name .. ".lua"
  return vim.fn.filereadable(colorscheme_file) == 1
end

--- Main theme setup function that reads macOS appearance and applies appropriate themes
--- @return nil
function M.setup_theme()
  local config_file = vim.fn.expand("~/.config/theme/current-theme.sh")
  local theme = "tokyonight_moon"
  local variant = "dark"

  if vim.fn.filereadable(config_file) == 1 then
    local theme_cmd = "source " .. config_file .. " && echo $MACOS_THEME"
    local variant_cmd = "source " .. config_file .. " && echo $MACOS_VARIANT"

    theme = vim.fn.system(theme_cmd):gsub("\n", "")
    variant = vim.fn.system(variant_cmd):gsub("\n", "")

    -- Handle legacy format
    if theme == "light" then
      theme = "tokyonight_day"
      variant = "light"
    elseif theme == "dark" then
      theme = "tokyonight_moon"
      variant = "dark"
    end
  end

  -- Get theme info from JSON config
  local theme_info = get_theme_info(theme)

  -- Set background
  vim.opt.background = (theme_info and theme_info.mode) or variant or "dark"

  -- Apply theme using local colorscheme files
  -- Local colorschemes are generated from colors.json and stored in src/neovim/colors/
  -- Format: family_variant (e.g., catppuccin_mocha, github_dark, tokyonight_storm)
  if local_colorscheme_exists(theme) then
    local ok = pcall(vim.cmd, "colorscheme " .. theme)
    if not ok then
      -- Fallback to tokyonight_moon
      pcall(vim.cmd, "colorscheme tokyonight_moon")
    end
  elseif theme_info and theme_info.colorscheme then
    -- Try external plugin colorscheme as fallback
    local ok = pcall(vim.cmd, "colorscheme " .. theme_info.colorscheme)
    if not ok then
      pcall(vim.cmd, "colorscheme tokyonight_moon")
    end
  else
    -- Ultimate fallback
    pcall(vim.cmd, "colorscheme tokyonight_moon")
  end

  -- Apply syntax highlighting optimizations
  vim.schedule(function()
    local current_bg = vim.o.background

    if current_bg == "dark" then
      vim.cmd("highlight Comment guifg=#6272A4 ctermfg=61 cterm=italic gui=italic")
      vim.cmd("highlight CommentDoc guifg=#7289DA ctermfg=68 cterm=italic gui=italic")
    else
      vim.cmd("highlight Comment guifg=#5C6370 ctermfg=59 cterm=italic gui=italic")
      vim.cmd("highlight CommentDoc guifg=#4078C0 ctermfg=32 cterm=italic gui=italic")
    end

    if current_bg == "light" then
      vim.cmd("highlight String guifg=#032F62 ctermfg=28")
      vim.cmd("highlight Number guifg=#0451A5 ctermfg=26")
      vim.cmd("highlight Constant guifg=#0451A5 ctermfg=26")
      vim.cmd("highlight PreProc guifg=#AF00DB ctermfg=129")
      vim.cmd("highlight Type guifg=#0451A5 ctermfg=26")
      vim.cmd("highlight Special guifg=#FF6600 ctermfg=202")
    end
  end)
end

-- =============================================================================
-- USER COMMANDS
-- =============================================================================

-- Auto-reload theme when the config file changes
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = vim.fn.expand("~/.config/theme/current-theme.sh"),
  callback = M.setup_theme,
  group = vim.api.nvim_create_augroup("ThemeReload", { clear = true }),
})

-- Convenient commands for manual theme management
vim.api.nvim_create_user_command("ReloadTheme", M.setup_theme, {
  desc = "Reload the current theme and adjust colors",
})

vim.api.nvim_create_user_command("FixComments", function()
  local current_bg = vim.o.background

  if current_bg == "dark" then
    vim.cmd("highlight Comment guifg=#6272A4 ctermfg=61 cterm=italic gui=italic")
    vim.cmd("highlight CommentDoc guifg=#7289DA ctermfg=68 cterm=italic gui=italic")
  else
    vim.cmd("highlight Comment guifg=#5C6370 ctermfg=59 cterm=italic gui=italic")
    vim.cmd("highlight CommentDoc guifg=#4078C0 ctermfg=32 cterm=italic gui=italic")
  end
end, {
  desc = "Fix comment colors for current background",
})

-- Command to switch themes dynamically
vim.api.nvim_create_user_command("Theme", function(args)
  local theme_name = args.args
  if theme_name == "" then
    vim.notify("Current theme: " .. (vim.g.colors_name or "unknown"), vim.log.levels.INFO)
    return
  end

  local theme_info = get_theme_info(theme_name)
  if theme_info then
    vim.opt.background = theme_info.mode or "dark"
  end

  -- Try local colorscheme first, then fall back to plugin colorscheme
  if local_colorscheme_exists(theme_name) then
    local ok = pcall(vim.cmd, "colorscheme " .. theme_name)
    if ok then
      vim.notify("Theme: " .. theme_name, vim.log.levels.INFO)
    else
      vim.notify("Failed to load theme: " .. theme_name, vim.log.levels.ERROR)
    end
  elseif theme_info and theme_info.colorscheme then
    local ok = pcall(vim.cmd, "colorscheme " .. theme_info.colorscheme)
    if ok then
      vim.notify("Theme: " .. theme_name, vim.log.levels.INFO)
    else
      vim.notify("Failed to load theme: " .. theme_name, vim.log.levels.ERROR)
    end
  else
    vim.notify("Unknown theme: " .. theme_name, vim.log.levels.ERROR)
  end
end, {
  nargs = "?",
  complete = function()
    local config = load_theme_config()
    if not config or not config.families then
      return { "tokyonight_moon", "tokyonight_storm", "tokyonight_day", "tokyonight_night" }
    end

    local themes = {}
    for family, family_config in pairs(config.families) do
      if family_config.variants then
        for variant, _ in pairs(family_config.variants) do
          table.insert(themes, family .. "_" .. variant)
        end
      end
    end
    table.sort(themes)
    return themes
  end,
  desc = "Switch to a theme (e.g., :Theme catppuccin_mocha)",
})

-- Command to force Tokyo Night theme reload (backward compatibility)
vim.api.nvim_create_user_command("TokyoNight", function(args)
  local style = args.args ~= "" and args.args or "moon"
  vim.opt.background = style == "day" and "light" or "dark"

  -- Use local colorscheme (tokyonight_moon, tokyonight_storm, etc.)
  local theme_name = "tokyonight_" .. style
  if local_colorscheme_exists(theme_name) then
    pcall(vim.cmd, "colorscheme " .. theme_name)
  else
    -- Fall back to plugin if local colorscheme not found
    local ok, tokyonight = pcall(require, "tokyonight")
    if ok then
      tokyonight.setup({
        style = style,
        transparent = false,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
        },
      })
      vim.g.tokyonight_style = style
      vim.cmd("colorscheme tokyonight-" .. style)
    else
      vim.notify("Tokyo Night colorscheme not found", vim.log.levels.WARN)
    end
  end
end, {
  nargs = "?",
  complete = function()
    return { "night", "moon", "storm", "day" }
  end,
  desc = "Load Tokyo Night theme variant (night, moon, storm, day)",
})

-- =============================================================================
-- INITIALIZATION
-- =============================================================================

-- Setup ligatures on load
setup_ligatures()

-- Note: Theme is loaded lazily after plugins via init.lua
-- Call M.setup_theme() after LazyVimStarted event

return M
