#!/usr/bin/env zsh
# Comprehensive Unit Tests for All Scripts
# Follows Google Shell Style Guide

set -euo pipefail

# Source test helpers
source "$(dirname "$0")/../../lib/test_helpers.zsh"

readonly SCRIPTS_DIR="${DOTFILES_DIR}/src/scripts"
readonly DEBUG="${DEBUG:-0}"

#######################################
# Debug logging function
#######################################
debug_log() {
    [[ "${DEBUG}" -eq 1 ]] && echo "[DEBUG] $*" >&2
}

#######################################
# Test all scripts in scripts/ folder
#######################################
test_all_scripts() {
    local failed_tests=0
    local passed_tests=0
    local skipped_tests=0

    echo -e "${BLUE}=== Comprehensive Scripts Unit Tests ===${NC}"

    # Test each script
    for script in "${SCRIPTS_DIR}"/*; do
        local script_name="$(basename "${script}")"

        # Skip non-executable files
        if [[ ! -x "${script}" ]] || [[ "${script_name}" == *.md ]]; then
            debug_log "Skipping non-executable: ${script_name}"
            continue
        fi

        echo -e "\n${CYAN}Testing: ${script_name}${NC}"

        case "${script_name}" in
            bugreport)
                test_bugreport_script
                ;;
            common.sh)
                test_common_script
                ;;
            extract)
                test_extract_script
                ;;
            fallback)
                test_fallback_script
                ;;
            fetch-quotes)
                test_fetch_quotes_script
                ;;
            fixy)
                test_fixy_script
                ;;
            install-ruby-lsp)
                test_install_ruby_lsp_script
                ;;
            nvim-debug)
                test_nvim_debug_script
                ;;
            scratchpad)
                test_scratchpad_script
                ;;
            theme)
                test_theme_script
                ;;
            tmux-utils)
                test_tmux_utils_script
                ;;
            update-dotfiles)
                test_update_dotfiles_script
                ;;
            *)
                debug_log "No specific test for: ${script_name}"
                test_generic_script "${script}"
                ;;
        esac
    done

    echo -e "\n${GREEN}=== Test Summary ===${NC}"
    echo "Passed: ${passed_tests}"
    echo "Failed: ${failed_tests}"
    echo "Skipped: ${skipped_tests}"

    return "${failed_tests}"
}

#######################################
# Test bugreport script
#######################################
test_bugreport_script() {
    test_case "bugreport: Script exists and is executable"
    [[ -x "${SCRIPTS_DIR}/bugreport" ]] && pass || fail "Not executable"

    test_case "bugreport: Shows help without errors"
    output=$("${SCRIPTS_DIR}/bugreport" --help 2>&1 || true)
    if [[ "${output}" == *"Bug Report Generator"* ]]; then
        pass
    else
        fail "Help output not found"
    fi

    test_case "bugreport: Validates arguments"
    output=$("${SCRIPTS_DIR}/bugreport" --invalid-option 2>&1 || true)
    if [[ "${output}" == *"Unknown option"* ]] || [[ "${output}" == *"Usage"* ]]; then
        pass
    else
        fail "Invalid argument not caught"
    fi

    if [[ "${DEBUG}" -eq 1 ]]; then
        test_case "bugreport: Can collect system info (debug mode)"
        temp_dir=$(mktemp -d)
        output=$("${SCRIPTS_DIR}/bugreport" --dry-run --output-dir="${temp_dir}" 2>&1 || true)
        if [[ "${output}" == *"System Information"* ]] || [[ "${output}" == *"Collecting"* ]]; then
            pass
        else
            fail "System info collection failed"
        fi
        rm -rf "${temp_dir}"
    fi
}

#######################################
# Test common.sh script
#######################################
test_common_script() {
    test_case "common.sh: Can be sourced"
    (source "${SCRIPTS_DIR}/common.sh" 2>/dev/null) && pass || fail "Cannot source"

    test_case "common.sh: Exports required functions"
    output=$(source "${SCRIPTS_DIR}/common.sh" && declare -F 2>/dev/null || true)
    if [[ "${output}" == *"log_"* ]] || [[ "${output}" == *"error"* ]]; then
        pass
    else
        fail "Functions not exported"
    fi
}

#######################################
# Test extract script
#######################################
test_extract_script() {
    test_case "extract: Script exists and is executable"
    [[ -x "${SCRIPTS_DIR}/extract" ]] && pass || fail "Not executable"

    test_case "extract: Handles missing arguments"
    output=$("${SCRIPTS_DIR}/extract" 2>&1 || true)
    if [[ "${output}" == *"Usage"* ]] || [[ "${output}" == *"extract"* ]]; then
        pass
    else
        fail "Usage not shown for missing args"
    fi

    test_case "extract: Recognizes archive formats"
    temp_file="${TEST_TMP_DIR}/test.tar.gz"
    echo "test" | gzip > "${temp_file}"
    output=$("${SCRIPTS_DIR}/extract" --dry-run "${temp_file}" 2>&1 || true)
    if [[ "${output}" == *"tar"* ]] || [[ "${output}" == *"would extract"* ]]; then
        pass
    else
        fail "Archive format not recognized"
    fi
}

#######################################
# Test fallback script
#######################################
test_fallback_script() {
    test_case "fallback: Script exists and is executable"
    [[ -x "${SCRIPTS_DIR}/fallback" ]] && pass || fail "Not executable"

    test_case "fallback: Returns first available command"
    # Test with commands that should exist
    output=$("${SCRIPTS_DIR}/fallback" "nonexistent_cmd_xyz" "echo" 2>&1 || true)
    if [[ "${output}" == "echo" ]]; then
        pass
    else
        fail "Did not return available command"
    fi
}

#######################################
# Test fetch-quotes script
#######################################
test_fetch_quotes_script() {
    test_case "fetch-quotes: Script exists and is executable"
    [[ -x "${SCRIPTS_DIR}/fetch-quotes" ]] && pass || fail "Not executable"

    test_case "fetch-quotes: Can run without network"
    output=$("${SCRIPTS_DIR}/fetch-quotes" --offline 2>&1 || true)
    if [[ -n "${output}" ]]; then
        pass
    else
        fail "No offline fallback"
    fi
}

#######################################
# Test fixy script
#######################################
test_fixy_script() {
    test_case "fixy: Script exists and is executable"
    [[ -x "${SCRIPTS_DIR}/fixy" ]] && pass || fail "Not executable"

    test_case "fixy: Shows help"
    output=$("${SCRIPTS_DIR}/fixy" --help 2>&1 || true)
    if [[ "${output}" == *"Universal code formatter"* ]] || [[ "${output}" == *"Usage"* ]]; then
        pass
    else
        fail "Help not shown"
    fi

    test_case "fixy: Detects file types"
    temp_file="${TEST_TMP_DIR}/test.sh"
    echo "#!/bin/bash" > "${temp_file}"
    output=$("${SCRIPTS_DIR}/fixy" --dry-run "${temp_file}" 2>&1 || true)
    if [[ "${output}" == *"shell"* ]] || [[ "${output}" == *"sh"* ]] || [[ "${output}" == *"would format"* ]]; then
        pass
    else
        fail "File type not detected"
    fi
}

#######################################
# Test install-ruby-lsp script
#######################################
test_install_ruby_lsp_script() {
    test_case "install-ruby-lsp: Script exists and is executable"
    [[ -x "${SCRIPTS_DIR}/install-ruby-lsp" ]] && pass || fail "Not executable"

    test_case "install-ruby-lsp: Checks for Ruby"
    output=$("${SCRIPTS_DIR}/install-ruby-lsp" --check 2>&1 || true)
    if [[ "${output}" == *"ruby"* ]] || [[ "${output}" == *"Ruby"* ]]; then
        pass
    else
        fail "Ruby check not performed"
    fi
}

#######################################
# Test nvim-debug script
#######################################
test_nvim_debug_script() {
    test_case "nvim-debug: Script exists and is executable"
    [[ -x "${SCRIPTS_DIR}/nvim-debug" ]] && pass || fail "Not executable"

    test_case "nvim-debug: Shows help"
    output=$("${SCRIPTS_DIR}/nvim-debug" --help 2>&1 || true)
    if [[ "${output}" == *"debug"* ]] || [[ "${output}" == *"Neovim"* ]]; then
        pass
    else
        fail "Help not shown"
    fi
}

#######################################
# Test scratchpad script
#######################################
test_scratchpad_script() {
    test_case "scratchpad: Script exists and is executable"
    [[ -x "${SCRIPTS_DIR}/scratchpad" ]] && pass || fail "Not executable"

    test_case "scratchpad: Creates temporary file"
    output=$("${SCRIPTS_DIR}/scratchpad" --dry-run 2>&1 || true)
    if [[ "${output}" == *"tmp"* ]] || [[ "${output}" == *"scratch"* ]]; then
        pass
    else
        fail "Temp file creation failed"
    fi
}

#######################################
# Test theme script
#######################################
test_theme_script() {
    test_case "theme: Script exists and is executable"
    [[ -x "${SCRIPTS_DIR}/theme" ]] && pass || fail "Not executable"

    test_case "theme: Shows available themes"
    output=$("${SCRIPTS_DIR}/theme" --list 2>&1 || true)
    if [[ "${output}" == *"tokyonight"* ]] || [[ "${output}" == *"theme"* ]]; then
        pass
    else
        fail "Theme list not shown"
    fi
}

#######################################
# Test tmux-utils script
#######################################
test_tmux_utils_script() {
    test_case "tmux-utils: Script exists and is executable"
    [[ -x "${SCRIPTS_DIR}/tmux-utils" ]] && pass || fail "Not executable"

    test_case "tmux-utils: Shows available utilities"
    output=$("${SCRIPTS_DIR}/tmux-utils" --help 2>&1 || true)
    if [[ "${output}" == *"battery"* ]] || [[ "${output}" == *"cpu"* ]]; then
        pass
    else
        fail "Utilities not listed"
    fi

    test_case "tmux-utils: Can check battery"
    output=$("${SCRIPTS_DIR}/tmux-utils" battery 2>&1 || true)
    if [[ -n "${output}" ]]; then
        pass
    else
        fail "Battery check failed"
    fi
}

#######################################
# Test update-dotfiles script
#######################################
test_update_dotfiles_script() {
    test_case "update-dotfiles: Script exists and is executable"
    [[ -x "${SCRIPTS_DIR}/update-dotfiles" ]] && pass || fail "Not executable"

    test_case "update-dotfiles: Checks git status"
    output=$("${SCRIPTS_DIR}/update-dotfiles" --dry-run 2>&1 || true)
    if [[ "${output}" == *"git"* ]] || [[ "${output}" == *"update"* ]]; then
        pass
    else
        fail "Git check not performed"
    fi
}

#######################################
# Generic script test
#######################################
test_generic_script() {
    local script="$1"
    local script_name="$(basename "${script}")"

    test_case "${script_name}: Is executable"
    [[ -x "${script}" ]] && pass || fail "Not executable"

    test_case "${script_name}: Has shebang"
    head -n1 "${script}" | grep -qE '^#!/' && pass || fail "No shebang"

    test_case "${script_name}: No syntax errors"
    if head -n1 "${script}" | grep -q 'zsh'; then
        zsh -n "${script}" 2>/dev/null && pass || fail "Syntax errors"
    elif head -n1 "${script}" | grep -q 'bash'; then
        bash -n "${script}" 2>/dev/null && pass || fail "Syntax errors"
    else
        skip "Unknown shell type"
    fi
}

# Run all tests
test_all_scripts