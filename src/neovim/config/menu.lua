--
-- config/menu.lua
-- Advanced Menu System Configuration
-- Provides context-aware, customizable menu interfaces
--

local M = {}

-- Enhanced menu configuration function
function M.setup()
    -- Ensure Menu is loaded
    local menu_ok, menu = pcall(require, "menu")
    if not menu_ok then
        vim.notify("Menu plugin not available", vim.log.levels.WARN)
        return
    end

    -- Use default highlights from the plugin

    -- Define custom menu configurations
    M.setup_custom_menus()
    M.setup_keymaps()
    M.setup_autocommands()
    pcall(M.integrate_with_telescope)
end

-- Custom menu definitions
function M.setup_custom_menus()
    -- Create menus directory structure
    local config_path = vim.fn.stdpath("config")
    local menus_path = config_path .. "/lua/menus"
    
    -- Ensure menus directory exists
    vim.fn.mkdir(menus_path, "p")
    
    -- Define menu structure compatible with nvzone/menu (array format)
    local default_menu = {
        { name = "🔭 Find File", cmd = "lua require('telescope.builtin').find_files()", rtxt = "f" },
        { name = "🔭 Recent Files", cmd = "lua require('telescope.builtin').oldfiles()", rtxt = "r" },
        { name = "🔭 Find in Files", cmd = "lua require('telescope.builtin').live_grep()", rtxt = "g" },
        { name = "🍿 File Explorer", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.explorer() else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = "e" },
        
        { name = "separator" },
        
        { name = "  New File", cmd = "enew", rtxt = "e" },
        { name = "  Save File", cmd = "w", rtxt = "s" },
        { name = "  Save All", cmd = "wa", rtxt = "a" },
        
        { name = "separator" },
        
        { name = "🔭 Buffer List", cmd = "lua require('telescope.builtin').buffers()", rtxt = "b" },
        { name = "  Next Buffer", cmd = "bnext", rtxt = "N" },
        { name = "  Previous Buffer", cmd = "bprevious", rtxt = "P" },
        { name = "  Close Buffer", cmd = "Kwbd", rtxt = "c" },
        
        { name = "separator" },
        
        { name = "  LSP Info", cmd = "LspInfo", rtxt = "i", hl = "Exblue" },
        { name = "  Go to Definition", cmd = "ALEGoToDefinition", rtxt = "d" },
        { name = "  Find References", cmd = "ALEFindReferences", rtxt = "R" },
        { name = "  Format Code", cmd = "ALEFix", rtxt = "F" },
        
        { name = "separator" },
        
        { name = "  AI Chat", cmd = "CodeCompanionChat", rtxt = "C", hl = "ExRed" },
        { name = "  AI Actions", cmd = "CodeCompanionActions", rtxt = "A", hl = "ExRed" },
        
        { name = "separator" },
        
        { name = "🐛 Toggle Breakpoint", cmd = "lua require('dap').toggle_breakpoint()", rtxt = "db", hl = "ExRed" },
        { name = "🐛 Start/Continue Debug", cmd = "lua require('dap').continue()", rtxt = "dc", hl = "ExRed" },
        { name = "🐛 Step Over", cmd = "lua require('dap').step_over()", rtxt = "ds", hl = "ExRed" },
        { name = "🐛 Toggle DAP UI", cmd = "lua require('dapui').toggle()", rtxt = "du", hl = "ExRed" },
        
        { name = "separator" },
        
        { name = "🍿 Dashboard", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.dashboard() else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = "D", hl = "ExCyan" },
        { name = "🍿 Scratch Buffer", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.scratch() else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = ".", hl = "ExCyan" },
        { name = "🍿 Explorer", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.explorer() else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = "E", hl = "ExCyan" },
        { name = "🍿 Zen Mode", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.zen() else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = "Z", hl = "ExCyan" },
        { name = "🍿 LazyGit", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.lazygit() else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = "G", hl = "ExCyan" },
        
        { name = "separator" },
        
        { name = "⌨️  Typing Test", cmd = "Typr", rtxt = "T", hl = "ExYellow" },
        { name = "  Typing Stats", cmd = "TyprStats", rtxt = "St", hl = "ExYellow" },
        
        { name = "separator" },
        
        { name = "  Git Status", cmd = "Git", rtxt = "S", hl = "ExGreen" },
        { name = "  Git Blame", cmd = "Git blame", rtxt = "B", hl = "ExGreen" },
        
        { name = "separator" },
        
        { name = "🍿 Terminal", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.terminal() else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = "t" },
        { name = "  Plugin Manager", cmd = "Lazy", rtxt = "l" },
        { name = "  Mason (LSP)", cmd = "Mason", rtxt = "m" },
    }
    
    -- LaTeX-specific menu for .tex files
    local latex_menu = {
        { name = "📝 Compile", cmd = "VimtexCompile", rtxt = "ll" },
        { name = "📖 View PDF", cmd = "VimtexView", rtxt = "lv" },
        { name = "📋 Toggle TOC", cmd = "VimtexTocToggle", rtxt = "lt" },
        
        { name = "separator" },
        
        { name = "🧹 Clean Aux", cmd = "VimtexClean", rtxt = "lk" },
        { name = "🧹 Clean All", cmd = "VimtexClean!", rtxt = "lK" },
        { name = "🛑 Stop", cmd = "VimtexStop", rtxt = "ls" },
        
        { name = "separator" },
        
        { name = "📐 Insert Section", cmd = "normal i\\section{}", rtxt = "lss" },
        { name = "📐 Insert Subsection", cmd = "normal i\\subsection{}", rtxt = "lsS" },
        { name = "🖼️ Insert Figure", cmd = "lua vim.api.nvim_put({'\\\\begin{figure}[htbp]', '    \\\\centering', '    \\\\includegraphics[width=0.8\\\\textwidth]{filename}', '    \\\\caption{Caption}', '    \\\\label{fig:label}', '\\\\end{figure}'}, 'l', true, true)", rtxt = "lff" },
        { name = "📊 Insert Table", cmd = "lua vim.api.nvim_put({'\\\\begin{table}[htbp]', '    \\\\centering', '    \\\\begin{tabular}{|c|c|}', '        \\\\hline', '        Header1 & Header2 \\\\\\\\', '        \\\\hline', '        Data1 & Data2 \\\\\\\\', '        \\\\hline', '    \\\\end{tabular}', '    \\\\caption{Caption}', '    \\\\label{tab:label}', '\\\\end{table}'}, 'l', true, true)", rtxt = "lft" },
        
        { name = "separator" },
        
        { name = "📚 Insert Citation", cmd = "normal i\\cite{}", rtxt = "lrc" },
        { name = "🏷️ Insert Label", cmd = "normal i\\label{}", rtxt = "lrl" },
        { name = "🔗 Insert Reference", cmd = "normal i\\ref{}", rtxt = "lrr" },
        
        { name = "separator" },
        
        { name = "ℹ️ VimTeX Info", cmd = "VimtexInfo", rtxt = "li" },
        { name = "📄 Show Log", cmd = "VimtexLog", rtxt = "lq" },
        { name = "❌ Show Errors", cmd = "VimtexErrors", rtxt = "le" },
    }
    
    -- Context-specific menus
    local nvimtree_menu = {
        { name = "  Open File", cmd = "normal o", rtxt = "o" },
        { name = "  Open in Split", cmd = "normal i", rtxt = "i" },
        { name = "  Open in VSplit", cmd = "normal s", rtxt = "s" },
        { name = "  Open in Tab", cmd = "normal t", rtxt = "t" },
        
        { name = "separator" },
        
        { name = "  New File", cmd = "normal a", rtxt = "a" },
        { name = "  Delete", cmd = "normal d", rtxt = "d" },
        { name = "  Rename", cmd = "normal r", rtxt = "r" },
        { name = "  Copy", cmd = "normal c", rtxt = "c" },
        { name = "  Refresh", cmd = "normal R", rtxt = "R" },
    }
    
    local terminal_menu = {
        { name = "  Exit Terminal Mode", cmd = "stopinsert", rtxt = "e" },
        { name = "  Close Terminal", cmd = "close", rtxt = "c" },
        { name = "  New Terminal", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.terminal() else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = "n" },
        { name = "  Clear Screen", cmd = "normal i<C-l>", rtxt = "l" },
    }
    
    -- Save menu configurations
    M.menus = {
        default = default_menu,
        nvimtree = nvimtree_menu,
        terminal = terminal_menu,
        latex = latex_menu,
    }
