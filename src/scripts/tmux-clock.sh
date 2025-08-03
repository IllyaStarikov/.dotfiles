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

# Get current hour in 24-hour format for color logic
hour_24=$(date +%H)
hour_num=$((10#$hour_24))  # Force base 10 to handle leading zeros

# Determine color based on time of day
# Night: 21:00 - 05:59 (dark blue/purple)
# Sunrise: 06:00 - 07:59 (orange)
# Day: 08:00 - 17:59 (bright yellow)
# Sunset: 18:00 - 20:59 (orange)
if [ $hour_num -ge 21 ] || [ $hour_num -lt 6 ]; then
    # Night time - dark blue
    color="#[fg=colour17]"
elif [ $hour_num -ge 6 ] && [ $hour_num -lt 8 ]; then
    # Sunrise - orange
    color="#[fg=colour208]"
elif [ $hour_num -ge 8 ] && [ $hour_num -lt 18 ]; then
    # Day time - bright yellow
    color="#[fg=colour226]"
elif [ $hour_num -ge 18 ] && [ $hour_num -lt 21 ]; then
    # Sunset - orange
    color="#[fg=colour208]"
fi

# Output clock emoji and time with color
echo "${color}${clock} $(date +%H:%M)#[default]"