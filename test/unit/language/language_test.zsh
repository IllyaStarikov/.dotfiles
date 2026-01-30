#!/usr/bin/env zsh
# Unit tests for language-specific configurations

# Get the test directory path
TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

# Test framework
source "${TEST_DIR}/lib/test_helpers.zsh"

# Test Python configuration (ruff.toml)
test_python_ruff_config() {
  local ruff_conf="${DOTFILES_DIR}/src/language/ruff.toml"

  assert_file_exists "$ruff_conf" "Ruff configuration should exist"

  # Check for essential Python settings
  assert_file_contains "$ruff_conf" "line-length" "Line length should be configured"
  assert_file_contains "$ruff_conf" "target-version" "Target Python version should be set"

  # Verify line length follows style guide (100 chars)
  assert_file_contains "$ruff_conf" "line-length = 100" "Line length should be 100 (style guide)"
}

# Test Lua configuration (stylua.toml)
test_lua_stylua_config() {
  local stylua_conf="${DOTFILES_DIR}/src/language/stylua.toml"

  assert_file_exists "$stylua_conf" "Stylua configuration should exist"

  # Check for Lua formatting settings
  assert_file_contains "$stylua_conf" "column_width" "Column width should be configured"
  assert_file_contains "$stylua_conf" "indent_type" "Indentation should be configured"

  # Verify column width is 100 (consistent with other languages)
  assert_file_contains "$stylua_conf" "column_width = 100" "Column width should be 100"
}

# Test C/C++ configuration (clangd_config.yaml)
test_cpp_clangd_config() {
  local clangd_conf="${DOTFILES_DIR}/src/language/clangd_config.yaml"

  assert_file_exists "$clangd_conf" "Clangd configuration should exist"

  # Check for C++ settings
  assert_file_contains "$clangd_conf" "CompileFlags" "Compile flags should be configured"
}

# Test LaTeX configuration (latexmkrc)
test_latex_config() {
  local latex_conf="${DOTFILES_DIR}/src/language/latexmkrc"

  assert_file_exists "$latex_conf" "LaTeX configuration should exist"

  # Check for PDF output configuration
  assert_file_contains "$latex_conf" "pdf_mode" "PDF compilation should be configured"
}

# Test Markdown configuration (markdownlint.json)
test_markdown_config() {
  local md_conf="${DOTFILES_DIR}/src/language/markdownlint.json"

  assert_file_exists "$md_conf" "Markdown lint configuration should exist"

  # Should be valid JSON
  if ! python3 -m json.tool < "$md_conf" >/dev/null 2>&1; then
    fail "markdownlint.json is not valid JSON"
  fi
}

# Test Python project configuration (pyproject.toml)
test_pyproject_config() {
  local pyproject="${DOTFILES_DIR}/src/language/pyproject.toml"

  assert_file_exists "$pyproject" "Python project configuration should exist"

  # Check for tool configurations
  assert_file_contains "$pyproject" "\[tool\." "Tool configurations should be present"
}

# Test that all configs have documentation
test_language_readme() {
  local readme="${DOTFILES_DIR}/src/language/README.md"

  assert_file_exists "$readme" "Language configs README should exist"

  # Check that each language is documented
  assert_file_contains "$readme" "Python" "Python configuration should be documented"
  assert_file_contains "$readme" "Lua" "Lua configuration should be documented"
  assert_file_contains "$readme" "C/C++" "C/C++ configuration should be documented"
}

# Run all tests
test_suite "Language Configurations" \
  test_python_ruff_config \
  test_lua_stylua_config \
  test_cpp_clangd_config \
  test_latex_config \
  test_markdown_config \
  test_pyproject_config \
  test_language_readme