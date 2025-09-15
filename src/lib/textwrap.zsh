#!/usr/bin/env zsh

# textwrap.zsh - Text formatting and wrapping utilities
# Provides functions for text wrapping, alignment, and formatting

# Default settings
typeset -gi TEXTWRAP_WIDTH=${TEXTWRAP_WIDTH:-80}
typeset -g TEXTWRAP_BREAK_LONG_WORDS=${TEXTWRAP_BREAK_LONG_WORDS:-true}
typeset -g TEXTWRAP_BREAK_ON_HYPHENS=${TEXTWRAP_BREAK_ON_HYPHENS:-true}

# Wrap text to specified width
wrap() {
    local text="$1"
    local width="${2:-$TEXTWRAP_WIDTH}"
    local indent="${3:-}"
    local subsequent_indent="${4:-$indent}"

    echo "$text" | fold -s -w "$width" | while IFS= read -r line; do
        if [[ -z "$first_line_done" ]]; then
            echo "${indent}${line}"
            first_line_done=1
        else
            echo "${subsequent_indent}${line}"
        fi
    done
}

# Fill paragraph (wrap and justify)
fill() {
    local text="$1"
    local width="${2:-$TEXTWRAP_WIDTH}"

    echo "$text" | fmt -w "$width"
}

# Dedent text (remove common leading whitespace)
dedent() {
    local text="$1"
    local min_indent=""

    # Find minimum indentation
    while IFS= read -r line; do
        if [[ -n "$line" ]] && [[ "$line" =~ ^[[:space:]]+ ]]; then
            local indent="${BASH_REMATCH[0]}"
            if [[ -z "$min_indent" ]] || [[ ${#indent} -lt ${#min_indent} ]]; then
                min_indent="$indent"
            fi
        fi
    done <<< "$text"

    # Remove minimum indentation from all lines
    if [[ -n "$min_indent" ]]; then
        echo "$text" | sed "s/^${min_indent}//"
    else
        echo "$text"
    fi
}

# Indent text
indent() {
    local text="$1"
    local prefix="${2:-    }"
    local first_line_prefix="${3:-$prefix}"

    local first_line=1
    while IFS= read -r line; do
        if [[ $first_line -eq 1 ]]; then
            echo "${first_line_prefix}${line}"
            first_line=0
        else
            echo "${prefix}${line}"
        fi
    done <<< "$text"
}

# Center text
center() {
    local text="$1"
    local width="${2:-$TEXTWRAP_WIDTH}"

    while IFS= read -r line; do
        local line_length=${#line}
        if [[ $line_length -ge $width ]]; then
            echo "$line"
        else
            local padding=$(( (width - line_length) / 2 ))
            printf "%*s%s\n" "$padding" "" "$line"
        fi
    done <<< "$text"
}

# Right align text
right_align() {
    local text="$1"
    local width="${2:-$TEXTWRAP_WIDTH}"

    while IFS= read -r line; do
        printf "%*s\n" "$width" "$line"
    done <<< "$text"
}

# Left align text (default behavior, but explicit)
left_align() {
    local text="$1"
    local width="${2:-$TEXTWRAP_WIDTH}"

    while IFS= read -r line; do
        printf "%-*s\n" "$width" "$line"
    done <<< "$text"
}

# Justify text (add spaces to reach width)
justify() {
    local text="$1"
    local width="${2:-$TEXTWRAP_WIDTH}"

    while IFS= read -r line; do
        local words=($line)
        local word_count=${#words[@]}

        if [[ $word_count -le 1 ]] || [[ ${#line} -ge $width ]]; then
            echo "$line"
            continue
        fi

        # Calculate spaces needed
        local text_length=0
        for word in "${words[@]}"; do
            text_length=$((text_length + ${#word}))
        done

        local total_spaces=$((width - text_length))
        local gaps=$((word_count - 1))

        if [[ $gaps -eq 0 ]]; then
            echo "$line"
            continue
        fi

        local space_per_gap=$((total_spaces / gaps))
        local extra_spaces=$((total_spaces % gaps))

        # Build justified line
        local result=""
        for ((i=0; i<word_count; i++)); do
            result+="${words[$i]}"
            if [[ $i -lt $((word_count - 1)) ]]; then
                for ((j=0; j<space_per_gap; j++)); do
                    result+=" "
                done
                if [[ $i -lt $extra_spaces ]]; then
                    result+=" "
                fi
            fi
        done

        echo "$result"
    done <<< "$text"
}

# Truncate text with ellipsis
truncate() {
    local text="$1"
    local max_length="${2:-$TEXTWRAP_WIDTH}"
    local ellipsis="${3:-...}"

    if [[ ${#text} -le $max_length ]]; then
        echo "$text"
    else
        local truncate_at=$((max_length - ${#ellipsis}))
        echo "${text:0:$truncate_at}${ellipsis}"
    fi
}

# Shorten text (truncate from middle)
shorten() {
    local text="$1"
    local max_length="${2:-$TEXTWRAP_WIDTH}"
    local placeholder="${3:-...}"

    if [[ ${#text} -le $max_length ]]; then
        echo "$text"
    else
        local keep_length=$((max_length - ${#placeholder}))
        local start_length=$((keep_length / 2))
        local end_length=$((keep_length - start_length))

        echo "${text:0:$start_length}${placeholder}${text: -$end_length}"
    fi
}

# Add prefix to each line
prefix_lines() {
    local text="$1"
    local prefix="$2"

    while IFS= read -r line; do
        echo "${prefix}${line}"
    done <<< "$text"
}

# Add suffix to each line
suffix_lines() {
    local text="$1"
    local suffix="$2"

    while IFS= read -r line; do
        echo "${line}${suffix}"
    done <<< "$text"
}

# Create a text box
text_box() {
    local text="$1"
    local width="${2:-$TEXTWRAP_WIDTH}"
    local style="${3:-single}"  # single, double, ascii, round

    # Define box characters based on style
    case "$style" in
        double)
            local tl="╔" tr="╗" bl="╚" br="╝" h="═" v="║"
            ;;
        ascii)
            local tl="+" tr="+" bl="+" br="+" h="-" v="|"
            ;;
        round)
            local tl="╭" tr="╮" bl="╰" br="╯" h="─" v="│"
            ;;
        *)  # single
            local tl="┌" tr="┐" bl="└" br="┘" h="─" v="│"
            ;;
    esac

    # Top border
    echo -n "$tl"
    for ((i=0; i<width+2; i++)); do
        echo -n "$h"
    done
    echo "$tr"

    # Content with side borders
    while IFS= read -r line; do
        printf "%s %-*s %s\n" "$v" "$width" "$line" "$v"
    done <<< "$text"

    # Bottom border
    echo -n "$bl"
    for ((i=0; i<width+2; i++)); do
        echo -n "$h"
    done
    echo "$br"
}

# Create a banner
banner() {
    local text="$1"
    local width="${2:-$TEXTWRAP_WIDTH}"
    local char="${3:-=}"

    local border=$(repeat "$char" "$width")
    local centered=$(center "$text" "$width")

    echo "$border"
    echo "$centered"
    echo "$border"
}

# Column layout
columns() {
    local -a texts=("$@")
    local num_columns=${#texts[@]}
    local total_width=${TEXTWRAP_WIDTH}
    local column_width=$((total_width / num_columns - 1))

    # Convert texts to arrays of lines
    local -a column_lines=()
    local max_lines=0

    for text in "${texts[@]}"; do
        local -a lines=()
        while IFS= read -r line; do
            lines+=("$(truncate "$line" "$column_width")")
        done <<< "$text"
        column_lines+=("${lines[@]}")
        [[ ${#lines[@]} -gt $max_lines ]] && max_lines=${#lines[@]}
    done

    # Print columns side by side
    for ((i=0; i<max_lines; i++)); do
        for ((j=0; j<num_columns; j++)); do
            local idx=$((j * max_lines + i))
            if [[ $idx -lt ${#column_lines[@]} ]]; then
                printf "%-*s" "$column_width" "${column_lines[$idx]}"
            else
                printf "%-*s" "$column_width" ""
            fi
            [[ $j -lt $((num_columns - 1)) ]] && echo -n " "
        done
        echo
    done
}

# Repeat string
repeat() {
    local string="$1"
    local count="${2:-1}"
    local result=""

    for ((i=0; i<count; i++)); do
        result+="$string"
    done

    echo "$result"
}

# Title case
title_case() {
    local text="$1"
    echo "$text" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1'
}

# Snake case to camel case
snake_to_camel() {
    local text="$1"
    echo "$text" | awk -F_ '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' OFS=""
}

# Camel case to snake case
camel_to_snake() {
    local text="$1"
    echo "$text" | sed 's/\([A-Z]\)/_\L\1/g' | sed 's/^_//'
}

# Remove ANSI escape codes
strip_ansi() {
    local text="$1"
    echo "$text" | sed 's/\x1b\[[0-9;]*m//g'
}

# Word wrap preserving ANSI codes
wrap_ansi() {
    local text="$1"
    local width="${2:-$TEXTWRAP_WIDTH}"

    # Strip ANSI codes for length calculation
    local plain_text=$(strip_ansi "$text")

    # Simple implementation - can be improved
    wrap "$text" "$width"
}

# Expand tabs to spaces
expand_tabs() {
    local text="$1"
    local tab_size="${2:-4}"

    echo "$text" | expand -t "$tab_size"
}

# Convert spaces to tabs
unexpand_tabs() {
    local text="$1"
    local tab_size="${2:-4}"

    echo "$text" | unexpand -t "$tab_size"
}

# Remove duplicate blank lines
squeeze_blank_lines() {
    local text="$1"
    echo "$text" | cat -s
}

# Number lines
number_lines() {
    local text="$1"
    local format="${2:-%3d: }"

    local line_num=1
    while IFS= read -r line; do
        printf "$format" "$line_num"
        echo "$line"
        ((line_num++))
    done <<< "$text"
}

# Quote text (email-style)
quote() {
    local text="$1"
    local marker="${2:-> }"

    prefix_lines "$text" "$marker"
}

# Markdown code block
code_block() {
    local text="$1"
    local language="${2:-}"

    echo '```'"$language"
    echo "$text"
    echo '```'
}

# Table formatter
format_table() {
    local -a headers=()
    local -a rows=()
    local -a widths=()

    # Parse input (first line is headers)
    local first_line=1
    while IFS= read -r line; do
        if [[ $first_line -eq 1 ]]; then
            IFS='|' read -ra headers <<< "$line"
            first_line=0
            # Initialize widths
            for header in "${headers[@]}"; do
                widths+=(${#header})
            done
        else
            IFS='|' read -ra row <<< "$line"
            rows+=("$line")
            # Update widths
            for ((i=0; i<${#row[@]}; i++)); do
                local len=${#row[$i]}
                [[ $len -gt ${widths[$i]:-0} ]] && widths[$i]=$len
            done
        fi
    done

    # Print table
    # Header
    for ((i=0; i<${#headers[@]}; i++)); do
        printf "%-*s" "${widths[$i]}" "${headers[$i]}"
        [[ $i -lt $((${#headers[@]} - 1)) ]] && echo -n " | "
    done
    echo

    # Separator
    for ((i=0; i<${#headers[@]}; i++)); do
        printf "%s" "$(repeat '-' "${widths[$i]}")"
        [[ $i -lt $((${#headers[@]} - 1)) ]] && echo -n "-+-"
    done
    echo

    # Rows
    for row in "${rows[@]}"; do
        IFS='|' read -ra cells <<< "$row"
        for ((i=0; i<${#cells[@]}; i++)); do
            printf "%-*s" "${widths[$i]}" "${cells[$i]}"
            [[ $i -lt $((${#cells[@]} - 1)) ]] && echo -n " | "
        done
        echo
    done
}