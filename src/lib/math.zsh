#!/usr/bin/env zsh

# math.zsh - Advanced math operations and calculations
# Provides mathematical functions beyond basic shell arithmetic

# Basic arithmetic operations with floating point support
# =========================================================

# Add numbers (supports floating point)
add() {
  echo "$@" | awk '{sum=0; for(i=1; i<=NF; i++) sum+=$i; print sum}'
}

# Subtract numbers
subtract() {
  echo "$@" | awk '{result=$1; for(i=2; i<=NF; i++) result-=$i; print result}'
}

# Multiply numbers
multiply() {
  echo "$@" | awk '{result=1; for(i=1; i<=NF; i++) result*=$i; print result}'
}

# Divide numbers
divide() {
  local dividend="$1"
  local divisor="$2"
  local precision="${3:-2}"

  if [[ "$divisor" == "0" ]]; then
    echo "Error: Division by zero" >&2
    return 1
  fi

  printf "%.${precision}f\n" $(echo "scale=$precision; $dividend / $divisor" | bc -l 2>/dev/null || echo "$dividend $divisor" | awk '{printf "%.'"$precision"'f", $1/$2}')
}

# Modulo operation
modulo() {
  local dividend="$1"
  local divisor="$2"
  echo $((dividend % divisor))
}

# Power operation
power() {
  local base="$1"
  local exponent="$2"
  echo "$base $exponent" | awk '{print $1^$2}'
}

# Square root
sqrt() {
  local number="$1"
  local precision="${2:-2}"
  printf "%.${precision}f\n" $(echo "scale=$precision; sqrt($number)" | bc -l 2>/dev/null || echo "$number" | awk '{printf "%.'"$precision"'f", sqrt($1)}')
}

# Absolute value
abs() {
  local number="$1"
  echo "${number#-}"
}

# Round to nearest integer
round() {
  local number="$1"
  printf "%.0f\n" "$number"
}

# Floor (round down)
floor() {
  local number="$1"
  echo "$number" | awk '{print int($1)}'
}

# Ceiling (round up)
ceil() {
  local number="$1"
  echo "$number" | awk '{print int($1) + ($1 > int($1))}'
}

# Minimum value
min() {
  local min_val="$1"
  shift
  for val in "$@"; do
    if (($(echo "$val < $min_val" | bc -l 2>/dev/null || echo "$val $min_val" | awk '{print ($1 < $2)}'))); then
      min_val="$val"
    fi
  done
  echo "$min_val"
}

# Maximum value
max() {
  local max_val="$1"
  shift
  for val in "$@"; do
    if (($(echo "$val > $max_val" | bc -l 2>/dev/null || echo "$val $max_val" | awk '{print ($1 > $2)}'))); then
      max_val="$val"
    fi
  done
  echo "$max_val"
}

# Average/mean
average() {
  add "$@" | awk -v count=$# '{print $1/count}'
}

# Sum of array
sum() {
  add "$@"
}

# Product of array
product() {
  multiply "$@"
}

# Trigonometric functions
# ========================

# Sine
sin() {
  local angle="$1"
  local precision="${2:-4}"
  echo "scale=$precision; s($angle * 3.14159265359 / 180)" | bc -l 2>/dev/null || echo "$angle" | awk '{printf "%.'"$precision"'f", sin($1 * 3.14159265359 / 180)}'
}

# Cosine
cos() {
  local angle="$1"
  local precision="${2:-4}"
  echo "scale=$precision; c($angle * 3.14159265359 / 180)" | bc -l 2>/dev/null || echo "$angle" | awk '{printf "%.'"$precision"'f", cos($1 * 3.14159265359 / 180)}'
}

# Tangent
tan() {
  local angle="$1"
  local precision="${2:-4}"
  echo "$angle" | awk '{printf "%.'"$precision"'f", sin($1 * 3.14159265359 / 180) / cos($1 * 3.14159265359 / 180)}'
}

# Logarithmic functions
# ======================

# Natural logarithm
ln() {
  local number="$1"
  local precision="${2:-4}"
  echo "scale=$precision; l($number)" | bc -l 2>/dev/null || echo "$number" | awk '{printf "%.'"$precision"'f", log($1)}'
}

# Base 10 logarithm
log10() {
  local number="$1"
  local precision="${2:-4}"
  echo "scale=$precision; l($number)/l(10)" | bc -l 2>/dev/null || echo "$number" | awk '{printf "%.'"$precision"'f", log($1)/log(10)}'
}

# Logarithm with custom base
log_base() {
  local number="$1"
  local base="$2"
  local precision="${3:-4}"
  echo "scale=$precision; l($number)/l($base)" | bc -l 2>/dev/null || echo "$number $base" | awk '{printf "%.'"$precision"'f", log($1)/log($2)}'
}

# Exponential
exp() {
  local number="$1"
  local precision="${2:-4}"
  echo "scale=$precision; e($number)" | bc -l 2>/dev/null || echo "$number" | awk '{printf "%.'"$precision"'f", exp($1)}'
}

# Statistical functions
# =====================

