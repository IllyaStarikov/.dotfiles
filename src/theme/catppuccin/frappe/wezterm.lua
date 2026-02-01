-- Catppuccin Frappe theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#c6d0f5",
  background = "#303446",
  cursor_bg = "#c6d0f5",
  cursor_fg = "#303446",
  cursor_border = "#c6d0f5",
  selection_fg = "#c6d0f5",
  selection_bg = "#51576d",

  -- ANSI colors
  ansi = {
    "#51576d",   -- black
    "#e78284",     -- red
    "#a6d189",   -- green
    "#e5c890",  -- yellow
    "#8caaee",    -- blue
    "#f4b8e4", -- magenta
    "#81c8be",    -- cyan
    "#b5bfe2",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#626880",   -- bright black
    "#e78284",     -- bright red
    "#a6d189",   -- bright green
    "#e5c890",  -- bright yellow
    "#8caaee",    -- bright blue
    "#f4b8e4", -- bright magenta
    "#81c8be",    -- bright cyan
    "#a5adce",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#484c5c",
    active_tab = {
      bg_color = "#303446",
      fg_color = "#8caaee",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#484c5c",
      fg_color = "#626880",
    },
    inactive_tab_hover = {
      bg_color = "#51576d",
      fg_color = "#8caaee",
      italic = false,
    },
    new_tab = {
      bg_color = "#484c5c",
      fg_color = "#8caaee",
    },
    new_tab_hover = {
      bg_color = "#51576d",
      fg_color = "#8caaee",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#626880",

  -- Split lines
  split = "#626880",
}

return M
