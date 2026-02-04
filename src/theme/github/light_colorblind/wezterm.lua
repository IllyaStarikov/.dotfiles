-- GitHub Light Colorblind theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#1b1f24",
  background = "#ffffff",
  cursor_bg = "#1b1f24",
  cursor_fg = "#ffffff",
  cursor_border = "#1b1f24",
  selection_fg = "#1b1f24",
  selection_bg = "#ddf4ff",

  -- ANSI colors
  ansi = {
    "#24292f",   -- black
    "#b35900",     -- red
    "#0550ae",   -- green
    "#4d2d00",  -- yellow
    "#0969da",    -- blue
    "#8250df", -- magenta
    "#1b7c83",    -- cyan
    "#6e7781",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#57606a",   -- bright black
    "#8a4600",     -- bright red
    "#0969da",   -- bright green
    "#633c01",  -- bright yellow
    "#218bff",    -- bright blue
    "#a475f9", -- bright magenta
    "#3192aa",    -- bright cyan
    "#8c959f",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#f6f8fa",
    active_tab = {
      bg_color = "#ffffff",
      fg_color = "#0969da",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#f6f8fa",
      fg_color = "#57606a",
    },
    inactive_tab_hover = {
      bg_color = "#d0d7de",
      fg_color = "#0969da",
      italic = false,
    },
    new_tab = {
      bg_color = "#f6f8fa",
      fg_color = "#0969da",
    },
    new_tab_hover = {
      bg_color = "#d0d7de",
      fg_color = "#0969da",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#57606a",

  -- Split lines
  split = "#57606a",
}

return M
