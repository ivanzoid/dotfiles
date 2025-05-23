#!/bin/bash
#
# .profile
# vim:expandtab
#

if [[ $- != *i* ]] ; then
	# Shell is non-interactive. Be done now!
	return
fi

if [ -n "$BASH_VERSION" ]; then
	if [ -f "$HOME/.bashrc" ]; then
		. "$HOME/.bashrc"
	fi
fi

#============================================================================
# Functions
#============================================================================

program_exists () {
	type "$1" &> /dev/null ;
}

check_uncommited_changes_in() {
    pushd "$1" >/dev/null 2>&1
    git diff --quiet HEAD
    if [ $? -ne 0 ]; then
        echo "Uncommited changes in $1:"
        git status -s
    fi
    popd >/dev/null 2>&1
}

is_osx() {
	if [[ $OSTYPE == darwin* ]]; then
		return 0
	else
		return 1
	fi
}

is_linux() {
	if [[ $OSTYPE == linux* ]]; then
		return 0
	else
		return 1
	fi
}

#============================================================================
# Exports
#============================================================================

if [ -x /usr/libexec/java_home ]; then
    export JAVA_HOME=$(/usr/libexec/java_home >/dev/null 2>&1)
fi

if [ -d /usr/local/opt/android-sdk ]; then
	export ANDROID_HOME=/usr/local/opt/android-sdk
fi

# Homebrew
if [ -d /usr/local/bin ]; then
	export PATH=/usr/local/bin:$PATH
fi

if [ -d /usr/local/sbin ]; then
	export PATH=/usr/local/sbin:$PATH
fi

if [ -d ~/bin ]; then
	export PATH=~/bin:$PATH

    check_uncommited_changes_in ~/bin
fi

if [ -d ~/private/bin ]; then
	export PATH=~/private/bin:$PATH
fi

if [ -d ~/private ]; then
    check_uncommited_changes_in ~/private
fi

# Docker
if program_exists docker; then
    export DOCKER_HOST=tcp://localhost:4243
fi


# Go
if [ -f .go.conf ]; then
    source .go.conf
else
    export GOPATH="$HOME/go"
fi

if [ -n "$GOPATH" ] && [ -d "$GOPATH/bin" ]; then
    PATH="$GOPATH/bin":$PATH
fi

if [ -n "/usr/local/opt/go/libexec/bin" ]; then
    export PATH=$PATH:/usr/local/opt/go/libexec/bin
fi


if [ -n "$HOME/.fastlane/bin" ]; then
    export PATH="$PATH:$HOME/.fastlane/bin"
fi


export LANG='en_US.UTF-8'
export EDITOR="vim -g -f"
export VISUAL=$EDITOR

# VSCode
if is_osx; then
    VSCODE="/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    if [ -n "$VSCODE" ]; then
        export PATH="$PATH:$VSCODE"
   fi
fi


#============================================================================
# Aliases
#============================================================================

if is_osx; then
	export CLICOLOR=1
	alias ls='ls -hF'
    alias mvim='vim -g'

elif is_linux; then
	alias ls='ls -hF --color=auto'
	MD5=md5sum
fi

#if program_exists rmtrash; then
#	alias rm=rmtrash
#fi

# Git
#
# Display unstaged (*) and staged(+) changes
#export GIT_PS1_SHOWDIRTYSTATE="1"
# Display if there are untracked (%) files
#export GIT_PS1_SHOWUNTRACKEDFILES="1"

#============================================================================
# Bash settings
#============================================================================

shopt -s histappend
export HISTSIZE=10000000
export HISTTIMEFORMAT="%F %T"
export PROMPT_COMMAND='history -a; history -n; echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'


