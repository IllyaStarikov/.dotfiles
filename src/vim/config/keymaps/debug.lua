--
-- config/keymaps/debug.lua
-- Debug Adapter Protocol (DAP) keybindings
--

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Only set up DAP keybindings if DAP is available
local function setup_dap_keybindings()
  local ok, dap = pcall(require, 'dap')
  if not ok then
    return
  end

  -- Core debugging actions
  map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
  map("n", "<leader>dB", function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { desc = "Set Conditional Breakpoint" })
  map("n", "<leader>dlp", function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, { desc = "Set Log Point" })

  -- Debug session control
  map("n", "<leader>dc", dap.continue, { desc = "Continue/Start Debugging" })
  map("n", "<leader>dr", dap.restart, { desc = "Restart Debug Session" })
  map("n", "<leader>dt", dap.terminate, { desc = "Terminate Debug Session" })
  map("n", "<leader>dq", dap.close, { desc = "Close Debug Session" })

  -- Stepping controls
  map("n", "<leader>ds", dap.step_over, { desc = "Step Over" })
  map("n", "<leader>di", dap.step_into, { desc = "Step Into" })
  map("n", "<leader>do", dap.step_out, { desc = "Step Out" })
  map("n", "<leader>dj", dap.down, { desc = "Go Down Stack Frame" })
  map("n", "<leader>dk", dap.up, { desc = "Go Up Stack Frame" })

  -- REPL and evaluation
  map("n", "<leader>dR", dap.repl.open, { desc = "Open REPL" })
  map("n", "<leader>dE", function()
    vim.ui.input({ prompt = "Expression: " }, function(expr)
      if expr then dap.eval(expr) end
    end)
  end, { desc = "Evaluate Expression" })

  -- Breakpoint management
  map("n", "<leader>dbc", dap.clear_breakpoints, { desc = "Clear All Breakpoints" })
  map("n", "<leader>dbl", dap.list_breakpoints, { desc = "List Breakpoints" })

  -- Run configurations
  map("n", "<leader>drl", dap.run_last, { desc = "Run Last Configuration" })
  map("n", "<leader>dro", dap.run_to_cursor, { desc = "Run to Cursor" })

  -- Function key shortcuts
  map("n", "<F5>", dap.continue, { desc = "DAP Continue" })
  map("n", "<F10>", dap.step_over, { desc = "DAP Step Over" })
  map("n", "<F11>", dap.step_into, { desc = "DAP Step Into" })
  map("n", "<F12>", dap.step_out, { desc = "DAP Step Out" })

  -- DAP UI keybindings (if dapui is available)
  local ok_ui, dapui = pcall(require, 'dapui')
  if ok_ui then
    map("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
    map("n", "<leader>dU", dapui.open, { desc = "Open DAP UI" })
    map("n", "<leader>dC", dapui.close, { desc = "Close DAP UI" })
  end

  -- DAP widgets (if available)
  local ok_widgets, widgets = pcall(require, 'dap.ui.widgets')
  if ok_widgets then
    map("n", "<leader>de", widgets.hover, { desc = "Evaluate Expression Under Cursor" })
    map("v", "<leader>de", widgets.hover, { desc = "Evaluate Selected Expression" })
    map("n", "<leader>dS", function()
      local sidebar = widgets.sidebar(widgets.scopes)
      sidebar.open()
    end, { desc = "Open Sidebar (Scopes)" })
    map("n", "<leader>dF", function()
      local sidebar = widgets.sidebar(widgets.frames)
      sidebar.open()
    end, { desc = "Open Sidebar (Frames)" })
    map("n", "<leader>dh", widgets.hover, { desc = "Hover Variables" })
    map("n", "<leader>dp", widgets.preview, { desc = "Preview Variables" })
  end

  -- Virtual text toggle (if nvim-dap-virtual-text is available)
  local ok_vt = pcall(require, 'nvim-dap-virtual-text')
  if ok_vt then
    map("n", "<leader>dvt", function()
      require('nvim-dap-virtual-text').toggle()
    end, { desc = "Toggle Virtual Text" })
  end
end

-- Set up keybindings on demand when DAP is loaded
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "javascript", "typescript", "rust", "go", "cpp", "c" },
  callback = function()
    setup_dap_keybindings()
  end,
  once = true,
})