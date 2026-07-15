--
-- render-markdown.nvim configuration
-- Clean markdown rendering with anti-conceal (raw markdown on cursor line)
--
-- Heading colors (RenderMarkdownH1-6 / RenderMarkdownH1-6Bg) are owned by the
-- generated colorschemes (src/theme/templates/neovim.lua), which blend each
-- palette's accents over its background — correct in light and dark themes.
--

require("render-markdown").setup({
  file_types = { "markdown", "quarto", "rmd" },
  -- "i" keeps the buffer rendered while typing; anti_conceal below reveals
  -- raw markdown on the cursor line only.
  render_modes = { "n", "c", "i", "v", "V" },
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

  -- No latex2text/utftex on this machine; browser preview (<leader>lmP)
  -- renders math via KaTeX instead. Disabling silences checkhealth.
  latex = { enabled = false },

  link = {
    enabled = true,
    hyperlink = "◉ ",
  },

  sign = { enabled = false },

  completions = {
    lsp = { enabled = true },
  },
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
