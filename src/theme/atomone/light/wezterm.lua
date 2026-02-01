-- Atom One Light theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#383a42",
  background = "#fafafa",
  cursor_bg = "#383a42",
  cursor_fg = "#fafafa",
  cursor_border = "#383a42",
  selection_fg = "#383a42",
  selection_bg = "#d0d0d1",

  -- ANSI colors
  ansi = {
    "#a0a1a7",   -- black
    "#e45649",     -- red
    "#50a14f",   -- green
    "#c18401",  -- yellow
    "#4078f2",    -- blue
    "#a626a4", -- magenta
    "#0184bc",    -- cyan
    "#fafafa",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#696c77",   -- bright black
    "#e45649",     -- bright red
    "#50a14f",   -- bright green
    "#c18401",  -- bright yellow
    "#4078f2",    -- bright blue
    "#a626a4", -- bright magenta
    "#0184bc",    -- bright cyan
    "#fafafa",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#e6e6e6",
    active_tab = {
      bg_color = "#fafafa",
      fg_color = "#4078f2",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#e6e6e6",
      fg_color = "#696c77",
    },
    inactive_tab_hover = {
      bg_color = "#d0d0d1",
      fg_color = "#4078f2",
      italic = false,
    },
    new_tab = {
      bg_color = "#e6e6e6",
      fg_color = "#4078f2",
    },
    new_tab_hover = {
      bg_color = "#d0d0d1",
      fg_color = "#4078f2",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#696c77",

  -- Split lines
  split = "#696c77",
}

return M
