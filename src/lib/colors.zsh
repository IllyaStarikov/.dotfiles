#!/usr/bin/env zsh

# colors.zsh - Comprehensive color library for terminal output
# Supports 16-color, 256-color, and true color (24-bit) modes

# Basic color codes (16-color palette)
readonly -A COLORS=(
  # Foreground colors
  [BLACK]='\033[30m'
  [RED]='\033[31m'
  [GREEN]='\033[32m'
  [YELLOW]='\033[33m'
  [BLUE]='\033[34m'
  [MAGENTA]='\033[35m'
  [CYAN]='\033[36m'
  [WHITE]='\033[37m'
  [DEFAULT]='\033[39m'

  # Bright foreground colors
  [BRIGHT_BLACK]='\033[90m'
  [BRIGHT_RED]='\033[91m'
  [BRIGHT_GREEN]='\033[92m'
  [BRIGHT_YELLOW]='\033[93m'
  [BRIGHT_BLUE]='\033[94m'
  [BRIGHT_MAGENTA]='\033[95m'
  [BRIGHT_CYAN]='\033[96m'
  [BRIGHT_WHITE]='\033[97m'

  # Background colors
  [BG_BLACK]='\033[40m'
  [BG_RED]='\033[41m'
  [BG_GREEN]='\033[42m'
  [BG_YELLOW]='\033[43m'
  [BG_BLUE]='\033[44m'
  [BG_MAGENTA]='\033[45m'
  [BG_CYAN]='\033[46m'
  [BG_WHITE]='\033[47m'
  [BG_DEFAULT]='\033[49m'

  # Bright background colors
  [BG_BRIGHT_BLACK]='\033[100m'
  [BG_BRIGHT_RED]='\033[101m'
  [BG_BRIGHT_GREEN]='\033[102m'
  [BG_BRIGHT_YELLOW]='\033[103m'
  [BG_BRIGHT_BLUE]='\033[104m'
  [BG_BRIGHT_MAGENTA]='\033[105m'
  [BG_BRIGHT_CYAN]='\033[106m'
  [BG_BRIGHT_WHITE]='\033[107m'
)

# Text style codes
readonly -A STYLES=(
  [RESET]='\033[0m'
  [BOLD]='\033[1m'
  [DIM]='\033[2m'
  [ITALIC]='\033[3m'
  [UNDERLINE]='\033[4m'
  [BLINK]='\033[5m'
  [REVERSE]='\033[7m'
  [HIDDEN]='\033[8m'
  [STRIKETHROUGH]='\033[9m'

  # Reset individual styles
  [NO_BOLD]='\033[21m'
  [NO_DIM]='\033[22m'
  [NO_ITALIC]='\033[23m'
  [NO_UNDERLINE]='\033[24m'
  [NO_BLINK]='\033[25m'
  [NO_REVERSE]='\033[27m'
  [NO_HIDDEN]='\033[28m'
  [NO_STRIKETHROUGH]='\033[29m'
)

# Special color aliases for common use cases
readonly -A COLOR_ALIASES=(
  [SUCCESS]="${COLORS[GREEN]}"
  [ERROR]="${COLORS[RED]}"
  [WARNING]="${COLORS[YELLOW]}"
  [INFO]="${COLORS[CYAN]}"
  [DEBUG]="${COLORS[BRIGHT_BLACK]}"
  [PRIMARY]="${COLORS[BLUE]}"
  [SECONDARY]="${COLORS[MAGENTA]}"
  [MUTED]="${COLORS[BRIGHT_BLACK]}"
)

# Get 256-color code
color256() {
  local color_num="$1"
  local is_bg="${2:-0}"

  if [[ $color_num -lt 0 || $color_num -gt 255 ]]; then
    echo "Invalid color number: $color_num (must be 0-255)" >&2
    return 1
  fi

  if [[ $is_bg -eq 1 ]]; then
    echo "\033[48;5;${color_num}m"
  else
    echo "\033[38;5;${color_num}m"
  fi
}

# Get RGB true color (24-bit)
rgb() {
  local r="$1"
  local g="$2"
  local b="$3"
  local is_bg="${4:-0}"

  # Validate RGB values
  for val in $r $g $b; do
    if [[ $val -lt 0 || $val -gt 255 ]]; then
      echo "Invalid RGB value: $val (must be 0-255)" >&2
      return 1
    fi
  done

  if [[ $is_bg -eq 1 ]]; then
    echo "\033[48;2;${r};${g};${b}m"
  else
    echo "\033[38;2;${r};${g};${b}m"
  fi
}

