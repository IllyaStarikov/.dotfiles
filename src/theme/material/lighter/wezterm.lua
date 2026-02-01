-- Material Lighter theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#546e7a",
  background = "#fafafa",
  cursor_bg = "#546e7a",
  cursor_fg = "#fafafa",
  cursor_border = "#546e7a",
  selection_fg = "#546e7a",
  selection_bg = "#ccd7da",

  -- ANSI colors
  ansi = {
    "#546e7a",   -- black
    "#ff5370",     -- red
    "#91b859",   -- green
    "#f6a434",  -- yellow
    "#6182b8",    -- blue
    "#7c4dff", -- magenta
    "#39adb5",    -- cyan
    "#ffffff",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#546e7a",   -- bright black
    "#ff5370",     -- bright red
    "#91b859",   -- bright green
    "#f6a434",  -- bright yellow
    "#6182b8",    -- bright blue
    "#7c4dff", -- bright magenta
    "#39adb5",    -- bright cyan
    "#ffffff",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#e6e6e6",
    active_tab = {
      bg_color = "#fafafa",
      fg_color = "#7c4dff",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#e6e6e6",
      fg_color = "#546e7a",
    },
    inactive_tab_hover = {
      bg_color = "#ccd7da",
      fg_color = "#7c4dff",
      italic = false,
    },
    new_tab = {
      bg_color = "#e6e6e6",
      fg_color = "#7c4dff",
    },
    new_tab_hover = {
      bg_color = "#ccd7da",
      fg_color = "#7c4dff",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#546e7a",

  -- Split lines
  split = "#546e7a",
}

return M
