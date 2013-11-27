#!/bin/bash
#
# .profile
#

if [[ $- != *i* ]] ; then
	# Shell is non-interactive. Be done now!
	return
fi

# Include .bashrc if needed
if [ -n "$BASH_VERSION" ]; then
	if [ -f "$HOME/.bashrc" ]; then
		. "$HOME/.bashrc"
	fi
fi

# Add homebrew/macports
if [ -d /usr/local/bin ]; then
	export PATH=/usr/local/bin:$PATH
fi

if [ -d /usr/local/sbin ]; then
	export PATH=/usr/local/sbin:$PATH
fi

program_exists () {
	type "$1" &> /dev/null ;
}

# Add ~/alac-utils
if [ -d ~/alac-utils ]; then
	export PATH=~/alac-utils:$PATH
fi

# Add ~/bin
if [ -d ~/bin ]; then
	export PATH=~/bin:$PATH
fi

# Add ~/private/bin
if [ -d ~/private/bin ]; then
	export PATH=~/private/bin:$PATH
fi

if [ -d /usr/local/opt/android-sdk ]; then
	export ANDROID_HOME=/usr/local/opt/android-sdk
fi

#
# Exports
#

export LANG='en_US.UTF-8'

# set editor
if program_exists mvim; then
	export EDITOR="mvim --nofork -f"
elif program_exists gvim; then
	export EDITOR="gvim -f"
elif program_exists vim; then
	export EDITOR="vim -f"
elif program_exists vi; then
	export EDITOR="vi -f"
fi

export VISUAL=$EDITOR
export SVN_EDITOR=$EDITOR

# Bash settings
shopt -s histappend
export HISTSIZE=1000000

#
# Aliases
#

if [[ $OSTYPE == darwin* ]]; then

	export CLICOLOR=1
	alias ls='ls -hF'

	alias .ap="cd '/Users/ivan/Library/Application Support/iPhone Simulator'"
	alias .ap51="cd '/Users/ivan/Library/Application Support/iPhone Simulator/5.1/Applications'"
	alias .ap60="cd '/Users/ivan/Library/Application Support/iPhone Simulator/6.0/Applications'"
	alias .ap61="cd '/Users/ivan/Library/Application Support/iPhone Simulator/6.1/Applications'"

	alias ramdisk='diskutil erasevolume HFS+ "Ramdisk" `hdiutil attach -nomount ram://4000000`'

	alias lock='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'

	alias sourcetree='open -a SourceTree'
	alias srctree='open -a SourceTree'

elif [[ $OSTYPE == linux* ]]; then
	alias ls='ls -hF --color=auto'
fi

alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias tunnel='ssh -C2qTnN -D 8080 ivan@zoid.cc'

if [ -x "$HOME/bin/svn-color.sh" ]; then
	. "$HOME/bin/svn-color.sh"
fi

#if program_exists rmtrash; then
#	alias rm=rmtrash
#fi

#
# mc
#
MC_WRAPPER="$HOME/private/bin/mc-wrapper.sh"
if [ -x $MC_WRAPPER ]; then
    alias mc=". $MC_WRAPPER" 
fi
unset MC_WRAPPER


# GIT
#
# Display unstaged (*) and staged(+) changes
export GIT_PS1_SHOWDIRTYSTATE="1"
# Display if there are untracked (%) files
export GIT_PS1_SHOWUNTRACKEDFILES="1"


