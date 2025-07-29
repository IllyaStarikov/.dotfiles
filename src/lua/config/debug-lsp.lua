-- Debug script for testing LSP and completion

local M = {}

function M.test_cpp_completion()
  -- Create a test C++ file
  vim.cmd('edit /tmp/test_completion.cpp')
  
  -- Insert some test code
  local lines = {
    '#include <iostream>',
    '#include <vector>',
    '',
    'class MyClass {',
    'public:',
    '    int value;',
    '    void print() { std::cout << value << std::endl; }',
    '};',
    '',
    'int main() {',
    '    MyClass obj;',
    '    obj.  // Type after the dot to test completion',
    '    ',
    '    std::vector<int> vec;',
    '    vec.  // Type after the dot to test STL completion',
    '    ',
    '    return 0;',
    '}'
  }
  
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  
  -- Wait for LSP to attach
  vim.defer_fn(function()
    print("\n=== LSP and Completion Debug Info ===")
    
    -- Check LSP clients
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
    print("Active LSP clients for this buffer: " .. #clients)
    for _, client in ipairs(clients) do
      print("  - " .. client.name)
    end
    
    -- Check blink.cmp
    local blink_ok, blink = pcall(require, "blink.cmp")
    print("\nblink.cmp loaded: " .. tostring(blink_ok))
    
    -- Position cursor after "obj."
    vim.api.nvim_win_set_cursor(0, {12, 8})
    print("\nCursor positioned after 'obj.' - try typing to see if completion appears")
    print("You can also try pressing Ctrl+Space to manually trigger completion")
    
  end, 2000)
end

-- Create a command to run the test
vim.api.nvim_create_user_command('TestCppCompletion', function()
  M.test_cpp_completion()
end, { desc = "Test C++ LSP completion" })

return M