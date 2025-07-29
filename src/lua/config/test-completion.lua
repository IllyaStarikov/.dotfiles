-- Test completion setup
-- Run :TestCompletion to verify C++ completion is working

local M = {}

function M.run_test()
  -- Create test file
  local test_file = "/tmp/completion_test.cpp"
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buf)
  
  -- Set filetype to trigger LSP
  vim.bo[buf].filetype = "cpp"
  
  -- Insert test content
  local content = {
    "#include <vector>",
    "#include <string>",
    "",
    "struct Point {",
    "    int x, y;",
    "    void move(int dx, int dy) { x += dx; y += dy; }",
    "};",
    "",
    "int main() {",
    "    Point p;",
    "    p.  // <-- Completion should trigger here",
    "    ",
    "    std::vector<int> v;",
    "    v.  // <-- STL completion should work here",
    "    ",
    "    return 0;",
    "}"
  }
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
  vim.api.nvim_buf_set_name(buf, test_file)
  
  print("Test file created. Checking completion setup...")
  
  -- Wait for LSP to attach
  vim.defer_fn(function()
    local clients = vim.lsp.get_active_clients({ bufnr = buf })
    if #clients == 0 then
      print("ERROR: No LSP clients attached!")
      print("Make sure clangd is installed: brew install llvm")
      return
    end
    
    print("LSP clients attached: " .. #clients)
    for _, client in ipairs(clients) do
      print("  - " .. client.name)
      if client.server_capabilities.completionProvider then
        print("    ✓ Completion enabled")
        local triggers = client.server_capabilities.completionProvider.triggerCharacters
        if triggers then
          print("    Triggers: " .. table.concat(triggers, ", "))
        end
      end
    end
    
    -- Position cursor after "p."
    vim.api.nvim_win_set_cursor(0, {11, 6})
    
    print("\nInstructions:")
    print("1. The cursor is now after 'p.'")
    print("2. Type a letter (like 'm' for 'move') to see if completion appears")
    print("3. Or press Ctrl+Space to manually trigger completion")
    print("4. You should see 'x', 'y', and 'move' as completion options")
    
  end, 1000)
end

vim.api.nvim_create_user_command('TestCompletion', M.run_test, {
  desc = "Test C++ LSP completion"
})

return M