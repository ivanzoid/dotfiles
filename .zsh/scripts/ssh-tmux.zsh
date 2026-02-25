# Auto-tmux on SSH only (zsh)
if [[ -o interactive ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_TTY" ]] && command -v tmux >/dev/null 2>&1; then
  host="${HOST%%.*}"

  # Rows: activity_epoch|session|windows|attached|cmdline(truncated)
  _tmux_session_rows() {
    local s meta activity win attached pid cmdline short maxlen
    maxlen=80

    for s in ${(f)"$(tmux list-sessions -F '#S' 2>/dev/null)"}; do
      meta="$(tmux display-message -p -t "$s" '#{session_activity}|#{session_windows}|#{?session_attached,attached,detached}|#{pane_pid}' 2>/dev/null)"
      activity="${meta%%|*}"; meta="${meta#*|}"
      win="${meta%%|*}"; meta="${meta#*|}"
      attached="${meta%%|*}"; pid="${meta#*|}"

      cmdline="$(ps -o args= -p "$pid" 2>/dev/null || ps -o command= -p "$pid" 2>/dev/null)"
      cmdline="${cmdline#"${cmdline%%[![:space:]]*}"}"
      cmdline="${cmdline%"${cmdline##*[![:space:]]}"}"

      if (( ${#cmdline} > maxlen )); then
        short="${cmdline[1,maxlen]}…"
      else
        short="$cmdline"
      fi

      print -r -- "$activity|$s|$win|$attached|$short"
    done
  }

  if [[ -n "$TMUX_ATTACH" ]]; then
    if tmux has-session 2>/dev/null; then
      if [[ "$(tmux list-sessions 2>/dev/null | wc -l | tr -d ' ')" == "1" ]]; then
        exec tmux attach
      fi

      if command -v fzf >/dev/null 2>&1; then
        selection="$(
          _tmux_session_rows \
          | sort -t'|' -k1,1nr \
          | fzf --delimiter='|' \
                --with-nth=2,3,4,5 \
                --prompt="tmux attach> " \
                --height=60% --reverse \
                --preview-window='right:60%:wrap' \
                --preview=$'tmux list-windows -t {2} 2>/dev/null; echo; tmux capture-pane -pt {2} -S -80 2>/dev/null'
        )"
        session="${selection#*|}"; session="${session%%|*}"
        [[ -n "$session" ]] && exec tmux attach -t "$session"
      fi

      exec tmux attach
    fi

    exec tmux new -s main
  else
    session="ssh-${host}-$(date +%Y%m%d-%H%M%S)-$$"
    exec tmux new -s "$session"
  fi
fi
