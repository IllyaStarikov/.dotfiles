--
-- minuet.lua
-- AI inline completion with dual providers: Ollama (local) + Claude (cloud)
-- Virtual text (ghost text) as primary frontend, blink.cmp as secondary
--

local M = {}

function M.setup()
  require("minuet").setup({
    -- Default to local Ollama (switch to Claude with <leader>mc)
    provider = "openai_fim_compatible",

    -- Global settings
    n_completions = 1,
    context_window = 4000,
    context_ratio = 0.75,
    throttle = 300,
    debounce = 150,
    request_timeout = 5,
    notify = "warn",
    add_single_line_entry = true,
    after_cursor_filter_length = 15,
    before_cursor_filter_length = 2,

    -- Virtual text (ghost text) — primary frontend
    virtualtext = {
      auto_trigger_ft = { "python", "cpp", "lua" },
      auto_trigger_ignore_ft = {},
      keymap = {
        -- accept is handled by custom Tab mapping below
        accept = nil,
        accept_line = "<A-a>",
        accept_n_lines = "<A-z>",
        prev = "<A-[>",
        next = "<A-]>",
        dismiss = "<A-e>",
      },
      show_on_completion_menu = false,
    },

    -- Frontend toggles
    blink = { enable_auto_complete = true },
    cmp = { enable_auto_complete = false },
    lsp = { enabled_ft = {} },

    -- Provider configurations
    provider_options = {
      -- Ollama FIM via OpenAI-compatible completions endpoint
      openai_fim_compatible = {
        api_key = "TERM",
        name = "Ollama",
        end_point = "http://localhost:11434/v1/completions",
        model = "qwen2.5-coder:7b",
        stream = true,
        optional = {
          max_tokens = 256,
          top_p = 0.9,
          temperature = 0.5,
          repetition_penalty = 1.1,
        },
      },
      -- Claude chat-based completion
      claude = {
        max_tokens = 256,
        model = "claude-haiku-4-5",
        stream = true,
        api_key = "ANTHROPIC_API_KEY",
        end_point = "https://api.anthropic.com/v1/messages",
      },
    },

    -- Presets for instant runtime switching
    presets = {
      ollama = {
        provider = "openai_fim_compatible",
        n_completions = 1,
        context_window = 4000,
        throttle = 300,
        debounce = 150,
        request_timeout = 5,
        provider_options = {
          openai_fim_compatible = {
            api_key = "TERM",
            name = "Ollama",
            end_point = "http://localhost:11434/v1/completions",
            model = "qwen2.5-coder:7b",
            stream = true,
            optional = {
              max_tokens = 256,
              top_p = 0.9,
              temperature = 0.5,
              repetition_penalty = 1.1,
            },
          },
        },
      },
      claude = {
        provider = "claude",
        n_completions = 3,
        context_window = 16000,
        throttle = 1500,
        debounce = 600,
        request_timeout = 4,
        provider_options = {
          claude = {
            max_tokens = 256,
            model = "claude-haiku-4-5",
            stream = true,
            api_key = "ANTHROPIC_API_KEY",
            end_point = "https://api.anthropic.com/v1/messages",
          },
        },
      },
    },
  })

  -- Smart Tab: accept ghost text if visible, otherwise normal Tab
  vim.keymap.set("i", "<Tab>", function()
    local vt = require("minuet.virtualtext")
    if vt.action.is_visible() then
      vt.action.accept()
    else
      -- Feed a real Tab to let blink.cmp or default behavior handle it
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
    end
  end, { desc = "Accept ghost text or Tab", silent = true })

  -- Since minuet loads on InsertEnter, the FileType autocmd it creates
  -- missed the current buffer (FileType already fired). Enable auto-trigger
  -- for the current buffer if its filetype matches.
  local ft = vim.bo.filetype
  local auto_ft = { "python", "cpp", "lua" }
  for _, v in ipairs(auto_ft) do
    if ft == v then
      vim.b.minuet_virtual_text_auto_trigger = true
      break
    end
  end
end

return M
