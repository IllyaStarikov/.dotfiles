-- Ligature support configuration for JetBrainsMono Nerd Font
-- JetBrainsMono supports 142 code ligatures

local M = {}

function M.setup()
  -- Terminal Neovim doesn't support ligatures directly
  -- They are rendered by the terminal emulator (Alacritty, iTerm2, etc.)
  
  -- For GUI Neovim (Neovide, VimR, etc.)
  if vim.fn.has("gui_running") == 1 or vim.g.neovide then
    -- Ensure proper font with ligature support
    vim.opt.guifont = "JetBrainsMono Nerd Font:h18"
    
    -- Neovide-specific ligature settings
    if vim.g.neovide then
      vim.g.neovide_ligatures = true
    end
    
    -- MacVim/GVim ligature settings
    if vim.fn.has("gui_macvim") == 1 then
      vim.cmd([[set macligatures]])
    end
  end
  
  -- Ensure proper rendering settings
  vim.opt.conceallevel = 0  -- Don't conceal text (let ligatures show)
  vim.opt.ambiwidth = "single"  -- Proper width calculation
  
  -- JetBrainsMono ligatures include:
  -- Arrows: -> => ==> --> <-- <== <= >= >> << >>> <<<
  -- Comparison: == === != !== <= >= <> /= 
  -- Logic: && || !! ?? ?. ?: 
  -- Comments: // /* */ /** <!-- -->
  -- Math: ++ -- ** // %% 
  -- Functions: => |> <| :: ::: .. ... 
  -- Special: ## ### #### __ ___ ~~ ~~~ ~= ~- -~ =~ !~ 
  -- Brackets: </ /> <> </> 
  -- Assignment: := += -= *= /= %= &= |= ^= <<= >>= >>>= //= **=
  -- Other: www #{ #[ ]# :: ::: !! ?? ?. ?: <| |> <$> <*> <+> \\ \\\ /// 
  
  -- Note: Actual rendering depends on terminal emulator support
  -- Alacritty, iTerm2, Kitty, and WezTerm all support ligatures
  -- Standard Terminal.app does NOT support ligatures
  
  -- For better ligature visibility in certain contexts
  local ligature_filetypes = {
    "javascript", "typescript", "javascriptreact", "typescriptreact",
    "rust", "go", "python", "lua", "haskell", "elm", "fsharp",
    "clojure", "scala", "kotlin", "swift", "c", "cpp", "java"
  }
  
  -- Create autocmd to ensure settings persist
  vim.api.nvim_create_autocmd("FileType", {
    pattern = ligature_filetypes,
    callback = function()
      -- Ensure conceallevel doesn't hide ligatures
      vim.opt_local.conceallevel = 0
    end,
  })
end

-- Auto-setup on load
M.setup()

return M