-- Aurora theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#a9b1d6",
  background = "#282c34",
  cursor_bg = "#e7c3fb",
  cursor_fg = "#282c34",
  cursor_border = "#e7c3fb",
  selection_fg = "#a9b1d6",
  selection_bg = "#3a3754",

  -- ANSI colors
  ansi = {
    "#1a1926",   -- black
    "#ff5874",     -- red
    "#addb67",   -- green
    "#ecc48d",  -- yellow
    "#4c77e4",    -- blue
    "#be9af7", -- magenta
    "#a1efe4",    -- cyan
    "#e7c3fb",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#637077",   -- bright black
    "#ff5874",     -- bright red
    "#9ec410",   -- bright green
    "#e7c547",  -- bright yellow
    "#7aa6da",    -- bright blue
    "#b77ee0", -- bright magenta
    "#54ced6",    -- bright cyan
    "#ececec",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#1a1926",
    active_tab = {
      bg_color = "#282c34",
      fg_color = "#be9af7",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#1a1926",
      fg_color = "#5f7e97",
    },
    inactive_tab_hover = {
      bg_color = "#4f4764",
      fg_color = "#be9af7",
      italic = false,
    },
    new_tab = {
      bg_color = "#1a1926",
      fg_color = "#be9af7",
    },
    new_tab_hover = {
      bg_color = "#4f4764",
      fg_color = "#be9af7",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#637077",

  -- Split lines
  split = "#637077",
}

return M
