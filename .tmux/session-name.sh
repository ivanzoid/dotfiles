#!/bin/sh
# Print a fresh, unique tmux session name: MMDD-HHMM, with a letter suffix
# (b, c, …) appended when that minute already has a session. Shared by the ssh
# auto-attach/chooser (~/.zsh/scripts/ssh-tmux.zsh) and the Ghostty cmd+t/cmd+n
# feature (~/.hammerspoon/ghostty-remote-tabs.lua) so every new session is named
# the same way.
#
# "=$name" makes has-session match exactly, so the bare base name isn't reported
# as taken just because a suffixed one (e.g. 0717-1550b) exists.

base=$(date +%m%d-%H%M)
name=$base
suffixes=bcdefghijklmnopqrstuvwxyz
i=0
while tmux has-session -t "=$name" 2>/dev/null; do
    i=$((i + 1))
    if [ "$i" -gt 25 ]; then
        # >25 sessions in one minute (never realistically): fall back to seconds.
        name=$(date +%m%d-%H%M%S)
        break
    fi
    name="$base$(printf '%s' "$suffixes" | cut -c "$i")"
done
printf '%s' "$name"
