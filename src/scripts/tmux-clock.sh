#!/bin/bash

# Get current time
hour=$(date +%I | sed 's/^0//')  # 12-hour format without leading zero
minute=$(date +%M)

# Determine if it's closer to the hour or half-hour
if [ "$minute" -lt 15 ]; then
    # Use hour clock
    case "$hour" in
        1)  clock="🕐" ;;
        2)  clock="🕑" ;;
        3)  clock="🕒" ;;
        4)  clock="🕓" ;;
        5)  clock="🕔" ;;
        6)  clock="🕕" ;;
        7)  clock="🕖" ;;
        8)  clock="🕗" ;;
        9)  clock="🕘" ;;
        10) clock="🕙" ;;
        11) clock="🕚" ;;
        12) clock="🕛" ;;
        *)  clock="🕐" ;;  # Default fallback
    esac
elif [ "$minute" -ge 15 ] && [ "$minute" -lt 45 ]; then
    # Use half-hour clock
    case "$hour" in
        1)  clock="🕜" ;;
        2)  clock="🕝" ;;
        3)  clock="🕞" ;;
        4)  clock="🕟" ;;
        5)  clock="🕠" ;;
        6)  clock="🕡" ;;
        7)  clock="🕢" ;;
        8)  clock="🕣" ;;
        9)  clock="🕤" ;;
        10) clock="🕥" ;;
        11) clock="🕦" ;;
        12) clock="🕧" ;;
    esac
else
    # Closer to next hour, so use next hour's clock
    next_hour=$(( (hour % 12) + 1 ))
    case "$next_hour" in
        1)  clock="🕐" ;;
        2)  clock="🕑" ;;
        3)  clock="🕒" ;;
        4)  clock="🕓" ;;
        5)  clock="🕔" ;;
        6)  clock="🕕" ;;
        7)  clock="🕖" ;;
        8)  clock="🕗" ;;
        9)  clock="🕘" ;;
        10) clock="🕙" ;;
        11) clock="🕚" ;;
        12) clock="🕛" ;;
        *)  clock="🕐" ;;  # Default fallback
    esac
fi

# Output clock emoji and time without any color
echo "${clock} $(date +%H:%M)"