--
-- config/blink.lua
-- blink.cmp configuration with full LSP trigger character support
--

local M = {}

function M.setup()
  local ok, blink = pcall(require, 'blink.cmp')
  if not ok then
    vim.notify("blink.cmp not found", vim.log.levels.ERROR)
    return
  end
  
  blink.setup({
    -- Enable the plugin
    enabled = function()
      return vim.bo.buftype ~= "prompt"
    end,
    
    -- Keymap configuration
    keymap = {
      preset = 'default',
      ['<Tab>'] = { 'accept', 'fallback' },
    },
    
    -- Appearance settings
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'normal',
    },
    
    -- Completion configuration - THE KEY SECTION
    completion = {
      keyword = {
        range = 'prefix',
      },
      
      trigger = {
        -- CRITICAL: These must all be true for dot completion to work
        show_on_trigger_character = true,
        show_on_accept_on_trigger_character = true,
        show_on_insert_on_trigger_character = true,
        -- Don't block any trigger characters
        show_on_blocked_trigger_characters = {},
        show_on_x_blocked_trigger_characters = {},
      },
      
      list = {
        max_items = 200,
        selection = {
          preselect = true,
          auto_insert = false,
        },
      },
      
      menu = {
        enabled = true,
        border = 'rounded',
        draw = {
          columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
        },
      },
      
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 100,
        window = {
          border = 'rounded',
        },
      },
    },
    
    -- Sources configuration
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      min_keyword_length = 0,  -- Global minimum
      providers = {
        lsp = {
          name = 'LSP',
          min_keyword_length = 0,  -- CRITICAL: Allow LSP to trigger on 0 characters
          score_offset = 100,  -- Prioritize LSP completions
        },
        path = {
          name = 'Path',
          min_keyword_length = 2,
        },
        snippets = {
          name = 'Snippets', 
          min_keyword_length = 2,
        },
        buffer = {
          name = 'Buffer',
          min_keyword_length = 3,
        },
      },
    },
    
    -- Signature help
    signature = {
      enabled = true,
      window = {
        border = 'rounded',
      },
    },
    
    -- Fuzzy matching
    fuzzy = {
      prebuilt_binaries = {
        download = false,
        ignore_version_mismatch = true,
      },
    },
    
    -- Snippet expansion
    snippets = {
      expand = function(snippet)
        require('luasnip').lsp_expand(snippet)
      end,
      active = function(filter)
        if filter and filter.direction then
          return require('luasnip').jumpable(filter.direction)
        end
        return require('luasnip').in_snippet()
      end,
      jump = function(direction)
        require('luasnip').jump(direction)
      end,
    },
  })
  
  -- Add a debug autocmd to verify trigger characters
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client.server_capabilities.completionProvider then
        local triggers = client.server_capabilities.completionProvider.triggerCharacters
        if triggers and vim.tbl_contains(triggers, '.') then
          vim.notify(client.name .. " supports dot completion", vim.log.levels.DEBUG)
        end
      end
    end,
  })
  
  -- Manual completion trigger for debugging
  vim.keymap.set('i', '<C-x><C-o>', function()
    require('blink.cmp').show()
  end, { desc = "Manually trigger completion" })
end

return M