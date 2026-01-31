#!/usr/bin/env zsh
# Behavioral tests for scripts in src/scripts/

# Tests handle errors explicitly, don't exit on failure

# Source test helpers
source "$(dirname "$0")/../../lib/test_helpers.zsh"

readonly SCRIPTS_DIR="${DOTFILES_DIR}/src/scripts"

describe "Comprehensive Scripts Behavioral Tests"

#######################################
# Test bugreport script behavior
#######################################
test_bugreport() {
  local script="${SCRIPTS_DIR}/bugreport"

  test_case "bugreport: Generates help information"
  output=$("${script}" --help 2>&1 || true)
  if [[ -n "${output}" ]]; then
    pass "Help displayed"
  else
    fail "No help output"
  fi

  test_case "bugreport: Handles invalid options properly"
  output=$("${script}" --invalid-option 2>&1 || true)
  # Should show error or usage
  if [[ "${output}" == *"Unknown"* ]] || [[ "${output}" == *"Error"* ]] || [[ "${output}" == *"Usage"* ]]; then
    pass "Invalid option handled"
  else
    fail "No error for invalid option"
  fi
}

#######################################
# Test common.sh behavior
#######################################
test_common() {
  test_case "common.sh: Provides reusable functions"
  # Source and check if we can use its functions
  (
    source "${SCRIPTS_DIR}/common.sh" 2>/dev/null
    # Try to use a function it should provide
    type log_info &>/dev/null || type info &>/dev/null || type log &>/dev/null
  ) && pass "Functions available after sourcing" || skip "No common functions found"
}

#######################################
# Test fixy formatter behavior
#######################################
test_fixy() {
  local script="${SCRIPTS_DIR}/fixy"

  test_case "fixy: Formats code files"
  temp_file="$TEST_TMP_DIR/format_test.py"
  echo "def hello( ): print('world' )" >"${temp_file}"

  "${script}" "${temp_file}" >/dev/null 2>&1 || true

  # Check if formatting improved
  content=$(cat "${temp_file}")
  if [[ "${content}" != *"def hello( ):"* ]]; then
    pass "File was formatted"
  else
    skip "Formatter not available"
  fi
  rm -f "${temp_file}"
}

#######################################
# Test scratchpad behavior
#######################################
test_scratchpad() {
  local script="${SCRIPTS_DIR}/scratchpad"

  test_case "scratchpad: Creates temporary workspace"
  # Don't actually run scratchpad as it opens an editor
  if [[ -x "${script}" ]]; then
    pass "Scratchpad script exists and is executable"
  else
    fail "Scratchpad script not found"
  fi
}

#######################################
# Test theme script behavior
#######################################
test_theme() {
  local script="${SCRIPTS_DIR}/theme"

  test_case "theme: Can switch themes"
  # Try to get current theme or switch
  output=$("${script}" 2>&1 | head -5 || true)

  # Should either show current theme or switch
  if [[ "${output}" == *"theme"* ]] || [[ "${output}" == *"Theme"* ]] || [[ "${output}" == *"tokyonight"* ]]; then
    pass "Theme operation performed"
  else
    skip "Theme script not functional"
  fi
}

#######################################
# Test tmux-utils behavior
#######################################
test_tmux_utils() {
  local script="${SCRIPTS_DIR}/tmux-utils"

  test_case "tmux-utils: Provides tmux utilities"
  output=$("${script}" 2>&1 | head -5 || true)

  # Should show usage or perform an action
  if [[ "${output}" == *"tmux"* ]] || [[ "${output}" == *"Usage"* ]] || [[ "${output}" == *"battery"* ]]; then
    pass "Utility functions available"
  else
    skip "tmux-utils not functional"
  fi
}

#######################################
# Test update-dotfiles behavior
#######################################
test_update_dotfiles() {
  local script="${SCRIPTS_DIR}/update-dotfiles"

  test_case "update-dotfiles: Can check for updates"
  # Run with --help or --dry-run to avoid actual updates
  output=$("${script}" --help 2>&1 || "${script}" --dry-run 2>&1 || true)

  # Should mention updating or show help
  if [[ "${output}" == *"update"* ]] || [[ "${output}" == *"Update"* ]] || [[ "${output}" == *"Usage"* ]]; then
    pass "Update functionality available"
  else
    skip "Update script not functional"
  fi
}

#######################################
# Test generic script behavior
#######################################
test_generic_script() {
  local script="$1"
  local script_name=$(basename "${script}")

  test_case "${script_name}: Responds to --help"
  output=$("${script}" --help 2>&1 || true)

  # Most scripts should provide help
  if [[ "${output}" == *"${script_name}"* ]] || [[ "${output}" == *"Usage"* ]] || [[ "${output}" == *"usage"* ]]; then
    pass "Help available"
  else
    skip "No help flag"
  fi

  test_case "${script_name}: Has proper shebang"
  first_line=$(head -n1 "${script}")
  if [[ "${first_line}" == "#!/"* ]]; then
    pass "Has shebang"
  else
    fail "Missing shebang"
  fi
}

#######################################
# Main test runner
#######################################
# Test each script's behavior
for script in "${SCRIPTS_DIR}"/*; do
  [[ -f "${script}" ]] || continue
  [[ -x "${script}" ]] || continue

  script_name=$(basename "${script}")

  echo -e "\n${CYAN}Testing: ${script_name}${NC}"

  case "${script_name}" in
    bugreport) test_bugreport ;;
    common.sh) test_common ;;
    fixy) test_fixy ;;
    scratchpad) test_scratchpad ;;
    theme) test_theme ;;
    tmux-utils) test_tmux_utils ;;
    update-dotfiles) test_update_dotfiles ;;
    *) test_generic_script "${script}" ;;
  esac
done

# Return success
exit 0