end

-- Enhanced keymapping setup
function M.setup_keymaps()
    local opts = { noremap = true, silent = true }
    
    -- Main menu trigger
    vim.keymap.set("n", "<C-t>", function()
        M.open_smart_menu()
    end, vim.tbl_extend("force", opts, { desc = "Open Smart Menu" }))
    
    -- Context menu with right-click
    vim.keymap.set({ "n", "v" }, "<RightMouse>", function()
        -- Clean up any existing menus first
        local menu_utils_ok, menu_utils = pcall(require, 'menu.utils')
        if menu_utils_ok and menu_utils.delete_old_menus then
            pcall(menu_utils.delete_old_menus)
        end
        M.open_context_menu({ mouse = true })
    end, vim.tbl_extend("force", opts, { desc = "Open Context Menu" }))
    
    -- Alternative menu triggers
    vim.keymap.set("n", "<leader>m", function()
        M.open_smart_menu()
    end, vim.tbl_extend("force", opts, { desc = "Open Menu" }))
    
    vim.keymap.set("n", "<leader>M", function()
        M.open_context_menu()
    end, vim.tbl_extend("force", opts, { desc = "Open Context Menu" }))
    
    -- Quick access menus
    vim.keymap.set("n", "<leader>mf", function()
        M.open_file_menu()
    end, vim.tbl_extend("force", opts, { desc = "File Menu" }))
    
    vim.keymap.set("n", "<leader>mg", function()
        M.open_git_menu()
    end, vim.tbl_extend("force", opts, { desc = "Git Menu" }))
    
    vim.keymap.set("n", "<leader>mc", function()
        M.open_code_menu()
    end, vim.tbl_extend("force", opts, { desc = "Code Menu" }))
    
    vim.keymap.set("n", "<leader>ma", function()
        M.open_ai_menu()
    end, vim.tbl_extend("force", opts, { desc = "AI Assistant Menu" }))
    
    vim.keymap.set("n", "<leader>md", function()
        M.open_debug_menu()
    end, vim.tbl_extend("force", opts, { desc = "Debug Menu" }))
    
    vim.keymap.set("n", "<leader>mF", function()
        M.open_file_management_menu()
    end, vim.tbl_extend("force", opts, { desc = "File Management Menu" }))
