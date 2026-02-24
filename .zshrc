# ~/.zshrc

#echo ".zshrc read"

# Zsh
HISTSIZE=100000000
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history
setopt INC_APPEND_HISTORY EXTENDED_HISTORY SHARE_HISTORY HIST_FIND_NO_DUPS
fpath=($HOME $fpath)
autoload -Uz .zprompt && .zprompt

setopt EMACS

# Autocompletion
autoload -U compinit && compinit

zmodload zsh/terminfo

# Up/down arrows completion
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "$terminfo[Up]" history-beginning-search-backward-end
bindkey "$terminfo[Down]" history-beginning-search-forward-end


# Shell
export LANG='en_US.UTF-8'
export CLICOLOR=1
unset MAILCHECK

# Aliases
alias ls='ls -AhF'

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

