--
-- config/typr.lua
-- Typing practice configuration with beautiful dashboard and stats
-- Provides comprehensive typing test functionality
--

local M = {}

function M.setup()
    -- Ensure Typr is loaded
    local typr_ok, typr = pcall(require, "typr")
    if not typr_ok then
        vim.notify("Typr plugin not available", vim.log.levels.WARN)
        return
    end
    
    -- Setup Typr with comprehensive configuration
    typr.setup({
        -- Core typing test settings
        test = {
            -- Default word count for typing tests
            word_count = 50,
            
            -- Enable/disable features by default
            numbers = false,      -- Include numbers in test
            symbols = false,      -- Include symbols in test
            random_mode = false,  -- Random word order
            
            -- Time-based or word-based tests
            mode = "words",       -- "words" or "time"
            time_limit = 60,      -- seconds for time-based tests
            
            -- Difficulty settings
            min_word_length = 3,
            max_word_length = 8,
        },
        
        -- Visual settings
        ui = {
            -- Dashboard appearance
            dashboard = {
                enable = true,
                title = "⌨️  Typr - Typing Practice",
                subtitle = "Improve your typing speed and accuracy",
                
                -- Dashboard sections
                sections = {
                    stats = true,
                    recent_tests = true,
                    achievements = true,
                },
            },
            
            -- Test interface styling
            typing_interface = {
                -- Colors and highlighting
                correct_char_hl = "TyprCorrect",
                incorrect_char_hl = "TyprIncorrect", 
                current_char_hl = "TyprCurrent",
                untyped_char_hl = "TyprUntyped",
                
                -- Progress indicators
                show_progress = true,
                show_wpm = true,
                show_accuracy = true,
                show_time = true,
                
                -- Line wrapping and layout
                wrap_text = true,
                center_text = false,
            },
        },
        
        -- Statistics and progress tracking
        stats = {
            -- Enable comprehensive statistics
            enable = true,
            
            -- Track detailed metrics
            track_keystrokes = true,
            track_errors = true,
            track_speed_over_time = true,
            
            -- History settings
            max_history_entries = 100,
            save_detailed_history = true,
            
            -- Performance targets
            target_wpm = 60,
            target_accuracy = 95,
        },
        
        -- Advanced features
        features = {
            -- Sound feedback
            sound_on_error = false,
            sound_on_completion = false,
            
            -- Auto-save progress
            auto_save = true,
            save_interval = 10, -- seconds
            
            -- Customization
            custom_word_lists = {},
            use_common_words = true,
            
            -- Practice modes
            enable_programming_mode = true,
            enable_language_specific = true,
        },
        
        -- File handling
        files = {
            -- Configuration and data storage
            data_dir = vim.fn.stdpath("data") .. "/typr",
            stats_file = "stats.json",
            history_file = "history.json",
            config_file = "config.json",
        },
    })
    
    -- Setup custom highlight groups for better visual feedback
    M.setup_highlights()
    
    -- Setup keymaps and commands
    M.setup_keymaps()
    M.setup_commands()
    M.setup_autocommands()
end

-- Custom highlight groups for typing interface
function M.setup_highlights()
    local highlights = {
        -- Typing interface highlights
        TyprCorrect = { fg = "#50fa7b", bold = true },      -- Green for correct
        TyprIncorrect = { fg = "#ff5555", bold = true },    -- Red for incorrect
        TyprCurrent = { fg = "#f1fa8c", bold = true, underline = true }, -- Yellow for current
        TyprUntyped = { fg = "#6272a4" },                   -- Gray for untyped
        
        -- Dashboard highlights
        TyprTitle = { fg = "#bd93f9", bold = true },        -- Purple title
        TyprSubtitle = { fg = "#8be9fd" },                  -- Cyan subtitle
        TyprStats = { fg = "#ffb86c" },                     -- Orange stats
        TyprProgress = { fg = "#50fa7b" },                  -- Green progress
        
        -- Speed indicators
        TyprWpmGood = { fg = "#50fa7b", bold = true },      -- Good WPM (>= target)
        TyprWpmBad = { fg = "#ff5555", bold = true },       -- Poor WPM (< target)
        TyprAccuracyGood = { fg = "#50fa7b", bold = true }, -- Good accuracy
        TyprAccuracyBad = { fg = "#ff5555", bold = true },  -- Poor accuracy
    }
    
    -- Apply highlights
    for name, config in pairs(highlights) do
        vim.api.nvim_set_hl(0, name, config)
    end
end

-- Setup additional keymaps for enhanced functionality
function M.setup_keymaps()
    -- No leader key mappings - access via commands and menu only
    -- This keeps the leader key namespace clean while maintaining full functionality
end

