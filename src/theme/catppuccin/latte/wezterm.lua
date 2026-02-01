-- Catppuccin Latte theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#4c4f69",
  background = "#eff1f5",
  cursor_bg = "#4c4f69",
  cursor_fg = "#eff1f5",
  cursor_border = "#4c4f69",
  selection_fg = "#4c4f69",
  selection_bg = "#bcc0cc",

  -- ANSI colors
  ansi = {
    "#bcc0cc",   -- black
    "#d20f39",     -- red
    "#40a02b",   -- green
    "#df8e1d",  -- yellow
    "#1e66f5",    -- blue
    "#ea76cb", -- magenta
    "#179299",    -- cyan
    "#5c5f77",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#acb0be",   -- bright black
    "#d20f39",     -- bright red
    "#40a02b",   -- bright green
    "#df8e1d",  -- bright yellow
    "#1e66f5",    -- bright blue
    "#ea76cb", -- bright magenta
    "#179299",    -- bright cyan
    "#6c6f85",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#dbdde1",
    active_tab = {
      bg_color = "#eff1f5",
      fg_color = "#1e66f5",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#dbdde1",
      fg_color = "#acb0be",
    },
    inactive_tab_hover = {
      bg_color = "#bcc0cc",
      fg_color = "#1e66f5",
      italic = false,
    },
    new_tab = {
      bg_color = "#dbdde1",
      fg_color = "#1e66f5",
    },
    new_tab_hover = {
      bg_color = "#bcc0cc",
      fg_color = "#1e66f5",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#acb0be",

  -- Split lines
  split = "#acb0be",
}

return M