end

-- Smart menu opening based on context
function M.open_smart_menu()
    local menu = require("menu")
    local context = M.get_context()
    
    -- Clean up any existing menus
    local menu_utils_ok, menu_utils = pcall(require, 'menu.utils')
    if menu_utils_ok and menu_utils.delete_old_menus then
        pcall(menu_utils.delete_old_menus)
    end
    
    local menu_config = M.menus[context] or M.menus.default
    
    -- Add project-specific menus to default context
    if context == "default" then
        local project_menus = M.get_project_specific_menu()
        if #project_menus > 0 then
            -- Create a copy and add project menus
            local enhanced_config = vim.deepcopy(menu_config)
            -- Add separator before project menus
            table.insert(enhanced_config, { name = "separator" })
            -- Add project menu items
            for _, item in ipairs(project_menus) do
                table.insert(enhanced_config, item)
            end
            menu_config = enhanced_config
        end
    end
    
    -- Ensure menu_config is valid before opening (array format)
    if menu_config and type(menu_config) == "table" and #menu_config > 0 then
        local success, err = pcall(menu.open, menu_config, {
            border = true,
            mouse = false,
        })
        if not success then
            vim.notify("Failed to open menu: " .. tostring(err), vim.log.levels.ERROR)
        end
    else
        vim.notify("No menu configuration available for current context", vim.log.levels.WARN)
    end
end

-- Context-aware menu opening
function M.open_context_menu(opts)
    local menu = require("menu")
    opts = opts or {}
    
    local context = M.get_context()
    local menu_config = M.menus[context] or M.menus.default
    
    -- Clean up any existing menus
    local menu_utils_ok, menu_utils = pcall(require, 'menu.utils')
    if menu_utils_ok and menu_utils.delete_old_menus then
        pcall(menu_utils.delete_old_menus)
    end
    
    -- Ensure menu_config is valid before opening (array format)
    if menu_config and type(menu_config) == "table" and #menu_config > 0 then
        local success, err = pcall(menu.open, menu_config, vim.tbl_extend("force", {
            border = true,
            mouse = opts.mouse or false,
        }, opts))
        if not success then
            vim.notify("Failed to open context menu: " .. tostring(err), vim.log.levels.ERROR)
        end
    else
        vim.notify("No menu configuration available for current context", vim.log.levels.WARN)
    end
