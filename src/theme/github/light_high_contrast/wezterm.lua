-- GitHub Light_High_Contrast theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#0e1116",
  background = "#ffffff",
  cursor_bg = "#0e1116",
  cursor_fg = "#ffffff",
  cursor_border = "#0e1116",
  selection_fg = "#0e1116",
  selection_bg = "#d0d7de",

  -- ANSI colors
  ansi = {
    "#0e1116",   -- black
    "#a0111f",     -- red
    "#024c1a",   -- green
    "#3f2200",  -- yellow
    "#0349b4",    -- blue
    "#622cbc", -- magenta
    "#1b6f7a",    -- cyan
    "#66707b",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#4b535d",   -- bright black
    "#86061d",     -- bright red
    "#055d20",   -- bright green
    "#4e2c00",  -- bright yellow
    "#1168e3",    -- bright blue
    "#844ae7", -- bright magenta
    "#3192aa",    -- bright cyan
    "#88929d",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#eaeaea",
    active_tab = {
      bg_color = "#ffffff",
      fg_color = "#0349b4",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#eaeaea",
      fg_color = "#4b535d",
    },
    inactive_tab_hover = {
      bg_color = "#d0d7de",
      fg_color = "#0349b4",
      italic = false,
    },
    new_tab = {
      bg_color = "#eaeaea",
      fg_color = "#0349b4",
    },
    new_tab_hover = {
      bg_color = "#d0d7de",
      fg_color = "#0349b4",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#4b535d",

  -- Split lines
  split = "#4b535d",
}

return M
