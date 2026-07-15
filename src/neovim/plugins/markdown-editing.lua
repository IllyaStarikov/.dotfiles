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

  -- Keymap choices (all buffer-local, so global plugins keep working):
  --  * delete/change emphasis live under the gs prefix (gsd/gsr) — the plugin
  --    defaults ds/cs would shadow mini.surround exactly where prose editing
  --    happens most (ds"/cs"' silently broke in markdown buffers).
  --  * link_add moved off gl, which the LSP owns (diagnostics float).
  --  * heading motions disabled: the runtime ftplugin already provides ]]/[[
  --    section motions, and ]c/]p belong to gitsigns hunk-nav/builtin paste.
  mappings = {
    inline_surround_toggle = "gs",
    inline_surround_toggle_line = "gss",
    inline_surround_delete = "gsd",
    inline_surround_change = "gsr",
    link_add = "<leader>lml",
    link_follow = "gx",
    go_curr_heading = false,
    go_parent_heading = false,
    go_next_heading = false,
    go_prev_heading = false,
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
