#!/usr/bin/env zsh

# yaml.zsh - YAML parsing and generation library
# Provides YAML encoding/decoding functionality

# YAML configuration
typeset -g YAML_INDENT=${YAML_INDENT:-2}
typeset -g YAML_QUOTE_STRINGS=${YAML_QUOTE_STRINGS:-0}
typeset -g YAML_FLOW_STYLE=${YAML_FLOW_STYLE:-0}

# YAML encoding
yaml_encode() {
  local -n data_ref=$1
  local indent="${2:-0}"
  local output=""

  # Check if associative array (hash) or regular array
  if [[ "${(t)data_ref}" == *association* ]]; then
    yaml_encode_hash data_ref "$indent"
  elif [[ "${(t)data_ref}" == *array* ]]; then
    yaml_encode_array data_ref "$indent"
  else
    yaml_encode_scalar "${data_ref}" "$indent"
  fi
}

yaml_encode_scalar() {
  local value="$1"
  local indent="${2:-0}"

  # Check for special values
  if [[ -z "$value" ]]; then
    echo "null"
  elif [[ "$value" == "true" ]] || [[ "$value" == "false" ]]; then
    echo "$value"
  elif [[ "$value" =~ ^-?[0-9]+\.?[0-9]*$ ]]; then
    echo "$value"
  elif [[ "$value" =~ [:\{\}\[\],\&\*\#\?\|\-\<\>\=\!\%\@\\] ]] || [[ "$YAML_QUOTE_STRINGS" -eq 1 ]]; then
    # Quote if contains special characters
    yaml_quote_string "$value"
  else
    echo "$value"
  fi
}

yaml_quote_string() {
  local str="$1"

  # Escape quotes and backslashes
  str="${str//\\/\\\\}"
  str="${str//\"/\\\"}"

  # Use literal style for multiline strings
  if [[ "$str" == *$'\n'* ]]; then
    echo "|"
    echo "$str" | sed "s/^/  /"
  else
    echo "\"$str\""
  fi
}

yaml_encode_array() {
  local -n arr_ref=$1
  local indent="${2:-0}"
  local indent_str="$(repeat ' ' "$indent")"

  if [[ $YAML_FLOW_STYLE -eq 1 ]]; then
    # Flow style [item1, item2, ...]
    local output="["
    local first=1
    for item in "${arr_ref[@]}"; do
      [[ $first -eq 0 ]] && output+=", "
      output+="$(yaml_encode_scalar "$item" 0)"
      first=0
    done
    output+="]"
    echo "$output"
  else
    # Block style
    for item in "${arr_ref[@]}"; do
      echo "${indent_str}- $(yaml_encode_scalar "$item" 0)"
    done
  fi
}

yaml_encode_hash() {
  local -n hash_ref=$1
  local indent="${2:-0}"
  local indent_str="$(repeat ' ' "$indent")"
  local inner_indent=$((indent + YAML_INDENT))

  if [[ $YAML_FLOW_STYLE -eq 1 ]]; then
    # Flow style {key1: value1, key2: value2}
    local output="{"
    local first=1
    for key in ${(k)hash_ref}; do
      [[ $first -eq 0 ]] && output+=", "
      output+="$key: $(yaml_encode_scalar "${hash_ref[$key]}" 0)"
      first=0
    done
    output+="}"
    echo "$output"
  else
    # Block style
    for key in ${(ok)hash_ref}; do
      local value="${hash_ref[$key]}"

      # Check if value is complex (contains newlines or is very long)
      if [[ "$value" == *$'\n'* ]] || [[ ${#value} -gt 80 ]]; then
        echo "${indent_str}${key}:"
        echo "$value" | sed "s/^/$(repeat ' ' $inner_indent)/"
      else
        echo "${indent_str}${key}: $(yaml_encode_scalar "$value" 0)"
      fi
    done
  fi
}

# YAML decoding (basic implementation)
yaml_decode() {
  local yaml="$1"
  local -n result_ref=$2

  if command -v yq >/dev/null 2>&1; then
    # Use yq if available
    result_ref=$(echo "$yaml" | yq eval '.' -)
  else
    yaml_decode_basic "$yaml" result_ref
  fi
}

yaml_decode_basic() {
  local yaml="$1"
  local -n result_ref=$2
  result_ref=()

  local current_key=""
  local in_multiline=0
  local multiline_content=""

  while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// }" ]] && continue

    # Check for array items
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]](.+) ]]; then
      local value="${BASH_REMATCH[1]}"
      result_ref+=("$(yaml_decode_value "$value")")
    # Check for key-value pairs
    elif [[ "$line" =~ ^[[:space:]]*([^:]+):[[:space:]]*(.*) ]]; then
      current_key="${BASH_REMATCH[1]// /}"
      local value="${BASH_REMATCH[2]}"

      if [[ -z "$value" ]]; then
        # Value on next line or multiline
        in_multiline=1
        multiline_content=""
      else
        result_ref[$current_key]="$(yaml_decode_value "$value")"
      fi
    elif [[ $in_multiline -eq 1 ]]; then
      # Multiline value
      if [[ "$line" =~ ^[[:space:]]{2,}(.+) ]]; then
        multiline_content+="${BASH_REMATCH[1]}\n"
      else
        result_ref[$current_key]="${multiline_content%\\n}"
        in_multiline=0
      fi
    fi
  done <<< "$yaml"

  # Handle final multiline if any
  if [[ $in_multiline -eq 1 ]] && [[ -n "$current_key" ]]; then
    result_ref[$current_key]="${multiline_content%\\n}"
  fi
}

yaml_decode_value() {
  local value="$1"

  # Remove leading/trailing whitespace
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"

  # Remove quotes if present
  if [[ "$value" =~ ^\"(.*)\"$ ]] || [[ "$value" =~ ^\'(.*)\'$ ]]; then
    value="${BASH_REMATCH[1]}"
  fi

  # Convert special values
  case "$value" in
    "null"|"~") echo "" ;;
    "true"|"yes"|"on") echo "true" ;;
    "false"|"no"|"off") echo "false" ;;
    *) echo "$value" ;;
  esac
}

