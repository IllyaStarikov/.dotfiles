#!/usr/bin/env zsh
# Unit tests for Cortex AI assistant configuration

# Get the test directory path
TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

# Test framework
source "${TEST_DIR}/lib/test_helpers.zsh"

# Test Cortex module structure
test_cortex_structure() {
  local cortex_dir="${DOTFILES_DIR}/src/cortex"

  assert_directory_exists "$cortex_dir" "Cortex directory should exist"
  assert_file_exists "$cortex_dir/setup.py" "Setup.py should exist"
  assert_directory_exists "$cortex_dir/cortex" "Cortex package directory should exist"
}

# Test Cortex Python package files
test_cortex_package_files() {
  local package_dir="${DOTFILES_DIR}/src/cortex/cortex"

  assert_file_exists "$package_dir/__init__.py" "Package __init__.py should exist"
  assert_file_exists "$package_dir/cli.py" "CLI module should exist"
  assert_file_exists "$package_dir/config.py" "Config module should exist"
  assert_file_exists "$package_dir/providers.py" "Providers module should exist"
}

# Test Cortex wrapper script
test_cortex_wrapper_script() {
  local wrapper="${DOTFILES_DIR}/src/scripts/cortex"

  assert_file_exists "$wrapper" "Cortex wrapper script should exist"
  assert_file_executable "$wrapper" "Cortex wrapper should be executable"

  # Check wrapper references the Python module
  assert_file_contains "$wrapper" "python.*cortex" "Wrapper should invoke Python module"
}

# Test Cortex Python syntax
test_cortex_python_syntax() {
  local package_dir="${DOTFILES_DIR}/src/cortex/cortex"

  # Check Python syntax for all .py files
  for py_file in "$package_dir"/*.py; do
    if [[ -f "$py_file" ]]; then
      if ! python3 -m py_compile "$py_file" 2>/dev/null; then
        fail "Python syntax error in $(basename "$py_file")"
      fi
    fi
  done
}

# Test Cortex configuration defaults
test_cortex_config_defaults() {
  local config_file="${DOTFILES_DIR}/src/cortex/cortex/config.py"

  assert_file_exists "$config_file" "Config module should exist"

  # Check for configuration class/constants
  assert_file_contains "$config_file" "class.*Config\|CONFIG\|DEFAULT" "Should define configuration"
}

# Test Cortex documentation
test_cortex_readme() {
  local readme="${DOTFILES_DIR}/src/cortex/README.md"

  assert_file_exists "$readme" "Cortex README should exist"
  assert_file_contains "$readme" "Cortex" "README should document Cortex"
  assert_file_contains "$readme" "Installation\|Setup\|Usage" "README should have usage instructions"
}

# Test Cortex requirements file
test_cortex_requirements() {
  local requirements="${DOTFILES_DIR}/src/cortex/requirements.txt"

  # Requirements file should exist
  if [[ -f "$requirements" ]]; then
    # Check it's not empty
    if [[ ! -s "$requirements" ]]; then
      fail "Requirements file exists but is empty"
    fi
  fi
  # Note: It's OK if requirements.txt doesn't exist if deps are in setup.py
}

# Run all tests
test_suite "Cortex AI Assistant" \
  test_cortex_structure \
  test_cortex_package_files \
  test_cortex_wrapper_script \
  test_cortex_python_syntax \
  test_cortex_config_defaults \
  test_cortex_readme \
  test_cortex_requirements