end

-- Get current context for smart menu selection
function M.get_context()
    local buftype = vim.bo.buftype
    local filetype = vim.bo.filetype
    
    -- Terminal context
    if buftype == "terminal" then
        return "terminal"
    end
    
    -- NvimTree context
    if filetype == "NvimTree" then
        return "nvimtree"
    end
    
    -- LaTeX context
    if filetype == "tex" or filetype == "latex" or filetype == "plaintex" then
        return "latex"
    end
    
    -- Default context
    return "default"
end

-- Specialized menu functions for specific categories
function M.open_file_menu()
    local menu = require("menu")
    local menu_utils_ok, menu_utils = pcall(require, 'menu.utils')
    if menu_utils_ok and menu_utils.delete_old_menus then
        pcall(menu_utils.delete_old_menus)
    end
    
    if not M.menus or not M.menus.default then
        vim.notify("Menu configuration not initialized", vim.log.levels.ERROR)
        return
    end
    
    -- Create file-specific menu from array
    local file_menu = {}
    for _, item in ipairs(M.menus.default) do
        if item.name and (item.name:match("File") or item.name:match("Find") or item.name:match("Save")) then
            table.insert(file_menu, item)
        end
    end
    
    if #file_menu > 0 then
        local success, err = pcall(menu.open, file_menu, { 
            border = true,
        })
        if not success then
            vim.notify("Failed to open file menu: " .. tostring(err), vim.log.levels.ERROR)
        end
    else
        vim.notify("File menu not found", vim.log.levels.WARN)
    end
end

function M.open_git_menu()
    local menu = require("menu")
    local menu_utils_ok, menu_utils = pcall(require, 'menu.utils')
    if menu_utils_ok and menu_utils.delete_old_menus then
        pcall(menu_utils.delete_old_menus)
    end
    
    if not M.menus or not M.menus.default then
        vim.notify("Menu configuration not initialized", vim.log.levels.ERROR)
        return
    end
    
    -- Create git-specific menu from array
    local git_menu = {}
    for _, item in ipairs(M.menus.default) do
        if item.name and item.name:match("Git") then
            table.insert(git_menu, item)
        end
    end
    
    if #git_menu > 0 then
        local success, err = pcall(menu.open, git_menu, { 
            border = true,
        })
        if not success then
            vim.notify("Failed to open git menu: " .. tostring(err), vim.log.levels.ERROR)
        end
    else
        vim.notify("Git menu not found", vim.log.levels.WARN)
    end
end

function M.open_code_menu()
    local menu = require("menu")
    local menu_utils_ok, menu_utils = pcall(require, 'menu.utils')
    if menu_utils_ok and menu_utils.delete_old_menus then
        pcall(menu_utils.delete_old_menus)
    end
    
    if not M.menus or not M.menus.default then
        vim.notify("Menu configuration not initialized", vim.log.levels.ERROR)
        return
    end
    
    -- Create code-specific menu from array
    local code_menu = {}
    for _, item in ipairs(M.menus.default) do
        if item.name and (item.name:match("LSP") or item.name:match("Definition") or item.name:match("References") or item.name:match("Format")) then
            table.insert(code_menu, item)
        end
    end
    
    if #code_menu > 0 then
        local success, err = pcall(menu.open, code_menu, { 
            border = true,
        })
        if not success then
            vim.notify("Failed to open code menu: " .. tostring(err), vim.log.levels.ERROR)
        end
    else
        vim.notify("Code menu not found", vim.log.levels.WARN)
    end
end

