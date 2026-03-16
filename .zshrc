# ~/.zshrc

setopt EMACS

# Zsh
HISTSIZE=100000000
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history
setopt INC_APPEND_HISTORY EXTENDED_HISTORY SHARE_HISTORY HIST_FIND_NO_DUPS
fpath=($HOME $fpath)
autoload -Uz .zprompt && .zprompt

# git me completion (remote branch names)
_git-me() {
  local -a branches
  branches=(${(f)"$(git branch -r --format='%(refname:short)' 2>/dev/null | sed 's|^origin/||' | grep -v '^HEAD')"})
  _describe 'branch' branches
}

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
alias ls='ls -h --color=auto'
alias ll='ls -l'	# hide hidden files, details format (table)
alias l1='ls -1'	# hide hidden files, short format (single column)
alias l='ls -A'		# all files, short format (multi-columns)
alias la='ls -lA'	# all files, details format (table)
alias g='git'
compdef g=git

# Utils
run_cmds() {
  while IFS= read -r cmd; do
    [[ -z "$cmd" || "$cmd" =~ ^[[:space:]]*# ]] && continue
    echo "> $cmd"
    eval "$cmd"
    echo
  done
}

check_uncommited_changes_in() {
    local dir=$1
    pushd "$dir" >/dev/null 2>&1
    if ! git diff --quiet HEAD; then
        echo "Uncommitted changes in $dir:"
        git status -s
    fi
    popd >/dev/null 2>&1
}

[[ -d ~/bin ]] && check_uncommited_changes_in ~/bin
[[ -d ~/private ]] && check_uncommited_changes_in ~/private
[[ -d ~/dotfiles ]] && check_uncommited_changes_in ~/dotfiles

# SSH tmux auto-attach & chooser
[[ -r "$HOME/.zsh/scripts/ssh-tmux.zsh" ]] && source "$HOME/.zsh/scripts/ssh-tmux.zsh"

# zsh-z
source ~/.zsh/plugins/zsh-z/zsh-z.plugin.zsh
ZSH_CASE=smart                     # lower case patterns are treated as case insensitive
zstyle ':completion:*' menu select # improve completion menu style

# zsh-completions
[[ -d "$HOME/opt/zsh-completions" ]] && fpath=($HOME/opt/zsh-completions/src $fpath)

# >>> mamba initialize >>>
if [[ -x '/usr/local/opt/micromamba/bin/mamba' ]]; then
	export MAMBA_ROOT_PREFIX="$HOME/mamba"
	eval "$(/usr/local/bin/micromamba shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX")"
	export PATH="$HOME/mamba/bin:$PATH"
	#micromamba activate base
fi
# <<< mamba initialize <<<

