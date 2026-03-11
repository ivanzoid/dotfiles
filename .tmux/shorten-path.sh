#!/bin/bash
# Shorten a path for tmux status bar: ~/projects/very/deep/nested/dir → ~/projects/…/nested/dir
max=30
p="${1/#$HOME/\~}"
if [[ ${#p} -le $max ]]; then
  echo "$p"
else
  # Split into segments, drop middle ones until it fits
  IFS='/' read -ra parts <<< "$p"
  n=${#parts[@]}
  # Keep first 2 and last 2 segments, join with …
  head="${parts[0]}/${parts[1]}"
  tail="${parts[$((n-2))]}/${parts[$((n-1))]}"
  result="$head/…/$tail"
  # If still too long or only 3-4 segments, just hard-truncate
  if [[ ${#result} -gt $max || $n -le 3 ]]; then
    half=$(( (max - 1) / 2 ))
    result="${p:0:$half}…${p: -$half}"
  fi
  echo "$result"
fi
