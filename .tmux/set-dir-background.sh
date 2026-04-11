#!/bin/bash
# Set tmux status bar background color based on directory path hash.
# Usage: set-dir-background.sh <path>

COLORS=(
    "#FAD7D7"  # Rose
    "#FAFAD7"  # Yellow
    "#D7FAD7"  # Green
    "#D7FAFA"  # Cyan
    "#D7D7FA"  # Blue
    "#FAD7FA"  # Purple
)

dir="$1"
[[ -z "$dir" ]] && exit 0

hash=$(printf "%s" "$dir" | md5sum | cut -c1-8)
hash=$((16#$hash))
index=$(( hash % ${#COLORS[@]} ))
color="${COLORS[$index]}"

tmux set-option status-style "bg=$color,fg=colour59"
