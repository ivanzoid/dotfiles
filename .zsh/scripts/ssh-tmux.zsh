# Auto-tmux on SSH only (zsh) — always offer selection when multiple sessions exist
if [[ -o interactive ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_TTY" ]] && command -v tmux >/dev/null 2>&1; then
  host="${HOST%%.*}"

  # Count existing sessions (0 if tmux server not running)
  session_count="$(tmux list-sessions -F '#S' 2>/dev/null | wc -l | tr -d ' ')"

  # If no sessions exist, start a stable default
  if [[ "$session_count" == "0" ]]; then
    exec tmux new -s main
  fi

  # If all sessions are attached, start a new one
  detached_count="$(tmux list-sessions -F '#{session_attached}' 2>/dev/null | grep -c '^0$')"
  if [[ "$detached_count" == "0" ]]; then
    exec tmux new -s "${host}-$(date +%m%d-%H%M)"
  fi

  # Detached sessions exist: show a chooser (requires fzf); otherwise attach to last
  if command -v fzf >/dev/null 2>&1; then
    new_session="${host}-$(date +%m%d-%H%M)"

    _tmux_menu_lines() {
      local s meta activity win attached pid cmdline short maxlen
      maxlen=80

      printf "%-300s\n" "➕ NEW  ($new_session)"

      for s in ${(f)"$(tmux list-sessions -F '#S' 2>/dev/null)"}; do
        meta="$(tmux display-message -p -t "$s" '#{session_activity}|#{session_windows}|#{?session_attached,attached,detached}|#{pane_pid}' 2>/dev/null)" || continue
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

        printf "%-300s\n" "$(printf '%-26s %-3s %-9s %s' "$s" "$win" "$attached" "$short")"
      done
    }

    selection="$(
      _tmux_menu_lines \
      | fzf --prompt="tmux> " \
            --height=60% --reverse \
            --color='bg+:#d0d0e0,fg+:#202020,hl:#3060b0,hl+:#3060b0,pointer:#3060b0,prompt:#808090' \
            --preview-window='right:60%:wrap' \
            --preview=$'s={1}; if [[ "$s" == "➕" ]]; then echo "Create new session:\n  '"$new_session"'"; else tmux list-windows -t "$s" 2>/dev/null; echo; tmux capture-pane -pt "$s" -S -80 2>/dev/null; fi'
    )"

    [[ -z "$selection" ]] && exit

    if [[ "$selection" == ➕* ]]; then
      exec tmux new -s "$new_session"
    else
      exec tmux attach -t "$session"
    fi
  fi

  # No fzf available -> just attach to whatever tmux picks
  exec tmux attach
fi