# Median
median() {
  local -a sorted=($(printf '%s\n' "$@" | sort -n))
  local count=${#sorted[@]}

  if ((count % 2 == 0)); then
    local mid1=$((count / 2 - 1))
    local mid2=$((count / 2))
    average "${sorted[$mid1]}" "${sorted[$mid2]}"
  else
    local mid=$((count / 2))
    echo "${sorted[$mid]}"
  fi
}

# Mode (most frequent value)
mode() {
  printf '%s\n' "$@" | sort | uniq -c | sort -rn | head -1 | awk '{print $2}'
}

# Range
range() {
  local min_val=$(min "$@")
  local max_val=$(max "$@")
  subtract "$max_val" "$min_val"
}

# Variance
variance() {
  local mean=$(average "$@")
  local sum_sq_diff=0
  local count=$#

  for val in "$@"; do
    local diff=$(subtract "$val" "$mean")
    local sq_diff=$(multiply "$diff" "$diff")
    sum_sq_diff=$(add "$sum_sq_diff" "$sq_diff")
  done

  divide "$sum_sq_diff" "$count"
}

# Standard deviation
stddev() {
  local var=$(variance "$@")
  sqrt "$var"
}

# Percentage
percentage() {
  local value="$1"
  local total="$2"
  local precision="${3:-2}"

  local percent=$(divide $(multiply "$value" 100) "$total" "$precision")
  echo "$percent"
}

# Percentage change
percentage_change() {
  local old_value="$1"
  local new_value="$2"
  local precision="${3:-2}"

  local change=$(subtract "$new_value" "$old_value")
  percentage "$change" "$old_value" "$precision"
}

# Number conversions
# ==================

# Decimal to binary
dec_to_bin() {
  local decimal="$1"
  echo "obase=2; $decimal" | bc
}

# Binary to decimal
bin_to_dec() {
  local binary="$1"
  echo "ibase=2; $binary" | bc
}

# Decimal to hexadecimal
dec_to_hex() {
  local decimal="$1"
  printf "%X\n" "$decimal"
}

# Hexadecimal to decimal
hex_to_dec() {
  local hex="$1"
  echo "ibase=16; ${hex^^}" | bc
}

# Decimal to octal
dec_to_oct() {
  local decimal="$1"
  printf "%o\n" "$decimal"
}

# Octal to decimal
oct_to_dec() {
  local octal="$1"
  echo "ibase=8; $octal" | bc
}

# Random numbers
# ==============

# Random integer between min and max (inclusive)
random_int() {
  local min="${1:-0}"
  local max="${2:-100}"
  echo $((RANDOM % (max - min + 1) + min))
}

# Random float between 0 and 1
random_float() {
  local precision="${1:-4}"
  printf "%.${precision}f\n" $(echo "scale=$precision; $RANDOM / 32767" | bc -l)
}

# Random float between min and max
random_range() {
  local min="$1"
  local max="$2"
  local precision="${3:-4}"

  local random=$(random_float "$precision")
  local range=$(subtract "$max" "$min")
  local result=$(add "$min" $(multiply "$random" "$range"))
  printf "%.${precision}f\n" "$result"
}

# Geometric functions
# ===================

# Calculate hypotenuse (Pythagorean theorem)
hypotenuse() {
  local a="$1"
  local b="$2"
  sqrt $(add $(power "$a" 2) $(power "$b" 2))
}

# Calculate distance between two points
distance_2d() {
  local x1="$1"
  local y1="$2"
  local x2="$3"
  local y2="$4"

  local dx=$(subtract "$x2" "$x1")
  local dy=$(subtract "$y2" "$y1")
  hypotenuse "$dx" "$dy"
}

# Calculate area of circle
circle_area() {
  local radius="$1"
  multiply 3.14159265359 $(power "$radius" 2)
}

# Calculate circumference of circle
circle_circumference() {
  local radius="$1"
  multiply 2 3.14159265359 "$radius"
}

# Financial calculations
# ======================

# Compound interest
compound_interest() {
  local principal="$1"
  local rate="$2"
  local time="$3"
  local n="${4:-1}" # Compounding frequency (default: annually)

  local rate_decimal=$(divide "$rate" 100)
  local base=$(add 1 $(divide "$rate_decimal" "$n"))
  local exponent=$(multiply "$n" "$time")
  multiply "$principal" $(power "$base" "$exponent")
}

# Simple interest
simple_interest() {
  local principal="$1"
  local rate="$2"
  local time="$3"

  local rate_decimal=$(divide "$rate" 100)
  local interest=$(multiply "$principal" "$rate_decimal" "$time")
  add "$principal" "$interest"
}

# Factorial
factorial() {
  local n="$1"
  if [[ $n -le 1 ]]; then
    echo 1
  else
    local result=1
    for ((i = 2; i <= n; i++)); do
      result=$(multiply "$result" "$i")
    done
    echo "$result"
  fi
}

# Greatest common divisor (GCD)
gcd() {
  local a="$1"
  local b="$2"

  while [[ $b -ne 0 ]]; do
    local temp=$b
    b=$(modulo "$a" "$b")
    a=$temp
  done

  echo "$a"
}

# Least common multiple (LCM)
lcm() {
  local a="$1"
  local b="$2"

  local gcd_val=$(gcd "$a" "$b")
  divide $(multiply "$a" "$b") "$gcd_val" 0
}

# Check if number is prime
is_prime() {
  local n="$1"

  if [[ $n -le 1 ]]; then
    return 1
  fi

  if [[ $n -le 3 ]]; then
    return 0
  fi

  if [[ $(modulo "$n" 2) -eq 0 ]] || [[ $(modulo "$n" 3) -eq 0 ]]; then
    return 1
  fi

  local i=5
  local sqrt_n=$(sqrt "$n" 0)

  while [[ $i -le $sqrt_n ]]; do
    if [[ $(modulo "$n" "$i") -eq 0 ]] || [[ $(modulo "$n" $((i + 2))) -eq 0 ]]; then
      return 1
    fi
    i=$((i + 6))
  done

  return 0
}

# Fibonacci number at position n
fibonacci() {
  local n="$1"

  if [[ $n -le 0 ]]; then
    echo 0
  elif [[ $n -eq 1 ]]; then
    echo 1
  else
    local a=0
    local b=1
    for ((i = 2; i <= n; i++)); do
      local temp=$(add "$a" "$b")
      a=$b
      b=$temp
    done
    echo "$b"
  fi
}
