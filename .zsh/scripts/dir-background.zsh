# Set tmux status bar color based on working directory.
# Uses chpwd hook for instant feedback on cd;
# tmux hooks (configured in .tmux.conf) handle pane/window switches
# using #{pane_current_path} to track the frontmost process's cwd.

[[ -z "$TMUX" ]] && return
[[ ! -x "$HOME/.tmux/set-dir-background.sh" ]] && return

_dir_bg_chpwd() {
    ~/.tmux/set-dir-background.sh "$PWD"
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _dir_bg_chpwd

# Set on shell startup
_dir_bg_chpwd
