# Auto-tmux on SSH only (zsh) — always offer selection when multiple sessions exist
# Set NOTMUX=1 to skip: ssh -t host 'NOTMUX=1 exec zsh -l'
# Run manually anytime: tmux-chooser

tmux-chooser() {
  if ! command -v tmux >/dev/null 2>&1; then
    echo "tmux not found." >&2
    return 1
  fi

  local inside_tmux="${TMUX:+1}"
  local host="${HOST%%.*}"

  # Count existing sessions (0 if tmux server not running)
  local session_count="$(tmux list-sessions -F '#S' 2>/dev/null | wc -l | tr -d ' ')"

  # If no sessions exist, start a stable default
  if [[ "$session_count" == "0" ]]; then
    if [[ -n "$inside_tmux" ]]; then
      tmux new -ds main && tmux switch-client -t main
    else
      exec tmux new -s main
    fi
    return
  fi

  # Detached sessions exist: show a chooser (requires fzf); otherwise attach to last
  if command -v fzf >/dev/null 2>&1; then
    local new_session="${host}-$(date +%m%d-%H%M%S)"

    _tmux_menu_lines() {
      local s meta activity natt attached short sdir
      local -A dir_max_activity=()

      printf '%s\n' "➕ NEW  ($new_session)"

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
        local cols="${COLUMNS:-80}"
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
      printf '%s\n' "${lines[@]}" | sort -k1,1rn -k2,2 | while IFS= read -r line; do
        printf '%s\n' "${line#* }"
      done
    }

    local selection="$(
      _tmux_menu_lines \
      | fzf --prompt="tmux> " \
            --height=60% --reverse \
            --color='bg+:#d0d0e0,fg+:#202020,hl:#3060b0,hl+:#3060b0,pointer:#3060b0,prompt:#808090' \
            --preview-window='right:60%:follow' \
            --preview=$'s={1}; s="${s%%[[]*}"; if [[ "$s" == "➕" ]]; then echo "Create new session:\n  '"$new_session"'"; else tmux list-windows -t "$s" 2>/dev/null; echo; echo "$(tmux capture-pane -pt "$s" 2>/dev/null)"; fi'
    )"

    [[ -z "$selection" ]] && return 0

    if [[ "$selection" == ➕* ]]; then
      if [[ -n "$inside_tmux" ]]; then
        tmux new -ds "$new_session" && tmux switch-client -t "$new_session"
      else
        exec tmux new -s "$new_session"
      fi
    else
      local target="${selection%% *}"
      target="${target%%[[]*}"
      if [[ -n "$inside_tmux" ]]; then
        tmux switch-client -t "$target"
      else
        exec tmux attach -t "$target"
      fi
    fi
    return
  fi

  # No fzf available -> just attach/switch to whatever tmux picks
  if [[ -n "$inside_tmux" ]]; then
    echo "No fzf available. Use: tmux switch-client -t <session>" >&2
    return 1
  fi
  exec tmux attach
}

# Auto-attach on SSH login (skip the chooser when all sessions are busy)
_tmux_ssh_auto() {
  local host="${HOST%%.*}"

  # If all sessions are attached, start a new one directly
  local detached_count="$(tmux list-sessions -F '#{session_attached}' 2>/dev/null | grep -c '^0$')"
  if [[ "$detached_count" == "0" ]]; then
    exec tmux new -s "${host}-$(date +%m%d-%H%M%S)"
  fi

  tmux-chooser
}

# Auto-run on SSH login
if [[ -o interactive ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_TTY" ]] && [[ -z "$NOTMUX" ]]; then
  _tmux_ssh_auto
fi
