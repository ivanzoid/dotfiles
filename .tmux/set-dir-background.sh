#!/bin/bash
# Set tmux status bar background color based on directory path hash.
#
# The palette follows the macOS appearance mirrored into the @appearance tmux
# option (light|dark). mosh can't carry the terminal-theme protocol, so the
# Mac's ssh/mosh tint wrapper (~/bin/ssh) pushes the bit over a quick ssh on
# every dark-mode flip; unset is treated as light. Light mode uses pale pastels
# with dark text; dark mode uses hue-matched dark backgrounds with pale text, so
# the strip stays legible when Ghostty goes near-black.
#
# Usage: set-dir-background.sh <path> [target-session]

# Index-aligned palettes: same hue at the same index, light vs dark.
LIGHT_COLORS=(
    "#FAD7D7"  # Rose
    "#FAFAD7"  # Yellow
    "#D7FAD7"  # Green
    "#D7FAFA"  # Cyan
    "#D7D7FA"  # Blue
    "#FAD7FA"  # Purple
)
DARK_COLORS=(
    "#4E3338"  # Rose
    "#4A4A32"  # Yellow
    "#324A34"  # Green
    "#32474E"  # Cyan
    "#33364E"  # Blue
    "#47334E"  # Purple
)

dir="$1"
[[ -z "$dir" ]] && exit 0
target="$2"   # optional: session to color (empty = current/inferred session)

hash=$(printf "%s" "$dir" | md5sum | cut -c1-8)
hash=$((16#$hash))
index=$(( hash % ${#LIGHT_COLORS[@]} ))

# -q: no error if @appearance is unset (treated as light).
appearance=$(tmux show-options -gqv @appearance 2>/dev/null)
if [[ "$appearance" == dark ]]; then
    bg="${DARK_COLORS[$index]}"
    fg="colour250"   # pale grey — legible on the dark hue backgrounds
else
    bg="${LIGHT_COLORS[$index]}"
    fg="colour59"    # dark grey — legible on the pale pastels
fi

if [[ -n "$target" ]]; then
    tmux set-option -t "$target" status-style "bg=$bg,fg=$fg"
else
    tmux set-option status-style "bg=$bg,fg=$fg"
fi
