-- GitHub Light Default theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#1f2328",
  background = "#ffffff",
  cursor_bg = "#1f2328",
  cursor_fg = "#ffffff",
  cursor_border = "#1f2328",
  selection_fg = "#1f2328",
  selection_bg = "#ddf4ff",

  -- ANSI colors
  ansi = {
    "#24292f",   -- black
    "#cf222e",     -- red
    "#116329",   -- green
    "#4d2d00",  -- yellow
    "#0969da",    -- blue
    "#8250df", -- magenta
    "#1b7c83",    -- cyan
    "#6e7781",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#57606a",   -- bright black
    "#a40e26",     -- bright red
    "#1a7f37",   -- bright green
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
      fg_color = "#656d76",
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
