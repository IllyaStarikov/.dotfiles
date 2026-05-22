-- :checkhealth dotfiles
--
-- Neovim discovers this file automatically: any `lua/<name>/health.lua` on
-- the runtimepath becomes a `:checkhealth <name>` provider. With
-- ~/.config/nvim symlinked at $DOTFILES/src/neovim, this lives at
-- $DOTFILES/src/neovim/lua/dotfiles/health.lua and registers as `dotfiles`.

local M = {}

local function check_module(name)
  return pcall(require, name)
end

local function check_command(cmd)
  return vim.fn.executable(cmd) == 1
end

function M.check()
  local health = vim.health

  -- Core dotfiles modules loaded by init.lua --------------------------------
  health.start("dotfiles: core modules")
  local core = {
    "utils",
    "error-handler",
    "core",
    "ui",
    "keymaps",
    "autocmds",
    "plugins",
    "commands",
    "fixy",
  }
  local missing = 0
  for _, m in ipairs(core) do
    if check_module(m) then
      health.ok(m)
    else
      health.error(m .. " failed to load")
      missing = missing + 1
    end
  end
  if missing == 0 then
    health.info(("all %d core modules loaded"):format(#core))
  end

  -- External binaries the config relies on ----------------------------------
  health.start("dotfiles: external tools")
  local required = { "git", "rg", "fd", "fzf" }
  for _, bin in ipairs(required) do
    if check_command(bin) then
      health.ok(bin .. " present")
    else
      health.warn(bin .. " not on PATH")
    end
  end

  local optional = { "lazygit", "delta", "bat", "eza" }
  for _, bin in ipairs(optional) do
    if check_command(bin) then
      health.ok(bin .. " present (optional)")
    else
      health.info(bin .. " missing (optional)")
    end
  end

  -- Paths and env-var contracts --------------------------------------------
  health.start("dotfiles: paths")
  if vim.g.dotfiles and vim.fn.isdirectory(vim.g.dotfiles) == 1 then
    health.ok("vim.g.dotfiles = " .. vim.g.dotfiles)
  else
    health.error("vim.g.dotfiles is not a valid directory")
  end

  local theme_state = vim.fn.expand("~/.config/theme/current-theme.sh")
  if vim.fn.filereadable(theme_state) == 1 then
    health.ok("theme state file present")
  else
    health.warn("theme state file missing: " .. theme_state)
  end

  -- Snippets path (the M1 fix verified) ------------------------------------
  local snippet_dir = vim.fn.stdpath("config") .. "/snippets"
  if vim.fn.isdirectory(snippet_dir) == 1 then
    health.ok("custom snippets dir: " .. snippet_dir)
  else
    health.warn("custom snippets dir missing: " .. snippet_dir)
  end

  -- Lazy.nvim state --------------------------------------------------------
  health.start("dotfiles: plugins")
  local lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok then
    local stats = lazy.stats()
    health.ok(("lazy.nvim loaded %d plugins"):format(stats.loaded or 0))
    if stats.count and stats.loaded and stats.count > stats.loaded then
      health.info(("%d plugins lazy-deferred"):format(stats.count - stats.loaded))
    end
  else
    health.warn("lazy.nvim not loaded yet (run after VeryLazy)")
  end
end

return M
