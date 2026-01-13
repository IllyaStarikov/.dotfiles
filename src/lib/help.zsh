#!/usr/bin/env zsh

# help.zsh - Help text generation and man page utilities
# Provides functions for generating help text, usage information, and documentation

# Configuration
typeset -g HELP_WIDTH=${HELP_WIDTH:-80}
typeset -g HELP_INDENT=${HELP_INDENT:-2}
typeset -g HELP_COLOR=${HELP_COLOR:-1}
typeset -g HELP_PAGER=${HELP_PAGER:-${PAGER:-less}}

# Source dependencies if available
[[ -f "${0:A:h}/colors.zsh" ]] && source "${0:A:h}/colors.zsh"
[[ -f "${0:A:h}/textwrap.zsh" ]] && source "${0:A:h}/textwrap.zsh"

# Help text builder
typeset -g HELP_PROGRAM_NAME=""
typeset -g HELP_PROGRAM_VERSION=""
typeset -g HELP_PROGRAM_DESCRIPTION=""
typeset -g HELP_PROGRAM_AUTHOR=""
typeset -g HELP_PROGRAM_LICENSE=""
typeset -ga HELP_SECTIONS=()
typeset -gA HELP_SECTION_CONTENT=()

# Set program information
help_program() {
    HELP_PROGRAM_NAME="$1"
    HELP_PROGRAM_VERSION="${2:-1.0.0}"
    HELP_PROGRAM_DESCRIPTION="${3:-}"
    HELP_PROGRAM_AUTHOR="${4:-}"
    HELP_PROGRAM_LICENSE="${5:-}"
}

# Add help section
help_section() {
    local name="$1"
    local content="$2"

    HELP_SECTIONS+=("$name")
    HELP_SECTION_CONTENT[$name]="$content"
}

# Add usage section
help_usage() {
    local usage="$1"
    help_section "USAGE" "$usage"
}

# Add synopsis section
help_synopsis() {
    local synopsis="$1"
    help_section "SYNOPSIS" "$synopsis"
}

# Add description section
help_description() {
    local description="$1"
    help_section "DESCRIPTION" "$description"
}

# Add options section
help_options() {
    local options="$1"
    help_section "OPTIONS" "$options"
}

# Add examples section
help_examples() {
    local examples="$1"
    help_section "EXAMPLES" "$examples"
}

# Add environment section
help_environment() {
    local environment="$1"
    help_section "ENVIRONMENT" "$environment"
}

# Add files section
help_files() {
    local files="$1"
    help_section "FILES" "$files"
}

# Add see also section
help_see_also() {
    local see_also="$1"
    help_section "SEE ALSO" "$see_also"
}

# Add bugs section
help_bugs() {
    local bugs="$1"
    help_section "BUGS" "$bugs"
}

# Add author section
help_author() {
    local author="$1"
    help_section "AUTHOR" "$author"
}

# Generate help text
help_generate() {
    local output=""

    # Header
    if [[ -n "$HELP_PROGRAM_NAME" ]]; then
        if [[ $HELP_COLOR -eq 1 ]] && [[ -n "${COLORS[BOLD]}" ]]; then
            output+="${COLORS[BOLD]}${HELP_PROGRAM_NAME}${COLORS[RESET]}"
        else
            output+="$HELP_PROGRAM_NAME"
        fi

        if [[ -n "$HELP_PROGRAM_VERSION" ]]; then
            output+=" version $HELP_PROGRAM_VERSION"
        fi
        output+="\n"

        if [[ -n "$HELP_PROGRAM_DESCRIPTION" ]]; then
            output+="$HELP_PROGRAM_DESCRIPTION\n"
        fi
        output+="\n"
    fi

    # Sections
    for section in "${HELP_SECTIONS[@]}"; do
        # Section header
        if [[ $HELP_COLOR -eq 1 ]] && [[ -n "${COLORS[YELLOW]}" ]]; then
            output+="${COLORS[YELLOW]}${section}${COLORS[RESET]}\n"
        else
            output+="$section\n"
        fi

        # Section content
        local content="${HELP_SECTION_CONTENT[$section]}"
        if command -v wrap >/dev/null 2>&1; then
            content=$(wrap "$content" $((HELP_WIDTH - HELP_INDENT)) "$(repeat ' ' "$HELP_INDENT")")
        else
            # Simple indentation if textwrap not available
            content="  $content"
        fi
        output+="$content\n\n"
    done

    # Footer
    if [[ -n "$HELP_PROGRAM_AUTHOR" ]] || [[ -n "$HELP_PROGRAM_LICENSE" ]]; then
        output+="\n"
        if [[ -n "$HELP_PROGRAM_AUTHOR" ]]; then
            output+="Author: $HELP_PROGRAM_AUTHOR\n"
        fi
        if [[ -n "$HELP_PROGRAM_LICENSE" ]]; then
            output+="License: $HELP_PROGRAM_LICENSE\n"
        fi
    fi

    echo -e "$output"
}

