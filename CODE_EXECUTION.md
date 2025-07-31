# Code Execution in Neovim

## Keymaps

- `<leader>R` - Run current file (capital R to avoid conflict with rename)
- `<F5>` - Alternative run key
- `:RunFile` - Command to run current file

## Supported Languages

- Python: `python3 <file>`
- JavaScript: `node <file>`
- TypeScript: `ts-node <file>`
- Lua: `lua <file>`
- Shell/Bash: `bash <file>`
- C: Compile with gcc and run
- C++: Compile with g++ and run
- Rust: `cargo run`
- Go: `go run <file>`
- Java: Compile with javac and run

## Usage

1. Open a file in Neovim
2. Press `<leader>R` (where leader is usually space)
3. A terminal will open at the bottom showing output
4. Press `i` to interact with the terminal
5. Press `<C-\><C-n>` to exit terminal mode
6. `:q` to close the terminal window

## Testing

Try with the included test file:
```bash
nvim test_run.py
# Press <space>R to run
```