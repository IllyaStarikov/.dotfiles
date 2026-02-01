-- Monokai Pro Octagon theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#eaf2f1",
  background = "#282a3a",
  cursor_bg = "#eaf2f1",
  cursor_fg = "#282a3a",
  cursor_border = "#eaf2f1",
  selection_fg = "#eaf2f1",
  selection_bg = "#696d77",

  -- ANSI colors
  ansi = {
    "#696d77",   -- black
    "#ff657a",     -- red
    "#bad761",   -- green
    "#ffd76d",  -- yellow
    "#9cd1bb",    -- blue
    "#c39ac9", -- magenta
    "#9cd1bb",    -- cyan
    "#eaf2f1",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#888d94",   -- bright black
    "#ff657a",     -- bright red
    "#bad761",   -- bright green
    "#ffd76d",  -- bright yellow
    "#9cd1bb",    -- bright blue
    "#c39ac9", -- bright magenta
    "#9cd1bb",    -- bright cyan
    "#eaf2f1",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#414351",
    active_tab = {
      bg_color = "#282a3a",
      fg_color = "#ff9b5e",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#414351",
      fg_color = "#888d94",
    },
    inactive_tab_hover = {
      bg_color = "#696d77",
      fg_color = "#ff9b5e",
      italic = false,
    },
    new_tab = {
      bg_color = "#414351",
      fg_color = "#ff9b5e",
    },
    new_tab_hover = {
      bg_color = "#696d77",
      fg_color = "#ff9b5e",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#888d94",

  -- Split lines
  split = "#888d94",
}

return M
