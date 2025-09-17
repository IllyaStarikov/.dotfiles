-- TokyoNight Storm theme for WezTerm
-- Ported from https://github.com/folke/tokyonight.nvim

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#c0caf5",
  background = "#24283b",
  cursor_bg = "#c0caf5",
  cursor_fg = "#24283b",
  cursor_border = "#c0caf5",
  selection_fg = "#c0caf5",
  selection_bg = "#364a82",

  -- ANSI colors
  ansi = {
    "#1d202f", -- black
    "#f7768e", -- red
    "#9ece6a", -- green
    "#e0af68", -- yellow
    "#7aa2f7", -- blue
    "#bb9af7", -- magenta
    "#7dcfff", -- cyan
    "#a9b1d6", -- white
  },

  -- Bright ANSI colors
  brights = {
    "#414868", -- bright black
    "#ff899d", -- bright red
    "#9fe044", -- bright green
    "#faba4a", -- bright yellow
    "#8db0ff", -- bright blue
    "#c7a9ff", -- bright magenta
    "#a4daff", -- bright cyan
    "#c0caf5", -- bright white
  },

  -- Indexed colors
  indexed = {
    [16] = "#ff9e64",
    [17] = "#db4b4b",
  },

  -- Tab bar
  tab_bar = {
    background = "#1f2335",
    active_tab = {
      bg_color = "#24283b",
      fg_color = "#7aa2f7",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#1f2335",
      fg_color = "#545c7e",
    },
    inactive_tab_hover = {
      bg_color = "#292e42",
      fg_color = "#7aa2f7",
      italic = false,
    },
    new_tab = {
      bg_color = "#1f2335",
      fg_color = "#7aa2f7",
    },
    new_tab_hover = {
      bg_color = "#292e42",
      fg_color = "#7aa2f7",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#414868",

  -- Split lines
  split = "#414868",

  -- Visual bell
  visual_bell = "#88c0d0",
}

return M
