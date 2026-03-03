--
-- markdown.nvim (tadmccorkle) configuration
-- Editing conveniences: list continuation, checkbox toggle, TOC, navigation
--

require("markdown").setup({
  -- Inline style toggling (gs + key)
  -- gsb = bold, gsi = italic, gsc = code, gss = strikethrough
  inline_surround = {
    emphasis = { key = "i", txt = "*" },
    strong = { key = "b", txt = "**" },
    strikethrough = { key = "s", txt = "~~" },
    code = { key = "c", txt = "`" },
  },

  -- Heading navigation: ]] / [[ are set by default
  mappings = {
    inline_surround_toggle = "gs",
    inline_surround_toggle_line = "gss",
    inline_surround_delete = "ds",
    inline_surround_change = "cs",
    link_add = "gl",
    link_follow = "gx",
    go_curr_heading = "]c",
    go_parent_heading = "]p",
    go_next_heading = "]]",
    go_prev_heading = "[[",
  },

  -- Auto-convert pasted URLs to markdown links
  link = {
    paste = { enable = true },
  },

  -- TOC generation
  toc = {
    markers = { "-" },
  },

  -- Buffer-local keymaps for commands that need explicit bindings
  on_attach = function(bufnr)
    local opts = { buffer = bufnr }

    vim.keymap.set(
      { "n", "x" },
      "<leader>lmx",
      "<Cmd>MDTaskToggle<CR>",
      vim.tbl_extend("force", opts, {
        desc = "Toggle checkbox",
      })
    )

    vim.keymap.set(
      "n",
      "<leader>lmt",
      "<Cmd>MDInsertToc<CR>",
      vim.tbl_extend("force", opts, {
        desc = "Insert TOC",
      })
    )

    vim.keymap.set(
      "n",
      "<leader>lmn",
      "<Cmd>MDListItemBelow<CR>",
      vim.tbl_extend("force", opts, {
        desc = "New list item below",
      })
    )

    vim.keymap.set(
      "n",
      "<leader>lmN",
      "<Cmd>MDListItemAbove<CR>",
      vim.tbl_extend("force", opts, {
        desc = "New list item above",
      })
    )
  end,
})
