-- Indentation and formatting settings

local opt = vim.opt

-- Default indentation (2 spaces)
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true

-- Language-specific indentation handled by autocmds
-- Python: 4 spaces per Google Style Guide
-- Others: 2 spaces