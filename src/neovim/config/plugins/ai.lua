--
-- config/codecompanion.lua
-- Minimal CodeCompanion configuration for local AI assistance
--

local M = {}

function M.setup()
  local ok, codecompanion = pcall(require, "codecompanion")
  if not ok then
    vim.notify("Failed to load codecompanion", vim.log.levels.WARN)
    return
  end
  
  codecompanion.setup({
    -- Minimal adapter configuration - just Ollama
    adapters = {
      ollama = function()
        return require("codecompanion.adapters").extend("ollama", {
          name = "llama3.1:70b",
          schema = {
            model = {
              default = "llama3.1:70b",
            },
          },
        })
      end,
    },

    -- Strategy configuration
    strategies = {
      chat = {
        adapter = "ollama", -- Use local Ollama as default for chat
      },
      inline = {
        adapter = "ollama", -- Use local Ollama for inline assistance
      },
      agent = {
        adapter = "ollama", -- Use local Ollama for agent workflows
      },
    },

    -- Minimal display options
    display = {
      chat = {
        window = {
          layout = "vertical",
          width = 0.5,
          height = 0.8,
        },
      },
    },

    -- Options
    opts = {
      log_level = "ERROR", -- TRACE, DEBUG, ERROR, INFO
      send_code = true, -- Send code context to the LLM
      use_default_actions = true, -- Use the default actions in the action palette
      use_default_prompts = true, -- Use the default prompts from the plugin
    },

    -- Use default prompts and slash commands
    use_default_prompts = true,
  })
end

return M