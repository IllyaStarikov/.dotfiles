#!/usr/bin/env zsh
# Integration Tests: All Scripts Functionality
# TEST_SIZE: medium
# Tests that all scripts in src/scripts/ work correctly

source "${TEST_DIR}/lib/framework.zsh"

# Test each script in src/scripts/
test_all_scripts_executable() {
    log "TRACE" "Testing all scripts are executable"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking scripts in: $DOTFILES_DIR/src/scripts/"
    
    local non_executable=()
    local total_scripts=0
    
    for script in "$DOTFILES_DIR"/src/scripts/*; do
        [[ -f "$script" ]] || continue
        
        # Skip non-script files
        local basename=$(basename "$script")
        [[ "$basename" == *.md ]] && continue
        [[ "$basename" == *.txt ]] && continue
        [[ "$basename" == *.json ]] && continue
        [[ "$basename" == .formatrc ]] && continue
        [[ "$basename" == README* ]] && continue
        
        ((total_scripts++))
        
        if [[ ! -x "$script" ]]; then
            non_executable+=("$basename")
            log "ERROR" "Not executable: $basename"
        else
            [[ $VERBOSE -ge 2 ]] && log "DEBUG" "✓ Executable: $basename"
        fi
    done
    
    [[ $VERBOSE -ge 1 ]] && log "INFO" "Checked $total_scripts scripts, ${#non_executable[@]} not executable"
    
    [[ ${#non_executable[@]} -eq 0 ]] || return 1
    return 0
}

# Test fixy script
test_fixy_script() {
    log "TRACE" "Testing fixy formatter script"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Testing: $DOTFILES_DIR/src/scripts/fixy"
    
    local fixy="$DOTFILES_DIR/src/scripts/fixy"
    
    if [[ ! -x "$fixy" ]]; then
        log "ERROR" "fixy script not found or not executable"
        return 1
    fi
    
    # Test help output
    local help_output=$("$fixy" --help 2>&1)
    if [[ $? -ne 0 ]]; then
        log "ERROR" "fixy --help failed"
        [[ $VERBOSE -ge 1 ]] && echo "$help_output" | head -5 | while read -r line; do
            log "DEBUG" "  $line"
        done
        return 1
    fi
    
    # Test with a sample file
    local test_file=$(mktemp -t fixy_test.sh)
    cat > "$test_file" <<'EOF'
#!/bin/bash
echo "test"
	echo "tabs"
echo "test"   
EOF
    
    # Test dry-run
    local dry_output=$("$fixy" --dry-run "$test_file" 2>&1)
    local exit_code=$?
    
    rm -f "$test_file"
    
    if [[ $exit_code -ne 0 ]]; then
        log "WARNING" "fixy dry-run returned non-zero: $exit_code"
        [[ $VERBOSE -ge 1 ]] && echo "$dry_output" | head -10 | while read -r line; do
            log "DEBUG" "  $line"
        done
    else
        [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "fixy script works correctly"
    fi
    
    return 0
}

# Test update-dotfiles script
test_update_dotfiles_script() {
    log "TRACE" "Testing update-dotfiles script"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Testing: $DOTFILES_DIR/src/scripts/update-dotfiles"
    
    local update_script="$DOTFILES_DIR/src/scripts/update-dotfiles"
    
    if [[ ! -x "$update_script" ]]; then
        log "ERROR" "update-dotfiles script not found or not executable"
        return 1
    fi
    
    # Test help output
    local help_output=$("$update_script" --help 2>&1)
    if [[ $? -ne 0 ]]; then
        log "ERROR" "update-dotfiles --help failed"
        return 1
    fi
    
    if [[ "$help_output" == *"update"* ]] || [[ "$help_output" == *"Update"* ]]; then
        [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "update-dotfiles help works"
    else
        log "WARNING" "update-dotfiles help output unexpected"
    fi
    
    return 0
}

# Test theme script
test_theme_script() {
    log "TRACE" "Testing theme switcher wrapper script"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Testing: $DOTFILES_DIR/src/scripts/theme"
    
    local theme_script="$DOTFILES_DIR/src/scripts/theme"
    
    if [[ ! -x "$theme_script" ]]; then
        log "WARNING" "theme script not found or not executable"
        return 0  # Not critical
    fi
    
    # Check if it's a wrapper for the actual theme switcher
    if grep -q "switch-theme" "$theme_script" 2>/dev/null; then
        [[ $VERBOSE -ge 1 ]] && log "DEBUG" "theme script wraps switch-theme.sh"
    fi
    
    return 0
}

# Test scratchpad script
test_scratchpad_script() {
    log "TRACE" "Testing scratchpad script"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Testing: $DOTFILES_DIR/src/scripts/scratchpad"
    
    local scratchpad="$DOTFILES_DIR/src/scripts/scratchpad"
    
    if [[ ! -x "$scratchpad" ]]; then
        log "WARNING" "scratchpad script not found"
        return 0  # Not critical
    fi
    
    # Check what it does
    if grep -q "mktemp\|tempfile\|/tmp" "$scratchpad" 2>/dev/null; then
        [[ $VERBOSE -ge 1 ]] && log "DEBUG" "scratchpad creates temporary files"
    fi
    
    return 0
}

# Test fetch-quotes script
test_fetch_quotes_script() {
    log "TRACE" "Testing fetch-quotes script"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Testing: $DOTFILES_DIR/src/scripts/fetch-quotes"
    
    local fetch_quotes="$DOTFILES_DIR/src/scripts/fetch-quotes"
    
    if [[ ! -x "$fetch_quotes" ]]; then
        log "INFO" "fetch-quotes script not found (optional)"
        return 0
    fi
    
    # Check if it makes network requests
    if grep -q "curl\|wget\|fetch" "$fetch_quotes" 2>/dev/null; then
        [[ $VERBOSE -ge 1 ]] && log "DEBUG" "fetch-quotes makes network requests"
        log "INFO" "Skipping fetch-quotes network test"
    fi
    
    return 0
}

# Test tmux-utils script
test_tmux_utils_script() {
    log "TRACE" "Testing tmux-utils script"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Testing: $DOTFILES_DIR/src/scripts/tmux-utils"
    
    local tmux_utils="$DOTFILES_DIR/src/scripts/tmux-utils"
    
    if [[ ! -x "$tmux_utils" ]]; then
        log "INFO" "tmux-utils script not found (optional)"
        return 0
    fi
    
    # Test help or subcommands
    local output=$("$tmux_utils" 2>&1 || true)
    
    if [[ "$output" == *"battery"* ]] || [[ "$output" == *"cpu"* ]]; then
        [[ $VERBOSE -ge 1 ]] && log "DEBUG" "tmux-utils has subcommands"
        
        # Test battery subcommand
        if command -v pmset >/dev/null 2>&1; then
            local battery_output=$("$tmux_utils" battery 2>&1 || true)
            [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Battery output: ${battery_output:0:50}"
        fi
    fi
    
    return 0
}

# Test common.sh library
test_common_library() {
    log "TRACE" "Testing common.sh library"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Testing: $DOTFILES_DIR/src/scripts/common.sh"
    
    local common="$DOTFILES_DIR/src/scripts/common.sh"
    
    if [[ ! -f "$common" ]]; then
        log "INFO" "common.sh library not found (optional)"
        return 0
    fi
    
    # Check if it's sourceable
    if zsh -c "source '$common' 2>/dev/null && exit 0" 2>/dev/null; then
        [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "common.sh is sourceable"
        
        # Check what functions it provides
        local functions=$(grep "^function\|^[a-z_]*(" "$common" 2>/dev/null | wc -l)
        [[ $VERBOSE -ge 1 ]] && log "DEBUG" "common.sh provides $functions functions"
    else
        log "WARNING" "common.sh has issues when sourced"
    fi
    
    return 0
}

# Test extract script
test_extract_script() {
    log "TRACE" "Testing extract archive script"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Testing: $DOTFILES_DIR/src/scripts/extract"
    
    local extract="$DOTFILES_DIR/src/scripts/extract"
    
    if [[ ! -x "$extract" ]]; then
        log "INFO" "extract script not found (optional)"
        return 0
    fi
    
    # Check supported formats
    local formats=(tar zip gz bz2 xz 7z rar)
    local supported=0
    
    for format in "${formats[@]}"; do
        if grep -q "$format" "$extract" 2>/dev/null; then
            ((supported++))
            [[ $VERBOSE -ge 2 ]] && log "DEBUG" "  Supports: $format"
        fi
    done
    
    [[ $VERBOSE -ge 1 ]] && log "INFO" "extract supports $supported archive formats"
    
    return 0
}

# Test all scripts for syntax errors
test_all_scripts_syntax() {
    log "TRACE" "Testing syntax of all shell scripts"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Running syntax checks on all scripts"
    
    local errors=0
    local checked=0
    
    for script in "$DOTFILES_DIR"/src/scripts/*; do
        [[ -f "$script" ]] || continue
        
        local basename=$(basename "$script")
        
        # Skip non-shell files
        [[ "$basename" == *.md ]] && continue
        [[ "$basename" == *.txt ]] && continue
        [[ "$basename" == *.json ]] && continue
        [[ "$basename" == .formatrc ]] && continue
        
        ((checked++))
        
        # Determine shell type from shebang
        local first_line=$(head -1 "$script" 2>/dev/null)
        
        if [[ "$first_line" == "#!/usr/bin/env zsh"* ]] || [[ "$first_line" == "#!/bin/zsh"* ]]; then
            if ! zsh -n "$script" 2>/dev/null; then
                log "ERROR" "Zsh syntax error in: $basename"
                [[ $VERBOSE -ge 1 ]] && zsh -n "$script" 2>&1 | head -3 | while read -r line; do
                    log "DEBUG" "  $line"
                done
                ((errors++))
            else
                [[ $VERBOSE -ge 2 ]] && log "DEBUG" "✓ Valid Zsh: $basename"
            fi
        elif [[ "$first_line" == "#!/usr/bin/env bash"* ]] || [[ "$first_line" == "#!/bin/bash"* ]]; then
            if ! bash -n "$script" 2>/dev/null; then
                log "ERROR" "Bash syntax error in: $basename"
                ((errors++))
            else
                [[ $VERBOSE -ge 2 ]] && log "DEBUG" "✓ Valid Bash: $basename"
            fi
        elif [[ "$first_line" == "#!/bin/sh"* ]]; then
            if ! sh -n "$script" 2>/dev/null; then
                log "ERROR" "Shell syntax error in: $basename"
                ((errors++))
            else
                [[ $VERBOSE -ge 2 ]] && log "DEBUG" "✓ Valid Shell: $basename"
            fi
        fi
    done
    
    [[ $VERBOSE -ge 1 ]] && log "INFO" "Syntax checked $checked scripts, $errors errors"
    
    [[ $errors -eq 0 ]] || return 1
    return 0
}

# Test script dependencies
test_scripts_dependencies() {
    log "TRACE" "Testing script dependencies"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking if scripts have required dependencies"
    
    # Common dependencies scripts might need
    local common_deps=(git curl jq yq fd rg fzf)
    
    for script in "$DOTFILES_DIR"/src/scripts/*; do
        [[ -f "$script" ]] || continue
        
        local basename=$(basename "$script")
        [[ "$basename" == *.md ]] && continue
        [[ "$basename" == *.json ]] && continue
        
        # Check what commands the script uses
        for dep in "${common_deps[@]}"; do
            if grep -q "\\<$dep\\>" "$script" 2>/dev/null; then
                if command -v "$dep" >/dev/null 2>&1; then
                    [[ $VERBOSE -ge 2 ]] && log "DEBUG" "$basename uses $dep (✓ installed)"
                else
                    log "WARNING" "$basename requires $dep (not installed)"
                fi
            fi
        done
    done
    
    return 0
}

# Test script error handling
test_scripts_error_handling() {
    log "TRACE" "Testing error handling in scripts"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking for proper error handling"
    
    local missing_error_handling=()
    
    for script in "$DOTFILES_DIR"/src/scripts/*; do
        [[ -f "$script" ]] || continue
        
        local basename=$(basename "$script")
        [[ "$basename" == *.md ]] && continue
        [[ "$basename" == *.json ]] && continue
        [[ "$basename" == .formatrc ]] && continue
        
        # Check for error handling patterns
        if ! grep -q "set -e\|set -o errexit\|\|\| exit\|\|\| return\|trap" "$script" 2>/dev/null; then
            missing_error_handling+=("$basename")
            [[ $VERBOSE -ge 2 ]] && log "WARNING" "$basename lacks explicit error handling"
        fi
    done
    
    if [[ ${#missing_error_handling[@]} -gt 0 ]]; then
        [[ $VERBOSE -ge 1 ]] && log "WARNING" "${#missing_error_handling[@]} scripts lack error handling"
    else
        [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "All scripts have error handling"
    fi
    
    return 0
}

# Test help/usage in scripts
test_scripts_help_output() {
    log "TRACE" "Testing help output in scripts"
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking if scripts provide help/usage"
    
    local scripts_with_help=0
    local scripts_without_help=0
    
    for script in "$DOTFILES_DIR"/src/scripts/*; do
        [[ -f "$script" ]] || continue
        [[ ! -x "$script" ]] && continue
        
        local basename=$(basename "$script")
        [[ "$basename" == *.md ]] && continue
        [[ "$basename" == common.sh ]] && continue
        
        # Check if script has help/usage
        if grep -q "usage\|help\|--help\|-h" "$script" 2>/dev/null; then
            ((scripts_with_help++))
            [[ $VERBOSE -ge 2 ]] && log "DEBUG" "$basename has help/usage"
        else
            ((scripts_without_help++))
            [[ $VERBOSE -ge 2 ]] && log "DEBUG" "$basename lacks help/usage"
        fi
    done
    
    [[ $VERBOSE -ge 1 ]] && log "INFO" "$scripts_with_help scripts have help, $scripts_without_help don't"
    
    return 0
}