# Convert hex color to RGB
hex_to_rgb() {
  local hex="${1#\#}" # Remove # if present

  if [[ ${#hex} -ne 6 ]]; then
    echo "Invalid hex color: $1 (must be 6 digits)" >&2
    return 1
  fi

  local r=$((16#${hex:0:2}))
  local g=$((16#${hex:2:2}))
  local b=$((16#${hex:4:2}))

  echo "$r $g $b"
}

# Apply color to text
colorize() {
  local color="$1"
  shift
  local text="$*"

  # Check if color is in our predefined colors
  if [[ -n "${COLORS[$color]}" ]]; then
    echo -e "${COLORS[$color]}${text}${STYLES[RESET]}"
  elif [[ -n "${COLOR_ALIASES[$color]}" ]]; then
    echo -e "${COLOR_ALIASES[$color]}${text}${STYLES[RESET]}"
  else
    echo -e "${color}${text}${STYLES[RESET]}"
  fi
}

# Apply style to text
stylize() {
  local style="$1"
  shift
  local text="$*"

  if [[ -n "${STYLES[$style]}" ]]; then
    echo -e "${STYLES[$style]}${text}${STYLES[RESET]}"
  else
    echo "$text"
  fi
}

# Rainbow text effect
rainbow() {
  local text="$1"
  local colors=(RED YELLOW GREEN CYAN BLUE MAGENTA)
  local result=""
  local color_index=0

  for ((i = 0; i < ${#text}; i++)); do
    local char="${text:$i:1}"
    if [[ "$char" != " " ]]; then
      result+="${COLORS[${colors[$color_index]}]}${char}"
      color_index=$(((color_index + 1) % ${#colors[@]}))
    else
      result+=" "
    fi
  done

  echo -e "${result}${STYLES[RESET]}"
}

# Gradient effect (requires 256-color support)
gradient() {
  local text="$1"
  local start_color="${2:-196}" # Red
  local end_color="${3:-21}"    # Blue
  local length=${#text}
  local result=""

  for ((i = 0; i < length; i++)); do
    local char="${text:$i:1}"
    local progress=$(((i * 100) / length))
    local color=$((start_color + ((end_color - start_color) * progress / 100)))
    result+="$(color256 $color)${char}"
  done

  echo -e "${result}${STYLES[RESET]}"
}

# Strip ANSI color codes from text
strip_colors() {
  local text="$1"
  echo "$text" | sed 's/\x1b\[[0-9;]*m//g'
}

# Check if terminal supports colors
supports_colors() {
  if [[ -t 1 ]] && [[ -n "${TERM}" ]] && [[ "${TERM}" != "dumb" ]]; then
    return 0
  else
    return 1
  fi
}

# Check if terminal supports 256 colors
supports_256_colors() {
  if [[ "${TERM}" == *"256color"* ]] || [[ "${COLORTERM}" == *"256"* ]]; then
    return 0
  else
    return 1
  fi
}

# Check if terminal supports true color (24-bit)
supports_true_color() {
  if [[ "${COLORTERM}" == "truecolor" ]] || [[ "${COLORTERM}" == "24bit" ]]; then
    return 0
  else
    return 1
  fi
}

# Print color palette (16 colors)
show_palette() {
  echo "Basic 16-color palette:"
  for color in BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
    echo -e "${COLORS[$color]}■■■ ${color}${STYLES[RESET]}"
  done
  echo
  for color in BRIGHT_BLACK BRIGHT_RED BRIGHT_GREEN BRIGHT_YELLOW BRIGHT_BLUE BRIGHT_MAGENTA BRIGHT_CYAN BRIGHT_WHITE; do
    echo -e "${COLORS[$color]}■■■ ${color}${STYLES[RESET]}"
  done
}

# Print 256-color palette
show_256_palette() {
  echo "256-color palette:"
  for i in {0..255}; do
    printf "$(color256 "$i")%3d${STYLES[RESET]}" "$i"
    if (((i + 1) % 16 == 0)); then
      echo
    else
      printf " "
    fi
  done
}

# Print style examples
show_styles() {
  echo "Text styles:"
  for style in BOLD DIM ITALIC UNDERLINE BLINK REVERSE STRIKETHROUGH; do
    echo -e "${STYLES[$style]}${style}${STYLES[RESET]}"
  done
}

# Theme colors based on popular color schemes
readonly -A NORD=(
  [POLAR_NIGHT_1]="$(rgb 46 52 64)"
  [POLAR_NIGHT_2]="$(rgb 59 66 82)"
  [POLAR_NIGHT_3]="$(rgb 67 76 94)"
  [POLAR_NIGHT_4]="$(rgb 76 86 106)"
  [SNOW_STORM_1]="$(rgb 216 222 233)"
  [SNOW_STORM_2]="$(rgb 229 233 240)"
  [SNOW_STORM_3]="$(rgb 236 239 244)"
  [FROST_1]="$(rgb 143 188 187)"
  [FROST_2]="$(rgb 136 192 208)"
  [FROST_3]="$(rgb 129 161 193)"
  [FROST_4]="$(rgb 94 129 172)"
  [AURORA_RED]="$(rgb 191 97 106)"
  [AURORA_ORANGE]="$(rgb 208 135 112)"
  [AURORA_YELLOW]="$(rgb 235 203 139)"
  [AURORA_GREEN]="$(rgb 163 190 140)"
  [AURORA_PURPLE]="$(rgb 180 142 173)"
)

readonly -A DRACULA=(
  [BACKGROUND]="$(rgb 40 42 54)"
  [CURRENT_LINE]="$(rgb 68 71 90)"
  [FOREGROUND]="$(rgb 248 248 242)"
  [COMMENT]="$(rgb 98 114 164)"
  [CYAN]="$(rgb 139 233 253)"
  [GREEN]="$(rgb 80 250 123)"
  [ORANGE]="$(rgb 255 184 108)"
  [PINK]="$(rgb 255 121 198)"
  [PURPLE]="$(rgb 189 147 249)"
  [RED]="$(rgb 255 85 85)"
  [YELLOW]="$(rgb 241 250 140)"
)
