# ~/.zshrc

setopt EMACS

# Zsh
HISTSIZE=100000000
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history
setopt INC_APPEND_HISTORY EXTENDED_HISTORY SHARE_HISTORY HIST_FIND_NO_DUPS
fpath=($HOME $fpath)
autoload -Uz .zprompt && .zprompt

# Autocompletion
autoload -U compinit && compinit

# Up/down arrows completion
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

bind-updown() {
  local keymap=$1 up=$2 down=$3

  [[ -n "$up"   ]] && bindkey -M "$keymap" "$up"   history-beginning-search-backward-end
  [[ -n "$down" ]] && bindkey -M "$keymap" "$down" history-beginning-search-forward-end
}

# terminfo (preferred when correct)
bind-updown emacs "$terminfo[kcuu1]" "$terminfo[kcud1]"
bind-updown viins "$terminfo[kcuu1]" "$terminfo[kcud1]"

# ANSI arrows (most terminals + macOS + ssh)
bind-updown emacs '^[[A' '^[[B'
bind-updown viins '^[[A' '^[[B'


# Shell
export LANG='en_US.UTF-8'
export CLICOLOR=1
unset MAILCHECK

# Aliases
alias ls='ls -AhF --color=auto'

# Utils
run_cmds() {
  while IFS= read -r cmd; do
    [[ -z "$cmd" || "$cmd" =~ ^[[:space:]]*# ]] && continue
    echo "> $cmd"
    eval "$cmd"
    echo
  done
}

# zsh-z
source ~/.zsh/plugins/zsh-z/zsh-z.plugin.zsh
ZSH_CASE=smart                     # lower case patterns are treated as case insensitive
zstyle ':completion:*' menu select # improve completion menu style

[[ -d "$HOME/opt/zsh-completions" ]] && fpath=($HOME/opt/zsh-completions/src $fpath)

# >>> mamba initialize >>>
if [[ -x '/usr/local/opt/micromamba/bin/mamba' ]]; then
	export MAMBA_ROOT_PREFIX="$HOME/mamba"
	eval "$(/usr/local/bin/micromamba shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX")"
	export PATH="$HOME/mamba/bin:$PATH"
	#micromamba activate base
fi
# <<< mamba initialize <<<

