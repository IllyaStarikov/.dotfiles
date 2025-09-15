-- Typr - Typing practice configuration

local M = {}

function M.setup()
  require("typr").setup({
    -- Test duration options
    duration = 30,

    -- Word list configuration
    word_count = 50,

    -- UI settings
    ui = {
      border = "rounded",
      height = 0.8,
      width = 0.8,
    },

    -- Statistics tracking
    save_stats = true,
    stats_file = vim.fn.stdpath("data") .. "/typr_stats.json",

    -- Key bindings within typr buffer
    keybinds = {
      quit = "q",
      restart = "r",
      toggle_stats = "s",
    },

    -- Programming mode languages
    programming_languages = {
      "lua",
      "python",
      "javascript",
      "rust",
      "go",
      "c",
      "cpp",
    },
  })
end

return M