function setPS1() {
	# Reset
	local Reset='\[\e[0m\]'             # Text Reset

	# Regular s
	local Black='\[\e[0;30m\]'        # Black
	local Red='\[\e[0;31m\]'          # Red
	local Green='\[\e[0;32m\]'        # Green
	local Yellow='\[\e[0;33m\]'       # Yellow
	local Blue='\[\e[0;34m\]'         # Blue
	local Purple='\[\e[0;35m\]'       # Purple
	local Cyan='\[\e[0;36m\]'         # Cyan
	local White='\[\e[0;37m\]'        # White

	# Bold
	local BBlack='\[\e[1;30m\]'       # Black
	local BRed='\[\e[1;31m\]'         # Red
	local BGreen='\[\e[1;32m\]'       # Green
	local BYellow='\[\e[1;33m\]'      # Yellow
	local BBlue='\[\e[1;34m\]'        # Blue
	local BPurple='\[\e[1;35m\]'      # Purple
	local BCyan='\[\e[1;36m\]'        # Cyan
	local BWhite='\[\e[1;37m\]'       # White

	# Underline
	local UBlack='\[\e[4;30m\]'       # Black
	local URed='\[\e[4;31m\]'         # Red
	local UGreen='\[\e[4;32m\]'       # Green
	local UYellow='\[\e[4;33m\]'      # Yellow
	local UBlue='\[\e[4;34m\]'        # Blue
	local UPurple='\[\e[4;35m\]'      # Purple
	local UCyan='\[\e[4;36m\]'        # Cyan
	local UWhite='\[\e[4;37m\]'       # White

	# Background
	local BgBlack='\[\e[40m\]'       # Black
	local BgRed='\[\e[41m\]'         # Red
	local BgGreen='\[\e[42m\]'       # Green
	local BgYellow='\[\e[43m\]'      # Yellow
	local BgBlue='\[\e[44m\]'        # Blue
	local BgPurple='\[\e[45m\]'      # Purple
	local BgCyan='\[\e[46m\]'        # Cyan
	local BgWhite='\[\e[47m\]'       # White

	# High Intensty
	local IBlack='\[\e[0;90m\]'       # Black
	local IRed='\[\e[0;91m\]'         # Red
	local IGreen='\[\e[0;92m\]'       # Green
	local IYellow='\[\e[0;93m\]'      # Yellow
	local IBlue='\[\e[0;94m\]'        # Blue
	local IPurple='\[\e[0;95m\]'      # Purple
	local ICyan='\[\e[0;96m\]'        # Cyan
	local IWhite='\[\e[0;97m\]'       # White

	# Bold High Intensty
	local BIBlack='\[\e[1;90m\]'      # Black
	local BIRed='\[\e[1;91m\]'        # Red
	local BIGreen='\[\e[1;92m\]'      # Green
	local BIYellow='\[\e[1;93m\]'     # Yellow
	local BIBlue='\[\e[1;94m\]'       # Blue
	local BIPurple='\[\e[1;95m\]'     # Purple
	local BICyan='\[\e[1;96m\]'       # Cyan
	local BIWhite='\[\e[1;97m\]'      # White

	# High Intensty backgrounds
	local BgIBlack='\[\e[0;100m\]'   # Black
	local BgIRed='\[\e[0;101m\]'     # Red
	local BgIGreen='\[\e[0;102m\]'   # Green
	local BgIYellow='\[\e[0;103m\]'  # Yellow
	local BgIBlue='\[\e[0;104m\]'    # Blue
	local BgIPurple='\[\e[10;95m\]'  # Purple
	local BgICyan='\[\e[0;106m\]'    # Cyan
	local BgIWhite='\[\e[0;107m\]'   # White

	local ColorArray=($BRed $BGreen $BYellow $BPurple $BCyan $BRed $BGreen $BYellow $BPurple $BCyan)
	local ColorForHost=${ColorArray[$(echo "${USER}@${HOSTNAME}" | $MD5 | sed s/[abcdef]*// | head -c 1)]}

    local GitStatus=""
    if [ -f /usr/local/opt/git/etc/bash_completion.d/git-prompt.sh ]; then
        source /usr/local/opt/git/etc/bash_completion.d/git-prompt.sh 
        local GitStatus='$(__git_ps1 " (%s)")'
    fi

	export PS1="\n${BBlue}\u${Reset}:${ColorForHost}\h${BGreen}${GitStatus}${BBlue} \w\n\$${Reset} "
}

setPS1


# Setup ~/.launchd.conf if needed
if is_osx && [ ! -f "$HOME/.launchd.conf" ] && [ -x update-launchd-conf ]; then
    update-launchd-conf
fi


# Homebrew
if program_exists brew; then
	BREW_PREFIX=`brew --prefix`

    if [ -f $BREW_PREFIX/etc/bash_completion.d/git-completion.bash ]; then
        . $BREW_PREFIX/etc/bash_completion.d/git-completion.bash
    fi

	if [ -f $BREW_PREFIX/Library/Contributions/brew_bash_completion.sh ]; then
		. $BREW_PREFIX/Library/Contributions/brew_bash_completion.sh
	fi
fi

if [ -d ~/dotfiles ]; then
    check_uncommited_changes_in ~/dotfiles
fi


# Nodenv
eval "$(nodenv init -)"

