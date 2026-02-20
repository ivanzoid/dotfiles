# ~/.zshrc

setopt EMACS

# Autocompletion
autoload -U compinit && compinit

autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "$terminfo[kcuu1]" history-beginning-search-backward-end
bindkey "$terminfo[kcud1]" history-beginning-search-forward-end

HISTSIZE=100000000
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history
setopt INC_APPEND_HISTORY EXTENDED_HISTORY SHARE_HISTORY HIST_FIND_NO_DUPS

unset MAILCHECK

fpath=($HOME $fpath)
autoload -Uz .zprompt && .zprompt

alias ls='ls -AhF'
alias mvim='vim -g'

# zsh-z
source ~/.zsh/plugins/zsh-z/zsh-z.plugin.zsh
ZSH_CASE=smart                     # lower case patterns are treated as case insensitive
zstyle ':completion:*' menu select # improve completion menu style

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

if [[ -d "$HOME/.rd" ]]; then
### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="$HOME/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
fi

if [[ -d "$HOME/.dart-cli-completion" ]]; then
## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f "$HOME/.dart-cli-completion/zsh-config.zsh" ]] && . "$HOME/.dart-cli-completion/zsh-config.zsh" || true
## [/Completion]
fi

if command -v mise >/dev/null 2>&1; then
	eval "$(mise activate zsh)"
fi
