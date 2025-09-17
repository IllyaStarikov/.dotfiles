--
-- config/keymaps/navigation.lua
-- Buffer, window, split and file navigation
--

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Window navigation with arrows
map("n", "<up>", "<C-w><up>", opts)
map("n", "<down>", "<C-w><down>", opts)
map("n", "<left>", "<C-w><left>", opts)
map("n", "<right>", "<C-w><right>", opts)

-- Smart split navigation
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Split creation
map("n", "<leader>-", ":split<CR>", { desc = "Horizontal Split" })
map("n", "<leader>|", ":vsplit<CR>", { desc = "Vertical Split" })

-- Window resizing
map("n", "<C-Up>", ":resize +2<CR>", opts)
map("n", "<C-Down>", ":resize -2<CR>", opts)
map("n", "<C-Left>", ":vertical resize -2<CR>", opts)
map("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Buffer navigation
map("n", "<Tab>", ":bnext<cr>", opts)
map("n", "<S-Tab>", ":bprevious<cr>", opts)
map("n", "<S-h>", ":bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", ":bnext<cr>", { desc = "Next buffer" })
map("n", "[b", ":bprevious<cr>", { desc = "Previous buffer" })
map("n", "]b", ":bnext<cr>", { desc = "Next buffer" })

-- Buffer management
map("n", "<leader>bd", ":bdelete<cr>", { desc = "Delete buffer" })
map("n", "<leader>ba", ":%bdelete<cr>", { desc = "Delete all buffers" })
map("n", "<leader>bo", ":%bdelete|edit#|bdelete#<cr>", { desc = "Delete other buffers" })
map("n", "<leader>c", ":Kwbd<cr>", { desc = "Delete buffer (keep window)" })

-- Buffer navigation by number
for i = 1, 9 do
  map("n", "<leader>" .. i, function()
    vim.cmd("buffer " .. i)
  end, { desc = "Go to buffer " .. i })
end
map("n", "<leader>0", ":bprevious<cr>", { desc = "Go to previous buffer" })

-- Show buffer list
map("n", "<leader>bb", function()
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })
  local lines = {}
  for i, buf in ipairs(buffers) do
    local name = vim.fn.fnamemodify(buf.name, ":t")
    if name == "" then
      name = "[No Name]"
    end
    local modified = buf.changed == 1 and " [+]" or ""
    table.insert(lines, string.format("%d: %s%s", i, name, modified))
  end
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Open Buffers" })
end, { desc = "Show buffer list" })

-- Tab navigation
map("n", "<leader>tn", ":tabnew<CR>", { desc = "New Tab" })
map("n", "<leader>tc", ":tabclose<CR>", { desc = "Close Tab" })
map("n", "<leader>to", ":tabonly<CR>", { desc = "Close Other Tabs" })
map("n", "[t", ":tabprevious<CR>", { desc = "Previous Tab" })
map("n", "]t", ":tabnext<CR>", { desc = "Next Tab" })

-- Quickfix navigation
map("n", "<leader>qo", ":copen<CR>", { desc = "Open Quickfix" })
map("n", "<leader>qc", ":cclose<CR>", { desc = "Close Quickfix" })
map("n", "[q", ":cprevious<CR>", { desc = "Previous Quickfix" })
map("n", "]q", ":cnext<CR>", { desc = "Next Quickfix" })

-- Location list navigation
map("n", "<leader>lo", ":lopen<CR>", { desc = "Open Location List" })
map("n", "<leader>lc", ":lclose<CR>", { desc = "Close Location List" })
map("n", "[l", ":lprevious<CR>", { desc = "Previous Location" })
map("n", "]l", ":lnext<CR>", { desc = "Next Location" })

-- Center cursor after jumps
map("n", "<C-d>", "<C-d>zz", opts)
map("n", "<C-u>", "<C-u>zz", opts)
map("n", "n", "nzzzv", opts)
map("n", "N", "Nzzzv", opts)
map("n", "*", "*zz", opts)
map("n", "#", "#zz", opts)
map("n", "g*", "g*zz", opts)
map("n", "g#", "g#zz", opts)