# YAML validation
yaml_validate() {
  local yaml="$1"

  if command -v yq >/dev/null 2>&1; then
    echo "$yaml" | yq eval '.' - >/dev/null 2>&1
  else
    yaml_validate_basic "$yaml"
  fi
}

yaml_validate_basic() {
  local yaml="$1"

  # Basic validation checks
  local indent_errors=0
  local prev_indent=0

  while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// }" ]] && continue

    # Check indentation
    local current_indent=0
    if [[ "$line" =~ ^([[:space:]]*) ]]; then
      current_indent=${#BASH_REMATCH[1]}
    fi

    # Indentation must be consistent
    if [[ $current_indent -gt 0 ]] && [[ $((current_indent % YAML_INDENT)) -ne 0 ]]; then
      ((indent_errors++))
    fi
  done <<< "$yaml"

  [[ $indent_errors -eq 0 ]]
}

# YAML query functions
yaml_get() {
  local yaml="$1"
  local path="$2"
  local default="${3:-}"

  if command -v yq >/dev/null 2>&1; then
    local result=$(echo "$yaml" | yq eval "$path" - 2>/dev/null)
    if [[ "$result" == "null" ]] || [[ -z "$result" ]]; then
      echo "$default"
    else
      echo "$result"
    fi
  else
    echo "$default"
  fi
}

yaml_set() {
  local yaml="$1"
  local path="$2"
  local value="$3"

  if command -v yq >/dev/null 2>&1; then
    echo "$yaml" | yq eval "$path = \"$value\"" -
  else
    echo "$yaml"
  fi
}

yaml_delete() {
  local yaml="$1"
  local path="$2"

  if command -v yq >/dev/null 2>&1; then
    echo "$yaml" | yq eval "del($path)" -
  else
    echo "$yaml"
  fi
}

yaml_merge() {
  local yaml1="$1"
  local yaml2="$2"

  if command -v yq >/dev/null 2>&1; then
    yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' <(echo "$yaml1") <(echo "$yaml2")
  else
    echo "$yaml1"
    echo "---"
    echo "$yaml2"
  fi
}

# YAML file operations
yaml_read() {
  local file="$1"

  if [[ -f "$file" ]]; then
    cat "$file"
  else
    echo ""
  fi
}

yaml_write() {
  local file="$1"
  local yaml="$2"

  echo "$yaml" > "$file"
}

# YAML to JSON conversion
yaml_to_json() {
  local yaml="$1"

  if command -v yq >/dev/null 2>&1; then
    echo "$yaml" | yq eval -o json '.' -
  else
    # Basic conversion
    local -A data
    yaml_decode_basic "$yaml" data
    json_encode_object data
  fi
}

# JSON to YAML conversion
json_to_yaml() {
  local json="$1"

  if command -v yq >/dev/null 2>&1; then
    echo "$json" | yq eval -P '.' -
  else
    # Basic conversion
    echo "# Converted from JSON"
    echo "$json" | sed 's/[{}]//g' | sed 's/,/\n/g' | sed 's/"//g' | sed 's/:/: /g'
  fi
}

# YAML document handling
yaml_split_documents() {
  local yaml="$1"
  local -a documents=()
  local current_doc=""

  while IFS= read -r line; do
    if [[ "$line" == "---" ]]; then
      [[ -n "$current_doc" ]] && documents+=("$current_doc")
      current_doc=""
    else
      current_doc+="$line\n"
    fi
  done <<< "$yaml"

  [[ -n "$current_doc" ]] && documents+=("$current_doc")

  printf '%s\n' "${documents[@]}"
}

yaml_join_documents() {
  local output=""
  local first=1

  for doc in "$@"; do
    [[ $first -eq 0 ]] && output+="\n---\n"
    output+="$doc"
    first=0
  done

  echo "$output"
}

# YAML anchors and aliases (basic support)
yaml_resolve_anchors() {
  local yaml="$1"
  local -A anchors=()

  # First pass: collect anchors
  while IFS= read -r line; do
    if [[ "$line" =~ \&([^[:space:]]+)[[:space:]](.+) ]]; then
      local anchor="${BASH_REMATCH[1]}"
      local value="${BASH_REMATCH[2]}"
      anchors[$anchor]="$value"
    fi
  done <<< "$yaml"

  # Second pass: replace aliases
  local output="$yaml"
  for anchor in ${(k)anchors}; do
    output="${output//\*$anchor/${anchors[$anchor]}}"
  done

  echo "$output"
}

# YAML schema validation
yaml_validate_schema() {
  local yaml="$1"
  local schema="$2"

  if command -v yq >/dev/null 2>&1; then
    # Basic schema validation
    local yaml_keys=$(echo "$yaml" | yq eval 'keys' -)
    local schema_keys=$(echo "$schema" | yq eval '.properties | keys' -)

    # Check if all required keys are present
    while IFS= read -r key; do
      if ! echo "$yaml_keys" | grep -q "$key"; then
        echo "Missing required key: $key" >&2
        return 1
      fi
    done <<< "$schema_keys"
  fi

  return 0
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

# YAML pretty printing
yaml_pretty() {
  local yaml="$1"
  local indent="${2:-2}"

  if command -v yq >/dev/null 2>&1; then
    echo "$yaml" | yq eval '.' -
  else
    # Basic formatting
    YAML_INDENT=$indent yaml_format "$yaml"
  fi
}

yaml_format() {
  local yaml="$1"
  local formatted=""
  local current_indent=0

  while IFS= read -r line; do
    # Adjust indentation based on content
    if [[ "$line" =~ ^[^[:space:]] ]]; then
      current_indent=0
    elif [[ "$line" =~ ^[[:space:]]*- ]]; then
      : # Keep current indent for list items
    fi

    formatted+="$(repeat ' ' $current_indent)$line\n"
  done <<< "$yaml"

  echo -e "$formatted"
}
