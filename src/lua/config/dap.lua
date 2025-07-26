--
-- config/dap.lua
-- Comprehensive Debug Adapter Protocol (DAP) configuration
--

local M = {}

function M.setup()
  local dap = require('dap')
  local dapui = require('dapui')
  local dap_virtual_text = require('nvim-dap-virtual-text')
  
  -- ⚡ PERFORMANCE & UI SETTINGS
  -- Configure DAP UI for optimal experience
  dapui.setup({
    icons = { 
      expanded = "▾", 
      collapsed = "▸",
      current_frame = "▸"
    },
    mappings = {
      -- Use a table to apply multiple mappings
      expand = { "<CR>", "<2-LeftMouse>" },
      open = "o",
      remove = "d",
      edit = "e",
      repl = "r",
      toggle = "t",
    },
    -- Expand lines larger than the render window
    -- Requires >= 0.7
    expand_lines = vim.fn.has("nvim-0.7") == 1,
    -- Layouts define sections of the screen to place windows.
    layouts = {
      {
        -- You can change the order of elements in the sidebar
        elements = {
          -- Elements can be strings or table with id and size keys.
          { id = "scopes", size = 0.25 },
          "breakpoints",
          "stacks",
          "watches",
        },
        size = 40, -- 40 columns
        position = "left",
      },
      {
        elements = {
          "repl",
          "console",
        },
        size = 0.25, -- 25% of total lines
        position = "bottom",
      },
    },
    controls = {
      -- Requires Neovim nightly (or 0.8 when released)
      -- In the repl window
      enabled = true,
      -- Display controls in this element
      element = "repl",
      icons = {
        pause = "",
        play = "",
        step_into = "",
        step_over = "",
        step_out = "",
        step_back = "",
        run_last = "↻",
        terminate = "□",
      },
    },
    floating = {
      max_height = nil, -- These can be integers or a float between 0 and 1.
      max_width = nil,   -- Floats will be treated as percentage of your screen.
      border = "single", -- Border style. Can be "single", "double" or "rounded"
      mappings = {
        close = { "q", "<Esc>" },
      },
    },
    windows = { indent = 1 },
    render = {
      max_type_length = nil, -- Can be integer or nil.
      max_value_lines = 100, -- Can be integer or nil.
    }
  })

  -- 🎨 VIRTUAL TEXT CONFIGURATION
  dap_virtual_text.setup({
    enabled = true,                        -- enable this plugin (the default)
    enabled_commands = true,               -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
    highlight_changed_variables = true,    -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
    highlight_new_as_changed = false,      -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
    show_stop_reason = true,               -- show stop reason when stopped for exceptions
    commented = false,                     -- prefix virtual text with comment string
    only_first_definition = true,          -- only show virtual text at first definition (if there are multiple)
    all_references = false,                -- show virtual text on all all references of the variable (not only definitions)
    clear_on_continue = false,             -- clear virtual text on "continue" (might cause flickering when stepping)
    -- A callback that determines how a variable is displayed or whether it should be omitted
    display_callback = function(variable, buf, stackframe, node, options)
      if options.virt_text_pos == 'inline' then
        return ' = ' .. variable.value
      else
        return variable.name .. ' = ' .. variable.value
      end
    end,
    -- position of virtual text, see `:h nvim_buf_set_extmark()`, default tries to inline the virtual text. Use 'eol' to set to end of line
    virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',

    -- experimental features:
    all_frames = false,                    -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
    virt_lines = false,                    -- show virtual lines instead of virtual text (will flicker!)
    virt_text_win_col = nil                -- position the virtual text at a fixed window column (starting from the first text column) ,
                                           -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
  })

  -- 🔧 AUTOMATIC DAP UI MANAGEMENT
  -- Automatically open/close DAP UI
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end

  -- 🐍 PYTHON DEBUGGING CONFIGURATION
  dap.adapters.python = function(cb, config)
    if config.request == 'attach' then
      ---@diagnostic disable-next-line: undefined-field
      local port = (config.connect or config).port
      ---@diagnostic disable-next-line: undefined-field
      local host = (config.connect or config).host or '127.0.0.1'
      cb({
        type = 'server',
        port = assert(port, '`connect.port` is required for a python `attach` configuration'),
        host = host,
        options = {
          source_filetype = 'python',
        },
      })
    else
      cb({
        type = 'executable',
        command = 'python',
        args = { '-m', 'debugpy.adapter' },
        options = {
          source_filetype = 'python',
        },
      })
    end
  end

  dap.configurations.python = {
    {
      -- The first three options are required by nvim-dap
      type = 'python', -- the type here established the link to the adapter definition: `dap.adapters.python`
      request = 'launch',
      name = "Launch file",

      -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

      program = "${file}", -- This configuration will launch the current file if used.
      pythonPath = function()
        -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
        -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
        -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
        local cwd = vim.fn.getcwd()
        if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
          return cwd .. '/venv/bin/python'
        elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
          return cwd .. '/.venv/bin/python'
        else
          return '/usr/bin/python'
        end
      end,
    },
    {
      type = 'python',
      request = 'launch',
      name = 'Launch file with arguments',
      program = '${file}',
      args = function()
        local args_string = vim.fn.input('Arguments: ')
        return vim.split(args_string, " +")
      end,
      console = 'integratedTerminal',
      pythonPath = function()
        local cwd = vim.fn.getcwd()
        if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
          return cwd .. '/venv/bin/python'
        elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
          return cwd .. '/.venv/bin/python'
        else
          return '/usr/bin/python'
        end
      end,
    },
    {
      type = 'python',
      request = 'attach',
      name = 'Attach remote',
      connect = function()
        local host = vim.fn.input('Host [127.0.0.1]: ')
        host = host ~= '' and host or '127.0.0.1'
        local port = tonumber(vim.fn.input('Port [5678]: ')) or 5678
        return { host = host, port = port }
      end,
    },
  }

  -- 🔧 C/C++ DEBUGGING CONFIGURATION
  dap.adapters.lldb = {
    type = 'executable',
    command = '/usr/bin/lldb-vscode', -- adjust as needed, must be absolute path
    name = 'lldb'
  }

  -- Alternative GDB adapter
  dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "-i", "dap" }
  }

  dap.configurations.cpp = {
    {
      name = 'Launch',
      type = 'lldb',
      request = 'launch',
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = {},
    },
    {
      name = 'Launch with args',
      type = 'lldb',
      request = 'launch',
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = function()
        local args_string = vim.fn.input('Arguments: ')
        return vim.split(args_string, " +")
      end,
    },
    {
      -- If you get an "Operation not permitted" error using this, try disabling YAMA:
      --  echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
      name = 'Attach to gdbserver :1234',
      type = 'lldb',
      request = 'launch',
      MIMode = 'gdb',
      miDebuggerServerAddress = 'localhost:1234',
      miDebuggerPath = '/usr/bin/gdb',
      cwd = '${workspaceFolder}',
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
    },
  }

  -- C uses the same configuration as C++
  dap.configurations.c = dap.configurations.cpp

  -- 🌙 LUA DEBUGGING CONFIGURATION
  dap.adapters.nlua = function(callback, config)
    callback({ type = 'server', host = config.host or "127.0.0.1", port = config.port or 8086 })
  end

  dap.configurations.lua = {
    {
      type = 'nlua',
      request = 'attach',
      name = "Attach to running Neovim instance",
    }
  }

  -- 🟨 JAVASCRIPT/TYPESCRIPT DEBUGGING
  dap.adapters.node2 = {
    type = 'executable',
    command = 'node',
    args = {vim.fn.stdpath("data") .. '/mason/packages/node-debug2-adapter/out/src/nodeDebug.js'},
  }

  dap.configurations.javascript = {
    {
      name = 'Launch',
      type = 'node2',
      request = 'launch',
      program = '${file}',
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = 'inspector',
      console = 'integratedTerminal',
    },
    {
      -- For this to work you need to make sure the node process is started with the `--inspect` flag.
      name = 'Attach to process',
      type = 'node2',
      request = 'attach',
      processId = require'dap.utils'.pick_process,
    },
  }

  dap.configurations.typescript = {
    {
      name = 'ts-node (Node2 with ts-node)',
      type = 'node2',
      request = 'launch',
      cwd = vim.fn.getcwd(),
      runtimeArgs = {'-r', 'ts-node/register'},
      runtimeExecutable = 'node',
      args = {'--inspect', '${file}'},
      sourceMaps = true,
      skipFiles = {'<node_internals>/**', 'node_modules/**'},
    },
    {
      name = 'Jest (Node2 with Jest)',
      type = 'node2',
      request = 'launch',
      cwd = vim.fn.getcwd(),
      runtimeArgs = {'--inspect-brk', '${workspaceFolder}/node_modules/.bin/jest', '--runInBand', '--no-cache', '--no-coverage', '${file}'},
      runtimeExecutable = 'node',
      args = {'--inspect', '${file}'},
      sourceMaps = true,
      skipFiles = {'<node_internals>/**', 'node_modules/**'},
    },
  }

  -- 🦀 RUST DEBUGGING CONFIGURATION
  dap.adapters.rust = {
    type = 'executable',
    command = 'lldb-vscode',
    name = 'rust_lldb'
  }

  dap.configurations.rust = {
    {
      name = 'Launch',
      type = 'rust',
      request = 'launch',
      program = function()
        local metadata_json = vim.fn.system("cargo metadata --format-version 1 --no-deps")
        local metadata = vim.json.decode(metadata_json)
        local target_name = metadata.packages[1].targets[1].name
        local target_dir = metadata.target_directory
        return target_dir .. '/debug/' .. target_name
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = {},
      initCommands = function()
        -- Find out where to look for the pretty printer Python module
        local rustc_sysroot = vim.fn.trim(vim.fn.system('rustc --print sysroot'))

        local script_import = 'command script import "' .. rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"'
        local commands_file = rustc_sysroot .. '/lib/rustlib/etc/lldb_commands'

        local commands = {}
        local file = io.open(commands_file, 'r')
        if file then
          for line in file:lines() do
            table.insert(commands, line)
          end
          file:close()
        end
        table.insert(commands, 1, script_import)

        return commands
      end,
    }
  }

  -- 🔧 MASON-DAP INTEGRATION
  -- Automatically install and configure debug adapters
  local mason_dap_ok, mason_dap = pcall(require, "mason-nvim-dap")
  if mason_dap_ok then
    mason_dap.setup({
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_setup = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'python',
        'codelldb',  -- For C/C++/Rust
        'node2',     -- For JavaScript/TypeScript
      }
    })
  end

  -- 🎯 CUSTOM COMMANDS
  -- Create useful DAP commands
  vim.api.nvim_create_user_command('DapUIToggle', function()
    dapui.toggle()
  end, { desc = 'Toggle DAP UI' })

  vim.api.nvim_create_user_command('DapClearBreakpoints', function()
    dap.clear_breakpoints()
    print("All breakpoints cleared")
  end, { desc = 'Clear all breakpoints' })

  vim.api.nvim_create_user_command('DapShowLog', function()
    dap.set_log_level('TRACE')
    dap.repl.open()
  end, { desc = 'Show DAP log' })

  -- 📊 SIGNS CONFIGURATION
  -- Set up custom signs for breakpoints
  vim.fn.sign_define('DapBreakpoint', {
    text = '🔴',
    texthl = 'DapBreakpoint',
    linehl = 'DapBreakpoint',
    numhl = 'DapBreakpoint'
  })

  vim.fn.sign_define('DapBreakpointCondition', {
    text = '🔶',
    texthl = 'DapBreakpoint',
    linehl = 'DapBreakpoint',
    numhl = 'DapBreakpoint'
  })

  vim.fn.sign_define('DapBreakpointRejected', {
    text = '🚫',
    texthl = 'DapBreakpoint',
    linehl = 'DapBreakpoint',
    numhl = 'DapBreakpoint'
  })

  vim.fn.sign_define('DapLogPoint', {
    text = '📝',
    texthl = 'DapLogPoint',
    linehl = 'DapLogPoint',
    numhl = 'DapLogPoint'
  })

  vim.fn.sign_define('DapStopped', {
    text = '▶️',
    texthl = 'DapStopped',
    linehl = 'DapStopped',
    numhl = 'DapStopped'
  })

  -- 🎨 HIGHLIGHT GROUPS
  -- Set up custom highlight groups
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#e51400' })
      vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef' })
      vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#98c379' })
    end,
  })

  -- Apply highlights immediately
  vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#e51400' })
  vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef' })
  vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#98c379' })
end

-- 🚀 UTILITY FUNCTIONS
function M.debug_nearest()
  local dap = require('dap')
  dap.run_to_cursor()
end

function M.debug_class()
  local dap = require('dap')
  -- This would need to be customized per language
  print("Debug class functionality would be implemented per language")
end

function M.debug_method()
  local dap = require('dap')
  -- This would need to be customized per language  
  print("Debug method functionality would be implemented per language")
end

return M