function M.open_ai_menu()
    local menu = require("menu")
    local menu_utils_ok, menu_utils = pcall(require, 'menu.utils')
    if menu_utils_ok and menu_utils.delete_old_menus then
        pcall(menu_utils.delete_old_menus)
    end
    
    if not M.menus or not M.menus.default then
        vim.notify("Menu configuration not initialized", vim.log.levels.ERROR)
        return
    end
    
    -- Create AI-specific menu from array
    local ai_menu = {}
    for _, item in ipairs(M.menus.default) do
        if item.name and item.name:match("AI") then
            table.insert(ai_menu, item)
        end
    end
    
    if #ai_menu > 0 then
        local success, err = pcall(menu.open, ai_menu, { 
            border = true,
        })
        if not success then
            vim.notify("Failed to open AI menu: " .. tostring(err), vim.log.levels.ERROR)
        end
    else
        vim.notify("AI Assistant menu not found", vim.log.levels.WARN)
    end
end

function M.open_debug_menu()
    local menu = require("menu")
    local menu_utils_ok, menu_utils = pcall(require, 'menu.utils')
    if menu_utils_ok and menu_utils.delete_old_menus then
        pcall(menu_utils.delete_old_menus)
    end
    
    -- Create comprehensive debug menu
    local debug_menu = {
        { name = "🚀 Start/Continue Debug", cmd = "lua require('dap').continue()", rtxt = "dc" },
        { name = "🛑 Stop Debugging", cmd = "lua require('dap').terminate()", rtxt = "dt" },
        { name = "🔄 Restart Debug", cmd = "lua require('dap').restart()", rtxt = "dr" },
        
        { name = "separator" },
        
        { name = "🔴 Toggle Breakpoint", cmd = "lua require('dap').toggle_breakpoint()", rtxt = "db" },
        { name = "🔶 Conditional Breakpoint", cmd = "lua require('dap').set_breakpoint(vim.fn.input('Condition: '))", rtxt = "dB" },
        { name = "📝 Log Point", cmd = "lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Log message: '))", rtxt = "dlp" },
        { name = "🧹 Clear All Breakpoints", cmd = "lua require('dap').clear_breakpoints()", rtxt = "dbc" },
        
        { name = "separator" },
        
        { name = "⏩ Step Over", cmd = "lua require('dap').step_over()", rtxt = "ds" },
        { name = "⏬ Step Into", cmd = "lua require('dap').step_into()", rtxt = "di" },
        { name = "⏫ Step Out", cmd = "lua require('dap').step_out()", rtxt = "do" },
        { name = "🎯 Run to Cursor", cmd = "lua require('dap').run_to_cursor()", rtxt = "dro" },
        
        { name = "separator" },
        
        { name = "🖥️ Toggle DAP UI", cmd = "lua require('dapui').toggle()", rtxt = "du" },
        { name = "📊 Open REPL", cmd = "lua require('dap').repl.open()", rtxt = "dR" },
        { name = "🔍 Hover Variables", cmd = "lua require('dap.ui.widgets').hover()", rtxt = "dh" },
        { name = "👁️ Toggle Virtual Text", cmd = "lua require('nvim-dap-virtual-text').toggle()", rtxt = "dvt" },
        
        { name = "separator" },
        
        { name = "📋 Evaluate Expression", cmd = "lua vim.ui.input({prompt='Expression: '}, function(expr) if expr then require('dap').eval(expr) end end)", rtxt = "dE" },
        { name = "📖 Open Scopes", cmd = "lua local widgets=require('dap.ui.widgets'); widgets.sidebar(widgets.scopes).open()", rtxt = "dS" },
        { name = "🗂️ Open Frames", cmd = "lua local widgets=require('dap.ui.widgets'); widgets.sidebar(widgets.frames).open()", rtxt = "dF" },
    }
    
    local success, err = pcall(menu.open, debug_menu, { 
        border = true,
    })
    if not success then
        vim.notify("Failed to open debug menu: " .. tostring(err), vim.log.levels.ERROR)
    end
end

