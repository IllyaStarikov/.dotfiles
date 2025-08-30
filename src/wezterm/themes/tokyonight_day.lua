-- TokyoNight Day theme for WezTerm
-- Ported from https://github.com/folke/tokyonight.nvim

local M = {}

M.colors = {
  -- Basic colors
  foreground = '#3760bf',
  background = '#e1e2e7',
  cursor_bg = '#3760bf',
  cursor_fg = '#e1e2e7',
  cursor_border = '#3760bf',
  selection_fg = '#3760bf',
  selection_bg = '#c4c8da',
  
  -- ANSI colors
  ansi = {
    '#b4b5b9', -- black
    '#f52a65', -- red
    '#587539', -- green
    '#8c6c3e', -- yellow
    '#2e7de9', -- blue
    '#9854f1', -- magenta
    '#007197', -- cyan
    '#6172b0', -- white
  },
  
  -- Bright ANSI colors
  brights = {
    '#a1a6c5', -- bright black
    '#ff4774', -- bright red
    '#5c8524', -- bright green
    '#a27629', -- bright yellow
    '#358aff', -- bright blue
    '#a463ff', -- bright magenta
    '#007ea8', -- bright cyan
    '#3760bf', -- bright white
  },
  
  -- Indexed colors
  indexed = {
    [16] = '#b15c00',
    [17] = '#c64343',
  },
  
  -- Tab bar
  tab_bar = {
    background = '#d0d5e3',
    active_tab = {
      bg_color = '#e1e2e7',
      fg_color = '#3760bf',
      intensity = 'Bold',
    },
    inactive_tab = {
      bg_color = '#c4c8da',
      fg_color = '#6172b0',
    },
    inactive_tab_hover = {
      bg_color = '#d0d5e3',
      fg_color = '#3760bf',
      italic = false,
    },
    new_tab = {
      bg_color = '#c4c8da',
      fg_color = '#3760bf',
    },
    new_tab_hover = {
      bg_color = '#d0d5e3',
      fg_color = '#3760bf',
      italic = false,
    },
  },
  
  -- Scrollbar
  scrollbar_thumb = '#a1a6c5',
  
  -- Split lines
  split = '#c4c8da',
  
  -- Visual bell
  visual_bell = '#88c0d0',
}

return M