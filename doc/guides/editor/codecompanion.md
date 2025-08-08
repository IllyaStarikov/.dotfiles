# CodeCompanion.nvim Configuration

> **Our AI integration setup optimized for local-first development**

[Official Documentation](https://github.com/olimorris/codecompanion.nvim)

## Our AI Philosophy

1. **Privacy-first** - Default to local LLMs via [Ollama](https://ollama.ai/)
2. **Multi-provider** - Seamless switching between local and cloud
3. **Context-aware** - Smart file and buffer inclusion
4. **Workflow-integrated** - Git-aware, project-aware

## Provider Configuration

### Default: Local Ollama

```lua
-- Primary adapter: Ollama with Llama 3.1 70B
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
}
```

### Cloud Providers (Optional)

```lua
-- All strategies default to local Ollama
strategies = {
  chat = {
    adapter = "ollama", -- Local Llama 3.1 70B
  },
  inline = {
    adapter = "ollama", -- For inline assistance
  },
  agent = {
    adapter = "ollama", -- For agent workflows
  },
}
```

## Custom Prompts

### Our Prompt Library

```lua
-- Located in: lua/config/plugins/ai.lua
prompts = {
  -- Industry style guide compliance
  ["Style Review"] = {
    strategy = "chat",
    description = "Review for industry style guide compliance",
    opts = {
      index = 10,
      default_prompt = [[
        Review this code for industry style guide compliance.
        Focus on:
        - Naming conventions
        - Documentation standards
        - Code organization
        - Language-specific guidelines
      ]],
    },
  },

  -- Performance optimization
  ["Performance Review"] = {
    strategy = "chat",
    description = "Analyze performance characteristics",
    opts = {
      index = 11,
      default_prompt = [[
        Analyze this code for performance:
        - Time complexity
        - Space complexity
        - Potential bottlenecks
        - Optimization opportunities
        Consider production scale.
      ]],
    },
  },
}
```

## Workflow Integration

### Git-Aware Context

```lua
-- Automatically include git context
opts = {
  send_code = true,
  use_default_prompt_library = true,
  -- Custom context function
  context = function()
    local git_diff = vim.fn.system("git diff --cached")
    return git_diff ~= "" and git_diff or nil
  end,
}
```

### Project-Aware Includes

```lua
-- Smart file inclusion based on project type
slash_commands = {
  ["project"] = {
    callback = function()
      -- Include relevant project files
      local ft = vim.bo.filetype
      if ft == "python" then
        return { "requirements.txt", "setup.py", "pyproject.toml" }
      elseif ft == "javascript" then
        return { "package.json", "tsconfig.json" }
      end
    end
  }
}
```

## Enhanced Keybindings

### Visual Mode Enhancements

```lua
-- Our visual mode mappings
keymaps = {
  ["<leader>ce"] = "explain",     -- Detailed explanation
  ["<leader>ct"] = "tests",       -- Generate tests
  ["<leader>cf"] = "fix",         -- Fix issues
  ["<leader>co"] = "optimize",    -- Performance optimization
  ["<leader>cr"] = "review",      -- Code review
  ["<leader>cs"] = "security",    -- Security audit (custom)
}
```

### Chat Interface

```lua
-- Enhanced chat experience
display = {
  chat = {
    window = {
      width = 0.4,    -- 40% of screen
      height = 0.8,   -- 80% height
      border = "rounded",
    },
    -- Custom highlighting
    highlights = {
      user = "CodeCompanionUser",
      assistant = "CodeCompanionAssistant",
    },
  },
}
```

## Performance Optimizations

### Streaming Configuration

```lua
-- Optimized for responsive feedback
opts = {
  stream = true,
  -- Faster token generation
  stream_callback = function(chunk)
    -- Process incrementally
    vim.schedule(function()
      -- Update UI without blocking
    end)
  end,
}
```

### Context Limiting

```lua
-- Prevent context overflow
pre_req = function(adapter, messages)
  -- Limit context to relevant code
  local max_tokens = 4000
  local current_tokens = 0
  
  for i = #messages, 1, -1 do
    current_tokens = current_tokens + #messages[i].content
    if current_tokens > max_tokens then
      -- Truncate older messages
      messages = vim.list_slice(messages, i + 1)
      break
    end
  end
  
  return messages
end
```

## Local LLM Optimization

### Model Selection

```bash
# Recommended models for coding
ollama pull codellama:13b       # Best for code completion
ollama pull llama3.2:latest     # General purpose
ollama pull deepseek-coder:6.7b # Smaller, faster
```

### Performance Tuning

```lua
-- Ollama-specific optimizations
adapters = {
  ollama = {
    parameters = {
      num_gpu = 1,        -- Use GPU if available
      num_thread = 8,     -- CPU threads
      repeat_penalty = 1.1, -- Reduce repetition
      mirostat = 2,       -- Better coherence
    }
  }
}
```

## Debugging Our Setup

### Health Check

```vim
:checkhealth codecompanion
```

### Adapter Testing

```lua
-- Test specific adapter
:CodeCompanion adapter=ollama "Test prompt"

-- Check adapter status
:lua print(vim.inspect(require('codecompanion').get_adapter('ollama')))
```

### Log Analysis

```bash
# Enable debug logging
export CODECOMPANION_LOG_LEVEL=debug

# View logs
tail -f ~/.local/state/nvim/codecompanion.log
```

## Integration with Other Plugins

### Telescope Integration

```lua
-- Find and include files via Telescope
["<leader>caf"] = function()
  require('telescope.builtin').find_files({
    attach_mappings = function(_, map)
      map('i', '<CR>', function(prompt_bufnr)
        -- Include selected file in context
        local selection = require('telescope.actions.state').get_selected_entry()
        require('codecompanion').add_context(selection.path)
      end)
      return true
    end,
  })
end
```

### Snippet Generation

```lua
-- Generate and insert snippets
["<leader>cg"] = function()
  require('codecompanion').generate({
    strategy = "inline",
    adapter = "ollama",
    prompt = "Generate a snippet for: " .. vim.fn.input("Snippet: "),
    callback = function(snippet)
      require('luasnip').snip_expand(snippet)
    end,
  })
end
```

## References

- [CodeCompanion.nvim Documentation](https://github.com/olimorris/codecompanion.nvim)
- [Ollama Documentation](https://ollama.ai/docs)
- [Our AI prompts configuration](https://github.com/starikov/.dotfiles/blob/main/src/neovim/config/plugins/ai.lua)

---

<p align="center">
  <a href="../README.md">← Back to Guides</a>
</p>