-- Synthwave 84 Default theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#ffffff",
  background = "#262335",
  cursor_bg = "#ffffff",
  cursor_fg = "#262335",
  cursor_border = "#ffffff",
  selection_fg = "#ffffff",
  selection_bg = "#614d85",

  -- ANSI colors
  ansi = {
    "#614d85",   -- black
    "#fe4450",     -- red
    "#72f1b8",   -- green
    "#fede5d",  -- yellow
    "#03edf9",    -- blue
    "#ff7edb", -- magenta
    "#36f9f6",    -- cyan
    "#ffffff",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#7a6a9a",   -- bright black
    "#ff6e7a",     -- bright red
    "#8fffd2",   -- bright green
    "#ffef7d",  -- bright yellow
    "#4effff",    -- bright blue
    "#ff9fe7", -- bright magenta
    "#6cffff",    -- bright cyan
    "#ffffff",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#403d4d",
    active_tab = {
      bg_color = "#262335",
      fg_color = "#ff7edb",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#403d4d",
      fg_color = "#7a6a9a",
    },
    inactive_tab_hover = {
      bg_color = "#614d85",
      fg_color = "#ff7edb",
      italic = false,
    },
    new_tab = {
      bg_color = "#403d4d",
      fg_color = "#ff7edb",
    },
    new_tab_hover = {
      bg_color = "#614d85",
      fg_color = "#ff7edb",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#7a6a9a",

  -- Split lines
  split = "#7a6a9a",
}

return M
