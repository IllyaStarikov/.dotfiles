-- Iceberg Dark theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#c6c8d1",
  background = "#161821",
  cursor_bg = "#c6c8d1",
  cursor_fg = "#161821",
  cursor_border = "#c6c8d1",
  selection_fg = "#c6c8d1",
  selection_bg = "#272c42",

  -- ANSI colors
  ansi = {
    "#1e2132",   -- black
    "#e27878",     -- red
    "#b4be82",   -- green
    "#e2a478",  -- yellow
    "#84a0c6",    -- blue
    "#a093c7", -- magenta
    "#89b8c2",    -- cyan
    "#c6c8d1",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#6b7089",   -- bright black
    "#e98989",     -- bright red
    "#c0ca8e",   -- bright green
    "#e9b189",  -- bright yellow
    "#91acd1",    -- bright blue
    "#ada0d3", -- bright magenta
    "#95c4ce",    -- bright cyan
    "#d2d4de",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#1e2132",
    active_tab = {
      bg_color = "#161821",
      fg_color = "#84a0c6",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#1e2132",
      fg_color = "#6b7089",
    },
    inactive_tab_hover = {
      bg_color = "#3d435c",
      fg_color = "#84a0c6",
      italic = false,
    },
    new_tab = {
      bg_color = "#1e2132",
      fg_color = "#84a0c6",
    },
    new_tab_hover = {
      bg_color = "#3d435c",
      fg_color = "#84a0c6",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#6b7089",

  -- Split lines
  split = "#6b7089",
}

return M
