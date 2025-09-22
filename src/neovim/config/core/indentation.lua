-- Indentation and formatting settings
-- Configures how tabs and spaces work for code indentation

local opt = vim.opt

-- Default indentation (2 spaces for most languages)
opt.expandtab = true     -- Default: false - convert tabs to spaces
opt.shiftwidth = 2       -- Default: 8 - spaces for each indentation level
opt.tabstop = 2          -- Default: 8 - width of tab character display
opt.softtabstop = 2      -- Default: 0 - spaces inserted when pressing tab
opt.smartindent = true   -- Default: false - auto-indent new lines based on syntax

-- Language-specific indentation handled by autocmds
-- Python: 4 spaces per Google Style Guide
-- Others: 2 spaces
