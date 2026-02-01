-- Monokai Pro Spectrum theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#f7f1ff",
  background = "#222222",
  cursor_bg = "#f7f1ff",
  cursor_fg = "#222222",
  cursor_border = "#f7f1ff",
  selection_fg = "#f7f1ff",
  selection_bg = "#525053",

  -- ANSI colors
  ansi = {
    "#525053",   -- black
    "#fc618d",     -- red
    "#7bd88f",   -- green
    "#fce566",  -- yellow
    "#5ad4e6",    -- blue
    "#948ae3", -- magenta
    "#5ad4e6",    -- cyan
    "#f7f1ff",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#69676c",   -- bright black
    "#fc618d",     -- bright red
    "#7bd88f",   -- bright green
    "#fce566",  -- bright yellow
    "#5ad4e6",    -- bright blue
    "#948ae3", -- bright magenta
    "#5ad4e6",    -- bright cyan
    "#f7f1ff",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#3c3c3c",
    active_tab = {
      bg_color = "#222222",
      fg_color = "#5ad4e6",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#3c3c3c",
      fg_color = "#69676c",
    },
    inactive_tab_hover = {
      bg_color = "#525053",
      fg_color = "#5ad4e6",
      italic = false,
    },
    new_tab = {
      bg_color = "#3c3c3c",
      fg_color = "#5ad4e6",
    },
    new_tab_hover = {
      bg_color = "#525053",
      fg_color = "#5ad4e6",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#69676c",

  -- Split lines
  split = "#69676c",
}

return M
