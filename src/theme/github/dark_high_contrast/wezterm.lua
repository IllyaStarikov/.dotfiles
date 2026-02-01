-- GitHub Dark_High_Contrast theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#f0f3f6",
  background = "#0a0c10",
  cursor_bg = "#f0f3f6",
  cursor_fg = "#0a0c10",
  cursor_border = "#f0f3f6",
  selection_fg = "#f0f3f6",
  selection_bg = "#272b33",

  -- ANSI colors
  ansi = {
    "#7a828e",   -- black
    "#ff9492",     -- red
    "#26cd4d",   -- green
    "#f0b72f",  -- yellow
    "#71b7ff",    -- blue
    "#cb9eff", -- magenta
    "#39c5cf",    -- cyan
    "#f0f3f6",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#9ea7b3",   -- bright black
    "#ffb1af",     -- bright red
    "#4ae168",   -- bright green
    "#f7c843",  -- bright yellow
    "#91cbff",    -- bright blue
    "#dbb7ff", -- bright magenta
    "#56d4dd",    -- bright cyan
    "#ffffff",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#27292c",
    active_tab = {
      bg_color = "#0a0c10",
      fg_color = "#71b7ff",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#27292c",
      fg_color = "#9ea7b3",
    },
    inactive_tab_hover = {
      bg_color = "#272b33",
      fg_color = "#71b7ff",
      italic = false,
    },
    new_tab = {
      bg_color = "#27292c",
      fg_color = "#71b7ff",
    },
    new_tab_hover = {
      bg_color = "#272b33",
      fg_color = "#71b7ff",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#9ea7b3",

  -- Split lines
  split = "#9ea7b3",
}

return M
