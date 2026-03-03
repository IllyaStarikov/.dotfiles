--
-- render-markdown.nvim configuration
-- Clean markdown rendering with anti-conceal (raw markdown on cursor line)
--

-- TokyoNight Moon palette blended at 35% over #222436
local heading_bg = {
  "#6f404f", -- H1: red/pink
  "#594d7c", -- H2: purple
  "#45667b", -- H3: cyan
  "#5a6854", -- H4: green
  "#6f5d4d", -- H5: yellow
  "#6f4c49", -- H6: orange
}

local heading_fg = {
  "#ffc9ce", -- H1: bright pink
  "#dcc5ff", -- H2: bright purple
  "#b4eeff", -- H3: bright cyan
  "#d9f0a5", -- H4: bright green
  "#ffe2a6", -- H5: bright amber
  "#ffbfa5", -- H6: bright orange
}

require("render-markdown").setup({
  file_types = { "markdown", "quarto", "rmd" },
  render_modes = { "n", "c", "v", "V" },
  max_file_size = 10.0,

  -- Show raw markdown only on the cursor line (eliminates insert-mode toggle dance)
  anti_conceal = {
    enabled = true,
    ignore = {
      code_background = true,
      sign = true,
      head_background = true,
    },
  },

  -- Let render-markdown manage conceallevel automatically
  win_options = {
    conceallevel = {
      default = vim.o.conceallevel,
      rendered = 3,
    },
    concealcursor = {
      default = vim.o.concealcursor,
      rendered = "",
    },
  },

  -- Headings — chevron icons, backgrounds overridden below
  heading = {
    enabled = true,
    sign = false,
    icons = {
      "❯ ",
      "❯❯ ",
      "❯❯❯ ",
      "❯❯❯❯ ",
      "❯❯❯❯❯ ",
      "❯❯❯❯❯❯ ",
    },
    width = "block",
    min_width = 100,
    border = false,
  },

  -- Code blocks — full background with language labels
  code = {
    enabled = true,
    sign = false,
    style = "full",
    position = "right",
    language_icon = true,
    language_name = true,
    width = "full",
    left_pad = 2,
    right_pad = 2,
    min_width = 100,
    border = "none",
    highlight_border = false,
  },

  -- Tables — rounded borders, overlay mode
  pipe_table = {
    enabled = true,
    preset = "round",
    style = "full",
    cell = "overlay",
  },

  -- Bullet points
  bullet = {
    enabled = true,
    icons = { "✦", "▪", "◆", "●" },
  },

  -- Checkboxes
  checkbox = {
    enabled = true,
    unchecked = { icon = "□ ", highlight = "RenderMarkdownUnchecked" },
    checked = {
      icon = "✓ ",
      highlight = "RenderMarkdownChecked",
      scope_highlight = "@markup.strikethrough",
    },
    custom = {
      todo = {
        raw = "[-]",
        rendered = "◐ ",
        highlight = "RenderMarkdownTodo",
      },
    },
  },

  quote = { repeat_linebreak = true },
  dash = { width = "full" },

  link = {
    enabled = true,
    hyperlink = "◉ ",
  },

  sign = { enabled = false },

  completions = {
    lsp = { enabled = true },
  },
})

-- Override default RenderMarkdownH* groups with vivid heading colors.
-- Generated colorscheme files set RenderMarkdownH*Bg = { bg = c.surface } (barely visible).
-- vim.schedule() defers to the next event loop tick, guaranteeing we run AFTER all
-- synchronous colorscheme handlers and render-markdown's own ColorScheme autocmd.
local function apply_heading_colors()
  for i = 1, 6 do
    vim.api.nvim_set_hl(0, "RenderMarkdownH" .. i, { fg = heading_fg[i], bold = true })
    vim.api.nvim_set_hl(0, "RenderMarkdownH" .. i .. "Bg", { bg = heading_bg[i] })
  end
end

vim.schedule(apply_heading_colors)

vim.api.nvim_create_autocmd({ "ColorScheme", "FocusGained" }, {
  group = vim.api.nvim_create_augroup("MdHeadingColors", { clear = true }),
  callback = function()
    vim.schedule(apply_heading_colors)
  end,
})

-- Toggle keybinding
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "quarto", "rmd" },
  group = vim.api.nvim_create_augroup("RenderMarkdownKeys", { clear = true }),
  callback = function()
    vim.keymap.set("n", "<leader>lmp", "<Cmd>RenderMarkdown toggle<CR>", {
      buffer = true,
      desc = "Toggle markdown rendering",
    })
  end,
})