-- Enhanced commands for different typing test modes
function M.setup_commands()
    -- Quick test variations
    vim.api.nvim_create_user_command("TyprQuick", function()
        M.quick_test()
    end, { desc = "Quick 25-word typing test" })
    
    vim.api.nvim_create_user_command("TyprLong", function()
        M.long_test()
    end, { desc = "Long 100-word typing test" })
    
    vim.api.nvim_create_user_command("TyprTimed", function(opts)
        local time = tonumber(opts.args) or 60
        M.timed_test(time)
    end, { 
        desc = "Timed typing test", 
        nargs = "?",
        complete = function()
            return { "30", "60", "120", "300" }
        end
    })
    
    vim.api.nvim_create_user_command("TyprProgramming", function()
        M.programming_test()
    end, { desc = "Programming-focused typing test" })
    
    -- Statistics commands
    vim.api.nvim_create_user_command("TyprHistory", function()
        M.show_history()
    end, { desc = "Show typing test history" })
    
    vim.api.nvim_create_user_command("TyprDashboard", function()
        M.show_dashboard()
    end, { desc = "Show typing dashboard" })
    
    vim.api.nvim_create_user_command("TyprConfig", function()
        M.configure_test()
    end, { desc = "Configure typing test settings" })
end

-- Auto-commands for enhanced functionality
function M.setup_autocommands()
    local typr_group = vim.api.nvim_create_augroup("TyprEnhancements", { clear = true })
    
    -- Disable completion for typr filetype
    vim.api.nvim_create_autocmd("FileType", {
        group = typr_group,
        pattern = "typr",
        callback = function()
            -- Disable completion sources that might interfere
            vim.bo.omnifunc = ""
            vim.bo.completefunc = ""
            
            -- Set appropriate options for typing practice
            vim.opt_local.spell = false
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
            vim.opt_local.signcolumn = "no"
            vim.opt_local.cursorline = false
            vim.opt_local.wrap = true
            
            -- Focus mode
            vim.opt_local.laststatus = 0  -- Hide status line
        end,
    })
    
    -- Restore settings when leaving typr buffer
    vim.api.nvim_create_autocmd("BufLeave", {
        group = typr_group,
        pattern = "*",
        callback = function()
            if vim.bo.filetype == "typr" then
                vim.opt_local.laststatus = 2  -- Restore status line
            end
        end,
    })
    
    -- Auto-save typing statistics
    vim.api.nvim_create_autocmd("VimLeavePre", {
        group = typr_group,
        callback = function()
            -- Auto-save any pending statistics
            pcall(require("typr.stats").save)
        end,
    })
end

-- Enhanced test functions
function M.quick_test()
    vim.cmd("Typr")
    -- Configure for quick test (25 words, no symbols/numbers)
    vim.defer_fn(function()
        if vim.bo.filetype == "typr" then
            vim.api.nvim_feedkeys("2", "n", false)  -- Set to 25 words
        end
    end, 100)
end

function M.long_test()
    vim.cmd("Typr")
    -- Configure for long test (100 words)
    vim.defer_fn(function()
        if vim.bo.filetype == "typr" then
            vim.api.nvim_feedkeys("4", "n", false)  -- Set to 100 words
        end
    end, 100)
end

function M.timed_test(seconds)
    vim.cmd("Typr")
    -- Note: Timed mode configuration would depend on plugin capabilities
    vim.notify(string.format("Starting %d-second typing test", seconds), vim.log.levels.INFO)
end

function M.programming_test()
    vim.cmd("Typr")
    -- Configure for programming test (with symbols/numbers)
    vim.defer_fn(function()
        if vim.bo.filetype == "typr" then
            vim.api.nvim_feedkeys("s", "n", false)  -- Toggle symbols
            vim.api.nvim_feedkeys("n", "n", false)  -- Toggle numbers
        end
    end, 100)
end

function M.show_history()
    vim.cmd("TyprStats")
    vim.defer_fn(function()
        vim.api.nvim_feedkeys("H", "n", false)  -- Show history
    end, 100)
end

function M.show_dashboard()
    vim.cmd("TyprStats")
    vim.defer_fn(function()
        vim.api.nvim_feedkeys("D", "n", false)  -- Show dashboard
    end, 100)
end

function M.configure_test()
    vim.cmd("Typr")
    vim.notify("Use 's' for symbols, 'n' for numbers, 'r' for random mode, and number keys for word count", vim.log.levels.INFO)
end

-- Get typing statistics for status line integration
function M.get_typing_status()
    local stats_ok, stats = pcall(require, "typr.stats")
    if not stats_ok then
        return ""
    end
    
    local recent_wpm = stats.get_recent_wpm()
    local avg_accuracy = stats.get_average_accuracy()
    
    if recent_wpm and avg_accuracy then
        return string.format("⌨️ %dwpm %.1f%%", recent_wpm, avg_accuracy)
    end
    
    return ""
end

return M