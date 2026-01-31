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
opt.colorcolumn = "100"
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

--- Main theme setup function that reads macOS appearance and applies appropriate themes
--- @return nil
function M.setup_theme()
  local config_file = vim.fn.expand("~/.config/theme/current-theme.sh")

  if vim.fn.filereadable(config_file) == 1 then
    -- Source the theme config and get environment variables
    local theme_cmd = "source " .. config_file .. " && echo $MACOS_THEME"
    local variant_cmd = "source " .. config_file .. " && echo $MACOS_VARIANT"
    -- MACOS_VARIANT is the single source of truth for light/dark

    local theme = vim.fn.system(theme_cmd):gsub("\n", "")
    local variant = vim.fn.system(variant_cmd):gsub("\n", "")

    -- Handle legacy format where theme is just "light" or "dark"
    if theme == "light" then
      theme = "tokyonight_day"
      variant = "light"
    elseif theme == "dark" then
      theme = "tokyonight_moon"
      variant = "dark"
    end

    -- Set background based on variant
    if variant == "dark" then
      vim.opt.background = "dark"
    else
      vim.opt.background = "light"
    end

    -- Apply colorscheme based on current theme
    if theme == "tokyonight_moon" then
      vim.opt.background = "dark"
      local ok, tokyonight = pcall(require, "tokyonight")
      if ok then
        tokyonight.setup({
          style = "moon",
          transparent = false,
          styles = {
            comments = { italic = true },
            keywords = { italic = true },
          },
        })
      end
      pcall(function()
        vim.cmd("colorscheme tokyonight-moon")
      end)
    elseif theme == "tokyonight_storm" then
      vim.opt.background = "dark"
      local ok, tokyonight = pcall(require, "tokyonight")
      if ok then
        tokyonight.setup({
          style = "storm",
          transparent = false,
          styles = {
            comments = { italic = true },
            keywords = { italic = true },
          },
        })
      end
      pcall(function()
        vim.cmd("colorscheme tokyonight-storm")
      end)
    elseif theme == "tokyonight_night" then
      vim.opt.background = "dark"
      -- Ensure Tokyo Night plugin is configured before loading
      local ok, tokyonight = pcall(require, "tokyonight")
      if ok then
        tokyonight.setup({
          style = "night",
          transparent = false,
          styles = {
            comments = { italic = true },
            keywords = { italic = true },
          },
        })
      end
      -- Set the style global for compatibility
      vim.g.tokyonight_style = "night"
      -- Try to load the colorscheme with error handling
      local status_ok = pcall(function()
        vim.cmd("colorscheme tokyonight-night")
      end)
      if not status_ok then
        -- Fallback to basic tokyonight command
        vim.cmd("colorscheme tokyonight")
      end
    elseif theme == "tokyonight_day" then
      vim.opt.background = "light"
      local ok, tokyonight = pcall(require, "tokyonight")
      if ok then
        tokyonight.setup({
          style = "day",
          transparent = false,
          styles = {
            comments = { italic = true },
            keywords = { italic = true },
          },
        })
      end
      pcall(function()
        vim.cmd("colorscheme tokyonight-day")
      end)
    else
      -- Default fallback to Tokyo Night Moon
      vim.opt.background = "dark"
      local ok, tokyonight = pcall(require, "tokyonight")
      if ok then
        tokyonight.setup({
          style = "moon",
          transparent = false,
          styles = {
            comments = { italic = true },
            keywords = { italic = true },
          },
        })
      end
      pcall(function()
        vim.cmd("colorscheme tokyonight-moon")
      end)
    end
  else
    -- Default to dark theme if config file doesn't exist
    vim.opt.background = "dark"
    local ok, tokyonight = pcall(require, "tokyonight")
    if ok then
      tokyonight.setup({
        style = "moon",
        transparent = false,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
        },
      })
    end
    vim.cmd("colorscheme tokyonight-moon")
  end

  -- Apply intelligent syntax highlighting optimizations
  vim.schedule(function()
    local current_bg = vim.o.background

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
      vim.cmd("highlight String guifg=#032F62 ctermfg=28") -- Dark blue strings
      vim.cmd("highlight Number guifg=#0451A5 ctermfg=26") -- Blue numbers
      vim.cmd("highlight Constant guifg=#0451A5 ctermfg=26") -- Blue constants
      vim.cmd("highlight PreProc guifg=#AF00DB ctermfg=129") -- Purple preprocessor
      vim.cmd("highlight Type guifg=#0451A5 ctermfg=26") -- Blue types
      vim.cmd("highlight Special guifg=#FF6600 ctermfg=202") -- Orange special chars
    end

    -- Theme changes are automatically applied by mini.statusline
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

-- Command to force Tokyo Night theme reload
vim.api.nvim_create_user_command("TokyoNight", function(args)
  local style = args.args ~= "" and args.args or "moon"
  vim.opt.background = style == "day" and "light" or "dark"

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
    vim.notify("Tokyo Night plugin not found", vim.log.levels.WARN)
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
