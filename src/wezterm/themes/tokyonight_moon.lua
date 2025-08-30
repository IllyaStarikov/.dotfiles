-- TokyoNight Moon theme for WezTerm
-- Ported from https://github.com/folke/tokyonight.nvim

local M = {}

M.colors = {
  -- Basic colors
  foreground = '#c8d3f5',
  background = '#222436',
  cursor_bg = '#c8d3f5',
  cursor_fg = '#222436',
  cursor_border = '#c8d3f5',
  selection_fg = '#c8d3f5',
  selection_bg = '#2d3f76',
  
  -- ANSI colors
  ansi = {
    '#1b1d2b', -- black
    '#ff757f', -- red
    '#c3e88d', -- green
    '#ffc777', -- yellow
    '#82aaff', -- blue
    '#c099ff', -- magenta
    '#86e1fc', -- cyan
    '#828bb8', -- white
  },
  
  -- Bright ANSI colors
  brights = {
    '#444a73', -- bright black
    '#ff8d94', -- bright red
    '#c7fb6d', -- bright green
    '#ffd8ab', -- bright yellow
    '#9ab8ff', -- bright blue
    '#caabff', -- bright magenta
    '#b2ebff', -- bright cyan
    '#c8d3f5', -- bright white
  },
  
  -- Indexed colors
  indexed = {
    [16] = '#ff966c',
    [17] = '#c53b53',
  },
  
  -- Tab bar
  tab_bar = {
    background = '#1e2030',
    active_tab = {
      bg_color = '#222436',
      fg_color = '#82aaff',
      intensity = 'Bold',
    },
    inactive_tab = {
      bg_color = '#1e2030',
      fg_color = '#545c7e',
    },
    inactive_tab_hover = {
      bg_color = '#2a2e48',
      fg_color = '#82aaff',
      italic = false,
    },
    new_tab = {
      bg_color = '#1e2030',
      fg_color = '#82aaff',
    },
    new_tab_hover = {
      bg_color = '#2a2e48',
      fg_color = '#82aaff',
      italic = false,
    },
  },
  
  -- Scrollbar
  scrollbar_thumb = '#444a73',
  
  -- Split lines
  split = '#444a73',
  
  -- Visual bell
  visual_bell = '#86e1fc',
}

return M