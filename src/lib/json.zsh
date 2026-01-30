#!/usr/bin/env zsh

# json.zsh - JSON parsing and generation library
# Provides JSON encoding/decoding functionality

# JSON parsing configuration
typeset -g JSON_STRICT=${JSON_STRICT:-1}
typeset -g JSON_PRETTY=${JSON_PRETTY:-0}
typeset -g JSON_INDENT=${JSON_INDENT:-2}

# JSON value types
typeset -g JSON_TYPE_NULL="null"
typeset -g JSON_TYPE_BOOL="bool"
typeset -g JSON_TYPE_NUMBER="number"
typeset -g JSON_TYPE_STRING="string"
typeset -g JSON_TYPE_ARRAY="array"
typeset -g JSON_TYPE_OBJECT="object"

# JSON encoding
json_encode() {
  local value="$1"
  local type="${2:-auto}"
  local indent="${3:-0}"

  case "$type" in
    auto)
      json_encode_auto "$value" "$indent"
      ;;
    null)
      echo "null"
      ;;
    bool|boolean)
      json_encode_bool "$value"
      ;;
    number|int|float)
      json_encode_number "$value"
      ;;
    string)
      json_encode_string "$value"
      ;;
    array)
      json_encode_array "$value" "$indent"
      ;;
    object|hash)
      json_encode_object "$value" "$indent"
      ;;
    *)
      echo "null"
      ;;
  esac
}

json_encode_auto() {
  local value="$1"
  local indent="${2:-0}"

  # Detect type
  if [[ -z "$value" ]] || [[ "$value" == "null" ]]; then
    echo "null"
  elif [[ "$value" == "true" ]] || [[ "$value" == "false" ]]; then
    echo "$value"
  elif [[ "$value" =~ ^-?[0-9]+\.?[0-9]*$ ]]; then
    echo "$value"
  elif [[ "$value" =~ ^\[.*\]$ ]]; then
    json_encode_array "$value" "$indent"
  elif [[ "$value" =~ ^\{.*\}$ ]]; then
    json_encode_object "$value" "$indent"
  else
    json_encode_string "$value"
  fi
}

json_encode_string() {
  local str="$1"

  # Escape special characters
  str="${str//\\/\\\\}"  # Backslash
  str="${str//\"/\\\"}"  # Quote
  str="${str//$'\n'/\\n}"  # Newline
  str="${str//$'\r'/\\r}"  # Carriage return
  str="${str//$'\t'/\\t}"  # Tab
  str="${str//$'\b'/\\b}"  # Backspace
  str="${str//$'\f'/\\f}"  # Form feed

  echo "\"$str\""
}

json_encode_bool() {
  local value="${1,,}"  # lowercase

  case "$value" in
    true|1|yes|on) echo "true" ;;
    false|0|no|off) echo "false" ;;
    *) echo "null" ;;
  esac
}

json_encode_number() {
  local value="$1"

  if [[ "$value" =~ ^-?[0-9]+$ ]]; then
    echo "$value"
  elif [[ "$value" =~ ^-?[0-9]+\.[0-9]+$ ]]; then
    echo "$value"
  else
    echo "null"
  fi
}