function setPS1()
{
	# Reset
	local ColorOff='\[\e[0m\]'       # Text Reset

	# Regular Colors
	local ColorBlack='\[\e[0;30m\]'        # Black
	local ColorRed='\[\e[0;31m\]'          # Red
	local ColorGreen='\[\e[0;32m\]'        # Green
	local ColorYellow='\[\e[0;33m\]'       # Yellow
	local ColorBlue='\[\e[0;34m\]'         # Blue
	local ColorPurple='\[\e[0;35m\]'       # Purple
	local ColorCyan='\[\e[0;36m\]'         # Cyan
	local ColorWhite='\[\e[0;37m\]'        # White

	# Bold
	local ColorBBlack='\[\e[1;30m\]'       # Black
	local ColorBRed='\[\e[1;31m\]'         # Red
	local ColorBGreen='\[\e[1;32m\]'       # Green
	local ColorBYellow='\[\e[1;33m\]'      # Yellow
	local ColorBBlue='\[\e[1;34m\]'        # Blue
	local ColorBPurple='\[\e[1;35m\]'      # Purple
	local ColorBCyan='\[\e[1;36m\]'        # Cyan
	local ColorBWhite='\[\e[1;37m\]'       # White

	# Underline
	local ColorUBlack='\[\e[4;30m\]'       # Black
	local ColorURed='\[\e[4;31m\]'         # Red
	local ColorUGreen='\[\e[4;32m\]'       # Green
	local ColorUYellow='\[\e[4;33m\]'      # Yellow
	local ColorUBlue='\[\e[4;34m\]'        # Blue
	local ColorUPurple='\[\e[4;35m\]'      # Purple
	local ColorUCyan='\[\e[4;36m\]'        # Cyan
	local ColorUWhite='\[\e[4;37m\]'       # White

	# Background
	local ColorBgBlack='\[\e[40m\]'       # Black
	local ColorBgRed='\[\e[41m\]'         # Red
	local ColorBgGreen='\[\e[42m\]'       # Green
	local ColorBgYellow='\[\e[43m\]'      # Yellow
	local ColorBgBlue='\[\e[44m\]'        # Blue
	local ColorBgPurple='\[\e[45m\]'      # Purple
	local ColorBgCyan='\[\e[46m\]'        # Cyan
	local ColorBgWhite='\[\e[47m\]'       # White

	# High Intensty
	local ColorIBlack='\[\e[0;90m\]'       # Black
	local ColorIRed='\[\e[0;91m\]'         # Red
	local ColorIGreen='\[\e[0;92m\]'       # Green
	local ColorIYellow='\[\e[0;93m\]'      # Yellow
	local ColorIBlue='\[\e[0;94m\]'        # Blue
	local ColorIPurple='\[\e[0;95m\]'      # Purple
	local ColorICyan='\[\e[0;96m\]'        # Cyan
	local ColorIWhite='\[\e[0;97m\]'       # White

	# Bold High Intensty
	local ColorBIBlack='\[\e[1;90m\]'      # Black
	local ColorBIRed='\[\e[1;91m\]'        # Red
	local ColorBIGreen='\[\e[1;92m\]'      # Green
	local ColorBIYellow='\[\e[1;93m\]'     # Yellow
	local ColorBIBlue='\[\e[1;94m\]'       # Blue
	local ColorBIPurple='\[\e[1;95m\]'     # Purple
	local ColorBICyan='\[\e[1;96m\]'       # Cyan
	local ColorBIWhite='\[\e[1;97m\]'      # White

	# High Intensty backgrounds
	local ColorBgIBlack='\[\e[0;100m\]'   # Black
	local ColorBgIRed='\[\e[0;101m\]'     # Red
	local ColorBgIGreen='\[\e[0;102m\]'   # Green
	local ColorBgIYellow='\[\e[0;103m\]'  # Yellow
	local ColorBgIBlue='\[\e[0;104m\]'    # Blue
	local ColorBgIPurple='\[\e[10;95m\]'  # Purple
	local ColorBgICyan='\[\e[0;106m\]'    # Cyan
	local ColorBgIWhite='\[\e[0;107m\]'   # White

	GitStatus='$(__git_ps1 " (%s)")'

	export PS1="\n${ColorBRed}\h${ColorBGreen}${GitStatus}${ColorBBlue} \w\n\$${ColorOff} "

	if [[ "$HOSTNAME" == *zoid.cc* ]]; then
		export PS1="\n${ColorBRed}\u@\H \w\$${ColorOff} "
	fi
}

setPS1

# Go setup

if program_exists go; then

	export GOPATH=$HOME/Go
	export PATH="$GOPATH/bin:$PATH"

	function setupGOROOT()
	{
		local GOPATH=`which go`
		local GODIR=`dirname $GOPATH`
		local GOPATH_BREW_RELATIVE=`readlink $GOPATH`
		local GOPATH_BREW=`dirname $GOPATH_BREW_RELATIVE`
		export GOROOT=`cd $GODIR; cd $GOPATH_BREW/..; pwd`
	}
	#setupGOROOT
fi

if program_exists brew; then
	BREW_PREFIX=`brew --prefix`
	if [ -f $BREW_PREFIX/etc/bash_completion ]; then
		. $BREW_PREFIX/etc/bash_completion
	fi
	if [ -f $BREW_PREFIX/Library/Contributions/brew_bash_completion.sh ]; then
		. $BREW_PREFIX/Library/Contributions/brew_bash_completion.sh
	fi
fi