function M.open_file_management_menu()
    local menu = require("menu")
    local menu_utils_ok, menu_utils = pcall(require, 'menu.utils')
    if menu_utils_ok and menu_utils.delete_old_menus then
        pcall(menu_utils.delete_old_menus)
    end
    
    -- Create comprehensive file management menu
    local file_menu = {
        { name = "📁 Open File Explorer", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.explorer() else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = "o" },
        { name = "🪟 Open Explorer (Float)", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.explorer({ float = true }) else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = "O" },
        { name = "🍿 Snacks Explorer", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.explorer() else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = "e" },
        
        { name = "separator" },
        
        { name = "🔭 Find Files", cmd = "lua require('telescope.builtin').find_files()", rtxt = "f" },
        { name = "🔭 Recent Files", cmd = "lua require('telescope.builtin').oldfiles()", rtxt = "r" },
        { name = "🔭 Live Grep", cmd = "lua require('telescope.builtin').live_grep()", rtxt = "g" },
        { name = "🔭 Buffers", cmd = "lua require('telescope.builtin').buffers()", rtxt = "b" },
        
        { name = "separator" },
        
        { name = "📄 New File", cmd = "enew", rtxt = "N" },
        { name = "💾 Save File", cmd = "w", rtxt = "s" },
        { name = "💾 Save All", cmd = "wa", rtxt = "a" },
        { name = "❌ Close Buffer", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.bufdelete() else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = "c" },
        
        { name = "separator" },
        
        { name = "📋 Copy File Path", cmd = "lua vim.fn.setreg('+', vim.fn.expand('%:p'))", rtxt = "p" },
        { name = "📋 Copy File Name", cmd = "lua vim.fn.setreg('+', vim.fn.expand('%:t'))", rtxt = "t" },
        { name = "📂 Open File Directory", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.explorer({ cwd = vim.fn.expand('%:p:h') }) else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = "d" },
    }
    
    local success, err = pcall(menu.open, file_menu, { 
        border = true,
    })
    if not success then
        vim.notify("Failed to open file management menu: " .. tostring(err), vim.log.levels.ERROR)
    end
end

function M.open_typing_menu()
    local menu = require("menu")
    local menu_utils_ok, menu_utils = pcall(require, 'menu.utils')
    if menu_utils_ok and menu_utils.delete_old_menus then
        pcall(menu_utils.delete_old_menus)
    end
    
    -- Create typing-specific menu
    local typing_menu = {
        { name = "⌨️  Quick Test (25 words)", cmd = "TyprQuick", rtxt = "q" },
        { name = "⌨️  Long Test (100 words)", cmd = "TyprLong", rtxt = "l" },
        { name = "⌨️  Programming Test", cmd = "TyprProgramming", rtxt = "p" },
        { name = "⌨️  Timed Test (60s)", cmd = "TyprTimed 60", rtxt = "t" },
        
        { name = "separator" },
        
        { name = "  Dashboard", cmd = "TyprDashboard", rtxt = "d" },
        { name = "  Statistics", cmd = "TyprStats", rtxt = "s" },
        { name = "  History", cmd = "TyprHistory", rtxt = "h" },
        
        { name = "separator" },
        
        { name = "  Configure", cmd = "TyprConfig", rtxt = "c" },
    }
    
    local success, err = pcall(menu.open, typing_menu, { 
        border = true,
    })
    if not success then
        vim.notify("Failed to open typing menu: " .. tostring(err), vim.log.levels.ERROR)
    end
end

-- Auto-command setup for enhanced functionality
function M.setup_autocommands()
    -- Create autocommand group
    local menu_group = vim.api.nvim_create_augroup("MenuEnhancements", { clear = true })
    
    -- Clean up menus when changing buffers
    vim.api.nvim_create_autocmd("BufEnter", {
        group = menu_group,
        callback = function()
            pcall(require('menu.utils').delete_old_menus)
        end,
    })
    
    -- Enhanced menu behavior in different contexts
    vim.api.nvim_create_autocmd("FileType", {
        group = menu_group,
        pattern = "NvimTree",
        callback = function()
            -- Special keybindings for NvimTree
            vim.keymap.set("n", "m", function()
                M.open_context_menu()
            end, { buffer = true, desc = "NvimTree Menu" })
        end,
    })
    
    vim.api.nvim_create_autocmd("TermOpen", {
        group = menu_group,
        callback = function()
            -- Special keybindings for terminal
            vim.keymap.set("t", "<C-t>", function()
                M.open_context_menu()
            end, { buffer = true, desc = "Terminal Menu" })
        end,
    })
end

