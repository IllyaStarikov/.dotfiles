-- GitHub Dark_Dimmed theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#adbac7",
  background = "#22272e",
  cursor_bg = "#adbac7",
  cursor_fg = "#22272e",
  cursor_border = "#adbac7",
  selection_fg = "#adbac7",
  selection_bg = "#444c56",

  -- ANSI colors
  ansi = {
    "#545d68",   -- black
    "#f47067",     -- red
    "#57ab5a",   -- green
    "#c69026",  -- yellow
    "#539bf5",    -- blue
    "#b083f0", -- magenta
    "#39c5cf",    -- cyan
    "#adbac7",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#636e7b",   -- bright black
    "#ff938a",     -- bright red
    "#6bc46d",   -- bright green
    "#daaa3f",  -- bright yellow
    "#6cb6ff",    -- bright blue
    "#dcbdfb", -- bright magenta
    "#56d4dd",    -- bright cyan
    "#cdd9e5",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#3c4047",
    active_tab = {
      bg_color = "#22272e",
      fg_color = "#539bf5",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#3c4047",
      fg_color = "#636e7b",
    },
    inactive_tab_hover = {
      bg_color = "#444c56",
      fg_color = "#539bf5",
      italic = false,
    },
    new_tab = {
      bg_color = "#3c4047",
      fg_color = "#539bf5",
    },
    new_tab_hover = {
      bg_color = "#444c56",
      fg_color = "#539bf5",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#636e7b",

  -- Split lines
  split = "#636e7b",
}

return M
