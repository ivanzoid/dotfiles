#!/usr/bin/env zsh
# fzf picker for tmux sessions: attach/switch to one, create a new one, or kill
# one (ctrl-x). Run via the `tmux-chooser` zsh function or the ssh auto-attach
# (~/.zsh/scripts/ssh-tmux.zsh).
#
# Exit status: 0 after attaching/switching (or tmux's own status once the
# attached client exits), 130 when the picker is cancelled, 1 on errors — the
# ssh auto-attach uses this to close the login shell only after a real detach.
#
# Internal modes, used by fzf's reload/preview/bindings:
#   --list           print the menu lines
#   --preview LINE1  print the preview for the menu line's first field
#   --kill LINE1     kill the session named by the menu line's first field

self="${0:A}"

# First field of a menu line → session name ("name[2]" → "name"; "➕" → "")
_session_of() {
  local s="${1%%[[]*}"
  [[ "$s" == "➕" ]] && s=""
  print -r -- "$s"
}

_menu_lines() {
  local s meta activity natt attached short sdir
  local -A dir_max_activity=()

  # Non-interactive zsh doesn't track the terminal width; ask the tty directly
  local cols="$COLUMNS"
  if [[ -z "$cols" ]]; then
    cols="$(stty size </dev/tty 2>/dev/null)"
    cols="${cols#* }"
  fi
  [[ "$cols" == <-> ]] && (( cols > 0 )) || cols=80

  printf '%s\n' "➕ NEW  ($TMUX_CHOOSER_NEW)"

  # First pass: find max activity per working directory
  for s in ${(f)"$(tmux list-sessions -F '#S' 2>/dev/null)"}; do
    activity="$(tmux display-message -p -t "$s" '#{session_activity}' 2>/dev/null)" || continue
    sdir="$(tmux list-panes -t "$s" -F '#{pane_current_path}' 2>/dev/null)"
    sdir="${sdir%%$'\n'*}"
    sdir="${sdir/#$HOME/~}"
    if [[ -z "${dir_max_activity[$sdir]}" ]] || (( activity > dir_max_activity[$sdir] )); then
      dir_max_activity[$sdir]="$activity"
    fi
  done

  # Second pass: build display lines with group sort key
  local -a lines=()
  for s in ${(f)"$(tmux list-sessions -F '#S' 2>/dev/null)"}; do
    meta="$(tmux display-message -p -t "$s" '#{session_activity}|#{session_attached}|#{?session_attached,attached,detached}|#{pane_current_command}' 2>/dev/null)" || continue
    activity="${meta%%|*}"; meta="${meta#*|}"
    natt="${meta%%|*}"; meta="${meta#*|}"
    attached="${meta%%|*}"; short="${meta#*|}"

    # Append client count to session name if >1
    local label="$s"
    (( natt > 1 )) && label="${s}[${natt}]"

    sdir="$(tmux list-panes -t "$s" -F '#{pane_current_path}' 2>/dev/null)"
    sdir="${sdir%%$'\n'*}"
    sdir="${sdir/#$HOME/~}"

    # Shorten attached/detached for narrower terminals
    if (( cols < 90 )); then
      [[ $attached == attached ]] && attached=a || attached=d
    elif (( cols < 120 )); then
      [[ $attached == attached ]] && attached=att || attached=det
    fi

    # Truncate path to fit
    local avail=$(( cols - 38 ))
    (( avail < 6 )) && avail=6
    local display_dir="$sdir"
    if (( ${#display_dir} > avail )); then
      display_dir="…${display_dir: -$((avail - 1))}"
    fi

    local ga="${dir_max_activity[$sdir]}"
    lines+=("$(printf '%010d %-18s %-4s %-12s %s' "$ga" "$label" "$attached" "$short" "$display_dir")")
  done

  # Sort by group activity descending, then session name ascending; strip sort key
  (( ${#lines} )) || return 0
  printf '%s\n' "${lines[@]}" | sort -k1,1rn -k2,2 | while IFS= read -r line; do
    printf '%s\n' "${line#* }"
  done
}

case "$1" in
  --list)
    _menu_lines
    exit
    ;;
  --preview)
    s="$(_session_of "$2")"
    if [[ -z "$s" ]]; then
      printf 'Create new session:\n  %s\n' "$TMUX_CHOOSER_NEW"
    else
      tmux list-windows -t "$s" 2>/dev/null
      echo
      tmux capture-pane -pt "$s" 2>/dev/null
    fi
    exit
    ;;
  --kill)
    s="$(_session_of "$2")"
    [[ -n "$s" ]] && tmux kill-session -t "=$s"
    exit 0
    ;;
esac

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux not found." >&2
  exit 1
fi

inside_tmux="${TMUX:+1}"

# If no sessions exist, start a stable default
if ! tmux has-session 2>/dev/null; then
  if [[ -n "$inside_tmux" ]]; then
    tmux new -ds main && tmux switch-client -t main
    exit
  fi
  exec tmux new -s main
fi

# No fzf available -> just attach/switch to whatever tmux picks
if ! command -v fzf >/dev/null 2>&1; then
  if [[ -n "$inside_tmux" ]]; then
    echo "No fzf available. Use: tmux switch-client -t <session>" >&2
    exit 1
  fi
  exec tmux attach
fi

# Fixed for the whole run so the NEW line, preview and result agree
export TMUX_CHOOSER_NEW="$(~/.tmux/session-name.sh)"

# ctrl-x: reload resets the cursor to the top, so re-place it on the same row
# (pos clamps, so killing the last row lands on the new last one)
selection="$(
  _menu_lines \
  | fzf --prompt="tmux> " \
        --height=60% --reverse \
        --header='enter: attach · ctrl-x: kill session' \
        --color='bg+:#d0d0e0,fg+:#202020,hl:#3060b0,hl+:#3060b0,pointer:#3060b0,prompt:#808090,header:#808090' \
        --preview-window='right:60%:follow' \
        --preview="${(q)self} --preview {1}" \
        --bind="ctrl-x:execute-silent(${(q)self} --kill {1})+transform:echo \"reload-sync(${(q)self} --list)+pos(\$(({n}+1)))\""
)"

[[ -z "$selection" ]] && exit 130

if [[ "$selection" == ➕* ]]; then
  if [[ -n "$inside_tmux" ]]; then
    tmux new -ds "$TMUX_CHOOSER_NEW" && tmux switch-client -t "$TMUX_CHOOSER_NEW"
    exit
  fi
  exec tmux new -s "$TMUX_CHOOSER_NEW"
fi

target="$(_session_of "${selection%% *}")"
if [[ -n "$inside_tmux" ]]; then
  tmux switch-client -t "=$target"
  exit
fi
exec tmux attach -t "=$target"