-- Utility functions for menu enhancement
function M.create_dynamic_menu()
    -- This function can be extended to create dynamic menus based on:
    -- - Current project structure
    -- - Available LSP servers
    -- - Git repository status
    -- - Recently opened files
    -- - Custom user preferences
    
    local dynamic_items = {}
    
    -- Add recent files if available
    if vim.v.oldfiles and #vim.v.oldfiles > 0 then
        local recent_files = {}
        for i, file in ipairs(vim.v.oldfiles) do
            if i > 5 then break end -- Limit to 5 recent files
            table.insert(recent_files, {
                name = "  " .. vim.fn.fnamemodify(file, ":t"),
                cmd = "edit " .. file,
                key = tostring(i)
            })
        end
        
        if #recent_files > 0 then
            table.insert(dynamic_items, {
                name = "Recent Files",
                hl = "Comment",
                items = recent_files
            })
        end
    end
    
    return dynamic_items
end

-- Integration with existing plugins
function M.integrate_with_telescope()
    -- Telescope is already integrated in the menu definitions above
    -- This function is maintained for compatibility but telescope commands
    -- are now directly embedded in the menu structure
    local telescope_ok, _ = pcall(require, "telescope")
    if telescope_ok then
        vim.notify("Telescope integration active in menu system", vim.log.levels.DEBUG)
    end
end

-- Advanced menu customization based on current project
function M.get_project_specific_menu()
    local cwd = vim.fn.getcwd()
    local project_menu = {}
    
    -- Check for specific project types and add relevant menu items
    if vim.fn.filereadable(cwd .. "/package.json") == 1 then
        table.insert(project_menu, { name = "📦 npm install", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.terminal('npm install') else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = "i" })
        table.insert(project_menu, { name = "📦 npm start", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.terminal('npm start') else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = "s" })
        table.insert(project_menu, { name = "📦 npm test", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.terminal('npm test') else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = "t" })
        table.insert(project_menu, { name = "📦 npm build", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.terminal('npm run build') else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = "b" })
        table.insert(project_menu, { name = "🔭 Find JS/TS", cmd = "lua require('telescope.builtin').find_files({find_command={'rg','--files','--glob','*.{js,ts,jsx,tsx}'}})", rtxt = "j" })
    end
    
    if vim.fn.filereadable(cwd .. "/Cargo.toml") == 1 then
        table.insert(project_menu, { name = "🦀 cargo build", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.terminal('cargo build') else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = "B" })
        table.insert(project_menu, { name = "🦀 cargo run", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.terminal('cargo run') else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = "R" })
        table.insert(project_menu, { name = "🦀 cargo test", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.terminal('cargo test') else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = "T" })
        table.insert(project_menu, { name = "🦀 cargo check", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.terminal('cargo check') else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = "C" })
        table.insert(project_menu, { name = "🔭 Find Rust", cmd = "lua require('telescope.builtin').find_files({find_command={'rg','--files','--glob','*.rs'}})", rtxt = "r" })
    end
    
    if vim.fn.filereadable(cwd .. "/requirements.txt") == 1 or vim.fn.filereadable(cwd .. "/src/pyproject.toml") == 1 then
        table.insert(project_menu, { name = "🐍 pip install", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.terminal('pip install -r requirements.txt') else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = "I" })
        table.insert(project_menu, { name = "🐍 pytest", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.terminal('python -m pytest') else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = "p" })
        table.insert(project_menu, { name = "🐍 run main", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.terminal('python main.py') else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = "M" })
        table.insert(project_menu, { name = "🐍 pip freeze", cmd = "lua local ok, s = pcall(require, 'snacks'); if ok and s then s.terminal('pip freeze') else vim.notify('Snacks not loaded', vim.log.levels.WARN) end", rtxt = "F" })
        table.insert(project_menu, { name = "🔭 Find Python", cmd = "lua require('telescope.builtin').find_files({find_command={'rg','--files','--glob','*.py'}})", rtxt = "y" })
    end
    
    return project_menu
end

-- Enhanced error handling for menu operations
function M.safe_execute_command(cmd)
    local success, result = pcall(function()
        vim.cmd(cmd)
    end)
    
    if not success then
        vim.notify("Menu command failed: " .. tostring(result), vim.log.levels.ERROR)
    end
end

-- Status line integration (show current menu context)
function M.get_menu_status()
    local context = M.get_context()
    local status_icons = {
        default = "📋",
        nvimtree = "📁",
        terminal = "💻",
    }
    
    return status_icons[context] or "📋"
end

return M