# Display help with pager
help_display() {
    local help_text="$(help_generate)"

    if [[ -t 1 ]] && command -v "$HELP_PAGER" >/dev/null 2>&1; then
        echo -e "$help_text" | "$HELP_PAGER"
    else
        echo -e "$help_text"
    fi
}

# Reset help builder
help_reset() {
    HELP_PROGRAM_NAME=""
    HELP_PROGRAM_VERSION=""
    HELP_PROGRAM_DESCRIPTION=""
    HELP_PROGRAM_AUTHOR=""
    HELP_PROGRAM_LICENSE=""
    HELP_SECTIONS=()
    HELP_SECTION_CONTENT=()
}

# Option formatting helpers
format_option() {
    local short="$1"
    local long="$2"
    local arg="$3"
    local description="$4"

    local option_str=""
    if [[ -n "$short" ]] && [[ -n "$long" ]]; then
        option_str="  -$short, --$long"
    elif [[ -n "$short" ]]; then
        option_str="  -$short"
    elif [[ -n "$long" ]]; then
        option_str="      --$long"
    fi

    if [[ -n "$arg" ]]; then
        option_str+=" $arg"
    fi

    if [[ ${#option_str} -lt 30 ]]; then
        printf "%-30s %s\n" "$option_str" "$description"
    else
        printf "%s\n%-30s %s\n" "$option_str" "" "$description"
    fi
}

# Build options list
build_options() {
    local -a options=()

    while [[ $# -gt 0 ]]; do
        local short="$1"
        local long="$2"
        local arg="$3"
        local desc="$4"
        shift 4

        options+=("$(format_option "$short" "$long" "$arg" "$desc")")
    done

    printf '%s\n' "${options[@]}"
}

# Man page generation
generate_man_page() {
    local name="$1"
    local section="${2:-1}"
    local date="${3:-$(date '+%B %Y')}"

    cat <<EOF
.TH ${name^^} $section "$date" "$HELP_PROGRAM_VERSION" "$HELP_PROGRAM_NAME"
.SH NAME
$name \\- $HELP_PROGRAM_DESCRIPTION
EOF

    for section_name in "${HELP_SECTIONS[@]}"; do
        echo ".SH $section_name"
        echo "${HELP_SECTION_CONTENT[$section_name]}" | sed 's/^/.PP\n/'
    done

    if [[ -n "$HELP_PROGRAM_AUTHOR" ]]; then
        echo ".SH AUTHOR"
        echo "$HELP_PROGRAM_AUTHOR"
    fi

    if [[ -n "$HELP_PROGRAM_LICENSE" ]]; then
        echo ".SH LICENSE"
        echo "$HELP_PROGRAM_LICENSE"
    fi
}

# Usage string builder
typeset -g USAGE_PROGRAM=""
typeset -ga USAGE_PATTERNS=()
typeset -gA USAGE_COMMANDS=()
typeset -gA USAGE_OPTIONS=()
typeset -gA USAGE_ARGUMENTS=()

usage_program() {
    USAGE_PROGRAM="$1"
}

usage_pattern() {
    USAGE_PATTERNS+=("$1")
}

usage_command() {
    local name="$1"
    local description="$2"
    USAGE_COMMANDS[$name]="$description"
}

usage_option() {
    local option="$1"
    local description="$2"
    USAGE_OPTIONS[$option]="$description"
}

usage_argument() {
    local arg="$1"
    local description="$2"
    USAGE_ARGUMENTS[$arg]="$description"
}

usage_generate() {
    local output=""

    # Usage patterns
    if [[ ${#USAGE_PATTERNS[@]} -gt 0 ]]; then
        output+="Usage:\n"
        for pattern in "${USAGE_PATTERNS[@]}"; do
            output+="  $USAGE_PROGRAM $pattern\n"
        done
    else
        output+="Usage: $USAGE_PROGRAM [OPTIONS]\n"
    fi

    # Commands
    if [[ ${#USAGE_COMMANDS[@]} -gt 0 ]]; then
        output+="\nCommands:\n"
        for cmd in ${(k)USAGE_COMMANDS}; do
            printf "  %-20s %s\n" "$cmd" "${USAGE_COMMANDS[$cmd]}"
        done | sort
    fi

    # Options
    if [[ ${#USAGE_OPTIONS[@]} -gt 0 ]]; then
        output+="\nOptions:\n"
        for opt in ${(k)USAGE_OPTIONS}; do
            printf "  %-20s %s\n" "$opt" "${USAGE_OPTIONS[$opt]}"
        done | sort
    fi

    # Arguments
    if [[ ${#USAGE_ARGUMENTS[@]} -gt 0 ]]; then
        output+="\nArguments:\n"
        for arg in ${(k)USAGE_ARGUMENTS}; do
            printf "  %-20s %s\n" "$arg" "${USAGE_ARGUMENTS[$arg]}"
        done
    fi

    echo -e "$output"
}

usage_reset() {
    USAGE_PROGRAM=""
    USAGE_PATTERNS=()
    USAGE_COMMANDS=()
    USAGE_OPTIONS=()
    USAGE_ARGUMENTS=()
}

# Error message helpers
error_usage() {
    local message="$1"

    if [[ $HELP_COLOR -eq 1 ]] && [[ -n "${COLORS[RED]}" ]]; then
        echo -e "${COLORS[RED]}Error: $message${COLORS[RESET]}" >&2
    else
        echo "Error: $message" >&2
    fi

    echo "Try '$USAGE_PROGRAM --help' for more information." >&2
    return 1
}

# Version string helpers
version_string() {
    local name="${1:-$HELP_PROGRAM_NAME}"
    local version="${2:-$HELP_PROGRAM_VERSION}"
    local extra="${3:-}"

    local output="$name"
    [[ -n "$version" ]] && output+=" version $version"
    [[ -n "$extra" ]] && output+=" ($extra)"

    echo "$output"
}

# Quick help generator for simple scripts
quick_help() {
    local program="${1:-${0:t}}"
    local description="$2"
    local usage="$3"
    shift 3

    echo "$program - $description"
    echo
    echo "Usage: $usage"

    if [[ $# -gt 0 ]]; then
        echo
        echo "Options:"
        while [[ $# -gt 0 ]]; do
            printf "  %-30s %s\n" "$1" "$2"
            shift 2
        done
    fi
}

# Command completion helper
generate_completion() {
    local program="${1:-${0:t}}"
    local shell="${2:-zsh}"

    case "$shell" in
        zsh)
            cat <<EOF
#compdef $program

_${program}() {
    local -a options commands

    options=(
EOF
            for opt in ${(k)USAGE_OPTIONS}; do
                echo "        '$opt[${USAGE_OPTIONS[$opt]}]'"
            done
            cat <<EOF
    )

    commands=(
EOF
            for cmd in ${(k)USAGE_COMMANDS}; do
                echo "        '$cmd:${USAGE_COMMANDS[$cmd]}'"
            done
            cat <<EOF
    )

    _arguments -s \\
        '\*::: :->args' \\
        \$options

    case \$state in
        args)
            _describe 'command' commands
            ;;
    esac
}

_${program} "\$@"
EOF
            ;;
        bash)
            cat <<EOF
_${program}() {
    local cur prev opts
    COMPREPLY=()
    cur="\${COMP_WORDS[COMP_CWORD]}"
    prev="\${COMP_WORDS[COMP_CWORD-1]}"
    opts="$(echo "${(k)USAGE_OPTIONS}" "${(k)USAGE_COMMANDS}")"

    COMPREPLY=( \$(compgen -W "\${opts}" -- \${cur}) )
    return 0
}
complete -F _${program} $program
EOF
            ;;
    esac
}

# Documentation generation helpers
generate_readme() {
    local format="${1:-markdown}"

    case "$format" in
        markdown)
            echo "# $HELP_PROGRAM_NAME"
            echo
            [[ -n "$HELP_PROGRAM_DESCRIPTION" ]] && echo "$HELP_PROGRAM_DESCRIPTION"
            echo
            echo "## Installation"
            echo
            echo '```bash'
            echo "# Add installation instructions here"
            echo '```'
            echo
            echo "## Usage"
            echo
            echo '```bash'
            for pattern in "${USAGE_PATTERNS[@]}"; do
                echo "$USAGE_PROGRAM $pattern"
            done
            echo '```'

            if [[ ${#USAGE_OPTIONS[@]} -gt 0 ]]; then
                echo
                echo "## Options"
                echo
                for opt in ${(k)USAGE_OPTIONS}; do
                    echo "- \`$opt\` - ${USAGE_OPTIONS[$opt]}"
                done | sort
            fi

            if [[ ${#USAGE_COMMANDS[@]} -gt 0 ]]; then
                echo
                echo "## Commands"
                echo
                for cmd in ${(k)USAGE_COMMANDS}; do
                    echo "- \`$cmd\` - ${USAGE_COMMANDS[$cmd]}"
                done | sort
            fi

            for section in "${HELP_SECTIONS[@]}"; do
                case "$section" in
                    USAGE|OPTIONS|SYNOPSIS) continue ;;
                    *)
                        echo
                        echo "## ${section:l:1}${section:l:1:}"
                        echo
                        echo "${HELP_SECTION_CONTENT[$section]}"
                        ;;
                esac
            done

            [[ -n "$HELP_PROGRAM_AUTHOR" ]] && echo -e "\n## Author\n\n$HELP_PROGRAM_AUTHOR"
            [[ -n "$HELP_PROGRAM_LICENSE" ]] && echo -e "\n## License\n\n$HELP_PROGRAM_LICENSE"
            ;;
    esac
}

# Helper to repeat character
str_repeat() {
    local char="${1:- }"
    local count="${2:-1}"
    local result=""

    for ((i=0; i<count; i++)); do
        result+="$char"
    done

    echo "$result"
}
