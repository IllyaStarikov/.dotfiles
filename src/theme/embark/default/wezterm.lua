-- Embark theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#cbe3e7",
  background = "#1e1c31",
  cursor_bg = "#a1efd3",
  cursor_fg = "#1e1c31",
  cursor_border = "#a1efd3",
  selection_fg = "#cbe3e7",
  selection_bg = "#3e3859",

  -- ANSI colors
  ansi = {
    "#1e1c31",   -- black
    "#f0719b",     -- red
    "#a1efd3",   -- green
    "#ffe6b3",  -- yellow
    "#91ddff",    -- blue
    "#d4bfff", -- magenta
    "#abf8f7",    -- cyan
    "#cbe3e7",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#3e3859",   -- bright black
    "#f02e6e",     -- bright red
    "#2ce592",   -- bright green
    "#ffb378",  -- bright yellow
    "#78a8ff",    -- bright blue
    "#a742ea", -- bright magenta
    "#63f2f1",    -- bright cyan
    "#f8f8f2",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#100e23",
    active_tab = {
      bg_color = "#1e1c31",
      fg_color = "#91ddff",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#100e23",
      fg_color = "#8a889d",
    },
    inactive_tab_hover = {
      bg_color = "#585273",
      fg_color = "#91ddff",
      italic = false,
    },
    new_tab = {
      bg_color = "#100e23",
      fg_color = "#91ddff",
    },
    new_tab_hover = {
      bg_color = "#585273",
      fg_color = "#91ddff",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#3e3859",

  -- Split lines
  split = "#3e3859",
}

return M
