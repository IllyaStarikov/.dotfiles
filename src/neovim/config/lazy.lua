-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup("config.plugins", {
  performance = {
    rtp = {
      disabled_plugins = {
        -- Keep these disabled as they have verified performance impact:
        "gzip", -- Rarely needed, adds startup overhead
        "netrwPlugin", -- Replaced by Snacks explorer
        "tarPlugin", -- Rarely needed for tar files
        "tohtml", -- Rarely used HTML export functionality
        "tutor", -- Tutorial, not needed after initial learning
        "zipPlugin", -- Rarely needed for zip files

        -- Re-enabled these as they're useful with minimal performance impact:
        -- "matchit",   -- Useful for % navigation in many languages
        -- "matchparen", -- Useful for seeing matching parens/brackets
      },
    },
  },
})
