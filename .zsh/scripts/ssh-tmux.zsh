# Auto-tmux on SSH only (zsh) — always offer selection when multiple sessions exist
# Set NOTMUX=1 to skip: ssh -t host 'NOTMUX=1 exec zsh -l'
# Run manually anytime: tmux-chooser

# Picker lives in ~/.tmux/chooser.sh (enter: attach/switch, ctrl-x: kill session)
tmux-chooser() {
  ~/.tmux/chooser.sh "$@"
}

# Auto-attach on SSH login (skip the chooser when all sessions are busy)
_tmux_ssh_auto() {
  # Bail if tmux is missing, otherwise the exec below kills the login shell
  # and closes the SSH session (you'd be locked out of the host).
  command -v tmux >/dev/null 2>&1 || return

  # If all sessions are attached, start a new one directly
  local detached_count="$(tmux list-sessions -F '#{session_attached}' 2>/dev/null | grep -c '^0$')"
  if [[ "$detached_count" == "0" ]]; then
    exec tmux new -s "$(~/.tmux/session-name.sh)"
  fi

  # Close the login shell after a real attach+detach, like the exec paths
  # above; a cancelled picker (130) or an error drops back to the shell
  ~/.tmux/chooser.sh && exit
}

# Auto-run on SSH login
if [[ -o interactive ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_TTY" ]] && [[ -z "$NOTMUX" ]]; then
  _tmux_ssh_auto
fi