json_encode_array() {
  local -n arr_ref=$1
  local indent="${2:-0}"
  local output="["

  if [[ $JSON_PRETTY -eq 1 ]] && [[ ${#arr_ref[@]} -gt 0 ]]; then
    local inner_indent=$((indent + JSON_INDENT))
    output+="\n"

    local first=1
    for item in "${arr_ref[@]}"; do
      [[ $first -eq 0 ]] && output+=",\n"
      output+="$(repeat ' ' $inner_indent)"
      output+="$(json_encode_auto "$item" $inner_indent)"
      first=0
    done

    output+="\n$(repeat ' ' "$indent")]"
  else
    local first=1
    for item in "${arr_ref[@]}"; do
      [[ $first -eq 0 ]] && output+=","
      output+="$(json_encode_auto "$item" 0)"
      first=0
    done
    output+="]"
  fi

  echo "$output"
}

json_encode_object() {
  local -n hash_ref=$1
  local indent="${2:-0}"
  local output="{"

  if [[ $JSON_PRETTY -eq 1 ]] && [[ ${#hash_ref[@]} -gt 0 ]]; then
    local inner_indent=$((indent + JSON_INDENT))
    output+="\n"

    local first=1
    for key in ${(ok)hash_ref}; do
      [[ $first -eq 0 ]] && output+=",\n"
      output+="$(repeat ' ' $inner_indent)"
      output+="$(json_encode_string "$key"): "
      output+="$(json_encode_auto "${hash_ref[$key]}" $inner_indent)"
      first=0
    done

    output+="\n$(repeat ' ' "$indent")}"
  else
    local first=1
    for key in ${(k)hash_ref}; do
      [[ $first -eq 0 ]] && output+=","
      output+="$(json_encode_string "$key"):$(json_encode_auto "${hash_ref[$key]}" 0)"
      first=0
    done
    output+="}"
  fi

  echo "$output"
}

# JSON decoding (basic implementation using jq if available)
json_decode() {
  local json="$1"
  local query="${2:-.}"

  if command -v jq >/dev/null 2>&1; then
    echo "$json" | jq -r "$query"
  else
    json_decode_basic "$json"
  fi
}

json_decode_basic() {
  local json="$1"

  # Remove whitespace
  json="${json//[$'\n\r\t']/}"

  # Basic parsing (limited functionality)
  if [[ "$json" == "null" ]]; then
    echo ""
  elif [[ "$json" == "true" ]] || [[ "$json" == "false" ]]; then
    echo "$json"
  elif [[ "$json" =~ ^-?[0-9]+\.?[0-9]*$ ]]; then
    echo "$json"
  elif [[ "$json" =~ ^\"(.*)\"$ ]]; then
    json_decode_string "${BASH_REMATCH[1]}"
  else
    echo "$json"
  fi
}

json_decode_string() {
  local str="$1"

  # Unescape special characters
  str="${str//\\n/$'\n'}"  # Newline
  str="${str//\\r/$'\r'}"  # Carriage return
  str="${str//\\t/$'\t'}"  # Tab
  str="${str//\\b/$'\b'}"  # Backspace
  str="${str//\\f/$'\f'}"  # Form feed
  str="${str//\\\"/\"}"    # Quote
  str="${str//\\\\/\\}"    # Backslash

  echo "$str"
}

# JSON validation
json_validate() {
  local json="$1"

  if command -v jq >/dev/null 2>&1; then
    echo "$json" | jq empty 2>/dev/null
  else
    json_validate_basic "$json"
  fi
}

json_validate_basic() {
  local json="$1"

  # Basic validation
  [[ -z "$json" ]] && return 1

  # Check for balanced braces and brackets
  local open_braces=$(echo "$json" | grep -o '{' | wc -l)
  local close_braces=$(echo "$json" | grep -o '}' | wc -l)
  local open_brackets=$(echo "$json" | grep -o '\[' | wc -l)
  local close_brackets=$(echo "$json" | grep -o '\]' | wc -l)

  [[ $open_braces -ne $close_braces ]] && return 1
  [[ $open_brackets -ne $close_brackets ]] && return 1

  return 0
}

# JSON query functions
json_get() {
  local json="$1"
  local path="$2"
  local default="${3:-}"

  if command -v jq >/dev/null 2>&1; then
    local result=$(echo "$json" | jq -r "$path" 2>/dev/null)
    if [[ "$result" == "null" ]] || [[ -z "$result" ]]; then
      echo "$default"
    else
      echo "$result"
    fi
  else
    echo "$default"
  fi
}

json_get_array() {
  local json="$1"
  local path="$2"

  if command -v jq >/dev/null 2>&1; then
    echo "$json" | jq -r "$path[]" 2>/dev/null
  fi
}

json_get_keys() {
  local json="$1"
  local path="${2:-.}"

  if command -v jq >/dev/null 2>&1; then
    echo "$json" | jq -r "$path | keys[]" 2>/dev/null
  fi
}

json_get_values() {
  local json="$1"
  local path="${2:-.}"

  if command -v jq >/dev/null 2>&1; then
    echo "$json" | jq -r "$path | .[]" 2>/dev/null
  fi
}

json_get_type() {
  local json="$1"
  local path="${2:-.}"

  if command -v jq >/dev/null 2>&1; then
    echo "$json" | jq -r "$path | type" 2>/dev/null
  else
    json_get_type_basic "$json"
  fi
}

json_get_type_basic() {
  local value="$1"

  if [[ "$value" == "null" ]]; then
    echo "null"
  elif [[ "$value" == "true" ]] || [[ "$value" == "false" ]]; then
    echo "boolean"
  elif [[ "$value" =~ ^-?[0-9]+\.?[0-9]*$ ]]; then
    echo "number"
  elif [[ "$value" =~ ^\".*\"$ ]]; then
    echo "string"
  elif [[ "$value" =~ ^\[.*\]$ ]]; then
    echo "array"
  elif [[ "$value" =~ ^\{.*\}$ ]]; then
    echo "object"
  else
    echo "unknown"
  fi
}

# JSON manipulation
json_set() {
  local json="$1"
  local path="$2"
  local value="$3"

  if command -v jq >/dev/null 2>&1; then
    echo "$json" | jq "$path = $value"
  else
    echo "$json"
  fi
}

json_delete() {
  local json="$1"
  local path="$2"

  if command -v jq >/dev/null 2>&1; then
    echo "$json" | jq "del($path)"
  else
    echo "$json"
  fi
}

json_merge() {
  local json1="$1"
  local json2="$2"

  if command -v jq >/dev/null 2>&1; then
    echo "$json1" | jq -s ".[0] * .[1]" - <(echo "$json2")
  else
    echo "$json1"
  fi
}

# JSON pretty printing
json_pretty() {
  local json="$1"
  local indent="${2:-2}"

  if command -v jq >/dev/null 2>&1; then
    echo "$json" | jq --indent "$indent" '.'
  else
    JSON_PRETTY=1 JSON_INDENT=$indent json_format "$json"
  fi
}

json_compact() {
  local json="$1"

  if command -v jq >/dev/null 2>&1; then
    echo "$json" | jq -c '.'
  else
    echo "$json" | tr -d '\n\r\t '
  fi
}

json_format() {
  local json="$1"
  local level="${2:-0}"
  local indent_str="$(repeat ' ' $((level * JSON_INDENT)))"

  # This is a simplified formatter
  echo "$json"
}

# JSON file operations
json_read() {
  local file="$1"

  if [[ -f "$file" ]]; then
    cat "$file"
  else
    echo "{}"
  fi
}

json_write() {
  local file="$1"
  local json="$2"
  local pretty="${3:-$JSON_PRETTY}"

  if [[ $pretty -eq 1 ]]; then
    json_pretty "$json" > "$file"
  else
    echo "$json" > "$file"
  fi
}

# JSON builder functions
json_object() {
  local output="{"
  local first=1

  while [[ $# -gt 0 ]]; do
    local key="$1"
    local value="$2"
    shift 2

    [[ $first -eq 0 ]] && output+=","
    output+="$(json_encode_string "$key"):$(json_encode_auto "$value")"
    first=0
  done

  output+="}"
  echo "$output"
}

json_array() {
  local output="["
  local first=1

  for item in "$@"; do
    [[ $first -eq 0 ]] && output+=","
    output+="$(json_encode_auto "$item")"
    first=0
  done

  output+="]"
  echo "$output"
}

# JSON schema validation (basic)
json_validate_schema() {
  local json="$1"
  local schema="$2"

  if command -v jq >/dev/null 2>&1; then
    # Basic schema validation using jq
    local json_type=$(json_get_type "$json")
    local schema_type=$(json_get "$schema" ".type")

    [[ "$json_type" == "$schema_type" ]]
  else
    return 0
  fi
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

# JSON to shell variable conversion
json_to_var() {
  local json="$1"
  local var_prefix="${2:-JSON_}"

  if command -v jq >/dev/null 2>&1; then
    while IFS='=' read -r key value; do
      eval "${var_prefix}${key}=\"$value\""
    done < <(echo "$json" | jq -r 'to_entries[] | "\(.key)=\(.value)"')
  fi
}

# Shell variable to JSON conversion
var_to_json() {
  local var_prefix="$1"
  local -A data=()

  # Get all variables with prefix
  for var in ${(M)$(set -o posix; set):#${var_prefix}*}; do
    local key="${var#${var_prefix}}"
    key="${key%%=*}"
    local value="${var#*=}"
    data[$key]="$value"
  done

  json_encode_object data
}
