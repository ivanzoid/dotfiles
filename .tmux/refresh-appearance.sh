#!/bin/bash
# Apply the current @appearance (light|dark) everywhere it shows.
#
# Called after the macOS appearance flips — either by the Mac's tint wrapper
# (~/bin/ssh) pushing the new @appearance and running this, or by the manual
# prefix+N toggle (see ~/.tmux.conf).
#
#   1. Re-color every tmux session's status bar. Each session is colored from
#      its own current pane's cwd, so per-folder hues are preserved.
#   2. Flip Claude Code's theme to match, so diffs/UI don't stay on the
#      light-mode palette at night (mosh can't carry the terminal-theme
#      protocol Claude Code would otherwise detect).

here="$(cd "$(dirname "$0")" && pwd)"
appearance=$(tmux show-options -gqv @appearance 2>/dev/null)
[[ "$appearance" == dark ]] || appearance=light   # unset/other => light

# --- 1. tmux status bar ---
tmux list-sessions -F '#{session_name}' 2>/dev/null | while read -r session; do
    path=$(tmux display-message -p -t "$session" '#{pane_current_path}' 2>/dev/null)
    [[ -n "$path" ]] || continue
    "$here/set-dir-background.sh" "$path" "$session"
done

# --- 2. Claude Code theme ---
# Swap only the light/dark prefix, preserving whatever flavor is set via /theme
# (plain, -ansi, or -daltonized). Best-effort: needs jq + an existing settings
# file, writes only when the value actually changes, and never touches anything
# but the "theme" key. Claude Code reads theme reactively, so it hot-reloads.
settings="$HOME/.claude/settings.json"
if command -v jq >/dev/null 2>&1 && [[ -f "$settings" ]]; then
    cur=$(jq -r '.theme // "light"' "$settings" 2>/dev/null)
    case "$cur" in
        *-ansi)        flavor=-ansi ;;
        *-daltonized)  flavor=-daltonized ;;
        *)             flavor= ;;
    esac
    new="${appearance}${flavor}"
    if [[ "$cur" != "$new" ]]; then
        tmp=$(mktemp "${settings}.XXXXXX") &&
            jq --arg t "$new" '.theme = $t' "$settings" >"$tmp" 2>/dev/null &&
            mv "$tmp" "$settings" || rm -f "$tmp" 2>/dev/null
    fi
fi
