--
-- config/keymaps/editing.lua
-- Text editing enhancements
--

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Better indenting (stay in visual mode)
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- Move lines up and down
map("n", "<A-j>", ":m .+1<CR>==", opts)
map("n", "<A-k>", ":m .-2<CR>==", opts)
map("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
map("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)

-- Paste without yanking in visual mode
map("v", "p", '"_dP', opts)
map("v", "<leader>p", [["_dP]], { desc = "Paste without yank" })

-- Select to end of line
map("n", "<leader><leader>", "v$h", opts)

-- Code execution
map("n", "<leader>r", "<cmd>RunFile<cr>", { desc = "Run current file" })

-- Formatting
map("n", "<leader>f", "<cmd>Format<cr>", { desc = "Format buffer" })
map("n", "<leader>F", "<cmd>Format all<cr>", { desc = "Format buffer (all fixes)" })

-- Python specific run command (F5)
map("n", "<F5>", function()
  if vim.bo.filetype == "python" then
    vim.cmd("write")
    local cmd = "python3 " .. vim.fn.shellescape(vim.fn.expand("%"))
    local ok, snacks = pcall(require, "snacks")
    if ok then
      snacks.terminal(cmd, { cwd = vim.fn.expand("%:p:h"), win = { position = "bottom", height = 0.3 } })
    else
      vim.cmd("split | terminal " .. cmd)
    end
  end
end, { desc = "Run Python file" })