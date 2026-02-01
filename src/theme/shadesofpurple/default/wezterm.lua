-- Shades of Purple Default theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#fafafa",
  background = "#1e1e3f",
  cursor_bg = "#fafafa",
  cursor_fg = "#1e1e3f",
  cursor_border = "#fafafa",
  selection_fg = "#fafafa",
  selection_bg = "#6d6d6d",

  -- ANSI colors
  ansi = {
    "#6d6d6d",   -- black
    "#ff628c",     -- red
    "#a5ff90",   -- green
    "#ffdd00",  -- yellow
    "#9d8bfe",    -- blue
    "#fad000", -- magenta
    "#80ffea",    -- cyan
    "#ffffff",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#8d8d8d",   -- bright black
    "#ff7e9e",     -- bright red
    "#b8ffa6",   -- bright green
    "#ffe64d",  -- bright yellow
    "#b4a6fe",    -- bright blue
    "#ffe14d", -- bright magenta
    "#9affef",    -- bright cyan
    "#ffffff",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#393956",
    active_tab = {
      bg_color = "#1e1e3f",
      fg_color = "#fad000",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#393956",
      fg_color = "#8d8d8d",
    },
    inactive_tab_hover = {
      bg_color = "#3d3d5c",
      fg_color = "#fad000",
      italic = false,
    },
    new_tab = {
      bg_color = "#393956",
      fg_color = "#fad000",
    },
    new_tab_hover = {
      bg_color = "#3d3d5c",
      fg_color = "#fad000",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#8d8d8d",

  -- Split lines
  split = "#8d8d8d",
}

return M
