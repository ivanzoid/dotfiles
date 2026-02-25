# Auto-tmux on SSH only (zsh) — always offer selection when multiple sessions exist
if [[ -o interactive ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_TTY" ]] && command -v tmux >/dev/null 2>&1; then
  host="${HOST%%.*}"

  _tmux_session_rows() {
    local s meta activity win attached pid cmdline short maxlen
    maxlen=80

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

      print -r -- "$activity|$s|$win|$attached|$short"
    done
  }

  # Count existing sessions (0 if tmux server not running)
  session_count="$(tmux list-sessions -F '#S' 2>/dev/null | wc -l | tr -d ' ')"

  # If no sessions exist, start a stable default
  if [[ "$session_count" == "0" ]]; then
    exec tmux new -s main
  fi

  # If exactly one session exists, auto-attach
  if [[ "$session_count" == "1" ]]; then
    exec tmux attach
  fi

# Multiple sessions: show a chooser (requires fzf); otherwise attach to last
  if command -v fzf >/dev/null 2>&1; then
    new_session="${host}-$(date +%m%d-%H%M)"

    _tmux_menu_lines() {
      # Prints: DISPLAY<TAB>SESSION
      local s meta activity win attached pid cmdline short maxlen
      maxlen=80

      # Header-like NEW row
      printf "%-26s %-3s %-9s %s\t%s\n" "➕ NEW" "" "" "($new_session)" "__NEW__"

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

        # Nicely aligned display columns
        # (session name | win | attached | cmdline)
        printf "%-26s %-3s %-9s %s\t%s\n" "$s" "$win" "$attached" "$short" "$s"
      done
    }

    selection="$(
      _tmux_menu_lines \
      | fzf --delimiter=$'\t' \
            --with-nth=1 \
            --prompt="tmux> " \
            --height=60% --reverse \
            --preview-window='right:60%:wrap' \
            --preview=$'if [[ "{2}" == "__NEW__" ]]; then echo "Create new session:\n  '"$new_session"'"; else tmux list-windows -t {2} 2>/dev/null; echo; tmux capture-pane -pt {2} -S -80 2>/dev/null; fi'
    )"

    [[ -z "$selection" ]] && exit

    session="$(print -r -- "$selection" | cut -f2)"

    if [[ "$session" == "__NEW__" ]]; then
      exec tmux new -s "$new_session"
    else
      exec tmux attach -t "$session"
    fi
  fi

  # No fzf available -> just attach to whatever tmux picks
  exec tmux attach
fi
