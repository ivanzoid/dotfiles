#!/bin/bash
# Re-color every tmux session's status bar for the current @appearance.
#
# Called after the macOS appearance flips — either by the Mac's tint wrapper
# (~/bin/ssh) pushing the new @appearance and running this, or by the manual
# prefix+N toggle (see ~/.tmux.conf). Each session is colored from its own
# current pane's cwd, so per-folder hues are preserved across the flip.
#
# (Claude Code's theme is intentionally NOT touched here: its diff colors are
# fixed at launch and don't hot-reload, so auto-flipping only produced a
# chrome/diff mismatch. Set the CC theme yourself via /theme.)

here="$(cd "$(dirname "$0")" && pwd)"

tmux list-sessions -F '#{session_name}' 2>/dev/null | while read -r session; do
    path=$(tmux display-message -p -t "$session" '#{pane_current_path}' 2>/dev/null)
    [[ -n "$path" ]] || continue
    "$here/set-dir-background.sh" "$path" "$session"
done
