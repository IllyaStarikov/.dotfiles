--
-- markdown-preview.nvim (iamcco) configuration
-- Live browser preview with synced scrolling — full-fidelity HTML rendering
-- (tables, KaTeX math, mermaid, images) that the in-buffer render-markdown
-- overlay cannot reproduce in a terminal.
--
-- The mkdp_* globals must be set BEFORE the plugin loads, so this module is
-- required from the spec's `init` (run at startup), not `config`.
--

local g = vim.g

g.mkdp_auto_start = 0 -- don't pop the browser on entering a markdown buffer
g.mkdp_auto_close = 1 -- close the preview tab when leaving the buffer
g.mkdp_refresh_slow = 0 -- refresh on every change, not only on save/cursor-hold
g.mkdp_command_for_global = 0 -- preview commands stay scoped to markdown filetypes
g.mkdp_open_to_the_world = 0 -- bind the local server to 127.0.0.1 only
g.mkdp_echo_preview_url = 1 -- print the preview URL when it opens
g.mkdp_page_title = "${name}" -- browser tab title = file name
-- mkdp_theme deliberately unset: the plugin then follows the system
-- light/dark appearance, which is what drives the theme switcher too.
g.mkdp_filetypes = { "markdown" }

-- Toggle the browser preview from markdown buffers. Capital P sits alongside
-- <leader>lmp (the in-buffer render-markdown toggle): lowercase = inline render,
-- uppercase = full browser preview.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  group = vim.api.nvim_create_augroup("MarkdownPreviewKeys", { clear = true }),
  callback = function()
    vim.keymap.set("n", "<leader>lmP", "<Cmd>MarkdownPreviewToggle<CR>", {
      buffer = true,
      desc = "Toggle markdown browser preview",
    })
  end,
})
