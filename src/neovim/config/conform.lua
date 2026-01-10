-- conform.lua

local M = {}

function M.setup()
  ---@diagnostic disable-next-line: redundant-parameter
  require("conform").setup({
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "isort", "black" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      html = { "prettier" },
      css = { "prettier" },
      json = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
    },
    -- Disable format on save - only manual formatting via :Format or <leader>f
    format_on_save = false,
  })
end

return M
