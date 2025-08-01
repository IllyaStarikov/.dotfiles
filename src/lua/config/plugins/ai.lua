--
-- config/codecompanion.lua
-- Comprehensive CodeCompanion configuration for AI-powered coding assistance
--

local M = {}

function M.setup()
  local ok, codecompanion = pcall(require, "codecompanion")
  if not ok then
    vim.notify("Failed to load codecompanion", vim.log.levels.WARN)
    return
  end
  
  codecompanion.setup({
    -- Adapter configuration
    adapters = {
      anthropic = function()
        local adapters_ok, adapters = pcall(require, "codecompanion.adapters")
        if not adapters_ok then return nil end
        return adapters.extend("anthropic", {
          env = {
            api_key = "ANTHROPIC_API_KEY",
          },
        })
      end,
      openai = function()
        return require("codecompanion.adapters").extend("openai", {
          env = {
            api_key = "OPENAI_API_KEY",
          },
        })
      end,
      copilot = function()
        return require("codecompanion.adapters").extend("copilot", {
          -- Uses Copilot.vim token
        })
      end,
      ollama = function()
        return require("codecompanion.adapters").extend("ollama", {
          name = "llama3.2",
          schema = {
            model = {
              default = "llama3.2:latest",
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

    -- Display options
    display = {
      action_palette = {
        width = 95,
        height = 10,
        prompt = "Prompt ",
        provider = "telescope", -- telescope, mini_pick, fzf_lua
      },
      chat = {
        window = {
          layout = "vertical", -- vertical, horizontal, float, buffer
          width = 0.5, -- percentage of editor width
          height = 0.8, -- percentage of editor height
          relative = "editor", -- cursor, win, editor
          opts = {
            breakindent = true,
            cursorcolumn = false,
            cursorline = false,
            foldcolumn = "0",
          },
        },
        intro_message = "Welcome to CodeCompanion ✨\n\nHow can I help you today?",
        separator = "─", -- The separator between the different messages in the chat buffer
        show_settings = true, -- Show LLM settings at the top of the chat buffer
        show_token_count = true, -- Show approximate token count of the current chat buffer
      },
      diff = {
        layout = "vertical", -- vertical, horizontal
        opts = {
          wrap = false,
        },
        provider = "mini_diff", -- default, mini_diff
      },
    },

    -- Options
    opts = {
      log_level = "ERROR", -- TRACE, DEBUG, ERROR, INFO
      send_code = true, -- Send code context to the LLM
      use_default_actions = true, -- Use the default actions in the action palette
      use_default_prompts = true, -- Use the default prompts from the plugin
    },

    -- Prompt Library (extended default prompts)
    prompt_library = {
      ["Code Review"] = {
        strategy = "chat",
        description = "Review the selected code for best practices, bugs, and improvements",
        opts = {
          placement = "replace",
          modes = { "v" },
        },
        prompts = {
          {
            role = "system",
            content = "You are an expert code reviewer. Analyze the provided code for:\n1. Best practices and coding standards\n2. Potential bugs or issues\n3. Performance improvements\n4. Security vulnerabilities\n5. Readability and maintainability\n\nProvide specific, actionable feedback.",
          },
          {
            role = "user",
            content = function(context)
              return "Please review this code:\n\n```" .. context.filetype .. "\n" .. context.selection .. "\n```"
            end,
          },
        },
      },
      ["Optimize Code"] = {
        strategy = "inline",
        description = "Optimize the selected code for performance and readability",
        opts = {
          placement = "replace",
          modes = { "v" },
        },
        prompts = {
          {
            role = "system",
            content = "You are an expert software engineer. Optimize the provided code for better performance, readability, and maintainability while preserving its functionality.",
          },
          {
            role = "user",
            content = function(context)
              return "Optimize this code:\n\n```" .. context.filetype .. "\n" .. context.selection .. "\n```"
            end,
          },
        },
      },
      ["Add Comments"] = {
        strategy = "inline",
        description = "Add comprehensive comments to the selected code",
        opts = {
          placement = "replace",
          modes = { "v" },
        },
        prompts = {
          {
            role = "system",
            content = "Add clear, helpful comments to the code explaining what it does, why it does it, and any important implementation details. Follow the language's commenting conventions.",
          },
          {
            role = "user",
            content = function(context)
              return "Add comments to this code:\n\n```" .. context.filetype .. "\n" .. context.selection .. "\n```"
            end,
          },
        },
      },
      ["Generate Tests"] = {
        strategy = "chat",
        description = "Generate comprehensive unit tests for the selected code",
        opts = {
          placement = "new",
          modes = { "v" },
        },
        prompts = {
          {
            role = "system",
            content = "You are an expert in software testing. Generate comprehensive unit tests for the provided code. Include edge cases, error handling, and follow the testing framework conventions for the language.",
          },
          {
            role = "user",
            content = function(context)
              return "Generate unit tests for this code:\n\n```" .. context.filetype .. "\n" .. context.selection .. "\n```"
            end,
          },
        },
      },
      ["Explain Code"] = {
        strategy = "chat",
        description = "Explain what the selected code does in detail",
        opts = {
          modes = { "v" },
        },
        prompts = {
          {
            role = "system",
            content = "You are an expert software engineer and teacher. Explain the provided code in a clear, educational manner. Break down complex concepts and explain the purpose and functionality.",
          },
          {
            role = "user",
            content = function(context)
              return "Please explain this code:\n\n```" .. context.filetype .. "\n" .. context.selection .. "\n```"
            end,
          },
        },
      },
      ["Fix Bug"] = {
        strategy = "inline",
        description = "Identify and fix bugs in the selected code",
        opts = {
          placement = "replace",
          modes = { "v" },
        },
        prompts = {
          {
            role = "system",
            content = "You are an expert debugger. Analyze the provided code for bugs, identify the issues, and provide the corrected version. Explain what was wrong and how you fixed it.",
          },
          {
            role = "user",
            content = function(context)
              return "Fix any bugs in this code:\n\n```" .. context.filetype .. "\n" .. context.selection .. "\n```"
            end,
          },
        },
      },
      ["Convert Language"] = {
        strategy = "inline",
        description = "Convert code from one programming language to another",
        opts = {
          placement = "replace",
          modes = { "v" },
        },
        prompts = {
          {
            role = "system",
            content = "You are an expert in multiple programming languages. Convert the provided code to the requested language while maintaining the same functionality and following the target language's best practices.",
          },
          {
            role = "user",
            content = function(context)
              local target_lang = vim.fn.input("Convert to which language? ")
              return "Convert this code to " .. target_lang .. ":\n\n```" .. context.filetype .. "\n" .. context.selection .. "\n```"
            end,
          },
        },
      },
    },

    -- Slash Commands
    slash_commands = {
      ["buffer"] = {
        callback = "strategies.chat.slash_commands.buffer",
        description = "Insert open buffers",
        opts = {
          provider = "telescope", -- default, telescope, mini_pick, fzf_lua
        },
      },
      ["file"] = {
        callback = "strategies.chat.slash_commands.file",
        description = "Insert a file",
        opts = {
          provider = "telescope", -- default, telescope, mini_pick, fzf_lua
          max_lines = 1000,
        },
      },
      ["help"] = {
        callback = "strategies.chat.slash_commands.help",
        description = "Insert content from help tags",
        opts = {
          provider = "telescope", -- telescope, mini_pick, fzf_lua
        },
      },
      ["symbols"] = {
        callback = "strategies.chat.slash_commands.symbols",
        description = "Insert symbols for a selected file",
        opts = {
          provider = "telescope", -- default, telescope, mini_pick, fzf_lua
        },
      },
      ["terminal"] = {
        callback = "strategies.chat.slash_commands.terminal",
        description = "Insert terminal output",
        opts = {
          provider = "telescope", -- default, telescope, mini_pick, fzf_lua
        },
      },
    },

    -- Auto commands
    autocmds = {
      -- Auto-save chat sessions
      {
        event = "BufWritePost",
        desc = "Save chat sessions",
        pattern = "codecompanion-*",
        callback = function()
          vim.cmd("silent! write")
        end,
      },
    },

    -- Keymaps (these will be set up in keymaps.lua)
    keymaps = {
      -- Disable default keymaps, we'll set our own
      {
        modes = { "n" },
        lhs = "<C-a>",
        rhs = "",
        opts = {
          desc = "Disabled: Use custom keymaps",
        },
      },
    },
  })

  -- Set up additional highlight groups for better visual experience
  vim.cmd([[
    highlight CodeCompanionChatHeader guifg=#50fa7b gui=bold
    highlight CodeCompanionChatSeparator guifg=#6272a4
    highlight CodeCompanionChatUser guifg=#8be9fd gui=bold
    highlight CodeCompanionChatAI guifg=#bd93f9 gui=bold
    highlight CodeCompanionChatCode guibg=#282a36 guifg=#f8f8f2
  ]])
end

return M